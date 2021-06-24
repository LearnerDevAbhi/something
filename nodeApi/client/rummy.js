var express = require("express");
var fs = require("fs");
var app = express();
var bodyParser = require("body-parser");
var cookieParser = require('cookie-parser');
var morgan = require('morgan');
const request = require('request');
var common_model = require('./socket/common_model.js');
var botCards = require('./socket/botCards.js');
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
server.listen(3006,function(){
  console.log('Socket listening on 3006 port');
}); 
app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

var reserve_moneyFieldName ='reserve_money';
var globleBotTurn =[3,4,5,6,7];
var winRound =[4,5,6];
var winNonRound =[10,11,12,13];

// get card type function
function getCardType(no){    
    var type= 'Jocker';
    if(no > 0 && no <= 13){
        type ='Spade';
    }else if(no > 13 && no <= 26){
        type ='Club';
    }else if(no > 26 && no <= 39){
        type ='Diamond';
    }else if(no > 39 && no <= 52){
        type ='Heart';
    }   
    return type;
}
// globle variable for socket 
var usernames = {};
var matches = [];
var DropTime = 30;
var showTime=45;
var roundTime=20;
var gameOverTime = 20;
var adminCommition= 15; // in percentage
var continueNotPlayCountLimit = 3;

updateTimers();
// socket connection
io.sockets.on('connection',function(socket){
    // for join room
    socket.on('joinRoom',function(data){
       data['playerType']='Real';
       joinRoomTable(socket,data);
    });
    //getBotPoints
   
    socket.on("getBotPoints",function(data){
        var match = findMatchByTableId(socket.tableId);   
        if(match){
             var player = findPlayerById(data.userId,match);
             if(player){
                if(Number(data.point)==0){
                    var p = 2;
                }else{
                    var p = Number(data.point);
                }
                if(player.isWinnerBot==true){
                    player.botReservePoint =Number(data.reservePoint);
                }
                player.botPoints=Number(p);
             }
        } 
    });
    // for disconnect
    socket.on("disconnect",function(reason){
         if(socket.tableId){

            var match = findMatchByTableId(socket.tableId);    
            if(match){
                   var player = findPlayerById(socket.id,match);
                    if(player){
                        socket.leave(socket.tableId);
                    }else{
                        var player = findPlayerByUserId(match,socket.userId);
                        if(player){
                            socket.leave(socket.tableId);
                        }
                    }
                   // playerDisconnected(socket);
              //  }
            }
            //socket.leave(socket.tableId);
       }else{
           // playerDisconnected(socket);
       }
    });
    // for left table
    socket.on("leftFromTable",function(){
        leftFromTable(socket);
    });
    // get card
    socket.on("getCard",function(data){
        data['tableId']  = socket.tableId;
        data['socketId'] = socket.id; 
        getCard(data);
    });
    // showCard
    socket.on("showCards",function(){
        var data= {
            tableId:socket.tableId,
            socketId:socket.id,
        };        
        showCard(data);
    });
    // send cards
    socket.on("sendShowCards",function(data){
        data['tableId'] = socket.tableId;
        data['socketId'] = socket.id; 
        sendShowCards(data);
    });
    //drop cards
    socket.on("dropRound",function(data){
        data['socketId']= socket.id;
        data['tableId']= socket.tableId;
        dropRound(data);
    });
    // for drop card
    socket.on("dropCard",function(data){
        var socketId = socket.id;
        var tableId  = socket.tableId;
       throwCard2(data.userId,tableId,data.card.cardIndex,"normal");
    });
    // get discart details
    socket.on("getDiscardDetails",function(){
        getDiscardDetails(socket);
    });
    // get discart details
    socket.on("userReconnect",function(data){
        userReconnect(socket,data);
    });
});
//user Reconnect 
function userReconnect(socket,data){
  
    var match = findMatchByTableId(data.tableId);    
    if(match){
         // socket.leave(data.tableId);
        var player = findPlayerByUserId(match,data.userId);
        if(player){
            if(match.isGameOver){
                var data = {
                    success:2,
                    message:"Match is ended."
                }               
            }else{
                console.log("Reconnect")
                // socket.join(data.tableId);
                //if(player.isDisconnet==false){
                    player.isDisconnet = true;
                    socket.userName =player.userName;
                    socket.tableId = player.tableId;
                    socket.userId= player.userId;
                    player.socketId = socket.id;
                    var pIndex = match.players.indexOf(player);
                    match.players[pIndex]= player;
                    socket.join(data.tableId);
                                    
                    io.to(player.socketId).emit("playerObject",match.players);
                    io.to(player.socketId).emit("jocker",match.jocker);
                    io.to(player.socketId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
                    io.to(player.socketId).emit("updateCards",player.cards);
                    var data = {
                        success:1,
                        message:"Reconnect Success"
                    }
                //}
                
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
//findPlayerByUserId
function findPlayerByUserId(match,userId){
    for (var i = 0; i < match.players.length; i++) {        
        if (match.players[i].userId  ==  userId) {
            return match.players[i];
        }       
    }
    return false;
}


//discardDetails
function getDiscardDetails(socket){  
    var match = findMatchByTableId(socket.tableId);
    var discardData= [];
    for (let i = 0; i < match.players.length; i++) {
        var data={
            userId:match.players[i].userId,
            userName:match.players[i].userName,
            disCards:match.players[i].disCards,
        }
        discardData.push(data);              
    }
    io.to(socket.id).emit("getDiscardDetails",discardData);
}
function dropRound(data){
    var match = findMatchByTableId(data.tableId);
    if(match){
        var player = findPlayerById(data.socketId,match);  
        if(player){
            if(player.isturn==true && player.cards.length==13){
                var pIndex = match.players.indexOf(player);
                player.isBlocked = true;
                if(player.isFirstTurn==false){  
                    if(match.game.gameType=='Pool'){
                        player.tempGamePoint = match.firstDropPoint;
                        player.tempGameCards = data.cards;
                        player.tempCardGroup = data.cardGroup;
                        var tempTotalPoint = Number(player.totalPoints) + Number(match.firstDropPoint); 
                        player.totalPoints = tempTotalPoint;
                        if(tempTotalPoint >= match.game.gameOrpoint){
                                player.isBlocked = true;         
                                player.isGameBlock = true;
                                io.to(player.socketId).emit("winnerMsg","You are loss.");
                        }
                    }else if(match.game.gameType=='Point'){    
                        player.tempGamePoint = match.firstDropPoint;
                        player.tempGameCards = data.cards;
                        player.tempCardGroup = data.cardGroup; 
                        player.isBlocked = true;    
                        player.totalPoints =player.tempGamePoint;
                        tempPointsAdd(match,player,match.firstDropPoint);
                    }
                }else{
                    if(match.game.gameType=='Pool'){
                        player.tempGamePoint = match.middleDropPoint;
                        player.tempGameCards = data.cards;
                        player.tempCardGroup = data.cardGroup;
                        var tempTotalPoint = Number(player.totalPoints) + Number(match.middleDropPoint); 
                        player.totalPoints = tempTotalPoint;
                        if(tempTotalPoint >= match.game.gameOrpoint){
                            player.isBlocked = true;         
                            player.isGameBlock = true;
                            io.to(player.socketId).emit("winnerMsg","You are loss.");
                        }
                    }else if(match.game.gameType=='Point'){    
                        player.tempGamePoint = match.middleDropPoint;
                        player.tempGameCards = data.cards;
                        player.tempCardGroup = data.cardGroup; 
                        player.isBlocked = true;           
                        player.totalPoints =player.tempGamePoint;
                        tempPointsAdd(match,player,match.middleDropPoint);
                    }
                }
                var cards = player.cards;
                var isGameBlockCount = gameBlockCountFunction(match);
                var block = isBlockedPlayerCount(match); 
                if(isGameBlockCount.blockLength==1){
                    if(match.game.gameType=='Point'){
                        pointFunction(match,'Point');
                    }
                    if(match.game.gameType=='Pool'){
                        poolFunction(match,'Pool');
                    }      
                }else if(block.blockLength==1){
                   // var winIndex = match.players.indexOf(block.winPlayer);
                    block.winPlayer.tempGamePoint = 0;
                    block.winPlayer.tempGameCards = block.winPlayer.cards;
                    block.winPlayer.isCardsShow = true;
                    if(match.game.gameType=='Bestof'){
                        besofFunction(match,'blockWin');
                    }
                    if(match.game.gameType=='Pool'){
                        poolFunction(match,'blockWin');
                    }                
                    if(match.game.gameType=='Point'){  
                        pointFunction(match,'blockWin');                  
                    }
                }else if(cards.length == 14 && player.isturn == true){                   
                    var cardIndex = cards[13].cardIndex;
                    throwCard(data.socketId,data.tableId,cardIndex,'normal');
                }else if(match.players[pIndex].isturn == true){
                    nextTurnFunction(match,pIndex,'normal');
                }else{
                    io.in(match.tableId).emit("playerObject",match.players);
                    io.in(match.tableId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
                }
            }            
        }         
    }   
}
// show cards
function showCard(data){
    var match = findMatchByTableId(data.tableId);
    if(match){
        var player = findPlayerById(data.socketId,match);
        if(player){
           // var pIndex = match.players.indexOf(player);
            var cardsLength = player.cards.length;
            if(match.isShowCards == false && player.isturn == true && cardsLength==14){
                match.isShowCards =true;
                if(match.isShowCards){
                    player.isBlocked = true;
                }
            }
        }
        
    }
    
}
// function show card time
function showCardTime(match){
    if(match.cardThrow){
        getcardsPoint(match); 
        if(match.game.gameType=='Bestof'){
            besofFunction(match,'turn');
        }
        if(match.game.gameType=='Pool'){
            poolFunction(match,'turn');
        }
        if(match.game.gameType=='Point'){
            pointFunction(match,'turn');
        }
    }else{
         for (var i = 0; i < match.players.length; i++) {
            if(match.players[i].isBlocked==false){
                match.players[i].isShowCards=true;
            }
        }
        var turnPlayer=  findIsTurnIndex(match);
       // var turnIndex = match.players.indexOf(turnPlayer);
        if(turnPlayer){
            if(match.game.gameType=='Point'){
            
            }else{
                turnPlayer.tempGamePoint =match.maxPointLimit;
                turnPlayer.tempGameCards =turnPlayer.cards;
            }
        }
        var block = isBlockedPlayerCount(match);
        if(block.blockLength==1){
            block.winPlayer.tempGamePoint = 0;
            block.winPlayer.tempGameCards = block.winPlayer.cards;
            block.winPlayer.isCardsShow = true;
            if(match.game.gameType=='Bestof'){
                besofFunction(match,'blockWin');
            }
            if(match.game.gameType=='Pool'){
                poolFunction(match,'blockWin');
            }                
            if(match.game.gameType=='Point'){                  
                pointFunction(match,'blockWin');                  
            }
        }else{
            match.isShowCards= false;
            timesup(match);
        }
    }
    match.showCardTime =match.constShowCardTime;
}
function poolFunction(match,blockOrTurn){
  
    var isGameBlockCount = gameBlockCountFunction(match);
    if(isGameBlockCount.blockLength==1){
        match.winnerSocketId = isGameBlockCount.socketId;
        poolWinnerFunction(match,'Pool');
        match.isGameOver = true; 
    }else{
        match.round = match.round + parseFloat(1);
        poolWinnerFunction(match,blockOrTurn);
        match.cardDropTime=match.constCardDropTime;
        //match.isNextRound = true;
    }   
}
// find pool winner 
function poolWinnerFunction(match,resultType){
    var players =match.players;
    match.tableResults =[];
    for (let i = 0; i < players.length; i++) {
        if(resultType=='turn'){
            if(players[i].isturn==true){
                players[i].isWinner = true;  
                players[i].tempGamePoint =0;              
            }else{
                players[i].isWinner = false;
            }
        }else if(resultType=="blockWin"){
            if(players[i].isBlocked ==false){
                players[i].isWinner = true;
                players[i].tempGamePoint =0;
            }else{
                players[i].isWinner = false;
            }  
        }else if(resultType=="Pool"){
            if(players[i].socketId ==match.winnerSocketId){
                players[i].isWinner = true;
                players[i].tempGamePoint =0;
            }else{
                players[i].isWinner = false;
            }  
        }


        if(players[i].isBlocked==true){

        }else{
            var totalPoint = Number(players[i].tempGamePoint) + Number(players[i].totalPoints);
            players[i].totalPoints =   totalPoint;
        }
        //var tempTotalPoint = parseFloat(player.totalPoints) + parseFloat(match.maxPointLimit);                   
        if(players[i].totalPoints >= match.game.gameOrpoint){
            players[i].isBlocked = true;         
            players[i].isGameBlock = true;
            io.to(players[i].socketId).emit("winnerMsg","You are loss.");
        }
        if(players[i].tempGameCards.length==0){
            var tempCard=players[i].cards;            
        }else{
            var tempCard=players[i].tempGameCards;
        }
        // player.tempCardGroup = {
        //                     groups:[3,4,3,3],
        //                     result:"Inorrect"
        //                 };
        if(players[i].isWinner==true){
            var winAmt = match.winningAmount- (match.winningAmount*match.adminCommition/100);
        }else{
            var winAmt = match.matchValue;
        }
        var dataPoint = {
            name:players[i].userName,            
            isWinner:players[i].isWinner,
            gamePoints:players[i].tempGamePoint,
            totalPoints:players[i].totalPoints,
            socketId:players[i].socketId,
            userId:players[i].userId,
            cardGroup:players[i].tempCardGroup,
            cards:tempCard,
            winningAmount:winAmt,
            message:""
        };
        match.tableResults.push(dataPoint);
        players[i].tempGamePoint =   0;
        players[i].tempGameCards =   [];
        players[i].tempCardGroup =   [];
    }
    var isGameBlockCount = gameBlockCountFunction(match);
    if(isGameBlockCount.blockLength==1){
        match.winnerSocketId = isGameBlockCount.socketId;
        match.isGameOver = true; 
    }else{
        match.isNextRound = true;
    }  
}
function gameBlockCountFunction(match){
    var block={
        blockLength:0,
        socketId:0,
    };
    for (let i = 0; i < match.players.length; i++) {
        if(match.players[i].isGameBlock == false){
            block.blockLength = block.blockLength + 1;
            block.socketId = match.players[i].socketId;
        }   
    }
    return block;
}
function besofFunction(match,blockOrTurn){
    var noOfRound = match.game.gameOrpoint;

    if(noOfRound == match.round){
        var winnerSocketId =[];
        var winningPoints=[];
        var winninguserId=[];
        var players = match.players;

        for (let i = 0; i < players.length; i++) {
            var tPoint= parseFloat(players[i].tempGamePoint) + parseFloat(players[i].totalPoints);
            winningPoints.push(tPoint);
            winnerSocketId.push(players[i].socketId);
            winninguserId.push(players[i].userId);
        }

        var minVal = Math.min.apply(Math,winningPoints);
        var winIndex = winningPoints.indexOf(minVal);
        match.winnerSocketId = winnerSocketId[winIndex];
        findWinnerFunction(match,'Bestof');
        match.isGameOver = true;        
    }else{
        match.round = match.round + parseFloat(1);
        findWinnerFunction(match,blockOrTurn);
        match.cardDropTime=match.constCardDropTime;
        match.isNextRound = true;
    }
}
// find winner 
function findWinnerFunction(match,resultType){
    var players =match.players;
    match.tableResults =[];
    for (let i = 0; i < players.length; i++) {
        if(resultType=='turn'){
            if(players[i].isturn==true){
                players[i].isWinner = true;  
                players[i].tempGamePoint =0;              
            }else{
                players[i].isWinner = false;
            }
        }else if(resultType=='Bestof'){
            if(players[i].socketId ==match.winnerSocketId){
                players[i].isWinner = true;
            }else{
                players[i].isWinner = false;
            }  
        }else if(resultType=="blockWin"){
            if(players[i].isBlocked ==false){
                players[i].isWinner = true;
                players[i].tempGamePoint =0;
            }else{
                players[i].isWinner = false;
            }  
        }else if(resultType=="Pool"){
            if(players[i].socketId ==match.winnerSocketId){
                players[i].isWinner = true;
                //players[i].tempGamePoint =0;
            }else{
                players[i].isWinner = false;
            }  
        }else if(resultType=="Point"){
        }


        if(players[i].isBlocked==true){

        }else{
            var totalPoint = Number(players[i].tempGamePoint) + Number(players[i].totalPoints);
            players[i].totalPoints =   totalPoint;
        }
                
        
        if(players[i].tempGameCards.length==0)        {
            var tempCard=players[i].cards;            
        }else{
            var tempCard=players[i].tempGameCards;
        }
        if(players[i].isWinner==true){
            var winAmt = match.winningAmount - (match.winningAmount*match.adminCommition/100);
        }else{
            var winAmt = match.matchValue;
        }
        var dataPoint = {
            name:players[i].userName,            
            isWinner:players[i].isWinner,
            gamePoints:players[i].tempGamePoint,
            totalPoints:players[i].totalPoints,
            socketId:players[i].socketId,
            userId:players[i].userId,
            cardGroup:players[i].tempCardGroup,
            cards:tempCard,
            winningAmount:winAmt,
            message:""
        };
        match.tableResults.push(dataPoint);
        players[i].tempGamePoint =   0;
        players[i].tempGameCards =   [];
        players[i].tempCardGroup =   [];
    }
}

// pointFunction 
function pointFunction(match,blockOrTurn){
    var isGameBlockCount = gameBlockCountFunction(match);
    if(isGameBlockCount.blockLength==1){
        match.winnerSocketId = isGameBlockCount.socketId;
        pointWinningFunction(match,'Point');
      match.isGameOver = true; 
    }else{
        match.round = match.round + parseFloat(1);
        pointWinningFunction(match,blockOrTurn);
        match.cardDropTime=match.constCardDropTime;
        match.isNextRound = true;
    }
}
function pointWinningFunction(match,resultType){
    if(match.isWinnerDefine==false){
        match.isWinnerDefine= true;
        var players =match.players;
        match.botPointsAmount =0;
        match.realPlayerPointsAmount =0;
        for (let i = 0; i < players.length; i++){
            if(players[i].blockForAllRound==false){
                if(resultType=='turn'){
                    if(players[i].isturn==true){
                        match.winnerSocketId = players[i].socketId;
                        players[i].isWinner = true;                
                        players[i].tempGamePoint=0;
                    }else{
                        players[i].isWinner = false;
                    }
                }else if(resultType=="blockWin"){
                    if(players[i].isBlocked ==false){
                        match.winnerSocketId = players[i].socketId;
                        players[i].isWinner = true;
                         players[i].tempGamePoint=0;
                    }else{
                        players[i].isWinner = false;
                    }  
                }else if(resultType=="Point"){
                    if(players[i].socketId == match.winnerSocketId){
                        players[i].isWinner = true;
                         players[i].tempGamePoint=0;
                    }else{
                        players[i].isWinner = false;
                    } 
                } 
                for(key in match.pointDeductArray){
                    if(players[i].userId==key){
                        delete match.pointDeductArray[key];
                    }
                }        
               // if(players[i].isWinner==false){
                    var storeCoins = (Number(match.maxPointLimit)*parseFloat(match.matchValue))-(Number(players[i].tempGamePoint)*parseFloat(match.matchValue));
                   // match.winningAmount -= storeCoins;
                   // return coinn
                    if(players[i].playerType == 'Real'){  
                        if(players[i].isWinner==false){
                            returnCoinsPointMode(match,players[i],storeCoins,players[i].playerType);  
                            players[i].totalPoints = storeCoins;
                            players[i].coins = parseFloat(players[i].coins)+parseFloat(storeCoins);
                        }
                        
                    }
                    if(players[i].playerType == 'Bot'){
                      
                        match.botPointsAmount += parseFloat(storeCoins);
                        // var reserverData={
                        //     type:'Add',
                        //     amount:storeCoins,
                        // };                
                        // updateReserveAmount(reserverData);
                    }
                    
                    match.winningAmount -= storeCoins;
                }else{
                     for(key in match.pointDeductArray){
                        if(players[i].userId==key){
                            delete match.pointDeductArray[key];
                        }
                    }  
                }
        }
    for(key in match.pointDeductArray){
        var distributionData={
            userId:key,
            userAmount:parseFloat(match.pointDeductArray[key]),
            totalAmount:parseFloat(match.winningAmount),
            adminPercent:match.adminCommition
        };
        commitionDistribution(distributionData);
        var rewardData ={
            userId:key,
            userAmount:Number(parseFloat(match.pointDeductArray[key]))
        }
        updateRewardFunction(rewardData);
    }
        for (let i = 0; i < players.length; i++) {
             if(players[i].blockForAllRound==false){
                if(players[i].playerType == 'Real' && players[i].isWinner == false){
                    var distributionData={
                        userId:players[i].userId,
                        userAmount:Number(players[i].tempGamePoint)*Number(parseFloat(match.game.valueInput)),
                        totalAmount:parseFloat(match.winningAmount),
                        adminPercent:match.adminCommition
                    };
                    commitionDistribution(distributionData);
                    var rewardData ={
                        userId:players[i].userId,
                        userAmount:Number(players[i].tempGamePoint)*Number(parseFloat(match.game.valueInput))
                    }
                    updateRewardFunction(rewardData);

                }
                       
               // botPointsAmount
                if(players[i].isWinner==true){
                    coinsToWinnerPoint(match,players[i],resultType);
                    var winAmount = (parseFloat(match.winningAmount) - (parseFloat(match.winningAmount)*match.adminCommition/100));
                }else{
                    var winAmount = Number(players[i].tempGamePoint)*Number(parseFloat(match.game.valueInput));

                }
                if(players[i].tempGameCards.length==0){
                    var tempCard=players[i].cards;            
                }else{
                    var tempCard=players[i].tempGameCards;
                }     
               // var wa = (parseFloat(match.winningAmount) - (parseFloat(match.winningAmount)*match.adminCommition/100));

                // if(!players[i].tempCardGroup){

                // }
                // player.tempCardGroup = {
                //                     groups:[3,4,3,3],
                //                     result:"Inorrect"
                //                 };)
               
              
                var dataPoint = {
                    name:players[i].userName,            
                    isWinner:players[i].isWinner,
                    gamePoints:players[i].tempGamePoint,
                    totalPoints:parseFloat(players[i].tempGamePoint) * parseFloat(match.matchValue),
                    socketId:players[i].socketId,
                    userId:players[i].userId,
                    cards:tempCard,
                    cardGroup:players[i].tempCardGroup,
                    winningAmount:winAmount,
                    message:""
                };
                 match.tableResults.push(dataPoint);
                 players[i].totalPoints   =   0;
                 players[i].tempGamePoint =   0;
                 players[i].tempGameCards =   [];
             }else{
                var pIndex  = match.players.indexOf(players[i]);
                match.players.splice(pIndex, 1);
             }
        }
        

    }
   // winnerFunctionForPoint(match,resultType);
}


function returnCoinsPointMode(match,player,coins,playerType){
    if(playerType=='Real'){
        var udata = {
            table:'pla24by7tbs_web.user_details',
            fields:"coins,user_id",
            condition:"user_id='"+player.userId+"'"
        };
        common_model.GetData(udata,function(respon){
            if(respon.success==1){
                var lcoin = Number(parseFloat(respon.data[0].coins))+ Number(parseFloat(coins));
                var deductCoins = Number(parseFloat(match.maxPointLimit)) * Number(parseFloat(match.matchValue));

                var updateUserCoinData = {
                    table:'pla24by7tbs_web.user_details',
                    setdata:"coins="+lcoin,
                    condition:"user_id="+respon.data[0].user_id
                };
                common_model.saveData(updateUserCoinData,function(response){  
                });
                if(playerType=='Real'){
                    var updateUserCoinData = {
                        table:'roulettnew.tbl_users',
                        setdata:"coins="+lcoin,
                        condition:"user_id="+respon.data[0].user_id
                    };
                    common_model.saveData(updateUserCoinData,function(response){  
                    });
                }
            }
           
        });
    }else{

    }
}
function coinsToWinnerPoint(match,player,resultType){
     
    if(player.playerType=='Bot'){
        var totalBoyPoint = (parseFloat(match.noOfBot)*(parseFloat(match.maxPointLimit)*parseFloat(match.matchValue)));
        var lastBotWinAmt = parseFloat(totalBoyPoint)- parseFloat(match.botPointsAmount);
        var winningAmount  = parseFloat(match.winningAmount)- parseFloat(lastBotWinAmt);
        match.winningAmount  = parseFloat(match.winningAmount)- parseFloat(lastBotWinAmt);
    }else{
        var winningAmount =  match.winningAmount;
    }
    var winningCoins =  winningAmount - (winningAmount*match.adminCommition/100);   
    var updatecoin = (parseFloat(winningCoins)+parseFloat(player.coins))+(parseFloat(match.maxPointLimit)*parseFloat(match.matchValue));
    player.coins = parseFloat(updatecoin)+parseFloat(0);
   

    var updateUserCoinData = {
        table:'pla24by7tbs_web.user_details',
        setdata:"coins="+updatecoin,
        condition:"user_id='"+player.userId+"'"
    };
   
    common_model.saveData(updateUserCoinData,function(response){  
    });
    if(player.playerType=='Real'){
         var updateUserCoinData2 = {
            table:'roulettnew.tbl_users',
            setdata:"coins="+updatecoin,
            condition:"user_id='"+player.userId+"'"
        };
       
        common_model.saveData(updateUserCoinData2,function(response){  
        });
    }
    var updateCoindata={
        message:"You win "+winningCoins,
        balanceCoins:updatecoin,
        winnigAmount:match.winningAmount
    }; 
    io.to(player.socketId).emit("coinUpdates",updateCoindata);
    var rummy_winning_data = {
        table:'rummy_winning_details',
        setdata:"tableId='"+match.tableId+"',userId='"+player.userId+"',winnigAmount='"+winningAmount+"',adminAmount='"+winningAmount*match.adminCommition/100+"',playerType='"+player.playerType+"',created=NOW()",
        condition:""
    };
    common_model.saveData(rummy_winning_data,function(response){  
    }); 
    if(player.playerType=='Bot'){ 
     var totalBoyPoint = (parseFloat(match.noOfBot)*(parseFloat(match.maxPointLimit)*parseFloat(match.matchValue)));     
       //match.botPointsAmount
        var reserverData={
            type:'Add',
            amount:(parseFloat(winningCoins)+parseFloat(totalBoyPoint)) 
        };
        updateReserveAmount(reserverData);
    }   
    if(match.isAddBot==true && player.playerType=='Real'){ 
        var reserverData={
            type:'Add',
            amount:parseFloat(match.botPointsAmount)
        };
        updateReserveAmount(reserverData);
    }   
   
    //match.winningAmount = 0;
    if(resultType != 'Point'){
        match.winnerSocketId=false;
    }

}

function pointWinnerDefine(match){    
    match.winnerSocketId = match.players[0].socketId;
    //match.players[0].isWinner= true;
    pointWinningFunction(match,'Point');
        // match.tableResults = [];
        // var players = match.players;
        // if(players[0].tempGameCards.length==0)
        // {
        //     var tempCard=players[0].cards;            
        // }else{
        //     var tempCard=players[0].tempGameCards;
        // }
        // var dataPoint = {
        //     name:players[0].userName,            
        //     isWinner:true,
        //     gamePoints:players[0].tempGamePoint,
        //     totalPoints:players[0].totalPoints,
        //     socketId:players[0].socketId,
        //     userId:players[0].userId,
        //     cardGroup:players[0].tempCardGroup,
        //     cards:tempCard,
        //     winningAmount:match.winningAmount,
        //     message:"All players are left you win."
        // };
        // match.tableResults.push(dataPoint);
        // match.winnerSocketId = match.players[0].socketId;
        // match.players[0].isWinner= true;
        match.isGameOver = true;
    
}
function winnerDefine(match){    
    if(match.players.length==1){
        match.tableResults = [];
        var players = match.players;
        if(players[0].tempGameCards.length==0)
        {
            var tempCard=players[0].cards;            
        }else{
            var tempCard=players[0].tempGameCards;
        }
        var dataPoint = {
            name:players[0].userName,            
            isWinner:true,
            gamePoints:players[0].tempGamePoint,
            totalPoints:players[0].totalPoints,
            socketId:players[0].socketId,
            userId:players[0].userId,
            cardGroup:players[0].tempCardGroup,
            cards:tempCard,
            winningAmount:match.winningAmount- (match.winningAmount*match.adminCommition/100),
            message:"All players are left you win."
        };
        match.tableResults.push(dataPoint);
        match.winnerSocketId = match.players[0].socketId;
        match.players[0].isWinner= true;
        match.isGameOver = true;
    }
}
function pointDeductCoins(match,player,points){
    if(player.isDeductMoney==false){
        player.isDeductMoney = true;
        var defalutcoinDeduct = parseFloat(points) * parseFloat(match.game.valueInput);
        player.totalPoints = defalutcoinDeduct;
        var lastCoins = parseFloat(player.coins) - parseFloat(defalutcoinDeduct);
        player.coins = lastCoins;     
        var udata = {
            table:'pla24by7tbs_web.user_details',
            fields:"coins,user_id",
            condition:"user_id='"+player.userId+"' and playerType='"+player.playerType+"'"
        };
        common_model.GetData(udata,function(respon){
            var lcoin = parseFloat(respon.data[0].coins)- parseFloat(defalutcoinDeduct);
            var updateUserCoinData = {
                table:'pla24by7tbs_web.user_details',
                setdata:"coins="+lcoin,
                condition:"user_id="+respon.data[0].user_id
            };
            common_model.saveData(updateUserCoinData,function(response){  
            });
            if(player.playerType=='Real'){
                var updateUserCoinData = {
                    table:'roulettnew.tbl_users',
                    setdata:"coins="+lcoin,
                    condition:"user_id="+respon.data[0].user_id
                };
                common_model.saveData(updateUserCoinData,function(response){  
                });
            }
            var deductData = {
                message:defalutcoinDeduct+" is deducted",
                balanceCoins:lcoin
            };  
            io.to(player.socketId).emit("coinUpdates",deductData);
        });
    }       
}


function tempPointsAdd(match,player,points){
    //if(match.isGameStart==true && (match.isGameOver==false || match.isNextRound==false ))
        var totalPoint =parseFloat(points)*parseFloat(match.matchValue);
        match.pointDeductArray[player.userId]=totalPoint;    
        var deductCoins = parseFloat(match.maxPointLimit) * parseFloat(match.matchValue);
        player.totalPoints = totalPoint;
        var addCoinToPlayer = parseFloat(deductCoins)- parseFloat(totalPoint);
        var lastCoins = (parseFloat(player.coins))+(parseFloat(addCoinToPlayer)) ;
        if(player.playerType=='Real'){
       
            if(lastCoins >= deductCoins){
            } else{
                player.isBlocked = true;
                player.isGameBlock = true;
                io.to(player.socketId).emit("winnerMsg","You have not enough balance to play game.");
            }
        }
     
}
function changeBotCards(){

}
// send show cards
function sendShowCards(data){
    var match = findMatchByTableId(data.tableId);
    if(match.isShowCards){
        var player = findPlayerById(data.socketId,match);
        var pIndex = match.players.indexOf(player);   
        if(pIndex > -1){
            player.continueNotPlayCount =0;
            if(player.isturn == true && data.isCard==true){
                player.isBlocked = false;
                match.cardThrow=true;
                player.isWinner =true;
                io.to(player.socketId).emit("sendShowCardMsg","Cards sequence is true");
            }
            if(player.isturn == true && data.isCard==false){
                player.isBlocked = true;                
                player.isCardsShow = true;
                match.isShowCards = false;

                for (var i = 0; i < match.players.length; i++) {
                    if(match.players[i].isBlocked==false){
                        match.players[i].isShowCards=false;
                    }
                }
                var tempTotalPoint = parseFloat(player.totalPoints) + parseFloat(match.maxPointLimit); 
                player.tempGamePoint = match.maxPointLimit;
                player.totalPoints = tempTotalPoint;
                player.tempGameCards = data.cards;
                player.tempCardGroup = data.cardGroup;
                
                io.to(player.socketId).emit("sendShowCardMsg","Invalid Cards You Are Block For This Round");  
                if(match.game.gameType=='Point'){
                    tempPointsAdd(match,player,match.maxPointLimit);                    
                    var isGameBlockCount = gameBlockCountFunction(match);
                    var block = isBlockedPlayerCount(match);                  
                    if(isGameBlockCount.blockLength==1){
                        pointFunction(match,'Point');
                    }else if(block.blockLength==1){
                        //var winIndex = match.players.indexOf(block.winPlayer);
                        block.winPlayer.tempGamePoint = 0;
                        block.winPlayer.tempGameCards = block.winPlayer.cards;
                        block.winPlayer.isCardsShow = true;
                        pointFunction(match,'blockWin');
                    }else{
                        match.isShowCards = false;
                        timesup(match);
                    }
                }              
              
                if(match.game.gameType=='Bestof'){
                    var block = isBlockedPlayerCount(match);
                    var noOfRound = match.game.gameOrpoint;
                    if(block.blockLength==1){
                        block.winPlayer.tempGamePoint = 0;
                        block.winPlayer.tempGameCards = block.winPlayer.cards;
                        block.winPlayer.isCardsShow = true;
                        besofFunction(match,'blockWin');                       
                    }else{
                        match.isShowCards = false;
                        timesup(match);
                    }
                }
                if(match.game.gameType=='Pool'){
                    //var tempTotalPoint = parseFloat(player.totalPoints) + parseFloat(match.maxPointLimit);                   
                    if(tempTotalPoint >= match.game.gameOrpoint){
                        player.isBlocked = true;         
                        player.isGameBlock = true;
                        io.to(player.socketId).emit("winnerMsg","You are loss.");
                    }
                    var isGameBlockCount = gameBlockCountFunction(match);
                    var block = isBlockedPlayerCount(match);
                    if(isGameBlockCount.blockLength==1){
                        poolFunction(match,'Pool');
                    }else if(block.blockLength==1){
                        block.winPlayer.tempGamePoint = 0;
                        block.winPlayer.tempGameCards = block.winPlayer.cards;
                        block.winPlayer.isCardsShow = true;
                        poolFunction(match,'blockWin');
                    }else{
                        match.isShowCards = false;
                        timesup(match);
                    }
                }
                
            }else{
                if(player.isCardsShow == false){                   
                    player.isCardsShow = true;
                    var totalPoint = parseFloat(Number(data.point)) + parseFloat(player.totalPoints);
                    player.tempGamePoint = Number(data.point);
                    player.tempGameCards = data.cards;
                    player.tempCardGroup = data.cardGroup;
                    if(match.game.gameType=='Point'){    
                        tempPointsAdd(match,player,data.point);
                    }                   
                    // var dataPoint = {
                    //     name:player.userName,
                    //     isWinner:'--',
                    //     gamePoints:player.tempGamePoint,
                    //     totalPoints:totalPoint,
                    //     socketId:player.socketId,
                    //     userId:player.userId,
                    //     cards:player.tempGameCards,
                    //     cardGroup:player.tempCardGroup,
                    //     message:""                       
                    // };
                    var isCardShowCount = 0;
                    for (let i = 0; i < match.players.length; i++) {
                        if(match.players[i].isCardsShow == true){
                            isCardShowCount += parseFloat(1);
                        }
                    }
                    if(isCardShowCount==match.players.length){
                        match.showCardTime = 1;
                    }
                  //  io.to(player.socketId).emit("singleResult",dataPoint);
                }
            }
        }
    }
}

// cards point addition
function getpoints(cards){
    var point = 0;
    for (let i = 0; i < cards.length; i++) {
        point += parseFloat(cards[i].cardValue);
    }
    return point;
}
// get cards
function getcardsPoint(match){
    var players =match.players;
    for (let i = 0; i < players.length; i++) {
        if(players[i].isturn !== true ){
           if(!players[i].isCardsShow){
                if(players[i].isGameBlock==false){                   
                    players[i].isCardsShow = true;
                    players[i].tempGamePoint = match.maxPointLimit;
                    players[i].tempGameCards = players[i].cards;                    
                    if(match.game.gameType=='Point'){
                        tempPointsAdd(match,players[i],match.maxPointLimit); 
                    }
                }else{
                    players[i].isBlocked = true; 
                }
                           
           }
        }
    }
}
// blocked player count
function isBlockedPlayerCount(match){
    var block={
        blockLength:0,
        winPlayer:0,
    };
    for (let i = 0; i < match.players.length; i++) {
        if(match.players[i].isBlocked == false){
            block.blockLength = block.blockLength + 1;
            block.winPlayer = match.players[i];
        }   
    }
    return block;
}

//findOpenCardFunction
function findOpenCardFunction(match,data){
    for (let i = 0; i < match.openDeck.length; i++) {
        if(match.openDeck[i].cardIndex==data.getcard.cardIndex){
            match.openDeck.splice(i,1);
            return "ok fine";
        } 
    }
    return false;
}
//shuffle cards
function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;
    // While there remain elements to shuffle...
    while (0 !== currentIndex) {  
      // Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1; 
      // And swap it with the current element.
      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }
    return array;
}
// removePlayerCardFunction
function removePlayerCardFunction(match,data){
    for (let i = 0; i < match.players.length; i++) {
        for (let j = 0; j < match.players[i].disCards.length; j++) {
           if(match.players[i].disCards[j].cardIndex==data.getcard.cardIndex){               
               match.players[i].disCards.splice(j,1);
               return "ok discard";
           }
        }
    }
    return false;
}
// getCard function 
function getCard(data){
    var match = findMatchByTableId(data.tableId);
    if(match){
        var player = findPlayerByUserId(match,data.userId);
        if(player){
            if(player.cards.length  ==  13 && player.isturn==true){
                player.isFirstTurn=true;
                if(data.cardThrow  ==  'nextcard'){
                    match.turnAndCard.nextcard = match.leftCards.shift();
                }else{          
                    var openDeckStatus =  findOpenCardFunction(match,data);
                    if(openDeckStatus){
                       removePlayerCardFunction(match,data);
                    }
                }
                if(match.leftCards.length==0){
                    var openDesk = shuffle(match.openDeck);
                    match.leftCards =openDesk;
                }
                player.cards.push(data.getcard);
                match.turnAndCard.cardEvent = "get";
                match.turnAndCard.whichCard=data.cardThrow;
                io.to(data.socketId).emit("updateCards",player.cards);
                io.in(match.tableId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
                match.turnAndCard.cardEvent=false;
            }
        }
        
    }
}
// throwCard function
function throwCard(socketId,tableId,cardIndex,isDropFrom){
    var match = findMatchByTableId(tableId);
    if(match){
        var player = findPlayerById(socketId,match);
        if(player){
            var pIndex = match.players.indexOf(player);
            var cards = player.cards; 
            if(cards.length  ==  14 && player.isturn == true){
               var index = -1;
                for (let i = 0; i < cards.length; i++) {
                    if(cards[i].cardIndex == cardIndex){
                        index =cards.indexOf(cards[i]);
                        if (index > -1) {
                            player.disCards.push(cards[i]);
                            match.openDeck.push(cards[i]);
                            match.turnAndCard.cardEvent="drop";
                            match.turnAndCard.oldOpenCard= match.turnAndCard.openCard;
                            match.turnAndCard.openCard = cards[i];
                            
                            player.cards.splice(index, 1);
                            io.to(player.socketId).emit("updateCards",player.cards);
                            nextTurnFunction(match,pIndex,isDropFrom);
                            match.turnAndCard.cardEvent=false;
                        }
                    }
                }
            }
       }
    }
}
function throwCard2(userId,tableId,cardIndex,isDropFrom){
    var match = findMatchByTableId(tableId);
    if(match){
       var player = findPlayerByUserId(match,userId);
        if(player){
           var pIndex = match.players.indexOf(player);
            var cards = player.cards; 
            if(cards.length  ==  14 && player.isturn == true){
               var index = -1;
                for (let i = 0; i < cards.length; i++) {
                    if(cards[i].cardIndex == cardIndex){
                        index =cards.indexOf(cards[i]);
                        if (index > -1) {
                            player.disCards.push(cards[i]);
                            match.openDeck.push(cards[i]);
                            match.turnAndCard.cardEvent="drop";
                            match.turnAndCard.oldOpenCard= match.turnAndCard.openCard;
                            match.turnAndCard.openCard = cards[i];
                            
                            player.cards.splice(index, 1);
                            io.to(player.socketId).emit("updateCards",player.cards);
                            nextTurnFunction(match,pIndex,isDropFrom);
                            match.turnAndCard.cardEvent=false;
                        }
                    }
                }
            }
       }
    }
}

// next turn function
function nextTurnFunction(match,pIndex,isDropFrom){    
    var currentTrn = nextIndexTest(match,pIndex,1);
    if(currentTrn!='Win'){
        for (let i = 0; i < match.players.length; i++) {
            if(i == currentTrn){
                match.whosTurn =match.players[i].playerType;
                match.players[i].isturn=true;
            }else{
                match.players[i].isturn=false;
            }
        }
        
    }   
    if(isDropFrom == 'left'){
        match.players.splice(pIndex, 1);
    }

    match.turnAndCard.currentTurnIndex = currentTrn;
    // match.turnAndCard.nextTurnIndex = nextTrn;
    io.in(match.tableId).emit("playerObject",match.players);
    io.in(match.tableId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
    match.cardDropTime = match.constCardDropTime; 
}
// next indext test
function turnAndCount(players){
    var data={
        trueTurnLength:0,
        turnPlayer:0,
    };
    for (let i = 0; i < players.length; i++) {
        if(players[i].isturn == true){
            data.trueTurnLength = data.trueTurnLength + 1;
            data.turnPlayer = players[i];
        }   
    }
    return data;
}
// next indext test
function nextIndexTest(match,pIndex,attempt){
    if(match.players.length-1 == pIndex){
        next = 0;
    }else{
        next = pIndex+1;
    }
    var isGameBlockCount = gameBlockCountFunction(match);
    var block = isBlockedPlayerCount(match); 
    if(isGameBlockCount.blockLength==1){
        if(match.game.gameType=='Point'){
            pointFunction(match,'Point');
        }
        if(match.game.gameType=='Pool'){
            poolFunction(match,'Pool');
        } 
        if(match.game.gameType=='Bestof'){
            besofFunction(match,'Bestof');
        }       
        return "Win";
    }else if(block.blockLength==1){
        block.winPlayer.tempGamePoint = 0;
        block.winPlayer.tempGameCards = block.winPlayer.cards;
        block.winPlayer.isCardsShow = true;
        if(match.game.gameType=='Bestof'){
            besofFunction(match,'blockWin');
        }
        if(match.game.gameType=='Pool'){
            poolFunction(match,'blockWin');
        }                
        if(match.game.gameType=='Point'){  
            pointFunction(match,'blockWin');                  
        }
        return "Win";
    }else  if(match.players[next]!=undefined){
        if(match.players[next].isGameBlock == true){
            match.players[next].isBlocked = true;
        }
        if(match.players[next].isBlocked  ==  true){
            attempt +=1;
            nextIndexTest(match,next,attempt);
        }
    }
    if(match.players[next]){

    }
    if(attempt==7){
        return 0;
    }    
    return next;
}

// when disconnect user
function playerDisconnected(socket) {
    var match = findMatchByTableId(socket.tableId);    
    if(match){
     var getval =  leftFromTable(socket);
      if(getval){
      }
    }
}
// when user left the table
function leftFromTable(socket){
    var match = findMatchByTableId(socket.tableId);
    if(match){
        var player = findPlayerById(socket.id,match);
        if(player){
            var index  = match.players.indexOf(player);
            var playerlength =match.players.length; 
            var updateData = {
                tableId:socket.tableId,
                userId:socket.userId,
                playerlength:playerlength -1,
                isGameStart:match.isGameStart
            }
            common_model.dbUpdates(updateData);
            if(match.isGameStart){
                 if (index > -1) {
                    var cards = player.cards;
                    if(match.game.gameType=='Point' && player.isWinner==false && match.isNextRound==false && match.isWinnerDefine==false){
                        var getValue= findIsDeductMoney(match,player);
                        if(getValue==false){
                           // match.pointDeductArray[player.userId] = parseFloat(match.maxPointLimit)*parseFloat(match.game.valueInput);
                           // pointDeductCoins(match,player,match.maxPointLimit);
                        }else{
                           // pointDeductCoins(match,player,player.tempGamePoint);
                        }
                    }else{
                         // console.log("yes log")
                    }
                    if(cards.length == 14 && player.isturn == true){
                        var cardIndex = cards[13].cardIndex;
                        throwCard(socket.id,socket.tableId,cardIndex,'left');
                    }else if(player.isturn == true){
                        nextTurnFunction(match,index,'left');
                    }else{
                        match.players.splice(index, 1);
                    }
                }
            }else{
                if (index > -1) {
                    match.players.splice(index, 1);
                }
                if(playerlength==1){
                    matches.splice(matches.indexOf(match), 1);
                }
            }
            socket.broadcast.to(socket.tableId).emit("leaveUser",socket.userName+" is left from this table");
            io.in(match.tableId).emit("playerObject",match.players);
            socket.leave(socket.tableId);  
        }
          
    }
    
}
function findIsDeductMoney(match,player){
    for(key in match.pointDeductArray){
        if(key==player.userId){
            return true;
        }
    }
    return false;
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
// find player list using socket id
function findPlayerById(socketId,match) {
    if(match){        
        for (var i = 0; i < match.players.length; i++) {        
            if (match.players[i].socketId  ==  socketId) {
                return match.players[i];
            }       
        }
    }
    return false;
}
function winnerFunction(match){   
    var players = match.players;
    for (let i = 0; i < players.length; i++) {
        if(players[i].socketId == match.winnerSocketId){
            if(match.isResultUpdate==false){
                    match.isResultUpdate = true;
                    var winningAmount =  match.winningAmount;                  
                    var winningCoins =  winningAmount - (winningAmount*match.adminCommition/100);
                    var updatecoin = parseFloat(winningCoins)+parseFloat(players[i].coins);
                    var updateUserCoinData = {
                        table:'pla24by7tbs_web.user_details',
                        setdata:"coins="+updatecoin,
                        condition:"user_id='"+players[i].userId+"' and playerType='"+players[i].playerType+"'"
                    };
                    common_model.saveData(updateUserCoinData,function(response){  
                    });
                    if(players[i].playerType=='Real'){
                        var updateUserCoinData = {
                            table:'roulettnew.tbl_users',
                            setdata:"coins="+updatecoin,
                            condition:"user_id='"+players[i].userId+"' and playerType='"+players[i].playerType+"'"
                        };
                        common_model.saveData(updateUserCoinData,function(response){  
                        });
                    }
                    var updateCoindata={
                        message:"You win "+winningCoins,
                        balanceCoins:updatecoin,
                        winnigAmount:match.winningAmount
                    }; 
                    io.to(players[i].socketId).emit("coinUpdates",updateCoindata);
                    var rummy_winning_data = {
                        table:'rummy_winning_details',
                        setdata:"tableId='"+match.tableId+"',userId='"+players[i].userId+"',winnigAmount='"+winningAmount+"',adminAmount='"+winningAmount*match.adminCommition/100+"',playerType='"+players[i].playerType+"',created=NOW()",
                        condition:""
                    };
                    common_model.saveData(rummy_winning_data,function(response){  
                    });  
                     //update reserver amount distribution
                    if(match.isAddBot==true && players[i].playerType=='Bot'){
                      
                        var reserverData={
                            type:'Add',
                            amount:winningCoins
                        };
                        updateReserveAmount(reserverData);
                    }
                                      
            }
            io.to(players[i].socketId).emit("winnerMsg","You are win.");
        }else{
            io.to(players[i].socketId).emit("winnerMsg","You are loss.");
        }
    }  
}
//update reserver Amount function
function updateReserveAmount(data){
    var sql ="select id,reserve_money from pla24by7tbs_web.web_admins limit 1";
    common_model.sqlQuery(sql,function(response){
        if(response.success=='1'){
            var reserve_money= response.data[0].reserve_money;
            if(data.type=='Add'){
                var updateAmount = Number(parseFloat(reserve_money).toFixed(3))+Number(parseFloat(data.amount).toFixed(3));
            }else{
                var updateAmount = Number(parseFloat(reserve_money).toFixed(3))-Number(parseFloat(data.amount).toFixed(3));
            }
            var passData={
                table:'pla24by7tbs_web.web_admins',
                setdata:'reserve_money="'+updateAmount+'"',
                condition:"id='"+response.data[0].id+"'",
            };
            common_model.saveData(passData,function(){
            });
        }     
    });
}
// update timers
function updateTimers(){
    for (var i = 0; i < matches.length; i++) {
        if(!matches[i].isGameStart){
            matches[i].waitingTime -= 1;
            io.in(matches[i].tableId).emit("waitingCountdown",matches[i].waitingTime);
            if(matches[i].waitingTime==45){
                addBotsFunction(matches[i]);   
                matches[i].isAddBot=true;
            }
            if (matches[i].waitingTime  ==  0) {
                var updateData = {
                    tableId:matches[i].tableId,
                    userId:false,
                    playerlength:0,
                    isGameStart:false
                }
                common_model.dbUpdates(updateData);
                io.in(matches[i].tableId).emit("playerObject",[]);
                matches.splice(matches.indexOf(matches[i]), 1);
            }
        }else{
             if(matches[i].players.length==matches[i].noOfBot && matches[i].isGameOver==false && matches[i].isAddBot==true && matches[i].isNextRound==false){
                if(matches[i].game.gameType=='Point' && matches[i].isWinnerDefine==false){
                     console.log("w gameType innerDefine")
                    matches[i].isfininshGame =true;
                    pointWinnerDefine(matches[i]);
                 }else if(matches[i].game.gameType=='Bestof'){
                    matches[i].winnerSocketId = matches[i].players[0].socketId;
                    findWinnerFunction(matches[i],'Bestof');
                    matches[i].isGameOver = true;
                 }else if(matches[i].game.gameType=='Pool'){
                    matches[i].winnerSocketId = matches[i].players[0].socketId;
                    poolWinnerFunction(matches[i],'Pool');
                 }
                    matches[i].isGameOver = true;
             }else if(matches[i].players.length==1 && matches[i].isGameOver==false){
                if(matches[i].game.gameType=='Point' && matches[i].isWinnerDefine==false){
                    console.log("winnerDefine")
                    if(matches[i].isNextRound==false){
                        matches[i].isfininshGame =true;
                        pointWinnerDefine(matches[i]);
                    }else{
                    }
                        matches[i].isGameOver = true;
                }else{
                    winnerDefine(matches[i]);
                }
                
            }else if(matches[i].isGameOver==true){
                matches[i].gameOverTime -= 1;
                //if(matches[i].isNextRound == false){
                    if(matches[i].game.gameType!='Point' && matches[i].gameOverTime==5){
                        winnerFunction(matches[i]);
                    }

                //}
                io.in(matches[i].tableId).emit("gameOverTime",matches[i].gameOverTime);
                io.in(matches[i].tableId).emit("tableResults",matches[i].tableResults);
                if (matches[i].gameOverTime == 0) {
                    matches.splice(matches.indexOf(matches[i]), 1);                    
                }
            }else if(matches[i].isNextRound == true){
                matches[i].nextRoundTime -= 1;
                io.in(matches[i].tableId).emit("nextRoundTime",matches[i].nextRoundTime);
                io.in(matches[i].tableId).emit("tableResults",matches[i].tableResults);
               if (matches[i].nextRoundTime == 1 && matches[i].isAddBot==true && matches[i].game.gameType=='Point' && matches[i].isfininshGame==false) {
                    botDeductMoney(matches[i]);
               }
                if (matches[i].nextRoundTime == 0) {
                    nextRoundTime(matches[i]);
                }
            }else{
                if(matches[i].isShowCards){
                    matches[i].showCardTime -= 1;
                    io.in(matches[i].tableId).emit("showCardTime",matches[i].showCardTime);
                    if(matches[i].isAddBot==true && matches[i].showCardTime==15){
                        botShowFunction(matches[i]);
                    }
                    if (matches[i].showCardTime == 0) {
                        showCardTime(matches[i]);
                    }
                }else{
                    matches[i].cardDropTime -= 1;
                    
                    io.in(matches[i].tableId).emit("cardDropTimeCount",matches[i].cardDropTime);
                    if(matches[i].cardDropTime==25 && matches[i].whosTurn=='Bot'){   
                        botGetCard(matches[i]);
                    }
                    if (matches[i].cardDropTime == 0) {
                        timesup(matches[i]);
                    }
                }
            }
        }
    }
    setTimeout(updateTimers, 1000);
}

function botShowFunction(match){
    var players =match.players;
    for (let i = 0; i < players.length; i++) {
        if(players[i].isturn == false ){
           if(players[i].isCardsShow==false && players[i].playerType=='Bot'){
                if(players[i].isGameBlock==false){
                   
                if(players[i].isWinnerBot==true){
                    var points = players[i].botReservePoint;
                    var cards  = players[i].reserverBotWrongCards;

                }else{
                     var points = players[i].botPoints;
                    var cards  = players[i].cards;
                }
                  
                    var sendCardData= {
                        isCard:false,
                        point:points,
                        cards:cards,
                        tableId:match.tableId,
                        socketId:players[i].socketId,
                        cardGroup:{
                            groups:[3,4,3,3],
                            result:"Inorrect"
                        }
                    }; 
                    players[i].tempGamePoint = players[i].botPoints;
                    players[i].tempGameCards = players[i].cards; 
                    sendShowCards(sendCardData)                 
                    players[i].isCardsShow = true;
                   
                }
                           
           }
        }
    }
}
function botGetCard(match){
    var timeArray = [2000,3000,4000,5000,6000];
    var randomTime=timeArray[Math.floor(Math.random()*timeArray.length)];
    var data =  {
        cardThrow:'nextcard',
        getcard:match.turnAndCard.nextcard,
        tableId:match.tableId,
        data:"bybot"
    };   
    var player  = findIsTurnIndex(match);
    if(player){
        data['socketId']=player.socketId;
        data['userId']=player.userId;
        if(player.isWinnerBot==true && player.botTurnCount!=0){
            player.botTurnCount -=1;
        }
        console.log(player.botTurnCount)
       
        getCard(data);
        if(player.botTurnCount <=0 && player.isWinnerBot==true){
            setTimeout(function() {
                if(player.cards.length==14){
                    var showCardData= {
                        tableId:match.tableId,
                        socketId:player.socketId,
                    };        
                    showCard(showCardData);
                    setTimeout(function() {
                        player.cards.splice(13, 1);
                        var sendCardData= {
                            isCard:true,
                            point:0,
                            cards:player.cards,
                            tableId:match.tableId,
                            socketId:player.socketId,
                            cardGroup:{
                                groups:[3,4,3,3],
                                result:"Correct"
                            }
                        };   
                        sendShowCards(sendCardData);
                      
                    },randomTime);
                }
            }, randomTime);
            
        }else{
            setTimeout(function() {
                if(player.cards.length==14){
                     var cardIndex =player.cards[13].cardIndex;
                    if(player.cards[13].cardValue==0){
                        var getCData=  getCardIndexForBot(player);  
                        if(getCData!=false){
                            cardIndex = getCData.cardIndex;
                        }                    
                    }
                    throwCard(player.socketId,match.tableId,cardIndex,"normal");
                }
            }, randomTime);
        }                
    }    
}
// getCardIndexForBot
 function getCardIndexForBot(player) {
    for (var i = 3; i < 13; i++) {
        if(player.cards[i].cardValue!=0){ 
            player.cards.splice(i, 0, player.cards[13]);
            player.cards.splice(14, 1);         
            return player.cards[i+1];
        }
    }
    return false;
 }
//nextRoundTime
function nextRoundTime(match){
    nextRoundFunction(match);
    match.isNextRound=false;
    match.nextRoundTime = roundTime;
}
//time up function
function timesup(match) {
    var player  = findIsTurnIndex(match);
    var pIndex = match.players.indexOf(player);
    if (pIndex > -1){
        var cards = player.cards;
        player.isFirstTurn = true;
        var playcount = parseFloat(player.continueNotPlayCount) + parseFloat(1);
        player.continueNotPlayCount = playcount;
        if(continueNotPlayCountLimit==player.continueNotPlayCount){          
            if(match.game.gameType=='Pool'){
                player.isBlocked = true; 
                player.tempGamePoint = match.middleDropPoint;
                player.tempGameCards = player.cards;
                player.tempCardGroup = {
                            groups:[3,4,3,3],
                            result:"Inorrect"
                        };
                var tempTotalPoint = parseFloat(player.totalPoints) + parseFloat(match.middleDropPoint); 
                player.totalPoints =   tempTotalPoint;
                if(tempTotalPoint >= match.game.gameOrpoint){
                    player.isBlocked = true;                                 
                    player.isGameBlock = true;
                    io.to(player.socketId).emit("winnerMsg","You are loss.");
                }
            }else if(match.game.gameType=='Point'){   
                player.tempGamePoint = match.middleDropPoint;
                player.tempGameCards = player.cards;
                player.tempCardGroup = {
                            groups:[3,4,3,3],
                            result:"Inorrect"
                        };
                player.isBlocked = true;                
                player.isGameBlock = true;                
                player.isCardsShow = true;         
                tempPointsAdd(match,player,match.middleDropPoint);
            }else if(match.game.gameType=='Bestof'){
                player.tempGamePoint = match.maxPointLimit;
                player.tempGameCards = player.cards;
                player.tempCardGroup = {
                            groups:[3,4,3,3],
                            result:"Inorrect"
                        };

                player.isBlocked = true;                
                player.isCardsShow = true;
            }
        }
        var cards = player.cards;
        var isGameBlockCount = gameBlockCountFunction(match);
        var block = isBlockedPlayerCount(match); 
        if(isGameBlockCount.blockLength==1){
            if(match.game.gameType=='Point'){
                pointFunction(match,'Point');
            }
            if(match.game.gameType=='Pool'){
                poolFunction(match,'Pool');
            }       
        }else if(block.blockLength==1){
            //var winIndex = match.players.indexOf(block.winPlayer);
            block.winPlayer.tempGamePoint = 0;
            block.winPlayer.tempGameCards = block.winPlayer.cards;
            block.winPlayer.tempCardGroup = {
                            groups:[3,4,3,3],
                            result:"Inorrect"
                        };
            block.winPlayer.isCardsShow = true;
            if(match.game.gameType=='Bestof'){
                besofFunction(match,'blockWin');
            }
            if(match.game.gameType=='Pool'){
                poolFunction(match,'blockWin');
            }                
            if(match.game.gameType=='Point'){  
                pointFunction(match,'blockWin');                  
            }
        }else if(cards.length == 14 && player.isturn == true){
            var cardIndex = cards[13].cardIndex;
            throwCard(player.socketId,match.tableId,cardIndex,'normal');
            //throwCard(socket.id,socket.tableId,cardIndex,'normal');
        }else if(player.isturn == true){
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
// add bot function 
function addBotsFunction(match){ 
    if(match){
        var remainingPlayer =match.matchPlayers-match.players.length;
        if(remainingPlayer > 0){
            match.noOfBot = remainingPlayer;
          //  if(match.game.valueType!='Point'){
                botDeductMoney(match);
           // }
            var data ={
                table:'rummy_tables',
                setdata:"status='BotAdding'",
                condition:"tableId="+match.tableId
            }; 
            common_model.saveData(data,function(res){
                    var sql ="select user_id,user_name,coins from pla24by7tbs_web.user_details where playerType='Bot' order by rand() limit "+remainingPlayer+"";
                    common_model.sqlQuery(sql,function(res){
                        if(res.success==1){                            
                            var botUsers=res.data;                           
                            joinBotDataFunction(match,botUsers);
                        }                       
                    });
            });
        }
    }
}
//join Bot Data Function 
function joinBotDataFunction(match,botUsers){
    for (let i = 0; i < botUsers.length; i++) {
        var userData= {
                    roomId:match.matchRoomId,
                    players:match.matchPlayers,
                    value:match.matchValue,
                    userId:botUsers[i].user_id,
                    playerType:'Bot',
                    tableId:match.tableId
        }
        var socke ='';
        joinBotsRoomTable(socke,userData);
    }
}
// update status when game is no of player = join no. of player
function updateStatus(match){
    if(match){
        var data ={
            table:'rummy_tables',
            setdata:"status='Active'",
            condition:"tableId="+match.tableId
        } 
        common_model.saveData(data,function(res){
            startMatchFunction(match);
        });
    }
}
// join bot room function 
function joinBotsRoomTable(socket,data){
    common_model.joinBotsTableFunc(data,function(res){
        var tableId = res.tableId;
        var userName = res.userName;
        var userId = res.userId;
        if(socket!=''){
            var socketId = socket.id;
            socket.userName =userName;
            socket.tableId = tableId;
            socket.userId= userId;
            usernames[socket.userName]=userName;  
            socket.join(tableId);
        }else{
            var socketId = userId;
        }
        var match = findMatchByTableId(tableId);
        if(res.valueType=='Point'){
            var coins = parseFloat(res.coins);
        }else{
            var coins = parseFloat(res.coins) - parseFloat(data.value);
        }
        var playerObject = {           
            isturn:false,
            tableId: tableId,
            isGameBlock:false,
            isBlocked:false,            
            totalPoints:0,
            gamePoints:0,
            userId:userId,
            disCards:[],
            userName:userName,
            socketId: socketId,
            tempGamePoint:0,
            tempGameCards:[],            
            tempCardGroup:[],  
            isDisconnet:false,
            continueNotPlayCount:0,
            isPoinCoinDeduct:false,
            isStart:false,
            isWinner:false,
            isCardsShow:false,
            isFirstTurn:false,
            totalTurn:0,
            coins:coins,
            cards:false,
            isWinnerBot:false,
            botTurnCount:0,
            playerType:res.playerType,
            botShowTime:0,
            botPoints:0,
            botReservePoint:0,
            isDeductMoney:false,
            reserverBotWrongCards:false,
            reserverRandNum:false,
            blockForAllRound:false,
        };
        if(!match){   
            var istable = {
                whosTurn:false,
                tableResults:[],  
                matchValue:Number(parseFloat(res.value)),
                matchPlayers:res.players,
                matchRoomId:res.roomId,
                adminCommition:Number(res.adminCommission),
                tableId: tableId,
                disconnectCount:0,
                isAddBot:false,
                noOfBot:0,
                botPointsAmount:0,
                realPlayerPointsAmount:0,
                isAllDisconnet:false,
                winnerSocketId:false,
                isResultUpdate:false,
                winningAmount:0,
                openDeck:[],
                round:1, 
                isDropPoint:res.isDropPoint,
                firstDropPoint:res.firstDropPoint,
                middleDropPoint:res.middleDropPoint,
                maxPointLimit:res.maxPointLimit,
                game:{
                    valueType:res.valueType,
                    gameOrpoint:res.gameOrpoint,
                    gameType:res.gameType,
                    valueInput:res.value,
                    scoreBoard:[],
                },
                cardThrow:false,
                isShowCards:false,
                isNextRound:false,
                lastTurnIndex:false,
                constCardDropTime:res.cardDropTime,
                constShowCardTime:showTime,
                constNextRoundTime:roundTime,
                waitingTime:res.waitingTime,
                cardDropTime:res.cardDropTime,
                showCardTime:showTime,
                nextRoundTime:roundTime,
                gameOverTime:gameOverTime,
                players: [],
                jocker:false,
                leftCards:[],
                remainingCards: {
                    openCard:false,
                    nextcard:false,
                },
                score: [],
                isGameStart:false,
                isGameOver:false,
                turnAndCard:{
                    cardEvent:false,
                    whichCard:false,
                    openCard:false,
                    nextcard:false,
                    oldOpenCard:false,
                    currentTurnIndex:false,
                },
                pointDeductArray:{},
                isWinnerDefine:false,
                isfininshGame:false,
            };
            istable.players.push(playerObject);
            io.in(tableId).emit("playerObject",istable.players);
            matches.push(istable);
        }else{   
            match.players.push(playerObject);
            if(match.matchPlayers==match.players.length){
                updateStatus(match);                
            }else{
                io.in(tableId).emit("playerObject",match.players);
            }
        }
    });
}
// for jon room 
function joinRoomTable(socket,data){
    common_model.joinTableFunc(data,function(res){
        var tableId = res.tableId;
        var userName = res.userName;
        var userId = res.userId;
        if(socket!=''){
            var socketId = socket.id;
            socket.userName =userName;
            socket.tableId = tableId;
            socket.userId= userId;
            usernames[socket.userName]=userName;  
            socket.join(tableId);
        }else{
            var socketId = userId;
        }
        var match = findMatchByTableId(tableId);
        if(res.valueType=='Point'){
            var coins = parseFloat(res.coins) -Number(parseFloat(data.value))*80;;
        }else{
            var coins = parseFloat(res.coins) - parseFloat(data.value);
        }
        var playerObject = {           
            isturn:false,
            tableId: tableId,
            isGameBlock:false,
            isBlocked:false,            
            totalPoints:0,
            gamePoints:0,
            userId:userId,
            disCards:[],
            userName:userName,
            socketId: socketId,
            tempGamePoint:0,
            tempGameCards:[],            
            tempCardGroup:[],  
            isDisconnet:false,
            continueNotPlayCount:0,
            isPoinCoinDeduct:false,
            isStart:false,
            isWinner:false,
            isCardsShow:false,
            isFirstTurn:false,
            totalTurn:0,
            coins:coins,
            cards:false,
            isWinnerBot:false,
            botTurnCount:0,
            playerType:res.playerType,
            botShowTime:0,
            botPoints:0,
            botReservePoint:0,
            isDeductMoney:false,
            reserverBotWrongCards:false,
            reserverRandNum:false,
            blockForAllRound:false,
            
        };
        if(!match){   
            var istable = {
                whosTurn:false,
                botTurnWinNum:false,
                tableResults:[],  
                matchValue:Number(parseFloat(res.value)),
                matchPlayers:res.players,
                matchRoomId:res.roomId,
                adminCommition:Number(res.adminCommission),
                tableId: tableId,
                disconnectCount:0,
                isAddBot:false,
                noOfBot:0,
                botPointsAmount:0,
                isAllDisconnet:false,
                winnerSocketId:false,
                isResultUpdate:false,
                winningAmount:0,
                openDeck:[],
                round:1, 
                isDropPoint:res.isDropPoint,
                firstDropPoint:res.firstDropPoint,
                middleDropPoint:res.middleDropPoint,
                maxPointLimit:res.maxPointLimit,
                game:{
                    valueType:res.valueType,
                    gameOrpoint:res.gameOrpoint,
                    gameType:res.gameType,
                    valueInput:res.value,
                    scoreBoard:[],
                },
                cardThrow:false,
                isShowCards:false,
                isNextRound:false,
                lastTurnIndex:false,
                constCardDropTime:res.cardDropTime,
                constShowCardTime:showTime,
                constNextRoundTime:roundTime,
                waitingTime:res.waitingTime,
                cardDropTime:res.cardDropTime,
                showCardTime:showTime,
                nextRoundTime:roundTime,
                gameOverTime:gameOverTime,
                players: [],
                jocker:false,
                leftCards:[],
                remainingCards: {
                    openCard:false,
                    nextcard:false,
                },
                score: [],
                isGameStart:false,
                isGameOver:false,
                turnAndCard:{
                    cardEvent:false,
                    whichCard:false,
                    openCard:false,
                    nextcard:false,
                    oldOpenCard:false,
                    currentTurnIndex:false,
                },
                pointDeductArray:{},
                isWinnerDefine:false,
                isfininshGame:false,
            };
            istable.players.push(playerObject);
            io.in(tableId).emit("playerObject",istable.players);
            matches.push(istable);
        }else{   
            match.players.push(playerObject);
            if(match.matchPlayers==match.players.length){
                updateStatus(match);                
            }else{
                io.in(tableId).emit("playerObject",match.players);
            }
        }
    });
}
function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;
    // While there remain elements to shuffle...
    while (0 !== currentIndex) {  
      // Pick a remaining element...
      randomIndex = Math.floor(Math.random() * currentIndex);
      currentIndex -= 1; 
      // And swap it with the current element.
      temporaryValue = array[currentIndex];
      array[currentIndex] = array[randomIndex];
      array[randomIndex] = temporaryValue;
    }
    return array;
}

function botDeductMoney(match){

   
    if(match.game.valueType=='Point'){
        var usrAmt = (Number(parseFloat(match.matchValue))*Number(parseFloat(match.maxPointLimit)));
    }else{
        var usrAmt = Number(parseFloat(match.matchValue)) -(Number(parseFloat(match.matchValue)) * Number(match.adminCommition)/100);
    }
    var botData = {
        table:'pla24by7tbs_web.web_admins',
        fields:"reserve_money",
        condition:"id!='0'"
    };
    common_model.GetData(botData,function(getresponsebot){
        if(getresponsebot.success==1){
            var damount = (Number(parseFloat(getresponsebot.data[0].reserve_money).toFixed(2))) - (Number(parseFloat(match.noOfBot)*Number(parseFloat(usrAmt))));
           
            var updateUserCoinData = {
                table:'pla24by7tbs_web.web_admins',
                setdata:"reserve_money="+damount,
                condition:"id!=0"
            };                            
            common_model.saveData(updateUserCoinData,function(response){  
            });
            if(damount < 100){
                match.botTurnWinNum = winRound;//[1];
            }else{
                match.botTurnWinNum = winNonRound;//[1];
            }
        }
            
    });
}
// join table 
function startMatchFunction(match){  
    var winAmt = Number(match.matchPlayers) * Number(match.matchValue);
    common_model.getAllCards(match.matchPlayers,function(getCards){
        common_model.shuffleCards(getCards,function(response){
             // return false;
            var catArray =[];
            var catArray = response.twoCatArray;
            var botCardArray = botCards.cards3(Number(match.noOfBot));
            var distributeCardArray = [];
            for (let i = 0; i < botCardArray.length; i++) {
                var botCard = botCardArray[i].dataStore;
                var botGroup = botCardArray[i].groups;
                var botCArray =[];
                for (var j in botCard){ 
                    var isRemove = false;             
                    var cardType = getCardType(botCard[j]);
                    for (let k = 0; k < catArray.length; k++) {
                        if(botCard[j]==0){
                            if(catArray[k].cardValue == botCard[j] && isRemove == false){
                                isRemove = true;
                                botCArray.push(catArray[k]);
                                catArray.splice(catArray.indexOf(catArray[k]),1);
                            }  
                        }else{
                            if(catArray[k].cardId == botCard[j] && cardType == catArray[k].cardType && isRemove == false){
                                isRemove = true;
                                botCArray.push(catArray[k]);
                                catArray.splice(catArray.indexOf(catArray[k]),1);
                            }  
                        }                                     
                    }
                }
                if(botCArray.length !=13){
                    var spiceNo = 13-botCArray.length;
                    var extraSpice = catArray.splice(0, spiceNo);
                    botCArray = botCArray.concat(extraSpice);
                }
                var botData={
                    botCArray:botCArray,
                    botGroup:botGroup,
                    points:0
                }
                distributeCardArray.push(botData);           
            }     

            // bot card distribution end
            var rannum  = Math.floor(Math.random() * (match.players.length - 0)) + 0;
            match.lastTurnIndex=rannum;
            var matchPlayers = match.players;
            // var isWinnerBot = false;
            var botPosition = 0;
            var botTurnCount = 0;
            var botTurnWinNum = match.botTurnWinNum;
            botTurnCount =  botTurnWinNum[Math.floor(Math.random()*botTurnWinNum.length)];
            for (var i = 0; i < matchPlayers.length; i++){                
                if(i == rannum){
                    match.whosTurn = matchPlayers[i].playerType;
                    matchPlayers[i].isturn = true;
                }
                if(match.isAddBot == true && matchPlayers[i].playerType == 'Bot'){                    
                    if(distributeCardArray[botPosition].botGroup==4){
                        // NEW BOT RESERVE CARD 
                        var botWinReserverCardRandNo = [3,6,10];
                        var reserverRandNum=botWinReserverCardRandNo[Math.floor(Math.random()*botWinReserverCardRandNo.length)];
                        reserverRandNum =3;
                        var winBCard =  distributeCardArray[botPosition].botCArray; 
                        var winBCard2  = catArray.splice(0, reserverRandNum);
                        var lno= 13 - reserverRandNum;
                        var carwinBCard3 =winBCard.splice(lno,13);
                        matchPlayers[i].reserverBotWrongCards =winBCard.concat(winBCard2);
                        matchPlayers[i].reserverRandNum =reserverRandNum;
                        distributeCardArray[botPosition].botCArray = distributeCardArray[botPosition].botCArray.concat(carwinBCard3);
                        // NEW BOT RESERVE CARD END

                        matchPlayers[i].isWinnerBot = true;
                        matchPlayers[i].botTurnCount = botTurnCount;

                    } else{
                        matchPlayers[i].isWinnerBot =false;
                    }
                    
                    matchPlayers[i].botPoints = distributeCardArray[botPosition].points;
                    var splice = distributeCardArray[botPosition].botCArray; 
                    botPosition = botPosition+1;
                }else{
                    var splice = catArray.splice(0, 13); 
                }  
                if(splice.length != 13){
                    var spiceNo = 13-splice.length;
                    var extraSpice = catArray.splice(0, spiceNo); 
                    splice = splice.concat(extraSpice);
                }    
                matchPlayers[i].cards =splice;
                matchPlayers[i].isStart =true;
                matchPlayers[i].isCardsShow =false;
                io.to(matchPlayers[i].socketId).emit("updateCards",matchPlayers[i].cards);
                if(match.game.valueType!='0'){
                    if(match.game.valueType=='Point'){
                        var usrAmt = Number(parseFloat(match.matchValue))*Number(parseFloat(match.maxPointLimit));
                    }else{
                         var usrAmt = match.matchValue;
                    }
                    if(matchPlayers[i].playerType=='Real'){
                        if(match.game.valueType!='Point'){
                            var usrAmt = match.matchValue;
                            var distributionData={
                                userId:matchPlayers[i].userId,
                                userAmount:usrAmt,
                                totalAmount:Number(parseFloat(usrAmt)) * Number(match.players.length),
                                adminPercent:match.adminCommition
                            };
                            commitionDistribution(distributionData);
                            var rewardData ={
                                userId:matchPlayers[i].userId,
                                userAmount:usrAmt
                            }
                            updateRewardFunction(rewardData);
                        }else{
                            match.pointDeductArray[matchPlayers[i].userId] = parseFloat(match.maxPointLimit)*parseFloat(match.matchValue);                            
                        }
                        
                        var updateUserCoinData = {
                            table:'pla24by7tbs_web.user_details',
                            setdata:"coins="+matchPlayers[i].coins,
                            condition:"user_id="+matchPlayers[i].userId
                        };                            
                        common_model.saveData(updateUserCoinData,function(response){  
                        });

                        var updateUserCoinData = {
                            table:'roulettnew.tbl_users',
                            setdata:"coins="+matchPlayers[i].coins,
                            condition:"user_id="+matchPlayers[i].userId
                        };                            
                        common_model.saveData(updateUserCoinData,function(response){  
                        });
                        var deductData={
                            message:usrAmt+" is deducted",
                            balanceCoins:matchPlayers[i].coins,
                            winnigAmount:winAmt
                        };  
                        io.to(matchPlayers[i].socketId).emit("coinUpdates",deductData);
                    }
                    // coins update
                    match.winningAmount += Number(parseFloat(usrAmt));
                    //coins update end
                }
                if(match.isAddBot==true && matchPlayers[i].playerType=='Bot'){   
                    // botOldCards                
                    io.in(match.tableId).emit("getBotPoints",matchPlayers[i]);
                }
            }
            match.jocker = response.jocker;
            if(match.matchPlayers==6){
                common_model.getSingleCat(match.matchPlayers,function(thirdCat){
                    var dataPass= {
                        thirdCat:thirdCat,
                        resultsLength:response.resultsLength,
                        jocker:response.jocker,
                    }
                    common_model.shuffleSingleCards(dataPass,function(singlesufData){
                        catArray =catArray.concat(singlesufData.thirdCatArray);
                        catArray = shuffle(catArray);
                        match.remainingCards.leftCards = catArray;
                        match.leftCards = catArray;
                    });
                  
                });
            }else{
                match.remainingCards.leftCards = catArray;
                match.leftCards = catArray;
            }
            
            
            match.turnAndCard.openCard = response.openCard;
            match.turnAndCard.nextcard = response.nextcard; 

            match.turnAndCard.currentTurnIndex = rannum;           

            match.isGameStart = true;
            io.in(match.tableId).emit("playerObject",match.players);
            io.in(match.tableId).emit("jocker",match.jocker);
            io.in(match.tableId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
        });
    });
}
// var data = {
//     userId:284
// };
//  var getSettingData = {
//         table:"pla24by7tbs_web.web_settings",
//         fields:"reward_percent",
//         condition:"id='1'"
//     }
//     common_model.GetData(getSettingData,function(settingResonse){
//         if(settingResonse.success==1){
//              var udata = {
//                 table:'pla24by7tbs_web.user_details',
//                 fields:"coins,user_id,reward_point",
//                 condition:"user_id='"+data.userId+"'"
//             };
//             common_model.GetData(udata,function(udataResponse){
//                 if(udataResponse.success==1){
//                     var calRewardAmt = Number(parseFloat(100))*parseFloat(settingResonse.data[0].reward_percent)/100;
//                     var lcoin = parseFloat(calRewardAmt)+parseFloat(udataResponse.data[0].reward_point)
                   
//                     var updateUserCoinData = {
//                         table:'pla24by7tbs_web.user_details',
//                         setdata:"reward_point="+lcoin,
//                         condition:"user_id="+udataResponse.data[0].user_id
//                     };
//                     common_model.saveData(updateUserCoinData,function(response){  
//                     });
//                     var updateUserCoinData = {
//                         table:'roulettnew.tbl_users',
//                         setdata:"reward_point="+lcoin,
//                         condition:"user_id="+udataResponse.data[0].user_id
//                     };
//                     common_model.saveData(updateUserCoinData,function(response){  
//                     });
//                 }
//             });
//         }
//     });
//rewardFunction
function updateRewardFunction(data){
   var getSettingData = {
        table:"pla24by7tbs_web.web_settings",
        fields:"reward_percent",
        condition:"id!='0'"
    }
    common_model.GetData(getSettingData,function(settingResonse){
        if(settingResonse.success==1){
             var udata = {
                table:'pla24by7tbs_web.user_details',
                fields:"coins,user_id,reward_point",
                condition:"user_id='"+data.userId+"'"
            };
            common_model.GetData(udata,function(udataResponse){
                if(udataResponse.success==1){
                    var calRewardAmt = Number(parseFloat(data.userAmount).toFixed(2))*parseFloat(settingResonse.data[0].reward_percent)/100;
                    var lcoin = parseFloat(calRewardAmt)+parseFloat(udataResponse.data[0].reward_point)
                   
                    var updateUserCoinData = {
                        table:'pla24by7tbs_web.user_details',
                        setdata:"reward_point="+lcoin,
                        condition:"user_id="+udataResponse.data[0].user_id
                    };
                    common_model.saveData(updateUserCoinData,function(response){  
                    });
                    var updateUserCoinData = {
                        table:'roulettnew.tbl_users',
                        setdata:"reward_point="+lcoin,
                        condition:"user_id="+udataResponse.data[0].user_id
                    };
                    common_model.saveData(updateUserCoinData,function(response){  
                    });
                }
            });
        }
    });
}
// commition distribution flow 
function commitionDistribution(data){
    var url = 'https://www.play24x7games.com/WebApis/index.php/play24x7Distribution/bettingAmountDistribution';
    var myJSONObject = {userId:data.userId,userAmount:data.userAmount,totalAmount:data.totalAmount,gameType:'rummy',adminPercent:data.adminPercent};
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
// get admin commition
function getAdminCommiton(){
    var url = 'https://www.play24x7games.com:3002/getAdminCommPercent';
    var myJSONObject = {};
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
            // adminCommition = body.adminPercent;
      });
}
// next round function
function nextRoundFunction(match){
    common_model.getAllCards(match.matchPlayers,function(getCards){
        common_model.shuffleCards(getCards,function(response){
            match.tableResults =[];
            match.showCardTime =match.constShowCardTime;
            match.cardDropTime =match.constCardDropTime;
            match.isWinnerDefine =false;
            var catArray = response.twoCatArray;
              if(match.game.valueType=='Point'){
                match.winningAmount =0;
                match.pointDeductArray = {};
              }
            //bot start
            var botCardArray = botCards.cards3(Number(match.noOfBot));
            var distributeCardArray = [];
            for (let i = 0; i < botCardArray.length; i++) {
                const botCard = botCardArray[i].dataStore;
                const botGroup = botCardArray[i].groups;
                var botCArray =[];
                for (var j in botCard){ 
                    var isRemove = false;             
                    var cardType = getCardType(botCard[j]);
                    for (let k = 0; k < catArray.length; k++) {
                        if(botCard[j]==0){
                            if(catArray[k].cardValue == botCard[j] && isRemove == false){
                                isRemove = true;
                                botCArray.push(catArray[k]);
                                catArray.splice(catArray.indexOf(catArray[k]),1);
                            }  
                        }else{
                            if(catArray[k].cardId == botCard[j] && cardType == catArray[k].cardType && isRemove == false){
                                isRemove = true;
                                botCArray.push(catArray[k]);
                                catArray.splice(catArray.indexOf(catArray[k]),1);
                            }  
                        }                                     
                    }
                }
                if(botCArray.length !=13){
                    var spiceNo = 13-botCArray.length;
                    var extraSpice = catArray.splice(0, spiceNo);
                    botCArray = botCArray.concat(extraSpice);
                }          
                var botData={
                    botCArray:botCArray,
                    botGroup:botGroup,
                    points:2
                }
                distributeCardArray.push(botData);           
            }   
            var botTurnCount = 0;            
            // bot card distribution end
            var botPosition =0;
            var botTurnWinNum = match.botTurnWinNum;
             botTurnCount = botTurnWinNum[Math.floor(Math.random()*botTurnWinNum.length)];
            for (var i = 0; i < match.players.length; i++) {                
                if(match.players[i].isGameBlock==true){
                    match.players[i].isBlocked = true;
                    match.players[i].blockForAllRound = true;
                    match.players[i].isDeductMoney = true;
                    match.players[i].isCardsShow =true;
                }else{
                    match.players[i].isBlocked = false;
                    match.players[i].isDeductMoney = false;
                    match.players[i].isCardsShow =false;
                }
                match.players[i].reserverBotWrongCards =false;
                match.players[i].isWinnerBot =false;
                match.players[i].isturn=false;
                match.players[i].continueNotPlayCount=0;
                match.players[i].isGameWinner=false;
            }
            var rannum = nextIndexTest(match,match.lastTurnIndex,1);
            match.lastTurnIndex = rannum;
            for (var i = 0; i < match.players.length; i++) {
                if(match.players[i].isBlocked==false){
                    if(i == rannum){
                        match.whosTurn = match.players[i].playerType;
                        match.players[i].isturn = true;

                    }
                    if(match.isAddBot==true && match.players[i].playerType=='Bot'){
                        if(distributeCardArray[botPosition].botGroup==4){
                             // NEW BOT RESERVE CARD 
                            var botWinReserverCardRandNo = [3,6,10];
                            var reserverRandNum=botWinReserverCardRandNo[Math.floor(Math.random()*botWinReserverCardRandNo.length)];
                            reserverRandNum =3;
                            var winBCard =  distributeCardArray[botPosition].botCArray; 
                            var winBCard2  = catArray.splice(0, reserverRandNum);
                            var lno= 13 -reserverRandNum;
                            var carwinBCard3 =winBCard.splice(lno,13);
                            match.players[i].reserverBotWrongCards =winBCard.concat(winBCard2);
                            match.players[i].reserverRandNum =reserverRandNum;
                            distributeCardArray[botPosition].botCArray = distributeCardArray[botPosition].botCArray.concat(carwinBCard3);
                            // NEW BOT RESERVE CARD END
                            match.players[i].isWinnerBot =true;
                            match.players[i].botTurnCount = botTurnCount;
                        } 
                        
                        match.players[i].botPoints = distributeCardArray[botPosition].points;
                        var splice = distributeCardArray[botPosition].botCArray; 
                        botPosition = botPosition+1;
                    }else{
                        var splice = catArray.splice(0, 13); 
                    }
                    if(splice.length!=13){
                        var spiceNo = 13-splice.length;
                        var extraSpice = catArray.splice(0, spiceNo); 
                        splice = splice.concat(extraSpice);
                    }
                     if(match.players[i].isGameBlock==true){
                        catArray= catArray.concat(splice);
                        var splice=[];
                    }
                    match.players[i].cards =splice;

                    if(match.game.valueType=='Point'){
                        var usrAmt = Number(parseFloat(match.matchValue))*Number(parseFloat(match.maxPointLimit));
                        match.pointDeductArray[match.players[i].userId] = parseFloat(usrAmt);
                        if(match.players[i].playerType=='Real'){ 
                            match.players[i].coins = Number(parseFloat(match.players[i].coins)) -Number(parseFloat(usrAmt));
                            var udata = {
                                table:'pla24by7tbs_web.user_details',
                                fields:"coins,user_id",
                                condition:"user_id='"+match.players[i].userId+"'"
                            };
                            common_model.GetData(udata,function(respon){
                                var lcoin = Number(parseFloat(respon.data[0].coins))- Number(parseFloat(usrAmt));
                                var updateUserCoinData = {
                                    table:'pla24by7tbs_web.user_details',
                                    setdata:"coins="+lcoin,
                                    condition:"user_id="+respon.data[0].user_id
                                };
                                common_model.saveData(updateUserCoinData,function(response){  
                                });
                                var updateUserCoinData = {
                                    table:'roulettnew.tbl_users',
                                    setdata:"coins="+lcoin,
                                    condition:"user_id="+respon.data[0].user_id
                                };
                                common_model.saveData(updateUserCoinData,function(response){  
                                });
                            });

                        }
                        // coins update
                        match.winningAmount += Number(parseFloat(usrAmt));


                        //coins update end
                    }
                    match.players[i].isStart =true;
                    match.players[i].isFirstTurn =false;
                    match.players[i].totalTurn =0;
                    
                    match.players[i].tempScoreSave =false;
                    match.players[i].isWinner = false;
                    match.players[i].isPoinCoinDeduct = false;
                    if(match.isAddBot==true && match.players[i].playerType=='Bot'){                  
                        io.in(match.tableId).emit("getBotPoints",match.players[i]);
                    }
                    io.to(match.players[i].socketId).emit("updateCards",match.players[i].cards);
                }
            }
            match.isShowCards = false;
            match.jocker = response.jocker;

             if(match.matchPlayers==6){
                common_model.getSingleCat(match.matchPlayers,function(thirdCat){
                    var dataPass= {
                        thirdCat:thirdCat,
                        resultsLength:response.resultsLength,
                        jocker:response.jocker,
                    }
                    common_model.shuffleSingleCards(dataPass,function(singlesufData){
                        catArray =catArray.concat(singlesufData.thirdCatArray);
                        catArray = shuffle(catArray);
                        match.remainingCards.leftCards = catArray;
                        match.leftCards = catArray;
                    });
                  
                });
            }else{
                match.remainingCards.leftCards = catArray;
                match.leftCards = catArray;
            }
            // match.remainingCards.leftCards = catArray;
            // match.leftCards = catArray;
            
            match.turnAndCard.openCard = response.openCard;
            match.turnAndCard.nextcard = response.nextcard; 

            match.turnAndCard.currentTurnIndex = rannum;

            match.isGameStart = true;
            io.in(match.tableId).emit("playerObject",match.players);
            io.in(match.tableId).emit("jocker",match.jocker);
            io.in(match.tableId).emit("remainingCardsAndTurn",{turnAndCard:match.turnAndCard});
            //getAdminCommiton();
        });
    });
}
/* * MVC * */
    var auth = require('./auth');
    var room = require('./controller/room');
/* * MVC * */

app.get('/',function(req,res){
    
    res.send("respossadassadnse");
});

// commmon Get Room Details api for all game
 app.post('/getRoomDetails',function(req,res){
   // var token = req.headers['x-access-token'];
    // auth.checkToken(token,function(response){
    //     if(response.auth === true){
            var reqData = req.body; 
            room.getRoomDetails(reqData,function(response){
                res.send(response);
            }); 
    //     }else{
    //         res.send(response);
    //     }
    // });
}); 
app.post('/getBotCardsArray',function(req,res){
    var reqData = req.body; 
    var cardsArray = botCards.cards3(reqData.noOfPlayer);
    res.send(cardsArray);
}); 