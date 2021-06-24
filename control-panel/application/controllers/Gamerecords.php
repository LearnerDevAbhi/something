<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Gamerecords extends CI_Controller {
	public function __construct()
	{
		parent::__construct();
	    $this->load->model('Gamerecords_model');
	} 
	
	public function index()
	{
		$getUsers = $this->Crud_model->GetData('user_details','','playerType="Real" and status="Active"');
		$data=array(
			'heading'=>"Manage Game Records",
			'bread'=>"Manage Game Records",
			'getUsers'=>$getUsers,
			);
		$this->load->view('gameRecord/list',$data);
	}

}