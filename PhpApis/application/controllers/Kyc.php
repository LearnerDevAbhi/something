<?php
defined('BASEPATH') OR exit('No direct script access allowed'); 

require APPPATH . '/libraries/REST_Controller.php';

 $clientId = 'CF72735BQNFC3N45TW6U2Q';
$clientSecret = '432718f950b3338e930a8e55e4ab4804c5201bba';
$env = 'prod';
$signature=null;

#config objs
$baseUrls = array(
    'prod' => 'https://payout-api.cashfree.com',
    'test' => 'https://payout-gamma.cashfree.com',
);
$urls = array(
    'auth' => '/payout/v1/authorize',
    'getBene' => '/payout/v1/getBeneficiary/',
    'addBene' => '/payout/v1/addBeneficiary',
    'requestTransfer' => '/payout/v1/requestTransfer',
    'getTransferStatus' => '/payout/v1/getTransferStatus?transferId='
);
$beneficiary = array(
    'beneId' => 'JOHN18019',
    'name' => 'jhon doe',
    'email' => 'johndoe@cashfree.com',
    'phone' => '9876543210',
    'bankAccount' => '000890289871772',
    'ifsc' => 'SCBL0036078',
    'address1' => 'address1',
    'city' => 'bangalore',
    'state' => 'karnataka',
    'pincode' => '560001',
);
$transfer = array(
    'beneId' => 'JOHN18019',
    'amount' => '1.00',
    'transferId' => 'DEC2039',
);

$header = array(
    'X-Cf-Signature: '.$signature,
    'X-Client-Id: '.$clientId,
    'X-Client-Secret: '.$clientSecret, 
    'Content-Type: application/json',
);

$baseurl = $baseUrls[$env];
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



   
public  function getSignature() {
    $clientId = "CF72735BQNFC3N45TW6U2Q";
    $publicKey =
    openssl_pkey_get_public(file_get_contents("http://localhost/ludokrishcashfree.pem"));
    $encodedData = $clientId.".".strtotime("now");
    return static::encrypt_RSA($encodedData, $publicKey);
  }
private  function encrypt_RSA($plainData, $publicKey) { if (openssl_public_encrypt($plainData, $encrypted, $publicKey,
OPENSSL_PKCS1_OAEP_PADDING))
      $encryptedData = base64_encode($encrypted);
    else return NULL;
    return $encryptedData;
  }

function create_header($token){
    global $header;
    $headers = $header;
    if(!is_null($token)){
        array_push($headers, 'Authorization: Bearer '.$token);
    }
    return $headers;
}

function post_helper($action, $data, $token){
    global $baseurl, $urls;
    $finalUrl = $baseurl.$urls[$action];
    $headers = $this->create_header($token);
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_URL, $finalUrl);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch,  CURLOPT_RETURNTRANSFER, true);
    if(!is_null($data)) curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data)); 
    
    $r = curl_exec($ch);
    
    if(curl_errno($ch)){
        //print('error in posting');
        //print(curl_error($ch));
        //die();
    }
    curl_close($ch);
    $rObj = json_decode($r, true);    
    if($rObj['status'] != 'SUCCESS' || $rObj['subCode'] != '200') throw new Exception('incorrect response: '.$rObj['message']);
    return $rObj;
}

function get_helper($finalUrl, $token){
    $headers = $this->create_header($token);

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $finalUrl);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch,  CURLOPT_RETURNTRANSFER, true);
    
    $r = curl_exec($ch);
   
    if(curl_errno($ch)){
       //// print('error in posting');
       // print(curl_error($ch));
       // die();
    }
    curl_close($ch);

    $rObj = json_decode($r, true);    
    if($rObj['status'] != 'SUCCESS' || $rObj['subCode'] != '200') throw new Exception('incorrect response: '.$rObj['message']);


    return $rObj;
}

#get auth token
function getToken(){
    try{
       $response = $this->post_helper('auth', null, null);
       return $response['data']['token'];
    }
    catch(Exception $ex){
        error_log('error in getting token');
        error_log($ex->getMessage());
         return $ex->getMessage();
    }

}

#get beneficiary details
function getBeneficiary($token,$benid1){
    try{
        global $baseurl, $urls, $beneficiary;
        $beneId = $benid1;

        $finalUrl = $baseurl.$urls['getBene'].$beneId;

        $response = $this->get_helper($finalUrl, $token);
         
        return true;
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();

        if(strstr($msg, 'Beneficiary does not exist')) return false;
        error_log('error in getting beneficiary details');
        error_log($msg);
       
        //die();
    }    
}

#add beneficiary
function addBeneficiary($token,$beneficiary1){
    try{
        global $beneficiary;
        $response =$this->post_helper('addBene', $beneficiary1, $token);
        error_log('beneficiary created');
        //print($response);
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in creating beneficiary');
        error_log($msg);
        //print($msg);
      //  die();
    }    
}

#request transfer
function requestTransfer($token){
    try{
        global $transfer;
        $response = post_helper('requestTransfer', $transfer, $token);
        error_log('transfer requested successfully');
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in requesting transfer');
        error_log($msg);
        die();
    }
}

#get transfer status
function getTransferStatus($token){
    try{
        global $baseurl, $urls, $transfer;
        $transferId = $transfer['transferId'];
        $finalUrl = $baseurl.$urls['getTransferStatus'].$transferId;
        $response = get_helper($finalUrl, $token);
        error_log(json_encode($response));
    }
    catch(Exception $ex){
        $msg = $ex->getMessage();
        error_log('error in getting transfer status');
        error_log($msg);
        die();
    }
}








  

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


if($accno!="" && $accno!=null && $accno!=" "){

$signature= $this->getSignature();
   
         $beneficiary = array(
    'beneId' => $accno,
    'name' => $accHolderName,
    'email' => $userId .'@gmail.com',
    'phone' =>  $mobile ,
    'bankAccount' =>  $accno,
    'ifsc' =>  $ifsc   ,
    'address1' => $bankCity  ,
    'city' =>  $bankCity  ,
    'state' => 'karnataka',
    'pincode' => '560001',
        );
  
        #main execution
            $token =  $this->getToken();
       
            if(!$this->getBeneficiary($token,$beneficiary['beneId'])) 
            {
             $this->addBeneficiary($token, $beneficiary);
             }




         }


       
       
        if(!empty($userId)){
              if(!empty($mobile)){
                    $mobileVerified=$this->Crud_model->GetData('user_details','id,user_name,is_mobileVerified,mobile',"id='".$userId."'", '', '', '', '1');
                    $eUpdate="No";
                    if($mobileVerified){
                        if($mobileVerified->mobile == $mobile && $mobileVerified->is_mobileVerified=='Yes'){
                            $isMobileCheck=0;
                        }else{
                            $isMobileCheck=2;
                        }
                    }else{
                        $isMobileCheck=3;
                    }
                      if($isMobileCheck == 2 && $mobile == $mobileVerified->mobile){
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
                            file_put_contents(FCPATH."../control-panel/uploads/kycImgs/aadhar/".$filenameF,$aadharFImg,TRUE);
                            $aahdarUpImg = $filenameF;
                            $aadharfront_img = $aahdarUpImg; 
                        }else if($getUserData->adharFron_img) { 
                            // unlink('../control-panel/uploads/kycImgs/aadhar/'.$getUserData->adharFron_img);
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
                            file_put_contents(FCPATH."../control-panel/uploads/kycImgs/aadhar/".$filenameB,$aadharBImg,TRUE);
                            $aahdarUpBImg = $filenameB;
                            $aadharback_img = $aahdarUpBImg; 
                        }else if($getUserData->adharBack_img) { 
                            //unlink('../control-panel/uploads/kycImgs/aadhar/'.$getUserData->adharBack_img);
                            $aadharback_img = $getUserData->adharBack_img; 
                        }else{
                            $aadharback_img='';
                        }

                        $is_aadharVerified='';
                        $aadharRejectReason='';
                        if(!empty($aadharNo)){ 
                            $is_aadharVerified = "Pending"; 
                            $aadharRejectReason="";
                            $kycStatus = "Pending";
                        }elseif(empty($panNo)){
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
                            file_put_contents(FCPATH."../control-panel/uploads/kycImgs/pan/".$filename,$pan_img,TRUE);
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
                $getKycData->adharFron_img = base_url().'../control-panel/uploads/kycImgs/aadhar/'.''.$getKycData->adharFron_img;
            }else{
                $getKycData->adharFron_img='';
            }

            if(!empty($getKycData->adharBack_img)){
                $getKycData->adharBack_img = base_url().'../control-panel/uploads/kycImgs/aadhar/'.''.$getKycData->adharBack_img;
            }else{
                $getKycData->adharBack_img='';
            }

            if(!empty($getKycData->pan_img)){
               $getKycData->pan_img = base_url().'../control-panel/uploads/kycImgs/pan/'.''.$getKycData->pan_img;
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



            if(!empty($getKycData->is_bankVerified=="Rejected") && !empty($getKycData->bankRejectionReason)){
                $getKycData->bankRejectionReason= $getKycData->bankRejectionReason;
                $getKycData->is_bankVerified= $getKycData->is_bankVerified;
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