<?php
defined('BASEPATH') OR exit('No direct script access allowed');
// This can be removed if you use __autoload() in config.php OR use Modular Extensions
require APPPATH.'/libraries/REST_Controller.php';
class Amount extends REST_Controller 
{
	function __construct()
	{
		parent::__construct();
		$this->load->model('Api_model');
	}

	public function updateReservedAmount_post()
	{
		$this->_request = file_get_contents("php://input");
		$jsonDecodeData = json_decode($this->_request, true);

		$amount    = $jsonDecodeData['amount'];
		$type      = $jsonDecodeData['type'];
		$field     = $jsonDecodeData['field'];

		if(!empty($amount) && !empty($type) && !empty($field)){

			$getWebAdminData = $this->Api_model->GetData('admin_login','',"id!=0 and adminType='Admin'",'','','','1');
			if(!empty($getWebAdminData))
			{
				if($type=="Add"){
					$data[$field] = $getWebAdminData->{$field}+$amount;
				}else{
					$data[$field] = $getWebAdminData->{$field}-$amount;
				}

				if($data[$field] < 0) {
					$deduct = 'No';
				}else{
					$deduct = 'Yes';
				}

				$getData=array(
					'oldAmount'=>$getWebAdminData->{$field},
					'reservedAmount'=>$data[$field],
					'amount'=>$amount,
					'field'=>$field,
					'type'=>$type,
					'isDeduct'=>$deduct,
					'data'=>$data
				);

				if($data[$field] < 0) {
					$response = array('status' => FALSE, 'success' => "1", 'msg' => "Reserved amount not updated","getData"=>$getData);	
				}else {
					$con = "id='".$getWebAdminData->id."' and adminType='Admin'";
					$this->Crud_model->SaveData("admin_login",$data,$con);	
					$response = array('status' => TRUE, 'success' => "1", 'msg' => "Reserved amount update successfully","getData"=>$getData);
				}
			}
		}
		else
		{
			$response = array('status' => FALSE, 'success' => "0", 'msg' => "All fields are required","getData"=>"None");
		}
		$this->response($response,REST_Controller::HTTP_CREATED);
	}


	
	public function updateReservedAmount2_post()
	{

		$this->_request = file_get_contents("php://input");
		$jsonDecodeData = json_decode($this->_request, true);

		//$response  ='';
		$amount    = $jsonDecodeData['amount'];
		$type      = $jsonDecodeData['type'];
		$field     = $jsonDecodeData['field'];

		if(!empty($amount) && !empty($type) && !empty($field))
		{
			$getWebAdminData = $this->Api_model->GetData('admin_login','',"id!=0 and adminType='Admin'",'','','','1');
			if(!empty($getWebAdminData)){

				if($type=="Add"){
					$data[$field] = $getWebAdminData->{$field}+$amount;
				}else{
					$data[$field] = $getWebAdminData->{$field}-$amount;
				}
				$getData=array(
					'oldAmount'=>$getWebAdminData->{$field},
					'reservedAmount'=>$data[$field],
					'field'=>$field,
					'type'=>$type,
				);
				$con = "id='".$getWebAdminData->id."' and adminType='Admin'";
				$this->Crud_model->SaveData("admin_login",$data,$con);
				//print_r($this->db->last_query( ));exit();
				$response = array('status' => TRUE, 'success' => "1", 'msg' => "Reserved amount update successfully","getData"=>$getData,"data"=>$data);
			}
		}
		else
		{
			$response = array('status' => FALSE, 'success' => "0", 'msg' => "All fields are required","getData"=>"None");
		}
		$this->response($response,REST_Controller::HTTP_CREATED);
	}

	public function updatePlayCoins_post()
	{
		$this->_request = file_get_contents("php://input");
		$jsonDecodeData = json_decode($this->_request, true);

		$userId    = $jsonDecodeData['userId'];
		$amount    = $jsonDecodeData['amount'];

		if(!empty($userId) && !empty($amount))
		{
			$getUser = $this->Crud_model->GetData('user_details','id,totalPlayCoins,allTotalPlayCoins','id="'.$userId.'"','','','','1');
			if(empty($getUser))
			{
				$response = array('status' => FALSE, 'success' => "0", 'msg' => "Record not found");
			}
			else
			{
				$totalPlayCoins = $getUser->totalPlayCoins + $amount;
				$allTotalPlayCoins = $getUser->allTotalPlayCoins + $amount;
				$data = array(
					'totalPlayCoins'=>$totalPlayCoins,
					'allTotalPlayCoins'=>$allTotalPlayCoins,
				);
				$con = "id='".$userId."'";
				$this->Crud_model->SaveData('user_details',$data,$con);
				$response = array('status' => TRUE,'getUser'=>$getUser, 'success' => "0", 'msg' => "update successfully");
			}
		}
		else
		{
			$response = array('status' => FALSE, 'success' => "0", 'msg' => "All fields are required");
		}
		$this->response($response,REST_Controller::HTTP_CREATED);
	}

}