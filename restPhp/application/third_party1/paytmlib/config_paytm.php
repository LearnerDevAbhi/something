<?php
/*

- Use PAYTM_ENVIRONMENT as 'PROD' if you wanted to do transaction in production environment else 'TEST' for doing transaction in testing environment.
- Change the value of PAYTM_MERCHANT_KEY constant with details received from Paytm.
- Change the value of PAYTM_MERCHANT_MID constant with details received from Paytm.
- Change the value of PAYTM_MERCHANT_WEBSITE constant with details received from Paytm.
- Above details will be different for testing and production environment.*/


define('PAYTM_ENVIRONMENT', 'TEST'); // PROD 
define('PAYTM_MERCHANT_KEY', 's6IGGfvrh#w@t41W'); //Merchant key downloaded from portal
define('PAYTM_MERCHANT_MID', 'otjVEx52359125695001'); //MID (Merchant ID) received from Paytm
define('PAYTM_MERCHANT_WEBSITE', 'WEBSTAGING'); //Website name received from Paytm*/

/*

define('PAYTM_ENVIRONMENT', 'PROD'); // PROD 
define('PAYTM_MERCHANT_KEY', 'ekSMk18p6x9VAezZ'); //Merchant key downloaded from portal
define('PAYTM_MERCHANT_MID', ''); //MID (Merchant ID) received from Paytm
define('PAYTM_MERCHANT_WEBSITE', 'WEB'); //Website name received from Paytm
*/
$PAYTM_DOMAIN = 'securegw-staging.paytm.in';
if (PAYTM_ENVIRONMENT == 'PROD') {
	//$PAYTM_DOMAIN = 'secure.paytm.in';
	$PAYTM_DOMAIN = 'securegw.paytm.in';
}





//define('PAYTM_REFUND_URL', 'https://'.$PAYTM_DOMAIN.'/oltp/HANDLER_INTERNAL/REFUND');
define('PAYTM_STATUS_QUERY_URL', 'https://'.$PAYTM_DOMAIN.'/oltp/HANDLER_INTERNAL/TXNSTATUS');
//define('PAYTM_TXN_URL', 'https://'.$PAYTM_DOMAIN.'/oltp-web/processTransaction');
define('PAYTM_TXN_URL', 'https://'.$PAYTM_DOMAIN.'/theia/processTransaction');
define('PAYTM_REFUND_URL', 'https://'.$PAYTM_DOMAIN.'/refund/HANDLER_INTERNAL/REFUND');
?>