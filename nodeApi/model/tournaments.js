var tournaments={};
var database = require('../database/database.js');
var common_model = require('../model/common_model.js');
var dateTime = require('node-datetime');

// get all tournaments
tournaments.getTournaments =function (reqData,cb) {
	let condition ="status='Active'";
	let  gettournaments ={
		'table':"tournaments",
		'fields':"",
		'condition':condition,
	}
	common_model.GetData(gettournaments,function(response){
		if (response.success===1) {
			cb({status:true,message:"Success",result:response.data,errorList: []}); 
		}else{
			cb(response);
		}
	});
};

// get bonus 
tournaments.getBonus =function (reqData,cb) {
	let condition ="status='Active'";
	let  getbonus ={
		'table':"mst_bonus",
		'fields':"",
		'condition':condition
	}
	common_model.GetData(getbonus,function(response){
		if(response.success===1) {
			cb({status:true,message:"Success",result:response.data,errorList: []}); 
		}else{
			cb(response); 
		}
	});
}
//get all tournaments rooms
tournaments.getRoomDetails =function (reqData,cb) {
	let condition ="status='Active'";
	let  getRooms ={
		'table':"ludo_mst_rooms",
		'fields':"",
		'condition':condition
	}
	common_model.GetData(getRooms,function(response){
	
		if(response.success===1) {
			let roomObject = [];
			response.data.forEach(function(data){
    			let result = {
    				roomId:data.roomId,
        			roomTitle:data.roomTitle,
        			entryFee:data.entryFee,
        			commision:data.commision,  
        			isPrivate:data.isPrivate,                  		
        			players:data.players,                  		
        			mode:data.mode,                  		
    			}
    			roomObject.push(result);
    		});
			cb({status:true,message:"Success",result:roomObject,errorList: []}); 
		}else{
			cb(response); 
		}
	});
} 
// get all tournaments rooms
// tournaments.getRoomDetails =function (reqData,cb) {
// 	let condition ="status='Active'";
// 	let  getRooms ={
// 		'table':"ludo_mst_rooms",
// 		'fields':"",
// 		'condition':condition
// 	}
// 	common_model.GetData(getRooms,function(response){
	
// 		if(response.success===1) {
// 			var d = new Date();
// 			dt = dateTime.create(d).format('Y-m-d');
// 			t = dateTime.create(d).format('H:M:S');
// 			isPlay = false;

// 			let condition ="dayIndex='"+d.getDay()+"'";
// 			let getTimings ={
// 				'table':"daywisetimings",
// 				'fields':"",
// 				'condition':condition
// 			}
// 			common_model.GetData(getTimings,function(timeresponse){
// 				if(timeresponse.success===1) {
// 					var fromTime1 = timeresponse.data[0].fromTime1;
// 					var toTime1 = timeresponse.data[0].toTime1;
// 					var fromTime2 = timeresponse.data[0].fromTime2;
// 					var toTime2 = timeresponse.data[0].toTime2;

// 					var beforeTime1 = Date.parse(dt+' '+fromTime1),
// 					afterTime1 = Date.parse(dt+' '+toTime1),
// 					beforeTime2 = Date.parse(dt+' '+fromTime2),
// 					afterTime2 = Date.parse(dateTime.create(d.setDate(d.getDate() + 1)).format('Y-m-d')+' '+toTime2),
// 					nowTime = Date.parse(dt+' '+t);

// 					if(d.getDay() >= 1 && d.getDay() <= 5){
// 						if((fromTime1!='00:00:00' && nowTime > beforeTime1 && nowTime < afterTime1) || (fromTime2!='00:00:00' && nowTime > beforeTime2 && nowTime < afterTime2)){
// 							isPlay = true;
// 						}
// 					} else if(d.getDay() == 0 || d.getDay() == 6){
// 						if(fromTime1!='00:00:00' && nowTime > beforeTime1 && nowTime < afterTime1) {
// 							isPlay = true;
// 						} else if(fromTime2!='00:00:00' && nowTime > beforeTime2 && nowTime < afterTime2){
// 							isPlay = true;
// 						}
// 					}

// 					let roomObject = [];
// 					response.data.forEach(function(data){
// 						let result = {
// 							roomId:data.roomId,
// 							roomTitle:data.roomTitle,
// 							entryFee:data.entryFee,
// 							commision:data.commision,  
// 							isPrivate:data.isPrivate,                  		
// 							players:data.players,                  		
// 							mode:data.mode,                  		
// 							isPlay:isPlay,      		
// 						}
// 						roomObject.push(result);
// 					});
// 					cb({status:true,message:"Success",result:roomObject,errorList: []}); 

// 				} else {
// 					isPlay = false;

// 					let roomObject = [];
// 					response.data.forEach(function(data){
// 						let result = {
// 							roomId:data.roomId,
// 							roomTitle:data.roomTitle,
// 							entryFee:data.entryFee,
// 							commision:data.commision,  
// 							isPrivate:data.isPrivate,                  		
// 							players:data.players,                  		
// 							mode:data.mode,                  		
// 							isPlay:isPlay,      		
// 						}
// 						roomObject.push(result);
// 					});
// 					cb({status:true,message:"Success",result:roomObject,errorList: []}); 
// 				}
// 			});
			
// 		}else{
// 			cb(response); 
// 		}
// 	});
// } 


tournaments.getdayWiseTimings = function (reqData,cb){
	var d = new Date();
	dt = dateTime.create(d).format('Y-m-d');
	isPlay = false;

	let condition ="";
	let getTimings ={
		'table':"daywisetimings",
		'fields':"",
		'condition':condition
	}
	common_model.GetData(getTimings,function(response){
		let timeObject = [];
		if(response.success===1) {

			response.data.forEach(function(data){

				var fromTime1 = data.fromTime1;
				var toTime1 = data.toTime1;
				var fromTime2 = data.fromTime2;
				var toTime2 = data.toTime2;
				
				var beforeTime1 = Date.parse(dt+' '+fromTime1);
				if(fromTime1.split(":")[0] > toTime1.split(":")[0]) {
					var afterTime1 = Date.parse(dateTime.create(d.setDate(d.getDate() + 1)).format('Y-m-d')+' '+toTime1);
				} else {
					var afterTime1 = Date.parse(dt+' '+toTime1);
				}
				var beforeTime2 = Date.parse(dt+' '+fromTime2);
				if(fromTime2.split(":")[0] > toTime2.split(":")[0]) {
					var afterTime2 = Date.parse(dateTime.create(d.setDate(d.getDate() + 1)).format('Y-m-d')+' '+toTime2);
				} else {
					var afterTime2 = Date.parse(dt+' '+toTime2);
				}

				let result = {};
				result.dayIndex = data.dayIndex;
				result.day = data.day;
				result.fromTime1 = dateTime.create(beforeTime1).format('I:S p');
				result.toTime1 = dateTime.create(afterTime1).format('I:S p');
				if(data.flag2 == 'true'){
					result.fromTime2 = dateTime.create(beforeTime2).format('I:S p');
					result.toTime2 = dateTime.create(afterTime2).format('I:S p');
				} else {
					result.fromTime2 = "";
					result.toTime2 = "";
				}
				
				timeObject.push(result);
			});
			// console.log(timeObject); return false;

			cb({status:true,message:"Success",timeObject:timeObject});
		} else {
			cb({status:true,message:"Failed",timeObject:timeObject});
		}
	});
}

tournaments.getIsPlayTime = function (reqData,cb){
	var d = new Date();
	dt = dateTime.create(d).format('Y-m-d');
	t = dateTime.create(d).format('H:M:S');
	isPlay = false;

	let condition ="dayIndex='"+d.getDay()+"'";
	let getTimings ={
		'table':"daywisetimings",
		'fields':"",
		'condition':condition
	}
	common_model.GetData(getTimings,function(timeresponse){
		isPlay = false;
		let timeObject = {};
		if(timeresponse.success===1) {
			var fromTime1 = timeresponse.data[0].fromTime1;
			var toTime1 = timeresponse.data[0].toTime1;
			var fromTime2 = timeresponse.data[0].fromTime2;
			var toTime2 = timeresponse.data[0].toTime2;

			var beforeTime1 = Date.parse(dt+' '+fromTime1);
			if(fromTime1.split(":")[0] > toTime1.split(":")[0]) {
				var afterTime1 = Date.parse(dateTime.create(d.setDate(d.getDate() + 1)).format('Y-m-d')+' '+toTime1);
			} else {
				var afterTime1 = Date.parse(dt+' '+toTime1);
			}
			var beforeTime2 = Date.parse(dt+' '+fromTime2);
			if(fromTime2.split(":")[0] > toTime2.split(":")[0]) {
				var afterTime2 = Date.parse(dateTime.create(d.setDate(d.getDate() + 1)).format('Y-m-d')+' '+toTime2);
			} else {
				var afterTime2 = Date.parse(dt+' '+toTime2);
			}
			var nowTime = Date.parse(dt+' '+t);

			if(d.getDay() >= 1 && d.getDay() <= 5){
				if(timeresponse.data[0].flag1=='true' && ((nowTime > beforeTime1 && nowTime < afterTime1) || (nowTime > beforeTime2 && nowTime < afterTime2))){
					isPlay = true;
				}
			} else if(d.getDay() == 0 || d.getDay() == 6){
				if(timeresponse.data[0].flag2=='true' && nowTime > beforeTime1 && nowTime < afterTime1) {
					isPlay = true;
				} else if(timeresponse.data[0].flag2=='true' && nowTime > beforeTime2 && nowTime < afterTime2){
					isPlay = true;
				}
			}

			/*var message = "Success";
			if(isPlay == false){
				message = "Gameplay Timings for "+timeresponse.data[0].day+" is from "+dateTime.create(beforeTime1).format('I:S p')+" to "+dateTime.create(afterTime1).format('I:S p');
				if(timeresponse.data[0].flag2 == 'true'){
					message += " and "+dateTime.create(beforeTime2).format('I:S p')+" to "+dateTime.create(afterTime2).format('I:S p')+"."					
				}
			}*/

			
			timeObject.dayIndex = timeresponse.data[0].dayIndex;
			timeObject.day = timeresponse.data[0].day;
			timeObject.fromTime1 = dateTime.create(beforeTime1).format('I:S p');
			timeObject.toTime1 = dateTime.create(afterTime1).format('I:S p');
			if(timeresponse.data[0].flag2 == 'true'){
				timeObject.fromTime2 = dateTime.create(beforeTime2).format('I:S p');
				timeObject.toTime2 = dateTime.create(afterTime2).format('I:S p');
			} else {
				timeObject.fromTime2 = "";
				timeObject.toTime2 = "";
			}

			cb({status:true,message:"Success",isPlay:isPlay,timeObject:timeObject});
		} else {
			isPlay = true;	
			cb({status:true,message:"Success",isPlay:isPlay,timeObject:timeObject});
		}
	});
}
// create private room for ludo game
tournaments.createPrivateRoom =function (reqData,cb) {
	let condition ="status='Active' and isPrivate='Yes'";
	let  getRooms ={
		'table':"ludo_mst_rooms",
		'fields':"",
		'condition':condition
	}
	common_model.GetData(getRooms,function(response){
	
		if(response.success===1) {
			cb({status:true,message:"Success"}); 
		}else{
			cb(response); 
		}
	});
} 



tournaments.updateplayerProgress =function (reqData,cb) {
	
	if(reqData.userId !==''){
		let condition ="id='"+reqData.userId+"'";
		let  getuser ={
		'table':"user_details",
		'fields':"",
		'condition':condition
		}
		common_model.GetData(getuser,function(response){
			if (response.success===1) {
				let setdata = "playerProgress='"+reqData.playerProgress+"'";
			    let condition ="id='"+reqData.userId+"'";

			    let updateplayerProgress ={
			    	table:"user_details",
			        setdata:setdata,
			        condition:condition
			    }
			   // console.log(updateplayerProgress);return false;
			    common_model.SaveData(updateplayerProgress,function(response){
			    	if (response.success === 1) 
				    {
				    	let condition ="id='"+reqData.userId+"'";
						let  getuser ={
						'table':"user_details",
						'fields':"",
						'condition':condition
						}
						common_model.GetData(getuser,function(response){
							if (response.success===1) {
								cb({status:true,success:"1",message:"Record updated Successfully",result:response.data,errorList: []}); 
							}else{
								cb(response);
							}
						});
				    }else{
				    	cb(response);
				    }

			    });
				    	
			}else{
				cb({status:false,success:"2",message:"No Record Found"}); 
			}
		});

	}else{
		cb({status:false,success:"0",message:"Plaese enter userId"}); 
	}
} 


tournaments.getplayerProgress =function (reqData,cb) {
	if(reqData.userId !==''){
		let condition ="id='"+reqData.userId+"'";
		let  getuser ={
		'table':"user_details",
		'fields':"",
		'condition':condition
		}
		common_model.GetData(getuser,function(response){
			if (response.success===1) {
				let playerProgressOjbject= {
					 userId: response.data[0].id,
					 playerProgress: response.data[0].playerProgress,
				}
				cb({status:true,success:"1",message:"Success",result:playerProgressOjbject,errorList: []}); 
			}else{
				cb({status:false,success:"2",message:"No Record Found"}); 
			}
		});
	}else{
		cb({status:false,success:"0",message:"Plaese enter userId"}); 
	}
} 

tournaments.getTransactionListByCustId =function (reqData,cb) {
		var condition ="id!=0";
		if(reqData.customerId !==''){
			condition +=" and customer_id='"+reqData.customerId+"'";
		}
		if(reqData.transactionId !==''){
			condition +=" and transaction_id='"+reqData.transactionId+"'";
		}
		
		var pageno=reqData.pageNo; 
		var no = Number(pageno)*10;
		var sql ="select * from orders where "+condition+" limit "+no+",10";
		common_model.sqlQuery(sql,function(response){
			if (response.success===1) {
				let transactionObject = [];
				response.data.forEach(function(data){
	    			let result = {
						transactionId:data.transaction_id,
						transactionDate:data.created,
						transactionAmount:data.amount,
						transactionStatus:data.isPayment,
	    			}
	    			transactionObject.push(result);
	    		});
				cb({status:true,success:"1",message:"Success",result:transactionObject,errorList: []}); 
			}else{
				cb({status:false,success:"2",message:"No Record Found"}); 
			}
		});
} 


// tournaments.saveReports = function(reqData,reqFile,cb){
		
//     if (reqData.userId!=='' && reqData.title!=''  && reqData.description!='') {
//     	let condition ="id='"+reqData.userId+"'";
// 		let  getuser ={
// 			'table':"user_details",
// 			'fields':"id",
// 			'condition':condition
// 		}
// 		common_model.GetData(getuser,function(response){
// 			if(response.success===1){
// 				if(reqFile === undefined){
//     				var screenshot = ''; 
// 		    	}else{
// 		    		var screenshot = reqFile.filename; 
// 		    	}
// 		    	let reportVal ="reportTitle='"+reqData.title+"',userId='"+reqData.userId+"',reportDescription='"+reqData.description+"',reportScreenShot='"+screenshot+"',created=now(),modified=now()"; 
// 				var saveReportData = {
// 					table:"reports",
// 					setdata:reportVal,
// 					condition:''
// 				};
// 				common_model.SaveData(saveReportData,function(response){
// 			    	if (response.success===1) {
// 			    		cb({status:true,success:"1",message:"Record save Successfully."}); 
// 			    	}else{
// 			    		cb(response); 
// 		    		}
// 				});
// 			}else{
// 				cb({status:false,success:"2",message:"No Record Found"}); 
// 			}
// 		});
    	
//     }else{
//     	cb({status:false,success:"0",message:"Please enter all values"}); 
//     }
// }

//save support
tournaments.addSupport = function(reqData,cb){
	if(reqData.userId!='' && reqData.message!=''){
		var msg=reqData.message;
		msg = msg.replace(/'/g, "\\'");
		let condition ="id='"+reqData.userId+"'";
		let  getuser ={
			'table':"user_details",
			'fields':"id",
			'condition':condition
		}
		common_model.GetData(getuser,function(response){
			if(response.success===1){
				var setData = "userId='"+reqData.userId+"',message='"+msg+"',type='User',created=now()";
				var saveSupport = {
					'table':"support_logs",
					'setdata':setData,
					'condition':""
				}
				common_model.SaveData(saveSupport,function(response){
					if(response.success===1){
						cb({status:true,success:"2",message:"Record add successfully"}); 
					}
				});
			}else{
				cb({status:false,success:"1",message:"No Record Found"}); 
			}
		});
	}else{
		cb({status:false,success:"0",message:"Please enter all values"});
	}
}

//get support
tournaments.getSupport = function(reqData,cb){
	if(reqData.userId!=''){
		var getUser = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"'"
		}
		common_model.GetData(getUser,function(response){
			if(response.success===1){
				var getSupportData = {
					'table':"support_logs",
					'fields':"",
					'condition':"userId='"+reqData.userId+"'"
				}
				common_model.GetData(getSupportData,function(response){
					if(response.success===1){
						var supportObj = [];
						response.data.forEach(function(data){
							var result = {
								userId:data.userId,
								message:data.message,
								type:data.type,
								isRead:data.isRead,
							}
							supportObj.push(result);
						});
						cb({status:true,success:"0",data:supportObj});
					}else{
						cb({status:false,success:"3",message:"No record found"});
					}
				});
			}else{
				cb({status:false,success:"2",message:"No record found"});
			}
		});
	}else{
		cb({status:false,success:"1",message:"Please enter userId"});
	}
}

module.exports= tournaments;