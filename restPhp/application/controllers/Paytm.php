<?php
defined('BASEPATH') OR exit('No direct script access allowed');
error_reporting(0);
ini_set('display_errors', 0);
date_default_timezone_set("Asia/Calcutta");

class Paytm extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        $this->load->helper('custom_helper');
        $this->load->library('email');
        $this->load->library('Custom');
        $config['protocol'] = 'sendmail';
        $config['mailpath'] = '/usr/sbin/sendmail';
        $config['charset']  = 'iso-8859-1';
        $config['wordwrap'] = TRUE;
    }
    
    public function pay_by_paytm($orderId, $customer_id, $amount)
    {
          require_once("PaytmChecksum.php");
        //http://3.7.61.227/r-rummy/restPhp/index.php/Paytm/pay_by_paytm/order12345678/8/5
        if (isset($orderId) && isset($customer_id) && isset($amount)) {
            $getOrderId = $this->Crud_model->GetData('orders', '', 'orderId="' . $orderId . '"');
            if (!empty($getOrderId) && $getOrderId=='test') {
                redirect('Welcome/payMentSucces/2');
            } else 
            if (!empty($orderId) && !empty($customer_id) && !empty($amount)) {
                $saveuserData         = array(
                    'orderId' => $orderId,
                    'amount' => $amount,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Pending',
                    'paymentType' => 'Paytm',
                    'created' => date('Y-m-d H:i:s'),
                    'modified' => date('Y-m-d H:i:s')
                );
               $this->Crud_model->SaveData("orders",$saveuserData);
            
   
                $_POST["customer_id"] = $customer_id;
                header("Pragma: no-cache");
                header("Cache-Control: no-cache");
                header("Expires: 0");
                
                // following files need to be included
                require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
                require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");

                 $paytmParams = array();

                $paytmParams["body"] = array(
                    "requestType"   => "Payment",
                    "mid"           => PAYTM_MERCHANT_MID,
                    "websiteName"   => PAYTM_MERCHANT_WEBSITE,
                    "orderId"       => $orderId,
                    "callbackUrl"   => base_url('index.php/Paytm/callurl/' . $orderId),
                    "txnAmount"     => array(
                         "value"     => $amount,
                         "currency"  => "INR",
                        ),
                    "userInfo"      => array(
                         "custId"    => $customer_id,
                    ),
                );

/*
* Generate checksum by parameters we have in body
* Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
*/
            $checksum = PaytmChecksum::generateSignature(json_encode($paytmParams["body"], JSON_UNESCAPED_SLASHES), PAYTM_MERCHANT_KEY);

                $paytmParams["head"] = array(
                 "signature" => $checksum
            );

            $post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);

            $txt =  $txt."------------". $post_data;
         //$txt1 = json_decode($post_data);
        //$myfile1 = file_put_contents('logs1.txt', $txt1.PHP_EOL , FILE_APPEND | LOCK_EX);

            /* for Staging */
            $url = "https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?mid=".PAYTM_MERCHANT_MID."&orderId=".$orderId;

            /* for Production */
            // $url = "https://securegw.paytm.in/theia/api/v1/initiateTransaction?mid=YOUR_MID_HERE&orderId=ORDERID_98765";

            $ch = curl_init($url);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
            curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json")); 
            $response = curl_exec($ch);

            $jsonDecodeData = json_decode($response, true);

               $txt =  $txt."==========".$response;
               $myfile = file_put_contents('logs.txt', $txt.PHP_EOL , FILE_APPEND | LOCK_EX);

            $url1="https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid=".PAYTM_MERCHANT_MID."&orderId=".$orderId;
            echo "<html>
            <head>
            <title>Merchant Check Out Page</title>
            </head>
            <body>
                <center><h1>Please do not refresh this page...</h1></center>
                    <form method='post' action='".$url1."' name='paytm'>
            <table border='1'>
            <tbody>";

             echo "<input type='hidden' name='mid' value='".PAYTM_MERCHANT_MID."'>
                 <input type='hidden' name='orderId' value='".$orderId."'>
                 <input type='hidden' name='txnToken' value='".$jsonDecodeData["body"]["txnToken"]."'>";

            echo "
            </tbody>
            </table>
            <script type='text/javascript'>
             document.paytm.submit();
            </script>
            </form>
            </body>
            </html>";

             
               
            } else {
                print_r('Insufficient parameters, Kindly uppdate with parameters');
                exit;
            }
        } else {
            print_r('Required parameters missing, Kindly uppdate with parameters');
            exit;
        }
    }



     public function callurl($orderId){


       //  $txt = json_decode($_POST);
       // $myfile = file_put_contents('logs.txt', $txt.PHP_EOL , FILE_APPEND | LOCK_EX);
            //print_r($orderId.'-'.$_POST);
           /*$url1="https://securegw-stage.paytm.in/theia/api/v1/showPaymentPage?mid=".PAYTM_MERCHANT_MID."&orderId=".$orderId;
            echo "<html>
            <head>
            <title>Merchant Check Out Page</title>
            </head>
            <body>
                <center><h1>Please do not refresh this page...</h1></center>
                    <form method='post' action='".$url1."' name='paytm'>
            <table border='1'>
            <tbody>";

             echo "<input type='hidden' name='mid' value='".PAYTM_MERCHANT_MID."'>
                 <input type='hidden' name='orderId' value='".$orderId."'>
                 <input type='hidden' name='txnToken' value='".$_POST["body"]["txnToken"]."'>";

            echo "
            </tbody>
            </table>
            <script type='text/javascript'>
             document.paytm.submit();
            </script>
            </form>
            </body>
            </html>";*/


     }

     public function checkPayment1($customer_id)
    {}
    
    public function checkPayment($customer_id)
    {

        
        header("Pragma: no-cache");
        header("Cache-Control: no-cache");
        header("Expires: 0");
        // following files need to be included
        require_once(APPPATH . "/third_party/paytmlib/config_paytm.php");
        require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");
        $paytmChecksum   = "";
        $paramList       = array();
        $isValidChecksum = "FALSE";
        $paramList       = $_POST;
        $paytmChecksum   = isset($_POST["CHECKSUMHASH"]) ? $_POST["CHECKSUMHASH"] : "";
        $isValidChecksum = verifychecksum_e($paramList, PAYTM_MERCHANT_KEY, $paytmChecksum); //will return TRUE or FALSE string.
       // http://3.7.61.227/r-rummy/restPhp/index.php/Paytm/pay_by_paytm/order12345678/8/5

// print_r($_POST);
// print_r($isValidChecksum);
// exit();
        if ($isValidChecksum == "TRUE" || $isValidChecksum=='1') {
            if ($_POST["STATUS"] == "TXN_SUCCESS") {
                $json_data = json_encode($_POST);
                
                $PaymentLog = array(
                    'transactionId' => $_POST['TXNID'],
                    'isPayment' => "Yes",
                    'json_data' => $json_data,
                    'modified' => date('Y-m-d H:i:s')
                );
                
                
                // $getOrderId = $this->Crud_model->GetData('user_account', '', 'orderId="' . $orderId . '"');
                
                // if (!empty($getOrderId)) {
                //     redirect('Welcome/payMentSucces/2');
                // } else {
                    
                    
                    $this->Crud_model->SaveData("orders", $PaymentLog, "orderId='" . $_POST['ORDERID'] . "'");
                    $getUserData = $this->Crud_model->GetData("user_details", "", "id='".$customer_id."'", "", "", "", "1");
                   
                    //  echo "<pre>"; 
                    if ($getUserData) {
                        $totalCoins = $getUserData->coins + $_POST['TXNAMOUNT'];
                        $mainWallet = $getUserData->mainWallet + $_POST['TXNAMOUNT'];
                        $data       = array(
                            "coins" => $totalCoins,
                            "mainWallet" => $mainWallet
                        );
                        $this->Crud_model->SaveData("user_details", $data, "id='" . $customer_id . "'");
                    }
                    $saveuserData = array(
                        'transactionId' => $_POST['TXNID'],
                        'orderId' => $_POST['ORDERID'],
                        'amount' => $_POST['TXNAMOUNT'],
                        'balance' => $getUserData->coins + $_POST['TXNAMOUNT'],
                        'mainWallet' => $getUserData->mainWallet + $_POST['TXNAMOUNT'],
                        'user_detail_id' => $customer_id,
                        'type' => 'Deposit',
                        'status' => 'Success',
                        'paymentType' => 'paytm',
                        'created' => date('Y-m-d H:i:s'),
                        'modified' => date('Y-m-d H:i:s')
                    );
                    $this->Crud_model->SaveData("user_account", $saveuserData);
                    //print_r($this->db->last_query());exit;
                    $last_insertedId = $this->db->insert_id();
                    $saveuserDataLog = array(
                        'transactionId' => $_POST['TXNID'],
                        'user_account_id' => $last_insertedId,
                        'orderId' => $_POST['ORDERID'],
                        'amount' => $_POST['TXNAMOUNT'],
                        'balance' => $getUserData->coins + $_POST['TXNAMOUNT'],
                        'mainWallet' => $getUserData->mainWallet + $_POST['TXNAMOUNT'],
                        'user_detail_id' => $customer_id,
                        'type' => 'Deposit',
                        'status' => 'Success',
                        'paymentType' => 'paytm',
                        'created' => date('Y-m-d H:i:s')
                    );
                    $this->Crud_model->SaveData("user_account_logs", $saveuserDataLog);
                    
                    redirect('Welcome/payMentSucces/1');
               // }
                print_r('Payment Done ');
                exit;
            } elseif ($_POST["STATUS"] == "PENDING") {
                $getUserData = $this->Crud_model->GetData("user_details", "", "user_id='" . $customer_id . "'", "", "", "", "1");
                // print_r($saveuserData);exit();
                //  echo "<pre>"; 
                if ($getUserData) {
                    $totalCoins = $getUserData->coins;
                    $mainWallet = $getUserData->mainWallet;
                    $data       = array(
                        "coins" => $totalCoins,
                        "mainWallet" => $mainWallet
                    );
                    $this->Crud_model->SaveData("user_details", $data, "user_id='" . $customer_id . "'");
                }
                $saveuserData = array(
                    'transactionId' => $_POST['TXNID'],
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Pending',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s'),
                    'modified' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account", $saveuserData);
                //print_r($this->db->last_query());exit;
                $last_insertedId = $this->db->insert_id();
                $saveuserDataLog = array(
                    'transactionId' => $_POST['TXNID'],
                    'user_account_id' => $last_insertedId,
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Pending',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account_logs", $saveuserDataLog);
                
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');
                exit;
            } else {
                $getUserData = $this->Crud_model->GetData("user_details", "", "user_id='" . $customer_id . "'", "", "", "", "1");
                // print_r($saveuserData);exit();
                //  echo "<pre>"; 
                if ($getUserData) {
                    $totalCoins = $getUserData->coins;
                    $mainWallet = $getUserData->mainWallet;
                    $data       = array(
                        "coins" => $totalCoins,
                        "mainWallet" => $mainWallet
                    );
                    $this->Crud_model->SaveData("user_details", $data, "user_id='" . $customer_id . "'");
                }
                $saveuserData = array(
                    'transactionId' => $_POST['TXNID'],
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Failed',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s'),
                    'modified' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account", $saveuserData);
                //print_r($this->db->last_query());exit;
                $last_insertedId = $this->db->insert_id();
                $saveuserDataLog = array(
                    'transactionId' => $_POST['TXNID'],
                    'user_account_id' => $last_insertedId,
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Failed',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account_logs", $saveuserDataLog);
                
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');
                exit;
                /*if(isset($_POST['TXTID'])){
                $json_data = json_encode($_POST);
                
                $PaymentLog = array(
                'transaction_id' => $_POST['TXNID'],
                'isPayment' => "No",
                'json_data' => $json_data,
                'modified' => date('Y-m-d H:i:s'),
                );
                $this->Crud_model->SaveData("orders",$PaymentLog, "orderId='".$_POST['ORDERID']."'");
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');exit;
                }
                else{
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');exit;    
                }*/
            }
        } else {
            if (!empty($_POST)) {
                $json_data = json_encode($_POST);
                
                $PaymentLog = array(
                    'transaction_id' => $_POST['TXNID'],
                    'isPayment' => "No",
                    'json_data' => $json_data,
                    'modified' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("orders", $PaymentLog, "orderId='" . $_POST['ORDERID'] . "'");
                $getUserData = $this->Crud_model->GetData("user_details", "", "user_id='" . $customer_id . "'", "", "", "", "1");
                // print_r($saveuserData);exit();
                //  echo "<pre>"; 
                if ($getUserData) {
                    $totalCoins = $getUserData->coins;
                    $mainWallet = $getUserData->mainWallet;
                    $data       = array(
                        "coins" => $totalCoins,
                        "mainWallet" => $mainWallet
                    );
                    $this->Crud_model->SaveData("user_details", $data, "user_id='" . $customer_id . "'");
                }
                $saveuserData = array(
                    'transactionId' => $_POST['TXNID'],
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Failed',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s'),
                    'modified' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account", $saveuserData);
                //print_r($this->db->last_query());exit;
                $last_insertedId = $this->db->insert_id();
                $saveuserDataLog = array(
                    'transactionId' => $_POST['TXNID'],
                    'user_account_id' => $last_insertedId,
                    'orderId' => $_POST['ORDERID'],
                    'amount' => $_POST['TXNAMOUNT'],
                    'balance' => $getUserData->coins,
                    'mainWallet' => $getUserData->mainWallet,
                    'user_detail_id' => $customer_id,
                    'type' => 'Deposit',
                    'status' => 'Failed',
                    'paymentType' => 'paytm',
                    'created' => date('Y-m-d H:i:s')
                );
                $this->Crud_model->SaveData("user_account_logs", $saveuserDataLog);
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');
                exit;
            } else {
                redirect('Welcome/payMentSucces/0');
                print_r('Payment Failed ');
                exit;
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    public function disburseFund() // Creation of disburse Bank Transfer API.
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
        $paytmParams["subwalletGuid"] = guid; //"97d2a3d6-f3bd-44e9-80de-c8a6dc89e7bc"; //GUID of AJAY
        
        /* Enter your unique order id, this should be unique for every disbursal */
        //$orderRand = rand(11111,99999);
        //$orderRand = 73387;
        
        $date                   = date('Y-m-d');
        $time                   = date('H:i:s');
        $paytmParams["orderId"] = $_REQUEST['order_id'];
        
        /* Enter Beneficiary Phone Number against which the disbursal needs to be made */
        //$paytmParams["beneficiaryPhoneNo"] = 8421491235;
        
        /* Amount in INR payable to beneficiary */
        //$paytmParams["beneficiaryAccount"] = 919899996782;
        //$paytmParams["beneficiaryIFSC"] = 'PYTM0123456';
        //$paytmParams["beneficiaryAccount"] = 919890800533;
        //$paytmParams["beneficiaryIFSC"] = 'HDFC0002746';
        //$paytmParams["beneficiaryAccount"] = 300000002448;    Invalid Account details
        //$paytmParams["beneficiaryIFSC"] = 'PYTM0123456';        Invalid Account details
        $paytmParams["beneficiaryAccount"] = $_REQUEST['beneficiaryAccount']; //20195656312;
        $paytmParams["beneficiaryIFSC"]    = $_REQUEST['beneficiaryIFSC']; //'MAHB0000303';
        $amount                            = $_REQUEST['amount']; //23;
        $paytmParams["amount"]             = $amount;
        $paytmParams["purpose"]            = 'BONUS'; //'BONUS';
        $paytmParams["date"]               = $date;
        $paytmParams["requestTimestamp"]   = $time;
        
        /* prepare JSON string for request body */
        $post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
        
        //echo "post_data <pre>"; print_r($post_data);echo '<br/>';
        /**
         * Generate checksum by parameters we have in body
         */
        $checksum = getChecksumFromString($post_data, key); //iwpS9miFa%K0!x1L
        echo "checksum <pre>";
        print_r($checksum);
        echo '<br/>';
        
        /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        //$x_mid = "AagamE55778795707048";
        $x_mid = mid; //"AagamE15178612468400";
        
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
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            "Content-Type: application/json",
            "x-mid: " . $x_mid,
            "x-checksum: " . $x_checksum
        ));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $response = curl_error($ch) ? curl_error($ch) : $response;
        $response = json_decode($response);
        if ($response->status == 'ACCEPTED') {
            $resStatus = '';
        } else {
            $resStatus = '';
        }
        // $saveOrderData = array(
        //               'orderId'=>$orderRand,
        //               'amount'=>$amount,
        //               'user_detail_id'=>1,
        //               'type'=>'Gratification',
        //               'status'=>'Pending',
        //               'checkSum'=>$x_checksum,
        //               'created'=>date('Y-m-d H:i:s'),
        //               'modified'=>date('Y-m-d H:i:s'),
        //           );
        //       $saveData = $this->Crud_model->SaveData("user_account",$saveOrderData);
        
        print_r($response);
        exit();
        curl_close($ch);
        //print_r($result);
    }
    
    public function checkDisburseStatus() // Check disburse bank status API
    {
        header("Pragma: no-cache");
        header("Cache-Control: no-cache");
        header("Expires: 0");
        require_once(APPPATH . "/third_party/paytmlib/encdec_paytm.php");
        
        /* initialize an array */
        $paytmParams = array();
        
        /* Enter your order id which needs to be check disbursal status for */
        $order_id               = $_REQUEST['order_id'];
        $paytmParams["orderId"] = $order_id;
        
        /* prepare JSON string for request body */
        $post_data = json_encode($paytmParams, JSON_UNESCAPED_SLASHES);
        //echo "checksum <pre>"; print_r($post_data);echo '<br/>';
        /**
         * Generate checksum by parameters we have in body
         */
        $checksum  = getChecksumFromString($post_data, key); //iwpS9miFa%K0!x1L
        //echo "checksum <pre>"; print_r($checksum);echo '<br/>';
        /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        $x_mid     = mid; //"AagamE15178612468400"
        
        /* put generated checksum value here */
        $x_checksum = $checksum;
        
        /* for Staging */
        //$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/query";
        
        /* for Production */
        $url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/query";
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            "Content-Type: application/json",
            "x-mid: " . $x_mid,
            "x-checksum: " . $x_checksum
        ));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        $response = curl_error($ch) ? curl_error($ch) : $response;
        $response = json_decode($response);
        //print_r($response);exit;
        
        print_r($response);
        exit();
        curl_close($ch);
    }
    
    public function wallet_transfer()
    {
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
        print_r("https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification");
        print_r("<br/>");
        print_r($post_data);
        print_r("<br/>");
        /**
         * Generate checksum by parameters we have in body
         * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys 
         */
        $checksum = getChecksumFromString($post_data, "sB6awRVJ@YpDm3ZV");
        //$checksum = getChecksumFromString($post_data, "uF9cZaNpABsC&Xxa");
        
        /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        $x_mid = "VIVSON97870791415983";
        //$x_mid = "VIVSON12966438680092";
        print_r("x-mid : " . $x_mid);
        print_r("<br/>");
        /* put generated checksum value here */
        $x_checksum = $checksum;
        print_r("x-checksum : " . $x_checksum);
        print_r("<br/>");
        /* Solutions offered are: food, gift, gratification, loyalty, allowance, communication */
        
        /* for Staging */
        //$url = "https://staging-dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/{solution}";
        
        /* for Production */
        //$url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/Gratification";
        $url = "https://dashboard.paytm.com/bpay/api/v1/disburse/order/wallet/gratification";
        
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            "Content-Type: application/json",
            "x-mid: " . $x_mid,
            "x-checksum: " . $x_checksum
        ));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        print_r($response);
        exit;
    }
}