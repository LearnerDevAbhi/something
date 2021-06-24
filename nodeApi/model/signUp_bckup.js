var signUp ={};
var database = require('../database/database.js');
var common_model = require('../model/common_model.js');
const request = require('request');
var crypto = require('crypto');
var nodemailer = require('nodemailer');

var fromEmail="ludo.power2019@gmail.com";
var transporter = nodemailer.createTransport({
	service: 'gmail',
	auth: {
	  user: fromEmail,
	  pass: 'vtabwzhcpgmbxdoc'
	}
});

// /* == Send Mail Common Function == */
// var sendMailFunction = function(reqData,cb){
//     var mailOptions = {
//         from: '"Ludo Power" <ludo.power2019@gmail.com>',
//         to: reqData.email,
//         subject: reqData.subject,
//         html: reqData.replacedMailBody
//     };
//     transporter.sendMail(mailOptions, function(error, info){
//         //console.log(info);return false;
//         if (error) {
//             console.log(error);
//         } else {
//             console.log('Email sent: ' + info.response);
//         }
//     });       
// }


/*--------------------------  Registration Api ------------------------*/
//check user register or not
signUp.registration = function (reqData,cb) {

	if(reqData.mobile !=''){
	let lastId=0;
	let dupMobile ={
		'table':"user_details",
		'fields':"id,email_id,socialId,mobile,otp_verify",
		'condition':"mobile='"+reqData.mobile+"'",
	}
	common_model.GetData(dupMobile,function(response){
		if (response.success != 1) {
			let dupEmail ={
				'table':"user_details",
				'fields':"id,email_id",
				'condition':"email_id='"+reqData.email+"' and email_id!=''",
			}
			common_model.GetData(dupEmail,function(response){
				if(response.success !== 1 ) {
					let dupUserName= {
						'table':"user_details",
						'fields':"id,user_name",
						'condition':"user_name='"+reqData.userName+"' and user_name!=''",
					}
					common_model.GetData(dupUserName,function(response){
							if(response.success != 1 ) {
								if (reqData.socialId !='') {
									let dupSocialId ={
										'table':"user_details",
										'fields':"id,socialId,registrationType",
										'condition':"socialId ='"+reqData.socialId+"' and registrationType='"+reqData.registrationType+"'",
									}
									common_model.GetData(dupSocialId,function(response){
									  if (response.success != 1) {
										if(reqData.referalCode != '')
										{
											let refalCodeExits = {
												'table':"user_details",
												'fields':"id,referal_code,user_name,referredAmt",
												'condition':"referal_code='"+reqData.referalCode+"' and blockuser='No'",
											}
											common_model.GetData(refalCodeExits,function(response){
											   //console.log(response);return false;
												if (response.success===1) {
													reqData.referalCode= response.data[0].referal_code;
													reqData.referredId= response.data[0].id;
													reqData.refferdByUserName= response.data[0].user_name;
													reqData.refAmt = response.data[0].referredAmt
													saveRegData(reqData,function(response){
														// console.log(response)
														cb(response);
													});
												}else{
													cb({success:2,message:"Invalid Referal Code"});
												}
											});
										}else{
											saveRegData(reqData,function(response){
												// console.log(response)
												cb(response);
											});
										}
									  }else{
										console.log("43");
										cb({success:3,message:"Social Id Already Exits."});
									  }
										
									});
								}else  if(reqData.referalCode != ''){
									let refalCodeExits = {
										'table':"user_details",
										'fields':"id,referal_code,user_name,referredAmt",
										'condition':"referal_code='"+reqData.referalCode+"' and blockuser='No'",
									}
									common_model.GetData(refalCodeExits,function(response){
										//console.log(response);return false;
										if (response.success===1) {
											reqData.referalCode= response.data[0].referal_code;
											reqData.referredId= response.data[0].id;
											reqData.refferdByUserName= response.data[0].user_name;
											reqData.refAmt = response.data[0].referredAmt
											saveRegData(reqData,function(response){
												// console.log(response)
												cb(response);
											});
										}else{
											cb({success:2,message:"Invalid Referal Code"});
										}
										
									});
									   
								}else{
									//console.log("save");return false;
									saveRegData(reqData,function(response){
										// console.log(response)
										cb(response);
									});
								}
							}else{
								//console.log("User Name Already Exits");
								cb({success:2,message:"User Name Already Exits."});
							}
					 });
				}else{
					cb({success:2,message:"Email Already Exits."});
				}
			});

		}else{
			cb({success:2,message:"Mobile Already Exits."});
		}
	});
	}else{
		cb({success:2,message:"Please Enter Your Mobile No."});
	}
}

// var data={
//     userId:15
// }
// sendMail(data);
function sendMail(userId) {
	var url = 'http://3.20.220.191/api/index.php/Kyc/emailVarification';
	var myJSONObject = {userId:userId};
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
		   console.log(error)
		   console.log(body)
		   console.log("mail body")
	  });
}

//Save registration
var saveRegData = function(reqData,cb){
	if(reqData.name !=='') 
	{
		var refFirstDigit = reqData.name.slice(0,1);
	}
	else
	{
		var refFirstDigit = reqData.name;
	}

	let randNum = Math.floor(100000 + Math.random() * 900000);
	let password = crypto.createHash('md5').update(reqData.password).digest("hex");
	let referalCode = '';
	   
	if(reqData.referalCode !== '') {
		if(reqData.referalCode.slice(0, 1) == "R") {
			referalCode = reqData.referalCode;
		}

	}
		
	let setdata= "email_id ='"+reqData.email+"',user_id='0',profile_img='', mobile='"+reqData.mobile+"',password='"+password+"',country_name='"+reqData.country_name+"',user_name='"+reqData.userName+"',name='"+reqData.name+"',referal_code='"+referalCode+"',signup_date=now(),blockuser='No',status='Active',socialId='"+reqData.socialId+"', registrationType='"+reqData.registrationType+"',device_id='"+reqData.deviceId+"',otp='"+randNum+"',deviceName='"+reqData.deviceName+"',deviceModel='"+reqData.deviceModel+"',deviceOs='"+reqData.deviceOs+"',deviceRam='"+reqData.deviceRam+"',deviceProcessor='"+reqData.deviceProcessor+"',playerId='"+reqData.playerId+"'";
	let signUpData ={
		table:'user_details',
		setdata:setdata,
		condition:''
	}
	common_model.SaveData(signUpData,function(response){
		if(response.success===1){
			lastId =response.lastId;
			let number = lastId;
			if (lastId<=9999) 
			{
				let number = ("000"+lastId).slice(-4);
			}
			let referal_code = "R"+refFirstDigit.toUpperCase()+number;
			let setUpdateData = "referal_code='"+referal_code+"',referred_by='"+reqData.referalCode+"',referredByUserId='"+reqData.referredId+"',user_id="+lastId;
			let condition1 = "id='"+response.lastId+"'";
			let updateData = {
				table:"user_details",
				setdata:setUpdateData,
				condition:condition1
			}
			common_model.SaveData(updateData,function(response){
					if (response.success===1) {
						if(reqData.referalCode!=''){
							var getSettingData = {
								'table':"mst_settings",
								'fields':"id,referralBonus",
								'condition':"",
							}
							common_model.GetData(getSettingData,function(settingResult){
								if(settingResult.success==1){
									var refBonus = settingResult.data[0].referralBonus;
									var refamtUpdate= Number(reqData.refAmt) + Number(settingResult.data[0].referralBonus);
									var addRefAmt ={
										table:'user_details',
										setdata:"referredAmt='"+refamtUpdate+"'",
										condition:'id="'+reqData.referredId+'"'
									}
									common_model.SaveData(addRefAmt,function(refresponse){
										if(refresponse.success==1){
											var setLog = "fromUserId='"+reqData.referredId+"',toUserId='"+lastId+"',toUserName='"+reqData.userName+"',referalAmount='"+refBonus+"',tableId='0',referalAmountBy ='Register',created=now()";
											let saveLog ={
												table:"referal_user_logs",
												setdata:setLog,
												condition:''
											}
											common_model.SaveData(saveLog,function(result){
												if(result.success==1){
													let gettLastInsertedUser ={
														'table':"user_details",
														'fields':"",
														'condition':condition1,
													}
													common_model.GetData(gettLastInsertedUser,function(response){
														var user_name= response.data[0].user_name;
														if(response.success===1){
														   // sendMail(response.data[0].id);
															var userObject ={
																userId: response.data[0].id,
																name:response.data[0].name,
																userName:response.data[0].user_name,
																emailId:response.data[0].email_id,
																mobile:response.data[0].mobile,
																userProfile:response.data[0].profile_img,
																status:response.data[0].status,
																countryName:response.data[0].country_name,
																referalCode:response.data[0].referal_code,
																availableBalance:response.data[0].balance,
																signupDate:response.data[0].signup_date,
																lastLoginOn:response.data[0].last_login,
																kycStatus:response.data[0].kyc_status,
																registrationType:response.data[0].registrationType,
																socialId:response.data[0].socialId,
																deviceId:response.data[0].device_id,
																deviceName:response.data[0].deviceName,
																deviceModel:response.data[0].deviceModel,
																deviceOs:response.data[0].deviceOs,
																deviceRam:response.data[0].deviceRam,
																deviceProcessor:response.data[0].deviceProcessor,
																totalScore:response.data[0].totalScore,
																referredBy:reqData.refferdByUserName,
																referredAmt:response.data[0].referredAmt,
																referredUser:response.data[0].UserName,
																totalWin:response.data[0].totalWin,
																totalLoss:response.data[0].totalLoss,
																mainWallet:response.data[0].mainWallet,
																winWallet:response.data[0].winWallet,
																playerId:response.data[0].playerId,
															}
															var getSmsData = {
																table:"mst_sms_body",
																fields:"",
																condition:"smsType='Otp-verification'"
															}
															common_model.GetData(getSmsData,function(response){
																//  console.log(response)
																// console.log("response33")
																if (response.success===1) {
																	var sms_body = response.data[0].smsBody;
																	var mobileNo = reqData.mobile;
																	var replacedSmsBody = sms_body.replace(/{otp}/g, randNum);
																	sendSmsOpt(mobileNo,replacedSmsBody);
																	console.log(userObject)
																	cb({success:1,lastId:response.data[0].id,result:userObject,message:"OTP is sent on your mobile number, Please verify OTP"});
																}else{
																		cb(response);
																}
															});
														}else{
															cb(response)
														}
													});
												}else{
													cb(response)
												}
											});
										}else{
											cb(refresponse)
										}
									});
								}else{
									cb(settingResult)
								}
							});
						}else{
							let gettLastInsertedUser ={
								'table':"user_details",
								'fields':"",
								'condition':condition1,
							}
							 common_model.GetData(gettLastInsertedUser,function(response){
									var user_name= response.data[0].user_name;
									if(response.success===1){
									//sendMail(response.data[0].id);
									 var userObject ={
									userId: response.data[0].id,
									name:response.data[0].name,
									userName:response.data[0].user_name,
									emailId:response.data[0].email_id,
									mobile:response.data[0].mobile,
									userProfile:response.data[0].profile_img,
									status:response.data[0].status,
									countryName:response.data[0].country_name,
									referalCode:response.data[0].referal_code,
									availableBalance:response.data[0].balance,
									signupDate:response.data[0].signup_date,
									lastLoginOn:response.data[0].last_login,
									kycStatus:response.data[0].kyc_status,
									registrationType:response.data[0].registrationType,
									socialId:response.data[0].socialId,
									deviceId:response.data[0].device_id,
									deviceName:response.data[0].deviceName,
									deviceModel:response.data[0].deviceModel,
									deviceOs:response.data[0].deviceOs,
									deviceRam:response.data[0].deviceRam,
									deviceProcessor:response.data[0].deviceProcessor,
									totalScore:response.data[0].totalScore,
									totalWin:response.data[0].totalWin,
									totalLoss:response.data[0].totalLoss,
									mainWallet:response.data[0].mainWallet,
									winWallet:response.data[0].winWallet,
									playerId:response.data[0].playerId,
									}
									var getSmsData = {
										table:"mst_sms_body",
										fields:"",
										condition:"smsType='Otp-verification'"
									}
									common_model.GetData(getSmsData,function(response){
										//  console.log(response)
										// console.log("response33")
										   if (response.success===1) {
											 var sms_body = response.data[0].smsBody;
											 var mobileNo = reqData.mobile;
											 var replacedSmsBody = sms_body.replace(/{otp}/g, randNum);

											 sendSmsOpt(mobileNo,replacedSmsBody);
													cb({success:1,lastId:response.data[0].id,result:userObject,message:"OTP is sent on your mobile number, Please verify OTP"});
										  
													   }else{
														 cb(response);
													   }
												 });

											}else{
													cb(response)
										}
								});
						}
					}else{
						cb(response)
					}
			});
		}else{
			cb(response)
		} 
	});
	
}



function sendSmsOpt(mobileNo,message){
	var url = 'http://api.textlocal.in//send//?username=ludofantasy1@gmail.com&hash=b329085b4779d9c9a00c9432e0fe43bf37be7c6b2023e87768179a63a496968a&message='+urlencode(message)+'&sender=LUDOFN&numbers='+mobileNo+'&test=0';
 
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
		  
		  // cb(body);
	  });
}
/*--------------------------  Forgot Password Api ------------------------*/

//for mobile
signUp.forgotPassword = function(reqData,cb)
{
	if(reqData.mobile!=''){
	var condition  = "mobile='"+reqData.mobile+"' and blockuser='No'";
	var passData={
		table:"user_details",
		fields:"id,user_name,mobile",
		condition:condition
	}
	common_model.GetData(passData,function(response){
	if (response.success===1 ) {
		var user_name = response.data[0].user_name.replace(/\b\w/g, l => l.toUpperCase());
		var randNum = new Array(6).join().replace(/(.|$)/g, function(){return ((Math.random()*36)|0).toString(36)[Math.random()<.5?"toString":"toUpperCase"]();});
		
		var password = crypto.createHash('md5').update(randNum).digest("hex");
		var mobileNo = response.data[0].mobile;
		var setdata = "password='"+password+"'";
		var userId = response.data[0].id;
		var cond1 = "id='"+response.data[0].id+"'";
		var updateData = {
			table:"user_details",
			setdata:setdata,
			condition:cond1
		};
		 common_model.SaveData(updateData,function(response){
			if (response.success === 1){
					 var getSmsData = {
						table:"mst_sms_body",
						fields:"",
						condition:"smsType='Forgot_password'"
					}
					common_model.GetData(getSmsData,function(response){
						if (response.success === 1) {
							var sms_body = response.data[0].smsBody;
							var replacedSmsBody = sms_body.replace(/{user_name}/g, user_name).replace(/{password}/g, randNum);
							sendSmsOpt(mobileNo,replacedSmsBody);
							cb({success:1,message:"Forgot Password Successfully, Password is send on your mobile"});
						   
						}else{
						   cb(response);
						}
					});
				}else{
				   cb(response);
				}
			
		 });
	}else{
		 cb({success:2,status:false,message:"Invalid User",result:[{emailId:reqData.email}],errorList: []}); 
	}   
	});
	}else{
		 cb({success:0,status:false,message:"Please enter mobile no."});
	}
}

// sendMail(15)
/*--------------------------  Otp Verify  Api ------------------------*/
signUp.OtpVerifyFunction = function(reqData,cb){
	var condition = "mobile='"+reqData.mobile+"' and otp='"+reqData.otp+"'";
	var otpData = {
		table:"user_details",
		fields:"id",
		condition:condition
	}
	common_model.GetData(otpData,function(response){
		if (response.success===1) {
			var userId =response.data[0].id;
			var setdata = "otp_verify='Yes',is_mobileVerified='Yes',status='Active'";
			var condition = "mobile='"+reqData.mobile+"'";
			var updateData = {
				table:"user_details",
				setdata:setdata,
				condition:condition
			}
			common_model.SaveData(updateData,function(response2){
				if (response2.success===1) 
				{
					cb({success:1,message:"Otp Verified successfully, Registration Successful."});
					sendMail(userId);
				}else{
					cb({success:0});  
				}
			});
		}else{
			cb({success:0,message:"Invalid Otp"});
		}
	});
}



/*--------------------------  resend Otp Api ------------------------*/
signUp.ResendOtpFunction =  function(reqData,cb){
	if(reqData.mobile !=''){
	var condition="mobile='"+reqData.mobile+"'";
	var checkData ={
		table:"user_details",
		fields:"id,mobile,user_name",
		condition:condition
	}
	common_model.GetData(checkData,function(response){
		if(response.success === 1)
		{
			
			var user_name = response.data[0].user_name.replace(/\b\w/g, l => l.toUpperCase());
			var mobileNo = response.data[0].mobile;
			var randNum = Math.floor(Math.random() * 1000000);
			var condition = "mobile='"+reqData.mobile+"'";
			var updateData = {
				table:"user_details",
				setdata:"otp='"+randNum+"'",
				condition:condition
			}
			common_model.SaveData(updateData,function(response){
				if (response.success === 1){
					 var getSmsData = {
						table:"mst_sms_body",
						fields:"",
						condition:"smsType='Otp-verification'"
					}
					common_model.GetData(getSmsData,function(response){
						if (response.success === 1) {

							var sms_body = response.data[0].smsBody;
							var replacedSmsBody = sms_body.replace(/{user_name}/g, user_name).replace(/{otp}/g, randNum);
							sendSmsOpt(mobileNo,replacedSmsBody);
							cb({success:1,message:"OTP is sent on your mobile number, Please verify OTP"});
						   
						}else{
						   cb(response);
						}
					});
				}else{
				   cb(response);
				}
			});
			
		}else{
			cb({success:2,message:"Invalid User"});
		}
	});
	}else{
	  cb({success:0,message:"Please Enter Mobile No."});  
	}
}


function urlencode (str) { 
	str = (str + '').toString();
	return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').
	replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/%20/g, '+');
}

/*---------------------------------- Change Password ---------------------------------------*/
signUp.changePassword= function(reqData,cb){
	var condition = "id='"+reqData.userId+"'";
	var passData = {
		table:"user_details",
		fields:"id,password",
		condition:condition
	}
	common_model.GetData(passData,function(response){
	if(response.success===1)
	{
		var oldPass = response.data[0].password;
		var password = crypto.createHash('md5').update(reqData.oldPassword).digest("hex");
		var newPassword = crypto.createHash('md5').update(reqData.newPassword).digest("hex");
		if (password != oldPass) 
		{
			cb({success:2,message:"password not matched."})
		}
		else if(oldPass == newPassword)
		{
			cb({success:3,message:"Old & new password can't be same"});
		}
		else if(reqData.newPassword != reqData.confirmPassword)
		{
			cb({success:4,message:"New password and confirm password should be same"});
		}
		else
		{
			var updateUserPassData = {
					table:"user_details",
					setdata:"password='"+newPassword+"'",
					condition:condition
				} 
			common_model.SaveData(updateUserPassData,function(response){
				if(response.success === 1)
				{
					cb({success:1,message:"Password changed successfully"});
				}else{
					cb(response);
				} 
			});
		}
	}else{
		cb({success:5,message:"Invalid User."})
	}

	});
}


/*---------------------------------- Profile Update for Website---------------------------------------*/
signUp.profileUpdateFunction = function(reqData,cb){
	isEmailExist(reqData,function(response){
		if (response.success === 1)
		{
			isMobileExist(reqData,function(response){
				if (response.success === 1)
				{
					
					var getProData={
						table:"user_details",
						fields:"",
						condition:"id = '"+reqData.userId+"'"
					}
					common_model.GetData(getProData,function(response){

						if(reqData.email!=''){
							emailId= reqData.email;
						}else{
							 emailId= response.data[0].email_id;
						}
						if(reqData.mobile!=''){
							mobileNum= reqData.mobile;
						}else{
							 mobileNum= response.data[0].mobile;
						}

						if(reqData.name!=''){
							userName= reqData.name;
						}else{
							 userName= response.data[0].name;
						}

						if(reqData.country_name!=''){
							country_name= reqData.country_name;
						}else{
							 country_name= response.data[0].country_name;
						}

						var setdata = "user_name='"+userName+"',email_id='"+emailId+"',mobile='"+mobileNum+"',country_name='"+country_name+"',last_login=now(),is_mobileVerified='No'";
						var condition = "id='"+reqData.userId+"'";

						var UpdateProfile ={
							table:"user_details",
							setdata:setdata,
							condition:condition
						}
						common_model.SaveData(UpdateProfile,function(response){
							if (response.success === 1) 
							{
								if (response.success === 1)
								{
									cb({success:1,message:"Profile update successfully"});
								}else{
									cb(response);
								}
							  
								
							}else{
								cb(response);
							}
						});
					});
				}else{
					cb(response);
				}
			});

		}else{
			cb(response);
		}
	})


}


/*------------------- Login  ----------------------*/
signUp.loginAction = function(reqData,cb){
	var condition = "(mobile='"+reqData.email+"' and mobile!='')  OR (socialId='"+reqData.email+"' and socialId!='') and registrationType='"+reqData.LoginType+"'  and playerType='Real'";
	var getCredentials= {
		 table:"user_details",
		fields:"",
		condition:condition,
	}
	common_model.GetData(getCredentials,function(response){
		if(response.success===1){
			if(response.data[0].blockuser=='No'){
				if(response.data[0].otp_verify=='Yes'){
					var password = crypto.createHash('md5').update(reqData.password).digest("hex");
					if(response.data[0].password == password){
						if(response.data[0].device_id == reqData.deviceId){
							var condition2 = "id='"+response.data[0].id+"'";
							var updateLastLoginData = {
								table:"user_details",
								setdata:"last_login=now()",
								condition:condition2
							};

							common_model.SaveData(updateLastLoginData,function(resp){
								if(resp.success==1){
									var userObject ={
										userId: response.data[0].id,
										name:response.data[0].name,
										userName:response.data[0].user_name,
										emailId:response.data[0].email_id,
										mobile:response.data[0].mobile,
										userProfile:response.data[0].profile_img,
										status:response.data[0].status,
										countryName:response.data[0].country_name,
										referalCode:response.data[0].referal_code,
										referredAmt:response.data[0].referredAmt,
										availableBalance:response.data[0].balance,
										signupDate:response.data[0].signup_date,
										lastLogin:response.data[0].last_login,
										socialId:response.data[0].socialId,
										deviceId:response.data[0].device_id,
										deviceName:response.data[0].deviceName,
										deviceModel:response.data[0].deviceModel,
										deviceOs:response.data[0].deviceOs,
										deviceRam:response.data[0].deviceRam,
										deviceProcessor:response.data[0].deviceProcessor,
										kycStatus:response.data[0].kyc_status,
										totalScore:response.data[0].totalScore,
										totalWin:response.data[0].totalWin,
										totalLoss:response.data[0].totalLoss,
										mainWallet:response.data[0].mainWallet,
										winWallet:response.data[0].winWallet,
										playerId:response.data[0].playerId,
									}
									cb({status:true,success:1,message:"Success",response: "Login successfully",result:userObject,errorList: []}); 
								}else{
									 cb({status:false,success:3,message:"Failed",response: "Last login not Update",result:[{emailId:reqData.email}],errorList: []});
								}
							});
						}else{
							cb({status:false,success:2,message:"Failed",response: "Device Id not matched",result:[{emailId:reqData.email}],errorList: []});
						}
					}else{
						cb({status:false,success:3,message:"Failed",response: "Incorrect Password",result:[{emailId:reqData.email}],errorList: []});
					}
				}else{
					cb({status:false,message:"Failed",response: "User Not Verified",result:[{emailId:reqData.emailId}],errorList: []});
				}

			}else{
				cb({status:false,success:4,message:"Failed",response: "User is blocked by admin",result:[{emailId:reqData.email}],errorList: []});  
			}
		}else{
			 cb({status:false,success:5,message:"Failed",response: "Incorrect email or password",result:[{emailId:reqData.email}],errorList: []});  
		}

	});
}


signUp.updateDeviceId = function(reqData,cb){
	if(reqData.deviceId != '' && reqData.email != '' && reqData.password != '' && reqData.playerId !=''){
		let getUserData={
			'table':"user_details",
			'fields':"id,mobile,socialId,password",
			'condition':"mobile='"+reqData.email+"' OR socialId='"+reqData.email+"'",
		}
		common_model.GetData(getUserData,function(response){
			if (response.success ===1) {
				let emailId = response.data[0].mobile;
				let socialId = response.data[0].socialId;
				let getpass = response.data[0].password;
				let password = crypto.createHash('md5').update(reqData.password).digest("hex");
				if( (emailId == reqData.email || socialId == reqData.email) && getpass == password){
					let setdata = "device_id='"+reqData.deviceId+"',deviceName='"+reqData.deviceName+"',deviceModel='"+reqData.deviceModel+"',deviceOs='"+reqData.deviceOs+"',deviceRam='"+reqData.deviceRam+"',deviceProcessor='"+reqData.deviceProcessor+"',playerId='"+reqData.playerId+"'";
					let condition = "mobile='"+reqData.email+"' OR socialId='"+reqData.email+"'";
					let updateDeviceId ={
						table:"user_details",
						setdata:setdata,
						condition:condition
					}
					common_model.SaveData(updateDeviceId,function(responseupdate){
						if (responseupdate.success === 1) 
						{
							let gettLastInsertedUser ={
								table:"user_details",
								fields:"",
								condition:"id='"+response.data[0].id+"'",
							}
						 common_model.GetData(gettLastInsertedUser,function(response){
							if(response.success===1){
								 var userObject ={
									userId: response.data[0].id,
									userName:response.data[0].user_name,
									emailId:response.data[0].email_id,
									mobile:response.data[0].mobile,
									userProfile:response.data[0].profile_img,
									status:response.data[0].status,
									countryName:response.data[0].country_name,
									referalCode:response.data[0].referal_code,
									referredAmt:response.data[0].referredAmt,
									availableBalance:response.data[0].balance,
									signupDate:response.data[0].signup_date,
									lastLoginOn:response.data[0].last_login,
									registrationType:response.data[0].registrationType,
									socialId:response.data[0].socialId,
									deviceId:response.data[0].device_id,
									deviceName:response.data[0].deviceName,
									deviceModel:response.data[0].deviceModel,
									deviceOs:response.data[0].deviceOs,
									deviceRam:response.data[0].deviceRam,
									deviceProcessor:response.data[0].deviceProcessor,
									totalScore:response.data[0].totalScore,
									totalWin:response.data[0].totalWin,
									totalLoss:response.data[0].totalLoss,
									mainWallet:response.data[0].mainWallet,
									winWallet:response.data[0].winWallet,
									playerId:response.data[0].playerId,
								}

							cb({success:1,lastId:response.data[0].id,result:userObject,message:"Device Id updated successfully."});
						}else{
								cb(response)
							}

						 });
						}else{
							cb(response);
						}
					});

				}else{
					cb({success:3,message:"Incorrect email or password"});
					//cb(response)
				}
			}else{
				cb({success:2,message:"User not found."});
			}
			
	});
		
	}else{
		cb({success:0,message:"All fields are required."});
	}
}


// mobile already exist
var isMobileExist = function (reqData,cb){
	var getData={
		table:"user_details",
		fields:"id,mobile",
		condition:"mobile = '"+reqData.mobile+"' and id !='"+reqData.userId+"' and blockuser='No'and mobile!=''"
	}
	common_model.GetData(getData,function(response){
		 if(response.success === 1){
			cb({success:5,message:"Moblie already exist"});
		}else{
			cb({success:1});
		}
	});
}

// email already exist
var isEmailExist = function(reqData,cb){
	var getData = {
		table:"user_details",
		fields:"id,email_id",
		condition:"email_id = '"+reqData.email+"' and id !='"+reqData.userId+"' and blockuser='No' and email_id!=''"
	}
	common_model.GetData(getData,function(response){
		if(response.success === 1){
			cb({success:4,message:"Email already exist"});
		}else{
			cb({success:1});
		}
	});
}



module.exports= signUp;