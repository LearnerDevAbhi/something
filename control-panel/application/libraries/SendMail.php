<?php
if (!defined('BASEPATH'))
    exit('No direct script access allowed');

class SendMail{

    public function __contruct($params =array())
    {       
        $this->CI->config->item('base_url');
        $this->CI->load->helper('url');
        $this->CI->load->database();
        $this->CI->library('session');
        $this->CI->library('email');
        $CI =& get_instance();
    }  
    
    function Send($Data)
    {
		 print_r($Data);exit;
        $CI =& get_instance();
        $config['protocol']    = 'smtp';
        $config['smtp_host']    = 'ssl://smtp.gmail.com';
        $config['smtp_port']    = '465';
        $config['smtp_timeout'] = '7';
        $config['smtp_user']    = 'tbsitplraja@gmail.com';
        $config['smtp_pass']    = 'ljcsnlzakvlmolfj';
        $config['charset']    = 'utf-8';
        $config['newline']    = "\r\n";
        $config['mailtype'] = 'html'; // or html//
        $config['validation'] = TRUE; // bool whether to validate email or not      
        $CI->email->initialize($config);
        $CI->email->from('tbsitplraja@gmail.com', 'Housie');   
        $CI->email->to($Data['mailoutbox_to']);
        $CI->email->subject($Data['mailoutbox_subject']);      
        $CI->email->message($Data['mailoutbox_body']);
        $CI->email->send();
        // print_r($attachment);exit;
        // echo $CI->email->print_debugger();exit;
    }
}

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

 

class Custom
{


    public function __contruct($params =array())
    {
       
        $this->CI->config->item('base_url');
        $this->CI->load->helper('url');
        $this->CI->load->database();
        $this->CI->library('session');
        $this->CI->library('email');
        $CI =& get_instance();
        //$this->CI =& get_instance();
       // $this->CI->load->database();
    }  


    function sendEmailSmtp($subject,$body_email,$to)
    {
        $CI =& get_instance();
        $CI->load->library('email');
        $config['protocol']    = 'smtp';
        $config['smtp_host']    = 'ssl://smtp.gmail.com';
        $config['smtp_port']    = '465';
        $config['smtp_timeout'] = '7';
        $config['smtp_user']    = 'xyz@gmail.com';
        $config['smtp_pass']    = 'vtabwzhcpgmbxdoc';
        $config['charset']    = 'utf-8';
        $config['newline']    = "\r\n";
        $config['mailtype'] = 'html'; // or html
        $CI->email->initialize($config);
        $CI->email->from('xyz@gmail.com', 'Ludo Fantacy');
        $CI->email->to($to);
        $CI->email->subject($subject);
        $CI->email->message($body_email);
        // if (!empty($attachment))
        // {
        //     //print_r($attachment);exit;
        //     $CI->email->attach($attachment);
        // }
        // if (!empty($attachment1)) {
        //     $CI->email->attach($attachment1);
        // }
        // if(!empty($RemoveAttachment))
        // {
        //     unlink($RemoveAttachment);
        // }
        $CI->email->send();
        //echo $CI->email->print_debugger();
    }


    function sendSms($mobileNo,$sms_body)
    {  
        $username = 'xyz';
        $apiKey = '67AB2-152CF';
        $apiRequest = 'Text';
        // Message details
        $numbers = $mobileNo; // Multiple numbers separated by comma
        $senderId = 'LUDSKL';
        $message = $sms_body;
        // Route details
        $apiRoute = 'TRANS';
        // Prepare data for POST request
        $data = 'username='.$username.'&apikey='.$apiKey.'&apirequest='.$apiRequest.'&route='.$apiRoute.'&mobile='.$numbers.'&sender='.$senderId."&message=".$message;
        // Send the GET request with cURL
        $url = 'http://www.alots.in/sms-panel/api/http/index.php?'.$data;
        $url = preg_replace("/ /", "%20", $url);
        $response = file_get_contents($url);
        // Process your response here
        //echo $response;
    }
}

?>