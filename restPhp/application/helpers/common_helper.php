

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
    function sendEmailSmtp($subject,$body_email,$to,$from,$attachment='',$removeattachment='')
    {
        //$from = "nafeesdadi@gmail.com";
        //$pass = "nafeez05$";
        $pass = "Pass$123";
        $CI =& get_instance();
        $config['protocol']    = 'smtp';
        $config['smtp_host']    = 'mail.mailgun.com';
        $config['smtp_port']    = '465';
        $config['smtp_timeout'] = '7';
        $config['smtp_user']    = $from;
        $config['smtp_pass']    = $pass;
        $config['charset']    = 'utf-8';
        $config['newline']    = "\r\n";
        $config['mailtype'] = 'html'; // or html
        $config['validation'] = TRUE; // bool whether to validate email or not      
        $CI->email->initialize($config);
        $CI->email->from($from, 'RemitOut');
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
        }
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

    function Sendsms($PhNo,$Text,$sms_link)
    {      
      $sms_link->value = str_replace("{phone_no}",$PhNo,$sms_link->value);
      $sms_link->value = str_replace("{text_message}",$Text,$sms_link->value);  
      $url = $sms_link->value;
      $ch = curl_init();
      curl_setopt($ch, CURLOPT_URL,$url); 
      curl_setopt($ch, CURLOPT_FAILONERROR, 1);
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); 
      curl_setopt($ch, CURLOPT_RETURNTRANSFER,1); 
      curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 0);
      curl_setopt($ch, CURLOPT_REFERER, $_SERVER['REQUEST_URI']);
      $result = curl_exec($ch); 
      $result = curl_error($ch) ? curl_error($ch) : $result;
      curl_close($ch);
    }
?>