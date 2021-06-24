<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class BotPlayer extends CI_Controller {
	public function __construct()
	{
		parent::__construct();
		$this->load->model("BotPlayer_model");
	}
 	public function index(){
 		$import = '<a class="btn btn-success" data-target="#uploadData" data-toggle="modal">Import</a>';
       	$data=array(
       	 'heading' => 'Manage Bot Players',
         'create_btn' => 'Create',
         'bread' => 'Manage Bot Players',
         'import' => $import,
		 'importTitle' => 'Import Bot Player',
		 'importAction'=>site_url('BotPlayer/Import'),
		 'importSheet'=>base_url('uploads/excel_files/BotPlayer.xlsx'),
       	);
       	$this->load->view('botPlayer/list',$data);
	}
 	public function ajax_manage_page(){
 		$cond = "u.playerType='Bot' ";
		if(!empty($this->input->post('SearchData')) && !empty($this->input->post('SearchData1'))) {
			$cond .= "and date(u.signup_date) between '".date("Y-m-d",strtotime($this->input->post('SearchData')))."' and '".date("Y-m-d",strtotime($this->input->post('SearchData1')))."' ";
		}else if(!empty($this->input->post('SearchData'))) {
			$cond .= "and date(u.signup_date) = '".date("Y-m-d",strtotime($this->input->post('SearchData')))."' ";
		}else if(!empty($this->input->post('SearchData1'))) {
			$cond .= "and date(u.signup_date) = '".date("Y-m-d",strtotime($this->input->post('SearchData1')))."' ";
		}
		$getData = $this->BotPlayer_model->get_datatables('user_details u',$cond);
		if(empty($_POST['start']))
	    {
	        $no =0;   
	    }else{
	         $no =$_POST['start'];
	    }
		$data = array();
	     		  
		foreach ($getData as $row) 
		{
		$btn = '';
         $btn =''.anchor(site_url(BOTPLAYERUPDATE.'/'.base64_encode($row->id)),'<button title="Edit" class="btn btn-info btn-circle btn-xs"><i class="fa fa-edit"></i></button>');

    	$btn .='&nbsp;|&nbsp; <button type="button" title="Delete" class="btn btn-danger btn-circle btn-xs" onClick="return deletebotplayer('.$row->id.');"><i class="fa fa-trash"></i></button>';

        if($row->status=='Active')
        {      
        	$status = '<a class="label label-success" onClick="return statusChange('.$row->id.');">'.$row->status.'</a>';
        }
        elseif($row->status=='Inactive')
        {
        	$status = '<a class="label label-danger" onClick="return statusChange('.$row->id.');">'.$row->status.'</a>';
		}

		if(!empty($row->user_name)){ $user_name = $row->user_name; }else{ $user_name = 'N/A'; }
		if(!empty($row->country_name)){ $country_name = $row->country_name; }else{ $country_name = 'N/A'; }

		if(file_exists(getcwd().'/uploads/userProfileImages/'.$row->profile_img)) 
			{
				$botplayers="<img width='100px' height='50px' src='".base_url("uploads/userProfileImages/".$row->profile_img)."'></img>"; 
			}
			else $botplayers="<img width='100px' height='50px' src='".base_url("uploads/no_image.png")."'></img>";  
         
		$no++;
		$nestedData = array();
	    $nestedData[] = $no;
	    $nestedData[] = $user_name;
	    $nestedData[] = $country_name;
	    // $nestedData[] = $row->balance;
	    $nestedData[] = $botplayers;
     	$nestedData[] = $status;
        $nestedData[] = $btn;
	    
	    $data[] = $nestedData;
	}

	$output = array(
				"draw"            => $_POST['draw'],
				"recordsTotal"    => $this->BotPlayer_model->count_all('user_details u',$cond),
				"recordsFiltered" => $this->BotPlayer_model->count_filtered('user_details u',$cond),
				"data"            => $data,
				"csrfHash"        => $this->security->get_csrf_hash(),
				"csrfName"        => $this->security->get_csrf_token_name(),
			);
	echo json_encode($output);
 }

public function create(){
   $data = array(
		'heading' => 'Create Bot Players',
		'breadhead' => 'Manage Bot Players',
		'bread' => 'Create Bot Players',
		'button' => 'Create',
		'action' => site_url(BOTPLAYERCREATEACTION),
		'user_name' => set_value('user_name',$this->input->post('user_name',TRUE)),
		'playerType' => 'Bot',
		'balance' => set_value('balance',$this->input->post('balance',TRUE)),
		'country_name' => set_value('country_name',$this->input->post('country_name',TRUE)),
		'status' => set_value('status',$this->input->post('status',TRUE)),
		'profile_img' => set_value('profile_img',$this->input->post('profile_img',TRUE)),
		'id' => '0',
				);
	$this->load->view('botPlayer/form',$data);
}

public function createAction(){
	$id=0;
	$this->set_rules($id);
	if(empty($_FILES['profile_img']['name'])){
			  $this->form_validation->set_rules('profile_img','profile image','required|xss_clean',
					array('required'=>'Please select %s'
			));
		  }
	if($this->form_validation->run()==false){
			$this->create();
		}else{
			//print_r($_FILES['profile_img']['name']);exit();
			if($_FILES['profile_img']['name']!=''){
					    $photo                          = time().$_FILES['profile_img']['name'];
					    $config['file_name'] 	        = $photo;
				        $config['upload_path']          = './uploads/userProfileImages/';
				        $config['allowed_types']        = 'gif|jpg|png|jpeg';
				        // $config['max_width']            = 1024;
				        // $config['max_height']           = 768;

				        $this->load->library('upload', $config);
				        $this->upload->initialize($config);
				        $this->upload->do_upload('profile_img');
					}else{
							$photo='';
						 }
			$savedata=array(
		            'user_name' =>$this->input->post('user_name',TRUE),
					'playerType' => 'Bot',
					'balance' =>$this->input->post('balance',TRUE),
					'country_name' =>$this->input->post('country_name',TRUE),
					'status' =>$this->input->post('status',TRUE), 
					'profile_img'=>$photo 
			);

			$this->Crud_model->SaveData('user_details',$savedata);
			//print_r($this->db->last_query());exit();
			$this->session->set_flashdata('message','Bot player has been created successfully');  
			$insertId = $this->db->insert_id();
			$data =array(
				   'user_id'=>$insertId,
			);
			$this->Crud_model->SaveData('user_details',$data,"id='".$insertId."'");
			redirect(BOTPLAYER);
		}
}

public function update($id){
	$cond = "id = '".base64_decode($id)."'";
    $getdata=$this->Crud_model->GetData('user_details','',$cond,'','','','1');
    $data=array(
   	    'heading' => 'Update Bot Players',
		'breadhead' => 'Manage Bot Players',
		'bread' => 'Update Bot Players',
		'button' => 'Update',
        'action'=>site_url(BOTPLAYERUPDATEACTION),
        'id' => set_value('id',$getdata->id),
        'user_name' => set_value('user_name',$getdata->user_name),
		'playerType' => 'Bot',
		'balance' => set_value('balance',$getdata->balance),
		'country_name' => set_value('country_name',$getdata->country_name),
		'profile_img' => set_value('profile_img',$getdata->profile_img),
		'status' => set_value('status',$getdata->status),
    );
   $this->load->view('botPlayer/form',$data);
}

public function updateAction(){
	$id=$this->input->post('id');
     	$this->set_rules($id);
		if($this->form_validation->run()==false){
			$this->update(base64_encode($id));
		}else{
			if($_FILES['profile_img']['name']!=''){
					    $photo                          = time().$_FILES['profile_img']['name'];
					    $config['file_name'] 	        = $photo;
				        $config['upload_path']          = './uploads/userProfileImages/';
				        $config['allowed_types']        = 'gif|jpg|png|jpeg';
				        // $config['max_width']            = 1024;
				        // $config['max_height']           = 768;

				        $this->load->library('upload', $config);
				        $this->upload->initialize($config);
				        $this->upload->do_upload('profile_img');
				        unlink('uploads/userProfileImages/'.$this->input->post('old_photo'));
					}else{
							$photo=$this->input->post('old_photo',TRUE);
						 }
	        $data=array(
	        'user_name' => $this->input->post('user_name',TRUE),
			'playerType' => 'Bot',
			'balance' => $this->input->post('balance',TRUE),
			'country_name' => $this->input->post('country_name',TRUE),
			'status' => $this->input->post('status',TRUE),
			'profile_img'=>$photo 
		);
	    $this->Crud_model->SaveData('user_details',$data,"id='".$this->input->post('id',TRUE)."'");
        $this->session->set_flashdata('message', 'Bot player has been updated successfully');  
        redirect(BOTPLAYER);    
        }
}

  public function deleteAction(){
   $id = $this->input->post('id',TRUE);
	    if(!empty($id))
	    {
	        $this->Crud_model->DeleteData("user_details","id='".$id."'",'');
	        $msg = 'Record has been deleted successfully';
	    }
	    else
	    {
	    	$msg = 'No record found bot player';
	    }
	    $response = array(
	    	'csrfName' => $this->security->get_csrf_token_name(),
	    	'csrfHash' => $this->security->get_csrf_hash(),
	    	'msg'      => $msg
	    );
	    echo json_encode($response);exit;
  }

 public function set_rules($id){
 	   $getdata=$this->Crud_model->GetData('user_details','',"user_name='".$this->input->post('user_name',TRUE)."' and id!=$id",'','','','1');
         $unique="";
     	if($getdata){
     		 $unique="|is_unique[user_details.user_name]";
			}
     	$this->form_validation->set_rules('user_name','user name','required|trim|xss_clean'.$unique,
        array(
              'required'=>'Please Enter %s.',
              'is_unique'=>"This field is already exist"
        ));
         $this->form_validation->set_rules('balance','balance','required|trim|xss_clean',
         array(
               'required'=>'Please Select %s.',
         ));
       $this->form_validation->set_rules('country_name','country name','required|trim|xss_clean',
        array(
              'required'=>'Please Enter %s.',
        ));
        $this->form_validation->set_rules('status','status','required|trim|xss_clean',
        array(
              'required'=>'Please Select %s.',
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
	    	$this->session->set_flashdata('message', '<label class="alert-success padd">Excel sheel is blank</label>');
	    	redirect(site_url('BotPlayer'));
	    }
	    else
	    {
		  	$data = $fields_fun;
		    $exists = 0;
		    $notinsert= '';
		    $ducplicat =0;
		    $insert = 0;
	        foreach ($data as $val) 
		    {
		      	if(isset($val[0]) && isset($val[1]) && isset($val[2]))
		        {
		        	$getBotName = $this->Crud_model->GetData('user_details','',"user_name='".$val[0]."'",'','','');

		        	if(!preg_match("/^[A-Za-z' ]*$/",$val[0]) )
	                {
	                  $notinsert +=1;
	                }
	                else if(!empty($getBotName))
		            {
		               $ducplicat +=1;
		            }
		            else
		            {
		            	$insert +=1;
		            	$data = array(
		            		'user_name'=>ucfirst($val[0]),
		            		'country_name'=>ucfirst($val[1]),
		            		'balance'=>$val[2],
		            		'status'=>'Active',
		            		'playerType'=>'Bot',
		            	);
		            	$this->Crud_model->SaveData('user_details',$data);
		            	$lastId = $this->db->insert_id();
		            	$dataUpdate = array(
		            		'user_id'=>$lastId,
		            	);
		            	$con = "id='".$lastId."'";
		            	$this->Crud_model->SaveData('user_details',$dataUpdate,$con);
		            }
		        }
		    }
		    $msg = "";
		    if($ducplicat!=0)
		    {
		        $msg .= "User name is already exits ";
		    }
		    if($notinsert!=0)
		    {
		        $msg .= "Invalid name ";
		    }
		    if($notinsert==0 && $ducplicat==0)
		    {
		       $msg ="Record import successfully";
		    } 
		    $this->session->set_flashdata('message', '<label class="alert-success padd">'.$msg.'</label>');
		    redirect(site_url('BotPlayer'));
        }
    }

    public function Export()
    {
    	$getUserData = $this->Crud_model->GetData("user_details",'','playerType="Bot"','','id DESC','','');

    	if(!empty($getUserData))
    	{
    		$this->load->library('excel');
			//activate worksheet number 1
            $this->excel->setActiveSheetIndex(0);
            //name the worksheet
            $this->excel->getActiveSheet()->setTitle('');
            
            $this->excel->getActiveSheet()->setCellValue('A2', 'Bots');
            $this->excel->getActiveSheet()->setCellValue('A4', 'Sr. No.');
            $this->excel->getActiveSheet()->setCellValue('B4', 'Bot Name');
            $this->excel->getActiveSheet()->setCellValue('C4', 'Country Name');
            $this->excel->getActiveSheet()->setCellValue('D4', 'Balance');
            $this->excel->getActiveSheet()->setCellValue('E4', 'Status');
            $a=5;
            $sr=1;
            foreach ($getUserData as $report) {
            	if(!empty($report->user_name)){ $user_name = $report->user_name; }else{ $user_name = 'NA'; }

            	if(!empty($report->country_name)){ $country_name = $report->country_name; }else{ $country_name = 'NA'; }

            	if(!empty($report->balance)){ $balance = $report->balance; }else{ $balance = '0'; }

            	if(!empty($report->status)){ $status = $report->status; }else{ $status = '0'; }


            	$this->excel->getActiveSheet()->setCellValue('A'.$a, $sr);
                $this->excel->getActiveSheet()->setCellValue('B'.$a, ucfirst($user_name));
                $this->excel->getActiveSheet()->setCellValue('C'.$a, ucfirst($country_name));
                $this->excel->getActiveSheet()->setCellValue('D'.$a, round($balance,2));
                $this->excel->getActiveSheet()->setCellValue('E'.$a, $status);

                $this->excel->getActiveSheet()->getStyle('A'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
                $this->excel->getActiveSheet()->getStyle('C'.$a)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);

                $this->excel->getActiveSheet()->getRowDimension($a)->setRowHeight(18); 

                $sr++;

               $a++;
            }

            //change the font size
            $this->excel->getActiveSheet()->getStyle('A2')->getFont()->setSize(14);

            //set each column width
            $this->excel->getActiveSheet()->getColumnDimension('A')->setWidth(6);
            $this->excel->getActiveSheet()->getColumnDimension('B')->setWidth(20);
            $this->excel->getActiveSheet()->getColumnDimension('C')->setWidth(18);
            $this->excel->getActiveSheet()->getColumnDimension('D')->setWidth(18);
            $this->excel->getActiveSheet()->getColumnDimension('E')->setWidth(18);

            //set each row height
            $this->excel->getActiveSheet()->getRowDimension('2')->setRowHeight(20);
            $this->excel->getActiveSheet()->getRowDimension('4')->setRowHeight(18);

            //make the font become bold
            $this->excel->getActiveSheet()->getStyle('A2')->getFont()->setBold(true);
            $this->excel->getActiveSheet()->getStyle('A4:E4')->getFont()->setBold(true);

            //merge cell A2 until F2
            $this->excel->getActiveSheet()->mergeCells('A1:E1');
            $this->excel->getActiveSheet()->mergeCells('A2:E2');

            //set aligment to center for that merged cell (A2 to F4)
            $this->excel->getActiveSheet()->getStyle('A2')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
            $this->excel->getActiveSheet()->getStyle('A4:E4')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);

            $filename='users_'.date('d-m-Y H:i').'.xls';
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
    	}
    	else 
    	{
			$this->session->set_flashdata('message', 'Record not avaliable.');
			redirect('BotPlayer');
		}
    }
}