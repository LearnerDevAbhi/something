var common_model = {};
var database = require('../database/database.js');
require('dotenv').config();

common_model.sqlProcedure = function (sql,cb) {
    database.pool.getConnection(function(err,connection){
        if(err){
            cb({success:0,message:"Parameter Problem"})
        }
        connection.query(sql,function(err,result){
            connection.release();
            if(!err){
                cb(result[0][0]);
            } else {
                cb(err);
            }            
            connection.destroy();
        });
        connection.on('error', function(err) {      
            cb({"code" : 100, "status" : "Error in database connection"});
        });
    });
};

// create private room procedure
common_model.createPrivateRoom = function(data,cb){
    var players = data.players;
    var gameMode = data.gameMode;
    var betValue = data.betValue;
    var roomId = data.roomId;
    var isFree = data.isFree;
    var sql = "CALL createPrivateRoom('"+players+"','"+gameMode+"','"+betValue+"','"+roomId+"','"+isFree+"')";
    database.pool.getConnection(function(err,connection){
        if (err) {
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                cb({success:0,message:err});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {   
            cb({"success" : 0, "message" : "Error in connection database"});
        });
    });
}
 //save Delete query for procedure
common_model.userCoinsUpdate = function(data,cb){ 
    var userId = data.userId;
    var coins = data.coins;
    var tableId = data.tableId;
    var gameType = data.gameType;
    var betValue = data.betValue;
    var rummyPoints = data.rummyPoints;
    var isWin = data.isWin;
    var adminCommition = data.adminCommition;
    var type = data.type;
    var adminCoins = data.adminCoins;
   // var referredBy = data.referredBy;
    var sql = "CALL userCoinsUpdate('"+userId+"','"+coins+"','"+tableId+"','"+gameType+"','"+betValue+"','"+rummyPoints+"','"+isWin+"','"+adminCommition+"','"+type+"','"+adminCoins+"')";  
    database.pool.getConnection(function(err,connection){
         if (err) {
             cb(err);
         }
         connection.query(sql,function(err,result){
             connection.release();
             if(!err) {
                 cb(result[0][0]);
             }else{
                cb(err);
             }
            connection.destroy();
         });
         connection.on('error', function(err) {   
             cb(err);
         });
    });
}
// join private room
common_model.joinPrivateRoom = function(data,cb){
    var userId = data.userId;
    var roomId = data.roomId;
    var players = data.players;
    var value = data.value;
    var color = data.color;
    var type = data.type;
    var tableId = data.tableId;
    var gameMode = data.gameMode;
    var isFree = data.isFree;
    var sql = "CALL joinPrivateRoom('"+userId+"','"+roomId+"','"+players+"','"+value+"','"+color+"','"+type+"','"+gameMode+"','"+tableId+"','"+isFree+"')";
    database.pool.getConnection(function(err,connection){
        if (err) {
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                cb(err);
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) { 
            cb(err);
        });
    });
};
// join table procedure
common_model.joinRoomTable = function(data,cb){
    var userId = data.userId;
    var roomId = data.roomId;
    var players = data.players;
    var value = data.value;
    var color = data.color;
    var playerType = data.type;
    var isFree = data.isFree;
    var gameMode = data.gameMode;
    var joingame = process.env.JOINGAME;
    var sql = "CALL joinRoom('"+userId+"','"+roomId+"','"+players+"','"+value+"','"+color+"','"+playerType+"','"+gameMode+"','"+isFree+"')";

    database.pool.getConnection(function(err,connection){
        if (err) {
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                cb({success:0,message:"error found"});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {    
            cb(err);
        });
    });
 }

// join table procedure
common_model.joinBotsRoomTable = function(data,cb){
    var userId = data.userId;
    var roomId = data.roomId;
    var players = data.players;
    var value = data.value;
    var playerType = data.playerType;
    var isFree = data.isFree;
    var gameMode = data.gameMode;
    var tableId = data.tableId;
    
    var sql = "CALL joinBotsRoomTable('"+userId+"','"+roomId+"','"+players+"','"+value+"','"+playerType+"','"+gameMode+"','"+isFree+"','"+tableId+"')";
    database.pool.getConnection(function(err,connection){
        if (err) {
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                cb(err);
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {  
            cb(err);
        });
    });
 }
/*========================== Get Data =============================*/
common_model.getData = function (data,cb) {
    //cb(data);return false;
    if(data.fields !=''){
        var sql ="select "+data.fields+" from "+data.table;
        message ="Get Data";
    }else{
        var sql = "select * from "+data.table;
        message  ="Get Data";
    }
    if(data.condition !=''){
        var sql = sql+" where "+data.condition;
    }
     database.pool.getConnection(function(err,connection){
        if(err){
            cb({success:0,message:err})
        }
        connection.query(sql,function(err,result){
            connection.release();
            if(!err){
                if(result.length){
                        var callback={
                            success:1,
                            status:true,
                            message:message,
                            data:result,
                        }
                }else{
                    var callback={
                        success:0,
                        status:false,
                        message:"Record Not Found",
                        data:null,
                    }
                }
            }else{
                var callback={
                        success:0,
                        status:false,
                        message:err,
                        data:null,
                    }
            }
            cb(callback);
            connection.destroy();
        });
        connection.on('error', function(err) {   
            cb({"code" : 100, "status" : "Error in database connection","message":err,});
        });
    });
}


/*======================== Save Data ===============================*/
common_model.SaveData =function (data,cb){
    if(data.condition !=''){
            var sql ="UPDATE "+data.table+" SET "+data.setdata+" WHERE "+data.condition;
            var message = "Updated";
    }else{
        var sql ="INSERT INTO "+data.table+" SET "+data.setdata;
        var message = "Inserted";
    }
     database.pool.getConnection(function (err,connection){
            if(err){
                cb({success:0,message:err});
            }
            connection.query(sql,function(err,result){
                connection.release();
                if(!err){
                    var callback ={
                        success:1,
                        message:message,
                        status:true, 
                        lastId:result.insertId,
                    }
                }else{
                 var callback ={
                        success:0,
                        message:err,
                        status:true, 
                        lastId:"",
                    }
                }
                    cb(callback);
                    connection.destroy();
            });
            connection.on('error', function(err) {
            cb({success:0,message:err});
        });
    });
}
// if disconnect player then update and delete from tables 
common_model.dbUpdates= function(data){    
    var tableId = data.tableId;
    var userId = data.userId;
    var isGameStart = data.isGameStart;
    var playerlength = data.playerlength;
    var saveDataPass ={
        condition:'joinRoomId="'+tableId+'"',
        setdata:'activePlayer="'+playerlength+'"',
        table:'ludo_join_rooms',
    }
    common_model.SaveData(saveDataPass,function(get){});
    if(isGameStart){
        var updateuserTable ={
            condition:'joinRoomId="'+tableId+'" and userId="'+userId+'"',
            setdata:"status='Disconnect'",
            table:'ludo_join_room_users',
        }
        common_model.SaveData(updateuserTable,function(data){})
    }else{
        if(playerlength===0){
           var condition='joinRoomId="'+tableId+'"';
        }else{
           var condition ='joinRoomId="'+tableId+'" and userId="'+userId+'"';
        }
         var sql ="DELETE FROM ludo_join_room_users WHERE "+condition;
        common_model.sqlQuery(sql,function(res){
        });
        // deleteRummyTableUser={
        //     con:condition,
        //     table:'ludo_join_room_users',
        // };
        // common_model.DeleteData(deleteRummyTableUser,function(data){});
    }
}

/*======================== Save Data ===============================*/
common_model.DeleteData =function(data,cb){
    if(data.condition !=''){
        var condition ="WHERE "+ data.condition;
    }else{
        var condition ="";
    }

    var sql = "DELETE FROM "+data.table+" "+condition+" ";
     database.pool.getConnection(function(err,connection){
        if(err){
            cb({success:0,message:err});
        }
        connection.query(sql,function(err,result){
            connection.release();
            if(!err){
                var callback ={
                    success:1,
                    status:true,
                    message:"Delete Succesfully",
                }
            }else{
                var callback ={
                    success:0,
                    status:false,
                    message:err,
                }
            }
                cb(callback);
        });
         connection.on('error', function(err) {      
            cb({success:0,message:err});
        });
    });
}

common_model.updateRoom =function(data,cb){

    var roomId = data.roomId;    
    var sql = "CALL updateRoom('"+roomId+"')";
    database.pool.getConnection(function(err,connection){
        if (err) {
            cb({"success" : 0, "message" :err});
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                cb({success:0,message:err});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {   
            cb({"success" : 0, "message" : err});
        });
    });
}
// sqlQuery
common_model.sqlQuery = function(sql,cb){   
    database.pool.getConnection(function(err,connection){
        if (err) {
            cb({success:0,message:err});
        }
        connection.query(sql,function(err,result){
            connection.release();
            
            if(!err) {
                var callback = {
                    success:1,
                    message:"Success",
                    status:true, 
                    data:result
                }
            }else{
                var callback = {
                    success:0,
                    message:err,
                    status:false, 
                    data:""
                }
            }
            cb(callback);
            connection.destroy();
        });
        connection.on('error', function(err) {   
            cb({success:0,message:err});
        });
   });
   
};

common_model.callProcedureCommon = function (sql,cb) {
    database.pool.getConnection(function(err,connection){
        if(err){
            cb({success:0,message:"Parameter Problem"})
        }
        connection.query(sql,function(err,result){
            connection.release();
            if(!err){
                cb(result[0][0]);
            } else {
                cb(err);
            }
            
            connection.destroy();
        });
        connection.on('error', function(err) {      
            cb({"code" : 100, "status" : "Error in database connection"});
        });
    });
};
module.exports = common_model;