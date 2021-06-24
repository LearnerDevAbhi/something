<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class PaymentTransaction extends CI_Controller {
	public function __construct()
	{
		parent::__construct();
	    $this->load->model('PaymentTransaction_model');
	} 

	public function index()
	{
		$getUsers = $this->Crud_model->GetData('user_details','','playerType="Real" and status="Active"');
		$data=array(
			'heading'=>"Transaction Details",
			'bread'=>"Transaction Details",
			'getUsers'=>$getUsers,
			);
		$this->load->view('payTransaction/list',$data);
	}

	public function ajaxList()
	{
		//print_r($_POST);exit;
		$condition='';
		if(!empty($this->input->post('SearchData')) && !empty($this->input->post('SearchData1'))) {
            $condition .= "date(ual.created) between '".date("Y-m-d",strtotime($this->input->post('SearchData')))."' and '".date("Y-m-d",strtotime($this->input->post('SearchData1')))."' ";
        }else if(!empty($this->input->post('SearchData'))) {
            $condition .= "date(ual.created) = '".date("Y-m-d",strtotime($this->input->post('SearchData')))."'";
        }else if(!empty($this->input->post('SearchData1'))) {
            $condition .= "date(ual.created) = '".date("Y-m-d",strtotime($this->input->post('SearchData1')))."'";
        }

		$getTransaction = $this->PaymentTransaction_model->get_datatables('user_account_logs ual',$condition);
		//print_r($this->db->last_query());exit;
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getTransaction as $transaction) 
		{
			

            if($transaction->type=='Deposit')
            {      
            	$type = '<a class="label label-info">'.$transaction->type.'</a>';
            }
            elseif($transaction->type=='Withdraw')
            {
            	$type = '<a class="label label-warning">'.$transaction->type.'</a>';
			}else{
				$type = 'NA';
			}


			if($transaction->paymentType=='byAdmin')
            {      
            	$paymentType = '<a class="label label-danger">'."Admin".'</a>';
            }
            elseif($transaction->paymentType=='Patym')
            {
            	$paymentType = '<a class="label label-success">'.$transaction->paymentType.'</a>';
			}elseif($transaction->paymentType=='Manually'){
            	$paymentType = '<a class="label label-Primary">'.$transaction->paymentType.'</a>';
			}else{
				$paymentType = 'NA';
			}

			
			if(!empty($transaction->orderId)){ $orderId = $transaction->orderId; }else{ $orderId = 'NA'; }
			if(!empty($transaction->user_name)){ $user_name = $transaction->user_name; }else{ $user_name = 'NA'; }
			if(!empty($transaction->status)){ $status = $transaction->status; }else{ $status = 'NA'; }

			if(!empty($transaction->balance)){ $balance = $transaction->balance; }else{ $balance = '0'; }
			if(!empty($transaction->amount)){ $amount = $transaction->amount; }else{ $amount = '0'; }

			if(!empty($transaction->created) && $transaction->created !="0000-00-00 00:00:00"){ $created = date('d M Y H:i A', strtotime($transaction->created)); }else{ $created = '0000-00-00 00:00:00'; }
		 
			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = $orderId;
		    $nestedData[] = ucfirst($user_name);
         	$nestedData[] = $amount;
         	$nestedData[] ="-";
		    $nestedData[] =$balance;
         	$nestedData[] =$created;
		    $nestedData[] = $type;
         	$nestedData[] = $paymentType;
         	$nestedData[] = $status;
		    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->PaymentTransaction_model->count_all('user_account_logs ual',$condition),
					"recordsFiltered" => $this->PaymentTransaction_model->count_filtered('user_account_logs ual',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}
}
