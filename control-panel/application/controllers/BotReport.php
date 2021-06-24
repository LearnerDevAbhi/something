<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class BotReport extends CI_Controller 
{
	public function __construct()
	{
		parent::__construct();
	    $this->load->model('BotReport_model');
	    $this->load->library('upload');
	    $this->load->library('image_lib');
	}

	public function index($isWinLoss='')
	{
		$getGameType = $this->Crud_model->GetData('ludo_mst_rooms','roomTitle');
		$data=array(
			'heading'=>"Manage Bot  Report",
			'bread'=>"Manage  Bot Report",
			'getGameType'=>$getGameType,
			'isWinLoss'=>$isWinLoss,
		);
		$this->load->view('botReport/list',$data);
	}

	public function ajax_manage_page($isWinLoss='')
	{
		//print_r($_POST);exit();
		$SearchData = $this->input->post('SearchData');
		$SearchData1 = $this->input->post('SearchData1');
		$SearchData2 = $this->input->post('SearchData2');
		$SearchData3 = $this->input->post('SearchData3');
		$SearchData4 = $this->input->post('SearchData4');
		
		$cond = "cdh.coinsDeductHistoryId!='0' and u.id!='' and u.playerType='Bot'";
		//select * from *table_name* where *datetime_column* >= '01/01/2009' and *datetime_column* <= curdate()
		
		if(!empty($SearchData)){
			$cond .= " and  date(cdh.created) >= '".date("Y-m-d",strtotime($SearchData))."'";
		}
		if(!empty($SearchData1)){
			$cond .= " and  date(cdh.created) <= '".date("Y-m-d",strtotime($SearchData1))."'";
		}
		if(!empty($SearchData2)){
			$cond .= " and cdh.isWin='".$SearchData2."'";
		}
		if(!empty($SearchData3)){
			$cond .= " and cdh.gameType LIKE '%".$SearchData3."%'";
		}
		

		$getUsers = $this->BotReport_model->get_datatables('coins_deduct_history cdh',$cond);
		//print_r($this->db->last_query());exit();
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();


		foreach ($getUsers as $userData) 
		{
			if($userData->isWin=='Win'){
				$sign = '+ ';
			}else{
				$sign = '- ';
			}

			// if($userData->playerType=='Bot' && $userData->isWin=='Loss'){
			// 	$percent = $userData->coins / 100  * $userData->adminCommition;
			// 	$coins= $userData->coins - $percent;
			// }else{
			// }
			$coins= $userData->coins;

			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($userData->user_name);
         	$nestedData[] = $userData->mobile;
         	$nestedData[] = $userData->playerType;
		    $nestedData[] = $userData->tableId;
		    $nestedData[] = ucfirst($userData->game);
		    $nestedData[] = $userData->gameType;
		    $nestedData[] = $userData->betValue;
		    $nestedData[] = $userData->isWin;
		    $nestedData[] = $sign."".$coins;
		    $nestedData[] = $userData->adminCommition.'%';
		    $nestedData[] = $userData->adminAmount;
		    $nestedData[] = date('d-m-Y H:i:s',strtotime($userData->created));
		    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->BotReport_model->count_all('coins_deduct_history cdh',$cond),
					"recordsFiltered" => $this->BotReport_model->count_filtered('coins_deduct_history cdh',$cond),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}

}