<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
|--------------------------------------------------------------------------
| Display Debug backtrace
|--------------------------------------------------------------------------
|
| If set to TRUE, a backtrace will be displayed along with php errors. If
| error_reporting is disabled, the backtrace will not display, regardless
| of this setting
|
*/
defined('SHOW_DEBUG_BACKTRACE') OR define('SHOW_DEBUG_BACKTRACE', TRUE);

/*
|--------------------------------------------------------------------------
| File and Directory Modes
|--------------------------------------------------------------------------
|
| These prefs are used when checking and setting modes when working
| with the file system.  The defaults are fine on servers with proper
| security, but you may wish (or even need) to change the values in
| certain environments (Apache running a separate process for each
| user, PHP under CGI with Apache suEXEC, etc.).  Octal values should
| always be used to set the mode correctly.
|
*/
defined('FILE_READ_MODE')  OR define('FILE_READ_MODE', 0644);
defined('FILE_WRITE_MODE') OR define('FILE_WRITE_MODE', 0666);
defined('DIR_READ_MODE')   OR define('DIR_READ_MODE', 0755);
defined('DIR_WRITE_MODE')  OR define('DIR_WRITE_MODE', 0755);
define('passno','c817638dd559d336192ed5351d04e4b6');

/*
|--------------------------------------------------------------------------
| File Stream Modes
|--------------------------------------------------------------------------
|
| These modes are used when working with fopen()/popen()
|
*/
defined('FOPEN_READ')                           OR define('FOPEN_READ', 'rb');
defined('FOPEN_READ_WRITE')                     OR define('FOPEN_READ_WRITE', 'r+b');
defined('FOPEN_WRITE_CREATE_DESTRUCTIVE')       OR define('FOPEN_WRITE_CREATE_DESTRUCTIVE', 'wb'); // truncates existing file data, use with care
defined('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE')  OR define('FOPEN_READ_WRITE_CREATE_DESTRUCTIVE', 'w+b'); // truncates existing file data, use with care
defined('FOPEN_WRITE_CREATE')                   OR define('FOPEN_WRITE_CREATE', 'ab');
defined('FOPEN_READ_WRITE_CREATE')              OR define('FOPEN_READ_WRITE_CREATE', 'a+b');
defined('FOPEN_WRITE_CREATE_STRICT')            OR define('FOPEN_WRITE_CREATE_STRICT', 'xb');
defined('FOPEN_READ_WRITE_CREATE_STRICT')       OR define('FOPEN_READ_WRITE_CREATE_STRICT', 'x+b');

/*
|--------------------------------------------------------------------------
| Exit Status Codes
|--------------------------------------------------------------------------
|
| Used to indicate the conditions under which the script is exit()ing.
| While there is no universal standard for error codes, there are some
| broad conventions.  Three such conventions are mentioned below, for
| those who wish to make use of them.  The CodeIgniter defaults were
| chosen for the least overlap with these conventions, while still
| leaving room for others to be defined in future versions and user
| applications.
|
| The three main conventions used for determining exit status codes
| are as follows:
|
|    Standard C/C++ Library (stdlibc):
|       http://www.gnu.org/software/libc/manual/html_node/Exit-Status.html
|       (This link also contains other GNU-specific conventions)
|    BSD sysexits.h:
|       http://www.gsp.com/cgi-bin/man.cgi?section=3&topic=sysexits
|    Bash scripting:
|       http://tldp.org/LDP/abs/html/exitcodes.html
|
*/
defined('EXIT_SUCCESS')        OR define('EXIT_SUCCESS', 0); // no errors
defined('EXIT_ERROR')          OR define('EXIT_ERROR', 1); // generic error
defined('EXIT_CONFIG')         OR define('EXIT_CONFIG', 3); // configuration error
defined('EXIT_UNKNOWN_FILE')   OR define('EXIT_UNKNOWN_FILE', 4); // file not found
defined('EXIT_UNKNOWN_CLASS')  OR define('EXIT_UNKNOWN_CLASS', 5); // unknown class
defined('EXIT_UNKNOWN_METHOD') OR define('EXIT_UNKNOWN_METHOD', 6); // unknown class member
defined('EXIT_USER_INPUT')     OR define('EXIT_USER_INPUT', 7); // invalid user input
defined('EXIT_DATABASE')       OR define('EXIT_DATABASE', 8); // database error
defined('EXIT__AUTO_MIN')      OR define('EXIT__AUTO_MIN', 9); // lowest automatically-assigned error code
defined('EXIT__AUTO_MAX')      OR define('EXIT__AUTO_MAX', 125); // highest automatically-assigned error code
// session name
define("title", 'Ludo');
define("SESSION_NAME", 'LUDO');



//  •  You can download the checksum utility from the link
//      •  MID -Dragon23841871619947
//      •  Merchant Key -Fo_AcvYl1IUh#mxw
//      •  Merchant_Guid -  6814a09b-1150-41a3-9f96-7e565b21c21c
//      •  MARKETING_DEALS\SalesWalletGuid - 674f60f6-618c-11ea-8708-fa163e429e83

// Kindly use mobile number 7777777777 for testing the gratification flow over staging environment
// test 

// define('guid', '674f60f6-618c-11ea-8708-fa163e429e83');
// define('key', 'Fo_AcvYl1IUh#mxw');
// define('isLivePaytm', 'No');
// define('mid', 'Dragon23841871619947');


define('guid', '9b836097-650d-4fb2-9fb2-f9b66b6ab5c3');
define('key', 'K_T1LfYr#5B9wA%h%K0!x1L');
define('mid', 'VizagC93143337804905');

define('gratificationGuId', 'f738c3e5-670d-480c-ba7b-2e79cdc9c8d2');
define('gratificationMerchantID', 'VizagC93143337804905');
define('gratificationMerchantKey', 'K_T1LfYr#5B9wA%h%M');

define("ISLIVE", 'Yes');

//routing
define('LOGIN','login');
define('PROFILE','profile');
define('LOGOUT','logout');
define('DASHBOARD','dashboard');
define('CHNGPASSWORD','change-password');
define('LOGINACTION','login-action');

/* Users Constant */
define('USERS','users');
define('USERVIEW','users-view');
define('USEREXPORT','users-export');
define('USERCHANGESTATUS','users-change-status');
define('USERCHANGEPASSWORD','users-change-password');
define('DELUSER','users-delete');
define('USERUPDATEBAL','users-updatebal');
define('USERGAMEPLAYEDEXPORT','users-gameplayedexport');
define('USERCOMPWITHDRAWEXPORT','users-compwithdrawexport');
define('USERCOMPDEPOSITEXPORT','users-compdepositexport');
define('USERREFERALBONUSEXPORT','users-referalbonusexport');
define('USEGAMEPLAYBONUSEXPORT','users-gameplaybonusexport');
define('USERKYCVIEW','users-kycview');


/* Users Constant */
define('FACEBOOKUSERS','facebookusers');


define('REFERRAL','referral');
define('REFERRALVIEW','referral-view');

/* Global setting Constant */
define('SETTINGS','settings');
define('SETTINGSCMSUPDATEACTION','settings-updateaction');
define('DAYWISETIMINGS','daywise-timings');
define('DAYWISETIMINGSUPDATE','update-daywise-timings');


/* Payment transaction Constant */
define('PAYMENTTRANSACTION','paymenttransaction');
define('PAYMENTTRANSACTIONEXPORT','paymenttransaction-export');

/* Game record  Constant */
define('GAMERECORD','gamerecord');

/* Withdrawal  Constant */
define('WITHDRAWAL','withdrawal');
define('WITHDRAWALDISTRIBUTE','withdrawal-approval');
define('WITHDRAWALEXPORT','withdrawal-export');


/*  Withdrawal Complete request  Constant */
define('WITHDRAWALCOMPREQ','withdrawalcompletedreq');
define('WITHDRAWALCOMPREQLIST','withdrawalcompletedreq-list');
define('WITHDRAWALCOMPREQEXPORT','withdrawalcompletedreq-export');
define('WITHDRAWALCOMPREQVIEW','withdrawalcompletedreq-view');

/* Withdrawal reject request  Constant */
define('WITHDRAWALREJECTREQ','withdrawalrejectreq');
define('WITHDRAWALREJECTREQLIST','withdrawalrejectreq-list');
define('WITHDRAWALREJECTREQEXPORT','withdrawalrejectreq-export');
define('WITHDRAWALREJECTVIEW','withdrawalrejectreq-view');

/* Withdrawal reject request  Constant */
define('WITHDRAWALBANKEXPORT','withdrawbybank');
define('WITHDRAWALBANKEXPORTLIST','withdrawbybank-list');
define('BANKWITHDRAWALEXPORT','withdrawbybank-export');

/* Maintainance  Constant */
define('MAINTAINANCE','maintainance');


/* Room  Constant */
define('GAMEPLAY','rooms');
define('GAMEPLAYCREATE', 'rooms-create');
define('GAMEPLAYSTATUS', 'rooms-status');
define('GAMEPLAYUPDATE', 'rooms-update');
define('GAMEPLAYACTION', 'rooms-action');
define('GAMEPLAYAJAX', 'rooms-ajax_manage_page');
define('GAMEPLAYIMPORT', 'rooms-import');
define('GAMEPLAYDELETE', 'rooms-delete');


/* Bonus Constants */
define('BONUS','bonus');
define('BONUSAJAX','bonus-list');
define('BONUSCREATE','bonus-create');
define('BONUUPDATEE','bonus-update');
define('BONUSCREATEACTION','bonus-createaction');
define('BONUSUPDATEACTION','bonus-updateaction');
define('BONUSIMPORT','bonus-import');



/* KYC  Constant */
define('KYC','kyc');
define('KYCAJAXLIST','kyc-list');
define('VERIFYKYC','kyc-verify');
define('KYCIMG','kyc-viewimage');
define('KYCBANKDETAIL','kyc-bankdetail');
define('KYCVIEW','kyc-view');
define('KYCEXPORT','kyc-export');
define('DELKYC','kyc-delete');

define('VERIFIEDKYC','verified');
define('VERIFIEDKYCLIST','verified-kyclist');
define('VERIFIEDKYCVIEW','verified-kycview');

/* Deposit Constant */
define('DEPOSIT','deposit');
define('AJAXDEPOSITLIST','deposit-list');
define('DEPOSITEXPORT','deposit-export');

define('TODAYSDEPOSIT','todaysdeposit');
define('TODAYSDEPOSITLIST','todaysdeposit-list');


/* Bot Constant */
define('BOTPLAYER','botPlayer');
define('BOTPLAYERAJAX','botPlayer-list');
define('BOTPLAYERCREATE','botPlayer-create');
define('BOTPLAYERCREATEACTION','botPlayer-createaction');
define('BOTPLAYERUPDATE','botPlayer-edit');
define('BOTPLAYERUPDATEACTION','botPlayer-editaction');
define('BOTPLAYERDELETE','botPlayer-delete');

/* contact us Constant */
define('CONTACTUS','contactus');
define('CONTACTAJAXLIST','contactus-ajax');
define('CONTACTDELETE','contactus-delete');
define('SENDREPLY','contactus-reply');
define('GETSENDREPLY','contactus-getreply');

/* REPORT  Constant */
define('USERREPORT','userreport');
define('USERREPORTLIST','userreport-list');
define('USERREPORTVIEW','userreport-view');
define('USERREPORTEXPORT','userreport-export');

/* Bot REPORT  Constant */
define('BOTREPORT','botreport');
define('BOTREPORTLIST','botreport-list');

 /* contact Constant */
define('SUPPORTS','support');
define('SUPPORTSLIST','support-list');
define('SUPPORTCHAT','support-chat');
define('SUPPORTREPLY','support-reply');

define('SUPPORTSCHAT','supportchat');

define('MATCHHISTORY','matchhistory');
define('MACTHHISTORYVIEW','matchhistory-view');
define('MACTHHISTORYEXPORT','matchhistory-export');

define('TODAYBONUS','todaybonus');


define('MAIL','mail');
define('MAILLIST','mail-list');
//define('MAILCREATE','mail-create');
define('MAILUPDATE','mail-update');
define('MAILACTION','mail-action');
define('MAILDELETE','mail-delete');

define('COUPONCODE','couponcode');
define('COUPONCODEAJAX','couponcode-list');
define('COUPONCODECREATE','couponcode-create');
define('COUPONCODEUPDATE','couponcode-edit');
define('COUPONCODECREATEACTION','couponcode-createaction');
define('COUPONCODEUPDATEACTION','couponcode-updateaction');
define('COUPONCODEDELETE','couponcode-delete');
define('COUPONCODESTATUS','couponcode-status');

define('SPINROLL','spinroll');
define('SPINROLLAJAX','spinroll-list');
define('SPINROLLCREATE','spinroll-create');
define('SPINROLLUPDATE','spinroll-edit');
define('SPINROLLCREATEACTION','spinroll-createaction');
define('SPINROLLUPDATEACTION','spinroll-updateaction');
define('SPINROLLDELETE','spinroll-delete');
define('SPINROLLSTATUS','spinroll-status');

define('TOURNAMENTS','tournaments');
define('TOURNAMENTSAJAX','tournaments-list');
define('TOURNAMENTSCREATE','tournaments-create');
define('TOURNAMENTSCREATEACTION','tournaments-createaction');
define('TOURNAMENTSSTATUS','tournaments-changestatus');
define('TOURNAMENTSDELETE','tournaments-delete');
define('TOURNAMENTSUPDATE','tournaments-update');
define('TOURNAMENTSUPDATEACTION','tournaments-updateaction');
define('TOURNAMENTSVIEW','tournaments-view');
define('TOURNAMENTUSERLIST','tournaments-user');
define('TOURNAMENTUSERAJAX','tournaments-user-list');
define('TOURNAMENTUSERHISTORY','tournaments-user-history');
define('TOURNAMENTUSERHISTORYLIST','tournaments-user-history-list');

define('ROLEACCESS','roleaccess');
define('ROLEACCESSLIST','roleaccess-list');
define('ROLEACCESSCREATE','roleaccess-create');
define('ROLEACCESSUPDATE','roleaccess-update');
define('ROLEACCESSACTION','roleaccess-action');
define('ROLEACCESSDELETE','roleaccess-delete');
define('ROLEACCESSVIEW','roleaccess-view');
define('ROLEACCESSMENUACTION','roleaccess-menu-action');