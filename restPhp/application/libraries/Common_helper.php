

<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

if (!function_exists('IND_money_format'))
{
	function IND_money_format($number){   
		$min = '';
		if($number<0){
			$min ='-';
			$number = abs($number);
		}
        $decimal = (string)($number - floor($number));
        $money = floor($number);
        $length = strlen($money);
        $delimiter = '';
        $money = strrev($money);
 
        for($i=0;$i<$length;$i++){
            if(( $i==3 || ($i>3 && ($i-1)%2==0) )&& $i!=$length){
                $delimiter .=',';
            }
            $delimiter .=$money[$i];
        }
 
        $result = strrev($delimiter);
        $decimal = preg_replace("/0\./i", ".", $decimal);
        $decimal = substr($decimal, 0, 3);
 
        if( $decimal != '0'){
            $result = $result.$decimal;
        }
        return $min.$result;
    }
}
 
function getResponseFromCurl($url, $method, $postData='')
    {
        //print_r($postData);exit();
       $method = strtoupper($method);
        $cURL = curl_init();
        curl_setopt_array($cURL, array(
        //CURLOPT_PORT => "8000",
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_ENCODING => "",
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_POSTFIELDS => $postData,
        CURLOPT_HTTPHEADER => array(
            "Authorization: Basic Rm9yZXg6UGFzcyQxMjM=",
            "Cache-Control: no-cache",
            "x-api-key: s4w8k8go4cw4s8gsg8w4oow4wgcggwk0o88s0c8k"
          ),
        ));
        $response = curl_exec($cURL);
        //print_r($response);exit();
        $err = curl_error($cURL);
        curl_close($cURL);
        if($err) 
        {
            return "error"; 
        }
        else
        {
            $responseData = json_decode($response, true);
            return $responseData;
        }
    }
    function sendEmailSmtp($subject,$body_email,$to,$from,$attachment='',$removeattachment='')
    {
        
       /* $CI =& get_instance();
        $config['protocol']    = 'smtp';
        $config['smtp_host']    = 'mail.buildinfra.in';
        $config['smtp_port']    = '25';
        $config['smtp_timeout'] = '7';
        $config['smtp_user']    = $from;
        $config['smtp_pass']    = 'pass$123';
        $config['charset']    = 'utf-8';
        $config['newline']    = "\r\n";
        $config['mailtype'] = 'html'; // or html
        $config['validation'] = TRUE; // bool whether to validate email or not      
        $CI->email->initialize($config);
        $CI->email->from($from, 'Remitout');
        $CI->email->to($to);
        $CI->email->subject($subject);
        $CI->email->message($body_email);
        if (!empty($attachment)) 
        {
            $CI->email->attach($attachment);
        }
        $CI->email->send();     
        if (!empty($removeattachment)) 
        {
            unlink($removeattachment);
        }*/
        
        
        // Always set content-type when sending HTML email
			$headers = "MIME-Version: 1.0" . "\r\n";
			$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";

			// More headers
			$headers .= 'From: Remitout <".$from.">' . "\r\n";
       // print_r($body_mail);exit;
			mail($subject,$body_email,$to,$headers);
    }
     function sendNotification($subject,$body,$appId)
    {
        ///print_r("hi");exit();
        $AppID[]=$appId;
        $Notification_title[]='Booking Request';
        $notification_type[]='Booking';
        $notification_logo[]=$image_path;
        
        $hashes_array = array();
        array_push($hashes_array, array(
            "id" => "like-button",
            "text" => "Like",
            "icon" => $image_path,
        ));
        
        $headings = array(
            "en" => $subject
        );
        $content = array(
            "en" => $body
        ); 
        $fields = array(
            'app_id' => "4de71a5c-00b1-495b-ab18-569e2cb3f4e5",
            'include_player_ids' => $AppID,
            'data' => array("type"=> $notification_type,),
            'contents' => $content,
            'headings' => $headings,
            'small_icon' => $image_path,
            'web_buttons' => $hashes_array);    
        $fields = json_encode($fields);
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json; charset=utf-8',
                                                   'Authorization: Basic ZGYwNGIxNDYtZTZjNy00OTQ2LTliMTAtOWFjNzQ5OGYzZWNi'));
        curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, 5);
        curl_setopt ($ch, CURLOPT_AUTOREFERER, true);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
        curl_setopt ($ch, CURLOPT_SSL_VERIFYHOST, 2);
        $result = curl_exec($ch);
    }
    function sendSms($PhNo,$Text,$sms_link)
    {
      ///print_r($sms_link);exit();
      $sms_link->value = str_replace("{PhNo}",$PhNo,$sms_link->value);
      $sms_link->value = str_replace("{Text}",$Text,$sms_link->value);  
    //$ret = file($url);
      $url = $sms_link->value;
      print_r($url);
      echo file_get_contents($url);exit;
    /*  $ch = curl_init();
      curl_setopt($ch, CURLOPT_URL,$url); 
      curl_setopt($ch, CURLOPT_FAILONERROR, 1);
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); 
      curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); 
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 0);
      curl_setopt($ch, CURLOPT_REFERER, $_SERVER['REQUEST_URI']);
      $result = curl_exec($ch); 
      $result = curl_error($ch) ? curl_error($ch) : $result;
      curl_close($ch);*/
    }

?>