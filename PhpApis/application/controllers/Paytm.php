<?php
defined('BASEPATH') OR exit('No direct script access allowed');

date_default_timezone_set("Asia/Calcutta");

class Paytm extends CI_Controller 
{
	public function __construct()
    {
        parent::__construct();
    }

	public function pay_by_paytm($orderId,$customer_id,$amount,$isCoupan='',$discountAmount='',$coupanCode='')
	{

		
		if(isset($orderId) && isset($customer_id) && isset($amount) && isset($isCoupan)){

			$getOrderId = $this->Crud_model->GetData('user_account','','orderId="'.$orderId.'"');
			if(!empty($getOrderId)){
				redirect('Welcome/PaymentDone/2');
			}else if(!empty($orderId) && !empty($customer_id) && !empty($amount)){
				$Data = array(
					'user_detail_id' => $customer_id,
		            'orderId' => $orderId,
					'amount' => $amount,
					'paymentType' => 'paytm',	
					'created' =>date('Y-m-d H:i:s'),
				);

				$isGoToPayment="Yes";
				if($isCoupan==""){ $isCoupan = "No";}
				if($isCoupan=="Yes"){
					$getcoupanCode = $this->Crud_model->GetData('coupon_codes','','couponCode="'.$coupanCode.'" and isUsed="No"');
					if(!empty($getcoupanCode)){
						$coupanData=array(
			        		"isUsed"=>'Yes',
			        	);
			        	$this->Crud_model->SaveData("coupon_codes",$coupanData, "couponCode='".$coupanCode."'");
			        	$amount = $amount - $getcoupanCode[0]->discount;
						$isGoToPayment="Yes";
						$Data['coupanCode'] =$coupanCode;
						$Data['discountAmount'] =$getcoupanCode[0]->discount;
						$Data['discount'] =$getcoupanCode[0]->discount;
						$Data['isCoupan'] ='Yes';
					}else{
						$isGoToPayment="No";						
					}
				}

				// echo "<pre>";	
				// print_r($amount); echo "<br>";
				// print_r($discountAmount); echo "<br>";
				
				// print_r($getcoupanCode);
				// exit();
				if($isGoToPayment=="No"){
					redirect('Welcome/PaymentDone/5');
				}else{					
					   
						$saveData = $this->Crud_model->SaveData('user_account',$Data);
						$_POST["customer_id"] = $customer_id;
						header("Pragma: no-cache");
				 		header("Cache-Control: no-cache");
				  		header("Expires: 0");
				   		$mode = "TEST";
					  	$appId = "623172cd3202e17eaedb9b6a371326";
					  	$secretKey = "5c9d361d4d91eff37076264fcedc43b5c9cd1bef";
				   		if($mode=="PROD"){
						  $appId = "623172cd3202e17eaedb9b6a371326";
						  $secretKey = "5c9d361d4d91eff37076264fcedc43b5c9cd1bef";
				   		}
  						$postData = array( 
  							"appId" => $appId, 
  							"orderId" => $orderId, 
  							"orderAmount" =>$amount, 
  							"orderCurrency" => "INR", 
  							"orderNote" => "PG", 
  							"customerName" =>  $customer_id, 
 							 "customerPhone" => "9999999999", 
  							"customerEmail" =>  $customer_id."@gmail.com",
  							"returnUrl" => base_url('index.php/Paytm/checkPayment/'.$customer_id), 
 							 "notifyUrl" => "",
						);
						ksort($postData);
						$signatureData = "";
						foreach ($postData as $key => $value){
    						$signatureData .= $key.$value;
						}
						$signature = hash_hmac('sha256', $signatureData, $secretKey,true);
						$signature = base64_encode($signature);

						if ($mode == "PROD") {
  								$url = "https://www.cashfree.com/checkout/post/submit";
						} else {
  								$url = "https://test.cashfree.com/billpay/checkout/post/submit";
						}	
							
						
						echo "<html>
						<head>
						<title>Merchant Check Out Page</title>
						</head>
						<body onload='document.frm1.submit()'>
						  <form method='post' action='".$url."' name='frm1'>
      						<p>Please wait.......</p>
      						<input type='hidden' name='signature' value='".$signature."'/>
      						<input type='hidden' name='orderNote' value='".$postData["orderNote"]."'/>
      						<input type='hidden' name='orderCurrency' value='".$postData["orderCurrency"]."'/>
      						<input type='hidden' name='customerName' value='".$postData["customerName"]."'/>
      						<input type='hidden' name='customerEmail' value='".$postData["customerEmail"]."'/>
      						<input type='hidden' name='customerPhone' value='".$postData["customerPhone"]."'/>
      						<input type='hidden' name='orderAmount' value='".$postData["orderAmount"]."'/>
      						<input type ='hidden' name='notifyUrl' value='".$postData["notifyUrl"]."'/>
      						<input type ='hidden' name='returnUrl' value='".$postData["returnUrl"]."'/>
      						<input type='hidden' name='appId' value='".$postData["appId"]."'/>
      						<input type='hidden' name='orderId' value='".$postData["orderId"]."'/>

  						   </form>
						</body>
						</html>";
				}
			}
			else
			{
				print_r('Insufficient parameters, Kindly uppdate with parameters');exit;
			}
		}
		else
		{
			print_r('Required parameters missing, Kindly uppdate with parameters');exit;
		}
	}

	public function checkPayment($customer_id)
	{
		
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");
	   
	    $paytmChecksum = "";
		$paramList = array();
		$isValidChecksum = "FALSE";
		$paramList = $_POST;
			$mode = "TEST";
		  	$appId = "rzp_test_zmTJmclxgissS7";
		  	// $secretKey = "5c9d361d4d91eff37076264fcedc43b5c9cd1bef";
		 $secretkey = "mSPlSYb5xLQZARJ1MQIAVAPF";
	   		if($mode=="PROD"){
			  $appId = "rzp_test_zmTJmclxgissS7";
			  $secretKey = "mSPlSYb5xLQZARJ1MQIAVAPF";
	   		}
		 $orderId = $_POST["orderId"];
		 $orderAmount = $_POST["orderAmount"];
		 $referenceId = $_POST["referenceId"];
		 $txStatus = $_POST["txStatus"];
		 $paymentMode = $_POST["paymentMode"];
		 $txMsg = $_POST["txMsg"];
		 $txTime = $_POST["txTime"];
		 $signature = $_POST["signature"];
		 $data = $orderId.$orderAmount.$referenceId.$txStatus.$paymentMode.$txMsg.$txTime;
		 $hash_hmac = hash_hmac('sha256', $data, $secretkey, true) ;
		 $computedSignature = base64_encode($hash_hmac);
		

		$orderData = $this->Crud_model->GetData('user_account','','orderId="'.$orderId.'"');
		if($orderData[0]->isCoupan=='Yes'){
			$isCoupan = "Yes";
			$coupanCode = $orderData[0]->coupanCode;
			$discount = $orderData[0]->discount;
			//$_POST['TXNAMOUNT'] = $orderData[0]->amount;
		}else{
			$isCoupan ="No";
			$coupanCode ="";
			$discount =0;
		}
		 if ($signature == $computedSignature) 
		{	
			if( $txStatus == "SUCCESS"){
		    	$json_data = json_encode($_POST);
				

		        $PaymentLog = array(
		          'transaction_id' => $referenceId,
		          'isPayment' => "Yes",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
		        // $this->Crud_model->SaveData("user_account",$PaymentLog, "orderId='".$orderId."'");
		        $getUserData = $this->Crud_model->GetData("user_details","","user_id='".$customer_id."'","","","","1");
		       	// print_r($saveuserData);exit();
		       	//  echo "<pre>"; 
		        if ($getUserData) {
		        	$totalCoins= $getUserData->balance + $orderAmount;
		        	$mainWallet= $getUserData->mainWallet + $orderAmount;
		        	$data=array(
		        		"balance"=>$totalCoins,
		        		"mainWallet"=>$mainWallet,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        $saveuserData = array(
		        		'transactionId'=>$referenceId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance + $orderAmount,
		        		'mainWallet'=>$getUserData->mainWallet + $orderAmount,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Success',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        		'modified'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account",$saveuserData, "orderId='".$orderId."'");
		        //print_r($this->db->last_query());exit;
		        $last_insertedId= $this->db->insert_id();
		        $saveuserDataLog = array(
		        		'transactionId'=>$referenceId,
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance +$orderAmount,
		        		'mainWallet'=>$getUserData->mainWallet + $orderAmount,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Success',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account_logs",$saveuserDataLog);
		       
		        redirect('Welcome/PaymentDone/1');
		        print_r('Payment Done ');exit;
			}elseif($txStatus == "PENDING"){
				if($isCoupan=="Yes"){
					$coupanData=array(
				        		"isUsed"=>'No',
		        	);
		        	$this->Crud_model->SaveData("coupon_codes",$coupanData, "couponCode='".$coupanCode."'");

				}
				 $getUserData = $this->Crud_model->GetData("user_details","","user_id='".$customer_id."'","","","","1");
		       	// print_r($saveuserData);exit();
		       	//  echo "<pre>"; 
		        if ($getUserData) {
		        	$totalCoins= $getUserData->balance;
		        	$mainWallet= $getUserData->mainWallet;
		        	$data=array(
		        		"balance"=>$totalCoins,
		        		"mainWallet"=>$mainWallet,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        $saveuserData = array(
		        		'transactionId'=>$referenceId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'type'=>'Deposit',
		        		'status'=>'Pending',
		        		'paymentType'=>'paytm',
		        		'discount'=>$discount,
		        		'created'=>date('Y-m-d H:i:s'),
		        		'modified'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account",$saveuserData, "orderId='".$orderId."'");
		        //print_r($this->db->last_query());exit;
		        $last_insertedId= $this->db->insert_id();
		        $saveuserDataLog = array(
		        		'transactionId'=>$referenceId,
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Pending',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account_logs",$saveuserDataLog);
		       
		        redirect('Welcome/PaymentDone/0');
		        print_r('Payment Failed ');exit;
			}else{	
				if($isCoupan=="Yes"){
					$coupanData=array(
				        		"isUsed"=>'No',
					);
					$this->Crud_model->SaveData("coupon_codes",$coupanData, "couponCode='".$coupanCode."'");

				}		
				$getUserData = $this->Crud_model->GetData("user_details","","user_id='".$customer_id."'","","","","1");
		       	// print_r($saveuserData);exit();
		       	//  echo "<pre>"; 
		        if ($getUserData) {
		        	$totalCoins= $getUserData->balance;
		        	$mainWallet= $getUserData->mainWallet;
		        	$data=array(
		        		"balance"=>$totalCoins,
		        		"mainWallet"=>$mainWallet,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        $saveuserData = array(
		        		'transactionId'=>$referenceId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Failed',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        		'modified'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account",$saveuserData, "orderId='".$orderId."'");
		        //print_r($this->db->last_query());exit;
		        $last_insertedId= $this->db->insert_id();
		        $saveuserDataLog = array(
		        		'transactionId'=>$referenceId,
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Failed',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account_logs",$saveuserDataLog);
		       
		        redirect('Welcome/PaymentDone/0');
		        print_r('Payment Failed ');exit;	
				
			} 
		}
		else 
		{
			if($isCoupan=="Yes"){
				$coupanData=array(
			        		"isUsed"=>'No',
				);
				$this->Crud_model->SaveData("coupon_codes",$coupanData, "couponCode='".$coupanCode."'");

			}
			if(!empty($_POST))
			{
				$json_data = json_encode($_POST);
					
		        $PaymentLog = array(
		          'transaction_id' =>  $referenceId,
		          'isPayment' => "No",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
			    // $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$orderId."'");
			    $getUserData = $this->Crud_model->GetData("user_details","","user_id='".$customer_id."'","","","","1");
		       	// print_r($saveuserData);exit();
		       	//  echo "<pre>"; 
		        if ($getUserData) {
		        	$totalCoins= $getUserData->balance;
		        	$mainWallet= $getUserData->mainWallet;
		        	$data=array(
		        		"balance"=>$totalCoins,
		        		"mainWallet"=>$mainWallet,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        $saveuserData = array(
		        		'transactionId'=> $referenceId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'type'=>'Deposit',
		        		'status'=>'Failed',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        		'modified'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account",$saveuserData, "orderId='".$orderId."'");
		        //print_r($this->db->last_query());exit;
		        $last_insertedId= $this->db->insert_id();
		        $saveuserDataLog = array(
		        		'transactionId'=> $referenceId,
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$orderId,
		        		'amount'=>$orderAmount,
		        		'balance'=>$getUserData->balance,
		        		'mainWallet'=>$getUserData->mainWallet,
		        		'user_detail_id'=>$customer_id,
		        		'isCoupan'=>$isCoupan,
		        		'coupanCode'=>$coupanCode,
		        		'discount'=>$discount,
		        		'type'=>'Deposit',
		        		'status'=>'Failed',
		        		'paymentType'=>'paytm',
		        		'created'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account_logs",$saveuserDataLog);
				redirect('Welcome/PaymentDone/0');
				print_r('Payment Failed ');exit;	
			}
			else{
				redirect('Welcome/PaymentDone/0');
				print_r('Payment Failed ');exit;	
			}
			
		} 
	}

	public function disburseFund()		// Creation of disburse Bank Transfer API.
	{
		header("Pragma: no-cache");
 		header("Cache-Control: no-cache");
  		header("Expires: 0");
   		//print_r($_POST);exit;
	    //require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
		require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");	
		//require_once("encdec_paytm.php");

	    /* initialize an array */
		$paytmParams = array();

		/* Find Sub Wallet GUID in your Paytm Dashboard at https://dashboard.paytm.com */
		//$paytmParams["subwalletGuid"] = "efbd16ef-0601-11ea-8708-fa163e429e83";
		//$paytmParams["subwalletGuid"] = "b1d0e909-8eb4-4474-8e17-eb2f98221862";
		$paytmParams["subwalletGuid"] = guid;//"97d2a3d6-f3bd-44e9-80de-c8a6dc89e7bc"; //GUID of AJAY

		/* Enter your unique order id, this should be unique for every disbursal */
		//$orderRand = rand(11111,99999);
		//$orderRand = 73387;

		$date = date('Y-m-d');
		$time = date('H:i:s');
		$paytmParams["orderId"] = $_REQUEST['order_id'];
		    
		/* Enter Beneficiary Phone Number against which the disbursal needs to be made */
		//$paytmParams["beneficiaryPhoneNo"] = 8421491235;

		/* Amount in INR payable to beneficiary */
		//$paytmParams["beneficiaryAccount"] = 919899996782;
		//$paytmParams["beneficiaryIFSC"] = 'PYTM0123456';
		//$paytmParams["beneficiaryAccount"] = 919890800533;
		//$paytmParams["beneficiaryIFSC"] = 'HDFC0002746';
		//$paytmParams["beneficiaryAccount"] = 300000002448;	Invalid Account details
		//$paytmParams["beneficiaryIFSC"] = 'PYTM0123456';		Invalid Account details
		$paytmParams["beneficiaryAccount"] = $_REQUEST['beneficiaryAccount'];//20195656312;
		$paytmParams["beneficiaryIFSC"] = $_REQUEST['beneficiaryIFSC'];//'MAHB0000303';
		$amount = $_REQUEST['amount'];//23;
		$paytmParams["amount"] = $amount;
		$paytmParams["purpose"] = 'BONUS';//'BONUS';
		$paytmParams["date"] = $date;
		$paytmParams["requestTimestamp"] = $time;

		/* prepare JSON string for request body */
		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);

		//echo "post_data <pre>"; print_r($post_data);echo '<br/>';
		/**
		* Generate checksum by parameters we have in body
		*/
		$checksum = getChecksumFromString($post_data, key);//iwpS9miFa%K0!x1L
		echo "checksum <pre>"; print_r($checksum);echo '<br/>';

		/* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
		//$x_mid = "AagamE55778795707048";
		$x_mid = mid;//"AagamE15178612468400";

		/* put generated checksum value here */
		$x_checksum = $checksum;
		// echo "x_checksum <pre>"; print_r($x_checksum);echo '</pre><br/>';

		/* Solutions offered are: food, gift, gratification, loyalty, allowance, communication */

		/* for Staging */
		//$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/bank";
		

		/* for Production */
		$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/bank";

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);	
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
		if($response->status=='ACCEPTED'){
			$resStatus ='';
		}else{
			$resStatus ='';
		}
		// $saveOrderData = array(
  //       		'orderId'=>$orderRand,
  //       		'amount'=>$amount,
  //       		'user_detail_id'=>1,
  //       		'type'=>'Gratification',
  //       		'status'=>'Pending',
  //       		'checkSum'=>$x_checksum,
  //       		'created'=>date('Y-m-d H:i:s'),
  //       		'modified'=>date('Y-m-d H:i:s'),
  //       	);
  //       $saveData = $this->Crud_model->SaveData("user_account",$saveOrderData);

	    print_r($response);exit();
	    curl_close($ch);
	    //print_r($result);
	}

	public function checkDisburseStatus()		// Check disburse bank status API
	{
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");		
		require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");	

		/* initialize an array */
		$paytmParams = array();

		/* Enter your order id which needs to be check disbursal status for */
		$order_id = $_REQUEST['order_id'];
		$paytmParams["orderId"] = $order_id;

		/* prepare JSON string for request body */
		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
		//echo "checksum <pre>"; print_r($post_data);echo '<br/>';
		/**
		* Generate checksum by parameters we have in body
		*/
		$checksum = getChecksumFromString($post_data, key);//iwpS9miFa%K0!x1L
		//echo "checksum <pre>"; print_r($checksum);echo '<br/>';
		/* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
		$x_mid = mid;//"AagamE15178612468400"

		/* put generated checksum value here */
		$x_checksum = $checksum;

		/* for Staging */
		//$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/query";

		/* for Production */
		$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/query";

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: ".$x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
		//print_r($response);exit;
		
	    print_r($response);exit();
	    curl_close($ch);
	}

	public function wallet_transfer(){
		/**
		* import checksum generation utility
		* You can get this utility from https://developer.paytm.com/docs/checksum/
		*/
		//print_r($customer_id);exit()
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");
	    // following files need to be included
	   // require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
	    require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");
	    $paytmChecksum = "";

		/* initialize an array */
		$paytmParams = array();

		/* Find Sub Wallet GUID in your Paytm Dashboard at https://dashboard.paytm.com */
		$paytmParams["subwalletGuid"] = "8aaab070-65bb-48d2-a5f3-f763edf6eb0d";
		//$paytmParams["subwalletGuid"] = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

		/* Enter your unique order id, this should be unique for every disbursal */
		$paytmParams["orderId"] = "190203";
		    
		/* Enter Beneficiary Phone Number against which the disbursal needs to be made */
		$paytmParams["beneficiaryPhoneNo"] = "9890800533";

		/* Amount in INR payable to beneficiary */
		$paytmParams["amount"] = "1";
		//$paytmParams["timestamp"] = date("Y-m-d h:i:s");

		/* prepare JSON string for request body */
		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
		print_r("https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification");print_r("<br/>");
		print_r($post_data);print_r("<br/>");
		/**
		* Generate checksum by parameters we have in body
		* Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
		*/
		$checksum = getChecksumFromString($post_data, "sB6awRVJ@YpDm3ZV");
		//$checksum = getChecksumFromString($post_data, "uF9cZaNpABsC&Xxa");

		/* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
		$x_mid = "VIVSON97870791415983";
		//$x_mid = "VIVSON12966438680092";
		print_r("x-mid : ".$x_mid);print_r("<br/>");	
		/* put generated checksum value here */
		$x_checksum = $checksum;
		print_r("x-checksum : ".$x_checksum );print_r("<br/>");		
		/* Solutions offered are: food, gift, gratification, loyalty, allowance, communication */

		/* for Staging */
		//$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/{solution}";

		/* for Production */
		 //$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification";
		 $url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/gratification";

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);
		print_r($response);exit;
	}
}