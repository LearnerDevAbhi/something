<?php
defined('BASEPATH') OR exit('No direct script access allowed');

$route['default_controller'] = LOGIN;
$route['404_override'] = '';
$route['translate_uri_dashes'] = FALSE;
$route[LOGIN] = 'Login';
$route[PROFILE] = 'Login/profile';
$route[LOGOUT] = 'Login/logout';
$route[DASHBOARD] = 'Dashboard';
$route[CHNGPASSWORD] = '/Login/changePassword';
$route[LOGINACTION] = '/Login/loginAction';



/* User Routing */
$route[USERS] = 'Users';
$route[USERS.'/(:any)']       = 'Users/index/$1';
$route[USERVIEW.'/(:any)'] = 'Users/view/$1';
$route[USEREXPORT] = 'Users/exportAction';
$route[USERCHANGESTATUS.'/(:num)'] = 'Users/change_status/$1';
$route[USERCHANGEPASSWORD.'/(:num)'] = 'Users/change_password/$1';
$route[DELUSER] = 'Users/delete';
$route[USERGAMEPLAYEDEXPORT.'/(:any)'] = 'Users/gamePlayedExportAction/$1';
$route[USERCOMPWITHDRAWEXPORT.'/(:any)'] = 'Users/compWithdrawExportAction/$1';
$route[USERCOMPDEPOSITEXPORT.'/(:any)'] = 'Users/compDepositExportAction/$1';
$route[USERREFERALBONUSEXPORT.'/(:any)'] = 'Users/referalBonusExportAction/$1';
$route[USEGAMEPLAYBONUSEXPORT.'/(:any)'] = 'Users/gamePlayBonusExportAction/$1';
$route[USERKYCVIEW.'/(:any)'] = 'Users/kycView/$1';




$route[SETTINGS] = 'Settings';
$route[SETTINGSCMSUPDATEACTION.'/(:any)'] = 'Settings/update_action/$1';
$route[DAYWISETIMINGS] = 'Settings/dayWiseTimings';
$route[DAYWISETIMINGSUPDATE] = 'Settings/update_daytimings';

/* Bonus Routing */
$route[BONUS]             = 'Bonus';
$route[BONUSAJAX]         = 'Bonus/ajax_manage_page';
$route[BONUSCREATE]       = 'Bonus/create';
$route[BONUUPDATEE.'/(:any)']       = 'Bonus/update/$1';
$route[BONUSCREATEACTION] = 'Bonus/createAction';
$route[BONUSUPDATEACTION] = 'Bonus/updateAction';
$route[BONUSIMPORT] 	  = 'Bonus/import';

/* Referral  Routing */
$route[REFERRAL] = 'Referral';
$route[REFERRALVIEW.'/(:any)'] = 'Referral/view/$1';

/* Payment Transaction  Routing */
$route[PAYMENTTRANSACTION] = 'PaymentTransaction';
$route[PAYMENTTRANSACTIONEXPORT] = 'PaymentTransaction/exportAction';

/* Gamerecords  Routing */
$route[GAMERECORD] = 'Gamerecords';


/* Withdrawal Request  Routing */
$route[WITHDRAWAL] = 'Withdrawal';
$route[WITHDRAWAL.'/(:any)'] = 'Withdrawal/index/$1';
$route[WITHDRAWALDISTRIBUTE.'/(:any)'] = 'Withdrawal/redeemDistribute/$1';
/* Withdrawal  Completed Request  Routing */
$route[WITHDRAWALCOMPREQ] = 'CompletedRequest';
$route[WITHDRAWALCOMPREQLIST] = 'CompletedRequest/ajax_manage_page';
$route[WITHDRAWALEXPORT] = 'Withdrawal/exportAction';
$route[WITHDRAWALCOMPREQEXPORT] = 'CompletedRequest/exportAction';
$route[WITHDRAWALCOMPREQVIEW.'/(:any)'] = 'CompletedRequest/viewRequest/$1';


/* Withdrawal  Completed Request  Routing */
$route[WITHDRAWALREJECTREQ] = 'RejectedRequest';
$route[WITHDRAWALREJECTREQLIST] = 'RejectedRequest/ajax_manage_page';
$route[WITHDRAWALREJECTREQEXPORT] = 'RejectedRequest/exportAction';
$route[WITHDRAWALREJECTVIEW.'/(:any)'] = 'RejectedRequest/viewRequest/$1';

/* Withdrawal  Completed Request  Routing */
$route[WITHDRAWALBANKEXPORT] = 'BankExpWithdrawRequest';
$route[WITHDRAWALBANKEXPORTLIST] = 'BankExpWithdrawRequest/ajax_manage_page';
$route[BANKWITHDRAWALEXPORT] = 'BankExpWithdrawRequest/exportAction';




/* Maintainance  Routing */
$route[MAINTAINANCE] = 'Maintainance';

/* Room  Routing */
$route[GAMEPLAY] = 'GamePlay';
$route[GAMEPLAYCREATE] = 'GamePlay/create';
$route[GAMEPLAYSTATUS] = 'GamePlay/status';
$route[GAMEPLAYUPDATE.'/(:any)'] = 'GamePlay/update/$1';
$route[GAMEPLAYACTION] = 'GamePlay/action';
$route[GAMEPLAYAJAX] = 'GamePlay/ajax_manage_page';
$route[GAMEPLAYIMPORT] = 'GamePlay/import';
$route[GAMEPLAYDELETE] = 'GamePlay/delete';



/* KYC Routing */
$route[KYC] = 'Kyc/index';
$route[KYC.'/(:any)'] = 'Kyc/index/$1';
$route[KYCAJAXLIST] = 'Kyc/ajax_manage_page';
$route[VERIFYKYC] = 'Kyc/verifyKyc';
$route[KYCIMG] = 'Kyc/getImage';
$route[KYCBANKDETAIL] = 'Kyc/getBankDetail';
$route[KYCEXPORT] = 'Kyc/exportAction';
$route[DELKYC] = 'Kyc/delete';
$route[KYCVIEW.'/(:any)'] = 'Kyc/view/$1';

/* verify KYC Routing */
$route[VERIFIEDKYC] = 'VerifiedKyc';
$route[VERIFIEDKYCLIST] = 'VerifiedKyc/ajax_manage_page';
$route[VERIFIEDKYCVIEW.'/(:any)'] = 'VerifiedKyc/view/$1';


/* Deposit Routing */
$route[DEPOSIT] = 'Deposit';
$route[AJAXDEPOSITLIST] = 'Deposit/ajax_manage_page';
$route[DEPOSITEXPORT] = 'Deposit/exportAction';


$route[TODAYSDEPOSIT] = 'TodaysDeposit';
$route[TODAYSDEPOSITLIST] = 'TodaysDeposit/ajax_manage_page';


/* bot Routing */
$route[BOTPLAYER] = 'BotPlayer';
$route[BOTPLAYERAJAX] = 'BotPlayer/ajax_manage_page';
$route[BOTPLAYERCREATE] = 'BotPlayer/create';
$route[BOTPLAYERCREATEACTION] = 'BotPlayer/createAction';
$route[BOTPLAYERUPDATE.'/(:any)'] = 'BotPlayer/update/$1';
$route[BOTPLAYERUPDATEACTION] = 'BotPlayer/updateAction';
$route[BOTPLAYERDELETE] = 'BotPlayer/deleteAction';

/* contact us Routing */
$route[CONTACTUS] = 'ContactUs';
$route[CONTACTAJAXLIST] = 'ContactUs/ajax_manage_page';
$route[CONTACTDELETE] = 'ContactUs/delete';
$route[SENDREPLY] = 'ContactUs/sendReplyMail';
$route[GETSENDREPLY] = 'ContactUs/getReply';

/* userReport us Routing */
$route[USERREPORT] = 'UserReport/index';
$route[USERREPORT.'/(:any)'] = 'UserReport/index/$1';
//$route[USERREPORTLIST.] = 'UserReport/ajax_manage_page/$1';
$route[USERREPORTVIEW.'/(:any)'] = 'UserReport/view/$1';
$route[USERREPORTEXPORT] = 'UserReport/exportAction';

/* Bot Report us Routing */
$route[BOTREPORT] = 'BotReport/index';
$route[BOTREPORT.'/(:any)'] = 'BotReport/index/$1';


$route[SUPPORTS] = 'Supports';
$route[SUPPORTSLIST] = 'Supports/getuserlist';
$route[SUPPORTCHAT] = 'Supports/getChat';
$route[SUPPORTREPLY] = 'Supports/replychat';

$route[SUPPORTSCHAT] = 'SupportChats';

$route[MATCHHISTORY] = 'MatchHistory';
$route[MACTHHISTORYVIEW.'/(:any)'] = 'MatchHistory/view/$1';
$route[MACTHHISTORYEXPORT] = 'MatchHistory/exportAction';

$route[TODAYBONUS] = 'TodayBonus';


$route[MAIL]  = 'Mail';
$route[MAILLIST]  = 'Mail/ajax_manage_page';
//$route[MAILCREATE]  = 'Mail/create';
$route[MAILUPDATE.'/(:any)']  = 'Mail/update/$1';
$route[MAILACTION]  = 'Mail/updateAction';
$route[MAILDELETE]  = 'Mail/delete';

$route[COUPONCODE]                 = 'CouponCodes';
$route[COUPONCODEAJAX]             = 'CouponCodes/ajax_manage_page';
$route[COUPONCODECREATE]           = 'CouponCodes/create';
$route[COUPONCODEUPDATE.'/(:any)'] = 'CouponCodes/update/$1';
$route[COUPONCODECREATEACTION]     = 'CouponCodes/createAction';
$route[COUPONCODEUPDATEACTION.'/(:any)']           = 'CouponCodes/updateAction/$1';
$route[COUPONCODEDELETE] = 'CouponCodes/delete';
$route[COUPONCODESTATUS] = 'CouponCodes/statusChange';

$route[SPINROLL]                       = 'SpinRolls';
$route[SPINROLLAJAX]                   = 'SpinRolls/ajax_manage_page';
$route[SPINROLLCREATE]                 = 'SpinRolls/create';
$route[SPINROLLUPDATE.'/(:any)']       = 'SpinRolls/update/$1';
$route[SPINROLLCREATEACTION]           = 'SpinRolls/createAction';
$route[SPINROLLUPDATEACTION.'/(:any)']           = 'SpinRolls/updateAction/$1';
$route[SPINROLLDELETE] = 'SpinRolls/delete';
$route[SPINROLLSTATUS] = 'SpinRolls/statusChange';

$route[TOURNAMENTS] = 'Tournaments';
$route[TOURNAMENTSAJAX] = 'Tournaments/ajax_manage_page';
$route[TOURNAMENTSCREATE] = 'Tournaments/create';
$route[TOURNAMENTSCREATEACTION] = 'Tournaments/createAction';
$route[TOURNAMENTSSTATUS] = 'Tournaments/statusChange';;
$route[TOURNAMENTSDELETE] = 'Tournaments/deleteAction';
$route[TOURNAMENTSUPDATE.'/(:any)'] = 'Tournaments/update/$1';
$route[TOURNAMENTSUPDATEACTION] = 'Tournaments/updateAction';
$route[TOURNAMENTSVIEW.'/(:any)'] = 'Tournaments/view/$1';
$route[TOURNAMENTUSERLIST.'/(:any)'] = 'Tournaments/getUserList/$1';
$route[TOURNAMENTUSERAJAX] = 'Tournaments/user_ajax_manage_page';
$route[TOURNAMENTUSERHISTORY.'/(:any)'.'/(:any)'] = 'Tournaments/getUserHistory/$1/$2';
$route[TOURNAMENTUSERHISTORYLIST] = 'Tournaments/user_history_ajax_manage_page';

$route[ROLEACCESS]  = 'RoleAccess';
$route[ROLEACCESSLIST]  = 'RoleAccess/ajax_manage_page';
$route[ROLEACCESSCREATE]  = 'RoleAccess/create';
$route[ROLEACCESSUPDATE.'/(:any)']  = 'RoleAccess/update/$1';
$route[ROLEACCESSACTION]  = 'RoleAccess/action';
$route[ROLEACCESSDELETE]  = 'RoleAccess/delete';
$route[ROLEACCESSVIEW.'/(:any)']  = 'RoleAccess/roleAccess/$1';
$route[ROLEACCESSMENUACTION]  = 'RoleAccess/roleAccessAction';