<?php
defined('BASEPATH') OR exit('No direct script access allowed');

date_default_timezone_set("Asia/Calcutta");

class Paytm extends CI_Controller 
{
	public function __construct()
    {
        parent::__construct();
    }

	public function pay_by_paytm($orderId,$customer_id,$amount)
	{
		$getOrderId = $this->Crud_model->GetData('orders','','orderId="'.$orderId.'"');
		if(!empty($getOrderId)){
			redirect('Welcome/PaymentDone/2');
		}
		if(!empty($orderId) && !empty($customer_id) && !empty($amount))
		{
			$Data = array(
				'customer_id' => $customer_id,
	            'orderId' => $orderId,
				'amount' => $amount,
				'paymentMode' => 'Paytm',	
				'created' =>date('Y-m-d H:i:s'),
			    );
		   
			$saveData = $this->Crud_model->SaveData('orders',$Data);
			$_POST["customer_id"] = $customer_id;
			header("Pragma: no-cache");
	 		header("Cache-Control: no-cache");
	  		header("Expires: 0");
	   
		    // following files need to be included
		    require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
		    require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");	
				
			$paramList["MID"] = PAYTM_MERCHANT_MID;
		
			$paramList["ORDER_ID"] = $orderId;
			$paramList["CUST_ID"] = $customer_id;
			$paramList["INDUSTRY_TYPE_ID"] = 'Retail';// For Live Retail109
			$paramList["CHANNEL_ID"] = 'WEB';
			//$paramList["TXN_AMOUNT"] = $amount;//$final_amount
			 $paramList["TXN_AMOUNT"] = $amount; 
			
			$paramList["WEBSITE"] = PAYTM_MERCHANT_WEBSITE;
			$paramList["CALLBACK_URL"] = base_url('index.php/Paytm/checkPayment/'.$customer_id);
			$paramList["MSISDN"] = ''; //Mobile number of customer
			$paramList["EMAIL"] = '';//Email ID of customer
			$checkSum = getChecksumFromArray($paramList,PAYTM_MERCHANT_KEY);
			//$action = PAYTM_TXN_URL;

			echo "<html>
			<head>
			<title>Merchant Check Out Page</title>
			</head>
			<body>
			    <center><h1>Please do not refresh this page...</h1></center>
			        <form method='post' action='".PAYTM_TXN_URL."' name='f1'>
			<table border='1'>
			<tbody>";

			foreach($paramList as $name => $value) {
			echo '<input type="hidden" name="'. $name .'" value="'. $value .'">';
			}

			echo "<input type='hidden' name='CHECKSUMHASH' value='". $checkSum ."'>
			</tbody>
			</table>
			<script type='text/javascript'>
			 document.f1.submit();
			</script>
			</form>
			</body>
			</html>";
		}
		else
		{
			print_r('Insufficient parameters, Kindly uppdate with parameters');exit;
		}
	}

	public function checkPayment($customer_id)
	{
		//print_r($customer_id);exit()
		header("Pragma: no-cache");
		header("Cache-Control: no-cache");
		header("Expires: 0");
	    // following files need to be included
	    require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
	    require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");
	    $paytmChecksum = "";
		$paramList = array();
		$isValidChecksum = "FALSE";
		$paramList = $_POST;
		$paytmChecksum = isset($_POST["CHECKSUMHASH"]) ? $_POST["CHECKSUMHASH"] : "";
		$isValidChecksum = verifychecksum_e($paramList, PAYTM_MERCHANT_KEY, $paytmChecksum); //will return TRUE or FALSE string.
		
		if($isValidChecksum == "TRUE") 
		{
			if($_POST["STATUS"] == "TXN_SUCCESS"){
		    	$json_data = json_encode($_POST);
					
		        $PaymentLog = array(
		          'transaction_id' => $_POST['TXNID'],
		          'isPayment' => "Yes",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
		        $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_POST['ORDERID']."'");
		        $saveuserData = array(
		        		'transactionId'=>$_POST['TXNID'],
		        		'orderId'=>$_POST['ORDERID'],
		        		'amount'=>$_POST['TXNAMOUNT'],
		        		'user_detail_id'=>$customer_id,
		        		'type'=>'Deposit',
		        		'status'=>'Success',
		        		//'status'=>'Pending',
		        		'created'=>date('Y-m-d H:i:s'),
		        		'modified'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account",$saveuserData);
		        //print_r($this->db->last_query());exit;
		        $last_insertedId= $this->db->insert_id();
		        $saveuserDataLog = array(
		        		'transactionId'=>$_POST['TXNID'],
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$_POST['ORDERID'],
		        		'amount'=>$_POST['TXNAMOUNT'],
		        		'user_detail_id'=>$customer_id,
		        		'type'=>'Deposit',
		        		'status'=>'Success',
		        		//'status'=>'Pending',
		        		'created'=>date('Y-m-d H:i:s'),
		        	);
		        $this->Crud_model->SaveData("user_account_logs",$saveuserDataLog);
		        $getUserData = $this->Crud_model->GetData("user_details","","user_id='".$customer_id."'","","","","1");
		       	// print_r($saveuserData);exit();
		       	//  echo "<pre>"; 
		        if ($getUserData) {
		        	$totalCoins= $getUserData->balance + $_POST['TXNAMOUNT'];
		        	$data=array(
		        		"balance"=>$totalCoins,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        redirect('Welcome/PaymentDone/1');
		        print_r('Payment Done ');exit;
			}
			else
			{				
				if(isset($_POST['TXTID'])){
					$json_data = json_encode($_POST);
						
			        $PaymentLog = array(
			          'transaction_id' => $_POST['TXNID'],
			          'isPayment' => "No",
			          'json_data' => $json_data,
			          'modified' => date('Y-m-d H:i:s'),
			         );
			        $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_POST['ORDERID']."'");
			        redirect('Welcome/PaymentDone/0');
					print_r('Payment Failed ');exit;
					}
				else{
					redirect('Welcome/PaymentDone/0');
					print_r('Payment Failed ');exit;	
				}
			} 
		}
		else 
		{
			if(!empty($_POST))
			{
				$json_data = json_encode($_POST);
					
		        $PaymentLog = array(
		          'transaction_id' => $_POST['TXNID'],
		          'isPayment' => "No",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
			    $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_POST['ORDERID']."'");
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
		//echo "checksum <pre>"; print_r($checksum);echo '<br/>';

		/* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
		//$x_mid = "AagamE55778795707048";
		$x_mid = mid;//"AagamE15178612468400";

		/* put generated checksum value here */
		$x_checksum = $checksum;
		// echo "x_checksum <pre>"; print_r($x_checksum);echo '<br/>';

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
		curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json", "x-mid: " . $x_mid, "x-checksum: " . $x_checksum)); 
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
		$response = curl_exec($ch);
		$response = curl_error($ch) ? curl_error($ch) : $response;
		$response = json_decode($response);
		//print_r($response);exit;
		
	    print_r($response);exit();
	    curl_close($ch);
	}
}