<?php
/**
* import checksum generation utility
* You can get this utility from https://developer.paytm.com/docs/checksum/
*/
require_once("application/third_party/paytmlib/encdec_paytm.php");
//Request
 /*{
    "orderId": "ORDER126",
    "subwalletGuid": "0bb236d7-7264-11ea-8708-fa163e429e83",
    "amount": "500",
    "purpose": "Bonus",
    "date": "2020/04/08",
    "beneficiaryAccount": "05391050114061",
    "beneficiaryIFSC": "HDFC0002844",
    "beneficiaryVPA": "9822000891@paytm",
    "beneficiaryPhoneNo": "9822000891",
   
}*/





/* initialize an array */
$paytmParams = array();

/* body parameters */
$paytmParams["body"] = array(

    /* for custom checkout value is 'Payment' and for intelligent router is 'UNI_PAY' */
    "requestType" => "Payment",

    /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
    "mid" => "Samart25954187992969",

    /* Find your Website Name in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
    "websiteName" => "https://www.ludo365.com",

    /* Enter your unique order id */
    "orderId" => "ORDER2",

    /* on completion of transaction, we will send you the response on this URL */
    "callbackUrl" => "https://www.ludo365.com",

    /* Order Transaction Amount here */
    "txnAmount" => array(

        /* Transaction Amount Value */
        "value" => "10",

        /* Transaction Amount Currency */
        "currency" => "INR",
    ),

    /* Customer Infomation here */
    "userInfo" => array(

        /* unique id that belongs to your customer */
        "custId" => "shaila09patange@gmail.com",
    ),
);

/**
* Generate checksum by parameters we have in body
* Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
*/
$checksum = getChecksumFromString(json_encode($paytmParams["body"], JSON_UNESCAPED_SLASHES), "5&%wCo05D2X&FMJf");


/* head parameters */
$paytmParams["head"] = array(

    /* put generated checksum value here */
    "signature"	=> $checksum
);

/* prepare JSON string for request */
$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);

/* for Staging */
$url = "https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?mid=Samart25954187992969&orderId=ORDER2";

/* for Production */
// $url = "https://securegw.paytm.in/theia/api/v1/initiateTransaction?mid=YOUR_MID_HERE&orderId=YOUR_ORDER_ID";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json")); 
$response = curl_exec($ch);



echo $response;