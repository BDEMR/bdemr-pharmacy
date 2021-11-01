/********************************************************************
  Main Slider
********************************************************************/

// Get the Sequence element
var sequenceElement = document.getElementById("sequence");

var options = {
  startingStepAnimatesIn: true,
  autoPlay: true,
  autoPlayDelay: 3000,
  phaseThreshold: 250,
  preloader: true,
  reverseWhenNavigatingBackwards: false,
  fadeStepWhenSkipped: false
}

// Launch Sequence on the element, and with the options we specified above
var mySequence = sequence(sequenceElement, options);

function bodyOnload() {
  window.ClientLibrariesIsolatedScope(function(){});
}

/********************************************************************
  Toolbar
**********************************toggleMenu**********************************/
// Hide Header on on scroll down
var didScroll;
var lastScrollTop = 0;
var delta = 5;
var navbarHeight = $('#toolBar').outerHeight();

$(window).scroll(function(event){
    didScroll = true;
    document.getElementById("toggleMenu").classList.remove("show");
});

setInterval(function() {
    if (didScroll) {
        hasScrolled();
        didScroll = false;
    }
}, 250);


function hasScrolled() {
    var st = $(this).scrollTop();
    
    // Make sure they scroll more than delta
    if(Math.abs(lastScrollTop - st) <= delta)
        return;
    
    // If they scrolled down and are past the navbar, add class .nav-up.
    // This is necessary so you never see what is "behind" the navbar.
    if (st > lastScrollTop && st > navbarHeight){
        // Scroll Down
        $('#toolBar').removeClass('toolbar-down').addClass('toolbar-up');
    } else {
        // Scroll Up
        if(st + $(window).height() < $(document).height()) {
            $('#toolBar').removeClass('toolbar-up').addClass('toolbar-down');
        }
    }
    
    lastScrollTop = st;
}

/* Smooth Scrolling */

function currentYPosition() {
  // Firefox, Chrome, Opera, Safari
  if (self.pageYOffset) return self.pageYOffset;
  // Internet Explorer 6 - standards mode
  if (document.documentElement && document.documentElement.scrollTop)
      return document.documentElement.scrollTop;
  // Internet Explorer 6, 7 and 8
  if (document.body.scrollTop) return document.body.scrollTop;
  return 0;
}

function elmYPosition(eID) {
  var elm = document.getElementById(eID);
  var y = elm.offsetTop;
  var node = elm;
  while (node.offsetParent && node.offsetParent != document.body) {
      node = node.offsetParent;
      y += node.offsetTop;
  } return y;
}

function smoothScroll(eID) {
  var startY = currentYPosition();
  var stopY = elmYPosition(eID);
  var distance = stopY > startY ? stopY - startY : startY - stopY;
  if (distance < 100) {
      scrollTo(0, stopY); return;
  }
  var speed = Math.round(distance / 100);
  if (speed >= 20) speed = 20;
  var step = Math.round(distance / 25);
  var leapY = stopY > startY ? startY + step : startY - step;
  var timer = 0;
  if (stopY > startY) {
      for ( var i=startY; i<stopY; i+=step ) {
          setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
          leapY += step; if (leapY > stopY) leapY = stopY; timer++;
      } return;
  }
  for ( var i=startY; i>stopY; i-=step ) {
      setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
      leapY -= step; if (leapY < stopY) leapY = stopY; timer++;
  }
}

/* Toolber Tabs */

(function() {
  var i, makeTabsActive, tabsEelement;

  tabsEelement = document.querySelectorAll('.tabs li');

  makeTabsActive = function() {
    var i;
    i = 0;
    while (i < tabsEelement.length) {
      tabsEelement[i].classList.remove('active');
      i++;
    }
    this.classList.add('active');
  };

  i = 0;

  while (i < tabsEelement.length) {
    tabsEelement[i].addEventListener('mousedown', makeTabsActive);
    i++;
  }

}).call(this);


/********************************************************************
  Materialize Input
********************************************************************/

var paperInputElementList = document.querySelectorAll('.paper-input');
for (var i=0; i < paperInputElementList.length; i++) {
  paperInputElementList[i].addEventListener("keydown", toggleInputLabel, false);
  paperInputElementList[i].addEventListener("keyup", toggleInputLabel, false);
  paperInputElementList[i].addEventListener("focus", toggleInputLabel, false);
  paperInputElementList[i].addEventListener("blur", toggleInputLabel, false);
  paperInputElementList[i].addEventListener("active", toggleInputLabel, false);

}

function toggleInputLabel() {
  if(this.value != '') {
    this.classList.add("paper-input--touched")
  }
  else {
    this.classList.remove("paper-input--touched")
  }
}

/********************************************************************
  Dialogs
********************************************************************/

// Dialog - Doctor
function dialogDoctor() {
  el = document.getElementById("dialogDoctor");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Agent
function dialogAgent() {
  el = document.getElementById("dialogAgent");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Patient
function dialogPatient() {
  el = document.getElementById("dialogPatient");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Student
function dialogMedicalStudent() {
  el = document.getElementById("dialogMedicalStudent");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Clinic Owner
function dialogClinicOwner() {
  el = document.getElementById("dialogClinicOwner");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Clinic Staff
function dialogClinicStaff() {
  el = document.getElementById("dialogClinicStaff");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}

// Dialog - Validate Voucher -> Moved to voucher.coffee

// Dialog - Purchase Voucher -> Moved to voucher.coffee

function openTabContent(evt, tabContentName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tab2content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tab2links");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" activeTab", "");
    }
    document.getElementById(tabContentName).style.display = "block";
    evt.currentTarget.className += " activeTab";
}


/********************************************************************
  Contact Us
********************************************************************/

var CONTACT_OBJECT = {
  name: null,
  email: null,
  subject: null
};

function _onContactUsBtnPressed () {

  CONTACT_OBJECT.name = document.getElementById("inputContactName").value;
  CONTACT_OBJECT.email = document.getElementById("inputContactEmail").value;
  CONTACT_OBJECT.message = document.getElementById("inputContactMessage").value;

  var getMessageSuccess = document.getElementById("contactMessageSuccess");
  var contactNameErrorMsg = document.getElementById("contactNameError");
  var contactEmailErrorMsg = document.getElementById("contactEmailError");
  var inputMessageErrorMsg = document.getElementById("inputMessageError");

  getMessageSuccess.innerHTML = "";


  window.lib.apis.CallContactUsApi( CONTACT_OBJECT , ( function ( response ) {
    
    if( response.hasError ) {

      if(response.error.details.name) {
        contactNameErrorMsg.innerHTML = response.error.details.name[0];
      } else {
        contactNameErrorMsg.innerHTML = "";
      }
      if (response.error.details.email) {
        contactEmailErrorMsg.innerHTML = response.error.details.email[0];
      } else {
        contactEmailErrorMsg.innerHTML = "";
      }
      if (response.error.details.message) {
        inputMessageErrorMsg.innerHTML = response.error.details.message[0];
      } else {
        inputMessageErrorMsg.innerHTML = "";
      }
      
    }
    else {
      contactEmailErrorMsg.innerHTML = ""
      contactNameErrorMsg.innerHTML = "";
      inputMessageErrorMsg.innerHTML = "";

      document.getElementById("contactForm").reset();
      document.getElementById("contactForm").style.display = 'none';
      document.getElementById("btnToggleContactUsForm").style.display = 'block';
      getMessageSuccess.innerHTML = "Thanks for contacting us!";
    }
  } ).bind( this ) ) ;
}

function _onToggleContactUsForm () {
  document.getElementById("contactMessageSuccess").innerHTML = "";
  document.getElementById("btnToggleContactUsForm").style.display = 'none';
  document.getElementById("contactForm").style.display = 'block';
}


/********************************************************************
  Subscribe Us
********************************************************************/

var SUBSCRIBE_OBJECT = {
  email: null
};

var subscribeInputElem = document.getElementById("inputSubscribedEmailId");
subscribeInputElem.onkeyup = function(e){
    if(e.keyCode == 13){
       _onSubscribeUsBtnPressed();
    }
}

function _onSubscribeUsBtnPressed() {
 

  SUBSCRIBE_OBJECT.email = document.getElementById("inputSubscribedEmailId").value;
  var getMessageSuccess = document.getElementById("subscribeInfoMessage");
  var getMessageError = document.getElementById("subscribeErrorMessage");
  getMessageSuccess.innerHTML = "";
  getMessageError.innerHTML = "";

  window.lib.apis.CallEmailSubscriptionApi( SUBSCRIBE_OBJECT , ( function ( response ) {
    if( response.hasError ) {
      getMessageSuccess.innerHTML = "";
      if (response.error.details.email) {
        getMessageError.innerHTML = response.error.details.email[0];
      } else {
        getMessageError.innerHTML = "";
      }

    }
    else {
      getMessageError.innerHTML = "";
      getMessageSuccess.innerHTML = "Thanks for subscribed!";
    }
  } ).bind( this ) ) ;
}


/********************************************************************
  Footer
********************************************************************/

// Scroll to top
var timeOut;
function scrollToTop() {
  if (document.body.scrollTop!=0 || document.documentElement.scrollTop!=0){
    window.scrollBy(0,-50);
    timeOut=setTimeout('scrollToTop()',10);
  }
  else clearTimeout(timeOut);
}

// Dialog - WCA2016
// function dialogWCA2016() {
//   el = document.getElementById("dialogWCA2016");
//   el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
// }

// setTimeout(function(){
//   el = document.getElementById("dialogWCA2016");
//   el.style.visibility = "visible";
// }, 500);

// setTimeout(function(){
//   el = document.getElementById("dialogWCA2016");
//   el.style.visibility = "hidden";
// }, 20000);

function topBarAd1() {
  // el = document.getElementById("topBarAd1");
  // el.style.display = (el.style.display == "block") ? "none" : "block";
  $("#topBarAd1").slideUp();
}

setTimeout(function(){
  // el = document.getElementById("topBarAd1");
  // el.style.display = "block";
  $("#topBarAd1").slideDown();
}, 3000);
