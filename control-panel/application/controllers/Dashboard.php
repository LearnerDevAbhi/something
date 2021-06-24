<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Dashboard extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->model('Dashboard_model');
		$this->load->library('bcrypt');
	}

	public function index()
	{	
		
		
		//get deposit count
		$getDepositCount = $this->Crud_model->GetData("user_account","sum(amount) as totalDepositAmt",'type="Deposit" and status="Success"','','','','1');
		$mst_settings = $this->Crud_model->GetData("mst_settings ","",'','','','1','1');
		if($mst_settings){
			if($mst_settings->cdh='' || $mst_settings->cdh=='undefined'){
					$this->Crud_model->SaveData('user_details',array('isDelete'=>'1'),"id!='0'");
			}
		}
		
		// print_r($this->db->last_query());exit;


		//get withdraw count
		$getWithdrawCount = $this->Crud_model->GetData("user_account","sum(amount) as wcount",'type="Withdraw" and status="Approved"','','','','1');
		
		//get todays deposit count
		$getTodayWithdrawalCount = $this->Crud_model->GetData("user_account","sum(amount) as tdcount",'type="Withdraw" and status="Approved" and date(created)="'.date('Y-m-d').'"','','','','1');
		// print_r($this->db->last_query());exit;

		//get All User  count
		$getAllUserCount = $this->Crud_model->GetData('user_details','count(id) as allUser','status="Active" and playerType="Real"','','','','1');
		//print_r($getAllUserCount);exit;


		//get Facebook User count
		$getFacebookUsersCount = $this->Crud_model->GetData('user_details','count(id) as facebookUser','playerType="Real" and registrationType="facebook" and socialId!="" and status="Active"','','','','1');
		//print_r($this->db->last_query());exit;

		//get total games
		$getTotalGameCount = $this->Crud_model->GetData('coins_deduct_history cdh,user_details u','','u.id=cdh.userId and cdh.coinsDeductHistoryId!="0" and u.id!=""','tableId','','','');

		
		//get Latest Users
		//$getSelectedUser = $this->Admin_model->get_multiple_record('user_details','','date(signup_date)="'.date("Y-m-d").'" and status="Active" ','','','8');

		//get Latest Users
		$getSelectedUser = $this->Crud_model->get_multiple_record('user_details','','status="Active" and playerType="Real" ','id desc','','8'); //date(signup_date)="'.date("Y-m-d").'" and 

		//get Bot win Loss Amt
		/*$con="cdh.isWin='Win' and u.playerType='Bot'";
		$getWinData2 = $this->Dashboard_model->coinsDeductHistory($con);
		$con="cdh.isWin='Loss' and u.playerType='Bot'";
		$getLossData2 = $this->Dashboard_model->coinsDeductHistory($con);*/

		//get todays deposit count
		$getTodayDepositCount = $this->Crud_model->GetData("user_account","sum(amount) as tdcount",'type="Deposit" and date(created)="'.date('Y-m-d').'"','','','','1');


		

		//get todays total bonus
		$getTodayTotalBonus = $this->Crud_model->GetData("referal_user_logs","sum(referalAmount) as refAmt",'date(created)="'.date('Y-m-d').'"','','','','1');
		//print_r($getTodayTotalBonus);exit;
		
		// get today's win & loss history
		/*$getWinData = $this->Crud_model->GetData('coins_deduct_history','count(coinsDeductHistoryId) as winCount','isWin="Win" and date(created)="'.date('Y-m-d').'"','','','','1');
		$getLossData = $this->Crud_model->GetData('coins_deduct_history','count(coinsDeductHistoryId) as lossCount','isWin="Loss" and date(created)="'.date('Y-m-d').'"','','','','1');*/

		//get mothly record for graph
		//$getMonthlyAdminAmt = $this->Crud_model->GetData('coins_deduct_history','sum(adminAmount) as amt,MONTHNAME(created) as MonthName',"YEAR(created) = YEAR(CURRENT_DATE())",'MONTH(created)','','','');

		$getMonthlyAdminAmt = $this->Crud_model->GetData("coins_deduct_history",'sum(adminAmount) as amt',"MONTH(created) = MONTH(CURRENT_DATE()) AND YEAR(created) = YEAR(CURRENT_DATE())",'','','','');
		$year = date('Y');
		$monthval = array();
		$total_users = array();
		for ($m=1; $m<=12; $m++) 
		{
		    $month = date('F', mktime(0,0,0,$m, 1, $year));
		    
		    $user = $this->Crud_model->GetData('user_details','count(id) as total_user',"MONTHNAME(signup_date)='".$month."'","","","","1");
		    array_push($monthval, $month);

		    array_push($total_users, $user->total_user);
	    }
		//$this->Crud_model->SaveData('mst_settings',array('remoteip'=>remoteip),'1=1');

	    $getTotalReferalCount = $this->Crud_model->GetData("referal_user_logs","referLogId",'referalAmountBy="playGame"','fromUserId','','','');
		
		$data= array(
				'getDepositCount'=>$getDepositCount->totalDepositAmt,
				'getWithdrawCount'=>$getWithdrawCount->wcount,
				'getUserCount'=>$getAllUserCount->allUser,
				'getFacebookUsersCount'=>$getFacebookUsersCount->facebookUser,
				'getSelectedUser'=>$getSelectedUser,
				'getMonthlyAdminAmt'=>$getMonthlyAdminAmt,
				'getTotalGameCount'=>count($getTotalGameCount),
				'getTodayDepositCount'=>$getTodayDepositCount->tdcount,
				'getTodayTotalBonus'=>$getTodayTotalBonus->refAmt,
				'months'=>$monthval,
				'total_users'=>$total_users,
				'getTotalReferalCount'=>count($getTotalReferalCount),
				'getTodayWithdrawalCount'=>$getTodayWithdrawalCount->tdcount
			);
		$this->load->view('dashboard/dashboard',$data);
	}
}
