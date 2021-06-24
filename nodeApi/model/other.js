var other={};
var database = require('../database/database.js');
require('dotenv').config();
var common_model = require('../model/common_model.js');
var crypto = require('crypto');

other.topPlayersRecord = function(reqData,cb){
	let  gettopPlayerLimit ={
		'table':"mst_settings",
		'fields':"id,topPlayerLimit",
		'condition':"",
	}
	common_model.GetData(gettopPlayerLimit,function(response){
		if (response.success===1) {
			let topplayerlimit = response.data[0].topPlayerLimit;
			var sql ="select * from user_details where playerType='Real' and totalScore!=0 order by totalScore  desc limit "+topplayerlimit+"";
			common_model.sqlQuery(sql,function(response){
				if(response.success===1) {
					let topPlayersObject = [];
					response.data.forEach(function(data){
	    			let result = {
	    				 userId:data.id,
	    				 userName:data.user_name,
	    				 playerProgress:data.playerProgress,
	    				 availableBalance:data.balance,
						 totalScore:data.totalScore,
	    			}
	    			topPlayersObject.push(result);
	    		});
					cb({status:true,success:"1",message:"Success",result:topPlayersObject,errorList: []}); 
				}else{
					cb({status:false,success:"2",message:"No Record Found"}); 
				}
			});
		}else{
			cb(response);
		}
		
	});
}

// var sql ="select adminPercent from mst_settings where id!=0";
// 	common_model.sqlQuery(sql,function(response){
// 		console.log(response)
// 	});
/*------------------- For get AdminPercent version -------------------------*/

other.getadminPercent =function (reqData,cb) {
	let  getVersion ={
		'table':"mst_settings",
		'fields':"adminPercent",
		'condition':""
	}
	var sql ="select adminPercent from mst_settings where id!=0";
	common_model.sqlQuery(sql,function(response){
		if(response.success==1) {
			cb({status:true,message:"Success",result:response.data}); 
		}else{
			cb(response); 
		}
	});
} 

other.getSettings =function (reqData,cb) {	
	var sql ="select * from mst_settings where id!=0";
	common_model.sqlQuery(sql,function(response){
		if(response.success==1) {
			console.log(response);
			cb({status:true,message:"Success",result:response.data}); 
		}else{
			cb(response); 
		}
	});
} 


/*------------------- Game History -------------------------*/
other.getGameHistory =function (reqData,cb) {
	if(reqData.userId!=''){
		let getUsers={
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"'",
		}
		common_model.GetData(getUsers,function(response){
			if(response.success==1){
					var sql ="SELECT cdh.*,u.id, u.user_id, u.user_name, u.email_id, u.mobile, u.playerType FROM coins_deduct_history cdh LEFT JOIN user_details u ON u.id=cdh.userId  WHERE cdh.userId='"+reqData.userId+"' ORDER BY cdh.coinsDeductHistoryId DESC";
					common_model.sqlQuery(sql,function(response){
						if(response.success===1){
							let gameObject = [];
								response.data.forEach(function(data){
									if(data.playerType=='Real' && data.isWin=='Win'){
										  var coins= data.coins + data.adminAmount;
									    }else{
									      var coins= data.coins;
									    }
									let result = {
										userId:data.userId,
										tableId:data.tableId,
										gameType:data.gameType,
										betValue:data.betValue,
										winOrLossAmount:data.coins,
										isWin:data.isWin,
										adminCommition:data.adminCommition,
										adminAmount:data.adminAmount,
										dateAndTime:data.created,
									}
								gameObject.push(result);
							});
								cb({status:true,success:"1",message:"Success",result:gameObject}); 
						}else{
							cb(response);
						}
					});
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",message:"Failed",message:"Please enter user id."}); 
	}
} 



/*------------------- My Referral Record -------------------------*/
other.myReferrRecord =function (reqData,cb) {
	if(reqData.userId !=''){
			let getUser = {
				'table':"user_details",
				'fields':"",
				'condition':"id='"+reqData.userId+"'",
			}
		common_model.GetData(getUser,function(response){
			if(response.success==1){
				if(reqData.type=='Register'){
					var query = "select *,count(toUserId) as matches ,sum(referalAmount) as referalAmount  where fromUserId='"+reqData.userId+"'  and referalAmountBy='Register' group by toUserId " ;
				}else if(reqData.type=='Playgame'){
					var query = "select *,count(toUserId) as matches ,sum(referalAmount) as referalAmount   where fromUserId='"+reqData.userId+"' and referalAmountBy='Playgame' group by toUserId";
				}else{
					//var query = "select rl.*,(select sum(referalAmount) from referal_user_logs rl1 where rl1.toUserId=rl.toUserId) referalAmount,(select count(toUserId) from referal_user_logs rl12 where rl12.toUserId=rl.toUserId) matches from referal_user_logs rl where rl.fromUserId='"+reqData.userId+"'  group by toUserId";

					var query= "select rl.*,if((select sum(referalAmount) from referal_user_logs rl1 where rl1.toUserId=rl.toUserId and rl1.referalAmountBy='Playgame'),(select sum(referalAmount) from referal_user_logs rl1 where rl1.toUserId=rl.toUserId and rl1.referalAmountBy='Playgame'),0) referalAmountPlayGame,(select count(toUserId) from referal_user_logs rl12 where rl12.toUserId=rl.toUserId and rl12.referalAmountBy='Playgame') matches,(select sum(referalAmount) from referal_user_logs rl12 where rl12.toUserId=rl.toUserId and rl12.referalAmountBy='Register' order by rl12.referLogId desc) referalAmountRegister  from referal_user_logs rl where rl.fromUserId='"+reqData.userId+"'  group by rl.toUserId;"
					
				}
			//	console.log(query);
				var sql = query;
				common_model.sqlQuery(sql,function(res){
					if(res.success==1){
						let referrObject = [];
							res.data.forEach(function(data){
							let result = {
								referralUser:data.toUserName,
								referalAmountPlayGame:data.referalAmountPlayGame,
								referalAmountRegister:data.referalAmountRegister,
								singupAmt:data.referalAmount,
								matches:data.matches,
							}
							referrObject.push(result);
						});
						cb({status:true,success:"1",message:"Success",result:referrObject}); 
					}else{
						cb(res);
					}
				});
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",message:"Failed",message:"Please enter user id."}); 
	}
} 

/*-------------------  my Transaction History -------------------------*/
other.myTransactionHistory =function (reqData,cb) {
	if(reqData.userId !=''){
		let getUser = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"'",
		}
		common_model.GetData(getUser,function(response){
			if(response.success==1){
					var sql ="SELECT ua.*,u.id, u.user_id, u.user_name, u.email_id, u.mobile,u.playerType FROM user_account ua LEFT JOIN user_details u ON u.id=ua.user_detail_id  WHERE ua.user_detail_id='"+reqData.userId+"' and paymentType!='paytm' and paymentType!='bank' and u.id != '' ORDER BY ua.id DESC";
					common_model.sqlQuery(sql,function(response){
					if(response.success==1){
						let transactionObject = [];
							response.data.forEach(function(data){
								let result = {
									userId:data.userId,
									orderId:data.orderId,
									transactionId:data.transactionId,
									transactionType:data.type,
									mainWallet:data.mainWallet,
									transactionAmount:data.amount,
									balance:data.balance,
									transactionMode:data.paymentType,
									transactionStatus:data.status,
									transactionDate:data.created,
								}
							transactionObject.push(result);
						});
						cb({status:true,success:"1",message:"Success",result:transactionObject}); 
					}else{
						cb({status:false,success:"0",message:"Failed"}); 
					}
				});
			}else{
				cb(response); 
			}
		});
	}else{
		cb({status:false,success:"0",message:"Failed",message:"Please enter user id."}); 
	}
} 

/*-------------------  my Transaction History -------------------------*/
other.myWithdrawalHistory =function (reqData,cb) {
	if(reqData.userId !=''){
		let getUser = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"'",
		}
		common_model.GetData(getUser,function(response){
			if(response.success==1){
				//	var sql ="SELECT ua.*,u.id, u.user_id, u.user_name, u.email_id, u.mobile,u.playerType FROM user_account ua LEFT JOIN user_details u ON u.id=ua.user_detail_id  WHERE ua.user_detail_id='"+reqData.userId+"' and u.id != '' and type='Withdraw' ORDER BY ua.id DESC";
					var sql ="SELECT ua.user_detail_id,amount,status,created FROM user_account ua  WHERE ua.user_detail_id='"+reqData.userId+"' and ua.type='Withdraw' ORDER BY ua.id DESC";

					common_model.sqlQuery(sql,function(response){
					if(response.success==1){
						var withdrawObject = [];
							response.data.forEach(function(data){
								let result = {
									userId:data.user_detail_id,
									amount:data.amount,
									status:data.status,
									date:data.created,
								}
							withdrawObject.push(result);

						});
						cb({status:true,success:"1",message:"Success",result:withdrawObject}); 
					}else{
						cb(response);
					}
				});
			}else{
				cb(response); 
			}
		});
	}else{
		cb({status:false,success:"0",message:"Failed",message:"Please enter user id."}); 
	}
} 


/*-------------------  Save Bonus By userID -------------------------*/
other.setBonusByUserId =function (reqData,cb) {
	if(reqData.userId !='' && reqData.bonusId!=''){
		let getUserChk = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"'",
		}
		common_model.GetData(getUserChk,function(response){
			if(response.success==1){
				let chkBonus= {
					'table':"mst_bonus",
					'fields':"",
					'condition':"bonusId='"+reqData.bonusId+"'",
				}
				common_model.GetData(chkBonus,function(result){
					if(result.success==1){
						var game = result.data[0].playGame;
						var bonus  = result.data[0].bonus;
						var bonusAmt= response.data[0].balance + bonus;
						var mainWAmt= response.data[0].mainWallet + bonus;
						let saveBonusAmt ={
					    	table:"user_details",
					        setdata:"balance='"+bonusAmt+"',mainWallet='"+mainWAmt+"'",
					        condition:"id='"+reqData.userId+"'",
					    }
					    common_model.SaveData(saveBonusAmt,function(updateRes){
					    	if(updateRes.success==1){
					    		var setData= "userId='"+reqData.userId+"',bonusId='"+reqData.bonusId+"',playGame='"+game+"',bonus='"+bonus+"',created=now()";
								let saveBonusLog ={
							    	table:"bonus_logs",
							        setdata:setData,
							        condition:'',
							    }
							    common_model.SaveData(saveBonusLog,function(saveRes){
									if(saveRes.success==1){
										cb({status:true,success:"1",message:"Success",message:"Bonus added successfully",lastId:saveRes.lastId}); 
									}else{
										cb({status:false,success:"0",message:"Failed"}); 
									}
							     	
							    });
					    	}else{
					    		cb(updateRes); 
					    	}
					    	
					    });
						
						
					}else{
						cb({status:false,success:"0",message:"Failed",message:"No Record Found"}); 
					}
				});
				
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",message:"Failed",message:"All fields are required."}); 
	}
}


/*-------------------  get Bonus By userID -------------------------*/
other.getBonusByUserId =function (reqData,cb) {
	if(reqData.userId !=''){
		let getUserChk = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"' and playerType='Real'",
		}
		common_model.GetData(getUserChk,function(response){
			if(response.success==1){
				let getBonusUserId ={
					'table':"bonus_logs",
					'fields':"",
					'condition':"userId='"+reqData.userId+"'",
				}
				common_model.GetData(getBonusUserId,function(result){
					if(result.success==1){
						let bonusObject = [];
						result.data.forEach(function(data){
								let bonusData = {
									userId:data.userId,
									bonusId:data.bonusId,
									playGame:data.playGame,
									bonus:data.bonus,
									date:data.created,
								}
							bonusObject.push(bonusData);
						});
						cb({status:true,success:"1",message:"Success",result:bonusObject}); 
					}else{
						cb({status:false,success:"0",message:"Failed",message:"No Record Found"}); 
					}
				})
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",success:"Failed",message:"All fields are required."}); 
	}
}


/*-------------------  get Bonus By userID -------------------------*/
other.getCurrentDateTime =function (reqData,cb) {
	var dateAndTime = new Date();
	cb({status:true,success:"1",result:dateAndTime}); 
}
/*-------------------  get Bonus By userID -------------------------*/
other.updateReferToBalance =function (reqData,cb) {
	if(reqData.userId !=''){
		let getUserChk = {
			'table':"user_details",
			'fields':"",
			'condition':"id='"+reqData.userId+"' and playerType='Real'",
		}
		common_model.GetData(getUserChk,function(response){
			if(response.success==1){
				var refAmt =response.data[0].balance + response.data[0].referredAmt;
				var mainWallet =response.data[0].mainWallet + response.data[0].referredAmt;
				let saveBonusAmt ={
			    	table:"user_details",
			        setdata:"balance='"+refAmt+"',referredAmt=0,mainWallet='"+mainWallet+"'",
			        condition:"id='"+reqData.userId+"'",
			    }
			    common_model.SaveData(saveBonusAmt,function(updateRes){
			    	if(updateRes.success==1)
					{
						cb({status:true,success:"1",message:"Success"}); 
					}else{
						cb(updateRes);
					}			    
				});
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",success:"Failed",message:"All fields are required."}); 
	}
}

/*------------------- For get Maintainance  -------------------------*/

other.getMaintainance =function (reqData,cb) {
	var sql ="select maintainance,maintainanceMsg from mst_settings where id!=0 limit 1";
	common_model.sqlQuery(sql,function(response){
		if(response.success===1) {
			cb({status:true,message:"Success",result:response.data}); 
		}else{
			cb(response); 
		}
	});
} 
other.addSpinWheel =function (reqData,cb) {
	if(reqData.userId !='' && reqData.coins!=''){
						var setLog = "fromUserId='"+reqData.user_id+"',referalAmount='"+reqData.coins+"',toUserId='"+reqData.userId+"',toUserName='"+reqData.userName+"',referalAmountBy='SpinWheel',created=now()";
						var referalLog = {
							'table':"referal_user_logs",
							'setdata':setLog,
							'condition':""
						}
						common_model.SaveData(referalLog,function(response2){
							if(response2.success==1){
								cb({status:true,success:"3",message:"Coins added successfully"});
							}
						});
					}else{
		cb({status:false,success:"0",message:"Fields is required"}); 
	}
} 

// other.addSpinWheel =function (reqData,cb) {
// 	if(reqData.userId !='' && reqData.coins!=''){
// 		var getUser = {
// 			'table':"user_details",
// 			'fields':"user_id,coins,user_name,balance,mainWallet",
// 			'condition':"user_id='"+reqData.userId+"'"
// 		}
// 		common_model.GetData(getUser,function(response){
// 			if(response.success==1){
// 				var userId = response.data[0].user_id;
// 				var userName = response.data[0].user_name;
// 				var coins = response.data[0].coins;
// 				var balance = response.data[0].balance;
// 				var mainWallet = response.data[0].mainWallet;

// 				var totalCoins = Number(coins) + Number(reqData.coins);
// 				var totalBal = Number(balance) + Number(reqData.coins);
// 				var totalMinWalet = Number(mainWallet) + Number(reqData.coins);
// 				var setRecord = "coins='"+totalCoins+"',balance='"+totalBal+"',mainWallet='"+totalMinWalet+"',lastSpinDate=now()";
// 				var saveRecord = {
// 					'table':"user_details",
// 					'setdata':setRecord,
// 					'condition':"user_id='"+reqData.userId+"'"
// 				}
// 				common_model.SaveData(saveRecord,function(response1){
// 					if(response1.success==1){
// 						var setLog = "fromUserId='0',referalAmount='"+reqData.coins+"',toUserId='"+userId+"',toUserName='"+userName+"',referalAmountBy='SpinWheel',created=now()";
// 						var referalLog = {
// 							'table':"referal_user_logs",
// 							'setdata':setLog,
// 							'condition':""
// 						}
// 						common_model.SaveData(referalLog,function(response2){
// 							if(response2.success==1){
// 								cb({status:true,success:"3",message:"Coins added successfully"});
// 							}
// 						});
// 					}else{
// 						cb({status:false,success:"2",message:"Coins not update"});
// 					}
// 				});
// 			}else{
// 				cb({status:false,success:"1",message:"No record found"}); 
// 			}
// 		});
// 	}else{
// 		cb({status:false,success:"0",message:"Fields is required"}); 
// 	}
// } 

other.getSpinWheel =function (reqData,cb) {
	if(reqData.userId!='' && reqData.type!=''){
		var getspin = {
		'table':"referal_user_logs",
		'fields':"",
		'condition':"toUserId='"+reqData.userId+"' and referalAmountBy='"+reqData.type+"'"
		}
		common_model.GetData(getspin,function(response){
			if(response.success==1){
				var countAll = response.data.length;
				let dataObj = [];
				response.data.forEach(function(data){
						let result = {
							toUserId:data.toUserId,
							referalAmount:data.referalAmount,
							toUserName:data.toUserName,
							referalAmountBy:data.referalAmountBy,
						}
					dataObj.push(result);
				});
				cb({status:true,success:"1",message:"Success",count:countAll,result:dataObj}); 
			}else{
				cb(response);
			}
		});
	}else{
		cb({status:false,success:"0",message:"Fields is required"});
	}
}

other.getSpinPrices =function (reqData,cb) {
	var getspin = {
	'table':"spin_rolls",
	'fields':"",
	'condition':""
	}
	common_model.GetData(getspin,function(response){
		if(response.success==1){
			var today = new Date(); 
			let dataObj = [];
			response.data.forEach(function(data){
					let result = {
						id:data.id,
						title:data.title,
						value:data.value,
						status:data.status,
						created:data.created,
						currentDate:today,
					}
				dataObj.push(result);
			});
			cb({status:true,success:"1",message:"Success",result:dataObj}); 
		}else{
			cb(response);
		}
	});
}

other.getCoupons =function (reqData,cb) {
	if(reqData.couponCode!='' && reqData.userId!=''){
		var getCoupon = {
			'table':"coupon_codes",
			'fields':"",
			'condition':"couponCode='"+reqData.couponCode+"' and isUsed='No'"
		}
		common_model.GetData(getCoupon,function(response2){
			if(response2.success==1){
				var getUser = {
					'table':"user_details",
					'fields':"user_id,coins,user_name,balance,mainWallet",
					'condition':"user_id='"+reqData.userId+"'"
				}
				common_model.GetData(getUser,function(response){
					if(response.success==1){
						var userId = response.data[0].user_id;
						var userName = response.data[0].user_name;
						var coins = response.data[0].coins;
						var balance = response.data[0].balance;
						var mainWallet = response.data[0].mainWallet;

						var totalCoins = Number(coins) + Number(response2.data[0].discount);
						var totalBal = Number(balance) + Number(response2.data[0].discount);
						var totalMinWalet = Number(mainWallet) + Number(response2.data[0].discount);
						var setRecord = "coins='"+totalCoins+"',balance='"+totalBal+"',mainWallet='"+totalMinWalet+"',lastSpinDate=now()";
						var saveRecord = {
							'table':"user_details",
							'setdata':setRecord,
							'condition':"user_id='"+reqData.userId+"'"
						}
						common_model.SaveData(saveRecord,function(response1){
							if(response1.success==1){
								var setLog = "userId='"+reqData.userId+"',couponId='"+response2.data[0].id+"',couponName='"+response2.data[0].title+"',couponCode='"+response2.data[0].couponCode+"',couponAmt='"+response2.data[0].discount+"',created=now()";
								var referalLog = {
									'table':"coupon_user_log",
									'setdata':setLog,
									'condition':""
								}
								common_model.SaveData(referalLog,function(response3){
									if(response3.success==1){
										var editData = "isUsed ='Yes',modified=now()";
										var updateIt = {
											'table':"coupon_codes",
											'setdata':editData,
											'condition':"id='"+response2.data[0].id+"'"
										}
										common_model.SaveData(updateIt,function(response4){
											if(response4.success==1){
												cb({status:true,success:"3",message:"Coupon added successfully",discount:response2.data[0].discount});
											}
										});
									}
								});
							}else{
								cb({status:false,success:"2",message:"Coins not update"});
							}
						});
					}else{
						cb({status:false,success:"1",message:"No record found"}); 
					}
				});
			}else{
				cb(response2);
			}
		});
	}else{
		cb({status:false,success:"0",message:"Code is required"});
	}
}
module.exports = other;
