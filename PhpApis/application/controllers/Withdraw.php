<?php
defined('BASEPATH') OR exit('No direct script access allowed'); 

require APPPATH . '/libraries/REST_Controller.php';

class Withdraw extends REST_Controller 
{

 	function __construct()
    {
        parent::__construct();
        $this->load->helper('custom_helper');
    }

    /*public function addWithdrawAmount_post() 
    {
        headers();
        $this->_request =  file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true);

        $userId = $jsonDecodeData['userId'];
        $withdrawAmount = $jsonDecodeData['withdrawAmount'];
        $userMobileNo = $jsonDecodeData['userMobileNo'];
        $paymentType = $jsonDecodeData['paymentType'];
        //$orderId = $jsonDecodeData['orderId'];

        if(!empty($userId) && !empty($withdrawAmount)  && !empty($userMobileNo) && !empty($paymentType) )
        {
            $userData =$this->Crud_model->GetData("user_details","id,status,blockuser,balance,winWallet","id='".$userId."'","","","","1");
            if(!empty($userData)){
            	 if($userData->status!='Active'){
	            	 $response = array('status' => FALSE, 'success' => "0",'msg' => "Your account is inactive.");
	            }elseif($userData->blockuser!='No'){
	            	$response = array('status' => FALSE, 'success' => "0",'msg' => "Your account is blocked by admin.");
	            }elseif($userData->balance < $withdrawAmount){
	                $response = array('status' => FALSE, 'success' => "3",'msg' => "You have insufficient available balance");
	            }elseif($userData->winWallet < $withdrawAmount){
	            	 $response = array('status' => FALSE, 'success' => "3",'msg' => "You have insufficient available balance in win wallet");
	            }elseif($withdrawAmount < 200){
	                $response = array('status' => FALSE, 'success' => "2",'msg' => "Withdraw amount should be greater than or equal 200");
	            }else{
	                $con = "id='".$userId."'";
	                $getData = $this->Crud_model->GetData('user_details','',$con,'','','','1');
	                
	                $totalBal = $getData->balance - $withdrawAmount;
	                $winWallet = $getData->winWallet - $withdrawAmount;
	                $mainWallet = $getData->mainWallet;

	                $dataUser = array(
	                    'balance'=>$totalBal,
	                    'winWallet'=>$winWallet,
	                    'mainWallet'=>$mainWallet,
	                );
	                $this->Crud_model->SaveData('user_details',$dataUser,$con);

	                $data = array(
	                    'user_detail_id'=>$userId,
	                    'type'=>'Withdraw',
	                    'mobileNo'=>$userMobileNo,
	                    'paymentType'=>$paymentType,
	                    'amount'=>$withdrawAmount,
	                    'balance'=>$totalBal,
	                    'winWallet'=>$winWallet,
	                    'mainWallet'=>$mainWallet,
	                    'isReadNotification'=>'No',
	                    'status'=>'Pending',
	                );
	                $this->Crud_model->SaveData('user_account',$data);
	                $last_id = $this->db->insert_id();

	                $dataLog = array(
	                    'user_account_id'=>$last_id,
	                    'user_detail_id'=>$userId,
	                    'mobileNo'=>$userMobileNo,
	                    'type'=>'Withdraw',
	                    'amount'=>$withdrawAmount,
	                    'balance'=>$totalBal,
	                    'winWallet'=>$winWallet,
	                    'mainWallet'=>$mainWallet,
	                    'paymentType'=>$paymentType,
	                    'isReadNotification'=>'No',
	                    'status'=>'Pending',
	                );
	                $this->Crud_model->SaveData('user_account_logs',$dataLog);

	                $response = array('status' => TRUE, 'success' => "1",'msg' => "Withdraw amount successfully");
	        	}
	        }else{
	        	$response = array('status' => FALSE, 'success' => "0", 'msg' => "No user found");
	        }
            
        }
        else
        {
            $response = array('status' => FALSE, 'success' => "0", 'msg' => "All fields are required");
        }
        $this->response($response,REST_Controller::HTTP_CREATED);
    }*/


    public function addWithdrawAmount_post() 
    {
        headers();
        $this->_request =  file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true);

        $userId = $jsonDecodeData['userId'];
        $withdrawAmount = $jsonDecodeData['withdrawAmount'];
        $userMobileNo = $jsonDecodeData['userMobileNo'];
        $paymentType = $jsonDecodeData['paymentType'];
        $orderId 	= $jsonDecodeData['orderId'];

        if(!empty($userId) && !empty($withdrawAmount)  && !empty($userMobileNo) && !empty($paymentType) && !empty($orderId))
        {
           	$userData =$this->Crud_model->GetData("user_details","id,status,blockuser,balance,winWallet","id='".$userId."'","","","","1");

           	$userSett =$this->Crud_model->GetData("mst_settings","minWithdraw","id='4'","","","","1");
            
            if(!empty($userData)){
            	if($userData->status!='Active'){
	            	 $response = array('status' => FALSE, 'success' => "0",'msg' => "Your account is inactive.");
	            }elseif($userData->blockuser!='No'){
	            	$response = array('status' => FALSE, 'success' => "0",'msg' => "Your account is blocked by admin.");
	            }elseif($userData->balance < $withdrawAmount){
	                $response = array('status' => FALSE, 'success' => "3",'msg' => "You have insufficient available balance");
	            }elseif($userData->winWallet < $withdrawAmount){
	            	 $response = array('status' => FALSE, 'success' => "3",'msg' => "You have insufficient available balance in win wallet");
	            }elseif($withdrawAmount > $userSett->minWithdraw){
	            	 $response = array('status' => FALSE, 'success' => "2",'msg' => "You will withdraw minimum ".$userSett->minWithdraw." Rs only");
	            }
	            // elseif($withdrawAmount <= 200 && $paymentType=='bank'){
	            //     $response = array('status' => FALSE, 'success' => "2",'msg' => "Withdraw amount should be greater than or equal 200");
	            //     //
	            // }
	            // elseif($withdrawAmount <= 50 && $paymentType=='patym'){
	            //     $response = array('status' => FALSE, 'success' => "2",'msg' => "Withdraw amount should be greater than or equal 50");
	            // }
	            else{
	            	$userRecord =$this->Crud_model->GetData("user_account","id,orderId","orderId='".$orderId."'");
	            	if(!empty($userRecord)){
	            	 $response = array('status' => FALSE, 'success' => "2",'msg' => "Order Id already exists");
	            	}else{
		            	$con = "id='".$userId."'";
		                $getData = $this->Crud_model->GetData('user_details','',$con,'','','','1');
		                
		                $totalBal = $getData->balance - $withdrawAmount;
		                $winWallet = $getData->winWallet - $withdrawAmount;
		                $mainWallet = $getData->mainWallet;

		                $dataUser = array(
		                    'balance'=>$totalBal,
		                    'winWallet'=>$winWallet,
		                    'mainWallet'=>$mainWallet,
		                );
		                $this->Crud_model->SaveData('user_details',$dataUser,$con);

		                $data = array(
		                    'user_detail_id'=>$userId,
		                    'orderId'=>$orderId,
		                    'type'=>'Withdraw',
		                    'mobileNo'=>$userMobileNo,
		                    'paymentType'=>$paymentType,
		                    'amount'=>$withdrawAmount,
		                    'balance'=>$totalBal,
		                    'winWallet'=>$winWallet,
		                    'mainWallet'=>$mainWallet,
		                    'isReadNotification'=>'No',
		                    'status'=>'Pending',
		                    'created'=>date("Y-m-d H:i:s"),
		                );
		                // print_r(date("Y-m-d H:i:s"));exit()
		                $this->Crud_model->SaveData('user_account',$data);
		                $last_id = $this->db->insert_id();

		                $dataLog = array(
		                    'user_account_id'=>$last_id,
		                    'orderId'=>$orderId,
		                    'user_detail_id'=>$userId,
		                    'mobileNo'=>$userMobileNo,
		                    'type'=>'Withdraw',
		                    'amount'=>$withdrawAmount,
		                    'balance'=>$totalBal,
		                    'winWallet'=>$winWallet,
		                    'mainWallet'=>$mainWallet,
		                    'paymentType'=>$paymentType,
		                    'isReadNotification'=>'No',
		                    'status'=>'Pending',
		                     'created'=>date("Y-m-d H:i:s"),
		                );
		                $this->Crud_model->SaveData('user_account_logs',$dataLog);

		                $response = array('status' => TRUE, 'success' => "1",'msg' => "Withdraw amount successfully");
	            	}
	        	}
	        }else{
	        	$response = array('status' => FALSE, 'success' => "0", 'msg' => "No user found");
	        }
            
        }
        else
        {
            $response = array('status' => FALSE, 'success' => "0", 'msg' => "All fields are required");
        }
        $this->response($response,REST_Controller::HTTP_CREATED);
    }
}