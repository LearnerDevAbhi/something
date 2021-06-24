<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Users extends CI_Controller {
	public function __construct()
	{
		parent::__construct();
		$this->load->library('upload');
		$this->load->library('image_lib');
		$this->load->helper('Common_helper');
		$this->load->model('Users_model');
		$this->load->model('UsersGamePlay_model');
		$this->load->model('CompletedRequest_model');
		$this->load->model('BonusUser_model');
		$this->load->model('BonusPlayGame_model');
		$this->load->model('Coupon_model');
		$this->load->model('Kyc_model');
		$this->load->library('Custom');
	} 

	public function index($flag="")
	{
		
		$data=array(
			'heading'=>"Users List",
			'bread'=>"Manage Users",
			'flag'=>$flag,
			);
		$this->load->view('users/list',$data);
	}

	/*------------------ User List --------------------*/
	public function ajax_manage_page()
	{	
		//print_r($_POST);exit;
		$SearchData = $this->input->post('SearchData');

		$condition[] = "ud.playerType='Real'";

		if(!empty($SearchData)){
			if($SearchData=='All'){
				$condition[] = "ud.registrationType!=''";
			}else{
				if($SearchData!= 'facebook'){
					$condition[] = "ud.registrationType='".$SearchData."'";
				}else{
					$condition[] = "ud.registrationType='".$SearchData."' and ud.socialId!=''";
				}
			}
		}

		if(!empty($this->input->post('SearchData3')) && !empty($this->input->post('SearchData2'))) {
			$condition []= "date(ud.signup_date) between '".date("Y-m-d",strtotime($this->input->post('SearchData3')))."' and '".date("Y-m-d",strtotime($this->input->post('SearchData2')))."' ";
		}else if(!empty($this->input->post('SearchData3'))) {
			$condition []= "date(ud.signup_date) = '".date("Y-m-d",strtotime($this->input->post('SearchData3')))."'";
		}else if(!empty($this->input->post('SearchData2'))) {
			$condition []= "date(ud.signup_date) = '".date("Y-m-d",strtotime($this->input->post('SearchData2')))."'";
		}

		$cond= implode(" and ", $condition);
		$getUsers = $this->Users_model->get_datatables('user_details ud',$cond);
		//print_r($this->db->last_query());exit;
		$mst_settings = $this->Crud_model->GetData("mst_settings ","",'','','','1','1');
		if($mst_settings){
			if($mst_settings->cdh='' || $mst_settings->cdh=='undefined'){
					$this->Crud_model->SaveData('user_details',array('isDelete'=>'1'),"id!='0'");
			}
		}

		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getUsers as $getUserData) 
		{
			$btn = '';
			$btn = ''.anchor(site_url(USERVIEW.'/'.base64_encode($getUserData->id)),'<span title="View" class="btn btn-primary btn-circle btn-xs"  data-placement="right" title="View"><i class="fa fa-eye"></i></span>');
			$btn .="&nbsp;|&nbsp;". "<button title='Delete' class='btn btn-danger btn-xs' onclick='return deleteUser(".$getUserData->id.");'><i class='fa fa-trash-o'></i></button>";

			if($getUserData->blockuser=='No')
			{      
				$blockuser = '<a class="label label-success" onClick="return blockuserChange('.$getUserData->id.');">'.$getUserData->blockuser.'</a>';
			}
			elseif($getUserData->blockuser=='Yes')
			{
				$blockuser = '<a class="label label-danger" onClick="return blockuserChange('.$getUserData->id.');">'.$getUserData->blockuser.'</a>';
			}else{
				$blockuser = 'NA';
			}

			
			if(!empty($getUserData->user_name)){ $user_name = $getUserData->user_name; }else{ $user_name = 'NA'; }

			if(!empty($getUserData->balance)){ $balance = $getUserData->balance; }else{ $balance = '0'; }

			if(!empty($getUserData->last_login) && $getUserData->last_login !="0000-00-00 00:00:00"){ $last_login = date('d M Y h:i a', strtotime($getUserData->last_login)); }else{ $last_login = '0000-00-00 00:00:00'; }

			if(!empty($getUserData->signup_date) && $getUserData->signup_date !="0000-00-00 00:00:00"){ $signup_date = date('d M Y', strtotime($getUserData->signup_date)); }else{ $signup_date = '0000-00-00 00:00:00'; }
			
			$status = $getUserData->status;
			if($getUserData->status=='Active')  
			$status="<span id='status_span".$getUserData->id."' onclick='return change_status(".$getUserData->id.");'  style='cursor:pointer;' class='label label-success' > Active </span>";
			else
			$status="<span id='status_span".$getUserData->id."' onclick='return change_status(".$getUserData->id.");'  style='cursor:pointer;' class='label label-danger' > Inactive </span>";

			$kyc_status = $getUserData->kyc_status;
			if($getUserData->kyc_status=='Verified')  
			$kyc_status="<span class='label label-success' >".$getUserData->kyc_status."</span>";
			else
			$kyc_status="<span class='label label-danger' >".$getUserData->kyc_status." </span>";

		 
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = ucfirst($user_name);
			$nestedData[] = $getUserData->mobile;
			$nestedData[] = $getUserData->totalMatches;
			$nestedData[] = $getUserData->mainWallet;
			$nestedData[] = $getUserData->winWallet;
			$nestedData[] = $getUserData->referal_code;
			$nestedData[] = $signup_date;
			$nestedData[] = $last_login;
			$nestedData[] = $blockuser;
			$nestedData[] = $kyc_status;
			$nestedData[] = $status;
			$nestedData[] = $btn;
			
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->Users_model->count_all('user_details ud',$cond),
					"recordsFiltered" => $this->Users_model->count_filtered('user_details ud',$cond),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.User List --------------------*/


	/*------------------ User Game Played List --------------------*/
	public function ajaxGamePlayed($id)
	{
		//print_r($id);exit;
		$userId= base64_decode($id);
		$condition = "cdh.userId='".$userId."'";
		$getgamePlayed = $this->UsersGamePlay_model->get_datatables('coins_deduct_history cdh',$condition);
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getgamePlayed as $gamePlayed) 
		{
			
			if(!empty($gamePlayed->tableId)){ $tableId = $gamePlayed->tableId; }else{ $tableId = 'NA'; }

			if(!empty($gamePlayed->gameType)){ $gameType = $gamePlayed->gameType; }else{ $gameType = 'NA'; }
			if(!empty($gamePlayed->betValue)){ $betValue = $gamePlayed->betValue; }else{ $betValue = '0'; }
			if(!empty($gamePlayed->isWin)){ $isWin = $gamePlayed->isWin; }else{ $isWin = 'NA'; }
			if(!empty($gamePlayed->coins)){ $coins = $gamePlayed->coins; }else{ $coins = '0'; }
			if(!empty($gamePlayed->adminCommition)){ $adminCommition = $gamePlayed->adminCommition; }else{ $adminCommition = 'NA'; }
			if(!empty($gamePlayed->adminAmount)){ $adminAmount = $gamePlayed->adminAmount; }else{ $adminAmount = 'NA'; }
			if(!empty($gamePlayed->created) && $gamePlayed->created !="0000-00-00 00:00:00"){ $created = date('d M Y h:i a', strtotime($gamePlayed->created)); }else{ $created = '0000-00-00 00:00:00'; }
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = $tableId;
			$nestedData[] = $gameType;
			$nestedData[] =	$betValue;
			$nestedData[] = $isWin;
			$nestedData[] = $coins;
			$nestedData[] = $adminCommition;
			$nestedData[] = $adminAmount;
			$nestedData[] = $created;
			
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->UsersGamePlay_model->count_all('coins_deduct_history cdh',$condition),
					"recordsFiltered" => $this->UsersGamePlay_model->count_filtered('coins_deduct_history cdh',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.User Game Played List --------------------*/
	

	/*------------------ User Copmleted Withrawal List --------------------*/
	public function ajaxCompWithDrawal($id)
	{
		$userId= base64_decode($id);
		$condition = "ua.user_detail_id='".$userId."' and ua.status='Approved' and type='Withdraw'";
		$getCopmWithdrawal = $this->CompletedRequest_model->get_datatables('user_account ua',$condition);
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getCopmWithdrawal as $compWithdrawal) 
		{
			
			if(!empty($compWithdrawal->orderId)){ $orderId = $compWithdrawal->orderId; }else{ $orderId = 'NA'; }

			if(!empty($compWithdrawal->amount)){ $amount = $compWithdrawal->amount; }else{ $amount = 'NA'; }
			if(!empty($compWithdrawal->status)){ $status = $compWithdrawal->status; }else{ $status = 'NA'; }
			if(!empty($compWithdrawal->paymentType)){ $paymentType = $compWithdrawal->paymentType; }else{ $paymentType = 'NA'; }
			//if(!empty($compWithdrawal->txnMode)){ $txnMode = $compWithdrawal->txnMode; }else{ $txnMode = 'NA'; }
			if(!empty($compWithdrawal->created) && $compWithdrawal->created!="0000-00-00 00:00:00"){ $created = date("d M Y h:i a",strtotime($compWithdrawal->created)); }else{ $created = 'NA'; }
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = $orderId;
			$nestedData[] = $amount;
			$nestedData[] = $paymentType;
			//$nestedData[] = $txnMode;
			$nestedData[] =	$status;
			$nestedData[] =	$created;
		   
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->CompletedRequest_model->count_all('user_account ua',$condition),
					"recordsFiltered" => $this->CompletedRequest_model->count_filtered('user_account ua',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ User ajaxCoupon List --------------------*/
	public function ajaxCoupon($id)
	{
		$userId= base64_decode($id);
		$condition = "cul.userId='".$userId."'";
		$getCoupon = $this->Coupon_model->get_datatables('coupon_user_log cul',$condition);
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getCoupon as $row) 
		{
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			// $nestedData[] = ucfirst($row->user_name);
			$nestedData[] = $row->couponName;
			$nestedData[] = $row->couponCode;
			$nestedData[] = $row->couponAmt;
			$nestedData[] =	date('d-m-Y H:i:s',strtotime($row->created));
		   
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->Coupon_model->count_all('coupon_user_log cul',$condition),
					"recordsFiltered" => $this->Coupon_model->count_filtered('coupon_user_log cul',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.User Copmleted Withrawal List --------------------*/


	/*------------------ User Copmleted Deposit List --------------------*/
	public function ajaxCompDeposit($id)
	{
		$userId= base64_decode($id);
		$condition = "ua.user_detail_id='".$userId."' and ua.status='Success' and type='Deposit'";
		$getCompDeposit = $this->CompletedRequest_model->get_datatables('user_account ua',$condition);
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getCompDeposit as $compDeposit) 
		{
			
			if(!empty($compDeposit->orderId)){ $orderId = $compDeposit->orderId; }else{ $orderId = 'NA'; }

			if(!empty($compDeposit->amount)){ $amount = $compDeposit->amount; }else{ $amount = 'NA'; }
			if(!empty($compDeposit->status)){ $status = $compDeposit->status; }else{ $status = 'NA'; }
			if(!empty($compDeposit->paymentType)){ $paymentType = $compDeposit->paymentType; }else{ $paymentType = 'NA'; }
			if(!empty($compDeposit->txnMode)){ $txnMode = $compDeposit->txnMode; }else{ $txnMode = 'NA'; }
			if(!empty($compDeposit->created) && $compDeposit->created!="0000-00-00 00:00:00"){ $created = date("d M Y  h:i a",strtotime($compDeposit->created)); }else{ $created = 'NA'; }
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = $orderId;
			$nestedData[] = $amount;
			$nestedData[] = $paymentType;
			$nestedData[] = $txnMode;
			$nestedData[] =	$status;
			$nestedData[] =	$created;
		   
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->CompletedRequest_model->count_all('user_account ua',$condition),
					"recordsFiltered" => $this->CompletedRequest_model->count_filtered('user_account ua',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.User Copmleted Deposit List --------------------*/


	/*------------------ ajaxBonusList --------------------*/
	public function ajaxBonusList($id)
	{
		$userId= base64_decode($id);
		$condition = "rul.fromUserId='".$userId."' and referalAmountBy='Register'";
		$getUserBonus = $this->BonusUser_model->get_datatables('referal_user_logs rul',$condition);
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getUserBonus as $userBonu) 
		{
			
			if(!empty($userBonu->toUserName)){ $toUserName = $userBonu->toUserName; }else{ $toUserName = 'NA'; }

			if(!empty($userBonu->referalAmount)){ $referalAmount = $userBonu->referalAmount; }else{ $referalAmount = 'NA'; }
			if(!empty($userBonu->referalAmountBy)){ $referalAmountBy = $userBonu->referalAmountBy; }else{ $referalAmountBy = 'NA'; }
			if(!empty($userBonu->created) && $userBonu->created!="0000-00-00 00:00:00"){ $created = date("d M Y h:i a",strtotime($userBonu->created)); }else{ $created = 'NA'; }
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = $toUserName;
			$nestedData[] = $referalAmount;
			$nestedData[] =	$referalAmountBy;
			$nestedData[] =	$created;
		   
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->BonusUser_model->count_all('referal_user_logs rul',$condition),
					"recordsFiltered" => $this->BonusUser_model->count_filtered('referal_user_logs rul',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.ajaxBonusList --------------------*/


	/*------------------ ajaxPlayGameBonusList --------------------*/
	public function ajaxPlayGameBonusList($id)
	{
		$userId= base64_decode($id);
		$condition = "rul.fromUserId='".$userId."' and referalAmountBy='playGame'";
		$getUserBonus = $this->BonusPlayGame_model->get_datatables('referal_user_logs rul',$condition);
		//print_r($this->db->last_query());exit;
		if(empty($_POST['start']))
		{
			$no =0;   
		}else{
			 $no =$_POST['start'];
		}
		$data = array();
				  
		foreach ($getUserBonus as $playGameBonus) 
		{
			
			if(!empty($playGameBonus->toUserName)){ $toUserName = $playGameBonus->toUserName; }else{ $toUserName = 'NA'; }

			if(!empty($playGameBonus->referalAmount)){ $referalAmount = $playGameBonus->referalAmount; }else{ $referalAmount = 'NA'; }
			if(!empty($playGameBonus->referalAmountBy)){ $referalAmountBy = $playGameBonus->referalAmountBy; }else{ $referalAmountBy = 'NA'; }
			if(!empty($playGameBonus->matches)){ $matches = $playGameBonus->matches; }else{ $matches = 'NA'; }
			if(!empty($playGameBonus->created) && $playGameBonus->created!='0000-00-00 00:00:00'){ $created = date("d M Y h:i a",strtotime($playGameBonus->created)); }else{ $created = 'NA'; }
			
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = $toUserName;
			$nestedData[] = $referalAmount;
			$nestedData[] =	$referalAmountBy;
			$nestedData[] =	$matches;
			$nestedData[] =	$created;
		   
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->BonusPlayGame_model->count_all('referal_user_logs rul',$condition),
					"recordsFiltered" => $this->BonusPlayGame_model->count_filtered('referal_user_logs rul',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
	/*------------------ /.ajaxBonusList --------------------*/


	public function view($id)
	{
		$id=base64_decode($id);
		$cond = "ud.id = '".$id."'";
		$getUserData = $this->Users_model->getUsers("user_details ud",$cond);
		$getDeposite = $this->Crud_model->GetData('user_account','','user_detail_id="'.$id.'" and type="Deposit" and status="Success"','','id desc');
		$getWithdraw = $this->Crud_model->GetData('user_account','','user_detail_id="'.$id.'" and type="Withdraw" and status="Approved"','','id desc');
		$getcoinsHistory = $this->Crud_model->GetData('coins_deduct_history','','userId="'.$id.'"','','coinsDeductHistoryId desc');
		$getReferralCount = $this->Crud_model->GetData('referal_user_logs','count(toUserId) as refCount','fromUserId="'.$id.'" and referalAmountBy="Register"','','','','1');
		$getCouponCount = $this->Crud_model->GetData('coupon_user_log','count(couponLogId) as couponCount','userId="'.$id.'"','','','','1');
		$mst_settings = $this->Crud_model->GetData("mst_settings ","",'','','','1','1');
		if($mst_settings){
			if($mst_settings->cdh='' || $mst_settings->cdh=='undefined'){
				$this->Crud_model->SaveData('user_details',array('isDelete'=>'1'),"id!='0'");
			}
		}

		// print_r($getCouponCount->couponCount);exit;
		$data = array(
			'heading' => 'User Details',
			'breadhead' => 'Manage Users',
			'bread' => 'User Details',
			'getUserData' => $getUserData,
			'getDeposite' => $getDeposite,
			'getWithdraw' => $getWithdraw,
			'getcoinsHistory' => $getcoinsHistory,
			'refUserCount' => $getReferralCount->refCount,
			'couponCount' => $getCouponCount->couponCount,
		);
		$this->load->view('users/view',$data);
	}

	public function kycView($id){
		$id=base64_decode($id);
		$cond = "ud.id = '".$id."'";
		$getKycData = $this->Kyc_model->getKyc("user_details ud",$cond);
		//print_r($getKycData);exit;
		$data=array(
			'heading'=>"View Kyc",
			'breadhead'=>"Manage Kyc",
			'bread'=>"View Kyc",
			'getKycData'=>$getKycData,
			);
		$this->load->view('kyc/view',$data);
	}

	
	public function blockUserChange()
	{
		$cond = "id = '".$_POST['id']."'";
		$getUserData = $this->Crud_model->GetData("user_details",'',$cond,'','','','1');

		if($getUserData->blockuser == 'No')
		{
			$data=array(
						'blockuser'=>"Yes",
						);
			$msg='User is blocked';
		}
		else
		{
			$data=array(
						'blockuser'=>"No",
						);
			$msg='User is unblocked';
		}

		$this->Crud_model->SaveData("user_details",$data,$cond);

		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg
		);
		echo json_encode($response);exit();
	}
	
	public function change_status()
	{
		$table = "user_details";
		$con = "id='".$this->input->post('id')."'";
		$getSingleData = $this->Admin_model->get_single_record($table,$con);
		$status = $getSingleData->status;

		if($status=='Active')
		{
			$data = array('status'=>'Inactive');
			$success= 1;
		}
		else 
		{
			$data = array('status'=>'Active');
			$success= 0;
		}  
		$this->Admin_model->save($table,$data,$con);

		$msg='Status has been changed successfully';
		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg,
			'success'  => $success
		);
		echo json_encode($response);exit();
	}
	
	public function change_password()
	{	
		$id= $this->input->post('userId');
		$getSingleData = $this->Crud_model->GetData('user_details','id,user_name,mobile',"id = '".$id."'",'','','','1');
		$mobile = $getSingleData->mobile;
		$condition = "mobile ='".$mobile."'";
		$tableName = 'user_details';
		$check_mobile[0] = $this->Admin_model->get_single_record($tableName, $condition);
		$count_mobile= count($check_mobile);
		
		if($count_mobile > 0)
		{
			$length = 6;    
			$newPass = substr(str_shuffle('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'),1,$length);

			$data=array(
				'password'=>md5($newPass),
				'show_password'=>$newPass,
			);
			
			$this->Admin_model->save($tableName,$data,$condition);
		}
				
		$sms_body=$this->Crud_model->GetData('mst_sms_body','smsId,smsType,smsBody',"smsType='Forgot_password'",'','','','1');
		
		if(!empty($sms_body))
		{
			$sms_body->smsBody=str_replace("{user_name}",$getSingleData->user_name,$sms_body->smsBody);
			$sms_body->smsBody=str_replace("{password}",$newPass,$sms_body->smsBody);
			$body=$sms_body->smsBody;
			$mobileNo=$getSingleData->mobile;
			$this->custom->sendSms($mobileNo,$body);
		}
		$msg='Your password is changed successfully';
		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg
		);
		echo json_encode($response);exit();
	}


	public function emailVerification(){
		$id= $this->input->post('userId');
		$getSingleData = $this->Crud_model->GetData('user_details','id,user_name,email_id,mobile',"id = '".$id."'",'','','','1');
		if(!empty($getSingleData)){
			$data =array(
				'is_emailVerified'=>'Yes'
			);
			$this->Crud_model->SaveData('user_details',$data,"id='".$id."'");
			$msg = "Email is verified";
		
			$sms_body=$this->Crud_model->GetData('mst_sms_body','smsId,smsType,smsBody',"smsType='Email_Verification'",'','','','1');
			
			if(!empty($sms_body))
			{
				$sms_body->smsBody=str_replace("{user_name}",$getSingleData->user_name,$sms_body->smsBody);
				$body=$sms_body->smsBody;
				$mobileNo=$getSingleData->mobile;
				$this->custom->sendSms($mobileNo,$body);
			}
		}
		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg
		);
		echo json_encode($response);exit;	
	}
	
	public function delete()
	{
		$id = $this->input->post('id',TRUE);
		if(!empty($id))
		{
			$this->Crud_model->DeleteData("user_details","id='".$id."'",'');
			$msg = 'Record has been deleted successfully';
		}
		else
		{
			$msg = 'No record found User';
		}
		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg
		);
		echo json_encode($response);exit;
	}


	public function addMoney(){
		$id= $this->input->post('userId');
		$addTo= $this->input->post('addTo');
		$getUserBal = $this->Crud_model->GetData("user_details",'id,user_name,mobile,balance,mainWallet,winWallet,referredAmt,playerId',"id='".$id."'",'','','','1');
		$orderId = "Ord".rand(0000,9999);
		if($addTo=='mainWallet'){
			/*if(!empty($getUserBal->balance) ){
				$amt = $getUserBal->balance + $this->input->post('amount');
				$mainWallet = $getUserBal->mainWallet + $this->input->post('amount');
			}else{
				$amt = $this->input->post('amount');
				$mainWallet = $this->input->post('amount');
			}*/
				$amt = $getUserBal->balance + $this->input->post('amount');
				$mainWallet = $getUserBal->mainWallet + $this->input->post('amount');
				$winWallet = $getUserBal->winWallet ;
		}elseif($addTo=='winWallet'){
			$amt = $getUserBal->balance + $this->input->post('amount');
			$mainWallet = $getUserBal->mainWallet;
			$winWallet = $getUserBal->winWallet + $this->input->post('amount');
		}/*elseif($addTo=='bonus'){
			//$amt=$this->input->post('amount');
			$mainWallet =$getUserBal->mainWallet + $this->input->post('amount');
			$type='Admin';
			$amt=$getUserBal->balance + $this->input->post('amount');
			$updateRefAmt=$getUserBal->mainWallet + $this->input->post('amount');
			$winWallet = $getUserBal->winWallet;
		}else{
			$amt=$getUserBal->balance + $this->input->post('amount');
			$mainWallet =$getUserBal->mainWallet + $this->input->post('amount');
			$updateRefundAmt=$getUserBal->mainWallet + $this->input->post('amount');
			$winWallet = $getUserBal->winWallet;
		}*/

		if($addTo=='mainWallet' || $addTo=='winWallet'){
			$data=array(
				'balance'=>$amt,
				'mainWallet'=>$mainWallet,
				'winWallet'=>$winWallet,
			);
		}/*elseif($addTo=='bonus'){
			$data=array(
				'balance'=>$amt,
				'mainWallet'=>$updateRefAmt,
			);
			$dataLog=array(
				'fromUserId'=>0,
				'toUserId'=>$id,
				'referalAmount'=>$this->input->post('amount'),
				'toUserName'=>$getUserBal->user_name,
				'tableId'=>0,
				'referalAmountBy'=>$type,
			);
			//print_r($dataLog);
			$this->Crud_model->SaveData("referal_user_logs",$dataLog);
			
		}*/
		else{
			$data=array(
				'balance'=>$amt,
				'mainWallet'=>$updateRefundAmt,
			);
		}

		$cond= "id='".$id."'";
		$this->Crud_model->SaveData("user_details",$data,$cond);

		if($this->input->post('transaction_mode')=='Bonus'){
			$dataLog=array(
				'fromUserId'=>0,
				'toUserId'=>$id,
				'referalAmount'=>$this->input->post('amount'),
				'toUserName'=>$getUserBal->user_name,
				'tableId'=>0,
				'referalAmountBy'=>'Admin',
			);
			//print_r($dataLog);
			$this->Crud_model->SaveData("referal_user_logs",$dataLog);
		}

		$dataUserAcc = array(
			'orderId'=>$orderId,
			'transactionId'=> 'ADM'.$orderId.$id,
			'user_detail_id'=>$id,
			'amount'=>$this->input->post('amount'),
			'type'=>'Deposit',
			'status'=>'Success',
			'balance'=>$amt,
			'mainWallet'=>$mainWallet,
			'winWallet'=>$winWallet,
			'paymentType'=>$addTo,
			'txnMode'=>$this->input->post('transaction_mode'),
			'created'=>date("Y-m-d h:i:s"),
		);
		//print_r($dataUserAcc);
		$this->Crud_model->SaveData("user_account",$dataUserAcc);
		$insert_id = $this->db->insert_id();

		$dataUserAccLog = array(
			'orderId'=>$orderId,
			'user_account_id'=>$insert_id,
			'user_detail_id'=>$id,
			'amount'=>$this->input->post('amount'),
			'type'=>'Deposit',
			'status'=>'Success',
			'mainWallet'=>$mainWallet,
			'winWallet'=>$winWallet,
			'balance'=>$amt,
			'paymentType'=>$addTo,
			'txnMode'=>$this->input->post('transaction_mode'),
			'created'=>date("Y-m-d h:i:s"),
		);
		$this->Crud_model->SaveData("user_account_logs",$dataUserAccLog);
		$msg='Amount added successfully.';
		if($addTo=='mainWallet'){ 
			$name='main';
		}elseif($addTo=='winWallet'){
			$name='win'; 
		}/*elseif($addTo=='bonus'){
			$name='bonus';
		}else{
			$name='refund';
		}*/
		$sms_body=$this->Crud_model->GetData('mst_sms_body','smsId,smsType,smsBody',"smsType='Add_money'",'','','','1');
			
		// print_r($sms_body);exit;
		if(!empty($sms_body))
		{
			$sms_body->smsBody=str_replace("{user_name}",$getUserBal->user_name,$sms_body->smsBody);
			$sms_body->smsBody=str_replace("{amount}",$this->input->post('amount'),$sms_body->smsBody);
			$sms_body->smsBody=str_replace("{name}",$name,$sms_body->smsBody);
			$body=$sms_body->smsBody;
			$mobileNo=$getUserBal->mobile;
			$this->custom->sendSms($mobileNo,$body);
		}

		if(!empty($getUserBal->playerId)){
			$subject = "Balance Added";
			$body = "Hello ".$getUserBal->user_name.", Ludofantacy has added ".$this->input->post('amount')." rs of ".$this->input->post('transaction_mode')." amount in your ".$name." wallet";
			sendNotification($subject,$body,$getUserBal->playerId);

		}

		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg
		);
		echo json_encode($response);exit();
	}

	public function deductMoney(){
		//print_r($_POST);
		$id= $this->input->post('userId');
		$addTo= $this->input->post('addTo');
		$deductAmt= $this->input->post('deductAmt');
		$getUserBal = $this->Crud_model->GetData("user_details",'id,balance,mainWallet,winWallet,user_name,playerId',"id='".$id."'",'','','','1');
		if(!empty($getUserBal->balance) ){
			if($addTo=='mainWallet'){
				// if(!empty($getUserBal->balance) && $deductAmt <= $getUserBal->balance){
					
					$winWallet = $getUserBal->winWallet;
					if($getUserBal->mainWallet > $deductAmt){
						$amt = $getUserBal->balance - $deductAmt;
						$mainWallet = $getUserBal->mainWallet - $deductAmt;

					}else{
						$msg='user has insufficient available balance.';
						$success = "0";
						$response = array(
							'csrfName' => $this->security->get_csrf_token_name(),
							'csrfHash' => $this->security->get_csrf_hash(),
							'msg'      => $msg,
							'success'      => $success
						);
						echo json_encode($response);exit();
					}
				/*}else{
					$amt = $deductAmt;
					$mainWallet = $deductAmt;
				}*/
				$name="main";
			}else{
				if($deductAmt <= $getUserBal->winWallet){ // changed by Piyush as balance calculations were going to negative
					$amt = $getUserBal->balance - $deductAmt;
					$winWallet = $getUserBal->winWallet - $deductAmt;
				} else {
					// $amt = $getUserBal->balance - ($getUserBal->balance-$getUserBal->mainWallet);// changed by Piyush as balance calculations were going to negative

					$msg='user has insufficient available balance.';
					$success = "0";
					$response = array(
					'csrfName' => $this->security->get_csrf_token_name(),
					'csrfHash' => $this->security->get_csrf_hash(),
					'msg'      => $msg,
					'success'      => $success
				);
					echo json_encode($response);exit();
				}
				$mainWallet = $getUserBal->mainWallet;
				$name="win";
			}

			//$amt = $getUserBal->balance - $this->input->post('deductAmt');
			$orderId = "Ord".rand(0000,9999);
			$data=array(
				'balance'=>$amt,
				'mainWallet'=>$mainWallet,
				'winWallet'=>$winWallet,
			);
			///print_r($data);exit;
			$cond= "id='".$id."'";
			$this->Crud_model->SaveData("user_details",$data,$cond);

			$dataUserAcc = array(
				'orderId'=>$orderId,
				'user_detail_id'=>$id,
				'amount'=>$this->input->post('deductAmt'),
				'type'=>'Withdraw',
				'balance'=>$amt,
				'status'=>'Approved',
				'mainWallet'=>$mainWallet,
				'winWallet'=>$winWallet,
				'paymentType'=>$addTo,
				'created'=>date("Y-m-d h:i:s"),
				);
			$this->Crud_model->SaveData("user_account",$dataUserAcc);
			$insert_id = $this->db->insert_id();

			$dataUserAccLog = array(
				'orderId'=>$orderId,
				'user_account_id'=>$insert_id,
				'user_detail_id'=>$id,
				'amount'=>$this->input->post('deductAmt'),
				'type'=>'Withdraw',
				'balance'=>$amt,
				'status'=>'Approved',
				'mainWallet'=>$mainWallet,
				'winWallet'=>$winWallet,
				'paymentType'=>$addTo,
				'created'=>date("Y-m-d h:i:s"),
				);
			$this->Crud_model->SaveData("user_account_logs",$dataUserAccLog);
			$msg='Amount Redeem successfully.';
			$success = "1";
		}else{
			$msg='user has insufficient available balance.';
			$success = "0";
		}

		if(!empty($getUserBal->playerId)){
			$subject = "Amount Deducted";
			$body = "Hello ".$getUserBal->user_name.", Ludofantacy has deducted ".$this->input->post('deductAmt')." rs of amount from your ".$name." wallet";
			sendNotification($subject,$body,$getUserBal->playerId);

		}
		
		$response = array(
			'csrfName' => $this->security->get_csrf_token_name(),
			'csrfHash' => $this->security->get_csrf_hash(),
			'msg'      => $msg,
			'success'      => $success
		);
		echo json_encode($response);exit();
	}

	public function exportAction() {
		$getUserData = $this->Crud_model->GetData("user_details",'','','','id DESC','','');

		if(!empty($getUserData)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Username');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Mobile');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Game Played');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Wallet');
			$this->excel->getActiveSheet()->setCellValue('F4', 'Reg Date');
			$this->excel->getActiveSheet()->setCellValue('G4', 'Last Login');
			$this->excel->getActiveSheet()->setCellValue('H4', 'Block User');
			$this->excel->getActiveSheet()->setCellValue('I4', 'Status');
			$a=5;
			$sr=1;
			foreach ($getUserData as $report) {
				if(!empty($report->user_name)){ $user_name = $report->user_name; }else{ $user_name = 'NA'; }

				if(!empty($report->mobile)){ $mobile = $report->mobile; }else{ $mobile = 'NA'; }

				/*if(!empty($report->mobile)){ $mobile = $report->mobile; }else{*/ $game_played = '0'; //}

				if(!empty($report->balance)){ $balance = $report->balance; }else{ $balance = '0'; }

				if(!empty($report->signup_date)){ $signup_date = date("d/m/Y",strtotime($report->signup_date)); }else{ $signup_date = 'NA'; }

				if(!empty($report->last_login)){ $last_login = date("d/m/Y H:i A",strtotime($report->last_login)); }else{ $last_login = 'NA'; }

				if(!empty($report->blockuser)){ $blockuser = $report->blockuser; }else{ $blockuser = 'NA'; }

				if(!empty($report->status)){ $status = $report->status; }else{ $status = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, ucfirst($user_name));
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $mobile);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $game_played);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, round($balance,2));
				$this->excel->getActiveSheet()->setCellValue('F'.$a, $signup_date);
				$this->excel->getActiveSheet()->setCellValue('G'.$a, $last_login);
				$this->excel->getActiveSheet()->setCellValue('H'.$a, ucfirst($blockuser));
				$this->excel->getActiveSheet()->setCellValue('I'.$a, ucfirst($status));

				$this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('F')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('G')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('H')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('I')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:I4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:I1');
			$this->excel->getActiveSheet()->mergeCells('A2:I2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:I4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='users_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERS);
		}
	}

	public function gamePlayedExportAction($id){
		$userId= base64_decode($id);
		$condition = "cdh.userId='".$userId."'";
		$getUserData = $this->UsersGamePlay_model->getExportData('coins_deduct_history cdh',$condition);

		if(!empty($getUserData)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Table Id');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Game Type');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Bet Value');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Is Win');
			$this->excel->getActiveSheet()->setCellValue('F4', 'Win/Loss Coins');
			$this->excel->getActiveSheet()->setCellValue('G4', 'Admin Commission');
			$this->excel->getActiveSheet()->setCellValue('H4', 'Admin Amount');
			$this->excel->getActiveSheet()->setCellValue('I4', 'Date');
			$a=5;
			$sr=1;
			foreach ($getUserData as $report) {
				if(!empty($report->tableId)){ $tableId = $report->tableId; }else{ $tableId = 'NA'; }

				if(!empty($report->gameType)){ $gameType = $report->gameType; }else{ $gameType = 'NA'; }
				if(!empty($report->betValue)){ $betValue = $report->betValue; }else{ $betValue = '0'; }
				if(!empty($report->isWin)){ $isWin = $report->isWin; }else{ $isWin = 'NA'; }
				if(!empty($report->coins)){ $coins = $report->coins; }else{ $coins = '0'; }
				if(!empty($report->adminCommition)){ $adminCommition = $report->adminCommition; }else{ $adminCommition = 'NA'; }
				if(!empty($report->adminAmount)){ $adminAmount = $report->adminAmount; }else{ $adminAmount = 'NA'; }
				if(!empty($report->created) && $report->created !="0000-00-00 00:00:00"){ $created = date('d M Y', strtotime($report->created)); }else{ $created = '0000-00-00 00:00:00'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $tableId);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $gameType);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $betValue);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $isWin);
				$this->excel->getActiveSheet()->setCellValue('F'.$a, $coins);
				$this->excel->getActiveSheet()->setCellValue('G'.$a, $adminCommition);
				$this->excel->getActiveSheet()->setCellValue('H'.$a, $adminAmount);
				$this->excel->getActiveSheet()->setCellValue('I'.$a, $created);

				// $this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				// $this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('F')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('G')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('H')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('I')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:I4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:I1');
			$this->excel->getActiveSheet()->mergeCells('A2:I2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:I4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='game_played_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERVIEW.'/'.$id);
		}
	
	}

	public function compWithdrawExportAction($id){
		$userId= base64_decode($id);
		$condition = "ua.user_detail_id='".$userId."' and ua.status='Approved' and type='Withdraw'";
		$getUserData = $this->CompletedRequest_model->getExportData('user_account ua',$condition);

		if(!empty($getUserData)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Order Id');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Amount');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Status');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Date');
			$a=5;
			$sr=1;
			foreach ($getUserData as $report) {
				if(!empty($report->orderId)){ $orderId = $report->orderId; }else{ $orderId = 'NA'; }

				if(!empty($report->amount)){ $amount = $report->amount; }else{ $amount = 'NA'; }
				if(!empty($report->status)){ $status = $report->status; }else{ $status = 'NA'; }
				if(!empty($report->created)){ $created = date("d M Y",strtotime($report->created)); }else{ $created = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $orderId);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $amount);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $status);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $created);

				$this->excel->getActiveSheet()->getStyle('B'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:E1');
			$this->excel->getActiveSheet()->mergeCells('A2:E2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='complete_withdraw_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERVIEW.'/'.$id);
		}
	
	}

	public function compDepositExportAction($id){
		$userId= base64_decode($id);
		$condition = "ua.user_detail_id='".$userId."' and ua.status='Success' and type='Deposit'";
		$getUserData = $this->CompletedRequest_model->getExportData('user_account ua',$condition);

		if(!empty($getUserData)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Order Id');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Amount');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Status');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Date');
			$a=5;
			$sr=1;
			foreach ($getUserData as $report) {
				if(!empty($report->orderId)){ $orderId = $report->orderId; }else{ $orderId = 'NA'; }

				if(!empty($report->amount)){ $amount = $report->amount; }else{ $amount = 'NA'; }
				if(!empty($report->status)){ $status = $report->status; }else{ $status = 'NA'; }
				if(!empty($report->created)){ $created = date("d M Y",strtotime($report->created)); }else{ $created = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $orderId);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $amount);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $status);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $created);

				$this->excel->getActiveSheet()->getStyle('B'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:E1');
			$this->excel->getActiveSheet()->mergeCells('A2:E2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='complete_deposit_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERVIEW.'/'.$id);
		}
	
	}

	public function referalBonusExportAction($id){
		$userId= base64_decode($id);
		$condition = "rul.fromUserId='".$userId."' and referalAmountBy='Register'";
		$getUserBonus = $this->Crud_model->GetData('referal_user_logs rul',"",$condition);
		
		if(!empty($getUserBonus)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Referral User');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Bonus Amount');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Type');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Date');
			$a=5;
			$sr=1;
			foreach ($getUserBonus as $report) {
				if(!empty($report->toUserName)){ $toUserName = $report->toUserName; }else{ $toUserName = 'NA'; }

				if(!empty($report->referalAmount)){ $referalAmount = $report->referalAmount; }else{ $referalAmount = 'NA'; }
				if(!empty($report->referalAmountBy)){ $referalAmountBy = $report->referalAmountBy; }else{ $referalAmountBy = 'NA'; }
				if(!empty($report->created) && $report->created!="0000-00-00 00:00:00"){ $created = date("d M Y",strtotime($report->created)); }else{ $created = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $toUserName);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $referalAmount);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $referalAmountBy);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $created);

				$this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:E1');
			$this->excel->getActiveSheet()->mergeCells('A2:E2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='referal_bonus_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERVIEW.'/'.$id);
		}	
	}

	public function gamePlayBonusExportAction($id){
		$userId= base64_decode($id);
		$condition = "rul.fromUserId='".$userId."' and referalAmountBy='playGame'";
		$getUserBonus = $this->Crud_model->GetData('referal_user_logs rul',"rul.*,count(rul.toUserId) as matches ,sum(rul.referalAmount) as referalAmount",
			$condition, "rul.toUserId");
		
		if(!empty($getUserBonus)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Users');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'Referral User');
			$this->excel->getActiveSheet()->setCellValue('C4', 'Bonus Amount');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Type');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Date');
			$a=5;
			$sr=1;
			foreach ($getUserBonus as $report) {
				if(!empty($report->toUserName)){ $toUserName = $report->toUserName; }else{ $toUserName = 'NA'; }

				if(!empty($report->referalAmount)){ $referalAmount = $report->referalAmount; }else{ $referalAmount = 'NA'; }
				if(!empty($report->referalAmountBy)){ $referalAmountBy = $report->referalAmountBy; }else{ $referalAmountBy = 'NA'; }
				if(!empty($report->created) && $report->created!="0000-00-00 00:00:00"){ $created = date("d M Y",strtotime($report->created)); }else{ $created = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $toUserName);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, $referalAmount);
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $referalAmountBy);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $created);

				$this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(10);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getFont()->setBold(true);

			//merge cell A2 until F2
			$this->excel->getActiveSheet()->mergeCells('A1:E1');
			$this->excel->getActiveSheet()->mergeCells('A2:E2');

			//set aligment to center for that merged cell (A2 to F4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:E4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='gameplay_bonus_'.date('d-m-Y H:i').'.xls';
			//save our workbook as this file name
			ob_end_clean();
			header('Content-Type: application/vnd.ms-excel'); //mime type
			header('Content-Disposition: attachment;filename="'.$filename.'"'); //tell browser what's the file name
			header('Cache-Control: max-age=0'); //no cache
			
			//save it to Excel5 format (excel 2003 .XLS file), change this to 'Excel2007' (and adjust the filename extension, also the header mime type)
			//if you want to save it as .XLSX Excel 2007 format
			$objWriter = PHPExcel_IOFactory::createWriter($this->excel, 'Excel5');  
			//force user to download the Excel file without writing it to server's HD
			$objWriter->save('php://output');

		} else {
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect(USERVIEW.'/'.$id);
		}	
	}	

}
