<?php

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
		// if (!empty($attachment))
		// {
		// 	//print_r($attachment);exit;
		// 	$CI->email->attach($attachment);
		// }
		// if (!empty($attachment1)) {
		// 	$CI->email->attach($attachment1);
		// }
		// if(!empty($RemoveAttachment))
		// {
		// 	unlink($RemoveAttachment);
		// }
		$CI->email->send();

		//echo $CI->email->print_debugger();
	}


	
}

?> 