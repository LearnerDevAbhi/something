var dice={};
var database = require('../database/database.js');
var common_model = require('../model/common_model.js');
var crypto = require('crypto');

/*------------------- For purchasing api -------------------------*/
dice.purchaseDice = function(reqData,cb){
	
	if (reqData.email !='' && reqData.password !='' && reqData.LoginType !='' && reqData.deviceId !='' && reqData.amountToDeduct !='' ) {
		let condition = "email_id='"+reqData.email+"' OR socialId='"+reqData.email+"' and registrationType='"+reqData.LoginType+"'";
	    let getCredentials= {
	         table:"user_details",
	        fields:"",
	        condition:condition,
	    }
	     common_model.GetData(getCredentials,function(response){
	     	if (response.success===1) {
	     		var password = crypto.createHash('md5').update(reqData.password).digest("hex");
					if(response.data[0].password == password){
						let balance = response.data[0].balance;
						let userId = response.data[0].id;
						if(balance >= reqData.amountToDeduct && balance!='0'){
						let deductBal = balance - reqData.amountToDeduct;
						let updateBal1 = "balance='"+deductBal+"'";
						let con = "id='"+userId+"'";
							var updateBalData = {
                            table:"user_details",
                            setdata:updateBal1,
                            condition:con
                        	};

	                        common_model.SaveData(updateBalData,function(response){
								if(response.success===1){
									let getUpdateBalanceData= {
								         table:"user_details",
								        fields:"",
								        condition:con,
								    }
	     							common_model.GetData(getCredentials,function(response){
	     								if (response.success===1) {
	     									var userObject ={
				                            userId: response.data[0].id,
				                            userName:response.data[0].user_name,
				                            emailId:response.data[0].email_id,
				                            mobile:response.data[0].mobile,
				                            status:response.data[0].status,
				                            countryName:response.data[0].country_name,
				                            referalCode:response.data[0].referal_code,
				                            availableBalance:response.data[0].balance,
				                            signupDate:response.data[0].signup_date,
				                            lastLogin:response.data[0].last_login,
				                            socialId:response.data[0].socialId,
				                            kycStatus:response.data[0].kyc_status,
				                        	}
					                       	cb({status:true,success:1,message:"Success",response: "purchase dice successfully",result:userObject}); 
	     								}else{
	     									cb({status:true,success:6,message:"Success",response: "No"}); 
	     								}
	     							});
								}else{
									cb({status:true,success:5,message:"Success",response: "No record found"}); 
								}
	                        });
	                        
			                    
						}else{
							cb({status:false,success:4,message:"your amountToDeduct is greater than available balance. "});  
						}
					}else{
						cb({status:false,success:3,message:"Incorrect password."});  
					}
	     	}else{
	     		cb({status:false,success:2,message:"Incorrect email or password."});  
	     	}
	     	
	     });
	}else{
		 cb({status:false,success:0,message:"Please enter all values."});  
	}
}

/*------------------- For get items -------------------------*/

dice.getItems = function(reqData,cb){

	let  getItems ={
		'table':"items",
		'fields':"id,itemName,itemPrice,status",
		'condition':"status='Active'"
	}
	common_model.GetData(getItems,function(response){
			let diceVariantsList =response.data; 
			if(response.success===1) {
			let  getcustomDice ={
				'table':"custom_dice",
				'fields':"id,diceName,dicePrice,counter,status",
				'condition':"status='Active'"
			}
			common_model.GetData(getcustomDice,function(response){
				if(response.success===1) {
					let customDiceList =response.data;
					cb({status:true,message:"Success",diceVariants:diceVariantsList,customDice:customDiceList,}); 
				}else{
					cb(response); 
				}
			});
			
		}else{
			cb(response); 
		}
	});
}



/*------------------- For get game version -------------------------*/
dice.getGameVersion =function (reqData,cb) {
	let  getVersion ={
		'table':"mst_settings",
		'fields':"version",
		'condition':""
	}
	common_model.GetData(getVersion,function(response){
		if(response.success===1) {
			cb({status:true,message:"Success",result:response.data}); 
		}else{
			cb(response); 
		}
	});
} 

module.exports = dice;
