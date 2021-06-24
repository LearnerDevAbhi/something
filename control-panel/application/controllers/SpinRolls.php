<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class SpinRolls extends CI_Controller {

	public function __construct()
	{
		parent::__construct();
		$this->load->model("SpinRoll_model");
	}

	public function index()
	{
	

		$data = array(
						'heading' => 'Manage Spin Rolls',
						'bread' => 'Manage Spin Rolls',
						'create_button' => 'Create',
					
					);
	
		$this->load->view('spinRoll/list',$data);

	}

	public function ajax_manage_page(){
		
		$getSpinRolls = $this->SpinRoll_model->get_datatables("spin_rolls sr");
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getSpinRolls as $row) 
		{
			
			$btn = '';
        	 $btn =''.anchor(site_url(SPINROLLUPDATE.'/'.base64_encode($row->id)),'<button title="Edit" class="btn btn-info btn-circle btn-xs"><i class="fa fa-edit"></i></button>');
         	
        	$btn .="&nbsp;|&nbsp;". "<button title='Delete' class='btn btn-danger btn-xs' onclick='return deleteCountry(".$row->id.");'><i class='fa fa-trash-o'></i></button>";

            if($row->status=='Active')  
			$status="<span id='status_span".$row->id."' onclick='return change_status(".$row->id.");'  style='cursor:pointer;' class='label label-success' > Active </span>";
			else
			$status="<span id='status_span".$row->id."' onclick='return change_status(".$row->id.");'  style='cursor:pointer;' class='label label-danger' > Inactive </span>";

			if(!empty($row->title)){ $title = $row->title; }else{ $title = 'N/A'; }
			if(!empty($row->value)){ $value = $row->value; }else{ $value = 'N/A'; }

			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($title);
         	$nestedData[] = $value;
         	$nestedData[] = $status;
            $nestedData[] = $btn;    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->SpinRoll_model->count_all("spin_rolls sr"),
					"recordsFiltered" => $this->SpinRoll_model->count_filtered("spin_rolls sr"),
					"data" => $data,
				);
		echo json_encode($output);
	}

	public function create(){
	
		$data = array(
						'heading' => 'Create Spin Roll',
						'breadhead' => 'Manage Spin Rolls',
						'bread' => 'Create Spin Roll',
						'button' => 'Create',
						'action' => site_url(SPINROLLCREATEACTION),
						'title' => set_value('title',$this->input->post('title',TRUE)),
						'value' => set_value('value',$this->input->post('value',TRUE)),
						'status' => set_value('status',$this->input->post('status',TRUE)),
						'id' => '0',
					);
				$this->load->view('spinRoll/form',$data);

	}


	public function createAction(){

	$id=0;
	$this->setRules($id);
	if($this->form_validation->run()==false){
			$this->create();
		}else{
			
			$data = array(
	 					'title' => $this->input->post('title',TRUE),
	 					'value' => $this->input->post('value',TRUE),
	 					'status' => $this->input->post('status',TRUE),
	 					'created' => date("Y-m-d H:i:s"),
	 				);

			$this->Crud_model->SaveData('spin_rolls',$data);
			//print_r($this->db->last_query());exit();
			$msg = $this->session->set_flashdata('message', '<label class="alert-success padd">Spin Roll has been created successfully</label>');
	 			redirect(SPINROLL);
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
			'value' => $this->input->post('value',TRUE),
			'status' => $this->input->post('status',TRUE),
			'modified' => date("Y-m-d H:i:s"),
		);
	        $cond="id='".$id."'";
	    	$this->Crud_model->SaveData("spin_rolls",$data,$cond);
            $msg = $this->session->set_flashdata('message', '<label class="alert-success padd">Spin Roll has been updated successfully</label>');
	 			redirect(SPINROLL);    
        }
}

	
	public function update($id){
        $id=base64_decode($id);
		$cond = "id = '".$id."'";
		$getSpinRollata = $this->Crud_model->GetData("spin_rolls",'',$cond,'','','','1');
		
		$data = array(
						'heading' => 'Update Spin Roll',
						'breadhead' => 'Manage Spin Rolls',
						'bread' => 'Update Spin Roll',
						'button' => 'Update',
						'action' => site_url(SPINROLLUPDATEACTION.'/'.base64_encode($id)),
						'title' => set_value('title',$getSpinRollata->title),
						'value' => set_value('value',$getSpinRollata->value),
						'status' => set_value('status',$getSpinRollata->status),
						'id' => set_value('id',$getSpinRollata->id),
						
					);
		
		$this->load->view('spinRoll/form',$data);
	}


	public function delete()
	{
		$id = $this->input->post('id',TRUE);
		if(!empty($id))
		{
			$this->Crud_model->DeleteData("spin_rolls","id='".$id."'",'');
			
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
		$table = "spin_rolls";
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
		$SpinRoll = $this->Crud_model->GetData('spin_rolls','',"title='".$this->input->post('title',TRUE)."' and id != '".$id."'");
		
		$isunique = '';
		if($SpinRoll) {
			$isunique = "|is_unique[spin_rolls.title]";
		}
	    $this->form_validation->set_rules('title','title', 'trim|required'.$isunique,
	    	array(
			'required' => 'Please enter %s',
			'is_unique' => 'This country name is already exist',
		));

		$this->form_validation->set_rules('value','value', 'trim|required',
	    	array(
			'required' => 'Please enter %s',
			
		));
	}
}
