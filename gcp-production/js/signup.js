// Initialze All Client Libraries code before API has been called
function bodyOnload() {

  window.ClientLibrariesIsolatedScope(function(res){
    _getCountryList();
  });

  
}


// Initialize Signup Object
var SIGNUP_OBJECT = {
  name: {
    honorifics : null,
    first : "",
    middle : null,
    last : null,
  },
  emailOrPhone : "",
  password : "",
  dateOfBirth : "",
  effectiveRegion: "",
  couponCode: null
};


var paperInputElementList = $('.paper-input');

paperInputElementList.on('keyup keydown keyup focus blur active', function() {
    if($(this).val() != '') {
      $(this).addClass('paper-input--touched');
    }
    else{
      $(this).removeClass('paper-input--touched');
    }
});


$( function() {

  // Date Picker
  $( "#inputDateOfBirth" ).datepicker( {
    changeMonth: true,
    changeYear: true,
    yearRange: "-100:+0",
    maxDate: "+0D"
  } );

  // EmailOrPhone Validator
  $.validator.addMethod("eitherEmailOrPhone", function(value, element) {

      isPhone = (this.optional(element) || /^[0-9]{11,11}(-[0-9]*){0,1}$/.test(value)) && this.getLength($.trim(value), element) <= 14 && this.getLength($.trim(value), element) >= 11 ;

      isEmail = this.optional(element) || /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value);

      return isPhone || isEmail;

  }, "Please enter either phone or e-mail");

  $.validator.addMethod("passwordValidation", function(value, element) {

    if(!/\d/.test(value))
        return false;
    else if(!/[a-z]/.test(value))
        return false;
    else if(!/[A-Z]/.test(value))
        return false;
    else if(/[^0-9a-zA-Z]/.test(value))
        return false;
    else
      return true;

    // isPassword = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,15}$/i.text(value);

    // console.log(isPassword);
    // return isPassword;

  }, "Password MUST contain atleast 1 Uppercase, 1 Digit!");

  // FullName Validator
  $.validator.addMethod("fullNameValidation", function(fullName, element) {
    var first, honorifics, last, middle, namePart, partArray;

    fullName = fullName.trim();

    partArray = fullName.split('.');

    namePart = partArray.pop();

    honorifics = (partArray.length === 0 ? '' : partArray.join('.')).trim();

    partArray = (namePart.trim()).split(' ');

    if (partArray.length <= 1) {
      first = partArray[0];
    } else {
      first = partArray.shift();
      last = partArray.pop();
      middle = partArray.join(' ');
      if(middle == '') {
        middle = null;
      }
      if(last == '')
        last = null;
    }

    if ( honorifics == '')
      honorifics = null;

    if( first == '')
      return false;


      
    else {
      return true;
    }

  }, "Atleast First Name required!");


  // Form Validation
  $( "#signupForm" ).validate( {
    errorClass: "error",
    rules: {
      inputFullName: {
        required: true,
        fullNameValidation: true
      },
      inputEmailOrPhone: {
        required: true,
        eitherEmailOrPhone: true
      },
      inputPassword: {
        required: true,
        minlength: 6,
        // passwordValidation: true
      },
      inputRepeatPassword: {
        required: true,
        minlength: 6,
        equalTo: "#inputPassword"

      },
      inputDateOfBirth: {
        required: true,
        date: true
      },
      inputEffectiveRegion: "required",
      inputCouponCode: {
        required: false,
        minlength: 6
      },
      inputCondition: "required"
    },
    messages: {
      inputFullName: {
        required: "Please enter your Full Name with Honorifics",
        // fullNameValidation: "Atleast FirstName required along with Honorifics like (Dr., Mr. Mrs. Miss, etc.)"
        fullNameValidation: "Atleast First Name required!)"
      },
      inputEmailOrPhone: {
        required: "Please enter your Email/Phone Number",
        eitherEmailOrPhone: "A valid Email/Phone is Required!"
      },
      inputDateOfBirth: {
        required: "Please enter your Birth Date",
        date: "A valid Date is Required!"
      },
      inputEffectiveRegion: "Please Select Your Country",
      inputPassword: {
        reuired: "Please provide a password",
        minlength: "Your password must be at least 6 characters long"
        // passwordValidation: "Password MUST contain atleast 1 Uppercase, 1 Digit!"
      },
      inputRepeatPassword: {
        reuired: "Please provide a password",
        minlength: "Your password must be at least 6 characters long",
        equalTo: "Please enter the same password as above"
      },
      inputCouponCode: {
        minlength: "Coupon Code MUST have 6 digit!",
      },
      inputCondition: "Please accept our policy"

    },
    errorPlacement: function( error, element ) {
      error.appendTo( element.parent().find( ".paper-input__error" ) );
    },
    submitHandler: function() {

      _callDirectSignupApi();
    }
  });
});


// Signup Success Dialog
function dialogSignupSuccess (getFullName) {

  document.getElementById('signupForm').reset();
  document.getElementById("viewFullName").innerHTML = getFullName;
  el = document.getElementById("dialogSignupSuccess");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";

}

// Success Dialog Close BUtton
function _ondialogSignupClosebtnPressed() {
  el = document.getElementById("dialogSignupSuccess");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
  location.reload();

}

// Trimming Full Name
function trimFullName(fullName) {
  var first, honorifics, last, middle, namePart, partArray;

  fullName = fullName.trim();

  partArray = fullName.split('.');

  namePart = partArray.pop();

  honorifics = (partArray.length === 0 ? '' : partArray.join('.')).trim();

  partArray = (namePart.trim()).split(' ');

  if(honorifics == '')
    honorifics = null;

  if (partArray.length <= 1) {
    first = partArray[0];
    // last = '';
  } else {
    first = partArray.shift();
    last = partArray.pop();
    middle = partArray.join(' ');
    
    if(middle == '')
      middle = null;
    if(last == '')
      last = null;
  
  }

  SIGNUP_OBJECT.name.honorifics = honorifics;
  SIGNUP_OBJECT.name.first = first;
  SIGNUP_OBJECT.name.middle = middle;
  SIGNUP_OBJECT.name.last = last;
}


// Call Direct Signup API
function _callDirectSignupApi () {

  var fullName = document.getElementById("inputFullName").value;
  trimFullName(fullName);

  SIGNUP_OBJECT.emailOrPhone = document.getElementById("inputEmailOrPhone").value;
  SIGNUP_OBJECT.password = document.getElementById("inputPassword").value;
  SIGNUP_OBJECT.dateOfBirth = document.getElementById("inputDateOfBirth").value;
  SIGNUP_OBJECT.effectiveRegion = $('#inputEffectiveRegion').val();
  SIGNUP_OBJECT.couponCode = document.getElementById("inputCouponCode").value;

  if(SIGNUP_OBJECT.couponCode == '') {
    SIGNUP_OBJECT.couponCode = null;
  }

  window.lib.apis.CallDirectSignupApi( SIGNUP_OBJECT , ( function ( response ) {
    console.log(response);
    if( response.hasError ) {
      $('#emailExistError').text(response.error.message);
      $('#emailExistError').addClass("show-error");
    }
    else {
      $('#emailExistError').text("");
      $('#emailExistError').removeClass("show-error");
      dialogSignupSuccess(fullName);
      SIGNUP_OBJECT = {};
    }
  }).bind( this ) ) ;

}

function _getCountryList() {
 
  window.lib.apis.GetCountryList( ( function ( response ) {

    var i, len;
    var data = [];
    var elm = document.getElementById("inputEffectiveRegion");
    
    len = response.data.length;
    for (i=0; i<len; i++) {
      data.push(response.data[i].name)
    }

    data.sort();
    // console.log(data);

    for (i=0; i<data.length; i++) {
      var elmOption = document.createElement("option");
      elmOption.text = data[i];
      elmOption.value = data[i];

      if (data[i] == 'Bangladesh') {
        elmOption.selected = true;
      }
      elm.add(elmOption);
    }


  } ).bind( this ) ) ;

}


// Dialog - Terms of Use
function dialogTermsOfUse() {
  el = document.getElementById("dialogTermsOfUse");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Privacy and Policy
function dialogPrivacyPolicy() {
  el = document.getElementById("dialogPrivacyPolicy");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

