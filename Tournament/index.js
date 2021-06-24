var express = require("express");
var path = require('path');
require('dotenv').config();
const request = require('request');
var bodyParser = require("body-parser");
var cookieParser = require('cookie-parser');
var fs = require("fs");
var app = express();
var http = require('http');
var morgan = require('morgan');
var config = require('./config.js');
var port     = process.env.PORT || config.port;
// process.env.NODE_TLS_REJECT_UNAUTHORIZED=0;
var tournament = require('./model/tournament.js');

var common_model = require('./model/common_model.js');

const model = require('./model/test_model.js');
var sql ="select * from user_details where id='1'"
var sql2 ="CALL joinTournament('3','7','1','Blue')"
async function get(){
    var query1 = await model.manualQuery(sql);
    console.log(query1,"query1")

}
async function get2(){
    var query1 = await model.procedure(sql2);
    console.log(query1,"procedure")

}
// const getd= async ()=>{
//     var query1 = await model.procedure(sql2);
//     console.log(query1,"procedurdsfsarde")
// }

// get2();
const server =require('http').createServer(app);
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
//skill!@#
//app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.set('view engine', 'ejs');



function pad(number, length) {
    var str = ''+number;
    while (str.length < length) {
        str = '0' + str;
    }
    return str;

}

Date.prototype.YYYYMMDDHHMMSS = function () {
    var yyyy = this.getFullYear().toString();
    var MM = pad(this.getMonth() + 1,2);
    var dd = pad(this.getDate(), 2);
    var hh = pad(this.getHours(), 2);
    var mm = pad(this.getMinutes(), 2);
    var ss = pad(this.getSeconds(), 2);
    return yyyy +'-'+ MM +'-'+ dd+' '+  hh +':'+ mm +':'+ ss;
};

function getDateTime() {
    d = new Date();
    return d.YYYYMMDDHHMMSS();
}



Date.prototype.DT = function () {
    var yyyy = this.getFullYear().toString();
    var MM = pad(this.getMonth() + 1,2);
    var dd = pad(this.getDate(), 2);
    var hh = pad(this.getHours() , 2);
    var mm = pad(this.getMinutes(), 2);
    var ss = pad(this.getSeconds(), 2);
    var date = yyyy +'-'+ MM +'-'+ dd;
    var time = hh +':'+ mm +':'+ ss;
    var dateTime = yyyy +'-'+ MM +'-'+ dd+' '+  hh +':'+ mm +':'+ ss;
    var data = {
        date:date,
        time:time,
        dateTime:dateTime,
    }
    return data;
   // retu rn yyyy +'-'+ MM +'-'+ dd+' '+  hh +':'+ mm +':'+ ss;
};

function getDateTimeHrAdd() {
    today = new Date();
    today.setMinutes(today.getMinutes() + 10);
    return today.DT();
}
// console.log(getDateTimeHrAdd())
var matches = [];
var totolBotMatches=0;
var currentBotMatches=0;
var totalPrivatePlayers = 340;
var totalOnlineGamePlayers = 480;
updateJoinRoomTable();
function updateJoinRoomTable() {
    var query="update ludo_join_tour_rooms set activePlayer=0 where joinTourRoomId!='0' and gameStatus='Active';update ludo_join_tour_rooms set activePlayer=0,isDelete='Yes' where joinTourRoomId!='0' and gameStatus='Pending';update tournament_registrations set isEnter='No' where roundStatus='Pending'";
    common_model.sqlQuery(query,function(res){
       // console.log(res)
    });
    
};



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
var tournamentMatches=[];
var connectCounter =1000;
updateTimers();
updateroom();
function updateroom() {
	var sql ="update ludo_join_rooms set activePlayer=0 where gameStatus='Pending'";
    common_model.sqlQuery(sql,function(res){
    });
}
var totolBotMatches=0;
var currentBotMatches=0;
var totalPrivatePlayers = 340;
var totalOnlineGamePlayers = 480;
io.sockets.on('connection',function(socket){
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
    socket.on("usedBooster",function(data){
    	var data={
    		tableId:data.tableId,
			userId:data.userId,
			type:data.type,
    	};
        usedBooster(data);
    });
      socket.on("addChoiceBooster",function(data){
    	var data={
    		tableId:data.tableId,
			userId:data.userId,
			number:data.number,
    	};
        addChoiceBooster(data);
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
	socket.on('joinTournament',function(data){  
        // console.log(data)
		joinTournament(socket,data);
	});
});
// find match object using table id
function findTournamentMatchByTorunamentId(tournamentId){
    // console.log(tournamentId)
    // console.log("tournamentId")
    for (var i = 0; i < tournamentMatches.length; i++) {
        if (tournamentMatches[i].tournamentId  ==  tournamentId) {
            return tournamentMatches[i];
        }
    }
    return false;
}
// find match object using table id
function findMatchByTournamentId(tournamentId){
    for (var i = 0; i < matches.length; i++) {
        if (matches[i].tournamentId  ==  tournamentId) {
            return matches[i];
        }
    }
    return false;
}
async function joinTournament(socket,data){
// const joinTournament = async (socket,data)=>{
    var userId = data.userId;
    var tournamentId = data.tournamentId;
    var currentRound = data.currentRound;
    var tokenColor = data.color;
    var sqlprocedure = "CALL joinTournament('"+userId+"','"+tournamentId+"','"+currentRound+"','"+tokenColor+"')";
     console.log(sqlprocedure)
    var response = await model.procedure(sqlprocedure);
     console.log(response)
    if(response.success==1){  
        var obj = JSON.parse(response.result);    
        var tableId = obj.joinTourRoomId;
            var userId = obj.userId;
            var userName = obj.userName;
            var tokenColor = obj.tokenColor;
            var playerType = obj.playerType;
            // console.log(tableId);
            var playerObj ={
                image:obj.profile,
                isDeductMoney:"No",
                tableId:tableId,
                roomId:obj.tournamentId,
                tournamenLogtId:obj.tournamenLogtId,
                currentRound:Number(obj.currentRound),
                winPosition:0,
                diceSixInTurn:0,
                userName:userName,
                totalLifes:3,
                coins:0,
                status:'Active',
                isBlocked:false,
                isWin:false,
                isturn:false,
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
                tossValue:0,
                randomBooster:0,
                choiseBooster:0,
                isExtratime:false,
                extratime:20,
            };  
            // console.log(playerObj)
            socket.tableId = tableId;
            socket.userId= userId;
            socket.join(tableId);
            var match = findMatchByTableId(tableId);
            if(match){
                match.players.push(playerObj);
                if(match.players.length==match.matchPlayers){    
                    if(match.matchPlayers==2){
                        match.isTossTimmer=1;
                    }           
                    updateStatus(match);  
                }
                io.in(tableId).emit("playerObject",match.players);
            }else{
                var tournamentMatch = findTournamentMatchByTorunamentId(obj.tournamentId);
                if(!tournamentMatch){
                    var toruData={
                        tournamentId:obj.tournamentId,
                        currentRound:Number(obj.currentRound),
                        startRoundWaiting:Number(data.remainingTable),
                        playerLimitInRoom:Number(obj.playerLimitInRoom),
                    };
                    //  console.log(toruData)
                    //  console.log("toruData")
                    tournamentMatches.push(toruData);
                }
                 var match = {
                    tableId:tableId,
                    roomId:obj.tournamentId,
                    tournamenLogtId:obj.tournamenLogtId,
                    tournamentId:obj.tournamentId,
                    currentRound:obj.currentRound,
                    roomTitle:obj.roomTitle,
                    isDeductReservemoney:"No",
                    isBotConnect:"No",
                    isFree:"No",
                    botWin:'No',
                    isTokenMove:false,
                    tokenMoveTime:2,
                    consttokenMoveTime:2,
                    isGameStart:false,
                    winnerCount :0,
                    startRoundWaiting:Number(data.remainingTable),
                    gameOverTime:5,
                    isGameOver:false,
                    throwDieTime:20,
                    constthrowDieTime:20,
                    botthrowDieTime:20,
                    matchPlayers:Number(obj.playerLimitInRoom),
                    leftPlayers:Number(obj.playerLimitInRoom),
                    players:[],
                    isReturn:false,
                    isKill:false,
                    isAddBot:false,
                    noOfBots:0,
                    isBotFirstSix:false,
                    currentRoundBot:Number(0),
                    totalRoundBot:Number(0),
                    isBotWinner:false,
                    matchDiceNumber:0,
                    isReturnMove :false,
                    matchValue:Number(data.value),
                    winningBet:0,
                    gameMode:obj.gameMode,
                    isPrivate:"No",
                    botUsersData:[],
                    whosTurn:false,
                    currentTurnUserId:false,
                    adminCommision:Number(0),
                    startDate:obj.startDate,
                    startTime:obj.startTime,
                    entryFee:obj.entryFee,
                    playerLimitInRoom:Number(obj.playerLimitInRoom),
                    isToss:false,
                    isTossTimmer:1,
                    startDicePosition:[],
                };
                match.players.push(playerObj);   
                matches.push(match);        
                io.in(tableId).emit("playerObject",match.players);
            }
            io.to(socket.id).emit("sessionMessage",response.message);
    }else{
        io.to(socket.id).emit("sessionMessage",response.message);
    }
    // console.log(query1,"procedurdsfsarde")
}
//join table join tournament 
function joinTournamentold(socket,data){   
// console.log(data); 
    tournament.joinTournament(data,function(response){     
    // console.log(response)    
       if(response.success==1){  
        var obj = JSON.parse(response.result);   
            var tableId = obj.joinTourRoomId;
            var userId = obj.userId;
            var userName = obj.userName;
            var tokenColor = obj.tokenColor;
            var playerType = obj.playerType;
            var playerObj ={
                image:obj.profile,
                isDeductMoney:"No",
                tableId:tableId,
                roomId:obj.tournamentId,
                tournamenLogtId:obj.tournamenLogtId,
                currentRound:Number(obj.currentRound),
                winPosition:0,
                diceSixInTurn:0,
                userName:userName,
                totalLifes:3,
                coins:0,
                status:'Active',
                isBlocked:false,
                isWin:false,
                isturn:false,
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
                tossValue:0,
				randomBooster:0,
				choiseBooster:0,
				isExtratime:false,
				extratime:20,
            };  
            // console.log(playerObj)
            socket.tableId = tableId;
            socket.userId= userId;
            socket.join(tableId); 
            // console.log(obj.tournamentId)
            var tournamentMatch = findTournamentMatchByTorunamentId(obj.tournamentId);
            if(!tournamentMatch){
                var toruData={
                    tournamentId:obj.tournamentId,
                    currentRound:Number(obj.currentRound),
                    startRoundWaiting:Number(data.remainingTable),
                    playerLimitInRoom:Number(obj.playerLimitInRoom),
                };
                //  console.log(toruData)
                //  console.log("toruData")
                tournamentMatches.push(toruData);
            }else{
                 // console.log("toruDatatoruDatatoruDatatoruDatatoruDatatoruData")
            }
            var match = findMatchByTableId(tableId);
                      // totalOnlineGamePlayers+=1;
            if(match){
                console.log("if if if if if if if if   ");
                // match['matchPlayers'] = Number(obj.playerLimitInRoom);
                // match['leftPlayers']  =  Number(obj.playerLimitInRoom);
                match.players.push(playerObj);  

                // console.log("length "+match.players.length)
                // console.log("matchPlayers "+match.matchPlayers)
                if(match.players.length==match.matchPlayers){    
                	if(match.matchPlayers==2){
						match.isTossTimmer=1;
					}			
					// updateStatus(match);
                	 // console.log("if if if if if if if if   11");
                  //   takePlayerIndex(match);
                  //   var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
                  //   match.players[rannum].isturn = true;
                  //   match.whosTurn  =   match.players[rannum].playerType;           
                  //   match.currentTurnUserId =   match.players[rannum].userId;           
                    updateStatus(match);  
                    // console.log("if if if if if if if if   2222");                  
                }
                io.in(tableId).emit("playerObject",match.players);
            }else{  	
                var match = {
                    tableId:tableId,
                    roomId:obj.tournamentId,
                    tournamenLogtId:obj.tournamenLogtId,
                    tournamentId:obj.tournamentId,
                    currentRound:obj.currentRound,
	                roomTitle:obj.roomTitle,
	                isDeductReservemoney:"No",
	                isBotConnect:"No",
	                isFree:"No",
	                botWin:'No',
	                isTokenMove:false,
                    tokenMoveTime:2,
                    consttokenMoveTime:2,
                    isGameStart:false,
                    winnerCount :0,
                    startRoundWaiting:Number(data.remainingTable),
                    gameOverTime:5,
                    isGameOver:false,
                    throwDieTime:20,
                    constthrowDieTime:20,
                    botthrowDieTime:20,
                    matchPlayers:Number(obj.playerLimitInRoom),
                    leftPlayers:Number(obj.playerLimitInRoom),
                    players:[],
                    isReturn:false,
                    isKill:false,
                    isAddBot:false,
                    noOfBots:0,
                    isBotFirstSix:false,
                    currentRoundBot:Number(0),
                    totalRoundBot:Number(0),
                    isBotWinner:false,
                    matchDiceNumber:0,
                    isReturnMove :false,
                    matchValue:Number(data.value),
                    winningBet:0,
                    gameMode:obj.gameMode,
                    isPrivate:"No",
                    botUsersData:[],
                    whosTurn:false,
                    currentTurnUserId:false,
                    adminCommision:Number(0),
                    startDate:obj.startDate,
                    startTime:obj.startTime,
                    entryFee:obj.entryFee,
                    playerLimitInRoom:Number(obj.playerLimitInRoom),
                    isToss:false,
					isTossTimmer:1,
					startDicePosition:[],
                };
                match.players.push(playerObj);          
                matches.push(match);        
                io.in(tableId).emit("playerObject",match.players);
            }
            io.to(socket.id).emit("sessionMessage",response.message);
        }else{
            io.to(socket.id).emit("sessionMessage",response.message);
        }  
        // console.log(response)             
    });
}
function addChoiceBooster(data) {
	var match = findMatchByTableId(data.tableId);	
	if(match){
		var player  = findPlayerById(match,data.userId);		
		if(player){
			player.choiseBooster = Number(data.number);
			io.in(match.tableId).emit('playerObject',match.players);
		}
	}
}
function usedBooster(data) {
	var match = findMatchByTableId(data.tableId);	
	if(match){
		var player  = findPlayerById(match,data.userId);		
		if(player){
			if(data.type=='choiseBooster'){
				player.choiseBooster = 0;
			}else{
				player.randomBooster = 0;
			}
		}
	}
}
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
    var created = getDateTime();
    
    for (var i = 0; i < match.players.length; i++) {   
        if(match.players[i].isDeductMoney=="No" ){
            match.players[i].isDeductMoney="Yes";
            var isWin ="No";

            var roundStatus ="Loss";
            if(match.players[i].isWin == true){               
                isWin ="Yes";
                roundStatus ="Win";                
                var currentRound = match.players[i].currentRound + 1;
                var sql ="update tournament_registrations set isWin='"+isWin+"',roundStatus='Win',round='"+currentRound+"' where  userId='"+match.players[i].userId+"' and tournamentId='"+match.roomId+"' and round='"+match.players[i].currentRound+"';";
                var data ={
                    success:1,message:"You win"
                };
                io.in(match.tableId).emit("tournamenMsg",data);
            }else{
                var sql ="update tournament_registrations set isWin='"+isWin+"',roundStatus='"+roundStatus+"' where  userId='"+match.players[i].userId+"' and tournamentId='"+match.roomId+"' and round='"+match.players[i].currentRound+"';";
                var data ={
                    success:1,message:"You Loss"
                };
                io.in(match.tableId).emit("tournamenMsg",data);
            }
            // console.log(sql);
            sql +="insert into tournament_win_loss_logs set tournamentId='"+match.roomId+"',tournamentTitle='"+match.roomTitle+"',userId='"+match.players[i].userId+"',startDate='"+match.startDate+"',startTime='"+match.startTime+"',userName='"+match.players[i].userName+"',round='"+match.players[i].currentRound+"',entryFee='"+match.entryFee+"',playerLimitInRoom='"+match.playerLimitInRoom+"',roundStatus='"+roundStatus+"',created='"+created+"'";
            common_model.sqlQuery(sql,function(res){
               var tournamentMatch = findTournamentMatchByTorunamentId(match.tournamentId);
             
            });  
        }  
    }  
    // isRoundEnd(match);
    
    // var data = {
    //     table:'ludo_join_tour_rooms',
    //     setdata:"gameStatus='Complete'",
    //     condition:"joinTourRoomId='"+match.tableId+"'"
    // } 
    // common_model.saveData(data,function(res){});
}
// tourWinnerDistribution('2');
function tourWinnerDistribution(tournamentId){
    // console.log(tournamentId ," tournamentId tournamentId ");
    var sql =`select mt.*,tr.round,tr.userId from mst_tournaments mt
        left join tournament_registrations tr on tr.tournamentId=mt.tournamentId  
        where tr.tournamentId ='${tournamentId}' and tr.roundStatus='Win' and mt.status='Complete';`;
    // console.log(sql);return false;
        common_model.sqlQuery(sql,function(res1){
            if(res1.success==1 && res1.data.length!=0){
                var winnerPositions =[1,2,3,4,5,6,7,8,9,10];
                var winningPrices =[res1.data[0].firstRoundWinner,res1.data[0].secondRoundWinner,res1.data[0].thirdRoundWinner,res1.data[0].fouthRoundWinner,res1.data[0].fivethRoundWinner,res1.data[0].sixthRoundWinner,res1.data[0].seventhRoundWinner,res1.data[0].eightRoundWinner,res1.data[0].ninethRoundWinner,res1.data[0].tenthRoundWinner];
                var upsql = `UPDATE user_details set winWallet=winWallet+${winningPrices[0]},balance=winWallet+mainWallet where  id='${res1.data[0].userId}';update tournament_registrations set winningPrice=${winningPrices[0]},winnerPosition=${winnerPositions[0]} where userId='${res1.data[0].userId}' and tournamentId='${res1.data[0].tournamentId}'`;
                // console.log(upsql," upsql");
                var topround= res1.data[0].round;
                var roundNumberForIn =[];
                var length =10;
                if(topround < 10){
                    length =topround;
                }
                var round =length;
                var roundWinners ={};
                for (var i = 1; i < length; i++) {
                    topround-=1;
                    roundWinners[topround] ={winningPrices:winningPrices[i],winnerPositions:winnerPositions[i]}
                    roundNumberForIn.push(topround);
                }
                roundNumberForIn = roundNumberForIn.toString();
                var sql2 =`select * from tournament_registrations where tournamentId='${tournamentId}' and round in (${roundNumberForIn}) order by round desc,modified desc;`;

                common_model.sqlQuery(sql2,function(res2){

                    if(res2.success==1 && res2.data.length!=0){
                        for (var i = 0; i < res2.data.length; i++) {

                            upsql += `;UPDATE user_details set winWallet=winWallet+${roundWinners[res2.data[i].round].winningPrices},balance=winWallet+mainWallet where id='${res2.data[i].userId}';update tournament_registrations set winningPrice=${roundWinners[res2.data[i].round].winningPrices},winnerPosition=${roundWinners[res2.data[i].round].winnerPositions} where userId='${res2.data[i].userId}' and tournamentId='${res2.data[i].tournamentId}'`;
                        }
                               // console.log(upsql); return false;
                    }
                    common_model.sqlQuery(upsql,function(res3){

                    });
                });
                // return false;
                
            }
        });
}
function isRoundEnd(match){
    // console.log("isRoundEnd")
    var currentRound    =     match.currentRound;
    var nextRound       =     Number(match.currentRound) + 1;
    var playerLimitInRoom =   match.playerLimitInRoom;
    var dateTime        =     getDateTime();
	var data2 ={
		table:'mst_tournaments',
		fields:'*',
		condition:"tournamentId='"+match.tournamentId+"' and currentRound='"+currentRound+"' and status!='Complete' and roundTimer='End'",
	};
 	common_model.getData(data2,function(response1){
	    if(response1.success==1){
             // console.log("oneww")
	        var dbStartDate=response1.data[0].startDate;
	        var winningPrice=response1.data[0].winningPrice;
	        var dbStartTime=response1.data[0].startTime;
	        var tournamentTitle=response1.data[0].tournamentTitle;
	        var gameMode=response1.data[0].gameMode;

	        var data ={
	            table:'tournament_registrations',
	            fields:'tournamentRegtrationId',
	            condition:"round='"+currentRound+"'  and isEnter='Yes' and  isDelete='No' and  tournamentId='"+match.tournamentId+"' and (roundStatus='Pending' or roundStatus='Win')",
	         };

	         common_model.getData(data,function(response2){
	            if(response2.success!=1){
                      // console.log("twooo")
	                var query="select count(tournamentRegtrationId) inGameEnterTotalCount from tournament_registrations where (round='"+currentRound+"' or round='"+nextRound+"') and tournamentId='"+match.tournamentId+"'and isEnter='Yes'";
	                    // console.log(query)
	                common_model.sqlQuery(query,function(res){
	                    var inGameEnterTotalCount = res.data[0].inGameEnterTotalCount;
	                    if(playerLimitInRoom >= inGameEnterTotalCount){
	                        var sql2 ="update mst_tournaments set status='Complete',modified='"+dateTime+"' where tournamentId='"+match.tournamentId+"';";
	                        sql2 +="insert into mst_tournament_logs set playerInGameCount='"+inGameEnterTotalCount+"',status='End',tournamentId='"+match.tournamentId+"',startDate='"+dbStartDate+"',startTime='"+dbStartTime+"',currentRound='"+match.currentRound+"',tournamentTitle='"+tournamentTitle+"',gameMode='"+gameMode+"',created='"+dateTime+"',playerLimitInRoom='"+playerLimitInRoom+"'";
	                        common_model.sqlQuery(sql2,function(res4){
                                tourWinnerDistribution(match.tournamentId);
	                        });
	                        console.log("End Match")
	                    }else{
	                        var startDate       =     getDateTimeHrAdd().date;
	                        var startTime       =     getDateTimeHrAdd().time;
                            console.log(startTime)
	                        var query2="select count(tournamentRegtrationId) inGameTotalCount from tournament_registrations where round='"+match.currentRound+"' and roundStatus='Pending' and tournamentId='"+match.tournamentId+"'";
	                        common_model.sqlQuery(query2,function(res3){
	                            var inGameTotalCount = res3.data[0].inGameTotalCount;  
	                           var sql2 ="update mst_tournaments set roundTimer='Start',startDate='"+startDate+"',startTime='"+startTime+"',currentRound='"+nextRound+"',status='Next',modified='"+dateTime+"' where tournamentId='"+match.tournamentId+"';";
                               sql2 +="update tournament_registrations set round='"+nextRound+"',isEnter='No' where tournamentId='"+match.tournamentId+"' and round='"+nextRound+"';";
                                console.log(sql2)
	                            sql2  +="insert into mst_tournament_logs set tournamentId='"+match.tournamentId+"',tournamentTitle='"+tournamentTitle+"',startDate='"+startDate+"',startTime='"+startTime+"',playerLimitInRoom='"+playerLimitInRoom+"',status='NextRound',currentRound='"+nextRound+"',gameMode='"+gameMode+"',created='"+dateTime+"'";
	                            common_model.sqlQuery(sql2,function(res4){
	                                // console.log(res4)
	                            });
	                        });
	                        
	                         console.log("Next Match")
	                       
	                    }
	                    var tournamentMatch = findTournamentMatchByTorunamentId(match.tournamentId);
	                        // console.log(tournamentMatch)
	                        // console.log("tournamentMatchtournamentMatch")
	                    if(tournamentMatch){
	                       tournamentMatches.splice(tournamentMatches.indexOf(tournamentMatch), 1);  
	                    }
	                });
	            }else{
	                 console.log("match still running");
	            }
	         });

	    }else{
	        console.log("No record found");
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
            var playerlength =match.players.length; 
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
           
            if(match.isGameStart){            	
            	
                if(player.isDeductMoney=="No" && match.isFree=="No" && player.playerType=='Real'){
                    var adminCoins = (Number(parseFloat(match.matchValue)) * Number(match.adminCommision)/100);
                    player.isDeductMoney="Yes";
                    if(player.isWin == false){
                        var isWin="No";
                        var roundStatus="Loss";
                    }else{
                        var isWin="Yes";
                        var roundStatus="Win";
                    }
                     var created = getDateTime();
                    var sql ="update tournament_registrations set isWin='"+isWin+"',roundStatus='"+roundStatus+"' where userId='"+player.userId+"' and tournamentId='"+match.roomId+"';";
                     sql +="insert into tournament_win_loss_logs set tournamentId='"+match.roomId+"',tournamentTitle='"+match.roomTitle+"',userId='"+player.userId+"',startDate='"+match.startDate+"',startTime='"+match.startTime+"',userName='"+player.userName+"',round='"+player.currentRound+"',entryFee='"+match.entryFee+"',playerLimitInRoom='"+match.playerLimitInRoom+"',roundStatus='"+roundStatus+"',created='"+created+"'";

                    console.log(sql);
                    common_model.sqlQuery(sql,function(res){
                        // console.log(res)
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
            }else{
                if(player.isWin == false){
                     var created = getDateTime();
            	    var leftPlayers =match.players.length - 1;
				    var sql ="update tournament_registrations set roundStatus='Loss' where userId='"+player.userId+"' and tournamentId='"+match.roomId+"';update ludo_join_tour_rooms set activePlayer='"+leftPlayers+"' where joinTourRoomId='"+match.tableId+"';";
                     sql +="insert into tournament_win_loss_logs set tournamentId='"+match.roomId+"',tournamentTitle='"+match.roomTitle+"',userId='"+player.userId+"',startDate='"+match.startDate+"',startTime='"+match.startTime+"',userName='"+player.userName+"',round='"+player.currentRound+"',entryFee='"+match.entryFee+"',playerLimitInRoom='"+match.playerLimitInRoom+"',roundStatus='Loss',created='"+created+"'";
				    console.log(sql);
    				common_model.sqlQuery(sql,function(res){
    				    // console.log(res)
    				});    

                }
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
                // if(player.socketId==socket.id){

                // }else{

                // }
                 player.socketId = socket.id;
                 socket.join(data.tableId);
                io.in(match.tableId).emit("playerObject",match.players);
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
	var match = findMatchByTableId(data.tableId);	
	if(match){
		var player  = findPlayerById(match,data.userId);		
		if(player){
			var diceNum =match.matchDiceNumber;
			if(data.status=='Inactive' && diceNum!=6){

			}else if(player.isturn==true && diceNum!=0){
				match.isReturnMove = true;
				var sefPosition = [1,9,14,22,27,35,40,48,52,53,54,55,56,57];
				var isMove ="Yes";
				if(player.fourToken[data.tokenIndex].status=='Active'){
					var movPosition = Number(diceNum)+Number(player.fourToken[data.tokenIndex].position);
					if(movPosition > 57){
						isMove="No";
					}
				}
				if(isMove=='Yes'){
					if(player.fourToken[data.tokenIndex].status == 'Inactive' && diceNum == 6){
						player.inactiveTokenCount -=1;
						player.fourToken[data.tokenIndex].position =1;
						player.fourToken[data.tokenIndex].status = 'Active';
					}else if(player.fourToken[data.tokenIndex].status=='Active'){
						player.fourToken[data.tokenIndex].position = Number(diceNum)+Number(player.fourToken[data.tokenIndex].position);
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
					var gPosition = GetGlobalPositionFunction(player.fourToken[data.tokenIndex].position,player.tokenGlobleValue);
					
					player.fourToken[data.tokenIndex].globlePosition = gPosition;
					var isKillToken = false;
					if(gPosition != -1){					
						var isKillToken = findKillingFunction(match,player,gPosition);
						if(isKillToken==true){
							match.isReturn = true;
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
					//io.in(match.tableId).emit("playerObject",match.players);
					match.matchDiceNumber= 0;
					match.isTokenMove= true;					
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

				var diceNumber = Math.floor(Math.random() * 6) + 1;		
				if(isTest=='Yes'){
					diceNumber=Number(num);
				}	
				
				if(diceNumber == 6){				
					player.diceSixInTurn +=1;
					match.isReturn = true;
				}else{
					player.diceSixInTurn =0;
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
				if(player.inactiveTokenCount == 4 && diceNumber != 6){
					match.isTokenMove= true;
				}else if(player.inactiveTokenCount < 4){					
					var lastno = 0;
					//var inActiveCount = 0;
					for (let i = 0; i < player.fourToken.length; i++) {
						if(player.fourToken[i].status=='Active'){
							var no = 57 - player.fourToken[i].position;
							if(lastno < no){
								lastno = no;
							}
						}						
					}
					if(diceNumber==6 && player.inactiveTokenCount > 0){
					}else if(lastno < diceNumber){
						match.isTokenMove= true;
					}
				}
				
			}
		}
	}
}
// find to token position 
function  findTopTokenPosition(player){
	var topposition = 57;
	for (let i = 0; i < player.fourToken.length; i++) {
		if(player.fourToken[i].status=='Active'){
			var position = 57 - player.fourToken[j].position;
			if(topposition < position){

			}
		}		
	}
}
function changePlayerIndex(match) {    
    var points= match.startDicePosition.sort(function(a, b){return b-a});  
    var allPlayer=[];
    for (var i = 0; i < points.length; i++) {
        for (var j = 0; j < match.players.length; j++) {
          if(match.players[j].tossValue==points[i]){
          	 
   //      	if(i==0){
			// 	match.players[i].isturn = true;
			// 	match.whosTurn	=	match.players[i].playerType;
			// 	match.currentTurnUserId	=	match.players[i].userId;
			// }else{
			// 	match.players[i].isturn = false;
			// }
            allPlayer.push(match.players[j]);
    		io.in(match.tableId).emit("playerObject",match.players);
          }
        }      
    }  
    match.players=allPlayer;
    io.in(match.tableId).emit("playerObject",match.players);
}
//takePlayerIndex tokenColor
function takePlayerIndex(match){
	for (let i = 0; i < match.players.length; i++) {	
		if(i==0){
			match.players[i].isturn = true;
			match.whosTurn	=	match.players[i].playerType;
			match.currentTurnUserId	=	match.players[i].userId;
		}else{
			match.players[i].isturn = false;
		}	
		match.players[i].isStart = true;
		match.players[i].playerIndex = i;
		if(match.players.length==2 && i==1){			
			match.players[i].playerIndex = 2;
		}
		match.players[i].tokenColor = tokenColor[match.players[i].playerIndex];
		match.players[i].tokenGlobleValue = Number(tokenGlobleValue[match.players[i].playerIndex]);
		io.in(match.tableId).emit("playerObject",match.players);
	}
	io.in(match.tableId).emit("playerObject",match.players);

}

// update timmer function
function updateTimers(){
	 for (var i = 0; i < tournamentMatches.length; i++) {
       if(tournamentMatches[i].startRoundWaiting!=0){
        	tournamentMatches[i].startRoundWaiting -=1;            
       }
        console.log("startRoundWaiting "+tournamentMatches[i].startRoundWaiting);
        if(tournamentMatches[i].startRoundWaiting==5){
             var q ="update tournament_registrations set roundStatus='Out' where round='"+tournamentMatches[i].currentRound+"' and tournamentId='"+tournamentMatches[i].tournamentId+"' and isEnter='No';update mst_tournaments set roundTimer='End' where tournamentId='"+tournamentMatches[i].tournamentId+"'";

             common_model.sqlQuery(q,function(res){
            });
        }
        if(tournamentMatches[i].startRoundWaiting==0){
            tournamentMatches[i].startRoundWaiting = 10;
            isRoundEnd(tournamentMatches[i])
        }
    }
	for (var i = 0; i < matches.length; i++) { 
		      	
        if(!matches[i].isGameStart){
			matches[i].startRoundWaiting -= 1;
            io.in(matches[i].tableId).emit("startRoundWaiting",matches[i].startRoundWaiting);  
            if(matches[i].startRoundWaiting==10){
                if(matches[i].players.length==1){
                    var data ={
                        success:1,message:"Direct Win"
                    };
                    io.in(matches[i].tableId).emit("tournamenMsg",data);
                    matches[i].players[0].isWin = true;
                    matches[i].isGameOver =true;
                    winLossCoinsDistribution(matches[i]);
                    console.log(data)
                    
                }else if(matches[i].players.length > 1){
                    takePlayerIndex(matches[i]);
                    var rannum  = Math.floor(Math.random() * (matches[i].players.length - 0)) + 0;
                    matches[i].players[rannum].isturn = true;
                    matches[i].whosTurn  =   matches[i].players[rannum].playerType;           
                    matches[i].currentTurnUserId =   matches[i].players[rannum].userId;  
                    updateStatus(matches[i]);
                }
            } 
        }else{
        	if(matches[i].isToss==false){
        		io.in(matches[i].tableId).emit("isTossTimmer",matches[i].isTossTimmer);	
        		matches[i].isTossTimmer -= 1;
        		if (matches[i].isTossTimmer == 0) {
        			changePlayerIndex(matches[i]);
					takePlayerIndex(matches[i]);
					matches[i].isToss = true;
					io.in(matches[i].tableId).emit("playerObject",matches[i].players);
        		}  
        	}else if(matches[i].isGameOver==false && matches[i].leftPlayers==1){
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
					timesup(matches[i],'No');
				}
				else if(matches[i].throwDieTime <  0){
					matches[i].throwDieTime =matches[i].constthrowDieTime;
				}
			}
		}
	}
	setTimeout(updateTimers, 1000);
}
//if(matches[i].extratime!=0 && matches[i].isExtratime==true){
//     	matches[i].extratime -= 1;
//}
//if(matches[i].throwDieTime == 0 && matches[i].extratime != 0 && matches[i].isExtratime==false){
// 	    matches[i].isExtratime=true;
// 		matches[i].throwDieTime =matches[i].extratime;
//}
//                 isExtratime
// extratime
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
		}else{
			var diceNum  =  [4,5,6];
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
					moveToken(data);
				}
				
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
			}
			if(player.totalLifes==0){
				var data={
		    		tableId:player.tableId,
					userId:player.userId,
		    	};
				leftFromTable('',data);
			}else{
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
	common_model.joinRoomTable(data,function(res){
		if(res.success == 1){	
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
				fourToken:[{tokenIndex:0,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:1,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:2,position:0,globlePosition:0,status:'Inactive',zone:'safe'},{tokenIndex:3,position:0,globlePosition:0,status:'Inactive',zone:'safe'}],
				tokenColor:tokenColor,
				winnerPosition:0,
				socketId:socket.id,
				type:data.type,
				inactiveTokenCount:4,
				winCount:0,
				playerType:playerType,
				tokenTopPosition:57,
				tossValue:0,
				randomBooster:0,
				choiseBooster:0,
				isExtratime:false,
				extratime:20,
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
					if(match.matchPlayers==2){
						match.isTossTimmer=1;
					}			
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
					startRoundWastartRoundWaitingiting:60,
					gameOverTime:5,
					isGameOver:false,
					throwDieTime:20,
					constthrowDieTime:20,
					botthrowDieTime:20,
					matchPlayers:Number(res.players),
					leftPlayers:Number(res.players),
					players:[],
					isReturn:false,
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
					isToss:false,
					isTossTimmer:1,
					startDicePosition:[],
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
	// console.log("tesstse")
    if(match){


        var timeArray  =  [2,3,2,3,2,3,2,3,4,3,2,3,4];
        var randomTime = timeArray[Math.floor(Math.random()*timeArray.length)];
        match.botthrowDieTime =match.constthrowDieTime -randomTime;
       

        
        match.winningBet =0;
        for (let i = 0; i < match.players.length; i++) {
            match.winningBet +=  Number(match.matchValue);  
        }
        io.in(match.tableId).emit('winningBet',match.winningBet);   
        var rNum = Math.floor(Math.random() * 5) + 1;   
        var randNum = [1,2,3,4,5,6];
        io.to(match.tableId).emit("randomBooster",rNum);
        for (var i = 0; i < match.players.length; i++) {
            var randTossNo = randNum[Math.floor(Math.random()*randNum.length)];
            randNum.splice(randNum.indexOf(randTossNo), 1);
            match.startDicePosition.push(randTossNo);
            match.players[i].tossValue = randTossNo;
            match.players[i].randomBooster = rNum;
        }
        io.in(match.tableId).emit("playerObject",match.players);

        match.startDicePosition.sort(function(a, b){return b-a});
        match.isGameStart = true;
        var data ={
            table:'ludo_join_tour_rooms',
            setdata:"gameStatus='Active'",
            condition:"joinTourRoomId='"+match.tableId+"'"
        } 
        common_model.SaveData(data,function(res){
            
   //      	var timeArray  =  [2,3,2,3,2,3,2,3,4,3,2,3,4];
		 //    var randomTime = timeArray[Math.floor(Math.random()*timeArray.length)];
		 //    match.botthrowDieTime =match.constthrowDieTime -randomTime;
		   

        	
   //      	match.winningBet =0;
   //      	for (let i = 0; i < match.players.length; i++) {
			// 	match.winningBet +=  Number(match.matchValue);	
			// }
			// io.in(match.tableId).emit('winningBet',match.winningBet);	
			// var rNum = Math.floor(Math.random() * 5) + 1;	
		 //    var randNum = [1,2,3,4,5,6];
		 //    io.to(match.tableId).emit("randomBooster",rNum);
			// for (var i = 0; i < match.players.length; i++) {
			// 	var randTossNo = randNum[Math.floor(Math.random()*randNum.length)];
			// 	randNum.splice(randNum.indexOf(randTossNo), 1);
			// 	match.startDicePosition.push(randTossNo);
			// 	match.players[i].tossValue = randTossNo;
			// 	match.players[i].randomBooster = rNum;
			// }
			// io.in(match.tableId).emit("playerObject",match.players);
	
			// match.startDicePosition.sort(function(a, b){return b-a});
			// match.isGameStart = true;
        });
    }
}
//console.log(process.env.CDH)

// start Match Function
function startMatchFunction(match){
	
	for (let i = 0; i < match.players.length; i++) {
		coinUpdateFunction(match,match.players[i],i);		
	}
}
//takePlayerIndex tokenColor
// function takePlayerIndex(players){
// 	for (let i = 0; i < players.length; i++) {
// 		players[i].isStart = true;
// 		players[i].playerIndex = i;
// 		if(players.length==2 && i==1){			
// 			players[i].playerIndex = 2;
// 		}
// 		players[i].tokenColor = tokenColor[players[i].playerIndex];
// 		players[i].tokenGlobleValue = Number(tokenGlobleValue[players[i].playerIndex]);
// 	}
// }
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
	                    match.isDeductReservemoney = "No";
	                }else{
	                    match.isDeductReservemoney = "Yes";
	                }                
	            }else{
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
           
      });
}


app.get('/',function(req,res){
    res.end('WELCOME TO NODE');
});

// get users details by userId
app.post("/getTournaments",function(req,res){
   var reqData = req.body;
   tournament.getTournaments(reqData,function(response){
        res.send(response);
    });
});
   var reqData = "";
tournament.getTournaments(reqData,function(response){
        // console.log(response);
    });
// Tournament registraion
app.post("/tournamentRegistration",function(req,res){
   var reqData = req.body;
   // console.log(reqData);
   tournament.tournamentRegistration(reqData,function(response){
        res.send(response);
    });
});
// tournament un registration
app.post("/tournamentUnRegistration",function(req,res){
   var reqData = req.body;
   tournament.tournamentUnRegistration(reqData,function(response){
        res.send(response);
    });
});
// get Tournament Users
app.post("/getTournamentUsers",function(req,res){
   var reqData = req.body;
   tournament.getTournamentUsers(reqData,function(response){
        res.send(response);
    });
});
// get Tournament Users
app.post("/getTournamentListByUserId",function(req,res){
   var reqData = req.body;
   tournament.getTournamentListByUserId(reqData,function(response){
        res.send(response);
    });
});
//getCurrentTime
app.post("/getCurrentTime",function(req,res){
   var reqData = req.body;
    let nDate = new Date().toLocaleString('en-US', {
        timeZone: 'Asia/Calcutta'
    });
    res.send(nDate);
});


// get getWinLossTourHistory userId
app.post("/getWinLossTourHistory",function(req,res){
   var reqData = req.body;
   tournament.getWinLossTourHistory(reqData,function(response){
        res.send(response);
    });
});

// get getRegTourData userId
app.post("/getRegTourData",function(req,res){
   var reqData = req.body;
   tournament.getRegTourData(reqData,function(response){
        res.send(response);
    });
});