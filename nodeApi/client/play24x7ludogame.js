var express = require("express");
var fs = require("fs");
var app = express();
var common_model = require('./socket/common_model.js');
var server =require('http').createServer(app);

var options = {transport: ['websocket']};
var io = require('socket.io')(options).listen(server);
 var server =require('https').createServer({
   key: fs.readFileSync('play24x7games_com.key'),
   cert: fs.readFileSync('play24x7games_com.crt'),
   ca: fs.readFileSync ('play24x7games_com.ca-bundle'),
   requestCert: false,
   rejectUnauthorized: false
},app);

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
server.listen(3005,function(){
  console.log('Socket listening on 3005 port');
}); 

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
updateTimers();
io.sockets.on('connection',function(socket){
    // for join room
    socket.on('joinRoom',function(data){
       joinRoomTable(socket,data);
	});
	socket.on("diceRoll",function(data){		
		var isTest = data.isTest;
		var number = Number(data.diceNumber);
		var passData={
			userId:socket.userId,
			tableId:socket.tableId
		};
		diceRollFunction(passData,isTest,number);
	});
	socket.on("moveToken",function(data){
		data['userId'] =socket.userId;
		data['tableId'] =socket.tableId;
		moveToken(data);
	});
	socket.on("disconnect",function(reason){
		if(socket.tableId){
			var match = findMatchByTableId(socket.tableId); 
			if(match){
				var player = findPlayerById(match,socket.userId);
				if(player){
                    socket.leave(socket.tableId);
                    console.log("leave")
                }
			}
		}
	});
	socket.on("userReconnect",function(data){
        userReconnect(socket,data);
    });
});
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
                var data = {
                    success:1,
                    message:"Reconnect Success"
                }
            }
        }
    }else{
        var data = {
            success:0,
            message:"Match is ended."
        }
    }
    io.to(socket.id).emit("userReconnectMsg",data);

}
//moveToken
function moveToken(data){
	var match = findMatchByTableId(data.tableId);	
	if(match){
		var player  = findPlayerById(match,data.userId);		
		if(player){
			var diceNum =match.matchDiceNumber;
			if(data.status=='Inactive' && diceNum!=6){

			}else if(player.isturn==true && diceNum!=0){
				match.isReturnMove = true;
				var sefPosition = [1,9,14,22,27,35,40,48,52,53,54,55,56,57];
				if(player.fourToken[data.tokenIndex].status == 'Inactive' && diceNum == 6){
					player.inactiveTokenCount -=1;
					player.fourToken[data.tokenIndex].postion =1;
					player.fourToken[data.tokenIndex].status = 'Active';
				}else if(player.fourToken[data.tokenIndex].status=='Active'){
					player.fourToken[data.tokenIndex].postion = Number(diceNum)+Number(player.fourToken[data.tokenIndex].postion);
					if(player.fourToken[data.tokenIndex].postion==57){
						player.fourToken[data.tokenIndex].status ='Win';
						player.fourToken[data.tokenIndex].winCount +=1;
						match.isReturn = true;
					}
					if(player.fourToken[data.tokenIndex].winCount==4){
						match.winPosition.winnerCount += 1;
						player.isWin = true;
						player.winPosition = match.winPosition.winnerCount;
					}
				}
				var gPosition = GetGlobalPositionFunction(player.fourToken[data.tokenIndex].postion,player.tokenGlobleValue);
				player.fourToken[data.tokenIndex].globlePostion = gPosition;
				var isKillToken = false;
				if(gPosition != -1){					
					var isKillToken = findKillingFunction(match,player,gPosition);
					if(isKillToken==true){
						match.isReturn = true;
						isKillToken = true;
					}
				}
				var isSafeIndex = sefPosition.indexOf(player.fourToken[data.tokenIndex].postion);
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
				match.matchDiceNumber= 0;
				match.isTokenMove= true;
			}
		}
	}
}
function findKillingFunction(match,player,gPosition){
	var isreturn = false;
	for (let i = 0; i < match.players.length; i++) {
		if(match.players[i].userId != player.userId){
			for (let j = 0; j < match.players[i].fourToken.length; j++) {
				if(gPosition==match.players[i].fourToken[j].globlePostion){		
					if(match.players[i].fourToken[j].zone=='kill'){
						match.players[i].fourToken[j].status='Inactive';
						match.players[i].fourToken[j].postion=0;
						match.players[i].fourToken[j].globlePostion=0;
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

//diceRollFunction
function diceRollFunction(data,isTest,num){
	var match = findMatchByTableId(data.tableId);
	if(match){
		var player  = findPlayerById(match,data.userId);
		if(player){				
			if(player.isturn==true && match.matchDiceNumber==0){
				var diceNumber = Math.floor(Math.random() * 6) + 1;		
				if(isTest=='Yes'){
					var diceNumber=num;
				}else{
					var diceNumber = Math.floor(Math.random() * 6) + 1;		
				}		
				if(diceNumber == 6){
					match.isReturn = true;
				}else{
					match.isReturn = false;
				}				
				var dicData={
					diceNumber:diceNumber,
					isReturn:match.isReturn,
					userId:player.userId
				};
				player.diceNumber= diceNumber;
				match.matchDiceNumber = diceNumber;
				io.to(match.tableId).emit("diceResult",dicData);
				if(player.inactiveTokenCount==4 && diceNumber != 6){
					timesup(match);
				}else if(player.inactiveTokenCount < 4){					
					var lastno = 0;
					for (let i = 0; i < player.fourToken.length; i++) {
						if(player.fourToken[i].status=='Active'){
							var no = 57 - player.fourToken[i].postion;
							if(lastno < no){
								lastno = no;
							}
						}						
					}
					if(lastno < diceNumber){
						timesup(match);
					}
				}
				
			}
		}
	}
}
// find to token position 
function  findTopTokenPosition(player){
	var topPostion = 57;
	for (let i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			var position = 57 - player.fourToken[j].postion;
			if(topPostion < position){

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
			if (matches[i].startRoundWaiting == 0) {
				matches.splice(matches.indexOf(matches[i]), 1);	
			}
        }else{
			
			if(matches[i].isTokenMove==true){
				matches[i].tokenMoveTime -= 1;
				io.in(matches[i].tableId).emit("tokenMoveTime",matches[i].tokenMoveTime); 
				if (matches[i].tokenMoveTime == 0) {
					matches[i].tokenMoveTime =matches[i].consttokenMoveTime;
					timesup(matches[i]);
				}
			}else{
				matches[i].throwDieTime -= 1; 
				io.in(matches[i].tableId).emit("rollDiceTimer",matches[i].throwDieTime);
				if (matches[i].throwDieTime == 0) {
					timesup(matches[i]);
				}
			}
		}
	}
	setTimeout(updateTimers, 1000);
}
// timesup
function timesup(match){
	 match.isTokenMove= false;
	 var player  = findIsTurnIndex(match);
	 if(player){
		var pIndex = match.players.indexOf(player);
		if (pIndex > -1){
			nextTurnFunction(match,pIndex,'normal');
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
function nextTurnFunction(match,pIndex,isDropFrom){ 
	match.matchDiceNumber = 0;
	if(match.isReturn==true && match.isReturnMove ==true){
		var currentTrn = pIndex;
	}else{
		var currentTrn = nextTurnIndex(match.players,pIndex);
	}
    for (let i = 0; i < match.players.length; i++) {
		match.players[i].diceNumber = 0;
        if(i == currentTrn){
            match.players[i].isturn=true;
        }else{
            match.players[i].isturn=false;
        }
    }
    if(isDropFrom == 'left'){
        match.players.splice(pIndex, 1);
	}    
	io.in(match.tableId).emit("playerObject",match.players);
	match.isReturn=false;
	match.isReturnMove=false;
    match.throwDieTime = match.constthrowDieTime;
}

// next index test
function nextTurnIndex(players,pIndex){
    if(players.length-1 == pIndex){
        next = 0;
    }else{
        next = pIndex+1;
    }   
    if(players[next].status != 'Active'){
        nextTurnIndex(players,next);
    }
    return next;
}
// find player list using socket id
function findPlayerById(match,socketId) {
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
			
			var tableId = res.joinRoomId;
			var userId = res.userId;
			var userName = res.userName;
			var tokenColor = res.tokenColor;
			var playerType = res.playerType;
			var playerObj ={
				winPosition:0,
				userName:userName,
				coins:res.coins,
				status:'Active',
				isBlocked:false,
				isWin:false,
				isturn:false,
				isStart:false,
				diceNumber:0,
				userId:userId,
				playerIndex:0,
				postionArray:[],
				fourToken:[{tokenIndex:0,postion:0,globlePostion:0,status:'Inactive',zone:'safe'},{tokenIndex:1,postion:0,globlePostion:0,status:'Inactive',zone:'safe'},{tokenIndex:2,postion:0,globlePostion:0,status:'Inactive',zone:'safe'},{tokenIndex:3,postion:0,globlePostion:0,status:'Inactive',zone:'safe'}],
				tokenColor:tokenColor,
				winnerPosition:0,
				socketId:socket.id,
				type:data.type,
				inactiveTokenCount:4,
				winCount:0,
				playerType:playerType,
				tokenTopPosition:57
			}
			socket.tableId = tableId;
			socket.userId= userId;
			socket.join(tableId);
			
			var match = findMatchByTableId(tableId);
			if(match){
				match.players.push(playerObj);	
				if(res.gameStatus=='Active'){
				    takePlayerIndex(match.players);
					var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;	
					match.players[rannum].isturn = true;	
					match.isGameStart = true;	  	
				}	
				io.in(socket.tableId).emit("playerObject",match.players);
			}else{
				var match = {
					tableId:tableId,
					isTokenMove:false,
					tokenMoveTime:2,
					consttokenMoveTime:2,
					isGameStart:false,
					winnerCount :0,
					startRoundWaiting:60,
					throwDieTime:20,
					constthrowDieTime:20,
					gamePlayerCount:Number(data.players),
					players:[],
					isReturn:false,
					isKill:false,
					matchDiceNumber:0,
					isReturnMove :false,
					gameBet:Number(data.value),
					winningBet:0
				}
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
// start Match Function
function startMatchFunction(match){
	for (let i = 0; i < match.players.length; i++) {		
		coinUpdateFunction(match,match.players[i],i);		
	}
}
function coinUpdateFunction(match,player,i){
	var data ={
		table:'pla24by7tbs_web.user_details',
		fields:'coins,user_id',
		condition:'user_id='+player.userId,
	};
	common_model.GetData(data,function(res){
		var coins = res.data[0].coins;
		var user_id = res.data[0].user_id;
		var lastCoin = coins - match.gameBet;		
		if(res.success==1){
			var passData ={
				table:'pla24by7tbs_web.user_details',
				setdata:'coins="'+lastCoin+'"',
				condition:'user_id='+user_id,
			};
			common_model.saveData(passData,function(res){
				match.winningBet +=  match.gameBet;
				player.coins = lastCoin;
				io.in(match.tableId).emit('winningBet',match.winningBet);
				io.to(player.socketId).emit('coinsUpdate',lastCoin);
				player.playerIndex = i;
				if(match.players.length==2 && i==1){			
					player.playerIndex = 2;
				}
				player.tokenColor = tokenColor[player.playerIndex];
				player.tokenGlobleValue = Number(tokenGlobleValue[player.playerIndex]);
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
// node express api
app.post('/getRoomDetails',function(req,res){
	var data={
		table:'ludo_mst_rooms',
		fields:'roomId,roomTitle,players,betValue',
		condition:"status='Active'"
	};
	common_model.GetData(data,function(response){
		res.send(response);
	});
   
});
