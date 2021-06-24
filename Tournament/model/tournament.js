var tournament = {};
var common_model = require('../model/common_model.js');
var database = require('../database/database.js');


// var getData = {
//         table:"mst_tournaments",
//         fields:"*",
//         condition:"",
//     };
//     common_model.getData(getData,function(response){
//            console.log(response); 
//         // if(response.success==1){
//         //     cb({success:1,status:true,message:"Success",response: "Tournament successfull",getData:response.data});
//         // }else{
//         //     cb({success:0,status:false,message:"Failed",response: "Tournament getdata Failed",getData:""})
//         // }
//     }); 

// data ={} 


//  getTournament
tournament.getTournaments = function(reqData,cb){	

	var getData = {
		table:"mst_tournaments",
        fields:"*",
        condition:"status!='Inactive'",
	};
  var sql ="select * from mst_tournaments where status!='Inactive' order by tournamentId desc;"
  common_model.sqlQuery(sql,function(response){
    if (response.success==1) {
      if(response.data.length!=0){      
          cb({success:1,status:true,message:"Success",response: "Tournament successfull",getData:response.data});
      }else{
          cb({success:0,status:false,message:"Tournament not available.",response: "Tournament not available.",getData:""})
      }
    }else{
      cb({success:0,status:false,message:"Tournament not available.",response: "Tournament not available.",getData:""})
    }
  });
	// common_model.getData(getData,function(response){
 //           // console.log(response); 
	// 	if(response.success==1){
	// 		cb({success:1,status:true,message:"Success",response: "Tournament successfull",getData:response.data});
	// 	}else{
	// 		cb({success:0,status:false,message:"Tournament not available.",response: "Tournament not available.",getData:""})
	// 	}
	// });	
};


// data ={userId:123} //  getTournamentListByUserId
tournament.getTournamentListByUserId = function(reqData,cb){
    if(reqData.userId!='')
    {
       var condition = "tr.userId='"+reqData.userId+"' and (t.status='Active' or t.status='Next')";       
       var sql = "select tr.* from tournament_registrations tr left join mst_tournaments t on t.tournamentId=tr.tournamentId  where "+condition+" order by tr.tournamentRegtrationId desc";
        common_model.sqlQuery(sql,function(response){
            if (response.success==1) {
                if(response.data!=''){      
                    cb({status:true,success:1,message:"Success",result:response.data,count:response.data.length});
                }else{
                    cb({status:false,success:0,message:"Failed",response:"No record found"});
                }
            }else{
                cb({status:false,success:0,message:response.message,response:"No record found"});
            }
        });

    }else{
        cb({success:0,status:false,message:"Failed",response: "All fields are require"});
    }
}
// 4391
// var sql = "CALL tournamentRegistration('4391','5')";
// common_model.sqlProcedure(sql,function(response){
//    console.log(response); 
// });
// data ={userId:123,:tournamentId:1} //  getTournamentListByUserId
tournament.tournamentRegistration = function(reqData,cb){
    if(reqData.userId != '' && reqData.tournamentId != ''){
        var userId = reqData.userId;
        var tournamentId = reqData.tournamentId;
        var sql = "CALL tournamentRegistration('"+userId+"','"+tournamentId+"')";
        common_model.sqlProcedure(sql,function(response){
            cb(response);
        });
    }else{
         cb({success:1,message:"All fields are required."});
    }   
 };
// var sql = "CALL tournamentRegistration('4391','3')";
// common_model.sqlProcedure(sql,function(response){
//     console.log(response);
// })
// data ={userId:123,:tournamentId:1} //  tournamentUnRegistration
 tournament.tournamentUnRegistration = function(reqData,cb){
    if(reqData.userId != '' && reqData.tournamentId != ''){
        var userId = reqData.userId;
        var tournamentId = reqData.tournamentId;
        var sql = "CALL tournamentUnRegistration('"+userId+"','"+tournamentId+"')";
        common_model.sqlProcedure(sql,function(response){
            cb(response);
        });
    }else{
         cb({success:1,message:"All fields are required."});
    }  
 }
tournament.joinTournament = function(reqData,cb){
    if(reqData.userId!='' && reqData.tournamentId != ''   && reqData.color != ''){
         // console.log("Yes")
        var userId = reqData.userId;
        var tournamentId = reqData.tournamentId;
        var currentRound = reqData.currentRound;
        var tokenColor = reqData.color;
        var sql = "CALL joinTournament('"+userId+"','"+tournamentId+"','"+currentRound+"','"+tokenColor+"')";
        console.log(sql);
        common_model.sqlProcedure(sql,function(response){
            cb(response);
        });
        //console.log(sql);
     }else{
         cb({success:4,message:"All fields are required."});
     }
};
// data ={tournamentId:1,limit:10} //  getTournamentUsers
 tournament.getTournamentUsers = function(reqData,cb){
 	if(reqData.tournamentId!='')
 	{
	    var condition = "tournamentId='"+reqData.tournamentId+"' and status!='Inactive'";
	    if(reqData.limit!='' || reqData.limit!=undefined){
	    	var  limit =    reqData.limit;
	    }else{
	    	var  limit = 0;
	    }
		var sql = "select * from tournament_registrations where "+condition+" order by tournamentRegtrationId desc limit "+Number(limit)+",20";
		common_model.sqlQuery(sql,function(response){
			if (response.success===1) {
				if(response.data!=''){		
					cb({status:true,success:1,message:"Success",result:response.data,count:response.data.length});
				}else{
					cb({status:false,success:0,message:"Failed",response:"No record found"});
				}
			}else{
				cb({status:false,success:0,message:response.message,response:"No record found"});
			}
		});

 	}else{
 		cb({success:0,status:false,message:"Failed",response: "All fields are require"});
 	}
 }

//getWinLossTourHistory
tournament.getWinLossTourHistory = function(reqData,cb){ 
  if(reqData.tournamentId!=''){
    var getData = {
      table:"tournament_win_loss_logs",
      fields:"*",
      condition:"tournamentId='"+reqData.tournamentId+"' and roundStatus='Win'",
    };
    common_model.getData(getData,function(response){
      if(response.success==1){
        var recordObj = [];
        response.data.forEach(function(data){
          var result = {
            tournamentWinLossLogId:data.tournamentWinLossLogId,
            tournamentId:data.tournamentId,
            tournamentTitle:data.tournamentTitle,
            userId:data.userId,
            startDate:data.startDate,
            startTime:data.startTime,
            userName:data.userName,
            entryFee:data.entryFee,
            round:data.round,
            roundStatus:data.roundStatus,
            playerLimitInRoom:data.playerLimitInRoom,
            created:data.created,
          }
          recordObj.push(result);
        });
        cb({success:1,status:true,message:"Success",response:recordObj});
      }else{
        cb({success:0,status:false,message:"Failed",response:"No record found"});
      }
    });
  }else{
    cb({success:0,status:false,message:"Failed",response:"tournamentId is required"});
  }
}

// tournament.getWinLossTourHistory = function(reqData,cb){ 
//   if(reqData.tournamentId!=''){
//     var condition = "tournamentId='"+reqData.tournamentId+"'";
//     var sql = "select twl.*,t.currentRound from tournament_win_loss_logs twl left join mst_tournaments t on t.tournamentId=twl.tournamentId where "+condition;
//     common_model.sqlQuery(sql,function(response){
//       if(response.success==1){
//         var roundResult = [];
//         for(i=0;i<response.data[0].currentRound;i++){
//           var con = "tournamentId='"+reqData.tournamentId+"' and round='"+i+"'";
//           var sql1 = "select * from tournament_win_loss_logs where "+con;
//             common_model.sqlQuery(sql1,function(response1){
//               if(response1.success==1){
//                 response.data.forEach(function(data){
//                   var output = {
//                     round:data.round,
//                     userId:data.userId,
//                     startDate:data.startDate,
//                     startTime:data.startTime,
//                     userName:data.userName,
//                     entryFee:data.entryFee,
//                     roundStatus:data.roundStatus,
//                     playerLimitInRoom:data.playerLimitInRoom,
//                     created:data.created,
//                   }
//                   roundResult.push(output);
//                 });
//               }
//             });
//           }  
//           var result = {
//               tournamentId:response.data[0].tournamentId,
//               tournamentTitle:response.data[0].tournamentTitle,
//               round:roundResult
//           }
//           cb({success:0,status:false,message:"Failed",response:result});
//       }else{
//         cb({success:0,status:false,message:"Failed",response:"No record found"});
//       }
//     });
//   }else{
//     cb({success:0,status:false,message:"Failed",response:"tournamentId is required"});
//   }
// }

//getRegTourData
tournament.getRegTourData = function(reqData,cb){ 
  if(reqData.tournamentId!=''){
    var getData = {
      table:"tournament_registrations",
      fields:"*",
      condition:"tournamentId='"+reqData.tournamentId+"'",
    };
    common_model.getData(getData,function(response){
      if(response.success==1){
        var recordObj = [];
        response.data.forEach(function(data){
          var result = {
            tournamentRegtrationId:data.tournamentRegtrationId,
            tournamentId:data.tournamentId,
            userName:data.userName,
            userId:data.userId,
            entryFee:data.entryFee,
            isEnter:data.isEnter,
            roundStatus:data.roundStatus,
            round:data.round,
            winningPrice:data.winningPrice,
            isDelete:data.isDelete,
            isWin:data.isWin,
            isJoin:data.isJoin,
            created:data.created,
          }
          recordObj.push(result);
        });
        cb({success:0,status:false,message:"Failed",response:recordObj});
      }else{
        cb({success:0,status:false,message:"Failed",response:"No record found"});
      }
    });
  }else{
    cb({success:0,status:false,message:"Failed",response:"tournamentId is required"});
  }
}

module.exports= tournament;

