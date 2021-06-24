<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');



class Custom
{


	public function __contruct($params =array())
    {
        $this->CI->config->item('base_url');
        $this->CI->load->helper('url');
         $this->load->library('bcrypt');
        $this->CI->load->database();
        $this->CI->library('session');
        $this->CI->library('email');
        $CI =& get_instance();
        //$this->CI =& get_instance();
       // $this->CI->load->database();
    }  

    /*public function sendEmailSmtp($subject,$body_email,$to)
    {
    	//http://3.20.220.191/admin/index.php/Zsendgridmail/index/tbsdev@tbsind.com
    	//https://api.sendgrid.com/api/mail.send.json
        $url = 'https://api.sendgrid.com/';
		$user = 'ludofantasy';
		$pass = 'cUGR$xg8rpFZ$a.';
		$params = array(
		    'api_user'  => $user,
		    'api_key'   => $pass,
		    'to'        => $to,
		    'subject'   => $subject,
		    'html'      => $body_email,
		    //'text'      => $body_email,
		    'from'      => 'info@ludofantacy.com',
		  );


		$request =  $url.'api/mail.send.json';
		//print_r($request);exit;

		// Generate curl request
		$session = curl_init($request);
		// Tell curl to use HTTP POST
		curl_setopt ($session, CURLOPT_POST, true);
		// Tell curl that this is the body of the POST
		curl_setopt ($session, CURLOPT_POSTFIELDS, $params);
		// Tell curl not to return headers, but do return the response
		curl_setopt($session, CURLOPT_HEADER, false);
		// Tell PHP not to use SSLv3 (instead opting for TLS)
		curl_setopt($session, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_2);
		curl_setopt($session, CURLOPT_RETURNTRANSFER, true);

		// obtain response
		$response = curl_exec($session);
		curl_close($session);
		//return $response;
		// print everything out
		print_r($response);exit;
    }*/


    public function sendEmailSmtp($subject,$body_email,$to)
    {
    	//http://3.20.220.191/admin/index.php/Zsendgridmail/index/tbsdev@tbsind.com
    	//https://api.sendgrid.com/api/mail.send.json
        $url = 'https://api.sendgrid.com/';
		$user = 'ludofantasy';
		$pass = 'cUGR$xg8rpFZ$a.';
		$params = array(
		    'api_user'  => $user,
		    'api_key'   => $pass,
		    'to'        => $to,
		    'subject'   => $subject,
		    'html'      => $body_email,
		    //'text'      => $body_email,
		    'from'      => 'info@ludofantacy.com',
		  );


		$request =  $url.'api/mail.send.json';
		//print_r($request);exit;

		// Generate curl request
		$session = curl_init($request);
		// Tell curl to use HTTP POST
		curl_setopt ($session, CURLOPT_POST, true);
		// Tell curl that this is the body of the POST
		curl_setopt ($session, CURLOPT_POSTFIELDS, $params);
		// Tell curl not to return headers, but do return the response
		curl_setopt($session, CURLOPT_HEADER, false);
		// Tell PHP not to use SSLv3 (instead opting for TLS)
		curl_setopt($session, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_2);
		curl_setopt($session, CURLOPT_RETURNTRANSFER, true);

		// obtain response
		$response = curl_exec($session);
		curl_close($session);
		//return $response;
		// print everything out
		//print_r($response);exit;
    }

    function sendEmailSmtp_old($subject,$body_email,$to)
	{
		$CI =& get_instance();
		$CI->load->library('email');
		$config['protocol']    = 'smtp';
		$config['smtp_host']    = 'ssl://smtp.gmail.com';
		$config['smtp_port']    = '465';
		$config['smtp_timeout'] = '7';
		$config['smtp_user']    = 'ludo.power2019@gmail.com';
		$config['smtp_pass']    = 'vtabwzhcpgmbxdoc';
		$config['charset']    = 'utf-8';
		$config['newline']    = "\r\n";
		$config['mailtype'] = 'html'; // or html
		$CI->email->initialize($config);
		$CI->email->from('ludo.power2019@gmail.com', 'Ludo Power');
		$CI->email->to($to);
		$CI->email->subject($subject);
		$CI->email->message($body_email);
		$CI->email->send();
	}

	 function sendTest($subject,$body_email,$to)
	{
		$CI =& get_instance();
		$CI->load->library('email');
		$from = "shriram@tbsind.com";
		$config['protocol']    = 'smtp';
	    $config['smtp_host']    = 'ses-smtp-user.20200214-164606';
		//$config['smtp_host']    = 'ssl://smtp.gmail.com';
		$config['smtp_port']    = '25';
		$config['smtp_timeout'] = '7';
		$config['smtp_user']    = 'AKIAQF73EBVP4MH77ZBQ';
		$config['smtp_pass']    = 'BC3JgK2l+MLbApk1f+CeZKcQxDgdMnHH3dN+4rQuvPEH';
		$config['charset']    = 'utf-8';
		$config['newline']    = "\r\n";
		$config['mailtype'] = 'html'; // or html
		$config['validation'] = TRUE; // bool whether to validate email or not      
		$CI->email->initialize($config);
		$CI->email->from($from,'REMITOUT');
		$CI->email->to($to);
		$CI->email->subject($subject);
		$CI->email->message($body_email);
		$CI->email->send();
	}
/*

<?php
// Authorisation details.
$username = "ludofantasy1@gmail.com";
$hash = "b329085b4779d9c9a00c9432e0fe43bf37be7c6b2023e87768179a63a496968a";

// Config variables. Consult http://api.textlocal.in/docs for more info.
$test = "0";

// Data for text message. This is the text message data.
$sender = "TXTLCL"; // This is who the message appears to be from.
$numbers = "910000000000"; // A single number or a comma-seperated list of numbers
$message = "This is a test message from the PHP API script.";
// 612 chars or less
// A single number or a comma-seperated list of numbers
$message = urlencode($message);
$data = "username=".$username."&hash=".$hash."&message=".$message."&sender=".$sender."&numbers=".$numbers."&test=".$test;
$ch = curl_init('http://api.textlocal.in/send/?');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$result = curl_exec($ch); // This is the result from the API
curl_close($ch);
?>
*/
	// function sendSms($mobileNo,$sms_body)
	// {  
	// 	//http://api.textlocal.in//send//?username=ludofantasy1@gmail.com&hash=b329085b4779d9c9a00c9432e0fe43bf37be7c6b2023e87768179a63a496968a&message=252763+is+your+OTP+%28One+Time+Password%29+to+verify+your+user+account+on+Ludo+Fantacy&sender=LUDOFN&numbers=8999068231&test=0
	// 	$username = "ludofantasy1@gmail.com";
	// 	$hash = "b329085b4779d9c9a00c9432e0fe43bf37be7c6b2023e87768179a63a496968a";
	// 	$test = "0";
	// 	// Data for text message. This is the text message data.
	// 	$sender = "LUDOFN"; // This is who the message appears to be from.
	// 	$numbers = $mobileNo; // A single number or a comma-seperated list of numbers
	// 	$message = $sms_body;
	// 	// 612 chars or less
	// 	// A single number or a comma-seperated list of numbers
	// 	$message = urlencode($message);
	// 	$data = "username=".$username."&hash=".$hash."&message=".$message."&sender=".$sender."&numbers=".$numbers."&test=".$test;
	// 	$ch = curl_init('http://api.textlocal.in/send/?');
	// 	curl_setopt($ch, CURLOPT_POST, true);
	// 	curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
	// 	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	// 	$result = curl_exec($ch); // This is the result from the API
	// 	curl_close($ch);

		
	// }
	function sendSms($mobileNo,$sms_body)
	{  
        $username = 'SanthoshiLakshmik';
        $apiKey = 'A0F46-2A862';
        $apiRequest = 'Text';
        // Message details
        $numbers = $mobileNo; // Multiple numbers separated by comma
        $senderId = 'RVNENT';
        $message = $sms_body;
        // Route details
        $apiRoute = 'TRANS';
        // Prepare data for POST request
        $data  = 'username='.$username.'&apikey='.$apiKey.'&apirequest='.$apiRequest.'&route='.$apiRoute.'&mobile='.$numbers.'&sender='.$senderId."&message=".$message;
        // Send the GET request with cURL
        $url = 'http://www.alots.in/sms-panel/api/http/index.php?'.$data;
        $url = preg_replace("/ /", "%20", $url);
        $response = file_get_contents($url);

		
	}

	function sendSmsOld($mobileNo,$sms_body)
	{  
		
		
		$username = 'ludofantasy1@gmail.com';
	    $apiKey = 'b329085b4779d9c9a00c9432e0fe43bf37be7c6b2023e87768179a63a496968a';
	    $apiRequest = 'Text';
	    // Message details
	    $numbers = $mobileNo; // Multiple numbers separated by comma
	    $senderId = 'LUDOFN';
	    $message = $sms_body;
	    // Route details
	    $apiRoute = 'TRANS';
	    // Prepare data for POST request
	    $data = 'username='.$username.'&apikey='.$apiKey.'&apirequest='.$apiRequest.'&route='.$apiRoute.'&mobile='.$numbers.'&sender='.$senderId."&message=".$message;
	    // Send the GET request with cURL
	    $url = 'http://www.alots.in/sms-panel/api/http/index.php?'.$data;
	    //print_r($url);exit();
	    $url = preg_replace("/ /", "%20", $url);
	    $response = file_get_contents($url);
	    // Process your response here
	    //echo $response;
	}
}

?> 