<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Bonus extends CI_Controller {

	public function __construct() {
		parent::__construct();
		$this->load->model('Bonus_model');
	} 

	function index() {
		$import = '<a href="" class="btn btn-info" data-target="#uploadData" data-backdrop="static" data-keyboard="false" data-toggle="modal">Import</a>';
		$data=array(
				'heading'    =>"Manage Bonus",
				'bread'      =>"Manage Bonus",
				'create_btn' => "Create",
				'import' =>$import,
				'importTitle'=>'Upload Bonus',
		        'importAction'=>site_url(BONUSIMPORT),
		        'importSheet'=>base_url('assets/import/Bonus.xlsx'),
				);
		$this->load->view('bonus/list',$data);
	}

	function ajax_manage_page() {
		$no = 0;
		if($_POST['start']) {
			$no = $_POST['start'];
		}

		$getBonusData = $this->Bonus_model->get_datatables('mst_settings bs');
		$data = array();

		foreach ($getBonusData as $listData) {
			$btn = '';
			
			$btn = ' <a href="'.site_url(BONUUPDATEE.'/'.base64_encode($listData->id)).'"><button type="button" class="btn btn-success btn-xs" title="Edit"><i class="fa fa-edit"></i></button></a>';
			// $btn .= ' <button type="button" class="btn btn-danger btn-xs" title="Delete" onclick="return deleteBonus('.$listData->bonusId.')"><i class="fa fa-trash-o"></i></button>';

			$no++;
			$nestedData   = array();
			$nestedData[] = $no;
			$nestedData[] = $listData->referralBonus;
			$nestedData[] = $listData->signupBonus;
			$nestedData[] = $listData->cashBonus;
			$nestedData[] = date('d-m-Y H:i:s',strtotime($listData->modified));
			$nestedData[] = $btn;

			$data[]       = $nestedData;
		}

		$output = array(
			'draw'            => $_POST['draw'],
			'recordsTotal'    => $this->Bonus_model->count_all('mst_settings bs'),
			'recordsFiltered' => $this->Bonus_model->count_filtered('mst_settings bs'),
			'data'            => $data,
			"csrfHash"        => $this->security->get_csrf_hash(),
			"csrfName"        => $this->security->get_csrf_token_name(),
		);

		echo json_encode($output);
	}

	// function create() {
	// 	$data=array(
	// 			'breadhead'       => "Manage Bonus",
	// 			'heading'         => "Create Bonus",
	// 			'bread'           => "Create Bonus",
	// 			'button'          => "Create",
	// 			'bonusId'         =>'0',
	// 			'referalBonus' => set_value('referalBonus',$this->input->post('referalBonus',TRUE)),
	// 			'signupBonus' => set_value('signupBonus',$this->input->post('signupBonus',TRUE)),
	// 			'cashBonus' => set_value('cashBonus',$this->input->post('cashBonus',TRUE)),
	// 			'action'          => site_url(BONUSCREATEACTION)
	// 		);
	// 	$this->load->view('bonus/form',$data);
	// }

	function update($id) {
		$bonusId = base64_decode($id);
		$getData = $this->Crud_model->GetData('mst_settings','','id="'.$bonusId.'"','','','','1');
		$data = array(
			'breadhead'       => "Manage Bonus",
			'heading'         => "Update Bonus",
			'bread'           => "Update Bonus",
			'button'          => "Update",
			'bonusId'=>$getData->id,
			'referalBonus'=>$getData->referralBonus,
			'signupBonus'=>$getData->signupBonus,
			'cashBonus'=>$getData->cashBonus,
			'action' => site_url(BONUSUPDATEACTION)
		);
		$this->load->view('bonus/form',$data);
	}

	function updateAction(){
		$this->bonusRules();
		if($this->form_validation->run() == FALSE) {
			$id = base64_encode($this->input->post('bonusId'));
			$this->update($id);
		}else {
			$data = array(
				'referralBonus'      => $this->input->post('referalBonus'),
				'signupBonus' => $this->input->post('signupBonus'),
				'cashBonus' => $this->input->post('cashBonus'),
				'modified'=> date('Y-m-d H:i:s'),
			);
			$con = "id='".$this->input->post('bonusId')."'";
			$this->Crud_model->SaveData('mst_settings',$data,$con);
			$this->session->set_flashdata('message','Bonus updated successfully.');
			redirect(BONUS);
		}
	}

	// function createAction() {
	// 	$this->bonusRules();
	// 	if($this->form_validation->run() == FALSE) {
	// 		$this->create();
	// 	}else {
	// 		$data = array(
	// 			'referalBonus'      => $this->input->post('referalBonus'),
	// 			'signupBonus' => $this->input->post('signupBonus'),
	// 			'cashBonus' => $this->input->post('cashBonus'),
	// 		);

	// 		$this->Crud_model->SaveData('bonus',$data);
	// 		$this->session->set_flashdata('message','Bonus created successfully.');
	// 		redirect(BONUS);
	// 	}
	// }

	function bonusRules() {
		// $this->form_validation->set_rules('referralBonus',"referal bonus","required|XSS_clean",array('required'=>'Please enter %s'));
		$this->form_validation->set_rules('signupBonus',"signup bonus","required",array('required'=>'Please enter %s'));
		$this->form_validation->set_rules('cashBonus',"cash bonus","required",array('required'=>'Please enter %s'));
	}

	// function changeBonusStatus() {
	// 	$response = array(
	// 	            'csrfName' => $this->security->get_csrf_token_name(),
	// 	            'csrfHash' => $this->security->get_csrf_hash(),
	// 	        );
	// 	$cond = "bonusId = '".$this->input->post('id',TRUE)."'";
	// 	$statusData = $this->input->post('status',TRUE);
	// 	if($statusData == 'apply') {
	// 		$status = 'Active';
	// 	} else {
	// 		$status = 'Inactive';
	// 	}

	// 	$data=array(
	// 			'status'=>$status,
	// 		);

	// 	$this->Crud_model->SaveData("bonus",$data,$cond);
		
	// 	$msg='Bonus '.$statusData.' successfully.';
	// 	$response['msg']=$msg;
	// 	echo json_encode($response);
	// }

	// function deleteBonus() {
	// 	$cond = "bonusId = '".$this->input->post('id')."'";
	// 	$getData = $this->Crud_model->GetData("bonus",'',$cond,'','','','1');

	// 	if($getData) {
	// 		$this->Crud_model->DeleteData("bonus",$cond,'1');
	// 		$msg='Bonus has been deleted successfully.';
	// 	}else{
	// 		$msg='Bonus not deleted.';
	// 	}

	// 	$response = array(
	// 		'csrfName' => $this->security->get_csrf_token_name(),
	// 		'csrfHash' => $this->security->get_csrf_hash(),
	// 		'msg'      => $msg
	// 	);
	// 	echo json_encode($response);
	// }

	// public function import()
	// {
	// 	$file = $_FILES['excel_file']['tmp_name'];
 //        $this->load->library('excel');

 //        $objPHPExcel = PHPExcel_IOFactory::load($file);
	//     $allDataInSheet = $objPHPExcel->getActiveSheet()->toArray(null,true);
	//     $arrayCount = count($allDataInSheet);

	//     $fields_fun =array();
	//     $i = 1;
	//     foreach ($allDataInSheet as $val) 
	//     {
	//        if ($i == 1) 
	//        {
	//        }else{
	//             $fields_fun[] = $val;
	//        }
	//        $i++;
	//     } 
	//     if(!$fields_fun)
	//     {
	//         $msg = $this->session->set_flashdata('message', 'Excel sheet is blank.');
	// 	    redirect(BONUS);
	//     }
	//     else
	//     {
	//     	$data = $fields_fun;
	//     	$numMsg = 0;
	//     	$duplicate = 0;
	//     	foreach ($data as $val) 
	//    		{
	//    			if(isset($val[0]) && isset($val[1]))
	//    			{
	//    				$getData = $this->Crud_model->GetData('mst_bonus','','newOffers="'.$val[0].'"','','','','');

	//    				$val1 = $val[0];
	//        			$val2 = $val[1];
	//        			if(!preg_match('/^[0-9]*$/', $val1) && !preg_match('/^[0-9]*$/', $val2))
	//        			{
	//        				$numMsg +=1;
	//        		    }
	//        		    else if(!empty($getData))
	//        		    {
	//        		    	$duplicate +=1;
	//        		    }
	//        		    else
	//        		    {
	//        		    	$data = array(
	//        		    		'newOffers'=>$val1,
	//        		    		'applyOnDeposit'=>$val1
	//        		    	);
	//        		    	$this->Crud_model->SaveData('mst_bonus',$data);
	//        		    }
	//    			}
	//    		}
	//    		$msg = "";
	//    		if($numMsg!=0)
	//    		{
	//    			$msg .= " Invalid Record";
	//    		}
	//    		if($duplicate!=0)
	//    		{
	//    			$msg .= " Record is Duplicate";
	//    		}
	//    		if($numMsg==0 && $duplicate==0)
	//    		{
	//    			$msg = " Record is Imported Successfully.";
	//    		}
	//    		$this->session->set_flashdata('message', '<p>'.$msg.'</p>');
	//    		redirect(BONUS);
	//     }
	// }
}
?>