<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class RoleAccess extends CI_Controller {
	public function __construct()
	{
		parent::__construct();
		$this->load->model('RoleAccess_model');
	} 

	public function index()
	{
		$data=array(
			'heading'=>"Manage Admin Users",
			'bread'=>"Manage Admin Users",
			);
		$this->load->view('roleAccess/list',$data);
	}

	public function ajax_manage_page()
	{	
		$cond = "al.role!='Admin'";
		$getUsers = $this->RoleAccess_model->get_datatables('admin_login al',$cond);

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

			$btn .= anchor(site_url(ROLEACCESSUPDATE.'/'.base64_encode($getUserData->id)),'<span class="btn btn-info btn-circle btn-xs"  data-placement="right" title="Update"><i class="fa fa-edit"></i></span>');

         	$btn .= '&nbsp;|&nbsp'.anchor(site_url(ROLEACCESSVIEW.'/'.base64_encode($getUserData->id)),'<span class="btn btn-warning btn-circle btn-xs"  data-placement="right" title="Role Access"><i class="fa fa-universal-access"></i> Role Access</span>');

         	$btn .='&nbsp;|&nbsp; <button type="button" title="Delete" class="btn btn-danger btn-circle btn-xs" onClick="return deleteRecord('.$getUserData->id.');"><i class="fa fa-trash"></i></button>';


			if($getUserData->status=="Active"){
				$status = '<label class="btn btn-success btn-xs">'.$getUserData->status.'</label>';
			}else{
				$status = '<label class="btn btn-danger btn-xs">'.$getUserData->status.'</label>';
			}
			$no++;
			$nestedData = array();
			$nestedData[] = $no;
			$nestedData[] = ucfirst($getUserData->name);
			$nestedData[] = $getUserData->email;
			$nestedData[] = $status;
			$nestedData[] = $btn;
			
			$data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->RoleAccess_model->count_all('admin_login al',$cond),
					"recordsFiltered" => $this->RoleAccess_model->count_filtered('admin_login al',$cond),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}

	public function create()
	{
		$data = array(
			'heading' => 'Create Admin Users',
			'breadhead' => 'Manage Admin Users',
			'bread' => 'Create Admin User',
			'button' => 'Create',
			'action' => site_url(ROLEACCESSACTION),
			'name' => set_value('name'),
			'email' => set_value('email'),
			'password' => set_value('password'),
			'id' => '0',
		);

		$this->load->view('roleAccess/form',$data);
	}

	public function update($id)
	{
		$cond = "id='".base64_decode($id)."' ";
        $row = $this->RoleAccess_model->GetData("admin_login",'',$cond,'','','','1');
		$data = array(
			'heading' => 'Update Admin Users',
			'breadhead' => 'Manage Admin Users',
			'bread' => 'Update Admin User',
			'button' => 'Update',
			'action' => site_url(ROLEACCESSACTION),
			'id' => set_value('id',$row->id),
			'name' => set_value('name',$row->name),
			'email' => set_value('email',$row->email),
			'password' => set_value('password',$row->password),
		);
		$this->load->view('roleAccess/form',$data);
	}
	public function action()
	{	
		$cond = "id='".$_POST['id']."' ";
        $row = $this->RoleAccess_model->GetData("admin_login",'',$cond,'','','','1');
		$data = array(
			'name' => $this->input->post('name',TRUE),
			'email' => $this->input->post('email',TRUE),
			'role' => "User",
		);

    	if($_POST['button'] == 'Create')
		{ 
			$data['created'] = date("Y-m-d H:i:s");
			$data['password'] = md5($this->input->post('password',TRUE));
			$this->RoleAccess_model->SaveData("admin_login",$data);

			$this->session->set_flashdata('message', 'User has been created successfully');
		}
		else
		{
			$data['modified'] = date("Y-m-d H:i:s");
			$this->RoleAccess_model->SaveData("admin_login",$data,$cond);
			
			$this->session->set_flashdata('message', 'User has been updated successfully');
		}
		redirect(ROLEACCESS);
	}

	public function delete()
	{
		$cond = "id = '".$_POST['id']."'";
		$cond1 = 'adminId="'.$_POST['id'].'"';
		$getData = $this->RoleAccess_model->GetData("admin_login",'',$cond,'','','','1');
		$getDataMenuLog = $this->RoleAccess_model->GetData("admin_menu_mapping",'',$cond1,'','','','');
		if(!empty($getData))
		{
			$this->RoleAccess_model->DeleteData("admin_login",$cond,'1');
			$this->RoleAccess_model->DeleteData("admin_menu_mapping",$cond1,'1');
			$msg = 'Record has been deleted successfully';
		}
		else
		{
			$msg = 'No Record Found';
		}
		$response = array(
	    	'csrfName' => $this->security->get_csrf_token_name(),
	    	'csrfHash' => $this->security->get_csrf_hash(),
	    	'msg'      => $msg
	    );
	    echo json_encode($response);exit;
	}

	public function roleAccess($id){
		$getmenus = $this->RoleAccess_model->GetData('admin_menus','',"parentId='0' and type='MENU'");

		$getmenus_ids = $this->RoleAccess_model->GetData('admin_menu_mapping','menuId','adminId="'.base64_decode($id).'"');
	
		$getsubmenus_ids = $this->RoleAccess_model->GetData('admin_menu_mapping','subMenuId','adminId="'.base64_decode($id).'"');

		$selected_ids=[];
		foreach ($getmenus_ids as $key => $value) {
			 $selected_ids[]=$value->menuId; 
		}
		
		$selected_submenu_ids=[];
		foreach ($getsubmenus_ids as $key => $value) {
			 $selected_submenu_ids[]=$value->subMenuId; 
		}

		$data = array(
			'action'=>site_url(ROLEACCESSMENUACTION),
			'getmenus'=>$getmenus,
			'adminId'=>$id,
			'selected_menu_id'=>$selected_ids,
			'selected_submenu_ids'=>$selected_submenu_ids,
		);
		$this->load->view('roleAccess/roleAccess',$data);
	}

	public function roleAccessAction(){
		$getmenus_data = $this->RoleAccess_model->GetData('admin_menu_mapping','menuId','adminId="'.base64_decode($_POST['adminId']).'"');

    	$getsubmenus_ids = $this->RoleAccess_model->GetData('admin_menu_mapping','menuId,subMenuId','adminId="'.base64_decode($_POST['adminId']).'"');

    	foreach ($getmenus_data as $key => $value) {
    		$menus[] = $value->menuId;  
    	}

    	foreach ($getsubmenus_ids as $key => $value) {
    		$submenu[] = $value->subMenuId;  
    	}

    	if(empty($menus)) $menus=[0];
			$array_diff = array_diff($_POST['menu'],$menus);
			$array_diff2 = array_diff($menus,$_POST['menu']);


		if(empty($submenu)) $submenu=[0];		
			$array_diff3 = array_diff($_POST['submenu'],$submenu);

			$array_diff4 = array_diff($submenu,$_POST['submenu']);
 
	 
		// to UNCHECK DELETE THE MENU CHECKBOX -----
		foreach ($array_diff2 as $key1 => $value1) {
			$this->RoleAccess_model->DeleteData('admin_menu_mapping',"adminId='".base64_decode($_POST['adminId'])."' and menuId='".$value1."'");
		}
		// to UNCHECK DELETE THE SUBMENU CHECKBOX -----
		foreach ($array_diff4 as $key2 => $value2) {


			$this->RoleAccess_model->DeleteData('admin_menu_mapping',"adminId='".base64_decode($_POST['adminId'])."' and subMenuId='".$value2."'  and subMenuId!='0'");
		}
 
		// to UNCHECK INSERT THE MENU CHECKBOX -----
		foreach ($array_diff as $key1 => $value1) {

			$data = array(
				"adminId"=> base64_decode($_POST['adminId']),
				"menuId"	  => $value1,
				"subMenuId"  => 0,
		    	);
			$this->RoleAccess_model->SaveData("admin_menu_mapping",$data);
		}

		// to UNCHECK INSERT THE SUBMENU CHECKBOX -----
		foreach ($array_diff3 as $key2 => $value2) {

			$submenu_parent = $this->RoleAccess_model->get_submenu_data($value2);

			$data = array(
				"adminId"=> base64_decode($_POST['adminId']),
				"menuId"	  => $submenu_parent->parentId,
				"subMenuId"  => $value2,
		    	);

			$this->RoleAccess_model->SaveData("admin_menu_mapping",$data);
		}
		$this->session->set_flashdata('message', 'Role Access has been successfully.'); 
		redirect(ROLEACCESS);
	}
}
