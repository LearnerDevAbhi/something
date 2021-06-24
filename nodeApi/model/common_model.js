var common_model = {};
const { response } = require('express');
var database = require('../database/database.js');

// create private room procedure
common_model.createPrivateRoom = function(data,cb){
    var players = data.players;
    var gameMode = data.gameMode;
    var betValue = data.betValue;
    var roomId = data.roomId;
    var isFree = data.isFree;
    var sql = "CALL createPrivateRoom('"+players+"','"+gameMode+"','"+betValue+"','"+roomId+"','"+isFree+"')";
    //console.log(sql)
    database.pool.getConnection(function(err,connection){
        if (err) {
            console.log(err)
            console.log(sql)
            console.log("err 1")
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                 console.log(err)
                 console.log(sql)
                console.log("err 2")
                cb({success:0,message:err});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {   
                console.log(err)
                console.log(sql)
                console.log("err 3")   
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
                console.log(err)
                console.log(sql)
                console.log("err 4")
             cb(err);
         }
         connection.query(sql,function(err,result){
             connection.release();
             if(!err) {
                 cb(result[0][0]);
             }else{
                console.log(err)
                console.log(sql)
                console.log("err 5")
                cb(err);
             }
            connection.destroy();
         });
         connection.on('error', function(err) {   
                console.log(err)
                console.log(sql)
                console.log("err 6")   
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
            console.log(err)
                console.log(sql)
                console.log("err 7")   
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                console.log(err)
                console.log(sql)
                console.log("err 8")   
                cb(err);
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) { 
        console.log(err)
                console.log(sql)
                console.log("err 9")        
            cb(err);
        });
    });
}
// join table procedure
common_model.joinTableFunc = function(data,cb){
    var userId = data.userId;
    var roomId = data.roomId;
    var players = data.players;
    var value = data.value;
    var color = data.color;
    var playerType = data.type;
    var isFree = data.isFree;
    var gameMode = data.gameMode;
    var sql = "CALL joinRoom('"+userId+"','"+roomId+"','"+players+"','"+value+"','"+color+"','"+playerType+"','"+gameMode+"','"+isFree+"')";
    console.log(sql)
    database.pool.getConnection(function(err,connection){
        if (err) {
             console.log(err)
                console.log(sql)
                console.log("err 10")  
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                 console.log(err)
                console.log(sql)
                console.log("err 11")  
                cb({success:0,message:"error found"});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {    
                 console.log(err)
                console.log(sql)
                console.log("err 12")    
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
             console.log(err)
                console.log(sql)
                console.log("err 13")   
            cb(err);
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                 console.log(err)
                console.log(sql)
                console.log("err 14")   
                cb(err);
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {  
         console.log(err)
                console.log(sql)
                console.log("err 15")       
            cb(err);
        });
    });
 }
/*========================== Get Data =============================*/
common_model.GetData = function (data,cb) {
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
    //console.log(sql);return false;
     database.pool.getConnection(function(err,connection){
        if(err){
             console.log(err)
                console.log(sql)
                console.log("err 16") 
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
                 console.log(err)
                console.log(sql)
                console.log("err 17") 
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
         console.log(err)
                console.log(sql)
                console.log("err 18")    
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
                console.log(err)
                console.log(sql)
                console.log("err 19")   
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
                    console.log(err)
                console.log(sql)
                console.log("err 20")   
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
            console.log(err)
                console.log(sql)
                console.log("err 21")         
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
     //   console.log(sql)
        common_model.sqlQuery(sql,function(res){
           // console.log(res)
            //console.log("DeleteData")
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
               console.log(err)
                console.log(sql)
                console.log("err 22")  
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
                 console.log(err)
                console.log(sql)
                console.log("err 23") 
                var callback ={
                    success:0,
                    status:false,
                    message:err,
                }
            }
    //console.log(callback);return false;
                cb(callback);
        });
         connection.on('error', function(err) {      
             console.log(err)
                console.log(sql)
                console.log("err 24") 
            cb({success:0,message:err});
        });
    });
}

common_model.updateRoom =function(data,cb){

    var roomId = data.roomId;    
    var sql = "CALL updateRoom('"+roomId+"')";
    database.pool.getConnection(function(err,connection){
        if (err) {
            console.log(err)
                console.log(sql)
                console.log("err 25") 
            cb({"success" : 0, "message" :err});
        }   
        connection.query(sql,function(err,result){
            connection.release();
            if(!err) {
                cb(result[0][0]);               
            } else{
                console.log(err)
                console.log(sql)
                console.log("err 26") 
                cb({success:0,message:err});
            }  
            connection.destroy();        
        });
        connection.on('error', function(err) {   
        console.log(err)
                console.log(sql)
                console.log("err 27")    
            cb({"success" : 0, "message" : err});
        });
    });
}
// sqlQuery
common_model.sqlQuery = function(sql,cb){   
    database.pool.getConnection(function(err,connection){
        if (err) {
            console.log(err)
                console.log(sql)
                console.log("err 28") 
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
                console.log(err)
                console.log(sql)
                console.log("err 29") 
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
        console.log(err)
                console.log(sql)
                console.log("err 30")    
            cb({success:0,message:err});
        });
   });
   
};
common_model.sqlQueryGetData = function(sql,cb){   
    database.pool.getConnection(function(err,connection){
        if (err) {
            console.log(err)
                console.log(sql)
                console.log("err 28") 
            cb({success:0,message:err});
        }
        connection.query(sql,function(err,result){
            connection.release();
            
            if(!err) {
                if(result.length==0){
                    var callback = {
                        success:0,
                        message:"No data found",
                        status:false, 
                        data:result
                    }
                }else{
                    var callback = {
                        success:1,
                        message:"Success",
                        status:true, 
                        data:result
                    }
                }
                
            }else{
                console.log(err)
                console.log(sql)
                console.log("err 29") 
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
        console.log(err)
                console.log(sql)
                console.log("err 30")    
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
            console.log("RESUTL",result)
            connection.release();
            if(!err){
                if(result.length){
                    cb(result[0][0]);
                }else{
                    cb(result)
                }
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

common_model.savefirebaseToken=(data,response)=>{
    database.pool.getConnection((err,connection)=>{
      if(err) throw err
      var checkuserQuery="SELECT * FROM `firebasetoken` WHERE `userId`=?"
      var insertQuery="INSERT INTO `firebasetoken`(`userId`,`token`) VALUES (?,?)"
      var updateQuery="UPDATE `firebasetoken` SET `token` = ? WHERE userId = ?"
      connection.query(checkuserQuery,[data.userId],(Err,result)=>{
          if(Err) throw Err
        console.log(result)
        if(result.length==0){
            connection.query(insertQuery,[data.userId,data.token],(err1,result1)=>{
                if(err1)throw err1
                response.send("query Inserted"+result1)
            }) 
        }else{
            connection.query(updateQuery,[data.token,data.userId],(err2,result2)=>{
                if(err2) throw err2
                response.send("query updated"+result2)
            }) 
        }

        })
    })
}
common_model.saveOtp=(userId,otp)=>{
database.pool.getConnection((err,connection)=>{
    if(err) throw err
    var myQuery="CALL saveOtp(?,?)"
    connection.query(myQuery,[otp,userId],(Err2,result)=>{
        if(Err2) throw Err2
        console.log("otp bhej diya"+otp+"Hello"+userId)
    })
})
}

common_model.toOtpVerify=(otp,userid,res)=>{
database.pool.getConnection((err,connection)=>{
    var myQuery="select `otp` from `user_details` WHERE `id`=?"
    connection.query(myQuery,[userid],(err1,result)=>{
        if(err1) throw err1
        console.log("result hu m bc"+result[0].otp)
        if(otp===result[0].otp){
            res.send("next page")
        }
        
        res.send("redirect again same page")

    })
})
}
common_model.transferAmount=(amount,userid,name,res)=>{
    database.pool.getConnection((err2,connection)=>{
        var myQuery="UPDATE `user_details` SET `mainWallet`=(`mainWallet`+?) , lastSpinDate=now() WHERE `id`=?;insert into referal_user_logs (fromUserId,toUserId,toUserName,referalAmountBy,referalAmount,created) values(?,?,?,'SpinWheel',?,now())"
        connection.query(myQuery,[amount,userid,userid,userid,name,amount],(err,result)=>{
            //console.log('update spin wheel = ',result)
        if(err) throw err
        res.send(result)
        })
    })

}
// transferAmount.transferAmount=(amount,userId)=>{
// database.pool.getConnection((err,response)=>{?
// if(err) throw err
// })
// }
module.exports = common_model;