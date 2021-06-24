<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');
	

	// function headers()
	// {
 //        $ci =&get_instance();
 //        header('Access-Control-Allow-Origin: *');
 //        header('Access-Control-Allow-Methods: POST');
 //        header('Access-Control-Max-Age: 1000');
 //        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
 //        header("Content-type: application/json");
 //        $ci->_request =  file_get_contents("php://input");
 //        $ci->_request=implode("",explode("\\",$ci->_request));
	// }


     function headers()
    {
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, PUT, POST, DELETE, OPTIONS');
        header('Access-Control-Max-Age: 1000');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
        header("Content-type: application/json");
        header('Access-Control-Allow-Credentials:true');
    }

        function base64_to_jpeg($base64_string) {
    // open the output file for writing
            if(!empty($base64_string)) {
            $image = base64_decode($base64_string);
            // decoding base64 string value
           // $image_name = md5(uniqid(rand(), true));// image name generating with random number with 32 characters
            $filenameClean = preg_replace("/\s+/", "",rand());
            $filename = $filenameClean.'.'.'png';
            //rename file name with random number
            file_put_contents(FCPATH."uploads/rental/".$filename, $image,TRUE);
            return $filename;
            }
            else
            {
                 return $filename = '';
            }

        }
?>

