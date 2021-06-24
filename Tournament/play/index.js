var express = require("express");
var path = require('path');
const request = require('request');
var bodyParser = require("body-parser");
var cookieParser = require('cookie-parser');
var fs = require("fs");
var app = express();
var http = require('http');
var morgan = require('morgan');
var signUp = require('./login/signUp.js');
var config = require('./config.js');
var port     = process.env.PORT || config.port;
process.env.NODE_TLS_REJECT_UNAUTHORIZED=0;
var tournaments = require('./login/tournaments.js');
var dice = require('./login/dice.js');
var other = require('./login/other.js');

var common_model = require('./socket/common_model.js');
//var server =http.createServer(app);

const server =require('http').createServer(/*{
   key: fs.readFileSync('ludopower.key'),
   cert: fs.readFileSync('ludopower.crt'),
   ca: fs.readFileSync ('ludopower.ca-bundle'),
   requestCert: false,
   rejectUnauthorized: false
},*/app);
//const server =require('http').createServer(app);
var options = {transport: ['websocket']};

var io = require('socket.io')(options).listen(server, {
	handlePreflightRequest: (req, res) => {
		const headers = {
		   "Content-type": "application/json",
		   "Access-Control-Allow-Origin":"*",
		   "Access-Control-Allow-Methods":"GET, PUT, POST, DELETE, OPTIONS",
		   "Access-Control-Max-Age":"1000",
		   "Access-Control-Allow-Headers":"Content-Type, Authorization, X-Requested-With",
		   "Access-Control-Allow-Credentials":"true"
		};
		res.writeHead(200, headers);
		res.end();
	}
});
server.listen(port,function(){
	 console.log(config.portMsg)
});

//app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.set('view engine', 'ejs');

var tokenColor = ['Red','Blue','Yellow','Green'];
var tokenGlobleValue = ['0','13','26','39'];

function GetGlobalPositionFunction(currentPosition,globalValue){
	if (currentPosition > 51){
		return -1;
	}
	var tempPos = globalValue + currentPosition;
	if (tempPos > 52)
	{
		tempPos -= 52;
	}
	return tempPos;
}
var matches = [];
var connectCounter =1000;
updateTimers();
updateroom();
function updateroom() {
	var sql ="update ludo_join_rooms set activePlayer=0 where gameStatus='Pending'";
	common_model.sqlQuery(sql,function(res){
	  //  console.log(res)                  
	});
}
var totolBotMatches=0;
var currentBotMatches=0;
var totalPrivatePlayers = 340;
var totalOnlineGamePlayers = 480;
io.sockets.on('connection',function(socket){
	//console.log("connection")
	connectCounter++;
	socket.on('onlinePlayerCount',function(){
	   var isPrivateData={
			online:totalOnlineGamePlayers,
			private:totalPrivatePlayers
		};
		io.emit('onlinePlayerCount',isPrivateData);
	});
	// for join room
	socket.on('joinRoom',function(data){ 
	   joinRoomTable(socket,data);
	});
	socket.on('joinPrivateRoom',function(data){		
	   joinPrivateRoom(socket,data);
	});
	socket.on("diceRoll",function(data){
		var isTest = data.isTest;			
		var number = Number(data.diceNumber);
		var passData={
			userId:socket.userId,
			tableId:socket.tableId,
			playerType:'Real',
		};
		diceRollFunction(passData,isTest,number);
	});
	socket.on("moveToken",function(data){
		data['userId'] =socket.userId;
		data['tableId'] =socket.tableId;
		moveToken(data);
	});
	// disconnect
	socket.on("disconnect",function(reason){
		connectCounter --;
		io.emit('connectCounter',connectCounter);
		disconnectFunction(socket);
	});
	// user reconnect
	socket.on("userReconnect",function(data){
		userReconnect(socket,data);
	});
	 // for left table
	socket.on("leftFromTable",function(data){
		var data={
			tableId:socket.tableId,
			userId:socket.userId,
		};
		leftFromTable(socket,data);
	});
	// createPrivateRoom
	socket.on("createPrivateRoom",function(data){    	
		createPrivateRoom(socket,data);
	});
	socket.on("getPrivateRoomDetails",function(data){
		getPrivateRoomDetails(socket,data);
	});
	socket.on('sendMessage',function(data){
	   sendMessage(data);
	});
});
// add bot function 
function addBotsFunction(match){ 
	if(match){
		var remainingPlayer =3;
		if(remainingPlayer > 0){
			var sql ="select id,user_id,user_name,coins from user_details where playerType='Bot' order by rand() limit 3";
			common_model.sqlQuery(sql,function(res){
				if(res.success==1){ 
					match.botUsersData =res.data;  
					joinBotDataFunction(match,0);
				}                       
			});
		}
	}
}
//join Bot Data Function 
function joinBotDataFunction(match,position){
	if(match.botUsersData[position]){
		var userData= {
				userId:match.botUsersData[position].id,
				roomId:match.roomId,
				players:match.matchPlayers,
				value:match.matchValue,
				playerType:'Bot',
				gameMode:match.gameMode,
				isFree:'No',
				tableId:match.tableId
		}
		joinBotsRoom(userData);
	}
}

function winLossCoinsDistribution(match){
	//console.log("length "+match.players.length);
	var tBotAmount =0;
	for (var i = 0; i < match.players.length; i++) {
		if(match.players[i].playerType=='Bot'){
			tBotAmount += (Number(parseFloat(match.matchValue)) * Number(parseFloat(match.adminCommision)/100));
		}
	}
	//console.log("tBotAmount "+tBotAmount)
	for (var i = 0; i < match.players.length; i++) {
		var isBotWin = "No";
		if(match.players[i].isDeductMoney=="No" && match.isFree=="No" ){
			match.players[i].isDeductMoney="Yes";
			if(match.players[i].isWin==true){				
				var isAdd= "Add";
				var isWin= "Win";
				var adminAmount = (parseFloat(match.winningBet)*parseFloat(match.adminCommision)/100);
				var winningPrice =(parseFloat(match.winningBet) - parseFloat(adminAmount));
				
				var lastAmount = parseFloat(winningPrice) -parseFloat(match.matchValue);
				if(match.players[i].playerType=='Bot'){
					isBotWin ="Yes";
					var adAmt = (Number(parseFloat(match.matchValue)) * Number(parseFloat(match.adminCommision)/100));
					lastAmount =  (Number(parseFloat(lastAmount)) +  Number(parseFloat(adAmt)));
				}else{
					//lastAmount +=Number(parseFloat(tBotAmount)) ;
				}
			}else{
				var adAmt = (Number(parseFloat(match.matchValue)) * Number(parseFloat(match.adminCommision)/100));
				if(match.players[i].playerType == 'Bot'){
					var lastAmount = parseFloat(match.matchValue) - parseFloat(adAmt);
				}else{
					var lastAmount = parseFloat(match.matchValue);
				}
				
				var isAdd= "Sub";
				var isWin= "Loss";
			}
			if(match.players[i].playerType=='Bot'){
				var adminCoins = 0;
			}else{
				var adminCoins = (Number(parseFloat(match.matchValue)) * Number(match.adminCommision)/100);
			}
			//var betValue =Number(parseFloat(match.matchValue))- (Number(parseFloat(match.matchValue)) * Number(parseFloat(match.adminCommision)/100));
			var coinsDeductData={
				userId:match.players[i].userId,
				coins:lastAmount,
				tableId:match.players[i].tableId,
				gameType:match.roomTitle+' '+match.gameMode,
				betValue:match.matchValue,
				rummyPoints:0,
				isWin:isWin,
				adminCommition:match.adminCommision,
				type:isAdd,
				adminCoins:adminCoins,
			};
			  common_model.userCoinsUpdate(coinsDeductData,function(respon){		
				// console.log(respon)	      
				//console.log("userCoinsUpdate")	      
			  });
			 
		}
	}
	 if(isBotWin=='Yes'){
		var adminAmount = (parseFloat(match.winningBet)*parseFloat(match.adminCommision)/100);
		var winningPrice =(parseFloat(match.winningBet) - parseFloat(adminAmount));

		// var adminWithBetAmt = parseFloat(match.matchValue) -(parseFloat(match.matchValue)*parseFloat(match.adminCommision)/100);
		// var adminWithBetAmt = Number(parseFloat(adminWithBetAmt)) *Number(parseFloat(match.noOfBots)); 
		
		//if(match.isDeductReservemoney=="Yes"){
		var lastUpAmt =winningPrice;
		// }else{
		// 	var lastUpAmt=parseFloat(winningPrice) - parseFloat(adminWithBetAmt);		    			
		// }
		var myJSONObject = {amount:lastUpAmt,type:"Add",roomId:match.roomId,isSub:"Yes"};
		//updateReserveAmount(myJSONObject);
	}
	
}
function joinBotsRoom(data){
	common_model.joinBotsRoomTable(data,function(res){
		if(res.success==1){	
			var tableId = res.joinRoomId;
			var userId = res.userId;
			var userName = res.userName;
			var tokenColor = res.tokenColor;
			var playerType = res.playerType;
			var playerObj ={
				image:res.profile,
				isDeductMoney:"No",
				tableId:tableId,
				roomId:res.roomId,
				winPosition:0,
				diceSixInTurn:0,
				userName:userName,
				totalLifes:3,
				coins:res.coins,
				status:'Active',
				isBlocked:false,
				isWin:false,
				isturn:false,
				isStart:false,
				diceNumber:0,
				userId:userId,
				playerIndex:0,
				positionArray:[],
				// fourToken:[{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}],
				fourToken:fourTokenArray,
				tokenColor:tokenColor,
				winnerPosition:0,
				socketId:res.userId,
				type:res.playerType,
				inactiveTokenCount:4,
				winCount:0,
				playerType:playerType,
				tokenTopPosition:57,
			};	
			
			var match = findMatchByTableId(tableId);
			if(match){
				match.isAddBot = true;
				match.noOfBots += 1;
				match.players.push(playerObj);	
				if(match.players.length==match.matchPlayers){		
					takePlayerIndex(match.players);
					var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
					match.players[rannum].isturn = true;
					match.whosTurn	=	match.players[rannum].playerType;
					match.currentTurnUserId	=	match.players[rannum].userId;
					updateStatus(match);					
				}
				io.in(tableId).emit("playerObject",match.players);
			}
		}       
	});
}
// join private room
function joinPrivateRoom(socket,data){
	common_model.joinPrivateRoom(data,function(res){		
		if(res.success==1){		
			if(res.gameMode == 'Quick'){
				var fourTokenArray = [{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'}];
			} else {
				var fourTokenArray = [{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}];
			}
			var tableId = res.joinRoomId;
			var userId = res.userId;
			var userName = res.userName;
			var tokenColor = res.tokenColor;
			var playerType = res.playerType;
			var playerObj ={
				image:res.profile,
				isDeductMoney:"No",
				tableId:tableId,
				roomId:res.roomId,
				winPosition:0,
				diceSixInTurn:0,
				userName:userName,
				totalLifes:3,
				coins:res.coins,
				status:'Active',
				isBlocked:false,
				isWin:false,
				isturn:false,
				isHold:false,
				isHoldPositionPlay:false,
				holdPosition:[],
				isStart:false,
				diceNumber:0,
				userId:userId,
				playerIndex:0,
				positionArray:[],
				fourToken:[{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}],
				tokenColor:tokenColor,
				winnerPosition:0,
				socketId:socket.id,
				type:data.type,
				inactiveTokenCount:4,
				winCount:0,
				playerType:playerType,
				tokenTopPosition:57,
			};	
			socket.tableId = tableId;
			socket.userId= userId;
			socket.join(tableId);	
			totalPrivatePlayers +=1;
			var isPrivateData={
				online:totalOnlineGamePlayers,
				private:totalPrivatePlayers
			};
			
			io.emit('onlinePlayerCount',isPrivateData);	
			var match = findMatchByTableId(tableId);
			if(match){
				match.players.push(playerObj);	
				if(match.players.length==match.matchPlayers){		
					takePlayerIndex(match.players);
					var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
					match.players[rannum].isturn = true;
					match.whosTurn	=	match.players[rannum].playerType;			
					match.currentTurnUserId	=	match.players[rannum].userId;			
					updateStatus(match);					
				}
				io.in(socket.tableId).emit("playerObject",match.players);
			}else{
				var match = {
					tableId:tableId,
					roomId:res.roomId,
					roomTitle:res.roomTitle,
					isDeductReservemoney:"No",
					isBotConnect:res.isBotConnect,
					isFree:res.isFree,
					botWin:'No',
					isTokenMove:false,
					tokenMoveTime:2,
					consttokenMoveTime:2,
					isGameStart:false,
					winnerCount :0,
					startRoundWaiting:60,
					gameOverTime:5,
					isGameOver:false,
					throwDieTime:20,
					constthrowDieTime:20,
					botthrowDieTime:20,
					matchPlayers:Number(res.players),
					leftPlayers:Number(res.players),
					players:[],
					isReturn:false,
					disableDice:false,
					isKill:false,
					isAddBot:false,
					noOfBots:0,
					isBotFirstSix:false,
					currentRoundBot:Number(res.currentRoundBot),
					totalRoundBot:Number(res.totalRoundBot),
					isBotWinner:false,
					matchDiceNumber:0,
					isReturnMove :false,
					matchValue:Number(data.value),
					winningBet:0,
					gameMode:res.gameMode,
					isPrivate:res.isPrivate,
					botUsersData:[],
					whosTurn:false,
					currentTurnUserId:false,
					adminCommision:Number(res.adminCommision),
				};
				match.players.push(playerObj);			
				matches.push(match);		
				io.in(socket.tableId).emit("playerObject",match.players);
			}
			io.to(socket.id).emit("sessionMessage",res.message);
		}else{
			io.to(socket.id).emit("sessionMessage",res.message);
		}   
	});
}


function sendMessage(data){
	io.in(data.tableId).emit("sendMessage",data);
}
function getPrivateRoomDetails(socket,data){
	var data ={
		table:'ludo_join_rooms',
		fields:'joinRoomId,roomId,noOfPlayers,betValue,gameMode',
		condition:'isPrivate="Yes" and joinRoomId="'+data.tableId+'"',
	};
	common_model.GetData(data,function(res){	
		
		var  passData ={};
		if(res.success==1){
			var passData ={
				roomId:res.data[0].roomId,
				tableId:res.data[0].joinRoomId,
				players:res.data[0].noOfPlayers,
				gameMode:res.data[0].gameMode,
				betValue:res.data[0].betValue,
			};
		}
		passData['success']=res.success;
		passData['message']=res.message;
		io.to(socket.id).emit("getPrivateRoomDetails",passData);			
	});
}
// create Private Room
function createPrivateRoom(socket,data) {
	 common_model.createPrivateRoom(data,function(res){
		var  passData ={};
		if(res.success==1){
			var passData ={
				roomId:res.roomId,
				tableId:res.joinRoomId,
				gameMode:res.gameMode,
				betValue:res.betValue,
				players:data.players,
				isFree:data.isFree,
			}
		}
		passData['success']=res.success;
		passData['message']=res.message;	 	
		io.to(socket.id).emit("getPrivateRoomDetails",passData);
	 });
}

// when disconnect 
function disconnectFunction(socket){
	var match = findMatchByTableId(socket.tableId);
	if(match){
		var player = findPlayerById(match,socket.userId);
		if(player){
			var pIndex  = match.players.indexOf(player);
			var playerlength = match.players.length; 
			var updateData = {
				tableId:socket.tableId,
				userId:socket.userId,
				playerlength:playerlength -1,
				isGameStart:match.isGameStart
			}
			common_model.dbUpdates(updateData);
			if(!match.isGameStart){
				if (pIndex > -1){
					match.players.splice(pIndex, 1);
				}
				if(playerlength==1){
					matches.splice(matches.indexOf(match), 1);
				}
			}
			io.in(match.tableId).emit("playerObject",match.players);
			socket.leave(socket.tableId);  
		}          
	}
}

// when user left the table
function leftFromTable(socket,data){
	var match = findMatchByTableId(data.tableId);
	if(match){
		var player = findPlayerById(match,data.userId);
		if(player){
			for (var i = 0; i < player.fourToken.length; i++) {
				player.fourToken[i].status='Inactive';
				player.fourToken[i].position=0;
				player.fourToken[i].globlePosition=0;
				player.fourToken[i].zone='safe';
				player.inactiveTokenCount += 1;
			}
			var pIndex  = match.players.indexOf(player);
			var playerlength =match.players.length; 
			var updateData = {
				tableId:data.tableId,
				userId:data.userId,
				playerlength:playerlength -1,
				isGameStart:match.isGameStart
			}
			common_model.dbUpdates(updateData);
			if(match.isGameStart){
				
				if(match.isPrivate=="No"){
					totalOnlineGamePlayers -=1;
				}else{
					totalPrivatePlayers -=1;
				}
				var isPrivateData={
					online:totalOnlineGamePlayers,
					private:totalPrivatePlayers
				};
				io.emit('onlinePlayerCount',isPrivateData);
				 if (pIndex > -1) {
					if(player.isDeductMoney=="No" && match.isFree=="No" && player.playerType=='Real'){
						var adminCoins = (Number(parseFloat(match.matchValue)) * Number(match.adminCommision)/100);
						player.isDeductMoney="Yes";
						var coinsDeductData={
						  userId:player.userId,
						  coins:match.matchValue,
						  tableId:player.tableId,
						  gameType:match.roomTitle+' '+match.gameMode,
						  betValue:match.matchValue,
						  rummyPoints:0,
						  isWin:"Loss",
						  adminCommition:match.adminCommision,
						  type:"Sub",
						  adminCoins:adminCoins,
					  };

					  common_model.userCoinsUpdate(coinsDeductData,function(respon){
					  });
					}
					if(player.isturn == true){
						player.isBlocked=true;
						player.status="left";
						match.leftPlayers -=1;
						if(match.leftPlayers!=1){
							nextTurnFunction(match,pIndex);
						}
					}else{
						player.isBlocked=true;
						player.status="left";
						match.leftPlayers -=1;
						//match.players.splice(pIndex, 1);
					}
				}
			}else{
				if (pIndex > -1){
					match.players.splice(pIndex, 1);
				}
				if(playerlength==1){
					matches.splice(matches.indexOf(match), 1);
				}
			}
			io.in(match.tableId).emit("playerObject",match.players);
			if(socket!=''){
				socket.leave(data.tableId);  
			}
		}          
	}
	
}
//getLastActivePlayer
function getLastActivePlayer(match){	
	for (var i = 0; i < match.players.length; i++) {
		if(match.players[i].status=='Active'){
			 return match.players[i];
		}
	}
	return false;

}
// reconnect user
function userReconnect(socket,data){
	var match = findMatchByTableId(data.tableId);    
	if(match){
		var player = findPlayerById(match,data.userId);
		if(player){
			if(match.isGameOver){
				var data = {
					success:2,
					message:"Match is ended."
				};
			}else{
				socket.tableId = player.tableId;
				socket.userId= player.userId;
				player.socketId = socket.id;
				socket.join(data.tableId);
				io.to(player.socketId).emit("playerObject",match.players);
				io.to(player.socketId).emit("jocker",match.jocker);
				io.to(player.socketId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
				io.to(player.socketId).emit("updateCards",player.cards);
				io.in(match.tableId).emit("isBotWinner",match.botWin);
				var data = {
					success:1,
					message:"Reconnect Success",
				};
			}
		}
	}else{
		var data = {
			success:0,
			message:"Match is ended."
		};
	}
	io.to(socket.id).emit("userReconnectMsg",data);

}
//moveToken
function moveToken(data){
	// console.log(data)
	var match = findMatchByTableId(data.tableId);	
	if(match){
		var player = findPlayerById(match,data.userId);		
		if(player){
			var diceNum =match.matchDiceNumber;
			if(data.status=='Inactive' && diceNum!=6 && diceNum!=1 && (!player.isHold || (data.holdPosition!=6 && data.holdPosition!=1))){

			} else if(player.isturn==true && (diceNum!=0 || player.isHold)) {
				match.isReturnMove = true;
				var sefPosition = [1,9,14,22,27,35,40,48,52,53,54,55,56,57];
				var isMove ="Yes";
				if(player.fourToken[data.tokenIndex].status=='Active') {
					if(player.isHold){
						var movPosition = Number(data.holdPosition)+Number(player.fourToken[data.tokenIndex].position);		
					} else {
						var movPosition = Number(diceNum)+Number(player.fourToken[data.tokenIndex].position);
					}
					if(movPosition > 57){
						isMove="No";
						/*player.isHold = false;
						player.holdPosition = [];*/
					}
				}
				if(player.isHold){
					if(!player.isHoldPositionPlay){
						isMove = 'No';
					}
				}
				if(isMove=='Yes'){
					if(player.fourToken[data.tokenIndex].status == 'Inactive'){
						if(player.isHold && (data.holdPosition==6 || data.holdPosition==1)){
							player.inactiveTokenCount -=1;
							player.fourToken[data.tokenIndex].position =1;
							player.fourToken[data.tokenIndex].status = 'Active';
							for(let i = 0; i < player.holdPosition.length; i++){
								if(player.holdPosition[i] == data.holdPosition){
									player.holdPosition.splice(i, 1);
									break;
								}
							}
						} else if(diceNum == 1){
							if(diceNum == 1){ // && player.inactiveTokenCount==4
								player.inactiveTokenCount -=1;
								player.fourToken[data.tokenIndex].position =1;
								player.fourToken[data.tokenIndex].status = 'Active';
							}
						}
					}else if(player.fourToken[data.tokenIndex].status=='Active'){
						if(player.isHold){
							player.fourToken[data.tokenIndex].position = Number(data.holdPosition)+Number(player.fourToken[data.tokenIndex].position);
							for(let i = 0; i < player.holdPosition.length; i++){
								if(player.holdPosition[i] == data.holdPosition){
									player.holdPosition.splice(i, 1);
									break;
								}
							}
							/*if(player.holdPosition.length==0){
								player.isHold = false;
								player.holdPosition = [];				
							}*/
						} else {
							player.fourToken[data.tokenIndex].position = Number(diceNum)+Number(player.fourToken[data.tokenIndex].position);
						}
						if(player.fourToken[data.tokenIndex].position==57){
							player.fourToken[data.tokenIndex].status ='Win';
							player.winCount +=1;
							match.isReturn = true;
						}
						if(match.gameMode=='Quick'){
							if(player.winCount==1){
								match.winnerCount += 1;
								player.isWin = true;
								player.winPosition = match.winnerCount;
								match.isGameOver =true;
								winLossCoinsDistribution(match);
								io.in(data.tableId).emit("playerObject",match.players);
							}
						}else{
							if(player.winCount==4){
								match.winnerCount += 1;
								player.isWin = true;
								player.winPosition = match.winnerCount;
								winLossCoinsDistribution(match);
								match.isGameOver =true;
								io.in(data.tableId).emit("playerObject",match.players);
							}
						}
					}

					if(player.holdPosition.length==0){
						player.isHold = false;
						player.diceSixInTurn = false;
						player.holdPosition = [];
						player.isHoldPositionPlay = false;
						match.disableDice = true;
					}

					var gPosition = GetGlobalPositionFunction(player.fourToken[data.tokenIndex].position,player.tokenGlobleValue);
					
					player.fourToken[data.tokenIndex].globlePosition = gPosition;
					var isKillToken = false;
					if(gPosition != -1){
						var isKillToken = findKillingFunction(match,player,gPosition);
						if(isKillToken==true){
							match.isReturn = true;
							match.disableDice = false;
							isKillToken = true;
						}
					}
					var isSafeIndex = sefPosition.indexOf(player.fourToken[data.tokenIndex].position);
					if (isSafeIndex > -1){
						player.fourToken[data.tokenIndex].zone = 'safe';
					}else{
						player.fourToken[data.tokenIndex].zone = 'kill';
					}
					var tokenResulltData={
						tokenIndex:data.tokenIndex,
						isKillToken:isKillToken,
						userId:player.userId,
						diceNum:diceNum
					};
					io.in(match.tableId).emit('moveTokenResult',tokenResulltData);
					match.matchDiceNumber = 0;
					if(!player.isHold && player.holdPosition.length==0){
						match.isReturn = false;
						match.isReturnMove = false;
						match.isTokenMove= true;
						if(isKillToken == true){
							match.disableDice = false;
							match.isReturn = true;
							match.isReturnMove = true;
						}
					} else {
						io.in(match.tableId).emit("playerObject",match.players);
					}
				}
			}
		}
	}
}
// winner function coins distribution
function winnerFuncion(match,player) {
	var data ={
		table:'user_details',
		fields:'coins,user_id,balance',
		condition:'user_id='+player.userId,
	};
	var adminAmount = (parseFloat(match.winningBet)*parseFloat(match.adminCommision)/100);
	var winningPrice =(parseFloat(match.winningBet) - parseFloat(adminAmount));
	common_model.GetData(data,function(res){	
		if(res.success==1){
			var balance = res.data[0].balance;
			var user_id = res.data[0].user_id;
			var lastCoin = Number(parseFloat(winningPrice)) +Number(parseFloat(balance));	
			player.coins = lastCoin;
			io.in(match.tableId).emit('winningBet',0);
			io.to(player.socketId).emit('coinsUpdate',lastCoin);
			// update user coins data to ludo_join_rooms
			var passData ={
				table:'user_details',
				setdata:'balance="'+lastCoin+'"',
				condition:'user_id='+user_id,
			};
			common_model.SaveData(passData,function(res){

			});
			// update data to ludo_join_rooms
			var passData2 ={
				table:'ludo_join_rooms',
				setdata:'gameStatus="Complete"',
				condition:'joinRoomId='+match.tableId,
			};
			common_model.SaveData(passData2,function(res1){
				// update data to ludo_join_room_users 
				var passData3 ={
					table:'ludo_join_room_users',
					setdata:'isWin="Yes"',
					condition:'joinRoomId="'+match.tableId+'" and userId="'+user_id+'"',
				};
				common_model.SaveData(passData3,function(res2){
				// insert winner data to ludo_winners
					var ludoWinData ={
						table:'ludo_winners',
						setdata:'joinRoomId="'+match.tableId+'",userId="'+user_id+'",adminPercent="'+match.adminCommision+'",totalWinningPrice="'+match.winningBet+'",adminAmount="'+adminAmount+'",winningPrice="'+winningPrice+'",gameMode="'+match.gameMode+'",isPrivate="'+match.isPrivate+'",created=now()',
						condition:'',
					};
					common_model.SaveData(ludoWinData,function(res3){
						
					});
				});
			});
			
		}
	});	
}

function findKillingFunction(match,player,gPosition){
	var isreturn = false;
	for (let i = 0; i < match.players.length; i++) {
		if(match.players[i].userId != player.userId){
			for (let j = 0; j < match.players[i].fourToken.length; j++) {
				if(gPosition==match.players[i].fourToken[j].globlePosition){		
					if(match.players[i].fourToken[j].zone=='kill'){
						match.players[i].fourToken[j].status='Inactive';
						match.players[i].fourToken[j].position=0;
						match.players[i].fourToken[j].globlePosition=0;
						match.players[i].fourToken[j].zone='safe';
						match.players[i].inactiveTokenCount += 1;						
						isreturn = true;
					}						
				}
			}			
		}				
	}
	return isreturn;
}

// diceRollFunction
function diceRollFunction(data,isTest,num){
	var match = findMatchByTableId(data.tableId);
	if(match){
		var player  = findPlayerById(match,data.userId);

		if(player){
			if(player.isturn==true && match.matchDiceNumber==0){
				console.log(match.disableDice)
				if(!match.disableDice){
					var diceNumber = Math.floor(Math.random() * 6) + 1;		
					if(isTest=='Yes'){
						diceNumber=Number(num);
					}	

					if(diceNumber == 6){
						player.diceSixInTurn +=1;
						match.isReturn = true;
						match.isReturnMove = true;
						player.isHold = true;
						player.holdPosition.push(diceNumber); 
					} else {
						if(player.isHold){
							player.holdPosition.push(diceNumber);
							player.isHoldPositionPlay = true;
							match.isReturnMove = true;
							match.isReturn = true;
						} else {
							player.diceSixInTurn = 0;
							match.isReturn = false;				
						}
						match.disableDice = true;
					}

					if(player.diceSixInTurn >= 3){
						player.diceSixInTurn = 0;
						match.isReturn = false;
						match.isTokenMove= true;
						player.isHold = false;
						match.disableDice = false;
						player.holdPosition = []; 
					}

					var dicData={
						diceNumber:diceNumber,
						isReturn:match.isReturn,
						userId:player.userId
					};
					player.diceNumber= diceNumber;
					match.matchDiceNumber = diceNumber;
					
					io.to(match.tableId).emit("diceResult",dicData);
					
					if(player.inactiveTokenCount == 4 && diceNumber != 6 && diceNumber != 1){
						if(player.isHold){
							match.isTokenMove= false;
						} else {
							match.isTokenMove= true;						
						}
					} else if(player.inactiveTokenCount == 4 && player.isHold){
						match.isTokenMove= true;
					} else if(player.inactiveTokenCount < 4){
						var lastno = 0;
						for (let i = 0; i < player.fourToken.length; i++) {
							if(player.fourToken[i].status=='Active'){
								var no = 57 - player.fourToken[i].position;
								if(lastno < no){
									lastno = no;
								}
							}						
						}
						if(player.isHold == true && diceNumber==6){
							match.isTokenMove= true;
						} else if(player.isHold == true && diceNumber!=6){
							match.isTokenMove= false;
						}
						if(diceNumber==6 && player.inactiveTokenCount > 0){
						} else if(lastno < diceNumber){
							match.isTokenMove= true;
						}
					}
					if(player.isHold){
						io.in(match.tableId).emit("playerObject",match.players);
					}
				}

			}
		}
	}
}

// find to token position 
function findTopTokenPosition(player){
	var topposition = 57;
	for (let i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			var position = 57 - player.fourToken[j].position;
			if(topposition < position){

			}
		}		
	}
}

// update timmer function
function updateTimers(){
	for (var i = 0; i < matches.length; i++) {        	
		if(!matches[i].isGameStart){
			matches[i].startRoundWaiting -= 1;
			io.in(matches[i].tableId).emit("startRoundWaiting",matches[i].startRoundWaiting);	
			if(matches[i].isPrivate=='No'){
				if(matches[i].isBotConnect=="Yes"){
					if(matches[i].startRoundWaiting==35){
						addBotsFunction(matches[i]);
					}	
					if(matches[i].startRoundWaiting==25){
						joinBotDataFunction(matches[i],1);
					}	
					if(matches[i].startRoundWaiting==15){
						joinBotDataFunction(matches[i],2);
					}
				}
				
				if (matches[i].startRoundWaiting == 0) {
					for (var j = 0; j < matches[i].players.length; j++) {
						var updateData = {
							tableId:matches[i].tableId,
							userId:matches[i].players[j].userId,
							playerlength:0,
							isGameStart:matches[i].isGameStart
						}
						common_model.dbUpdates(updateData);
					}					 
					matches.splice(matches.indexOf(matches[i]), 1);	
				}
			}
		}else{
			if(matches[i].isGameOver==false && matches[i].leftPlayers==1){
				var winPlayer = getLastActivePlayer(matches[i]);
				winPlayer.isWin= true;
				matches[i].isGameOver =true;
				winLossCoinsDistribution(matches[i]);
				io.in(matches[i].tableId).emit("playerObject",matches[i].players);
			}else if(matches[i].isGameOver==true){
				matches[i].gameOverTime -= 1;
				io.in(matches[i].tableId).emit("gameOverTime",matches[i].gameOverTime); 
				if (matches[i].gameOverTime == 0) {
					matches.splice(matches.indexOf(matches[i]), 1);                    
				}
			}else if(matches[i].isTokenMove==true){
				matches[i].tokenMoveTime -= 1;
				io.in(matches[i].tableId).emit("tokenMoveTime",matches[i].tokenMoveTime); 
				if (matches[i].tokenMoveTime == 0) {
					matches[i].tokenMoveTime =matches[i].consttokenMoveTime;
					timesup(matches[i],'Yes');
				}
			}else{
				matches[i].throwDieTime -= 1; 
				if(matches[i].throwDieTime==matches[i].botthrowDieTime && matches[i].whosTurn=='Bot'){   
					botDiceRollFunction(matches[i]);	                                 
				}
				io.in(matches[i].tableId).emit("rollDiceTimer",matches[i].throwDieTime);
				if (matches[i].throwDieTime == 0) {
					matches[i].isReturn = false;
					matches[i].isReturnMove = false;
					timesup(matches[i],'No');
				}
			}
		}
	}
	setTimeout(updateTimers, 1000);
}

function getDiceNo(match,player){
	player.diceSixInTurn =0;
	if(match.botWin=="Yes"){
		var diceNum  =  [4,5];
	}else{
		var diceNum  =  [3,4,5];
	}		
	var randomNum = diceNum[Math.floor(Math.random()*diceNum.length)];
	return randomNum;
}

function findWinningNumber(player){
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			if(player.fourToken[i].position >=51 && player.fourToken[i].position <57){
				var num = 57-Number(player.fourToken[i].position);
				return num;
			}
		}
	}
	return false;
}

function getUnsafeToken(match,player){
	var data={
		tokenPosition:0,
		number:5,
		token:false
	};
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active' && player.fourToken[i].zone=='kill'){
			var globlePosition = Number(player.fourToken[i].globlePosition);
			var globlePosition2 = Number(player.fourToken[i].globlePosition) - Number(6);
			for (var j = 0; j < match.players.length; j++) {
				if(player.userId != match.players[j].userId){
					for (var k = 0; k < match.players[j].fourToken.length; k++) {
						var oppositeGloblePosition = Number(match.players[j].fourToken[k].globlePosition);
						if(globlePosition > oppositeGloblePosition && globlePosition2 < oppositeGloblePosition && match.players[j].fourToken[k].status=='Active'){
							if(data.tokenPosition < globlePosition){
								var gNum= globlePosition - oppositeGloblePosition;
								data.tokenPosition=globlePosition;
								data.token=player.fourToken[i];
							}
						}						
					}
				}					
			}
		}		
	}
	return data;
}
function moveTopPostionToken(player){
	//if(0 < 40){
	var movedata={
		tokenPosition:0,
		token:false
	};
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			if(movedata.tokenPosition < player.fourToken[i].position){
				movedata.tokenPosition =player.fourToken[i].position;
				movedata.token =player.fourToken[i];
			}
		}
	}
	return movedata;
}
// bot dice roll function 
function botDiceRollFunction(match){
	var timeArray = [2000,3000,4000];
	var randomTime=timeArray[Math.floor(Math.random()*timeArray.length)];

	var passData={
		userId:match.currentTurnUserId,
		tableId:match.tableId
	};
	
	var player  = findIsTurnIndex(match);
	if(player){	
		if(match.botWin == "Yes"){
			var diceNum  =  [6,5,6];
			//console.log("Yes Yes")
		}else{
			var diceNum  =  [4,5,6];
			//var diceNum  =  [1,2,3];
			//console.log("no no no")
		}
		var randomNum = diceNum[Math.floor(Math.random()*diceNum.length)];
		
		var winnerNumber=findWinningNumber(player);
		var killingNumber=getKillerPositionNumber(match,player);
		var isBehindToken=getUnsafeToken(match,player);
		var moveTopPosition=moveTopPostionToken(player);
		// if(player.diceSixInTurn==1){
		// 	randomNum =6;
		// }

		if(player.diceSixInTurn==0){
			randomNum =6;
		}
		if(match.isBotFirstSix==false){
			randomNum=6;
			match.isBotFirstSix=true;
		}else if(winnerNumber){
			randomNum = winnerNumber;
		}else if(killingNumber){
			randomNum = killingNumber;
		}else if(isBehindToken.token){
			randomNum = isBehindToken.number;
		}

		if(player.diceSixInTurn==2){
			var getranNum = getDiceNo(match,player);
		}else{
			var getranNum = randomNum;
		}

		var randomNum =getranNum;
		
		diceRollFunction(passData,"Yes",randomNum); 
			var isKillerToken = isKillerTokenFunction(match,player,randomNum);
			var isSafferToken = isSafferTokenFunction(player,randomNum);
			var isWinnerToken = isWinnerTokenFunction(player,randomNum);
		setTimeout(function() {
			//if(isKillerToken)
			if(player.inactiveTokenCount==4 && randomNum == 6){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:player.fourToken[0].tokenIndex,
					status:player.fourToken[0].status,
				};
				moveToken(data);	
			}else if(isWinnerToken){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:isWinnerToken.tokenIndex,
					status:isWinnerToken.status,
				};
				moveToken(data);
			}else if(isKillerToken){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:isKillerToken.tokenIndex,
					status:isKillerToken.status,
				};
				moveToken(data);
			}else if(isBehindToken.token){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:isBehindToken.token.tokenIndex,
					status:isBehindToken.token.status,
				};
				moveToken(data);
			}else if(match.gameMode=='Quick' && player.inactiveTokenCount==2 && moveTopPosition.token!=false){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:moveTopPosition.token.tokenIndex,
					status:moveTopPosition.token.status,
				};
				
				moveToken(data);
			}else if(isSafferToken){
				var data ={
					userId:player.userId,
					tableId:player.tableId,
					tokenIndex:isSafferToken.tokenIndex,
					status:isSafferToken.status,
				};
				moveToken(data);
			}else if(player.inactiveTokenCount==3){
				var activeTokenDetail = findActiveToken(player,randomNum);
				var activeCurrentPosition = activeTokenDetail.position + randomNum;
				if(randomNum != 6){
					if(activeCurrentPosition <= 57){
						var data ={
							userId:player.userId,
							tableId:player.tableId,
							tokenIndex:activeTokenDetail.tokenIndex,
							status:activeTokenDetail.status,
						};
						moveToken(data);
					}				
				}else if(randomNum==6){
					var inactiveTokenDetail = findInactiveToken(player);
					var inactiveCurrentPosition = inactiveTokenDetail.position + randomNum;
					var data ={
						userId:player.userId,
						tableId:player.tableId,
						tokenIndex:inactiveTokenDetail.tokenIndex,
						status:inactiveTokenDetail.status,
					};
					moveToken(data);
				}
			}else if(player.inactiveTokenCount!=0 && randomNum==6){
				var allActiveTokenData = findActiveTokenWithGposition(player,randomNum);
				if(allActiveTokenData.isKillReturn==true){
					var rannum  = Math.floor(Math.random() * (allActiveTokenData.tokenKillArray.length - 0)) + 0;
					var data ={
						userId:player.userId,
						tableId:player.tableId,
						tokenIndex:allActiveTokenData.tokenKillArray[rannum].tokenIndex,
						status:allActiveTokenData.tokenKillArray[rannum].status,
					};
					moveToken(data);					
				}else{
					var inactiveTokenDetail = findInactiveToken(player);
					var inactiveCurrentPosition = inactiveTokenDetail.position + randomNum;
					var data ={
						userId:player.userId,
						tableId:player.tableId,
						tokenIndex:inactiveTokenDetail.tokenIndex,
						status:inactiveTokenDetail.status,
					};
				}
				
				moveToken(data);
			}else{
				var allActiveTokenData = findActiveTokenWithGposition(player,randomNum);
				if(allActiveTokenData.isKillReturn==true){
					var rannum  = Math.floor(Math.random() * (allActiveTokenData.tokenKillArray.length - 0)) + 0;
					var data ={
						userId:player.userId,
						tableId:player.tableId,
						tokenIndex:allActiveTokenData.tokenKillArray[rannum].tokenIndex,
						status:allActiveTokenData.tokenKillArray[rannum].status,
					};
					moveToken(data);					
				}else{
					if(allActiveTokenData.isSafeReturn==true){
						var rannum  = Math.floor(Math.random() * (allActiveTokenData.tokenSafeArray.length - 0)) + 0;
						var data ={
							userId:player.userId,
							tableId:player.tableId,
							tokenIndex:allActiveTokenData.tokenSafeArray[rannum].tokenIndex,
							status:allActiveTokenData.tokenSafeArray[rannum].status,
						};
						moveToken(data);					
					}
				}
			}
		},randomTime);		
	}	
}

function getKillerPositionNumber(match,player){
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			var globlePosition = Number(player.fourToken[i].globlePosition);
			var globlePosition2 = Number(player.fourToken[i].globlePosition) + Number(6);
			for (var j = 0; j < match.players.length; j++) {
				if(player.userId != match.players[j].userId){
					for (var k = 0; k < match.players[j].fourToken.length; k++) {
						var oppositeGloblePosition = Number(match.players[j].fourToken[k].globlePosition);
						if(oppositeGloblePosition > globlePosition && oppositeGloblePosition <= globlePosition2 && match.players[j].fourToken[k].zone=='kill' && match.players[j].fourToken[k].status=='Active'){
							var gNum= oppositeGloblePosition - globlePosition;
							return gNum;
						}						
					}
				}					
			}
		}		
	}
	return false;
}
function isKillerTokenFunction(match,player,randomNum){
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			//var globlePosition = player.fourToken[i].globlePosition + randomNum;
			var globlePosition = Number(player.fourToken[i].globlePosition) + Number(randomNum);
			for (var j = 0; j < match.players.length; j++) {
				if(player.userId != match.players[j].userId){
					for (var k = 0; k < match.players[j].fourToken.length; k++) {
						if(match.players[j].fourToken[k].globlePosition==globlePosition && match.players[j].fourToken[k].zone=='kill' && match.players[j].fourToken[k].status=='Active'){
							return player.fourToken[i];
						}
					}
				}					
			}
		}
	}
	return false;
}
function isSafferTokenFunction(player,randomNum){
	var sefPosition = [1,9,14,22,27,35,40,48,52,53,54,55,56,57];				
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			var currentPosition = Number(player.fourToken[i].position) + Number(randomNum);
			var isSafeIndex = sefPosition.indexOf(currentPosition);
			if (isSafeIndex > -1){
				return player.fourToken[i];
			}	
		}
			
	}
	return false;
}
function isWinnerTokenFunction(player,randomNum){
	for (var i = 0; i < player.fourToken.length; i++) {
		var currentPosition = Number(player.fourToken[i].position) + Number(randomNum);
		if(player.fourToken[i].status=='Active' && currentPosition==57){
			return player.fourToken[i];
		}
	}
	return false;
}
// find active token
function findisKillToken(player){
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			return player.fourToken[i];
		}
	}
	return false;
}
// find active token
function findActiveToken(player,randomNum){
	for (var i = 0; i < player.fourToken.length; i++) {
		var activeCurrentPosition = player.fourToken[i].position + randomNum;
		if(player.fourToken[i].status=='Active' && activeCurrentPosition==57){
			return player.fourToken[i];
		}
	}
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			return player.fourToken[i];
		}
	}
	return false;
}
//var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
// find active token
function findActiveTokenWithGposition(player,randomNum){
	var data = {
		tokenSafeArray:[],
		tokenKillArray:[],
		isSafeReturn:false,
		isKillReturn:false
	};
	for (var i = 0; i < player.fourToken.length; i++) {
		var activeCurrentPosition = player.fourToken[i].position + randomNum;
		if(player.fourToken[i].status=='Active' &&  activeCurrentPosition <= 57 && player.fourToken[i].zone =="safe"){
			data.isSafeReturn = true;
			data.tokenSafeArray.push(player.fourToken[i]);
		}
	}
	for (var i = 0; i < player.fourToken.length; i++) {
		var activeCurrentPosition = player.fourToken[i].position + randomNum;
		if(player.fourToken[i].status=='Active' &&  activeCurrentPosition <= 57 && player.fourToken[i].zone =="kill"){
			data.isKillReturn = true;
			data.tokenKillArray.push(player.fourToken[i]);
		}
	}
	return data;
}
// find active token
function findInactiveToken(player){
	for (var i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Inactive'){
			return player.fourToken[i];
		}
	}
	return false;
}
// find active token
function activeTokenCurrentPosition(player){
	// var activePlayerGpositoion = 0;
	// for (var i = 0; i < player.fourToken.length; i++) {
	// 	if(player.fourToken[i].status=='Active'){
	// 		return player.fourToken[i];
	// 	}
	// }
}
// timesup
function timesup(match,isPlay){
	match.isTokenMove= false;
	var player  = findIsTurnIndex(match);
	 
	if(player){
		var pIndex = match.players.indexOf(player);
		if (pIndex > -1){
			if(isPlay=='No'){
				player.totalLifes -=1;
				player.isHold = false;
				player.diceSixInTurn = 0;
				player.holdPosition = [];
				player.isHoldPositionPlay = false;
			}
			if(player.totalLifes==0){
				var data={
					tableId:player.tableId,
					userId:player.userId,
				};
				leftFromTable('',data);
			} else {
				nextTurnFunction(match,pIndex);
			}
		}
	}
}
// findIsTurnIndex
function findIsTurnIndex(match){
	var players = match.players;
	for (let i = 0; i < players.length; i++) {
		if(players[i].isturn == true){
		   return players[i];
		}
	}
	return false;
}

// next turn function
function nextTurnFunction(match,pIndex){
	var timeArray  = [2,3,2,3,2,3,2,3,3,2,3];
	var randomTime = timeArray[Math.floor(Math.random()*timeArray.length)];
	match.botthrowDieTime =match.constthrowDieTime -randomTime;

	match.matchDiceNumber = 0;
	if(match.isReturn==true && match.isReturnMove ==true){
		var currentTrn = pIndex;
	}else{
		match.disableDice = false;
		var currentTrn = nextTurnIndex(match,pIndex);
	}
	for (let i = 0; i < match.players.length; i++) {
		match.players[i].diceNumber = 0;
		if(i == currentTrn){
			match.whosTurn = match.players[i].playerType;
			match.currentTurnUserId = match.players[i].userId;
			match.players[i].isturn=true;
		}else{
			match.players[i].isturn=false;
		}
	}
 
	io.in(match.tableId).emit("playerObject",match.players);
	match.isReturn=false;
	match.isReturnMove=false;
	match.throwDieTime = match.constthrowDieTime;
}

// next index test
function nextTurnIndex(match,pIndex){
	if(match.leftPlayers!=1){
		if(match.players.length-1 == pIndex){
			next = 0;
		}else{
			next = pIndex+1;
		} 
		if(match.players[next].status != 'Active'){
			nextTurnIndex(match,next);
		}
		return next;
	}
	
}
// find player list using socket id
function findPlayerById(match,userId) {
	for (var i = 0; i < match.players.length; i++) {
		if (match.players[i].userId  ==  userId) {
			return match.players[i];
		}       
	}
	return false;
}

function joinRoomTable(socket,data){
	common_model.joinTableFunc(data,function(res){
		if(res.success==1){	
			if(res.gameMode == 'Quick'){
				var fourTokenArray = [{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'}];
			} else {
				var fourTokenArray = [{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}];
			}
			var tableId = res.joinRoomId;
			var userId = res.userId;
			var userName = res.userName;
			var tokenColor = res.tokenColor;
			var playerType = res.playerType;
			var playerObj ={
				image:res.profile,
				isDeductMoney:"No",
				tableId:tableId,
				roomId:res.roomId,
				winPosition:0,
				diceSixInTurn:0,
				userName:userName,
				totalLifes:3,
				coins:res.coins,
				status:'Active',
				isBlocked:false,
				isWin:false,
				isturn:false,
				isHold:false,
				isHoldPositionPlay:false,
				holdPosition:[],
				isStart:false,
				diceNumber:0,
				userId:userId,
				playerIndex:0,
				positionArray:[],
				// fourToken:[{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}],
				fourToken:fourTokenArray,
				tokenColor:tokenColor,
				winnerPosition:0,
				socketId:socket.id,
				type:data.type,
				inactiveTokenCount:4,
				winCount:0,
				playerType:playerType,
				tokenTopPosition:57,
			};	
			socket.tableId = tableId;
			socket.userId= userId;
			socket.join(tableId);		
			var match = findMatchByTableId(tableId);
			totalOnlineGamePlayers+=1;
			var isPrivateData={
				online:totalOnlineGamePlayers,
				private:totalPrivatePlayers
			};
			io.emit('onlinePlayerCount',isPrivateData);
			if(match){
				match.players.push(playerObj);	
				if(match.players.length==match.matchPlayers){		
					takePlayerIndex(match.players);
					var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
					match.players[rannum].isturn = true;
					match.whosTurn	=	match.players[rannum].playerType;			
					match.currentTurnUserId	=	match.players[rannum].userId;			
					updateStatus(match);					
				}
				io.in(tableId).emit("playerObject",match.players);
			}else{
				var match = {
					tableId:tableId,
					roomId:res.roomId,
					roomTitle:res.roomTitle,
					isDeductReservemoney:"No",
					isBotConnect:res.isBotConnect,
					isFree:res.isFree,
					botWin:'No',
					isTokenMove:false,
					tokenMoveTime:2,
					consttokenMoveTime:2,
					isGameStart:false,
					winnerCount :0,
					// startRoundWaiting:60,
					startRoundWaiting:15,
					gameOverTime:5,
					isGameOver:false,
					throwDieTime:20,
					constthrowDieTime:20,
					botthrowDieTime:20,
					matchPlayers:Number(res.players),
					leftPlayers:Number(res.players),
					players:[],
					isReturn:false,
					/*isHold:false,
					isHoldPositionPlay:false,
					holdPosition:[],*/
					disableDice:false,
					isKill:false,
					isAddBot:false,
					noOfBots:0,
					isBotFirstSix:false,
					currentRoundBot:Number(res.currentRoundBot),
					totalRoundBot:Number(res.totalRoundBot),
					isBotWinner:false,
					matchDiceNumber:0,
					isReturnMove :false,
					matchValue:Number(data.value),
					winningBet:0,
					gameMode:res.gameMode,
					isPrivate:res.isPrivate,
					botUsersData:[],
					whosTurn:false,
					currentTurnUserId:false,
					adminCommision:Number(res.adminCommision),
				};
				match.players.push(playerObj);			
				matches.push(match);		
				io.in(tableId).emit("playerObject",match.players);
			}
			io.to(socket.id).emit("sessionMessage",res.message);
		}else{
			io.to(socket.id).emit("sessionMessage",res.message);
		}        
	});
	
}
// var totolBotMatches=0;
// var currentBotMatches=0;
function updateStatus(match){
	if(match){
		var data ={
			table:'ludo_join_rooms',
			setdata:"gameStatus='Active'",
			condition:"joinRoomId="+match.tableId
		} 
		common_model.SaveData(data,function(res){
			var timeArray  =  [2,3,2,3,2,3,2,3,4,3,2,3,4];
			var randomTime = timeArray[Math.floor(Math.random()*timeArray.length)];
			match.botthrowDieTime =match.constthrowDieTime -randomTime;
		   

			if(match.isFree=="No"){
				//startMatchFunction(match);
			}
			match.winningBet =0;
			for (let i = 0; i < match.players.length; i++) {
				match.winningBet +=  Number(match.matchValue);	
			}
			io.in(match.tableId).emit('winningBet',match.winningBet);	

			if(match.isAddBot==true){
				var data ={
					roomId:match.roomId,
				};
				var data2={
					isSub:"Yes",
					type:"Sub"
				};
				//botDeductMoney(match,data2);
				// update currnbotwin round in room table 
				common_model.updateRoom(data,function(res){
					if(res.success==1){
						if(res.currentRoundBot <=5){
							match.botWin="Yes";
							io.in(match.tableId).emit("isBotWinner","Yes");
						}else{
							match.botWin ="No";
							io.in(match.tableId).emit("isBotWinner","No");
						}        				
					}else{
						match.botWin="Yes";
						io.in(match.tableId).emit("isBotWinner","Yes");
					}
					match.isGameStart = true;
				});
			}else{
				match.isGameStart = true;
			}
			
		});
	}
}


// start Match Function
function startMatchFunction(match){
	
	for (let i = 0; i < match.players.length; i++) {
		coinUpdateFunction(match,match.players[i],i);		
	}
}
//takePlayerIndex tokenColor
function takePlayerIndex(players){
	for (let i = 0; i < players.length; i++) {
		players[i].isStart = true;
		players[i].playerIndex = i;
		if(players.length==2 && i==1){			
			players[i].playerIndex = 2;
		}
		players[i].tokenColor = tokenColor[players[i].playerIndex];
		players[i].tokenGlobleValue = Number(tokenGlobleValue[players[i].playerIndex]);
	}
}
function coinUpdateFunction(match,player,i){
	var data ={
		table:'user_details',
		fields:'coins,user_id,balance',
		condition:'user_id='+player.userId,
	};
	common_model.GetData(data,function(res){			
		if(res.success==1){
			var balance = res.data[0].balance;
			var user_id = res.data[0].user_id;
			var lastCoin = balance - match.matchValue;	
			var passData ={
				table:'user_details',
				setdata:'balance="'+lastCoin+'"',
				condition:'user_id='+user_id,
			};
			common_model.SaveData(passData,function(res){
				//match.winningBet +=  match.matchValue;
				player.coins = lastCoin;
				
				io.to(player.socketId).emit('coinsUpdate',lastCoin);				
			});
		}
	});
	
}
// find match object using table id
function findMatchByTableId(tableId){
	for (var i = 0; i < matches.length; i++) {
		if (matches[i].tableId  ==  tableId) {
			return matches[i];
		}
	}
	return false;
}



// bot deduct money
function botDeductMoney(match,data){
	var adminCommision =match.adminCommision;
	var betValue =match.matchValue;
	var roomId =match.roomId;	
	var noOfBots =match.noOfBots;	

	var usrAmt = Number(parseFloat(betValue)) - (Number(parseFloat(betValue)) * Number(adminCommision)/100);
	var usrAmt = Number(parseFloat(usrAmt)) *Number(parseFloat(noOfBots)); 
	var url = 'https://www.ludopower.com/api/index.php/Amount/ludoReserveAmount';
	var myJSONObject = {amount:usrAmt,type:data.type,roomId:roomId,isSub:data.isSub,isLive:config.isLive};
	request({
		  url: url,
		  method: "POST",
		  headers : {
		   "Content-type": "application/json",
		   "Access-Control-Allow-Origin":"*",
		   "Access-Control-Allow-Methods":"GET, PUT, POST, DELETE, OPTIONS",
		   "Access-Control-Max-Age":"1000",
		   "Access-Control-Allow-Headers":"Content-Type, Authorization, X-Requested-With",
		   "Access-Control-Allow-Credentials":"true"
		  },
		  json: true,
		  body: myJSONObject
		},function (error, response, body){
		   // console.log(body)
			if(error){
				var returnData={
					success:0,
				};
			}else{
				var returnData={
					success:body.success,
				};
				if(body.success==1){
					io.emit("updateReserveDashboard","");
					if(body.getData.isDeduct=='No'){
						//console.log("one")
						match.isDeductReservemoney = "No";
					   // match.botWin = "Yes";
					}else{
						//console.log("TWO")
						match.isDeductReservemoney = "Yes";
					   // match.botWin = "No";
					}                
				}else{
						//console.log("three")
				   // match.botWin = "Yes";
					match.isDeductReservemoney = "No";
				}
				match.isGameStart = true;
			}
			
		   // io.in(match.tableId).emit("isBotWinner",match.isDeductReservemoney);
			return returnData;
	  });
	
}

function updateReserveAmount(data){
	var url = 'https://www.ludopower.com/api/index.php/Amount/ludoReserveAmount';
	//var myJSONObject = {amount:'1000',type:"add",field:reserveFieldName};
   // var myJSONObject = {amount:data.amount,type:data.type,field:fieldname};
	var myJSONObject = {amount:data.amount,type:data.type,roomId:data.roomId,isSub:data.isSub,isLive:config.isLive};
	request({
		  url: url,
		  method: "POST",
		  headers : {
		   "Content-type": "application/json",
		   "Access-Control-Allow-Origin":"*",
		   "Access-Control-Allow-Methods":"GET, PUT, POST, DELETE, OPTIONS",
		   "Access-Control-Max-Age":"1000",
		   "Access-Control-Allow-Headers":"Content-Type, Authorization, X-Requested-With",
		   "Access-Control-Allow-Credentials":"true"
		  },
		  json: true,
		  body: myJSONObject
		},function (error, response, body){
			//console.log("updateReserveAmount")
			//console.log(body)
		   
	  });
}


app.get('/',function(req,res){
	res.end('WELCOME TO NODE');
});


app.post("/signUp",function(req,res){
	var reqData = req.body;
	signUp.registration(reqData,function(response){
		 res.send(response);
	});
});


app.post("/forgotPassword",function(req,res){
		var reqData = req.body;
		signUp.forgotPassword(reqData,function(response){
			res.send(response);
		});
});


app.post("/OtpVerify",function(req,res){
	var reqData = req.body;
	signUp.OtpVerifyFunction(reqData,function(response){
		res.send(response);
	});
});


app.post("/resendOtp",function(req,res){
	var reqData = req.body;
	signUp.ResendOtpFunction(reqData,function(response){
		res.send(response);
	});
});


app.post("/changePassword",function(req,res){
	var reqData =req.body;
	signUp.changePassword(reqData,function(response){
		res.send(response);
	});
});

app.post("/updateProfile",function(req,res){
	var reqData = req.body;
	signUp.profileUpdateFunction(reqData,function(response){
		res.send(response);
	});
});


app.post("/login",function(req,res){
			var reqData =req.body;
			signUp.loginAction(reqData,function(response){
			res.send(response);
		});
});


/*---------------------------- Get tournaments ------------------------------*/

app.post("/getTournaments",function(req,res){
	var reqData = req.body;
	tournaments.getTournaments(reqData,function(response){
		res.send(response);
	});
});


/*---------------------------- Get Bonus ------------------------------*/
app.post("/getBonus",function(req,res){
	 var reqData = req.body;
	 tournaments.getBonus(reqData,function(response){
		res.send(response);
	 });
});

/*---------------------------- Get Rooms ------------------------------*/

app.post("/getRoomDetails",function(req,res){
	 var reqData = req.body;
	 tournaments.getRoomDetails(reqData,function(response){
		res.send(response);
	 });
});

/*---------------------------- Update Device Id ------------------------------*/
app.post("/updateDevice",function(req,res){
	var reqData = req.body;
	 signUp.updateDeviceId(reqData,function(response){
		res.send(response);
	 });
});



/*---------------------------- Update player progress ------------------------------*/
app.post("/updateplayerProgress",function(req,res){
  var reqData = req.body;
	 tournaments.updateplayerProgress(reqData,function(response){
		res.send(response);
	 });
});


/*---------------------------- Get player progress------------------------------*/

app.post("/getplayerProgress",function(req,res){
	 var reqData = req.body;
	 tournaments.getplayerProgress(reqData,function(response){
		res.send(response);
	 });
});


/*---------------------------- Get transaction list------------------------------*/

app.post("/getTransactionList",function(req,res){
	 var reqData = req.body;
	 tournaments.getTransactionListByCustId(reqData,function(response){
		res.send(response);
	 });
});

/*---------------------------- Get transaction list------------------------------*/
app.post("/purchaseDice",function(req,res){
		var reqData =req.body;
		dice.purchaseDice(reqData,function(response){
			res.send(response);
		});
});

//------------------ save support------------------------------------
app.post("/support",function(req,res){
	var reqData =req.body;
	tournaments.addSupport(reqData,function(response){
		res.send(response);
	});
});

app.post("/getSupport",function(req,res){
	var reqData =req.body;
	tournaments.getSupport(reqData,function(response){
		res.send(response);
	});
});
/*------------------- For get game version -------------------------*/
app.post("/getGameVersion",function(req,res){
	var reqData =req.body;
	dice.getGameVersion(reqData,function(response){
		res.send(response);
	});
});


/*------------------- get top 30 players record -------------------------*/
app.post("/topPlayersRecord",function(req,res){
	var reqData =req.body;
	other.topPlayersRecord(reqData,function(response){
		res.send(response);
	});
});

/*------------------- get items record -------------------------*/
app.post("/getItems",function(req,res){
	var reqData =req.body;
	dice.getItems(reqData,function(response){
		res.send(response);
	});
});


/*------------------- get admin Percent record -------------------------*/
app.post("/getadminPercent",function(req,res){
	var reqData =req.body;
	other.getadminPercent(reqData,function(response){
		res.send(response);
	});
});
