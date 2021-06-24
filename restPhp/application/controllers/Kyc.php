<?php
defined('BASEPATH') OR exit('No direct script access allowed'); 

require APPPATH . '/libraries/REST_Controller.php';

class Kyc extends REST_Controller {

 	function __construct()
    {
        parent::__construct();
        $this->load->helper('custom_helper');
        $this->load->library('email');
        $this->load->library('Custom');
        $config['protocol'] = 'sendmail';
        $config['mailpath'] = '/usr/sbin/sendmail';
        $config['charset'] = 'iso-8859-1';
        $config['wordwrap'] = TRUE;
        $this->email->initialize($config);
    }

// public function kycAdd_post() {
//     headers();
//     $this->_request =  file_get_contents("php://input");
//     $jsonDecodeData = json_decode($this->_request, true);
//     $userId  = $jsonDecodeData['userId'];
//     $documentImg  = $jsonDecodeData['documentImg'];
//     $documentType  = $jsonDecodeData['documentType'];

//     $accHolderName  = $jsonDecodeData['accHolderName'];
//     $bankName  = $jsonDecodeData['bankName'];
//     $bankCity  = $jsonDecodeData['bankCity'];
//     $bankBranch  = $jsonDecodeData['bankBranch'];
//     $accNo  = $jsonDecodeData['accNo'];
//     $ifsc  = $jsonDecodeData['ifsc'];

//     if(!empty($userId)){
//         $getuser = $this->Crud_model->GetData('user_details','',"id='".$userId."'", '', '', '', '1');
//         if(!empty($getuser)){
//             if(!empty($documentImg)) 
//             { 
//                 $aadharBImg = base64_decode($documentImg);
//                 $aadharbackImg = 'Doc_'.md5(uniqid(rand(), true));// image name generating with random number with 32 characters
//                 $filenameB = $aadharbackImg.'.png';
//                 file_put_contents(FCPATH."../admin/uploads/kycImgs/".$filenameB,$aadharBImg,TRUE);
//                 $aahdarUpBImg = $filenameB;
//                 $doc_img = $aahdarUpBImg; 
//                 if(!empty($getuser->documentImg)){
//                     unlink('../admin/uploads/kycImgs/'.$getuser->documentImg);
//                 }
//             }else if($getuser->documentImg) { 
//                 $doc_img = $getuser->documentImg; 
//             }else{
//                 $doc_img ='';
//             }
//             if(!empty($documentType)){
//                 $docType = $documentType;
//             } else{
//                 $docType = $getuser->documentType;
//             }
//             if(!empty($accHolderName)){
//                 $name = $accHolderName;
//             }else{
//                 $name = $getuser->accHolderName;
//             }
//             if(!empty($bankName)){
//                 $bankname = $bankName;
//             }else{
//                 $bankname = $getuser->bankName;
//             } 
//             if(!empty($bankCity)){
//                 $city = $bankCity;
//             }else{
//                 $city = $getuser->bankCity;
//             } 
//             if(!empty($bankBranch)){
//                 $branch = $bankBranch;
//             }else{
//                 $branch = $getuser->bankBranch;
//             } 
//             if(!empty($accNo)){
//                 $number = $accNo;
//             }else{
//                 $number = $getuser->accNo;
//             } 
//             if(!empty($ifsc)){
//                 $code = $ifsc;
//             }else{
//                 $code = $getuser->ifsc;
//             }

//             $data = array(
//                 "documentImg"=>$doc_img,
//                 "documentType"=>$docType,
//                 "accHolderName"=>$name,
//                 "bankName"=>$bankname,
//                 "bankCity"=>$city,
//                 "bankBranch"=>$branch,
//                 "accNo"=>$number,
//                 "ifsc"=>$code,
//             );
//             $this->Crud_model->SaveData('user_details',$data,"id='".$userId."'");
//             $dataBank = array(
//                 "documentImg"=>$doc_img,
//                 "documentType"=>$docType,
//             );
//             $this->Crud_model->SaveData('bank_details',$dataBank,"user_detail_id='".$userId."'");

//             $response = array('status' => TRUE, 'success' => "1", 'message' => "Kyc added successfully");
//         }else{
//             $response = array('status' => FALSE, 'success' => "0", 'message' => "no record found");
//         }
//     }else{
//         $response = array('status' => FALSE, 'success' => "0", 'message' => "please enter UserId");
//     }
//     $this->response($response,REST_Controller::HTTP_CREATED);
// }

// public function kycGet_post() {
//     headers();
//     $this->_request =  file_get_contents("php://input");
//     $jsonDecodeData =json_decode($this->_request, true);
//     $userId         = $jsonDecodeData['userId'];
//     if(!empty($userId)){
//         $condition="id='".$userId."'";
//         $getKycData = $this->Crud_model->GetData('user_details','',$condition,'','','','1');
//         if(!empty($getKycData)){
//             $kycData = array(
//                 "id"=>$getKycData->id,
//                 "user_name"=>$getKycData->user_name,
//                 "mobile"=>$getKycData->mobile,
//                 "documentImg"=>$getKycData->documentImg,
//                 // "docImgUrl"=>"control-panel/uploads/kycImgs/".$getKycData->documentImg,
//                 "documentType"=>$getKycData->documentType,
//                 "accHolderName"=>$getKycData->accHolderName,
//                 "bankName"=>$getKycData->bankName,
//                 "bankCity"=>$getKycData->bankCity,
//                 "bankBranch"=>$getKycData->bankBranch,
//                 "accNo"=>$getKycData->accNo,
//                 "ifsc"=>$getKycData->ifsc,
//                 "kyc_status"=>$getKycData->kyc_status,
//                 "kycDate"=>$getKycData->kycDate,
//             );
//             $response = array('status' => TRUE, 'success' => "1", 'response' => $kycData);
//         }else{
//             $response = array('status' => FALSE, 'success' => "0", 'message' => "no record found");
//         }
//     }else{
//         $response = array('status' => FALSE, 'success' => "0", 'message' => "please enter UserId");
//     }
//     $this->response($response,REST_Controller::HTTP_CREATED);
// }

   public function addKyc_post() {
       // print_r("expression");exit;
        headers();
        $this->_request =  file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true);
        $userId                 = $jsonDecodeData['userId'];
        //$emailId                 = $jsonDecodeData['emailId'];
        $mobile                 = $jsonDecodeData['mobile'];
        $aadharNo               = $jsonDecodeData['aadharNo'];
        $aadharUserName         = $jsonDecodeData['aadharUserName'];
        $panUserName            = $jsonDecodeData['panUserName'];
        $panNo                  = $jsonDecodeData['panNo'];
        $aadharFrontImg         = $jsonDecodeData['aadharFrontImg'];
        $aadharBackImg          = $jsonDecodeData['aadharBackImg'];
        $panImg                 = $jsonDecodeData['panImg'];
        $accHolderName          = $jsonDecodeData['accHolderName'];
        $accno                  = $jsonDecodeData['accno'];
        $ifsc                   = $jsonDecodeData['ifsc'];
        $bankName               = $jsonDecodeData['bankName'];
        $bankCity               = $jsonDecodeData['bankCity'];
       
        if(!empty($userId)){
              $userData=$this->Crud_model->GetData('user_details','id,user_name,is_mobileVerified,mobile',"id='".$userId."'", '', '', '', '1');
              if($userData){
                    if(!empty($mobile)){
                        $eUpdate="No";
                        if($userData){
                            if($userData->mobile == $mobile && $userData->is_mobileVerified=='Yes'){
                                $isMobileCheck=0;
                            }else{
                                $isMobileCheck=2;
                            }
                        }else{
                            $isMobileCheck=3;
                        }
                          if($isMobileCheck == 2 && $mobile == $userData->mobile){
                              $response = array('status' => FALSE, 'success' => "4", 'message' => "please verify your mobile No.");  
                          }else{
                               $response = array('status' => FALSE, 'success' => "5", 'message' => "please enter correct mobile No.");  
                          }
                    }else{
                         $isMobileCheck=1;//empty
                    }
                    if($isMobileCheck !=2 ){
                        if((!empty($aadharUserName) &&!empty($aadharNo) && !empty($aadharFrontImg) && !empty($aadharBackImg)) || (!empty($panUserName) && !empty($panNo) && !empty($panImg)) || (!empty($accHolderName) && !empty($accno) && !empty($ifsc) && !empty($bankName) && !empty($bankCity)))
                        {
                           
                            /*-------------------------- For Aadhar Card Verification-------------------------*/
                            $getUserData = $this->Crud_model->get_single('user_details',"id='".$userId."'");
                            

                            $adharUser =  '';
                            if(!empty($aadharUserName)) 
                            { 
                                $adharUser = $aadharUserName; 
                            }else if($getUserData->adharUserName) { 
                                $adharUser = $getUserData->adharUserName; 
                            }

                            $adharCardNo =  '';
                            if(!empty($aadharNo)) 
                            { 
                                $adharCardNo = $aadharNo; 
                            }else if($getUserData->adharCard_no) { 
                                $adharCardNo = $getUserData->adharCard_no; 
                            }

                            $aadharfront_img='';
                            if(!empty($aadharFrontImg)) 
                            { 
                                $aadharFImg = base64_decode($aadharFrontImg);
                                $aadharImg = 'Aadhar_'.md5(uniqid(rand(), true));// image name generating with random number with 32 characters
                                $filenameF = $aadharImg.'.png';
                                file_put_contents(FCPATH."../admin/uploads/kycImgs/aadhar/".$filenameF,$aadharFImg,TRUE);
                                $aahdarUpImg = $filenameF;
                                $aadharfront_img = $aahdarUpImg; 
                            }else if($getUserData->adharFron_img) { 
                                // unlink('../admin/uploads/kycImgs/aadhar/'.$getUserData->adharFron_img);
                                $aadharfront_img = $getUserData->adharFron_img; 
                            }else{
                                $aadharfront_img='';
                            }

                            $aadharback_img='';
                            if(!empty($aadharBackImg)) 
                            { 
                                $aadharBImg = base64_decode($aadharBackImg);
                                $aadharbackImg = 'AadharB_'.md5(uniqid(rand(), true));// image name generating with random number with 32 characters
                                $filenameB = $aadharbackImg.'.png';
                                file_put_contents(FCPATH."../admin/uploads/kycImgs/aadhar/".$filenameB,$aadharBImg,TRUE);
                                $aahdarUpBImg = $filenameB;
                                $aadharback_img = $aahdarUpBImg; 
                            }else if($getUserData->adharBack_img) { 
                                //unlink('../admin/uploads/kycImgs/aadhar/'.$getUserData->adharBack_img);
                                $aadharback_img = $getUserData->adharBack_img; 
                            }else{
                                $aadharback_img='';
                            }

                            $is_aadharVerified='';
                            $aadharRejectReason='';
                            if(!empty($aadharNo)) 
                            { 
                                $is_aadharVerified = "Pending"; 
                                $aadharRejectReason="";
                                $kycStatus = "Pending";
                            }else if(empty($panNo)){
                              $kycStatus = "Pending";
                              $is_aadharVerified = $getUserData->is_aadharVerified; 
                              $aadharRejectReason = $getUserData->aadharRejectionReason;
                            }else if($getUserData->is_aadharVerified) { 
                                $is_aadharVerified = $getUserData->is_aadharVerified; 
                                $aadharRejectReason = $getUserData->aadharRejectionReason; 
                                $kycStatus =  $getUserData->kyc_status;
                            }

                            /*-------------------------- For Pan Card Verification-------------------------*/
                            $panUser='';
                            if(!empty($panUserName)) 
                            { 
                                $panUser = $panUserName; 
                            }else if($getUserData->panUserName) { 
                                $panUser = $getUserData->panUserName; 
                            }

                            $panCardNo='';
                            if(!empty($panNo)) 
                            { 
                                $panCardNo = $panNo; 
                            }else if($getUserData->panCard_no) { 
                                $panCardNo = $getUserData->panCard_no; 
                            }
                            
                            $panCardImg='';
                            if(!empty($panImg)) { 
                                $pan_img = base64_decode($panImg);
                                $panImage = 'Pan_'.md5(uniqid(rand(), true));// image name generating with random number with 32 characters
                                $filename = $panImage.'.png';
                                file_put_contents(FCPATH."../admin/uploads/kycImgs/pan/".$filename,$pan_img,TRUE);
                                $panUpImg = $filename;
                                $panCardImg = $panUpImg; 
                            }else if($getUserData->pan_img) { 
                                $panCardImg = $getUserData->pan_img; 
                            }else{
                                $panCardImg='';
                            }
                            
                            $is_panVerified='';
                            $panRejectReason='';
                            if(!empty($panNo)) 
                            { 
                                $is_panVerified = "Pending";
                                $panRejectReason = ""; 
                                $kycStatus = "Pending";
                            }elseif(empty($panNo)){
                              $kycStatus = "Pending";
                              $is_panVerified = $getUserData->is_panVerified; 
                              $panRejectReason = $getUserData->panRejectionReason;
                            }elseif($getUserData->is_panVerified) { 
                                $is_panVerified = $getUserData->is_panVerified; 
                                $panRejectReason = $getUserData->panRejectionReason;
                                $kycStatus = $getUserData->kyc_status; 
                            }

                            $data= array(
                                    'adharUserName'=>$adharUser,
                                    'panUserName'=>$panUser,
                                    'adharCard_no'=>$adharCardNo,
                                    'panCard_no'=>$panCardNo,
                                    'adharFron_img'=>$aadharfront_img,
                                    'adharBack_img'=>$aadharback_img,
                                    'pan_img'=>$panCardImg,
                                    'is_aadharVerified'=>$is_aadharVerified,
                                    'is_panVerified'=>$is_panVerified,
                                    'panRejectionReason'=>$panRejectReason,
                                    'aadharRejectionReason'=>$aadharRejectReason,
                                    'kycDate'=>date("Y-m-d"),
                                    'kyc_status'=>$kycStatus,
                                );
                            $this->Crud_model->SaveData('user_details',$data,"id='".$userId."'");

                            $KycDataLog=array(
                                    'user_detail_id'=>$userId,
                                    'adharUserName'=>$adharUser,
                                    'panUserName'=>$panUser,
                                    'adharCard_no'=>$adharCardNo,
                                    'panCard_no'=>$panCardNo,
                                    'adharFron_img'=>$aadharfront_img,
                                    'adharBack_img'=>$aadharback_img,
                                    'pan_img'=>$panCardImg,
                                    'is_aadharVerified'=>$is_aadharVerified,
                                    'is_panVerified'=>$is_panVerified,
                                    'kyc_status'=>$kycStatus,
                                );
                             $this->Crud_model->SaveData('kyc_logs',$KycDataLog);


                            $getBankexist = $this->Crud_model->get_single('bank_details',"user_detail_id='".$userId."'");
                            //print_r($getBankexist);exit;
                            $accholderName =  '';
                            if(!empty($accHolderName)) 
                            { 
                                $accholderName = $accHolderName; 
                            }else if(!empty($getBankexist->acc_holderName)) { 
                                $accholderName = $getBankexist->acc_holderName; 
                            }

                            $acc_no =  '';
                            if(!empty($accno)) 
                            { 
                                $acc_no = $accno; 
                            }else if(!empty($getBankexist->accno)) { 
                                $acc_no = $getBankexist->accno; 
                            }
                        
                            $ifsc_code =  '';
                            if(!empty($ifsc)) 
                            { 
                                $ifsc_code = $ifsc; 
                            }else if(!empty($getBankexist->ifsc)) { 
                                $ifsc_code = $getBankexist->ifsc; 
                            }
                            

                            $bankname =  '';
                            if(!empty($bankName)) 
                            { 
                                $bankname = $bankName; 
                            }else if(!empty($getBankexist->bank_name)) { 
                                $bankname = $getBankexist->bank_name; 
                            }

                            $bankcity =  '';
                            if(!empty($bankCity)) 
                            { 
                                $bankcity = $bankCity; 
                            }else if(!empty($getBankexist->bank_city)) { 
                                $bankcity = $getBankexist->bank_city; 
                            }
                            

                           
                           // print_r($getBankexist->is_bankVerified);exit;
                           // $is_bankVerified='';
                            //$bankRejectReason='';
                            $kyc_data=date("Y-m-d");
                            if(!empty($accno)) 
                            { 
                               // $is_bankVerified = "Pending";
                               // $bankRejectReason = ""; 
                                $kyc_data = date("Y-m-d");
                                //$kycStatus = "Pending";
                            }elseif(!empty($getBankexist) && $getBankexist->is_bankVerified) { 
                                //$is_bankVerified = $getBankexist->is_bankVerified; 
                                //$bankRejectReason = $getUserData->bankRejectionReason; 
                                $kyc_data=date("Y-m-d");
                                //$kycStatus = $getUserData->kyc_status;
                            }
                            //print_r($kyc_data);exit;

                            $data= array(
                                'user_detail_id'=>$userId,
                                'acc_holderName'=>$accholderName,
                                'accno'=>$acc_no,
                                'ifsc'=>$ifsc_code,
                                'bank_name'=>$bankname,
                                'bank_city'=>$bankcity,
                                //'is_bankVerified'=>$is_bankVerified,
                            );
                           
                            //$bankData= array('bankRejectionReason'=>$bankRejectReason);
                            $date=array('kycDate'=>$kyc_data);
                           // $date=array('kycDate'=>$kyc_data,'kyc_status'=>$kycStatus);
                            if (!empty($getBankexist)) {
                                //print_r("if");exit;
                                $this->Crud_model->SaveData('bank_details',$data,"user_detail_id='".$userId."'");
                                //$this->Crud_model->SaveData('user_details',$bankData,"id='".$userId."'");
                                $this->Crud_model->SaveData('user_details',$date,"id='".$userId."'");
                                $KycBankDataLog=array(
                                    'user_detail_id'=>$userId,
                                    'acc_holderName'=>$accholderName,
                                    'accno'=>$acc_no,
                                    'ifsc'=>$ifsc_code,
                                    'bank_name'=>$bankname,
                                    'bank_city'=>$bankcity,
                                    //'is_bankVerified'=>$is_bankVerified,
                                    //'kyc_status'=>$kycStatus,
                                );
                                $this->Crud_model->SaveData('kyc_logs',$KycBankDataLog);
                            }else{
                                // print_r("else");exit;
                                $this->Crud_model->SaveData('bank_details',$data);
                                //$this->Crud_model->SaveData('user_details',$bankData,"id='".$userId."'");
                            }
                            $response = array('status' => TRUE, 'success' => "1", 'message' => "kyc added succesfully.");
                        }else{
                            $response = array('status' => FALSE, 'success' => "2", 'message' => "All fields are required");
                        }
                    }
              }else{
                $response = array('status' => FALSE, 'success' => "0", 'message' => "No Record Found");
              }
                
        }else{
            $response = array('status' => FALSE, 'success' => "0", 'message' => "please enter UserId");
        }
        $this->response($response,REST_Controller::HTTP_CREATED);
    }


    public function getKyc_post() {
        headers();
        $this->_request =  file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true);

        $userId         = $jsonDecodeData['userId'];

        if(!empty($userId)){
        $condition="ud.id='".$userId."'";
        $getKycData = $this->Crud_model->getKyc('user_details ud',$condition);
        if(!empty($getKycData)){
          
            if(!empty($getKycData->adharFron_img)){
                $getKycData->adharFron_img = base_url().'../admin/uploads/kycImgs/aadhar/'.''.$getKycData->adharFron_img;
            }else{
                $getKycData->adharFron_img='';
            }

            if(!empty($getKycData->adharBack_img)){
                $getKycData->adharBack_img = base_url().'../admin/uploads/kycImgs/aadhar/'.''.$getKycData->adharBack_img;
            }else{
                $getKycData->adharBack_img='';
            }

            if(!empty($getKycData->pan_img)){
               $getKycData->pan_img = base_url().'../admin/uploads/kycImgs/pan/'.''.$getKycData->pan_img;
            }else{
                $getKycData->pan_img='';
            }

            if(!empty($getKycData->is_aadharVerified=="Rejected") && !empty($getKycData->aadharRejectionReason)){
                $getKycData->aadharRejectionReason= $getKycData->aadharRejectionReason;
                $getKycData->is_aadharVerified= $getKycData->is_aadharVerified;
            }elseif(!empty($getKycData->is_aadharVerified=="Pending") && !empty($getKycData->aadharRejectionReason)){
                $getKycData->aadharRejectionReason= $getKycData->aadharRejectionReason;
                $getKycData->is_aadharVerified= $getKycData->is_aadharVerified;
            }else{
                $getKycData->aadharRejectionReason= $getKycData->aadharRejectionReason;
                $getKycData->is_aadharVerified= $getKycData->is_aadharVerified;
            }


            if(!empty($getKycData->is_panVerified=="Rejected") && !empty($getKycData->panRejectionReason)){
                $getKycData->panRejectionReason= $getKycData->panRejectionReason;
                $getKycData->is_panVerified= $getKycData->is_panVerified;
            }elseif(!empty($getKycData->is_panVerified=="Pending") && !empty($getKycData->panRejectionReason)){
                $getKycData->panRejectionReason= $getKycData->panRejectionReason;
                $getKycData->is_panVerified= $getKycData->is_panVerified;
            }else{
                $getKycData->panRejectionReason= $getKycData->panRejectionReason;
                $getKycData->is_panVerified= $getKycData->is_panVerified;
            }


            if(!empty($getKycData->is_bankVerified == "Rejected") && !empty($getKycData->bankRejectionReason)){
                $getKycData->bankRejectionReason = $getKycData->bankRejectionReason;
                $getKycData->is_bankVerified = $getKycData->is_bankVerified;
            }elseif(!empty($getKycData->is_bankVerified=="Pending") && !empty($getKycData->bankRejectionReason)){
                $getKycData->bankRejectionReason= $getKycData->bankRejectionReason;
                $getKycData->is_bankVerified= $getKycData->is_bankVerified;
            }else{
                $getKycData->bankRejectionReason= $getKycData->bankRejectionReason;
                $getKycData->is_bankVerified= $getKycData->is_bankVerified;
            }

            unset($getKycData->registrationType);
            unset($getKycData->socialId);
            unset($getKycData->user_name);
            unset($getKycData->country_name);
            unset($getKycData->profile_img);
            unset($getKycData->password);
            unset($getKycData->otp);
            unset($getKycData->otp_verify);
            unset($getKycData->blockuser);
            unset($getKycData->last_login);
            unset($getKycData->signup_date);
            unset($getKycData->referred_by);
            unset($getKycData->balance);
            unset($getKycData->userLevel);
            unset($getKycData->device_id);
            unset($getKycData->playerProgress);
            unset($getKycData->mobile);
            unset($getKycData->referal_code);
            unset($getKycData->status);
            unset($getKycData->is_emailVerified);
           
            $response = array('status' => TRUE, 'success' => "1",'data'=>$getKycData, 'message' => "Success");
        }else{
            $response = array('status' => FALSE, 'success' => "2", 'message' => "No Record Found");
        }
        }else{
            $response = array('status' => FALSE, 'success' => "0", 'message' => "please enter UserId");
        }
        $this->response($response,REST_Controller::HTTP_CREATED);
    }


    function mail_post(){
         header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, PUT, POST, DELETE, OPTIONS');
        header('Access-Control-Max-Age: 1000');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header("Content-type: application/json");
        header('Access-Control-Allow-Credentials:true');
        $this->_request = file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true); 

        $this->custom->sendEmailSmtp("sub",'body','nilesh410451@gmail.com');
        
        $response = array('status' => TRUE, 'success' => "1");
        $this->response($response,REST_Controller::HTTP_CREATED);

    }
     function sendSmsApi_post(){
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, PUT, POST, DELETE, OPTIONS');
        header('Access-Control-Max-Age: 1000');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header("Content-type: application/json");
        header('Access-Control-Allow-Credentials:true');
        $this->_request = file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true); 
        $username = 'SanthoshiLakshmik';
        $apiKey = 'A0F46-2A862';
        $apiRequest = 'Text';
        // Message details
        $numbers = $jsonDecodeData['mobileNo']; // Multiple numbers separated by comma
        $senderId = 'RVNENT';
        $message = $jsonDecodeData['replacedSmsBody'];
        // Route details
        $apiRoute = 'TRANS';
        // Prepare data for POST request
        $data = 'username='.$username.'&apikey='.$apiKey.'&apirequest='.$apiRequest.'&route='.$apiRoute.'&mobile='.$numbers.'&sender='.$senderId."&message=".$message;
        // Send the GET request with cURL
        $url = 'http://www.alots.in/sms-panel/api/http/index.php?'.$data;
        $url = preg_replace("/ /", "%20", $url);
        $response = file_get_contents($url);
        // Process your response here
        $response = array('status' => TRUE, 'success' => "1");
        $this->response($response,REST_Controller::HTTP_CREATED);
    }
    function sendSmsApi2_post(){
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, PUT, POST, DELETE, OPTIONS');
        header('Access-Control-Max-Age: 1000');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header("Content-type: application/json");
        header('Access-Control-Allow-Credentials:true');

        $this->_request = file_get_contents("php://input");
        $jsonDecodeData =json_decode($this->_request, true); 
        $response = array('status' => TRUE, 'success' => "1");
        $this->response($response,REST_Controller::HTTP_CREATED);
    }

}
?>