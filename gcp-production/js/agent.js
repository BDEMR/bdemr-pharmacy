// Initialze All Client Libraries code before API has been called
window.ClientLibrariesIsolatedScope(function(res) {
  _callGetListOfAgentsApi(function() {
    applyListViewWrapperPlugin();
  });

});


// Get List of Agent API
function _callGetListOfAgentsApi (cbfn) {

  window.lib.apis.CallGetListOfAgentsApi(( function ( response ) {
    var data = [];
    if( response.hasError == false ) {
      data = response.data;
      // console.log(data);
      for (var i = 0; i < data.length; i++) {
        viewListItem(data[i], i);
      }
      cbfn();
    }
  }).bind( this ) ) ;

}


function viewListItem(itemData) {
  var fullName, honorifics, middle, last, email, phone, profileImage, imageId, district;

  if(itemData.name.honorifics == null) {
    honorifics = "";
  } else {
    honorifics = itemData.name.honorifics + " ";
  }
  
  if(itemData.name.middle == null) {
    middle = "";
  } else {
    middle = " " + itemData.name.middle;
  }

  if(itemData.name.last == null) {
    last = "";
  } else {
    last = " " + itemData.name.last;
  }


  // Get Full Name
  fullName = honorifics + itemData.name.first + middle + last;

  // Get Only (1) Email Address from Email Address List Array if Array Length > 0
  if(itemData.emailAddressList.length > 0) {
    email = itemData.emailAddressList[0].emailAddress;
  } else {
    email = "-";
  }

  // Get Only (1) Phone Number from Phone Number List Array if Array Length > 0
  if(itemData.phoneNumberList.length > 0) {
    phone = itemData.phoneNumberList[0].phoneNumber;
  } else {
    phone = "-";
  }

  // Get Profile Image By Calling Another API called CallGetImageDataApi.
  if(itemData.profileImage == null) {
    profileImage = "images/staff/default.png";
  } else {
    imageId = itemData.profileImage;
    _callGetImageDataApi(itemData.profileImage); // Async
  }
  // Get District Name
  if(itemData.agentAppliedDistrictName == null) {
    district = "-"
  } else {
    district = itemData.agentAppliedDistrictName;
  }
  

  $("#agentList").append($('<div class="list-item-2"><div class="item-inline-thumbnail"><img id="'+ imageId +'" src="' + profileImage + '" alt=""><div><div class="agentName type body-lead">'+ fullName +'</div><div class="agentDistrictName">'+ district +'</div></div></div><div class="item-inline-details"><div class="agentPhoneNumber">' + phone + '</div><div class="agentEmail">' + email + '</div></div></div>'));

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

// Add Agent List Pagination and Filter
function applyListViewWrapperPlugin(){ 
  var agentListView = new List('listViewWrapper', {
    valueNames: ['agentName', 'agentPhoneNumber', 'agentEmail', 'agentDistrictName'],
    page: 10,
    plugins: [ ListPagination({}) ] 
  });
}