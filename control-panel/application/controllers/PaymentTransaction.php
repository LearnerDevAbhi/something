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
		$data=array(
			'heading'=>"Transaction Details",
			'bread'=>"Transaction Details",
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

		$getTransaction = $this->PaymentTransaction_model->get_datatables('user_account ual',$condition);
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


			if($transaction->paymentType=='mainWallet' || $transaction->paymentType=='winWallet')
            {      
            	$paymentType = '<a class="label label-danger">'.ucfirst($transaction->paymentType).'</a>';
            }elseif($transaction->paymentType =='paytm'){
            	$paymentType = '<a class="label label-success">'.ucfirst($transaction->paymentType).'</a>';
			}elseif($transaction->paymentType=='bank'){
            	$paymentType = '<a class="label label-info">'.ucfirst($transaction->paymentType).'</a>';
			}else{
				$paymentType = 'NA';
			}

			
			if(!empty($transaction->orderId)){ $orderId = $transaction->orderId; }else{ $orderId = 'NA'; }
			if(!empty($transaction->user_name)){ $user_name = $transaction->user_name; }else{ $user_name = 'NA'; }
			if(!empty($transaction->mobileNo)){ $mobileNo = $transaction->mobileNo; }else{ $mobileNo = 'NA'; }
			if(!empty($transaction->status)){ $status = $transaction->status; }else{ $status = 'NA'; }

			if(!empty($transaction->balance)){ $balance = $transaction->balance; }else{ $balance = '0'; }
			if(!empty($transaction->mainWallet)){ $mainWallet = $transaction->mainWallet; }else{ $mainWallet = '0'; }
			if(!empty($transaction->winWallet)){ $winWallet = $transaction->winWallet; }else{ $winWallet = '0'; }
			if(!empty($transaction->amount)){ $amount = $transaction->amount; }else{ $amount = '0'; }

			if(!empty($transaction->created) && $transaction->created !="0000-00-00 00:00:00"){ $created = date('d M Y H:i A', strtotime($transaction->created)); }else{ $created = '0000-00-00 00:00:00'; }
		 
			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = $orderId;
		    $nestedData[] = ucfirst($user_name);
		    $nestedData[] = $mobileNo;
         	$nestedData[] = $amount;
         	$nestedData[] = $winWallet;
		    $nestedData[] =$mainWallet;
         	$nestedData[] =$created;
		    $nestedData[] = $type;
         	$nestedData[] = $paymentType;
         	$nestedData[] = $status;
		    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->PaymentTransaction_model->count_all('user_account ual',$condition),
					"recordsFiltered" => $this->PaymentTransaction_model->count_filtered('user_account ual',$condition),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}

	public function exportAction() {
		$condition='';
		// if(!empty($this->input->post('toDate')) && !empty($this->input->post('fromDate'))) {
  //           $condition .= "date(ual.created) between '".date("Y-m-d",strtotime($this->input->post('toDate')))."' and '".date("Y-m-d",strtotime($this->input->post('fromDate')))."' ";
  //       }else if(!empty($this->input->post('toDate'))) {
  //           $condition .= "date(ual.created) = '".date("Y-m-d",strtotime($this->input->post('toDate')))."'";
  //       }else if(!empty($this->input->post('fromDate'))) {
  //           $condition .= "date(ual.created) = '".date("Y-m-d",strtotime($this->input->post('fromDate')))."'";
  //       }
		$getPaymentTransData = $this->PaymentTransaction_model->getPaymentTransData('user_account ual',$condition);
		// print_r($getPaymentTransData);exit;
		if(!empty($getPaymentTransData)) {
			$this->load->library('excel');
			//activate worksheet number 1
			$this->excel->setActiveSheetIndex(0);
			//name the worksheet
			$this->excel->getActiveSheet()->setTitle('');
			
			$this->excel->getActiveSheet()->setCellValue('A2', 'Transaction Details');
			$this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
			$this->excel->getActiveSheet()->setCellValue('B4', 'OrderId');
			$this->excel->getActiveSheet()->setCellValue('C4', 'User Name');
			$this->excel->getActiveSheet()->setCellValue('D4', 'Mobile');
			$this->excel->getActiveSheet()->setCellValue('E4', 'Tax Amount(Rs)');
			$this->excel->getActiveSheet()->setCellValue('F4', 'Win Wallet(Rs)');
			$this->excel->getActiveSheet()->setCellValue('G4', 'Main Wallet(Rs)');
			$this->excel->getActiveSheet()->setCellValue('H4', 'Date');
			$this->excel->getActiveSheet()->setCellValue('I4', 'Type');
			$this->excel->getActiveSheet()->setCellValue('J4', 'Payment Mode');
			$this->excel->getActiveSheet()->setCellValue('K4', 'Status');
			$a=5;
			$sr=1;
			foreach ($getPaymentTransData as $report) {
				if(!empty($report->orderId)){ $orderId = $report->orderId; }else{ $orderId = 'NA'; }

				if(!empty($report->user_name)){ $user_name = $report->user_name; }else{ $user_name = 'NA'; }

				if(!empty($report->mobileNo)){ $mobileNo = $report->mobileNo; }else{ $mobileNo = 'NA'; }

				if(!empty($report->amount)){ $amount = $report->amount; }else{ $amount = '0'; }

				if(!empty($report->winWallet)){ $winWallet = $report->winWallet; }else{ $winWallet = '0'; }

				if(!empty($report->mainWallet)){ $mainWallet = $report->mainWallet; }else{ $mainWallet = '0'; }

				if(!empty($report->created)){ $created = date('d/m/Y', strtotime($report->created)); }else{ $created = 'NA'; }

				if(!empty($report->type)){ $type = $report->type; }else{ $type = 'NA'; }

				if(!empty($report->paymentType)){ $paymentType = $report->paymentType; }else{ $paymentType = 'NA'; }

				if(!empty($report->status)){ $status = $report->status; }else{ $status = 'NA'; }

				$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
				$this->excel->getActiveSheet()->setCellValue('B'.$a, $orderId);
				$this->excel->getActiveSheet()->setCellValue('C'.$a, ucfirst($user_name));
				$this->excel->getActiveSheet()->setCellValue('D'.$a, $mobileNo);
				$this->excel->getActiveSheet()->setCellValue('E'.$a, $amount);
				$this->excel->getActiveSheet()->setCellValue('F'.$a, $winWallet);
				$this->excel->getActiveSheet()->setCellValue('G'.$a, $mainWallet);
				$this->excel->getActiveSheet()->setCellValue('H'.$a, $created);
				$this->excel->getActiveSheet()->setCellValue('I'.$a, $type);
				$this->excel->getActiveSheet()->setCellValue('J'.$a, $paymentType);
				$this->excel->getActiveSheet()->setCellValue('K'.$a, $status);

				$this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('D'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
				$this->excel->getActiveSheet()->getStyle('F'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

				// $this->excel->getActiveSheet()->getStyle('F'.$a)->getNumberFormat()->setFormatCode('0');

				$this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

				$sr++;

			   $a++;
			}

			//change the font size
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

			//set each column width
			$this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(6);
			$this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
			$this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(25);
			$this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);
			$this->excel->getActiveSheet()->getColumnDimension('F')->setWidth(40);
			$this->excel->getActiveSheet()->getColumnDimension('G')->setWidth(40);
			$this->excel->getActiveSheet()->getColumnDimension('H')->setWidth(40);
			$this->excel->getActiveSheet()->getColumnDimension('I')->setWidth(40);
			$this->excel->getActiveSheet()->getColumnDimension('J')->setWidth(40);
			$this->excel->getActiveSheet()->getColumnDimension('K')->setWidth(40);

			//set each row height
			$this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
			$this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

			//make the font become bold
			$this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
			$this->excel->getActiveSheet()->getStyle('A4:K4')->getFont()->setBold(true);

			//merge cell A2 until E2
			$this->excel->getActiveSheet()->mergeCells('A1:K1');
			$this->excel->getActiveSheet()->mergeCells('A2:K2');

			//set aligment to center for that merged cell (A2 to E4)
			$this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
			$this->excel->getActiveSheet()->getStyle('A4:K4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

			$filename='transaction_'.date('d-m-Y H:i').'.xls';
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
			redirect(DEPOSIT);
		}
	}
}
