<?php
defined('BASEPATH') OR exit('No direct script access allowed');
// This can be removed if you use __autoload() in config.php OR use Modular Extensions
require APPPATH.'/libraries/REST_Controller.php';
class play24x7Distribution extends REST_Controller 
{
	function __construct()
	{
		parent::__construct();
		$this->load->model('Api_model');
	}

	public function bettingAmountDistribution_post() {
		$this->_request = file_get_contents("php://input");
		$jsonDecodeData =json_decode($this->_request, true); 
		if(!empty($jsonDecodeData['userId']) && !empty($jsonDecodeData['userAmount']) && !empty($jsonDecodeData['totalAmount'])) {
			$userId = $jsonDecodeData['userId'];
			$userAmount = $jsonDecodeData['userAmount'];
			$totalAmount = $jsonDecodeData['totalAmount'];
			$gameType = $jsonDecodeData['gameType'];
			$adminPercent = $jsonDecodeData['adminPercent'];
			//$isAdminPercent = $jsonDecodeData['isAdminPercent'];

			$getUserData =  $this->Api_model->GetData('user_details','referal_code,franchise_code',"id='".$userId."'",'','','','1');
			if(!empty($getUserData)) {

				/* Get User Percent */
				$getUserPercent = ($userAmount * 100) / $totalAmount;

				/* Get Admin Amount */
				$getAdminPercent = $this->Api_model->GetData('web_settings','admin_commission',"id!='0'",'','','','1');
			
				if(!empty($adminPercent))
				{
					$getAdminAmount = ($totalAmount * $adminPercent) / 100;
				}else{
					$getAdminAmount = ($totalAmount * $getAdminPercent->admin_commission) / 100;
				}
				$getUserAmt_fromAdminAmt = ($getAdminAmount * $getUserPercent) / 100;

				if(!empty($getUserData->used_referal_code) && empty($getUserData->franchise_code)){

					$getRefUser =  $this->Api_model->GetData('user_details','id,coins',"referred_by='".$getUserData->referal_code."'",'','','','1');
					$randNum = mt_rand(100000, 999999);
					$refUserAmount = 0;
					if(!empty($getRefUser)) {
						$refUserAmount = ($getUserAmt_fromAdminAmt * $getAdminPercent->userTouserCommPercent) / 100;
						$refUserData = array(
							'user_id' => $getRefUser->id,
							'from_user_id' => $userId,
							'precentage' => $getAdminPercent->userTouserCommPercent,
							'deposit_coins' => $refUserAmount,
							'total_balance' => $getRefUser->coins + $refUserAmount,
							'date' => date("Y-m-d H:i:s"),
							'type' => 'Coins',
							'game_type' => $gameType,
							'transactionId' => $randNum.'UTU',
						);
						$this->Crud_model->SaveData("web_coins",$refUserData); 

						$updateUserCoins = array(
							'coins'=> $getRefUser->coins + $refUserAmount,
						);
						$this->Crud_model->SaveData("user_details",$updateUserCoins,"id='".$getRefUser->id."'");
						
					}

					$admin_remain_amt = ($getUserAmt_fromAdminAmt - $refUserAmount);
					/* Save Admin Amount */
					$getAdminData=$this->Crud_model->GetData("web_admins","id,admin_total_coins","id!='0'",'','','','1'); // Get web_admins data
					if (!empty($getAdminData->admin_total_coins)) {
						$adminTotalAmt = $getAdminData->admin_total_coins + $admin_remain_amt;
					} else {
						$adminTotalAmt = $admin_remain_amt; 
					}
					$updateAdminData = array(
						'admin_total_coins'=>$adminTotalAmt,
					);
					$this->Crud_model->SaveData("web_admins",$updateAdminData,"id!='0'");
					$saveAdminLogData = array(
						'from_user_details_id'=>$userId,
						'to_web_admins_id'=>$getAdminData->id,
						'total_coins'=>$admin_remain_amt,
						'type'=>'deposit',
						'game_type'=>$gameType,
					);
					$this->Crud_model->SaveData("web_admin_account_log",$saveAdminLogData);

					$response = array('status' => TRUE, 'success' => 1, 'message' => "Amount Distribute Successfully.");
					$this->set_response($response, REST_Controller::HTTP_OK);

				}else if(!empty($getUserData->franchise_code)) {
					$getFranData = $this->Api_model->GetData("web_franchisees","id,fran_code,comm_percent,total_coins,parent_id","fran_code='".$getUserData->franchise_code."'","","","","1");

					if (!empty($getFranData->parent_id)) {
						$saveData = array(
							'web_franchisees_id'=>$getFranData->id,
							'commPercent'=>$getFranData->comm_percent,
							'getUserAmt_fromAdminAmt'=>$getUserAmt_fromAdminAmt,
							'total_coins'=>$getFranData->total_coins,
							'franCode'=>$getUserData->franchise_code,
							'userId'=>$userId,
							'gameType'=>$gameType,
						);
						$adminRemainAmount = $this->saveAllFranchiseData($saveData);

						$subFranData = array(
							'parentId'=>$getFranData->parent_id,
							'commPercent'=>$getFranData->comm_percent,
							'getUserAmt_fromAdminAmt'=>$getUserAmt_fromAdminAmt,
							'adminRemainAmount'=>$adminRemainAmount,
							'franCode'=>$getUserData->franchise_code,
							'userId'=>$userId,
							'gameType'=>$gameType,
						);
						$this->getParentFranchiseData($subFranData);
					} else {
						$saveData = array(
							'web_franchisees_id'=>$getFranData->id,
							'commPercent'=>$getFranData->comm_percent,
							'getUserAmt_fromAdminAmt'=>$getUserAmt_fromAdminAmt,
							'total_coins'=>$getFranData->total_coins,
							'franCode'=>$getUserData->franchise_code,
							'userId'=>$userId,
							'gameType'=>$gameType,
						);
						$adminRemainAmount = $this->saveAllFranchiseData($saveData);

						$admin_remain_amount = $adminRemainAmount;
						/* Referal user to user commission */
						if(!empty($getUserData->used_referal_code)){
							$getRefUser =  $this->Api_model->GetData('user_details','id,coins',"referal_code='".$getUserData->used_referal_code."'",'','','','1');

							$refUserAmount = 0;
							if(!empty($getRefUser)) {
								$refUserAmount = ($admin_remain_amount * $getAdminPercent->userTouserCommPercent) / 100;
								$randNum = mt_rand(100000, 999999);
								$refUserData = array(
									'user_id' => $getRefUser->id,
									'from_user_id' => $userId,
									'precentage' => $getAdminPercent->userTouserCommPercent,
									'deposit_coins' => $refUserAmount,
									'total_balance' => $getRefUser->coins + $refUserAmount,
									'date' => date("Y-m-d H:i:s"),
									'type' => 'Coins',
									'game_type' => $gameType,
									'transactionId' => $randNum.'UTU',
								);
								$this->Crud_model->SaveData("web_coins",$refUserData); 

								$updateUserCoins = array(
									'coins'=> $getRefUser->coins + $refUserAmount,
								);
								$this->Crud_model->SaveData("user_details",$updateUserCoins,"id='".$getRefUser->id."'");
								
							}

							$admin_remain_amount = ($admin_remain_amount - $refUserAmount);
						}

						/* Save Admin Amount */
							$getAdminData=$this->Crud_model->GetData("web_admins","id,admin_total_coins","id!='0'",'','','','1'); // Get web_admins data
							if (!empty($getAdminData->admin_total_coins)) {
								$adminTotalAmt = $getAdminData->admin_total_coins + $admin_remain_amount;
							} else {
								$adminTotalAmt = $admin_remain_amount; 
							}
							$updateAdminData = array(
								'admin_total_coins'=>$adminTotalAmt,
							);
							$this->Crud_model->SaveData("web_admins",$updateAdminData,"id!='0'");

							$saveAdminLogData = array(
								'from_user_details_id'=>$userId,
								'to_web_admins_id'=>$getAdminData->id,
								'total_coins'=>$admin_remain_amount,
								'type'=>'deposit',
								'game_type'=>$gameType,
							);
							$this->Crud_model->SaveData("web_admin_account_log",$saveAdminLogData);
						$response = array('status' => TRUE, 'success' => 1, 'message' => "Amount Distribute Successfully.");
						$this->set_response($response, REST_Controller::HTTP_OK);
					}
				} else {
					/* Save Admin Amount */
						$getAdminData=$this->Crud_model->GetData("web_admins","id,admin_total_coins","id!='0'",'','','','1'); // Get web_admins data
						if (!empty($getAdminData->admin_total_coins)) {
							$adminTotalAmt = $getAdminData->admin_total_coins + $getUserAmt_fromAdminAmt;
						} else {
							$adminTotalAmt = $getUserAmt_fromAdminAmt; 
						}
						$updateAdminData = array(
							'admin_total_coins'=>$adminTotalAmt,
						);
						$this->Crud_model->SaveData("web_admins",$updateAdminData,"id!='0'");

						$saveAdminLogData = array(
							'from_user_details_id'=>$userId,
							'to_web_admins_id'=>$getAdminData->id,
							'total_coins'=>$getUserAmt_fromAdminAmt,
							'type'=>'deposit',
							'game_type'=>$gameType,
						);
						$this->Crud_model->SaveData("web_admin_account_log",$saveAdminLogData);
					$response = array('status' => TRUE, 'success' => 1, 'message' => "Amount Distribute Successfully.");
					$this->set_response($response, REST_Controller::HTTP_OK);
				}
			} else {
				$response = array('status' => FALSE, 'success' => 0, 'message' => "Invalid userId");
				$this->set_response($response, REST_Controller::HTTP_OK);
			}
		} else {
			if($jsonDecodeData['userAmount'] == 0) {
				$response = array('status' => TRUE, 'success' => 1, 'message' => "User betting amount is zero");
				$this->set_response($response, REST_Controller::HTTP_OK);	
			} else {
				$response = array('status' => FALSE, 'success' => 0, 'message' => "Please provide all fields.");
				$this->set_response($response, REST_Controller::HTTP_OK);
			}
		}
	}

	public function getParentFranchiseData($data) {
		$getParentFranData = $this->Api_model->GetData("web_franchisees","id,fran_code,comm_percent,total_coins,parent_id","id='".$data['parentId']."'","","","","1");
		if(!empty($getParentFranData->parent_id)) {
			$divPercent = $getParentFranData->comm_percent - $data['commPercent'];
			$saveData = array(
				'web_franchisees_id'=>$getParentFranData->id,
				'commPercent'=>$divPercent,
				'getUserAmt_fromAdminAmt'=>$data['getUserAmt_fromAdminAmt'],
				'adminRemainAmount'=>$data['adminRemainAmount'],
				'total_coins'=>$getParentFranData->total_coins,
				'parent_id'=>$getParentFranData->parent_id,
				'franCode'=>$data['franCode'],
				'userId'=>$data['userId'],
				'gameType'=>$data['gameType'],
			);
			$admin_Amount = $this->saveAllFranchiseData($saveData);
			$subFranData = array(
				'parentId'=>$getParentFranData->parent_id,
				'commPercent'=>$getParentFranData->comm_percent,
				'getUserAmt_fromAdminAmt'=>$data['getUserAmt_fromAdminAmt'],
				'adminRemainAmount'=>$admin_Amount,
				'franCode'=>$data['franCode'],
				'userId'=>$data['userId'],
				'gameType'=>$data['gameType'],
			);
			$this->getParentFranchiseData($subFranData);
		} else {
			$divPercent = $getParentFranData->comm_percent - $data['commPercent'];
			$saveData = array(
				'web_franchisees_id'=>$getParentFranData->id,
				'commPercent'=>$divPercent,
				'getUserAmt_fromAdminAmt'=>$data['getUserAmt_fromAdminAmt'],
				'adminRemainAmount'=>$data['adminRemainAmount'],
				'total_coins'=>$getParentFranData->total_coins,
				'parent_id'=>$getParentFranData->parent_id,
				'franCode'=>$data['franCode'],
				'userId'=>$data['userId'],
				'gameType'=>$data['gameType'],
			);
			$adminRemainAmount = $this->saveAllFranchiseData($saveData);

			$admin_remain_amt = $adminRemainAmount;

			/* Get Users Amount */
			$getUserData =  $this->Api_model->GetData('user_details','used_referal_code,franchise_code',"id='".$data['userId']."'",'','','','1'); 
			/* Get Admin Amount */
				$getAdminPercent = $this->Api_model->GetData('web_settings','admin_commission,userTouserCommPercent',"id!='0'",'','','','1');
			/* Referal user to user commission */
			if(!empty($getUserData->used_referal_code)){
				$getRefUser =  $this->Api_model->GetData('user_details','id,coins',"referal_code='".$getUserData->used_referal_code."'",'','','','1');

				$refUserAmount = 0;
				if(!empty($getRefUser)) {
					$refUserAmount = ($admin_remain_amt * $getAdminPercent->userTouserCommPercent) / 100;
					$randNum = mt_rand(100000, 999999);
					$refUserData = array(
						'user_id' => $getRefUser->id,
						'from_user_id' => $data['userId'],
						'precentage' => $getAdminPercent->userTouserCommPercent,
						'deposit_coins' => $refUserAmount,
						'total_balance' => $getRefUser->coins + $refUserAmount,
						'date' => date("Y-m-d H:i:s"),
						'type' => 'Coins',
						'game_type' => $data['gameType'],
						'transactionId' => $randNum.'UTU',
					);
					$this->Crud_model->SaveData("web_coins",$refUserData); 

					$updateUserCoins = array(
						'coins'=> $getRefUser->coins + $refUserAmount,
					);
					$this->Crud_model->SaveData("user_details",$updateUserCoins,"id='".$getRefUser->id."'");
					
				}

				$admin_remain_amt = ($admin_remain_amt - $refUserAmount);
			}

			/* Save Admin Amount */
				$getAdminData=$this->Crud_model->GetData("web_admins","id,admin_total_coins","id!='0'",'','','','1'); // Get web_admins data
				if (!empty($getAdminData->admin_total_coins)) {
					$adminTotalAmt = $getAdminData->admin_total_coins + $admin_remain_amt;
				} else {
					$adminTotalAmt = $admin_remain_amt; 
				}
				$updateAdminData = array(
					'admin_total_coins'=>$adminTotalAmt,
				);
				$this->Crud_model->SaveData("web_admins",$updateAdminData,"id!='0'");

				$saveAdminLogData = array(
					'from_user_details_id'=>$data['userId'],
					'to_web_admins_id'=>$getAdminData->id,
					'total_coins'=>$admin_remain_amt,
					'type'=>'deposit',
					'game_type'=>$data['gameType'],
				);
				$this->Crud_model->SaveData("web_admin_account_log",$saveAdminLogData);

			$response = array('status' => TRUE, 'success' => 1, 'message' => "Amount Distribute Successfully.");
			$this->set_response($response, REST_Controller::HTTP_OK);
		}
	}

	public function saveAllFranchiseData($data) {
		$getmainFranData = $this->Api_model->GetData("web_franchisees","id,fran_code,comm_percent,total_coins,parent_id","id='".$data['web_franchisees_id']."' and fran_code='".$data['franCode']."'","","","","1");

		$from_franchisees_id = 0;	
		$from_user_details_id = 0;	
		if (empty($getmainFranData)) {
			$getFromFranData = $this->Api_model->GetData("web_franchisees","id,fran_code,comm_percent,total_coins,parent_id","parent_id='".$data['web_franchisees_id']."' and fran_code='".$data['franCode']."'","","","","1");
			$from_franchisees_id += $getFromFranData->id;
		}
		if(!empty($getmainFranData)) {
			if ($data['franCode'] == $getmainFranData->fran_code) {
				$from_user_details_id += $data['userId'];
			}
		}

		$calAmt = ($data['getUserAmt_fromAdminAmt'] * $data['commPercent']) / 100;
		$totalAmt = $data['total_coins'] + $calAmt;
		$franData = array(
			'total_coins'=>$totalAmt,
		);
		$this->Api_model->SaveData("web_franchisees",$franData,"id='".$data['web_franchisees_id']."'");

		$savefranLogData = array(
			'to_franchisees_id'=>$data['web_franchisees_id'],
			'from_user_details_id'=>$from_user_details_id,
			'from_franchisees_id'=>$from_franchisees_id,
			'betting_coins'=>$calAmt,
			'precentage'=>$data['commPercent'],
			'type'=>'deposit',
			'game_type'=>$data['gameType'],
		);
		$this->Crud_model->SaveData("web_franchisees_account_log",$savefranLogData);
		/* Save Admin Amount */
		if(!empty($data['adminRemainAmount'])) {
			$admin_amt= $data['adminRemainAmount'] - $calAmt;
		} else {
			$admin_amt = $data['getUserAmt_fromAdminAmt'] - $calAmt;
		}
		return $data['adminRemainAmount'] = $admin_amt;
	}
}
?>