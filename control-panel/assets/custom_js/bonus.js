function only_number(event)
{
  var x = event.which || event.keyCode;
  if((x >= 48 ) && (x <= 57 ) || x == 8 | x == 9 || x == 13)
  {
    return;
  }else{
    event.preventDefault();
  }    
}

function validBonus() {
	var referalBonus      = $('#referalBonus').val().trim();
	var signupBonus = $('#signupBonus').val().trim();
	var cashBonus = $('#cashBonus').val().trim();

	if(referalBonus == '') {
		$("#err_referalBonus").html('Please enter referal banus');
		setTimeout(function(){ $("#err_referalBonus").html(''); },3000);
		$('#referalBonus').focus();
		return false;
	}
	// else if (referalBonus == 0) {
	// 	$("#err_referalBonus").html('Enter referal banus can not set to zero');
	// 	setTimeout(function(){ $("#err_referalBonus").html(''); },3000);
	// 	$('#referalBonus').focus();
	// 	return false;
	// }
	
	if(signupBonus == '') {
		$("#err_signupBonus").html('Please enter signup bonus');
		setTimeout(function(){ $("#err_signupBonus").html(''); },3000);
		$('#signupBonus').focus();
		return false;
	}
	// else if(signupBonus == 0) {
	// 	$("#err_signupBonus").html('Apply signup bonus can not set to zero');
	// 	setTimeout(function(){ $("#err_signupBonus").html(''); },3000);
	// 	$('#signupBonus').focus();
	// 	return false;
	// }

	if(cashBonus == '') {
		$("#err_cashBonus").html('Please enter cash bonus');
		setTimeout(function(){ $("#err_cashBonus").html(''); },3000);
		$('#cashBonus').focus();
		return false;
	}
	// else if(cashBonus == 0) {
	// 	$("#err_cashBonus").html('Apply cash bonus can not set to zero');
	// 	setTimeout(function(){ $("#err_cashBonus").html(''); },3000);
	// 	$('#cashBonus').focus();
	// 	return false;
	// }
}

