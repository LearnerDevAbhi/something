<?php
defined('BASEPATH') OR exit('No direct script access allowed');

date_default_timezone_set("Asia/Calcutta");
$clientId = 'CF72735BQNFC3N45TW6U2Q';
$clientSecret = '432718f950b3338e930a8e55e4ab4804c5201bba';
$env = 'prod';
$signature=null;
#config objs
$baseUrls = array(
    'prod' => 'https://payout-api.cashfree.com',
    'test' => 'https://payout-gamma.cashfree.com',
);
$urls = array(
    'auth' => '/payout/v1/authorize',
    'getBene' => '/payout/v1/getBeneficiary/',
    'addBene' => '/payout/v1/addBeneficiary',
    'requestTransfer' => '/payout/v1/requestTransfer',
    'getTransferStatus' => '/payout/v1/getTransferStatus?transferId='
);
$beneficiary = array(
    'beneId' => 'JOHN18019',
    'name' => 'jhon doe',
    'email' => 'johndoe@cashfree.com',
    'phone' => '9876543210',
    'bankAccount' => '000890289871772',
    'ifsc' => 'SCBL0036078',
    'address1' => 'address1',
    'city' => 'bangalore',
    'state' => 'karnataka',
    'pincode' => '560001',
);
$transfer = array(
    'beneId' => 'JOHN18019',
    'amount' => '1.00',
    'transferId' => 'DEC2039',
);

$header = array(
	'X-Cf-Signature: '.$signature,
    'X-Client-Id: '.$clientId,
    'X-Client-Secret: '.$clientSecret, 
    'Content-Type: application/json',
);

$baseurl = $baseUrls[$env];
class Paytm extends CI_Controller 
{
	public function __construct()
    {
        parent::__construct();

    }

    public function saveAllDistributerRedeemBypaytm(){
        $userData =$this->Crud_model->GetData("user_account","id,mobileNo,orderId,paymentType","id='".$_POST['id']."'","","","","1");
        $getSettData = $this->Crud_model->GetData("mst_settings","id,adminPercent","id='4'",'','','','1');
		$admin_rs=($_POST['withAmt']*$getSettData->adminPercent)/100;

		$getAdminData=$this->Crud_model->GetData("admin_login","id,adminBalance","id='".$_SESSION[SESSION_NAME]['id']."'",'','','','1');
		$userAmt = $_POST['withAmt'] - $admin_rs;
		$order_id = $userData->orderId;
		$amount=$userAmt;
		$userAccId=$this->input->post('id');
		$userId=$this->input->post('userId');
		$withrawAmt=$this->input->post('withAmt');
		$userMobileNo= $userData->mobileNo;
		//print_r($userMobileNo);exit();
		$this->wallet_transfer($order_id,$amount,$userMobileNo,$userAccId,$userId,$withrawAmt);
		redirect(site_url(WITHDRAWALDISTRIBUTE.'/'.base64_encode($_POST['id'])));

    }
    public function saveAllDistributerRedeem(){
        $userData =$this->Crud_model->GetData("user_account","id,mobileNo,orderId,paymentType","id='".$_POST['id']."'","","","","1");
       // print_r($userData->paymentType);exit();
        if($userData){
        	//if($userData->paymentType=='bank'){
        		$getSettData = $this->Crud_model->GetData("mst_settings","id,adminPercent","id='4'",'','','','1');
				$admin_rs=($_POST['withAmt']*$getSettData->adminPercent)/100;
				$getAdminData=$this->Crud_model->GetData("admin_login","id,adminBalance","id='".$_SESSION[SESSION_NAME]['id']."'",'','','','1');

				$userAmt = $_POST['withAmt'] - $admin_rs;
			   	$userBankData =$this->Crud_model->GetData("bank_details","","user_detail_id='".$_POST['userId']."'","","","","1"); 
				$order_id =$userData->orderId;
				$beneficiaryAccount= $userBankData->accno;
				$beneficiaryIFSC= $userBankData->ifsc;
				$amount=$userAmt;
				$userAccId=$this->input->post('id');
				$userId=$this->input->post('userId');
				$withAmt=$this->input->post('withAmt');
				$this->disburseFund($order_id,$amount,$beneficiaryAccount,$beneficiaryIFSC,$userAccId,$userId,$withAmt);

    //     	}else{
    //     		$getSettData = $this->Crud_model->GetData("mst_settings","id,adminPercent","id='4'",'','','','1');
				// $admin_rs=($_POST['withAmt']*$getSettData->adminPercent)/100;

				// $getAdminData=$this->Crud_model->GetData("admin_login","id,adminBalance","id='".$_SESSION[SESSION_NAME]['id']."'",'','','','1');
				// $userAmt = $_POST['withAmt'] - $admin_rs;
				// $order_id = $userData->orderId;
				// $amount=$userAmt;
				// $userAccId=$this->input->post('id');
				// $userId=$this->input->post('userId');
				// $withrawAmt=$this->input->post('withAmt');
				// $userMobileNo= $userData->mobileNo;
				// $this->wallet_transfer($order_id,$amount,$userMobileNo,$userAccId,$userId,$withrawAmt);
    //     	}
        }
   
       redirect(site_url(WITHDRAWALDISTRIBUTE.'/'.base64_encode($_POST['id'])));
    }
    public function test(){
    	header("Pragma: no-cache");
 		header("Cache-Control: no-cache");
  		header("Expires: 0");
		require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");
		$paytmParams = array();

		$paytmParams["subwalletGuid"] = guid;//"97d2a3d6-f3bd-44e9-80de-c8a6dc89e7bc"; //GUID of AJAY

		$date = date('Y-m-d');
		$time = date('H:i:s');
		$order_id = rand(000000000,999999999);
		$amount = 1;
		$paytmParams["orderId"] = $order_id;	
		/* Amount in INR payable to beneficiary */
		$paytmParams["beneficiaryAccount"] = '919899996782';
		$paytmParams["beneficiaryIFSC"] = 'PYTM0123456';
		$paytmParams["amount"] = $amount;
		$paytmParams["purpose"] = 'OTHERS';//'BONUS';
		// $paytmParams["date"] = $date;
		// $paytmParams["requestTimestamp"] = $time;


		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
		$x_checksum = getChecksumFromString($post_data, key);
		$x_mid = mid;
	    $url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/bank";
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);	
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
		if($response->status=='ACCEPTED'){
			$this->checkQuery($order_id,'12','1',$amount);
			//echo "<pre>";  print_r("OK");exit();
		}else{
			//echo "<pre>";  print_r($response->status);
		}
		
    }
    public function checkQuery($order_id,$userAccId,$userId,$amount)	// Check disburse bank status API
	{
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");		
		require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");	
		/* initialize an array */
		$paytmParams = array();
		$getPaytmData = $this->Crud_model->GetData("user_account",'','id="'.$userAccId.'"','','','','1');
		$paytmParams["orderId"] = $order_id;
		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
		$checksum = getChecksumFromString($post_data, key);//iwpS9miFa%K0!x1L
		$x_mid = mid;//"AagamE15178612468400"
		$x_checksum = $checksum;
		$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/query";
		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
	    curl_close($ch);
	
	}


	public  function getSignature() {
    $clientId = "CF72735BQNFC3N45TW6U2Q";
    $publicKey =
    openssl_pkey_get_public(file_get_contents("http://localhost/ludokrishcashfree.pem"));
    $encodedData = $clientId.".".strtotime("now");
    return static::encrypt_RSA($encodedData, $publicKey);
  }
private  function encrypt_RSA($plainData, $publicKey) { if (openssl_public_encrypt($plainData, $encrypted, $publicKey,
OPENSSL_PKCS1_OAEP_PADDING))
      $encryptedData = base64_encode($encrypted);
    else return NULL;
    return $encryptedData;
  }
    public function disburseFund($order_id,$amt,$beneficiaryAccount,$beneficiaryIFSC,$userAccId,$userId,$withAmt)// Creation of disburse Bank Transfer API.
	{	
		


		$signature= $this->getSignature();

	
         $beneficiary = array(
    'beneId' => $beneficiaryAccount,
    'name' =>$beneficiaryAccount,
    'email' =>$userId.'@gmail.com',
    'phone' =>  '9898989898' ,
    'bankAccount' =>$beneficiaryAccount,
    'ifsc' => $beneficiaryIFSC   ,
    'address1' =>'bangalore'  ,
    'city' =>  'bangalore' ,
    'state' => 'karnataka',
    'pincode' => '560001',
        );
  

	
		$token = $this->getToken();

		

		if(!$this->getBeneficiary($token,$beneficiary['beneId'])) 
        {
             $this->addBeneficiary($token, $beneficiary);
        }

		$transfer1 = array(
   	 	'beneId' => $beneficiaryAccount,
    	'amount' => $withAmt,
    	'transferId' => $order_id,
		);


		$this->requestTransfer($token,$transfer1);

		//sleep(3);


		$response1=$this->getTransferStatus($token,$transfer1);



		$response2=json_encode($response1);

		$response=json_decode($response2);


		
		
		$userBal =$this->Crud_model->GetData("user_details","id,status,balance","id='".$_POST['userId']."'","","","","1");
	
		if($response->status=='SUCCESS'){
			$resStatus ='Approved';
			$type ='Withdraw';
			$statusMessage=$response->message;
			$statusCode=$response->subCode;
			$saveRefundData = array(
	    		'orderId'=>$order_id,
	    		'user_detail_id'=>$userId,
	    		'paytmStatus'=>$response->status,
	    		'statusCode'=>$response->subCode,
	    		'statusMessage'=>$response->message,
	    		'checkSum'=>"",
	    		'type'=>$type,
	    		'paymentType'=>'bank',
	            'status'=>$resStatus,
	    		'created'=>date('Y-m-d H:i:s'),
	    		'modified'=>date('Y-m-d H:i:s'),
	        );
	        $saveData = $this->Crud_model->SaveData("user_account",$saveRefundData,'id="'.$userAccId.'"');

	        $saveRefundDataLog = array(
	        		'user_account_id'=>$userAccId,
	        		'orderId'=>$order_id,
	    			'amount'=>$withAmt,
	    			'balance'=>$userBal->balance,
	        		'user_detail_id'=>$userId,
	        		'paytmType'=>'byBank',
	        		'paytmStatus'=>$response->status,
	        		'statusCode'=>$response->subCode,
	        		'statusMessage'=>$response->message,
	        		'checkSum'=>"",
	        		'type'=>$type,
	        		'paymentType'=>'bank',
	                'status'=>$resStatus,
	        		'created'=>date('Y-m-d H:i:s'),
	        		'modified'=>date('Y-m-d H:i:s'),
	        	);
	        $saveData = $this->Crud_model->SaveData("user_account_logs",$saveRefundDataLog);
			//$this->checkDisburseStatus($order_id,$userAccId,$userId,$amount);
		}elseif($response->status=='ERROR'){
			$getUserDatadetails = $this->Crud_model->GetData('user_details','email_id,user_name,mobile,balance,winWallet',"id='".$userId."'",'','','','1');
			
			$updateBal =  $getUserDatadetails->balance + $getPaytmData->amount;
			$updatewinWallet =  $getUserDatadetails->winWallet + $getPaytmData->amount;
            $updateUserBal = array(
                'balance'=> $updateBal,
                'winWallet'=> $updatewinWallet,
                );
			$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');


			/*  Sms Code  */
			/*$sms_body=$this->Crud_model->GetData("mst_sms_body","","smsType='refund-reedem-amount'",'','','','1');
	        $sms_body->smsBody=str_replace("{user_name}",ucfirst($getUserDatadetails->user_name),$sms_body->smsBody); 
	        $sms_body->smsBody=str_replace("{amt}",$withAmt,$sms_body->smsBody); 
			$sms_body->smsBody=str_replace("{reason}",$response->statusMessage,$sms_body->smsBody);
			$body=$sms_body->smsBody;
			$mobileNo=$getUserDatadetails->mobile;
	        $this->custom->sendSms($mobileNo,$body);*/
			/*  /.Sms Code  */
			$resStatus="Failed";
			$type ='Withdraw';
			$statusMessage=$response->message;
			$statusCode=$response->subCode;
			$status='Failed';
			$statusMail ='failed';
			$content='Your withdrawal request of Rs '.$withrawAmt.' has been processed '.$statusMail.' due to '.$response->message.' ,please contact us at ';
           
		}else{
			$resStatus ='Pending';
			$type ='Withdraw';
			$statusMessage=$response->message;
			$statusCode=$response->subCode;
			$status='Pending';
			$statusMail ='pending';
			$content='Your withdrawal request of Rs '.$withrawAmt.' has been processed '.$statusMail.' due to '.$response->message.' ,please contact us at ';
		}
		$saveRefundData = array(
    		'orderId'=>$order_id,
    		'user_detail_id'=>$userId,
    		'paytmStatus'=>$response->status,
    		'statusCode'=>$response->subCode,
    		'statusMessage'=>$response->message,
    		'checkSum'=>"",
    		'type'=>$type,
            'status'=>$resStatus,
            'paymentType'=>'bank',
    		'created'=>date('Y-m-d H:i:s'),
    		'modified'=>date('Y-m-d H:i:s'),
        );
        $saveData = $this->Crud_model->SaveData("user_account",$saveRefundData,'id="'.$userAccId.'"');

        $saveRefundDataLog = array(
        		'user_account_id'=>$userAccId,
        		'orderId'=>$order_id,
    			'amount'=>$withAmt,
    			'balance'=>$userBal->balance,
        		'user_detail_id'=>$userId,
        		'paytmType'=>'byBank',
        		'paytmStatus'=>$response->status,
        		'statusCode'=>$response->subCode,
        		'statusMessage'=>$response->message,
        		'checkSum'=>"",
        		'type'=>$type,
                'status'=>$resStatus,
                'paymentType'=>'bank',
        		'created'=>date('Y-m-d H:i:s'),
        		'modified'=>date('Y-m-d H:i:s'),
        	);
        $saveData = $this->Crud_model->SaveData("user_account_logs",$saveRefundDataLog);
	   	// echo "<pre>"; print_r($response);echo '<br/>';
	    //exit();
	   if($response->status=='ERROR'){
	   		$this->session->set_flashdata('message', '<span>'.$response->message.' </span>'); 
	   }elseif($response->status=='PENDING'){
	   		$this->session->set_flashdata('message', '<span>'.$response->message.'</span>'); 	
	   }else{
	   		$this->session->set_flashdata('message', '<span>'.$response->message.'</span>'); 
	   }
	   curl_close($ch);
	   redirect(site_url(WITHDRAWALDISTRIBUTE.'/'.base64_encode($userAccId)));
	}

	function create_header($token){
    global $header;
    $headers = $header;
    if(!is_null($token)){
        array_push($headers, 'Authorization: Bearer '.$token);
    }
    return $headers;
}

function post_helper($action, $data, $token){
    global $baseurl, $urls;
    $finalUrl = $baseurl.$urls[$action];
    $headers = $this->create_header($token);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_URL, $finalUrl);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch,  CURLOPT_RETURNTRANSFER, true);
    if(!is_null($data)) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data)); 
    
    $r = curl_exec($ch);
    
    if(curl_errno($ch)){
        //print('error in posting');
        //print(curl_error($ch));
        //die();
    }
    curl_close($ch);
    $rObj = json_decode($r, true);    
    if($rObj['status'] != 'SUCCESS' || $rObj['subCode'] != '200') throw new Exception('incorrect response: '.$rObj['message']);
    return $rObj;
}

function get_helper($finalUrl, $token){
    $headers = $this->create_header($token);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $finalUrl);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch,  CURLOPT_RETURNTRANSFER, true);
    
    $r = curl_exec($ch);
   
    if(curl_errno($ch)){
       //// print('error in posting');
       // print(curl_error($ch));
       // die();
    }
    curl_close($ch);

    $rObj = json_decode($r, true);    
    if($rObj['status'] != 'SUCCESS' || $rObj['subCode'] != '200') throw new Exception('incorrect response: '.$rObj['message']);


    return $rObj;
}

#get auth token
function getToken(){
    try{
       $response = $this->post_helper('auth', null, null);
       return $response['data']['token'];
    }
    catch(Exception $ex){
        error_log('error in getting token');
        error_log($ex->getMessage());

       
         return $ex->getMessage();
    }

}

#get beneficiary details
function getBeneficiary($token,$benid1){
    try{
        global $baseurl, $urls, $beneficiary;
        $beneId = $benid1;

        $finalUrl = $baseurl.$urls['getBene'].$beneId;

        $response = $this->get_helper($finalUrl, $token);
         
        return true;
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();

        if(strstr($msg, 'Beneficiary does not exist')) return false;
        error_log('error in getting beneficiary details');
        error_log($msg);
       
        //die();
    }    
}

#add beneficiary
function addBeneficiary($token,$beneficiary1){
    try{
        global $beneficiary;
        $response =$this->post_helper('addBene', $beneficiary1, $token);
        error_log('beneficiary created');
        //print($response);
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in creating beneficiary');
        error_log($msg);
        //print($msg);
      //  die();
    }    
}
#request transfer
function requestTransfer($token,$transfer1){
    try{
        global $transfer;
        $response = $this->post_helper('requestTransfer', $transfer1, $token);
        error_log('transfer requested successfully');
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in requesting transfer');
        error_log($msg);

        //die();
    }
}

#get transfer status
function getTransferStatus($token,$transfer1){
    try{
        global $baseurl, $urls, $transfer;
        $transferId = $transfer1['transferId'];
        $finalUrl = $baseurl.$urls['getTransferStatus'].$transferId;
        $response = $this->get_helper($finalUrl, $token);
        return ($response);
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in getting transfer status');
        error_log($msg);
       // die();
    }
}

	public function wallet_transfer($order_id,$amount,$userMobileNo,$userAccId,$userId,$withrawAmt){
		/*print_r($order_id);echo "<br>";
		print_r($amount);echo "<br>";
		print_r($withrawAmt);echo "<br>";
		print_r($userMobileNo);echo "<br>";
		print_r($userAccId);echo "<br>";
		print_r($userId);echo "<br>";
		exit;*/

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
		$paytmParams["subwalletGuid"] = gratificationGuId;
		//$paytmParams["subwalletGuid"] = '6814a09b-1150-41a3-9f96-7e565b21c21c';
		//$paytmParams["subwalletGuid"] = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";
		//$order_id = rand(00000000000000,99999999999999);
		/* Enter your unique order id, this should be unique for every disbursal */
		$paytmParams["orderId"] = $order_id;
		//$paytmParams["orderId"] = "190202";
		    
		/* Enter Beneficiary Phone Number against which the disbursal needs to be made */
		$paytmParams["beneficiaryPhoneNo"] = $userMobileNo;
		//$paytmParams["beneficiaryPhoneNo"] = '917777777777';

		/* Amount in INR payable to beneficiary */
		$paytmParams["amount"] = $amount;
		$paytmParams["purpose"] = 'OTHERS';
		//$paytmParams["timestamp"] = date("Y-m-d h:i:s");

		/* prepare JSON string for request body */
		$post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
		//echo "<pre>";print_r($post_data);
		/*print_r("https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification");print_r("<br/>");
		print_r($post_data);print_r("<br/>");*/
		/**
		* Generate checksum by parameters we have in body
		* Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
		*/
		$checksum = getChecksumFromString($post_data, gratificationMerchantKey);
		//$checksum = getChecksumFromString($post_data, "uF9cZaNpABsC&Xxa");

		/* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
		$x_mid = gratificationMerchantID;
		
		// echo "<pre> key ";print_r(key);
		// echo "<pre> mid ";print_r(mid);
		//$x_mid = "VIVSON12966438680092";
		//print_r("x-mid : ".$x_mid);print_r("<br/>");	
		/* put generated checksum value here */
		$x_checksum = $checksum;
		//print_r("x-checksum : ".$x_checksum );print_r("<br/>");		
		/* Solutions offered are: food, gift, gratification, loyalty, allowance, communication */

		/* for Staging */
		//$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/{solution}";

		/* for Production */
		 //$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification";
		$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/gratification";
		//$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/bank";
		//echo "<pre> url ";print_r($url);

		$ch = curl_init($url);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$resData = curl_exec($ch);
		//echo "<pre>";print_r($resData);
		$response = json_decode($resData);
			//echo "<pre>"; print_r($response);exit();
		$userBal =$this->Crud_model->GetData("user_details","id,status,balance","id='".$userId."'","","","","1");
		$getPaytmData = $this->Crud_model->GetData("user_account",'','id="'.$userAccId.'"','','','','1');
		//print_r($response);exit;
		if($response->status=='ACCEPTED'){
			$resStatus ='Approved';
			$status ='Approved';
			$statusMail ='successfully';
			$content='Congratulations! Your withdrawal request of Rs '.$withrawAmt.' has been processed '.$statusMail.'. Amount will reflect in your account within 24 working hours, if not then please contact us at ';
			if(!empty($getPaytmData) && $getPaytmData->isAdminReedem=='No'){
				$userData =$this->Crud_model->GetData("user_details","id,status,balance","id='".$userId."'","","","","1"); 
				$getSettData = $this->Crud_model->GetData("mst_settings","id,adminPercent","id='4'",'','','','1');
				$admin_rs=($amount*$getSettData->adminPercent)/100;
				$getAdminData=$this->Crud_model->GetData("admin_login","id,adminBalance","id='".$_SESSION[SESSION_NAME]['id']."'",'','','','1');
				if (!empty($getAdminData->adminBalance)) {
					$adminTotalAmt = $getAdminData->adminBalance + $admin_rs;
				} else {
					$adminTotalAmt = $admin_rs; 
				}
				$updateAdminData = array(
					'adminBalance'=>$adminTotalAmt,
				);

				$this->Crud_model->SaveData("admin_login",$updateAdminData,"id='".$_SESSION[SESSION_NAME]['id']."'");
				$saveAdminLogData = array(
						'user_account_id'=>$userAccId,
						'from_user_details_id'=>$userId,
						'to_admin_login_id'=>$getAdminData->id,
						'percent'=>$getSettData->adminPercent,
						'total_amount'=>$admin_rs,
						'type'=>'deposit',
					);
				$this->Crud_model->SaveData("admin_account_log",$saveAdminLogData);
				/***** Admin Data *****/
				 $approveData = array(
	                'status'=>$status,
	                'isAdminReedem'=>'Yes',
	                'paymentType'=>'paytm',
	                'paytmStatus'=>$response->status,
		    		'statusCode'=>$response->statusCode,
		    		'statusMessage'=>$response->statusMessage,
		    		'checkSum'=>"",
	                'modified'=>date("Y-m-d H:i:s")
	            );
				 $approveDataLog = array(
	                'orderId'=>$order_id,
	                'user_account_id'=>$userAccId,
	                'user_detail_id'=>$userId,
	                'amount'=>$amount,
	                'balance'=>$userBal->balance,
	                'type'=>'Withdraw',
	                'paymentType'=>'paytm',
	                'paytmStatus'=>$response->status,
		    		'statusCode'=>$response->statusCode,
		    		'statusMessage'=>$response->statusMessage,
		    		'checkSum'=>"",
	                'status'=>$status,
	                'created'=>date("Y-m-d H:i:s")
	            );
				$this->Crud_model->SaveData('user_account',$approveData,'id="'.$userAccId.'"');
				//$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');
				$this->Crud_model->SaveData('user_account_logs',$approveDataLog);
				
			}
			
		}elseif($response->status=='FAILURE'){
			$getUserFail = $this->Crud_model->GetData('user_details','email_id,user_name,mobile,balance,winWallet',"id='".$userId."'",'','','','1');
			
			$updateBal =  $getUserFail->balance + $getPaytmData->amount;
			$updatewinWallet =  $getUserFail->winWallet + $getPaytmData->amount;
            $updateUserBal = array(
                'balance'=> $updateBal,
                'winWallet'=> $updatewinWallet,
                );
			$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');
			/*  Sms Code  */
			/*$sms_body=$this->Crud_model->GetData("mst_sms_body","","smsType='refund-reedem-amount'",'','','','1');
	        $sms_body->smsBody=str_replace("{user_name}",ucfirst($getUserFail->user_name),$sms_body->smsBody); 
	        $sms_body->smsBody=str_replace("{amt}",$getPaytmData->amount,$sms_body->smsBody); 
			$sms_body->smsBody=str_replace("{reason}",$response->statusMessage,$sms_body->smsBody);
			$body=$sms_body->smsBody;
			$mobileNo=$getUserFail->mobile;
	        $this->custom->sendSms($mobileNo,$body);*/
			$resStatus ='Failed';
			$status='Failed';
			$statusMail ='failed';
			$content='Your withdrawal request of Rs '.$withrawAmt.' has been processed '.$statusMail.' due to '.$response->statusMessage.' ,please contact us at ';
		}else{
			$getUserFail = $this->Crud_model->GetData('user_details','email_id,user_name,mobile,balance,winWallet',"id='".$userId."'",'','','','1');
			
			$updateBal =  $getUserFail->balance + $getPaytmData->amount;
			$updatewinWallet =  $getUserFail->winWallet + $getPaytmData->amount;
            $updateUserBal = array(
                'balance'=> $updateBal,
                'winWallet'=> $updatewinWallet,
                );
			$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');
			$resStatus ='Failed';
			$status='Failed';
			$statusMail ='failed';
			$content='Your withdrawal request of Rs '.$withrawAmt.' has been processed '.$statusMail.' due to '.$response->statusMessage.' ,please contact us at ';
		}
		$saveRefundUpdate = array(
        		'orderId'=>$order_id,
        		'user_detail_id'=>$getPaytmData->user_detail_id,
        		'paytmStatus'=>$resStatus,
        		'statusCode'=>$response->statusCode,
        		'statusMessage'=>$response->statusMessage,
        		'checkSum'=>$x_checksum,
        		'type'=>'Withdraw',
                'status'=>$status,
                'paymentType'=>'paytm',
        		'modified'=>date('Y-m-d H:i:s'),
        	);
        $saveData = $this->Crud_model->SaveData("user_account",$saveRefundUpdate,'id="'.$userAccId.'"');
        $saveRefundUpdateLog = array(
        		'user_account_id'=>$userAccId,
        		'orderId'=>$order_id,
        		'amount'=>$getPaytmData->amount,
        		'balance'=>$getPaytmData->balance,
        		'user_detail_id'=>$getPaytmData->user_detail_id,
        		'paytmStatus'=>$response->status,
        		'statusCode'=>$response->statusCode,
        		'statusMessage'=>$response->statusMessage,
        		'checkSum'=>$x_checksum,
        		'type'=>'Withdraw',
        		'paymentType'=>'paytm',
                'status'=>$status,
        		'created'=>date('Y-m-d H:i:s'),
        		'modified'=>date('Y-m-d H:i:s'),
        	);
        $saveData = $this->Crud_model->SaveData("user_account_logs",$saveRefundUpdateLog);
        $getUserDAta=$this->Crud_model->GetData('user_details','id,user_name,email_id,mobile',"id='".$userId."'", '', '', '', '1');
        if($getUserDAta){
        	$siteTitle="LUDO FANTACY";
            $mail_to=$getUserDAta->email_id;
            $subject='Redeem on ludo fantacy';
            $mail_body ='<html>
				<head>
					<title></title>
				</head>
				<body>
					<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
				        <tbody><tr>
				            <td valign="top" align="left">
				                <center>
				                    <table cellspacing="0" cellpadding="0" width="600">
				                        <tbody><tr>

				                            <td>

				                                <table cellspacing="0" cellpadding="0" width="100%">
				                                    <tbody><tr>
				                                       <td style="padding: 30.0px 0 10.0px 0;"><img src="http://3.20.220.191/admin/assets/images/profile/AT_8033logo.png" id="" alt="logo" width="120"><br></td>
				                                    </tr>
				                                    <tr>
				                                        <td height="150" valign="top">
				                                            <b>
				                                                <span>'.$siteTitle.'</span>
				                                            </b>
				                                            <br>
				                                            <span><small>'.$siteTitle.' is a dream game project of VIVSON Games Pvt. Ltd.</small></span>
				                                        </td>
				                                    </tr>

				                                    <tr>
				                                        <td style="height: 180.0px;width: 299.0px;">
				                                        </td>
				                                    </tr>
				                                </tbody></table>
				                            </td>

				                            <td valign="top">
				                                <table cellspacing="0" cellpadding="0" width="100%">
				                                    <tbody><tr>
				                                        <td>
				                                            <table cellspacing="0" cellpadding="0" width="100%">
				                                                <tbody><tr>
				                                                    <td>
				                                                        <table cellspacing="0" cellpadding="10" width="100%">
				                                                            <tbody><tr>
				                                                                <td>
				                                                                    <b>Dear '.$getUserDAta->user_name.',</b>
				                                                                </td>
				                                                            </tr>
				                                                        </tbody></table>

				                                                        <table cellspacing="0" cellpadding="10" width="100%">
				                                                            <tbody><tr>
				                                                                <td>
				                                                                    '.$content.' <a href="mailto:support@ludofantasy.com" target="_blank">support@ludofantasy.com</a>
				                                                                    <p><b>Thank you,</b></p>
				                                                                    <p><b><i>Team '.$siteTitle.'</i></b></p>
				                                                                </td>
				                                                            </tr>
				                                                        </tbody></table>
				                                                        
				                                                        <table cellspacing="0" cellpadding="0" width="100%">
				                                                            <tbody><tr>
				                                                                <td style="text-align: center;padding-top: 30.0px;"><img src="http://3.20.220.191/admin/uploads/settings/thank-you.png" id="" alt="signature" width="80px"><br>
				                                                                </td>
				                                                            </tr>
				                                                        </tbody></table>
				                                                        <table cellspacing="0" cellpadding="0" width="100%">
				                                                            <tbody><tr>
				                                                                <td>
				                                                                    <b>
				                                                                        <span>'.$siteTitle.'</span>
				                                                                    </b>
				                                                                    <br>
				                                                                    <span><small>'.$siteTitle.' is a dream game project of VIVSON Games Pvt. Ltd.</small></span>
				                                                                </td>
				                                                            </tr>
				                                                    </tbody></table></td>
				                                                </tr>
				                                            </tbody></table>
				                                        </td>
				                                    </tr>
				                                </tbody></table>
				                            </td>
				                        </tr>
				                    </tbody></table>
				                </center>
				            </td>
				        </tr>
				    </tbody></table>
				</body>
			</html>';
			//print_r($mail_body);exit;
			$this->load->library("Custom");
    		$this->custom->sendEmailSmtp($subject,$mail_body,$mail_to);
        }

    	if($response->status=='ACCEPTED'){
	    	$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>'); 	
	   }elseif($response->status=='FAILURE'){
	   		$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>'); 
	   }else{
	   		$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>');
	   }
	   redirect(site_url(WITHDRAWALDISTRIBUTE.'/'.base64_encode($userAccId)));
	}
	public function checkDisburseStatus($order_id,$userAccId,$userId,$amount)	// Check disburse bank status API
	{
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");		
		require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");	

		/* initialize an array */
		$paytmParams = array();
		$getPaytmData = $this->Crud_model->GetData("user_account",'','id="'.$userAccId.'"','','','','1');
		/* Enter your order id which needs to be check disbursal status for */
		//$order_id = $_REQUEST['order_id'];
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
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
	    curl_close($ch);
	    $userBal =$this->Crud_model->GetData("user_details","id,status,balance","id='".$_POST['userId']."'","","","","1");
	    if($response->status=='SUCCESS' || $response->status=='PENDING'){
	    	//print_r("if");exit;
			$resStatus ='Approved';
			$status='Approved';
			if(!empty($getPaytmData) && $getPaytmData->isAdminReedem=='No'){
				$userData =$this->Crud_model->GetData("user_details","id,status,balance","id='".$userId."'","","","","1"); 
				$getSettData = $this->Crud_model->GetData("mst_settings","id,adminPercent","id='4'",'','','','1');
				$admin_rs=($amount*$getSettData->adminPercent)/100;

				$getAdminData=$this->Crud_model->GetData("admin_login","id,adminBalance","id='".$_SESSION[SESSION_NAME]['id']."'",'','','','1');
				
				if (!empty($getAdminData->adminBalance)) {
					$adminTotalAmt = $getAdminData->adminBalance + $admin_rs;
				} else {
					$adminTotalAmt = $admin_rs; 
				}
				$updateAdminData = array(
					'adminBalance'=>$adminTotalAmt,
				);
				$this->Crud_model->SaveData("admin_login",$updateAdminData,"id='".$_SESSION[SESSION_NAME]['id']."'");
				$saveAdminLogData = array(
						'user_account_id'=>$userAccId,
						'from_user_details_id'=>$userId,
						'to_admin_login_id'=>$getAdminData->id,
						'percent'=>$getSettData->adminPercent,
						'total_amount'=>$admin_rs,
						'type'=>'deposit',
					);
				$this->Crud_model->SaveData("admin_account_log",$saveAdminLogData);
				/***** Admin Data *****/
				 $approveData = array(
	                'status'=>'Approved',
	                'isAdminReedem'=>'Yes',
	                'paymentType'=>'bank',
	                'modified'=>date("Y-m-d H:i:s")
	            );

				 $approveDataLog = array(
	                'orderId'=>$order_id,
	                'user_account_id'=>$userAccId,
	                'user_detail_id'=>$userId,
	                'amount'=>$amount,
	                'balance'=>$userBal->balance,
	                'type'=>'Withdraw',
	                'paymentType'=>'bank',
	                'status'=>'Approved',
	                'created'=>date("Y-m-d H:i:s")
	            );
				
				$this->Crud_model->SaveData('user_account',$approveData,'id="'.$userAccId.'"');
				//$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');
				$this->Crud_model->SaveData('user_account_logs',$approveDataLog);
			}
		}elseif($response->status=='PENDING'){
			$resStatus ='Process';
			$status='Process';
		}elseif($response->status=='FAILURE'){
			//print_r("query");echo "<prev>";
			$getUserDatadetails = $this->Crud_model->GetData('user_details','email_id,user_name,mobile,balance,winWallet',"id='".$userId."'",'','','','1');
			
			$updateBal =  $getUserDatadetails->balance + $getPaytmData->amount;
			$updatewinWallet =  $getUserDatadetails->winWallet + $getPaytmData->amount;
            $updateUserBal = array(
                'balance'=> $updateBal,
                'winWallet'=> $updatewinWallet,
                );
			$this->Crud_model->SaveData('user_details',$updateUserBal,'id="'.$userId.'"');
			/*  Sms Code  */
			/*$sms_body=$this->Crud_model->GetData("mst_sms_body","","smsType='refund-reedem-amount'",'','','','1');
	        $sms_body->smsBody=str_replace("{user_name}",ucfirst($getUserFail->user_name),$sms_body->smsBody); 
	        $sms_body->smsBody=str_replace("{amt}",$getPaytmData->amount,$sms_body->smsBody); 
			$sms_body->smsBody=str_replace("{reason}",$response->statusMessage,$sms_body->smsBody);
			$body=$sms_body->smsBody;
			$mobileNo=$getUserFail->mobile;
	        $this->custom->sendSms($mobileNo,$body);*/
			$resStatus ='Failed';
			$status='Failed';
		}else{
			$resStatus ='Pending';
			$status='Pending';
		}

		$saveRefundUpdate = array(
        		'orderId'=>$order_id,
        		'user_detail_id'=>$getPaytmData->user_detail_id,
        		'paytmStatus'=>$resStatus,
        		'statusCode'=>$response->statusCode,
        		'statusMessage'=>$response->statusMessage,
        		'checkSum'=>$x_checksum,
        		'type'=>'Withdraw',
                'status'=>$status,
                'paymentType'=>'bank',
        		'modified'=>date('Y-m-d H:i:s'),
        	);
        $saveData = $this->Crud_model->SaveData("user_account",$saveRefundUpdate,'id="'.$userAccId.'"');
        $saveRefundUpdateLog = array(
        		'user_account_id'=>$userAccId,
        		'orderId'=>$order_id,
        		'amount'=>$getPaytmData->amount,
        		'balance'=>$getPaytmData->balance,
        		'user_detail_id'=>$getPaytmData->user_detail_id,
        		'paytmType'=>'byQuery',
        		'paytmStatus'=>$response->status,
        		'statusCode'=>$response->statusCode,
        		'statusMessage'=>$response->statusMessage,
        		'checkSum'=>$x_checksum,
        		'type'=>'Withdraw',
        		'paymentType'=>'bank',
                'status'=>$status,
        		'created'=>date('Y-m-d H:i:s'),
        		'modified'=>date('Y-m-d H:i:s'),
        	);
        $saveData = $this->Crud_model->SaveData("user_account_logs",$saveRefundUpdateLog);
		//print_r($resStatus);exit();
       if($response->status=='SUCCESS'){
	    	$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>'); 	
	   }elseif($response->status=='PENDING'){
	   		$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>'); 
	   }elseif($response->status=='FAILURE'){
	   		$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>'); 
	   }else{
	   		$this->session->set_flashdata('message', '<span>'.$response->statusMessage.'</span>');
	   }
	   redirect(site_url(WITHDRAWALDISTRIBUTE.'/'.base64_encode($userAccId)));
	}
}