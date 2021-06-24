<?php
defined('BASEPATH') OR exit('No direct script access allowed');
require_once(APPPATH."libraries/razorpay/razorpay-php/Razorpay.php");
include APPPATH . 'libraries/razorpay/razorpay-php/Razorpay.php';
use Razorpay\Api\Api;
use Razorpay\Api\Errors\SignatureVerificationError;

class Register extends CI_Controller {
  /**
   * This function loads the registration form
   */
  public function index()
  {
    
  }
  /**
   * This function creates order and loads the payment methods
   */
  public function pay($orderId,$coustomerId,$amount)
  {
    $api = new Api('rzp_test_zmTJmclxgissS7', 'mSPlSYb5xLQZARJ1MQIAVAPF');
    /**
     * You can calculate payment amount as per your logic
     * Always set the amount from backend for security reasons
     */
    $_SESSION['user_id'] = $coustomerId;
    $_SESSION['payable_amount'] = $amount;
    $razorpayOrder = $api->order->create(array(
      'receipt'         => rand(),
      'amount'          => $_SESSION['payable_amount'] * 100, // 2000 rupees in paise
      'currency'        => 'INR',
      'payment_capture' => 1 // auto capture
    ));
    $amount = $razorpayOrder['amount'];
    $razorpayOrderId = $razorpayOrder['id'];
    $_SESSION['razorpay_order_id'] = $razorpayOrderId;
    $data = $this->prepareData($amount,$razorpayOrderId);
    $this->load->view('rezorpay',array('data' => $data));
  }
  /**
   * This function verifies the payment,after successful payment
   */
  public function verify()
  {
    $success = true;
    $error = "payment_failed";
    if (empty($_POST['razorpay_payment_id']) === false) {
      $api = new Api('rzp_test_zmTJmclxgissS7', 'mSPlSYb5xLQZARJ1MQIAVAPF');
    try {
        $attributes = array(
          'razorpay_order_id' => $_SESSION['razorpay_order_id'],
          'razorpay_payment_id' => $_POST['razorpay_payment_id'],
          'razorpay_signature' => $_POST['razorpay_signature']
        );
        $api->utility->verifyPaymentSignature($attributes);
      } catch(SignatureVerificationError $e) {
        $success = false;
        $error = 'Razorpay_Error : ' . $e->getMessage();
      }
    }
    if ($success === true) {
      $json_data = json_encode($_POST);
      $customer_id = $_SESSION['user_id'];
		        $PaymentLog = array(
		          'transaction_id' => $_POST['razorpay_payment_id'],
		          'isPayment' => "Yes",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
		        $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_SESSION['razorpay_order_id']."'");
		        $saveuserData = array(
		        		'transactionId'=>$_POST['razorpay_payment_id'],
		        		'orderId'=>$_SESSION['razorpay_order_id'],
		        		'amount'=>$_SESSION['payable_amount'],
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
		        		'transactionId'=>$_POST['razorpay_payment_id'],
		        		'user_account_id'=>$last_insertedId,
		        		'orderId'=>$_SESSION['razorpay_order_id'],
		        		'amount'=>$_SESSION['payable_amount'],
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
		        	$totalCoins= $getUserData->balance + $_SESSION['payable_amount'];
              $mainWallet= $getUserData->mainWallet + $_SESSION['payable_amount'];
		        	$data=array(
		        		"balance"=>$totalCoins,
                "mainWallet"=>$mainWallet,
		        	);
		        	$this->Crud_model->SaveData("user_details",$data, "user_id='".$customer_id."'");
		        }
		        redirect('Welcome/PaymentDone/1');
		        print_r('Payment Done ');exit;
      $this->setRegistrationData();
      redirect('Welcome/PaymentDone/1');
		        print_r('Payment Done ');exit;
      
    }
    else {
      if(!empty($_POST))
			{
				$json_data = json_encode($_POST);
					
		        $PaymentLog = array(
		          'transaction_id' => $_SESSION['razorpay_order_id'],
		          'isPayment' => "No",
		          'json_data' => $json_data,
		          'modified' => date('Y-m-d H:i:s'),
		         );
			    $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_SESSION['razorpay_order_id']."'");
				redirect('Welcome/PaymentDone/0');
				print_r('Payment Failed ');exit;	
			}
			else{
				redirect('Welcome/PaymentDone/0');
				print_r('Payment Failed ');exit;	
			}
      redirect(base_url().'register/paymentFailed');
    }
    redirect('Welcome/PaymentDone/0');
				print_r('Payment Failed ');exit;
  }
  /**
   * This function preprares payment parameters
   * @param $amount
   * @param $razorpayOrderId
   * @return array
   */
  public function prepareData($amount,$razorpayOrderId)
  {
    $data = array(
      "key" => 'rzp_test_zmTJmclxgissS7',
      "amount" => $amount,
      "name" => "Ludo Cash",
      "description" => "Learn To Code",
      
      "prefill" => array(
        "name"  => $this->input->post('name'),
        "email"  => $this->input->post('email'),
        "contact" => $this->input->post('contact'),
      ),
      "notes"  => array(
        "address"  => "Hello World",
        "merchant_order_id" => rand(),
      ),
      "theme"  => array(
        "color"  => "#F37254"
      ),
      "order_id" => $razorpayOrderId,
    );
    return $data;
  }
  /**
   * This function saves your form data to session,
   * After successfull payment you can save it to database
   */
  public function setRegistrationData()
  {
    $name = $this->input->post('name');
    $email = $this->input->post('email');
    $contact = $this->input->post('contact');
    $amount = $_SESSION['payable_amount'];
    $registrationData = array(
      'order_id' => $_SESSION['razorpay_order_id'],
      'name' => $name,
      'email' => $email,
      'contact' => $contact,
      'amount' => $amount,
    );
    // save this to database
  }
  /**
   * This is a function called when payment successfull,
   * and shows the success message
   */
  public function success()
  {
    echo "Success";
    print_r($_REQUEST);
    print_r($_SESSION);
  }
  /**
   * This is a function called when payment failed,
   * and shows the error message
   */
  public function paymentFailed()
  {
    echo "Faield";
    print_r($_REQUEST);
    print_r($_SESSION);
  }  
}