<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Welcome extends CI_Controller {

	/**
	 * Index Page for this controller.
	 *
	 * Maps to the following URL
	 * 		http://example.com/index.php/welcome
	 *	- or -
	 * 		http://example.com/index.php/welcome/index
	 *	- or -
	 * Since this controller is set as the default controller in
	 * config/routes.php, it's displayed at http://example.com/
	 *
	 * So any other public methods not prefixed with an underscore will
	 * map to /index.php/welcome/<method_name>
	 * @see https://codeigniter.com/user_guide/general/urls.html
	 */
	public function index()
	{
		$this->load->view('welcome_message');
	}
	public function payMentSucces($success)
	{
		// status 1 is success
		if($success== '1'){
			$msg = "Payment Success";
		}else{
			$msg = "Payment Failed";
		}

		if($success=='2'){
			$msg = "Order Id Already Exits.";
		}
		
		$data=array(
			'msg'=>$msg
		);
		$this->load->view('pattm/paytm_success',$data);
	}
}
