var express = require("express");
var path = require('path');
const request = require('request');
var bodyParser = require("body-parser");
var cookieParser = require('cookie-parser');
var fs = require("fs");
require('dotenv').config();
var app = express();
var http = require('http');
var morgan = require('morgan');
var signUp = require('./model/signUp.js');
var config = require('./config.js');
var port     = process.env.PORT || config.port;
process.env.NODE_TLS_REJECT_UNAUTHORIZED=0;
var tournaments = require('./model/tournaments.js');
var dice = require('./model/dice.js');
var other = require('./model/other.js');
var common_model = require('./model/common_model.js');
const { Console } = require("console");
//var server =http.createServer(app);
const server =require('http').createServer(app);
//const server =require('http').createServer(app);

process.on("uncaughtException",(err)=>{
console.log("exception error",err)
})
server.listen(port,function(){
	 console.log(config.portMsg)
});

//app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.set('view engine', 'ejs');


app.get('/',function(req,res){
	res.end('WELCOME TO NODE');
});

app.post("/signUp",function(req,res){
	var reqData = req.body;
	signUp.registration(reqData,function(response){
		res.send(response)
	})
});

app.post("/forgotPassword",function(req,res){
	var reqData = req.body;
	signUp.forgotPassword(reqData,function(response){
		res.send(response);
	});
});
app.post('/sendotp',(req,res)=>{
	var reqData=req.body
	var otp =signUp.sendSmsOpt(reqData.mobile,reqData.userId);
	console.log('sended otp  '+otp);
	var updateotp ={
		condition:'id="'+reqData.userId+'" and mobile="'+reqData.mobile+'"',
		setdata:"otp="+otp,
		table:'user_details',
	}
	common_model.SaveData(updateotp,function(data){
		//console.log('update otp db data = ',data)
	})
	res.send({success:1,message:"OTP is sent on your mobile number, Please verify OTP"})
})
app.post("/OtpVerify",function(req,res){
   var reqData = req.body;
 	signUp.OtpVerifyFunction(reqData,function(response){
		res.send(response);
});
 });
app.post("/verifyloginotp",(req,res)=>{
	var reqData = req.body;
	common_model.toOtpVerify(reqData.otp,reqData.userId,res)
})
// app.post("/resendOtp",function(req,res){
// 	var reqData = req.body;
// 	signUp.ResendOtpFunction(reqData,function(response){
// 		res.send(response);
// 	});
// });
app.post("/resendOtp",function(req,res){
	var reqData=req.body
	var otp =signUp.sendSmsOpt(reqData.mobile,reqData.userId);
	console.log('sended otp  '+otp);
	var updateotp ={
		condition:'id="'+reqData.userId+'" and mobile="'+reqData.mobile+'"',
		setdata:"otp="+otp,
		table:'user_details',
	}
	common_model.SaveData(updateotp,function(data){
		//console.log('update otp db data = ',data)
	})
	res.send({success:1,message:"OTP is sent on your mobile number, Please verify OTP"})
});
//cb({success:1,message:"OTP is sent on your mobile number, Please verify OTP"});
app.post("/transferamount",(req,response)=>{
	var reqData = req.body;
	common_model.transferAmount(reqData.amount,reqData.userId,reqData.name,response)
})
app.get("/lederboardwork",(req,res)=>{
	res.send(true)
})

app.post("/changePassword",function(req,res){
	var reqData =req.body;
	signUp.changePassword(reqData,function(response){
		res.send(response);
	});
});

app.post("/updateProfile",function(req,res){
	var reqData = req.body;
	signUp.profileUpdateFunction(reqData,function(response){
		res.send(response);
	});
});


app.post("/login",function(req,res){
	var reqData =req.body;
	signUp.loginAction(reqData,function(response){
		res.send(response);
	});
});

app.get("/leaderboard", function (req, res) {
  const duration = req.query.duration;

  if (!duration) {
    res.send({
      error: "Invalid Request",
      message: "'duration' in Query is Required",
      status: false,
    });
}else{
	let durationFilter = '';
	const date = new Date()
	if(duration === 'day'){
		const formattedDate = `'${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}'`
		durationFilter = `created >= ${formattedDate}`
	}else if(duration === 'week'){
		const oneDayMilliSeconds = 8.64e+7;
		const weekStart =  date.getTime()- (date.getDay() * oneDayMilliSeconds)
		const startDay = new Date(weekStart);
		// const formattedDate = `${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`
		const formattedStartDate = `${startDay.getFullYear()}-${startDay.getMonth()+1}-${startDay.getDate()}`
		
		durationFilter = `created >= '${formattedStartDate}'`
	}else if(duration === 'month'){
		const formattedStartDate = `${date.getFullYear()}-${date.getMonth()+1}-01`
		// const formattedDate = `${date.getFullYear()}-${date.getMonth()+1}-${date.getDate()}`
		
		durationFilter = `created >= '${formattedStartDate}'`
	}else{
		res.send({
		error: "Invalid Request",
		message: "'duration' value is invalid in Query is Required",
		status: false,
		});
		return;
	}
	
	const sqlQuery = `
	SELECT userId, tableId, isWin, coins_deduct_history.winWallet, created, user_details.name, user_details.profile_img, user_details.user_name
	FROM coins_deduct_history LEFT JOIN user_details
	ON coins_deduct_history.userId = user_details.user_id
	WHERE 
		isWin='Win' AND  
		${durationFilter}
	ORDER BY winWallet DESC;
		`
		// ORDER BY winWallet DESC;
	common_model.sqlQuery(sqlQuery, function (response) {
		res.send(response)
	})
  }
});

// GET all transitional History
app.post("/transition", function (req, res) {
	const userId = req.body.userId;
	if(!userId){
		res.send({
			error: "Invalid Request",
			message: "userId is required",
			status: false,
		});
		return;
	  }
		//   Getting data from referal_user_logs
		const sqlQueryReferalLogs = `
		SELECT fromUserId,created, toUserId, user_id as userId, referalAmount, referalAmountBy, name, profile_img, user_name
		FROM referal_user_logs LEFT JOIN user_details
		ON referal_user_logs.toUserId = user_details.user_id
		WHERE 
			fromUserId = ${userId}  order by referlogid  ;
		`

		const sqlQueryCoinDeductHistory = `
		SELECT userId, tableId, isWin, betvalue,game, coins_deduct_history.winWallet, created, user_details.name, user_details.profile_img, user_details.user_name
		FROM coins_deduct_history LEFT JOIN user_details
		ON coins_deduct_history.userId = user_details.user_id
		WHERE 
		userId=${userId};
		`

		const sqlQueryForUserAccount = `
			SELECT user_detail_id, paymentType, type, amount, status, created
			FROM user_account
			WHERE user_detail_id = ${userId};
		`

		const sqlQueryForWithdraw = `
			SELECT user_id, type, bank_account_no, bank_ifsc_code, bank_account_name, upi_id, amount, created, status  
			FROM withdraw
			WHERE user_id = ${userId};
		`


			// ORDER BY winWallet DESC;
		  // ORDER BY winWallet DESC;
	  common_model.sqlQuery(`${sqlQueryReferalLogs} ${sqlQueryCoinDeductHistory} ${sqlQueryForUserAccount} ${sqlQueryForWithdraw}`, function (response) {
		  if(response.success !== 1){
			  res.send(response)
			 return; 
		  }

		  response.data[0] = response.data[0].map(v => ({...v, category: 'referal_log'}))
		  response.data[1] = response.data[1].map(v => ({...v, category: 'coin_deduct_history'}))
		  response.data[2] = response.data[2].map(v => ({...v, category: 'user_account'}))
		  response.data[3] = response.data[3].map(v => ({...v, category: 'withdraw'}))


		  res.send(response)

		// //   console.log("Response 1 ", response);
		//   let referalLogs = response.data;
		//   referalLogs = referalLogs.map(v => ({...v, type: 'referal_log'}))
		//   common_model.sqlQuery(sqlQueryCoinDeductHistory, (response2)=>{
		// 	if(response2.success !== 1){
		// 		res.send(response2)
		// 	   return; 
		// 	}

		// 	let coinDeductHistory = response2.data;
		// 	coinDeductHistory = coinDeductHistory.map(v => ({...v, type: 'coin_deduct_history'}))
			
		//   common_model.sqlQuery(sqlQueryForUserAccount, (response3)=>{
		// 	if(response3.success !== 1){
		// 		res.send(response3)
		// 	   return; 
		// 	}
	
		// 	let userAccountLogs = response3.data;
		// 	userAccountLogs = userAccountLogs.map(v => ({...v, type: 'user_account'}))
		// 	const allTransitions = referalLogs.concat(coinDeductHistory).concat(userAccountLogs);
	
		// 	response3['data'] = allTransitions;
		// 	res.send(response3);
		// 	})
		//   })
	  })
  });

//   withdraw amount
app.post("/withdraw", (req, res) => {
	// Table withdraw
	const reqData = req.body;
	console.log("REQ", reqData);

	const sql = `call withdraw('${reqData.type}', '${reqData.bank_account_no}', '${reqData.bank_ifsc_code}', '${reqData.bank_account_name}', ${reqData.amount}, ${reqData.user_id}, '${reqData.upi_id}')`;
	// console.log(reqData);
	// console.log(sql);
	common_model.callProcedureCommon(sql,function(response1){
		console.log("AA",response1)
		
		res.send(response1)
	});


	// let sqlQueryForWithdraw = "";

	// if(reqData.type === 'bank' && reqData.bank_account_no && reqData.bank_ifsc_code && reqData.bank_account_name){
	// 	sqlQueryForWithdraw = `
	// 		INSERT INTO withdraw 
	// 			(user_id, type, bank_account_no, bank_ifsc_code, bank_account_name, amount) 
	// 		VALUES
	// 			(${reqData.user_id}, '${reqData.type}', '${reqData.bank_account_no}', '${reqData.bank_ifsc_code}', '${reqData.bank_account_name}', ${reqData.amount});
	// 		`
	// }else if(reqData.type === "upi" && reqData.upi_id){
	// 	sqlQueryForWithdraw = `
	// 		INSERT INTO withdraw 
	// 			(user_id, type, upi_id, amount) 
	// 		VALUES
	// 			(${reqData.user_id}, '${reqData.type}', '${reqData.upi_id}', ${reqData.amount});
	// 		`
	// }else{
	// 	res.send({
	// 		error: 'Invalid Data',
	// 		message: "Specify a valid type either 'bank' or 'upi' and respecity details",
	// 		status: false,
	// 	})
	// 	return;
	// }

	// // checking if withdraw amount is less than (mainWallet Ammount)
	// const sqlQueryForBalanceChecking = `SELECT user_id, mainWallet, winWallet FROM user_details WHERE user_id = ${reqData.user_id};`
	
	// common_model.sqlQuery(sqlQueryForBalanceChecking, function (response) {
	// 	console.log("Respone Of Balance : ", response);
	// 	if(response.success !== 1){
	// 		res.send(response)
	// 	   return; 
	// 	}
	// 	if(response.data.length === 0){
	// 		res.send({
	// 			error: 'Invalid User',
	// 			message: "User does not exists",
	// 			status: false,
	// 		})
	// 	   return; 
	// 	}

	// 	let mainWallet = response.data[0].mainWallet;
	// 	let winWallet = response.data[0].winWallet;
	// 	let deductAmount = reqData.amount;

	// 	// Checking balance
	// 	if(deductAmount > (mainWallet + winWallet)){
	// 		res.send({
	// 			error: 'Low Balance',
	// 			message: "Your balance is Low",
	// 			status: false,
	// 		})
	// 		return;
	// 	}

	// 	// first deduct from winWallet and then from mainWallet
	// 	if(winWallet >= deductAmount){
	// 		winWallet = winWallet - deductAmount;
	// 	} else if(winWallet < deductAmount){
	// 		let a = deductAmount - winWallet;
	// 		winWallet = 0;
	// 		mainWallet = mainWallet - a;
	// 	}

	// 	// Balance Deducting from user Account
	// 	const sqlQueryForBalanceDeducting = `UPDATE user_details SET mainWallet = ${mainWallet}, winWallet = ${winWallet};`

	// 	common_model.sqlQuery(sqlQueryForBalanceDeducting, function (response2) {
	// 		console.log("Respone Balance Deduction : ", response2);
	// 		if(response2.success !== 1){
	// 			res.send(response2)
	// 		   return; 
	// 		}
			
	// 		common_model.sqlQuery(sqlQueryForWithdraw, function (response3) {
	// 			console.log("Respone : ", response3);
	// 			if(response3.success !== 1){
	// 				res.send(response3)
	// 			   return; 
	// 			}
	// 			res.send(response3)
	// 			return;
	// 		})
	// 	})
		
	// })

})

/*---------------------------- Get tournaments ------------------------------*/
app.post("/getTournaments",function(req,res){
	var reqData = req.body;
	tournaments.getTournaments(reqData,function(response){
		res.send(response);
	});
});

/*---------------------------- Get Bonus ------------------------------*/
app.post("/getBonus",function(req,res){
	 var reqData = req.body;
	 tournaments.getBonus(reqData,function(response){
		res.send(response);
	 });
});

/*---------------------------- Get Rooms ------------------------------*/

app.post("/getRoomDetails",function(req,res){
	 var reqData = req.body;
	 tournaments.getRoomDetails(reqData,function(response){
		res.send(response);
	 });
});
// get api for play time
app.post("/getIsPlayTime",function(req,res){
	var reqData =req.body;
	tournaments.getIsPlayTime(reqData,function(response){
		res.send(response);
	});
})
// get api for play time
app.post("/getdayWiseTimings",function(req,res){
	var reqData =req.body;
	tournaments.getdayWiseTimings(reqData,function(response){
		res.send(response);
	});
})

/*---------------------------- Update Device Id ------------------------------*/
app.post("/updateDevice",function(req,res){
	var reqData = req.body;
	signUp.updateDeviceId(reqData,function(response){
		res.send(response);
	});
});

/*---------------------------- Update player progress ------------------------------*/
app.post("/updateplayerProgress",function(req,res){
  	var reqData = req.body;
	tournaments.updateplayerProgress(reqData,function(response){
		res.send(response);
	});
});


/*---------------------------- Get player progress------------------------------*/

app.post("/getplayerProgress",function(req,res){
	 var reqData = req.body;
	 tournaments.getplayerProgress(reqData,function(response){
		res.send(response);
	 });
});


/*---------------------------- Get transaction list------------------------------*/

app.post("/getTransactionList",function(req,res){
	 var reqData = req.body;
	 tournaments.getTransactionListByCustId(reqData,function(response){
		res.send(response);
	 });
});

/*---------------------------- Get transaction list------------------------------*/
app.post("/purchaseDice",function(req,res){
		var reqData =req.body;
		dice.purchaseDice(reqData,function(response){
			res.send(response);
		});
});

//------------------ save support------------------------------------
app.post("/addSupport",function(req,res){
	var reqData =req.body;
	tournaments.addSupport(reqData,function(response){
		res.send(response);
	});
});

app.post("/getSupport",function(req,res){
	var reqData =req.body;
	tournaments.getSupport(reqData,function(response){
		res.send(response);
	});
});
/*------------------- For get game version -------------------------*/
app.post("/getGameVersion",function(req,res){
	var reqData =req.body;
	dice.getGameVersion(reqData,function(response){
		res.send(response);
	});
});

/*------------------- get top 30 players record -------------------------*/
app.post("/topPlayersRecord",function(req,res){

	var reqData =req.body;
	other.topPlayersRecord(reqData,function(response){
		res.send(response);
	});
});

/*------------------- get items record -------------------------*/
app.post("/getItems",function(req,res){
	var reqData =req.body;
	dice.getItems(reqData,function(response){
		res.send(response);
	});
});


/*------------------- get admin Percent record -------------------------*/
app.post("/getadminPercent",function(req,res){
	var reqData =req.body;
	other.getadminPercent(reqData,function(response){
		res.send(response);
	});
});



/*------------------- get game history -------------------------*/
app.post("/getGameHistory",function(req,res){
    var reqData =req.body;
    other.getGameHistory(reqData,function(response){
        res.send(response);
    });
});

/*------------------- my Referr Record -------------------------*/
app.post("/myReferrRecord",function(req,res){
    var reqData =req.body;
    other.myReferrRecord(reqData,function(response){
        res.send(response);
    });
});

/*------------------- my Withdrawal History -------------------------*/
app.post("/myTransactionHistory",function(req,res){
    var reqData =req.body;
    other.myTransactionHistory(reqData,function(response){
        res.send(response);
    });
});

/*------------------- my Withdrawal History -------------------------*/
app.post("/myWithdrawalHistory",function(req,res){
    var reqData =req.body;
    other.myWithdrawalHistory(reqData,function(response){
        res.send(response);
    });
});

/*-------------------  Save Bonus By userID -------------------------*/
app.post("/setBonusByUserId",function(req,res){
    var reqData =req.body;
    other.setBonusByUserId(reqData,function(response){
        res.send(response);
    });
});

/*-------------------  get Bonus By userID -------------------------*/
app.post("/getBonusByUserId",function(req,res){
    var reqData =req.body;
    other.getBonusByUserId(reqData,function(response){
        res.send(response);
    });
});

/*-------------------  get Current Date&Time -------------------------*/
app.post("/getCurrentDateTime",function(req,res){
    var reqData =req.body;
    other.getCurrentDateTime(reqData,function(response){
        res.send(response);
    });
});

/*-------------------  get Current Date&Time -------------------------*/
app.post("/updateReferToBalance",function(req,res){
    var reqData =req.body;
    other.updateReferToBalance(reqData,function(response){
        res.send(response);
    });
});

/*-------------------  get Bonus By userID -------------------------*/
app.post("/getMaintainance",function(req,res){
    var reqData =req.body;
    other.getMaintainance(reqData,function(response){
        res.send(response);
    });
});


/*------------------- get addSpinWheel -------------------------*/
app.post("/addSpinWheel",function(req,res){
    var reqData =req.body;
	console.log('add spin wheel call = ',reqData);
    other.addSpinWheel(reqData,function(response){
        res.send(response);
    });
});

/*------------------- get getSpinWheel -------------------------*/
app.post("/getSpinWheel",function(req,res){
    var reqData =req.body;
    other.getSpinWheel(reqData,function(response){
        res.send(response);
    });
});

/*------------------- get getSpinPrices -------------------------*/
app.post("/getSpinPrices",function(req,res){
    var reqData =req.body;
    other.getSpinPrices(reqData,function(response){
        res.send(response);
    });
});

/*------------------- get getCoupons -------------------------*/
app.post("/getCoupons",function(req,res){
    var reqData =req.body;
    other.getCoupons(reqData,function(response){
        res.send(response);
    });
});
app.post("/getSettings",function(req,res){
    var reqData =req.body;
    other.getSettings(reqData,function(response){
        res.send(response);
    });
});
app.post("/savefirebasetoken",(req,res)=>{
	var reqData =req.body;
common_model.savefirebaseToken(reqData,res)
})
// var reqData={
// 	couponCode:'l7wqY1',
// 	userId:'1'
// }
//  other.getSettings(reqData,function(response){

//         console.log(response);
//     });

