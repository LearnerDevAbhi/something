<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Tournaments extends CI_Controller 
{
	public function __construct()
	{
		parent::__construct();
		$this->load->model("Tournaments_model");
		$this->load->model("TournamentsUsers_model");
		$this->load->model("TournamentsUsersHistory_model");
	}

	public function index()
	{  
		$data = array(
			'heading' => 'Manage Tournaments',
			'bread' => 'Manage Tournaments',
		);
		$this->load->view('tournaments/list',$data);
	}

	public function ajax_manage_page(){
		$getData = $this->Tournaments_model->get_datatables('mst_tournaments t');

		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getData as $getTournaments) 
		{			
			$btn = '';

            $btn .= '&nbsp;&nbsp;'.anchor(site_url(TOURNAMENTSVIEW.'/'.base64_encode($getTournaments->tournamentId)),'<span title="View" class="btn btn-primary btn-circle btn-xs"  data-placement="right" title="View"><i class="fa fa-eye"></i> </span>');

            $btn .= '&nbsp;&nbsp;'.anchor(site_url(TOURNAMENTSUPDATE.'/'.base64_encode($getTournaments->tournamentId)),'<span title="Update" class="btn btn-success btn-circle btn-xs"  data-placement="right" title="Update"><i class="fa fa-edit"></i></span>');
            if($getTournaments->status=="Active" || $getTournaments->status=="Inactive" || $getTournaments->status=="Complete"){
         		$btn .="&nbsp;&nbsp;". "<button title='Delete' class='btn btn-danger btn-xs' onclick='return deleteTournaments(".$getTournaments->tournamentId.");'><i class='fa fa-trash'></button>";
            }

            if($getTournaments->status=='Active')
            {      
            	$status = '<a class="label label-success" onclick="statusChange('.$getTournaments->tournamentId.')">'.$getTournaments->status.'</a>';
            }
            elseif($getTournaments->status=='Inactive')
            {
            	$status = '<a class="label label-danger" onclick="statusChange('.$getTournaments->tournamentId.')">'.$getTournaments->status.'</a>';
			}
			elseif($getTournaments->status=='Start')
            {
            	$status = '<a class="label label-info">'.$getTournaments->status.'</a>';
			}
			elseif($getTournaments->status=='Complete')
            {
            	$status = '<a class="label label-warning">'.$getTournaments->status.'</a>';
			}else{
				$status = '<a class="label label-info">'.$getTournaments->status.'</a>';
			}

			if(!empty($getTournaments->startDate) && $getTournaments->startDate!='0000-00-00'){
				$startDate= $getTournaments->startDate;
			}else{
				$startDate= "NA";
			}
			if(!empty($getTournaments->startTime) && $getTournaments->startTime!='00:00:00'){
				$startTime= date("h:i A",strtotime($getTournaments->startTime));;
			}else{
				$startTime= "NA";
			}

			if($getTournaments->playerCount!=0){
				$playerCount = "<a href='".site_url(TOURNAMENTUSERLIST.'/'.base64_encode($getTournaments->tournamentId))."'><label class='btn btn-primary btn-xs'>".$getTournaments->playerCount."</label></a>";
			}else{
				$playerCount = "<label class='btn btn-primary btn-xs'>".$getTournaments->playerCount."</label>";
			}

			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($getTournaments->tournamentTitle);
		    $nestedData[] = $startDate;
		    $nestedData[] = $startTime;
		    $nestedData[] = $getTournaments->playerLimitInRoom;
		    $nestedData[] = $getTournaments->entryFee;
		    $nestedData[] = $playerCount;
         	$nestedData[] = $status;
            $nestedData[] = $btn;
		    
		    $data[] = $nestedData;
		}

		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->Tournaments_model->count_all('mst_tournaments t'),
					"recordsFiltered" => $this->Tournaments_model->count_filtered('mst_tournaments t'),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
	}

	public function create()
	{
		$data = array(
			'heading'=>'Create Tournaments',
			'breadhead'=>'Create Tournaments',
			'bread'=>'Create',
			'button'=>'CREATE',
			'action'=>site_url(TOURNAMENTSCREATEACTION),
			'tournamentId'=>'0',
			'tournamentTitle' => set_value('tournamentTitle',$this->input->post('tournamentTitle',TRUE)),
			'startDate' => set_value('startDate',$this->input->post('startDate',TRUE)),
			'startTime' => set_value('startTime',$this->input->post('startTime',TRUE)),
			'tournamentDescription' => set_value('tournamentDescription',$this->input->post('tournamentDescription',TRUE)),
			'winningPrice' => set_value('winningPrice',$this->input->post('winningPrice',TRUE)),
			'playerLimitInRoom' => set_value('playerLimitInRoom',$this->input->post('playerLimitInRoom',TRUE)),
			'noOfRoundInTournament' => set_value('noOfRoundInTournament',$this->input->post('noOfRoundInTournament',TRUE)),
			'playerLimitInTournament' => set_value('playerLimitInTournament',$this->input->post('playerLimitInTournament',TRUE)),
			'commision' => set_value('commision',$this->input->post('commision',TRUE)),
			'startRoundTime' => set_value('startRoundTime',$this->input->post('startRoundTime',TRUE)),
			'tokenMoveTime' => set_value('tokenMoveTime',$this->input->post('tokenMoveTime',TRUE)),
			'rollDiceTime' => set_value('rollDiceTime',$this->input->post('rollDiceTime',TRUE)),
			'entryFee' => set_value('entryFee',$this->input->post('entryFee',TRUE)),
			'gameMode' => set_value('gameMode',$this->input->post('gameMode',TRUE)),

			'firstRoundWinner' => set_value('firstRoundWinner',$this->input->post('firstRoundWinner',TRUE)),
			'secondRoundWinner' => set_value('secondRoundWinner',$this->input->post('secondRoundWinner',TRUE)),
			'thirdRoundWinner' => set_value('thirdRoundWinner',$this->input->post('thirdRoundWinner',TRUE)),
			'fouthRoundWinner' => set_value('fouthRoundWinner',$this->input->post('fouthRoundWinner',TRUE)),
			'fivethRoundWinner' => set_value('fivethRoundWinner',$this->input->post('fivethRoundWinner',TRUE)),
			'sixthRoundWinner' => set_value('sixthRoundWinner',$this->input->post('sixthRoundWinner',TRUE)),
			'seventhRoundWinner' => set_value('seventhRoundWinner',$this->input->post('seventhRoundWinner',TRUE)),
			'eightRoundWinner' => set_value('eightRoundWinner',$this->input->post('eightRoundWinner',TRUE)),
			'ninethRoundWinner' => set_value('ninethRoundWinner',$this->input->post('ninethRoundWinner',TRUE)),
			'tenthRoundWinner' => set_value('tenthRoundWinner',$this->input->post('tenthRoundWinner',TRUE)),
			// 'callTimmer' => set_value('callTimmer',$this->input->post('callTimmer',TRUE)),
			// 'startGameTimmer' => set_value('startGameTimmer',$this->input->post('startGameTimmer',TRUE)),
			// 'nextRoundTimmer' => set_value('nextRoundTimmer',$this->input->post('nextRoundTimmer',TRUE)),
			// 'gameOverTimmer' => set_value('gameOverTimmer',$this->input->post('gameOverTimmer',TRUE)),
			// 'breakTime' => set_value('breakTime',$this->input->post('breakTime',TRUE)),
			// 'percentOfWinPlayer' => set_value('percentOfWinPlayer',$this->input->post('percentOfWinPlayer',TRUE)),
			// 'status' => set_value('status',$this->input->post('status',TRUE)),
		);
		$this->load->view('tournaments/form',$data);
	}

	public function createAction(){
		
		$tournamentId=0;
		$this->form_rules($tournamentId);
		if($this->form_validation->run()==false){
	        $this->create();
	         }else{
	         	$savedata=array(
					'tournamentTitle'=>$this->input->post('tournamentTitle',true),
					'startDate'=>date("Y-m-d",strtotime($this->input->post('startDate',true))),
					'startTime'=>date("H:i:s",strtotime($this->input->post('startTime',true))),
					'tournamentDescription'=>ucfirst($this->input->post('tournamentDescription',true)),
					'winningPrice'=>ucfirst($this->input->post('winningPrice',true)),
					'playerLimitInRoom'=>($this->input->post('playerLimitInRoom',true)),
					'noOfRoundInTournament'=>ucfirst($this->input->post('noOfRoundInTournament',true)),
					'playerLimitInTournament'=>ucfirst($this->input->post('playerLimitInTournament',true)),
					'commision'=>ucfirst($this->input->post('commision',true)),
					'startRoundTime'=>ucfirst($this->input->post('startRoundTime',true)),
					'tokenMoveTime'=>$this->input->post('tokenMoveTime',true),
					'rollDiceTime'=>$this->input->post('rollDiceTime',true),
					'entryFee'=>$this->input->post('entryFee',true),
					'gameMode'=>$this->input->post('gameMode',true),
					'firstRoundWinner' => $this->input->post('firstRoundWinner',TRUE),
					'secondRoundWinner' => $this->input->post('secondRoundWinner',TRUE),
					'thirdRoundWinner' => $this->input->post('thirdRoundWinner',TRUE),
					'fouthRoundWinner' => $this->input->post('fouthRoundWinner',TRUE),
					'fivethRoundWinner' => $this->input->post('fivethRoundWinner',TRUE),
					'sixthRoundWinner' => $this->input->post('sixthRoundWinner',TRUE),
					'seventhRoundWinner' => $this->input->post('seventhRoundWinner',TRUE),
					'eightRoundWinner' => $this->input->post('eightRoundWinner',TRUE),
					'ninethRoundWinner' => $this->input->post('ninethRoundWinner',TRUE),
					'tenthRoundWinner' => $this->input->post('tenthRoundWinner',TRUE),
					// 'bigBlind'=>$this->input->post('bigBlind',true),
					// 'startGameTimmer'=>$this->input->post('startGameTimmer',true),
					// 'nextRoundTimmer'=>$this->input->post('nextRoundTimmer',true),
					// 'gameOverTimmer'=>$this->input->post('gameOverTimmer',true),
					// 'breakTime'=>$this->input->post('breakTime',true),
					// 'percentOfWinPlayer'=>$this->input->post('percentOfWinPlayer',true),
					// 'status'=>$this->input->post('status',true),
			   );
	         	//print_r($savedata);exit;
				$this->Tournaments_model->SaveData('mst_tournaments',$savedata);
				// $lastId = $this->db->insert_id();
				// $logData = array(
				// 	'tournamentId'=>$lastId,
				// 	'tournamentTitle'=>$this->input->post('tournamentTitle',true),
				// 	'startDate'=>date("Y-m-d",strtotime($this->input->post('startDate',true))),
				// 	'startTime'=>date("H:i:s",strtotime($this->input->post('startTime',true))),
				// 	'playerLimitInRoom'=>ucfirst($this->input->post('playerLimitInRoom',true)),
				// 	'playerLimitInTournament'=>ucfirst($this->input->post('playerLimitInTournament',true)),
				// 	'status'=>"Start"
				// );
				// $this->Tournaments_model->SaveData('mst_tournament_logs',$logData);
				$msg = $this->session->set_flashdata('message', 'Record has been added successfully');
				redirect(TOURNAMENTS);
	         }
	}

	public function update($tournamentId){
        $cond = "tournamentId = '".base64_decode($tournamentId)."'";
		$getData = $this->Tournaments_model->GetData("mst_tournaments",'',$cond,'','','','1');
		$data = array(
				'heading'          			=> 'Update Tournaments',
				'breadhead'        			=> 'Manage Tournaments',
				'bread'            			=> 'Update',
				'button'           			=> 'UPDATE',
				'action'           			=> site_url(TOURNAMENTSUPDATEACTION),
				'tournamentId'     			=> set_value('tournamentId',$getData->tournamentId),
				'tournamentTitle'  			=> set_value('tournamentTitle',$getData->tournamentTitle),
				'startDate'        			=> set_value('startDate',$getData->startDate),
				'startTime'       			=> set_value('startTime',date("h:i A",strtotime($getData->startTime))),
				'tournamentDescription'       			=> set_value('tournamentDescription',$getData->tournamentDescription),
				'winningPrice'         			=> set_value('winningPrice',$getData->winningPrice),
				'playerLimitInRoom'     			=> set_value('playerLimitInRoom',$getData->playerLimitInRoom),
				'noOfRoundInTournament'     => set_value('noOfRoundInTournament',$getData->noOfRoundInTournament),
				'playerLimitInTournament'  			=> set_value('playerLimitInTournament',$getData->playerLimitInTournament),
				'commision'       			=> set_value('commision',$getData->commision),
				'startRoundTime'    			=> set_value('startRoundTime',$getData->startRoundTime),
				'tokenMoveTime'      			=> set_value('tokenMoveTime',$getData->tokenMoveTime),
				'rollDiceTime'      			=> set_value('rollDiceTime',$getData->rollDiceTime),
				'entryFee'      			=> set_value('entryFee',$getData->entryFee),
				'gameMode'      			=> set_value('gameMode',$getData->gameMode),

				'firstRoundWinner' => set_value('firstRoundWinner',$getData->firstRoundWinner),
				'secondRoundWinner' => set_value('secondRoundWinner',$getData->secondRoundWinner),
				'thirdRoundWinner' => set_value('thirdRoundWinner',$getData->thirdRoundWinner),
				'fouthRoundWinner' => set_value('fouthRoundWinner',$getData->fouthRoundWinner),
				'fivethRoundWinner' => set_value('fivethRoundWinner',$getData->fivethRoundWinner),
				'sixthRoundWinner' => set_value('sixthRoundWinner',$getData->sixthRoundWinner),
				'seventhRoundWinner' => set_value('seventhRoundWinner',$getData->seventhRoundWinner),
				'eightRoundWinner' => set_value('eightRoundWinner',$getData->eightRoundWinner),
				'ninethRoundWinner' => set_value('ninethRoundWinner',$getData->ninethRoundWinner),
				'tenthRoundWinner' => set_value('tenthRoundWinner',$getData->tenthRoundWinner),
				// 'bigBlind'        			=> set_value('bigBlind',$getData->bigBlind),
				// 'startGameTimmer' 			=> set_value('startGameTimmer',$getData->startGameTimmer),
				// 'nextRoundTimmer' 			=> set_value('nextRoundTimmer',$getData->nextRoundTimmer),
				// 'gameOverTimmer'  			=> set_value('gameOverTimmer',$getData->gameOverTimmer),
				// 'breakTime'  				=> set_value('breakTime',$getData->breakTime),
				// 'percentOfWinPlayer'  		=> set_value('percentOfWinPlayer',$getData->percentOfWinPlayer),
				// 'status'          		 	=> set_value('status',$getData->status),
			);
		$this->load->view('tournaments/form',$data);
	}

	public function updateAction(){
        $tournamentId=$this->input->post('tournamentId');
		$this->form_rules($tournamentId);
		if($this->form_validation->run()==false){
	         $this->update(base64_encode($tournamentId));
	         }else{
		         	$savedata=array(
					'tournamentTitle'					=>$this->input->post('tournamentTitle',true),
					'startDate'							=>date("Y-m-d",strtotime($this->input->post('startDate',true))),
					'startTime'							=>date("H:i:s",strtotime($this->input->post('startTime',true))),
					'tournamentDescription'						=>$this->input->post('tournamentDescription',true),
					'winningPrice'							=>$this->input->post('winningPrice',true),
					'playerLimitInRoom'						=>$this->input->post('playerLimitInRoom',true),
					'noOfRoundInTournament'							=>$this->input->post('noOfRoundInTournament',true),
					'playerLimitInTournament'						=>$this->input->post('playerLimitInTournament',true),
					'commision'				=>$this->input->post('commision',true),
					'startRoundTime'					=>$this->input->post('startRoundTime',true),
					'tokenMoveTime'        				=> $this->input->post('tokenMoveTime',TRUE),
					'rollDiceTime'        				=> $this->input->post('rollDiceTime',TRUE),
					'entryFee'        				=> $this->input->post('entryFee',TRUE),
					'gameMode'        				=> $this->input->post('gameMode',TRUE),
					'firstRoundWinner' => $this->input->post('firstRoundWinner',TRUE),
					'secondRoundWinner' => $this->input->post('secondRoundWinner',TRUE),
					'thirdRoundWinner' => $this->input->post('thirdRoundWinner',TRUE),
					'fouthRoundWinner' => $this->input->post('fouthRoundWinner',TRUE),
					'fivethRoundWinner' => $this->input->post('fivethRoundWinner',TRUE),
					'sixthRoundWinner' => $this->input->post('sixthRoundWinner',TRUE),
					'seventhRoundWinner' => $this->input->post('seventhRoundWinner',TRUE),
					'eightRoundWinner' => $this->input->post('eightRoundWinner',TRUE),
					'ninethRoundWinner' => $this->input->post('ninethRoundWinner',TRUE),
					'tenthRoundWinner' => $this->input->post('tenthRoundWinner',TRUE),
					// 'bigBlind'          				=> $this->input->post('bigBlind',TRUE),
					// 'startGameTimmer'   				=> $this->input->post('startGameTimmer',TRUE),
					// 'nextRoundTimmer'   				=> $this->input->post('nextRoundTimmer',TRUE),
					// 'gameOverTimmer'    				=> $this->input->post('gameOverTimmer',TRUE),
					// 'breakTime'   						=> $this->input->post('breakTime',TRUE),
					// 'percentOfWinPlayer'    			=> $this->input->post('percentOfWinPlayer',TRUE),
					// 'status'							=>$this->input->post('status',true),
				);
	         	$cond="tournamentId='".$this->input->post('tournamentId')."'";
				$this->Tournaments_model->SaveData('mst_tournaments',$savedata,$cond);
				// $logData = array(
				// 	'tournamentTitle'					=>$this->input->post('tournamentTitle',true),
				// 	'startDate'							=>date("Y-m-d",strtotime($this->input->post('startDate',true))),
				// 	'startTime'							=>date("H:i:s",strtotime($this->input->post('startTime',true))),
				// 	'playerLimitInRoom'				    =>$this->input->post('playerLimitInRoom',true),
				// 	'playerLimitInTournament'			=>$this->input->post('playerLimitInTournament',true),
				// );
				// $this->Tournaments_model->SaveData('mst_tournament_logs',$logData,$cond);
				$msg = $this->session->set_flashdata('message', 'Record has been updated successfully');  
				redirect(TOURNAMENTS);
	         }
	}

	public function view($tournamentId){
    	$cond = "tournamentId = '".base64_decode($tournamentId)."'";
		$gettournaments = $this->Tournaments_model->GetData("mst_tournaments",'',$cond,'','','','1');
		$data = array(
			'heading'         				=> 'View Tournaments',
			'breadhead'       				=> 'Manage  Tournaments',
			'bread'           				=> 'View',
			'tournamentTitle'       		=> $gettournaments->tournamentTitle,
			'startDate'       				=> $gettournaments->startDate,
			'startTime'      				=> $gettournaments->startTime,
			'tournamentDescription'       			=> $gettournaments->tournamentDescription,
			'winningPrice'       				=> $gettournaments->winningPrice,
			'playerLimitInRoom'       			=> $gettournaments->playerLimitInRoom,
			'noOfRoundInTournament'       				=> $gettournaments->noOfRoundInTournament,
			'playerLimitInTournament'       	=> $gettournaments->playerLimitInTournament,
			'commision'       			=> $gettournaments->commision,
			'startRoundTime'       				=> $gettournaments->startRoundTime,
			'tokenMoveTime'       		=> $gettournaments->tokenMoveTime,
			'rollDiceTime'      				=> $gettournaments->rollDiceTime,
			'status'          				=> $gettournaments->status,
			'currentRound'      				=> $gettournaments->currentRound,
			'registerPlayerCount'        				=> $gettournaments->registerPlayerCount,
			'entryFee'        				=> $gettournaments->entryFee,
			'gameMode'        				=> $gettournaments->gameMode,
			// 'startTime'          			=> $gettournaments->startTime,
			// 'startGameTimmer' 				=> $gettournaments->startGameTimmer,
			// 'nextRoundTimmer' 				=> $gettournaments->nextRoundTimmer,
			// 'gameOverTimmer'  				=> $gettournaments->gameOverTimmer,
		);
    	$this->load->view('tournaments/view',$data);
    }



	public function deleteAction(){
	$cond="tournamentId='".$this->input->post('id')."'";
    $getdata=$this->Tournaments_model->GetData('mst_tournaments','',$cond,'','','','1');
	    if($getdata){
	   	$this->Tournaments_model->DeleteData('mst_tournaments',$cond,'1');
	   	$msg='Record has been deleted successfully';
		   }else{
		   		$msg='Record does not deleted';
		   }
		    $response=array(
		            'csrfName' =>$this->security->get_csrf_token_name(),
		            'csrfHash' => $this->security->get_csrf_hash(),
				    'msg'      => $msg
		    );
            echo json_encode($response);
    }

	public function statusChange(){
		$response = array(
				'csrfName' => $this->security->get_csrf_token_name(),
				'csrfHash' => $this->security->get_csrf_hash()
		);
		$cond = "tournamentId= '".$this->input->post('id')."'";
		$getUserData = $this->Tournaments_model->GetData("mst_tournaments",'',$cond,'','','','1');
		if($getUserData->status == 'Active'){
			$data=array(
						'status'=>"Inactive",
						);
		}
		else{
			$data=array(
						'status'=>"Active",
						);
		}
		$this->Tournaments_model->SaveData("mst_tournaments",$data,$cond);
		$msg='Status has been changed successfully';
		$response['msg'] = $msg;
		echo json_encode($response);
	}

	public function form_rules($tournamentId){
       $getdata=$this->Tournaments_model->GetData('mst_tournaments','',"tournamentTitle='".trim($this->input->post('tournamentTitle',TRUE))."' and tournamentId!='".$tournamentId."'");
        $unique="";
         if($getdata){
       	   $unique="|is_unique[mst_tournaments.tournamentTitle]";
       }
	 	$this->form_validation->set_rules('tournamentTitle','tournament title','required|trim|xss_clean'.$unique,
				  array(
				  'required'=>'Please enter %s.',
				  'is_unique'=>'This %s is already exist.',
				));
	 	$this->form_validation->set_rules('startDate','start date','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('startTime','start fee','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('tournamentDescription','description','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	// $this->form_validation->set_rules('winningPrice','winning price','required|trim|xss_clean',
			// 	  array(
			// 	  'required'=>'Please enter %s.',
			// 	));
	 	$this->form_validation->set_rules('playerLimitInRoom','player limit in room','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('noOfRoundInTournament','no of round','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('playerLimitInTournament','player limit in tournament','required|trim|xss_clean',
			  array(
			  'required'=>'Please enter %s.',
			));
	 	$this->form_validation->set_rules('commision','commission','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('startRoundTime','start round time','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('tokenMoveTime','token move time','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('rollDiceTime','roll dice time','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('entryFee','entry Fee','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));
	 	$this->form_validation->set_rules('gameMode','game mode','required|trim|xss_clean',
				  array(
				  'required'=>'Please select %s.',
				));
	 	$this->form_validation->set_rules('firstRoundWinner','first winner price','required|trim|xss_clean',
				  array(
				  'required'=>'Please enter %s.',
				));

	  //   $this->form_validation->set_rules('tournamentDescription','tournament description','required|trim|xss_clean',
			// 	  array(
			// 	  'required'=>'Please enter %s.',
			// 	));
	  //   $this->form_validation->set_rules('tournamentSize','tournament size','required|trim|xss_clean',
			// 		  array(
			// 		  'required'=>'Please enter %s.',
			// 		));
 	}

 	public function getUserList($tournamentId){
 		$tournamentId = base64_decode($tournamentId);
 		$data = array(
			'heading' => 'Manage Tournaments Register User',
			'head' => 'Manage Tournaments',
			'bread' => 'Manage Tournaments Register User',
			'tournamentId'=>$tournamentId,
		);
		$this->load->view('tournaments/userList',$data);
 	}

 	public function user_ajax_manage_page(){
 		$tournamentId = $this->input->post('SearchData');
 		$con = "tr.tournamentId='".$tournamentId."'";
 		$getData = $this->TournamentsUsers_model->get_datatables('tournament_registrations tr',$con);
		
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getData as $getTournaments) 
		{			
			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($getTournaments->userName);
		    $nestedData[] = $getTournaments->entryFee;
		    $nestedData[] = $getTournaments->isEnter;
		    // $nestedData[] = $getTournaments->isWin;
		    $nestedData[] = $getTournaments->round;
         	$nestedData[] = $getTournaments->isDelete;
         	$nestedData[] = $getTournaments->roundStatus;
            $nestedData[] = date('d-m-Y',strtotime($getTournaments->created));
            $nestedData[] = '<a href="'.site_url(TOURNAMENTUSERHISTORY.'/'.base64_encode($tournamentId).'/'.base64_encode($getTournaments->userId)).'"><label class="btn btn-warning btn-xs" title="History"><i class="fa fa-history"></i></label></a>';
		    
		    $data[] = $nestedData;
		}
		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->TournamentsUsers_model->count_all('tournament_registrations tr',$con),
					"recordsFiltered" => $this->TournamentsUsers_model->count_filtered('tournament_registrations tr',$con),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
 	}

 	public function getUserHistory($tournamentId,$userId){
 		$tournamentId = base64_decode($tournamentId);
 		$userId = base64_decode($userId);
 		$data = array(
			'heading' => 'Manage Tournaments Register User History',
			'head' => 'Manage Tournaments',
			'bread' => 'Manage Tournaments Register User History',
			'tournamentId'=>$tournamentId,
			'userId'=>$userId,
		);
		$this->load->view('tournaments/userHistory',$data);
 	}

 	public function user_history_ajax_manage_page(){
 		$tournamentId = $this->input->post('SearchData');
 		$userId = $this->input->post('SearchData1');
 		$con = "tr.tournamementId='".$tournamentId."' and userId='".$userId."'";
 		$getData = $this->TournamentsUsersHistory_model->get_datatables('tournament_win_loss_logs tr',$con);
		
		if(empty($_POST['start']))
        {
            $no =0;   
        }else{
             $no =$_POST['start'];
        }
		$data = array();
         		  
		foreach ($getData as $getTournaments) 
		{			
			$no++;
			$nestedData = array();
		    $nestedData[] = $no;
		    $nestedData[] = ucfirst($getTournaments->tournamentTitle);
		    $nestedData[] = ucfirst($getTournaments->userName);
		    $nestedData[] = $getTournaments->entryFee;
		    $nestedData[] = $getTournaments->round;
         	$nestedData[] = $getTournaments->roundStatus;
         	$nestedData[] = $getTournaments->playerLimitInRoom;
            $nestedData[] = date('d-m-Y',strtotime($getTournaments->startDate));
            $nestedData[] = date('H:i:s',strtotime($getTournaments->startTime));
		    
		    $data[] = $nestedData;
		}
		$output = array(
					"draw" => $_POST['draw'],
					"recordsTotal" => $this->TournamentsUsersHistory_model->count_all('tournament_win_loss_logs tr'),
					"recordsFiltered" => $this->TournamentsUsersHistory_model->count_filtered('tournament_win_loss_logs tr'),
					"data" => $data,
					"csrfHash" => $this->security->get_csrf_hash(),
					"csrfName" => $this->security->get_csrf_token_name(),
				);
		echo json_encode($output);
 	}
}