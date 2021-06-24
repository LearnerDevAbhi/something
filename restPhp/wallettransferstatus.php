<?php
/**
* import checksum generation utility
* You can get this utility from https://developer.paytm.com/docs/checksum/
*/
require_once("application/third_party/paytmlib/encdec_paytm.php");
//Request
 /*{
    "orderId": "ORDER8181",
    "amount": "50",
    "beneficiaryPhoneNo": "7777777777",
  
   
}*/



require_once("PaytmChecksum.php");

$paytmParams = array();

$paytmParams["orderId"] = "ORDER818187";

$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);

/*
* Generate checksum by parameters we have in body
* Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
*/
$checksum = PaytmChecksum::generateSignature($post_data, "T0KGN3FmR6_M7zL9");

$x_mid      = "Chinma14743989764574";
$x_checksum = $checksum;

/* for Staging */
$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/query";

/* for Production */
// $url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/query";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
$response = curl_exec($ch);
//print_r($response);



echo $response;