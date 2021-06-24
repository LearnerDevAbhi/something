<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class CouponCodes extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->model("CouponCode_model");
		$this->load->helper('string');
	}

	public function index()
	{
		$import = '<a class="btn btn-success" data-target="#uploadData" data-toggle="modal">Import</a>';
		$data = array(
			'heading' => 'Manage Coupon Codes',
			'bread' => 'Manage Coupon Codes',
			'create_button' => 'Create',
			'import' => $import,
			'importTitle' => 'Import Coupon Codes',
			'importAction'=>site_url('CouponCodes/Import'),
			'importSheet'=>base_url('uploads/excel_files/CouponCode.xlsx'),
		
		);
		$this->load->view('couponCode/list',$data);
	}

	public function ajax_manage_page(){
		
		$getCouponCode = $this->CouponCode_model->get_datatables("coupon_codes cc");
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getCouponCode as $row) 
		{
			
			$btn = '';
        	 $btn =''.anchor(site_url(COUPONCODEUPDATE.'/'.base64_encode($row->id)),'<button title="Edit" class="btn btn-info btn-circle btn-xs"><i class="fa fa-edit"></i></button>');
         	
        	$btn .="&nbsp;|&nbsp;". "<button title='Delete' class='btn btn-danger btn-xs' onclick='return deleteCouponCode(".$row->id.");'><i class='fa fa-trash-o'></i></button>";

            if($row->status=='Active')  
			$status="<span id='status_span".$row->id."' onclick='return change_status(".$row->id.");'  style='cursor:pointer;' class='label label-success' > Active </span>";
			else
			$status="<span id='status_span".$row->id."' onclick='return change_status(".$row->id.");'  style='cursor:pointer;' class='label label-danger' > Inactive </span>";

			if(!empty($row->title)){ $title = $row->title; }else{ $title = 'N/A'; }
			if(!empty($row->description)){ $description = $row->description; }else{ $description = 'N/A'; }
			if(!empty($row->isExpired)){ $isExpired = $row->isExpired; }else{ $isExpired = 'N/A'; }
			if($row->expiredDate!='0000-00-00'){ $expiredDate = $row->expiredDate; }else{ $expiredDate = 'N/A'; }
			if(!empty($row->discount)){ $discount = $row->discount; }else{ $discount = 'N/A'; }
			if(!empty($row->couponCode)){ $couponCode = $row->couponCode; }else{ $couponCode = 'N/A'; }

			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($title);
         	$nestedData[] = $description;
         	// $nestedData[] = $isExpired;
         	$nestedData[] = $expiredDate;
         	$nestedData[] = $discount;
         	$nestedData[] = $couponCode;
         	$nestedData[] = $row->isUsed;
         	$nestedData[] = $status;
            $nestedData[] = $btn;    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->CouponCode_model->count_all("coupon_codes cc"),
					"recordsFiltered" => $this->CouponCode_model->count_filtered("coupon_codes cc"),
					"data" => $data,
				);
		echo json_encode($output);
	}

	public function create(){
		$code = random_string('alnum',6);
		$data = array(
				'heading' => 'Create Coupon Code',
				'breadhead' => 'Manage Coupon Codes',
				'bread' => 'Create Coupon Code',
				'button' => 'Create',
				'action' => site_url(COUPONCODECREATEACTION),
				'title' => set_value('title',$this->input->post('title',TRUE)),
				'description' => set_value('description',$this->input->post('description',TRUE)),
				// 'isExpired' => set_value('isExpired',$this->input->post('isExpired',TRUE)),
				'expiredDate' => set_value('expiredDate',$this->input->post('expiredDate',TRUE)),
				'discount' => set_value('discount',$this->input->post('discount',TRUE)),
				'couponCode' => $code,
				'status' => set_value('status',$this->input->post('status',TRUE)),
				'id' => '0',
				'code' => $code,
			);
		$this->load->view('couponCode/form',$data);

	}


	public function createAction(){

	$id=0;
	$this->setRules($id);
	if($this->form_validation->run()==false){
			$this->create();
		}else{
			
			$data = array(
	 					'title' => $this->input->post('title',TRUE),
	 					'description' => $this->input->post('description',TRUE),
	 					// 'isExpired' => $this->input->post('isExpired',TRUE),
	 					'expiredDate' => $this->input->post('expiredDate',TRUE),
	 					'discount' => $this->input->post('discount',TRUE),
	 					'couponCode' => $this->input->post('couponCode',TRUE),
	 					'status' => $this->input->post('status',TRUE),
	 					'created' => date("Y-m-d H:i:s"),
	 				);

			$this->Crud_model->SaveData('coupon_codes',$data);
			//print_r($this->db->last_query());exit();
			$msg = $this->session->set_flashdata('message', '<label class="alert-success padd">Coupon Code has been created successfully</label>');
	 			redirect(COUPONCODE);
		}
}

public function updateAction($sid){
	$id=base64_decode($sid);
	
     	$this->setRules($id);
		if($this->form_validation->run()==false){
			
			$this->update(base64_encode($id));
		}else{
			
	        $data=array(
			'title' => $this->input->post('title',TRUE),
	 		'description' => $this->input->post('description',TRUE),
	 		// 'isExpired' => $this->input->post('isExpired',TRUE),
	 		'expiredDate' => $this->input->post('expiredDate',TRUE),
	 		'discount' => $this->input->post('discount',TRUE),
	 		'couponCode' => $this->input->post('couponCode',TRUE),
	 		'status' => $this->input->post('status',TRUE),
			'modified' => date("Y-m-d H:i:s"),
		);
	        if($_POST['isExpired']=='No')
	        	$data['expiredDate']='0000-00-00';
	        $cond="id='".$id."'";
	    	$this->Crud_model->SaveData("coupon_codes",$data,$cond);
            $msg = $this->session->set_flashdata('message', '<label class="alert-success padd">Coupon Code has been updated successfully</label>');
	 			redirect(COUPONCODE);    
        }
}

	
	public function update($id){
        $id=base64_decode($id);
		$cond = "id = '".$id."'";
		$getcoupon_codes = $this->Crud_model->GetData("coupon_codes",'',$cond,'','','','1');
		
		$data = array(
			'heading' => 'Update Coupon Code',
			'breadhead' => 'Manage Coupon Codes',
			'bread' => 'Update Coupon Code',
			'button' => 'Update',
			'action' => site_url(COUPONCODEUPDATEACTION.'/'.base64_encode($id)),
			'title' => set_value('title',$getcoupon_codes->title),
			'description' => set_value('description',$getcoupon_codes->description),
			// 'isExpired' => set_value('isExpired',$getcoupon_codes->isExpired),
			'expiredDate' => set_value('expiredDate',$getcoupon_codes->expiredDate),
			'discount' => set_value('discount',$getcoupon_codes->discount),
			'couponCode' => set_value('couponCode',$getcoupon_codes->couponCode),
			'status' => set_value('status',$getcoupon_codes->status),
			'id' => set_value('id',$getcoupon_codes->id),
			
		);
		
		$this->load->view('couponCode/form',$data);
	}


	public function delete()
	{
		$id = $this->input->post('id',TRUE);
		if(!empty($id))
		{
			$this->Crud_model->DeleteData("coupon_codes","id='".$id."'",'');
			
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

	public function statusChange()
	{
		$table = "coupon_codes";
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


	public function setRules($id){
		// $SpinRoll = $this->Crud_model->GetData('coupon_codes','',"title='".$this->input->post('title',TRUE)."' and id != '".$id."'");
		
		// $isunique = '';
		// if($SpinRoll) {
		// 	$isunique = "|is_unique[coupon_codes.title]";
		// }
	    $this->form_validation->set_rules('title','title', 'trim|required',
	    	array(
			'required' => 'Please enter %s',
			// 'is_unique' => ' Coupon title is already exist',
		));

		$this->form_validation->set_rules('description','description', 'trim|required',
	    	array(
			'required' => 'Please enter %s',
			
		));

		// $this->form_validation->set_rules('expiredDate','expired date', 'trim|required',
	 //    	array(
		// 	'required' => 'Please enter %s',
			
		// ));

		$this->form_validation->set_rules('discount','discount', 'trim|required',
	    	array(
			'required' => 'Please enter %s',
			
		));

		$this->form_validation->set_rules('couponCode','coupon code', 'trim|required',
	    	array(
			'required' => 'Please enter %s',
			
		));
	}

	public function Import()
    {  

	    $file = $_FILES['excel_file']['tmp_name'];
	    $this->load->library('excel');
	      
	    $objPHPExcel = PHPExcel_IOFactory::load($file);
	    $allDataInSheet = $objPHPExcel->getActiveSheet()->toArray(null,true);
	    $arrayCount = count($allDataInSheet);
	    $fields_fun =array();
	    $i = 1;
        foreach ($allDataInSheet as $val) 
        {
	        if ($i == 1) 
	        {
	        } else {
	            $fields_fun[] = $val;
	        }
	        $i++;
        }  
   
	    if(!$fields_fun)
	    {
	    	$this->session->set_flashdata('message', 'Excel sheel is blank');
	    	redirect(site_url(COUPONCODE));
	    }
	    else
	    {
		  	$data = $fields_fun;
		    $exists = 0;
		    $notinsert= '';
		    $ducplicat =0;
		    $insert = 0;
		    // $code = random_string('alnum',6);
	        foreach ($data as $val) 
		    {
		      	if(isset($val[0]) && isset($val[1]) && isset($val[2]) && isset($val[3]) && isset($val[4]))
		        {
		        	// $getTitle = $this->Crud_model->GetData('coupon_codes','',"title='".$val[0]."'",'','','');

		        	if(!preg_match("/^[A-Za-z' ]*$/",$val[0]) )
	                {
	                  $notinsert +=1;
	                }
	             //    else if(!empty($getTitle))
		            // {
		            //    $ducplicat +=1;
		            // }
		            else
		            {
		            	$insert +=1;
		            	$record = array(
		            		'title'=>ucfirst($val[0]),
		            		'description'=>ucfirst($val[1]),
		            		'expiredDate'=>date('Y-m-d',strtotime($val[2])),
		            		'discount'=>$val[3],
		            		'couponCode'=>$val[4],
		            	);
		            	$this->Crud_model->SaveData('coupon_codes',$record);
		            }
		        }
		    }
		    $msg = "";
		    if($ducplicat!=0)
		    {
		        $msg .= "Title is already exits ";
		    }
		    if($notinsert!=0)
		    {
		        $msg .= "Invalid title ";
		    }
		    if($notinsert==0 && $ducplicat==0)
		    {
		       $msg ="Record import successfully";
		    } 
		    $this->session->set_flashdata('message', '<label class="alert-success padd">'.$msg.'</label>');
		    redirect(site_url(COUPONCODE));
        }
    }
}
