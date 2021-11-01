// Initialze All Client Libraries code before API has been called
window.ClientLibrariesIsolatedScope(function(res) {
  _callGetListOfDoctorApi(function() {
    applyListViewWrapperPlugin();
  });

});


// Get List of Doctor API
function _callGetListOfDoctorApi (cbfn) {

  window.lib.apis.CallGetListOfDoctorApi(( function ( response ) {
    // console.log(response);
    var data = [];
    if( response.hasError == false ) {
      data = response.data;
      // console.log(data);
      for (var i = 0; i < data.length; i++) {
        viewListItem(data[i], data[i].userId);
      }
      cbfn();
    }
  }).bind( this ) ) ;

}

// Get List of Doctor API
function _callGetDoctorPublicDetailsApi (doctorIdendifier, cbfn) {
  // console.log(doctorIdendifier);
  window.lib.apis.CallGetDoctorPublicDetailsApi(doctorIdendifier, ( function ( response ) {
    var data = [];
    if( response.hasError == false ) {
      data = response.data;
      console.log(data);
      addDoctorDetailsHTMLContent(data);
      // console.log(data);
      cbfn();
    }
  }).bind( this ) ) ;

}

function getFullName(name) {
  var honorifics, middle, last;

  if(name.honorifics == null) {
    honorifics = "";
  } else {
    honorifics = name.honorifics + " ";
  }
  
  if(name.middle == null) {
    middle = "";
  } else {
    middle = " " + name.middle;
  }

  if(name.last == null) {
    last = "";
  } else {
    last = " " + name.last;
  }

  return honorifics + name.first + middle + last;
}

function getSpecializationList(data) {

  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += data[i].specializationTitle + ", ";
    }

    console.log(itemContent);

    return itemContent;
  }

  else return '';

  
  
}

function getDegreeList(data) {

  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += data[i].degreeTitle + ", ";
    }
    return itemContent;
  }
  else return '';
  
}

function _nullChecker(data) {
  if(data == null || data == 'undefined' || data == '') {
    return '';
  } 
  else return data;
}

function getAddressList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="row"><div class="one-half column"><div class="type body-lead">'+_nullChecker(data[i].addressTitle)+'</div><div class="type body"><strong>Address:</strong>' + _nullChecker(data[i].addressLine1) + _nullChecker(data[i].addressLine2) + '</div><div class="type body"><strong>Flat/Floor/Plot:</strong>' + _nullChecker(data[i].flatOrFloorOrPlot) +'</div><div class="type body"><strong>Block/Road Number: </strong>'+ _nullChecker(data[i].blockAndRoadNumber)+'</div><div class="type body"><strong>Subdistrict Name: </strong>'+ _nullChecker(data[i].subdistrictName) +'</div></div><div class="one-half column"><div class="type body"><strong>Union:</strong>'+ _nullChecker(data[i].addressUnion) +'</div><div class="type body"><strong>City/Town:</strong>'+_nullChecker(data[i].addressCityOrTown)+'</div><div class="type body"><strong>State/Province:</strong>'+_nullChecker(data[i].stateOrProvince)+'</div><div class="type body"><strong>District:</strong>'+_nullChecker(data[i].addressDistrict)+'</div><div class="type body"><strong>Country:</strong>'+_nullChecker(data[i].addressCountry)+'</div></div></div>';
    }
    return itemContent;
  }

  else return '- no data available -';

}

function _convertMsToUserReadbleTime(ms) {
  var minutes, hours, modifier, time;

  minutes = (ms/(1000*60))%60
  hours = parseInt(Math.floor((ms/(1000*60*60))%24));

  if(hours > 12) {
    hours = hours - 12;
    modifier = 'PM';
  } else if (hours == 12) {
    hours = hours;
    modifier = 'PM';
  } else if (hours == 0) {
    hours = hours + 12;
    modifier = 'AM';
  } else {
    modifier = 'AM';
  }

  time = hours + ":" + minutes + " " + modifier;

  return time;

}

function getVisitingTimeList(data) {
  var i;
  var itemContent = '';
  if(data.length > 0) {
    for(i=0;i<data.length;i++) {
      itemContent += "[" + data[i].day + ": " + _convertMsToUserReadbleTime(data[i].fromTime) + "-" + _convertMsToUserReadbleTime(data[i].toTime) + "], ";
    }
    return itemContent;
  }
  else return '- no data available -';
}
function getEmploymentList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="type body-lead">'+ _nullChecker(data[i].currentPosition) +'</div><div class="type body"><strong>Institution Name: </strong>'+ _nullChecker(data[i].institutionName) +'</div><div class="type body"><strong>Institution Website: </strong>'+ _nullChecker(data[i].institutionWebsiteLink) +'</div><div class="type body"><strong>Institution Address: </strong>'+ _nullChecker(data[i].institutionAddress) +'</div><div class="type body"><strong>Visiting Time: </strong>'+ getVisitingTimeList(data[i].visitingTime) +'</div>';
    }
    return itemContent;
  }

  else return '- no data available -';

}

function getPublicationList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="type body-lead">'+ _nullChecker(data[i].publicationTitle)+'</div><div class="type body">'+ _nullChecker(data[i].publicationUrl)+'</div>';
    }
    return itemContent;
  }

  else return '- no data available -';

}

function getSocialConnectionList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="type body-lead">'+ _nullChecker(data[i].socialConnectionTitle)+'</div><div class="type body">'+ _nullChecker(data[i].socialConnectionUrl)+'</div>';
    }
    return itemContent;
  }

  else return '- no data available -';
}

function getWebsiteList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="type body-lead">'+ _nullChecker(data[i].websiteTitle)+'</div><div class="type body">'+ _nullChecker(data[i].websiteUrl)+'</div>';
    }
    return itemContent;
  }

  else return '- no data available -';
}

function getAwardList(data) {
  var i;
  var itemContent = '';

  if(data.length > 0) {

    for(i=0;i<data.length;i++) {
      itemContent += '<div class="type body-lead">'+ _nullChecker(data[i].awardTitle)+'</div><div class="type body">'+ _nullChecker(data[i].awardWebUrl) +'</div><div class="type caption">'+ _nullChecker(data[i].awardYear)+'</div><div class="type body">'+ _nullChecker(data[i].awardDetails) +'</div>';
    }
    return itemContent;
  }

  else return '- no data available -';

  
}

function getPreferedLanguage (data) {
  if (data == '' || data == null || data == 'undefined') {
    return '-';
  } else {
    return data;
  }
}

function getBiography (data) {
  if (data == '' || data == null || data == 'undefined') {
    return '- no data available -';
  } else {
    return data;
  }
}


function viewListItem(itemData, userId) {
  var fullName, email, phone, profileImage, imageId, district;
  userId = "'" + userId + "'";

  // Get Full Name
  fullName = getFullName(itemData.name);

  // Get Only (1) Email Address from Email Address List Array if Array Length > 0
  // if(itemData.emailAddressList.length > 0) {
  //   email = itemData.emailAddressList[0].emailAddress;
  // } else {
  //   email = "-";
  // }

  // Get Only (1) Phone Number from Phone Number List Array if Array Length > 0
  // if(itemData.phoneNumberList.length > 0) {
  //   phone = itemData.phoneNumberList[0].phoneNumber;
  // } else {
  //   phone = "-";
  // }

  // Get Profile Image By Calling Another API called CallGetImageDataApi.
  if(itemData.profileImage == null) {
    profileImage = "images/staff/default.png";
  } else {
    imageId = itemData.profileImage;
    _callGetImageDataApi(itemData.profileImage); // Async
  }

  // Get Only (1) Specialization from  Array if Array Length > 0
  if(itemData.specializationList.length > 0) {
    specialization = itemData.specializationList[0].specializationTitle;
  } else {
    specialization = "-";
  }


  // Get District Name
  // if(itemData.agentAppliedDistrictName == null) {
  //   district = "-"
  // } else {
  //   district = itemData.agentAppliedDistrictName;
  // }
  

  // $("#doctorList").append($('<div class="list-item-2"><div class="item-inline-thumbnail"><img id="'+ imageId +'" src="' + profileImage + '" alt=""><div><div class="doctorName type body-lead">'+ fullName +'</div><div class="doctorSpecialization">'+ specialization +'</div></div></div><div class="item-inline-details"><div class="doctorInstitutionName">' + institutionName + '</div><div class="doctorDistrict">' + district + '</div></div></div>'));

  $("#doctorList").append($('<div class="list-item-2 clickable" onclick="_onViewSelectedDoctorDetails(' + userId + ')"><div class="item-inline-thumbnail"><img id="'+ imageId +'" src="' + profileImage + '" alt=""><div><div class="doctorName type body-lead">'+ fullName +'</div><div class="doctorSpecialization">'+ specialization +'</div></div></div></div>'));

}

// Get Image Data API
function _callGetImageDataApi(data) {
  window.lib.apis.CallGetImageDataApi({imageId : data, height: 64, width: 64},( function ( response ) {
    // console.log(response);
    if( response.hasError == false ) {
      data = response.data;
      document.getElementById(data.imageId).src = data.imageData;
    }
    else {
    }
  }).bind( this ) ) ;
}

// Get Image Data API
function _callGetImageDataApiForDoctorDetails(data) {
  console.log(data);
  window.lib.apis.CallGetImageDataApi({imageId : data, height: 150, width: 150},( function ( response ) {
    // console.log(response);
    if( response.hasError == false ) {
      data = response.data;
      document.getElementById('doctorImageId').src = data.imageData;
    }
    else {
    }
  }).bind( this ) ) ;
}

// Add Agent List Pagination and Filter
function applyListViewWrapperPlugin(){
  var agentListView = new List('listViewWrapper', {
    valueNames: ['doctorName', 'doctorSpecialization'],
    page: 10,
    plugins: [ ListPagination({}) ] 
  });
}

function addDoctorDetailsHTMLContent(data) {

  var profileImage;

  // Get Profile Image By Calling Another API called CallGetImageDataApi.
  if(data.profileImage == null) {
    profileImage = "images/staff/default.png";
  } else {
    // doctorImageId = data.profileImage;
    _callGetImageDataApiForDoctorDetails(data.profileImage); // Async
  }

  var htmlContent = '<div id="dialogDoctorDetails" class="overlay"><div class="modal-container"><img src="images/ico_cross.png" alt="" onclick="dialogDoctorDetails()" class="modal-close"><div class="modal-header"><img src="images/bdemr_logo_small.png" alt=""><div class="type headline m-left-8">Doctor Details</div></div><div class="type body modal-content p-0"><div class="p-vertical-16"><div class="p-horizontal-16"><img id="doctorImageId" src="'+ profileImage +'" alt="" class="doctorProfileImage"><div class="type title-2">'+ getFullName(data.name) +'</div><div class="type body">'+ getSpecializationList(data.specializationList) +'</div><div class="type body">'+ getDegreeList(data.degreeList) +'</div><div class="type body"><strong>BMDC # </strong>'+ data.bmdcRegNumber + '(' + data.bmdcRegType +')</div><div class="type body"><strong>Nationality:  </strong>'+ data.effectiveRegion +'</div><div class="type body"><strong>Language: </strong>'+ getPreferedLanguage(data.preferedLanguage) +'</div></div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Biography</div><div class="type body">'+ getBiography(data.biography) +'</div></div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Address</div>'+ getAddressList(data.addressList) +'</div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Employment/Attachment</div><div>'+ getEmploymentList(data.employmentDetailsList) + '</div></div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Social</div>'+ getSocialConnectionList(data.socialConnectionList)+'</div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Website</div>' + getWebsiteList(data.websiteList) + '</div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Publication</div>' + getPublicationList(data.publicationList)+ '</div><div class="separator-2"></div><div class="p-horizontal-16"><div class="type title-2">Award</div>' + getAwardList(data.awardList) + '</div></div></div></div></div>';

    $('#dialogContent').append(htmlContent);
}

function _onViewSelectedDoctorDetails(userId) {
  $("#dialogContent").empty();
  _callGetDoctorPublicDetailsApi(userId, function() {
    dialogDoctorDetails();
  });
  
}

// Dialog - Doctor Details
function dialogDoctorDetails() {
  el = document.getElementById("dialogDoctorDetails");
  el.style.visibility = (el.style.visibility == "visible") ? "hidden" : "visible";
}