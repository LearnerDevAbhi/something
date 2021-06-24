<?php
defined('BASEPATH') OR exit('No direct script access allowed');
require_once(APPPATH."libraries/razorpay/razorpay-php/Razorpay.php");
include APPPATH . 'libraries/razorpay/razorpay-php/Razorpay.php';
use Razorpay\Api\Api;
use Razorpay\Api\Errors\SignatureVerificationError;
class Razorpay extends CI_Controller {
  /**
   * This function loads the registration form
   */
  public function index()
  {
    echo base_url("img/logo_large.png");
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
    $amount = $amount;
    $_SESSION['payable_amount'] = $amount;
    $razorpayOrder = $api->order->create(array(
      'receipt'         => rand(),
      'amount'          => $_SESSION['payable_amount'] * 100, // 2000 rupees in paise
      'currency'        => 'INR',
      'payment_capture' => 1 // auto capture
    ));
    //$razorpayOrder=$orderId;
    $amount = $razorpayOrder['amount'];
    $razorpayOrderId = $razorpayOrder['id'];

    $_SESSION['razorpay_order_id'] = $razorpayOrderId;

    $data = array(
      "key" => 'rzp_test_zmTJmclxgissS7',
      "amount" => 20,
      "name" => "Ludo Cash",
      "description" => "",
      "image" => "http://13.233.233.105/PhpApis/img/logo_large.png",
      
      "notes"  => array(
        "address"  => "Hello World",
        "merchant_order_id" => $coustomerId,
      ),
      "theme"  => array(
        "color"  => "#F37254"
      ),
      "order_id" => $razorpayOrderId,
    );
    $isGoToPayment="Yes";
				if(empty($isCoupan)){ $isCoupan = "No";}
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
    $this->load->view('rezorpay',array('data' => $data));
  }
  // public function pay($amount,$coustomerId)
  // {
  //   $api = new Api('rzp_test_zmTJmclxgissS7', 'mSPlSYb5xLQZARJ1MQIAVAPF');
  //   /**
  //    * You can calculate payment amount as per your logic
  //    * Always set the amount from backend for security reasons
  //    */
  //   $amount = base64_decode($amount);
  //   $_SESSION['payable_amount'] = $amount;
  //   $razorpayOrder = $api->order->create(array(
  //     'receipt'         => rand(),
  //     'amount'          => $_SESSION['payable_amount'] * 100, // 2000 rupees in paise
  //     'currency'        => 'INR',
  //     'payment_capture' => 1 // auto capture
  //   ));
  //   $amount = $razorpayOrder['amount'];
  //   $razorpayOrderId = $razorpayOrder['id'];

  //   $_SESSION['razorpay_order_id'] = $razorpayOrderId;

  //   $data = array(
  //     "key" => 'rzp_test_zmTJmclxgissS7',
  //     "amount" => $amount,
  //     "name" => "Ludo Cash",
  //     "description" => "",
  //     "image" => "http://13.233.233.105/PhpApis/img/logo_large.png",
      
  //     "notes"  => array(
  //       "address"  => "Hello World",
  //       "merchant_order_id" => $coustomerId,
  //     ),
  //     "theme"  => array(
  //       "color"  => "#F37254"
  //     ),
  //     "order_id" => $razorpayOrderId,
  //   );
  //   $isGoToPayment="Yes";
	// 			if(empty($isCoupan)){ $isCoupan = "No";}
	// 			if($isCoupan=="Yes"){
	// 				$getcoupanCode = $this->Crud_model->GetData('coupon_codes','','couponCode="'.$coupanCode.'" and isUsed="No"');
	// 				if(!empty($getcoupanCode)){
	// 					$coupanData=array(
	// 		        		"isUsed"=>'Yes',
	// 		        	);
	// 		        	$this->Crud_model->SaveData("coupon_codes",$coupanData, "couponCode='".$coupanCode."'");
	// 		        	$amount = $amount - $getcoupanCode[0]->discount;
	// 					$isGoToPayment="Yes";
	// 					$Data['coupanCode'] =$coupanCode;
	// 					$Data['discountAmount'] =$getcoupanCode[0]->discount;
	// 					$Data['discount'] =$getcoupanCode[0]->discount;
	// 					$Data['isCoupan'] ='Yes';
	// 				}else{
	// 					$isGoToPayment="No";						
	// 				}
	// 			}
  //   $this->load->view('rezorpay',array('data' => $data));
  // }
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
      /**
       * Call this function from where ever you want
       * to save save data before of after the payment
       */
      $this->setRegistrationData();
      redirect(base_url().'register/success');
    }
    else {
      redirect(base_url().'register/paymentFailed');
    }
  }
  /**
   * This function preprares payment parameters
   * @param $amount
   * @param $razorpayOrderId
   * @return array
   */
  public function prepareData($amount,$razorpayOrderId,$name,$email,$contact)
  {
    $data = array(
      "key" => 'rzp_test_zmTJmclxgissS7',
      "amount" => $amount,
      "name" => "Saurabh",
      "description" => "For play",
      "image" => "https://demo.codingbirdsonline.com/website/img/coding-birds-online/coding-birds-online-favicon.png",
      "prefill" => array(
        "name"  => $name,
        "email"  => $email,
        "contact" => $contact,
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
    // $this->load->view('success');
  }
  /**
   * This is a function called when payment failed,
   * and shows the error message
   */
  public function paymentFailed()
  {
    $this->load->view('error');
  }  
}