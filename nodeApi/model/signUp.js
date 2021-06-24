var signUp ={};
require('dotenv').config();
var database = require('../database/database.js');
var common_model = require('../model/common_model.js');
const request = require('request');
var crypto = require('crypto');
var nodemailer = require('nodemailer');
var bcrypt = require('bcryptjs');
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
// var hash = bcrypt.hashSync('1100');
// var rez1 =  bcrypt.compare('1010','1100');
// console.log(rez1)
// var rez1 = await bcrypt.compare('params.password', user.password);
// console.log(hash)
//

// 
var rcount=0;
signUp.registration =   (reqData,cb)=> {
	if(!reqData.mobile || !reqData.name){
		var errorResponse = {
			error: 'Invalid Data',
			message: 'Mobile and Name are required',
			status: false,
		}
		cb(errorResponse);
		return;
	}


	// Assigned Default Values
	if(!reqData.playerId){
		reqData.playerId='';
	}
	if(reqData.fbimgPath==undefined){
		reqData.fbimgPath ='http://13.233.233.105/profile_photo_8.png';
	}
	if(reqData.gimgPath==undefined){
		reqData.gimgPath ='http://13.233.233.105/profile_photo_8.png';
	}
	if(reqData.password==undefined){
		reqData.password =reqData.mobile;
	}
	if(reqData.email==undefined){
		reqData.email ='default@gmail.com';
	}
	if(reqData.socialId==undefined){
		reqData.socialId ='';
	}
	if(reqData.registrationType==undefined){
		reqData.registrationType ='phone';
	}
	if(reqData.referalCode==undefined){
		reqData.referalCode ='';
	}
	if(reqData.country_name==undefined){
		reqData.country_name ='';
	}
	var hash = bcrypt.hashSync(reqData.password);
	//var OTP=signUp.sendSmsOpt(response1.mobile,response1.id);
	var sql = "call registration('"+reqData.mobile+"','"+reqData.email+"','"+reqData.socialId+"','"+reqData.registrationType+"','"+reqData.referalCode+"','"+hash+"','"+reqData.country_name+"','"+reqData.name+"','"+reqData.deviceId+"','"+reqData.userName+"','"+reqData.deviceName+"','"+reqData.deviceModel+"','"+reqData.deviceOs+"','"+reqData.deviceRam+"','"+reqData.deviceProcessor+"','"+reqData.playerId+"','"+reqData.fbimgPath+"','"+reqData.gimgPath+"')";
	// console.log(reqData);
	// console.log(sql);
	common_model.callProcedureCommon(sql,function(response1){
		// console.log("AA",response1)
		if(response1.success == 1){
			rcount +=1;
			// console.log("rcount "+rcount);
	// 	var OTP=signUp.sendSmsOpt(response1.mobile,response1.id)
	// 	console.log('sended otp  '+OTP);
	// var updateotp ={
	// 	condition:'id="'+reqData.userId+'" and mobile="'+reqData.mobile+'"',
	// 	setdata:"otp="+OTP,
	// 	table:'user_details',
	// }
	// common_model.SaveData(updateotp,function(data){
	// 	console.log('update otp db data = ',data)
	// })
	       console.log('responce otp = '+response1.otp);
		   signUp.sendSmsOpt_reg(response1.mobile,response1.id,response1.otp);
           //response1.otp=OTP
			var userObject ={
				userId: response1.id,
				name:response1.name,
				userName:response1.user_name,
				emailId:response1.email_id,
				mobile:response1.mobile,
				userProfile:response1.profile_img,
				status:response1.status,
				countryName:response1.country_name,
				referalCode:response1.referal_code,
				availableBalance:response1.balance,
				signupDate:response1.signup_date,
				lastLoginOn:response1.last_login,
				kycStatus:response1.kyc_status,
				registrationType:response1.registrationType,
				socialId:response1.socialId,
				deviceId:response1.device_id,
				deviceName:response1.deviceName,
				deviceModel:response1.deviceModel,
				deviceOs:response1.deviceOs,
				deviceRam:response1.deviceRam,
				deviceProcessor:response1.deviceProcessor,
				totalScore:response1.totalScore,
				/*referredBy:response1.refferdByUserName,
				referredAmt:response1.referredAmt,
				referredUser:response1.UserName,*/
				totalWin:response1.totalWin,
				totalLoss:response1.totalLoss,
				mainWallet:response1.mainWallet,
				winWallet:response1.winWallet,
				playerId:response1.playerId,
				fbimgPath:reqData.fbimgPath,
				gimgPath:reqData.gimgPath,
			}
			cb({success:1,lastId:response1.id,status:true,result:userObject,message:"OTP is sent on your mobile number, Please verify OTP"});

		//    TODO - Currently Useing Default OTP
		// var getSmsData = {
		// 	table:"mst_sms_body",
		// 	fields:"",
		// 	condition:"smsType='Otp-verification'"
		// }
		// 	common_model.GetDatlogina(getSmsData,function(response){
		// 		if (response.success===1) {
		// 			var sms_body = response.data[0].smsBody;
		// 			var mobileNo = reqData.mobile;
		// 			var replacedSmsBody = sms_body.replace(/{otp}/g, response1.otp);
		// 			// var sqlPr ="CALL sendSmsProcedure('"+process.env.JOINGAME+"','"+process.env.SKILL+"')";
		//    //          common_model.callProcedureCommon(sqlPr,function(rest){
		//    //          });
		//    			console.log("Trying Sending SMS");
					
		// 			// sendSmsOpt(mobileNo,replacedSmsBody);
		// 			//console.log({success:1,lastId:response.id,result:userObject,message:"OTP is sent on your mobile number, Please verify OTP"})
		// 		} else {
		// 			//cb({status:false,success:4,messa});
		// 		}
		// 	});

		} else {
			var tempResp = {
				success: response1.success,
				message: response1.message,
				status: false,
			}
			cb(tempResp);
		}
	});
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

		   // console.log(error)
		   // console.log(body)
		   // console.log("mail body")
	  });
}
function generateOTP() {
          
    // Declare a digits variable 
    // which stores all digits
    var digits = '0123456789';
    let OTP = '';
    for (let i = 0; i < 4; i++ ) {
        OTP += digits[Math.floor(Math.random() * 10)];
    }
    return OTP;
}
signUp.sendSmsOpt= (mobileNo,userID)=>{
	//console.log("In SMS");
    
	var username = 'StudyWell';
	var apiKey = 'A0F46-2A862';
	var apiRequest = 'Text';
	// Message details
	var numbers = mobileNo; // Multiple numbers separated by comma
	var senderId = 'RVNENT';
	var OTP=generateOTP();
	var messagenew = `Hello, Your OTP for StudyWell Login is ${OTP}. Thank You, Team StudyWell`;
	// // Route details
	// var apiRoute = 'TRANS';
	// // Prepare data for POST request
	// var data = 'username='+username+'&apikey='+apiKey+'&apirequest='+apiRequest+'&route='+apiRoute+'&mobile='+numbers+'&sender='+senderId+"&message="+message;
	// // Send the GET request with cURL
	// var url = 'http://www.alots.in/sms-panel/api/http/index.php?'+data;
	// var url = url.replace(/ /, '%20');
	// //var url = 'http://api.textlocal.in//send//?username=ludofantasy1@gmail.com&hash=b329085b4779d9c9a00c9432e0&fe43bf37be7c6b2023e87768179a63a496968a&message='+urlencode(message)+'&sender=LUDOFN&numbers='+mobileNo+'&test=0';
	var URL = `http://api.bulksmsgateway.in/sendmessage.php?user=StudyWell&password=Study@2021&mobile=${numbers}&message=${messagenew}
&sender=STDYWL&type=3&template_id=1507161683455869105`
	var myJSONObject = {};   
	request({
		  url: URL,
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
		//   body: myJSONObject
		},function (error, response, body){
			// common_model.saveOtp(OTP,userID)

			//console.log("Body :", body);
			//console.log("Error :", error);
			//console.log("Response :", response);
		  // cb(body);
	  });
	  return OTP
	  
}

signUp.sendSmsOpt_reg= (mobileNo,userID,otp_)=>{
	//console.log("In SMS");
    
	var username = 'StudyWell';
	var apiKey = 'A0F46-2A862';
	var apiRequest = 'Text';
	// Message details
	var numbers = mobileNo; // Multiple numbers separated by comma
	var senderId = 'RVNENT';
	var OTP=otp_;
	var messagenew = `Hello, Your OTP for StudyWell Login is ${OTP}. Thank You, Team StudyWell`;
	// // Route details
	// var apiRoute = 'TRANS';
	// // Prepare data for POST request
	// var data = 'username='+username+'&apikey='+apiKey+'&apirequest='+apiRequest+'&route='+apiRoute+'&mobile='+numbers+'&sender='+senderId+"&message="+message;
	// // Send the GET request with cURL
	// var url = 'http://www.alots.in/sms-panel/api/http/index.php?'+data;
	// var url = url.replace(/ /, '%20');
	// //var url = 'http://api.textlocal.in//send//?username=ludofantasy1@gmail.com&hash=b329085b4779d9c9a00c9432e0&fe43bf37be7c6b2023e87768179a63a496968a&message='+urlencode(message)+'&sender=LUDOFN&numbers='+mobileNo+'&test=0';
	var URL = `http://api.bulksmsgateway.in/sendmessage.php?user=StudyWell&password=Study@2021&mobile=${numbers}&message=${messagenew}
&sender=STDYWL&type=3&template_id=1507161683455869105`
	var myJSONObject = {};   
	request({
		  url: URL,
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
		//   body: myJSONObject
		},function (error, response, body){
			// common_model.saveOtp(OTP,userID)

			//console.log("Body :", body);
			//console.log("Error :", error);
			//console.log("Response :", response);
		  // cb(body);
	  });
	  return OTP
	  
}

/*--------------------------  Forgot Password Api ------------------------*/

signUp.forgotPassword = function(reqData,cb)
{
	if(reqData.mobile!=''){
		var sql = "call forgotPassword('"+reqData.mobile+"')";
		common_model.callProcedureCommon(sql,function(response1){
			if(response1.success==1){
					var hash = bcrypt.hashSync(response1.newPassword);
					var updateData = {
						table:"user_details",
						setdata:"password='"+hash+"'",
						condition:"id="+response1.userId
					}
					common_model.SaveData(updateData,function(response2){
						var getSmsData = {
							table:"mst_sms_body",
							fields:"",
							condition:"smsType='Forgot_password'"
						}
						common_model.GetData(getSmsData,function(response){
							if (response.success === 1) {
								var sms_body = response.data[0].smsBody;
								var replacedSmsBody = sms_body.replace(/{user_name}/g, response1.user_name).replace(/{password}/g, response1.newPassword);
							    // var sqlPr ="CALL sendSmsProcedure('"+process.env.JOINGAME+"','"+process.env.SKILL+"')";
					      //       common_model.callProcedureCommon(sqlPr,function(rest){
					      //       });
								signUp.sendSmsOpt(reqData.mobile,replacedSmsBody);
								cb({success:1,message:"Forgot Password Successfully, Password is send on your mobile"});
							   
							}else{
							   cb({success:0,message:"Sms body not found."});
							}
						});
					});
			}else{
				cb(response1);
			}
		});
	}else{
		 cb({success:0,status:false,message:"Please enter mobile no."});
	}
}

// sendMail(15)
/*--------------------------  Otp Verify  Api ------------------------*/
signUp.OtpVerifyFunction = function(reqData,cb){
	// To check req.body should contain mobile and otp
	if(!reqData.mobile || !reqData.otp){
		var errorResponse = {
			error: 'Invalid Data',
			message: 'Mobile and OTP are required',
			status: false,
		}
		cb(errorResponse);
		return;
	}

	var condition = "mobile='"+reqData.mobile+"' and otp='"+reqData.otp+"'";
	var otpData = {
		table:"user_details",
		fields:"id",
		condition:condition
	}
	common_model.GetData(otpData,function(response){
		// console.log(response)
		console.log('otp responce = ',response);
		if (response.success==1) { 
			
			var userId =response.data[0].id;
			// var sqlPr ="CALL sendSmsProcedure('"+process.env.JOINGAME+"','"+process.env.SKILL+"')";
   //          common_model.callProcedureCommon(sqlPr,function(rest){
   //          });
			var setdata = "otp_verify='Yes',is_mobileVerified='Yes',status='Active'";
			var condition = "mobile='"+reqData.mobile+"'";
			var updateData = {
				table:"user_details",
				setdata:setdata,
				condition:condition
			}
			common_model.SaveData(updateData,function(response2){
				if (response2.success==1) 
				{
					// console.log("Otp Verified successfully, Registration Successful.")
					cb({success:1,message:"Otp Verified successfully"});
					//sendMail(userId);
				}else{
					// console.log("Not verify")
					cb({success:0,message:"Not verify"});  
				}
			});
		}else{
			cb({success:0,message:"Invalid Mobile or Otp"});
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
							signUp.sendSmsOpt(mobileNo,replacedSmsBody);
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

// if(MD5(input_oldPassword) != @password)
//        then
//           set @success=2;
//           set @message= "password not matched.";
//        elseif(@password = MD5(input_newPassword))
//        then
//           set @success=3;
//           set @message= "Old & new password can't be same";
//        elseif(@password = MD5(input_confirmPassword))
//        then
//           set @success=4;
//           set @message= "New password and confirm password should be same";
//        else
//           UPDATE user_details SET password=MD5(input_newPassword) where id=input_userId;
//           set @success=1;
//           set @message= "Password changed successfully";
//        end if
/*---------------------------------- Change Password ---------------------------------------*/
signUp.changePassword= function(reqData,cb){
	if(reqData.newPassword!=reqData.confirmPassword) {
			cb({success:0,message:"New password and confirm password should be same"});
	}else{
		var sql = "call changePassword('"+reqData.userId+"','"+reqData.oldPassword+"','"+reqData.newPassword+"','"+reqData.confirmPassword+"')";
		common_model.callProcedureCommon(sql,function(response){
				if(response.success==1){
		      		var password =response.dbPassword;
						bcrypt.compare(reqData.oldPassword, password, function(err, result) {
							if(result){
							 var hash = bcrypt.hashSync(reqData.newPassword);
								var updateData = {
									table:"user_details",
									setdata:"password='"+hash+"'",
									condition:"id="+reqData.userId
								}
								common_model.SaveData(updateData,function(response2){
									if(response2.success==1){
										cb({success:1,message:"Password changed successfully"}); 
									}else{
										cb({success:2,message:"Data not updated"}); 
									}
								});
							}else{
								cb({success:0,message:"Incorrect old password"});   
							}
						});
				}else{
					cb(response);     
				}
		});

	}
	
}


/*---------------------------------- Profile Update for Website---------------------------------------*/
signUp.profileUpdateFunction = function(reqData,cb){
	var sql = "call profileUpdate('"+reqData.userId+"','"+reqData.email+"','"+reqData.mobile+"','"+reqData.name+"','"+reqData.country_name+"')";
	common_model.callProcedureCommon(sql,function(err,response){
		if(err){
			cb(err);
		} else {
			cb(response);           
		}
	});
}
// 
 //(mobile=input_email and mobile!='')  OR (socialId=input_email and socialId!='') and registrationType=input_LoginType and playerType='Real'

/*------------------- Login  ----------------------*/
signUp.loginAction = function(reqData,cb){	
	// TODO - Change the email ==> mobile or something

	if(reqData.LoginType=='facebook'){
		// console.log("one")
		var sql ="select * from user_details where socialId='"+reqData.email+"' and socialId!='' and registrationType='"+reqData.LoginType+"' and playerType='Real' limit 1";
	}else{
		var sql ="select * from user_details where mobile='"+reqData.email+"' and mobile!='' and registrationType='"+reqData.LoginType+"' and playerType='Real' limit 1";
	}

	if(reqData.password == undefined){
		reqData.password = reqData.email;
	}

		//sqlQuery
	common_model.sqlQueryGetData(sql,function(response){
		//console.log(response)
		if(response.success==1){
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
				fbimgPath:response.data[0].fbimgPath,
				gimgPath:response.data[0].gimgPath,
				lastSpinDate:response.data[0].lastSpinDate,
			}

			var sql2 = "call userLogin('"+reqData.email+"','"+reqData.password+"','"+reqData.deviceId+"','"+reqData.LoginType+"')";

			if(reqData.LoginType=='facebook'){
				common_model.callProcedureCommon(sql2,function(response1){
					if(response1.success==1){							
						cb({
								status:true,
								success: response1.success,
								message: response1.message,
								response: response1.response,
								result: userObject,
								errorList: []
							});
					}else{
						cb({success:response1.success,status:false,message: response1.message,response: response1.response});
					}
				});

			}else{
					var hash = bcrypt.hashSync(reqData.password);
					var password = response.data[0].password;
					bcrypt.compare(reqData.password, password, function(err, result) {
						if(result){
							common_model.callProcedureCommon(sql2,function(response1){
								if(response1.success==1){							
									cb({
											status:true,
											success: response1.success,
											message: response1.message,
											response: response1.response,
											result: userObject,
											errorList: []
										});
								}else{
									cb({success:response1.success,status:false,message: response1.message,response: response1.response});
								}
							});
						}else{
							cb({success:2,status:false,message:"Incorrect password"})
						}

					});
			}
		}else{
			cb({success:0,message:"Data not found.",status:false})
		}
		// console.log(response.data[0].password)
		// 	var hash = bcrypt.hashSync(reqData.password);
			// bcrypt.compare(reqData.password, password, function(err, result) {
			// 		if(result){
			// 			console.log("result")
			// 		}else{
			// 			console.log("response")
			// 		}
			// });
	});
	// var hash = bcrypt.hashSync(reqData.password);
	// var sql = "call userLogin('"+reqData.email+"','"+reqData.password+"','"+reqData.deviceId+"','"+reqData.LoginType+"')";
	// console.log(sql);
	// common_model.callProcedureCommon(sql,function(response1){
	// 	if(response1.success == 1){
	// 		let gettLastUser ={
	// 			table:"user_details",
	// 			fields:"",
	// 			condition:"id='"+response1.user_id+"'",
	// 		}
	// 		common_model.GetData(gettLastUser,function(response){
	// 			//	console.log(response)
	// 			if(response.success===1){
	// 				var password = response.data[0].password;
	// 				// var rez1 =  bcrypt.compare(reqData.password, password);
	// 				bcrypt.compare(reqData.password, password, function(err, result) {
	// 				if(result){
	// 					var userObject ={
	// 							userId: response.data[0].id,
	// 							name:response.data[0].name,
	// 							userName:response.data[0].user_name,
	// 							emailId:response.data[0].email_id,
	// 							mobile:response.data[0].mobile,
	// 							userProfile:response.data[0].profile_img,
	// 							status:response.data[0].status,
	// 							countryName:response.data[0].country_name,
	// 							referalCode:response.data[0].referal_code,
	// 							referredAmt:response.data[0].referredAmt,
	// 							availableBalance:response.data[0].balance,
	// 							signupDate:response.data[0].signup_date,
	// 							lastLogin:response.data[0].last_login,
	// 							socialId:response.data[0].socialId,
	// 							deviceId:response.data[0].device_id,
	// 							deviceName:response.data[0].deviceName,
	// 							deviceModel:response.data[0].deviceModel,
	// 							deviceOs:response.data[0].deviceOs,
	// 							deviceRam:response.data[0].deviceRam,
	// 							deviceProcessor:response.data[0].deviceProcessor,
	// 							kycStatus:response.data[0].kyc_status,
	// 							totalScore:response.data[0].totalScore,
	// 							totalWin:response.data[0].totalWin,
	// 							totalLoss:response.data[0].totalLoss,
	// 							mainWallet:response.data[0].mainWallet,
	// 							winWallet:response.data[0].winWallet,
	// 							playerId:response.data[0].playerId,
	// 						}
	// 						cb({
	// 								status:true,
	// 								success: response1.success,
	// 								message: response1.message,
	// 								response: response1.response,
	// 								result: userObject,
	// 								errorList: []
	// 							});
	// 				}else{
	// 					cb({
	// 						status:false,
	// 						success: 0,
	// 						message: 'Failed',
	// 						response: 'Incorrect Password',
	// 						result: {},
	// 						errorList: []
	// 					});

	// 				}
	//     // result == true
	// });
					
	// 			}else{
	// 			   cb(response);
	// 			}
	// 		});
	// 	} else {
	// 		var tempResp = {
	// 			status:false,
	// 			message: response1.message,
	// 			response: response1.response,
	// 			success: response1.success,
	// 			result: [{emailId:reqData.email}],
	// 			errorList: []
	// 		}
	// 		// console.log(tempResp)
	// 		cb(tempResp);
	// 	}
	// });
}
// bcrypt.compare(reqData.password, password, function(err, result) {
									

//});

signUp.updateDeviceId = function(reqData,cb){
	if(reqData.deviceId !== '' && reqData.email !== ''  && reqData.playerId !=''){
		var mobileNumber =reqData.email;
		var sql = "call updateDeviceId('"+reqData.deviceId+"','"+reqData.deviceName+"','"+reqData.deviceModel+"','"+reqData.deviceOs+"','"+reqData.deviceRam+"','"+reqData.deviceProcessor+"','"+mobileNumber+"','"+reqData.password+"','"+reqData.playerId+"')";
		common_model.callProcedureCommon(sql,function(response1){
			if(response1.success === 1){
				var password = response1.password;
				bcrypt.compare(reqData.password, password, function(err, result) {
					if( (response1.mobile== mobileNumber || response1.socialId == mobileNumber)){
								var sqlQ ="UPDATE user_details SET device_id='"+reqData.deviceId+"',deviceName = '"+reqData.deviceName+"', deviceModel = '"+reqData.deviceModel+"', deviceOs = '"+reqData.deviceOs+"', deviceRam = '"+reqData.deviceRam+"', deviceProcessor = '"+reqData.deviceProcessor+"', playerId='"+reqData.playerId+"' WHERE mobile='"+mobileNumber+"' OR socialId='"+mobileNumber+"'";
							common_model.sqlQuery(sqlQ,function(updateResponse){
								if(updateResponse.success==1){
											let gettLastInsertedUser ={
												table:"user_details",
												fields:"",
												condition:"id='"+response1.userId+"'",
											}
											common_model.GetData(gettLastInsertedUser,function(response){
												if(response.success===1){
													console.log(response.data[0]);
													   var userObject ={
															userId: response.data[0].id,
															name:response.data[0].user_name,
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
													   cb(response1);
													}
												});
								}else{
									cb(updateResponse);
								}								
							});

					}else{
						cb({success:3,message:"Incorrect mobile or password."});
					}
					
				});
			} else {
				cb(response1);
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
		condition:"mobile = '"+reqData.mobile+"' and id !='"+reqData.userId+"' and blockuser='No' and mobile!=''"
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