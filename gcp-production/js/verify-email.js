
// EMAIL VERIFICATION START

(function(){

	function getQueryVariable(variable) {
		var query = window.location.search.substring(1);
		var vars = query.split("&");
		for (var i=0;i<vars.length;i++) {
			var pair = vars[i].split("=");
			if (pair[0] == variable) {
				return pair[1];
			}
		}
		return null
	}

	window.setTimeout(function () {
		try {
			token = getQueryVariable('verify-email');
			if(token){
				obj = {
					typedEmailVerificationToken: token
				}
				window.lib.apis.UserVerifyEmailWithToken( obj , ( function ( response ) {
				if( response.hasError ) {
					// console.log(response)
					dialogEmailVerifySuccess('Could Not Verify Email with token' + token)
				}
				else {
				  dialogEmailVerifySuccess("Your Email has been verified!");
				}
				}).bind( this ) ) ;
			}
		} catch (ex) {

		}

	}, 2000)

})();


// Dialog - Email Verification success
function dialogEmailVerifySuccess(msg) {
  el = document.getElementById("dialogEmailVerifySuccess");
  document.getElementById("emailVerifyingMsg").innerHTML = msg;
  el.style.visibility = "visible";
}

function _onDialogEmailVerifySuccessCloseBtnPressed(msg) {
  el = document.getElementById("dialogEmailVerifySuccess");
  el.style.visibility = "hidden";
}

// EMAIL VERIFICATION END