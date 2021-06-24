var common_model = {};
var database = require('../database/database.js');
const manualQuery =(sql)=>{
    return new Promise((resolve,reject)=>{
        database.pool.getConnection(function(err,connection){
            if (err) {
                reject({success:0,message:"Parameter Problem"});
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
                resolve(callback);
                connection.destroy();
            });
            connection.on('error', function(err) {      
                reject({success:0,message:"Parameter Problem"});
            });
       });
    });

}
const procedure =(sql)=>{
   return new Promise((resolve,reject)=>{
      database.pool.getConnection(function(err,connection){
          if(err){
              reject({success:0,message:"Parameter Problem"})
          }
          connection.query(sql,function(err,result){
              connection.release();
              if(!err){
                  resolve(result[0][0]);
              } else {
                  reject({success:0,"code" : 222, "status" : "Error in database connection"});
              }            
              connection.destroy();
          });
          connection.on('error', function(err) {      
              reject({success:0,"code" : 100, "status" : "Error in database connection"});
          });
      });
   });
}


module.exports = {manualQuery,procedure} ;