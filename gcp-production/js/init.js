var extractWhich;

extractWhich = function() {
  var endIndex, index, partArray, startIndex, which;
  if ((window.location.pathname.indexOf('/staff.html')) > -1) {
    which = null;
    startIndex = null;
    if ((index = window.location.search.indexOf('?which=')) > -1) {
      startIndex = index;
    }
    if ((index = window.location.search.indexOf('&which=')) > -1) {
      startIndex = index;
    }
    if (startIndex !== null) {
      if ((index = window.location.search.indexOf('&', startIndex + 1)) > -1) {
        endIndex = index;
      } else {
        endIndex = window.location.search.length;
      }
      which = window.location.search.substr(startIndex + '&which='.length, endIndex);
    } else {
      which = '';
    }
    return which;
  } else {
    partArray = window.location.pathname.split('/');
    if (partArray[0] === '') {
      partArray.shift();
    }
    if (partArray[0] !== 'staff' || partArray.length < 2) {
      console.log('Malformatted URL');
      return '';
    } else {
      return partArray[1];
    }
  }
};

document.addEventListener('DOMContentLoaded', function() {
  var index, map, staff, which;
  which = extractWhich();
  map = {
    'ashit': 0,
    'sayem': 1,
    'mahmudul': 2,
    'ijaz': 3,
    'al-amin': 4,
    'taufiq': 5,
    'sabbir': 6
  };
  if (which in map) {
    index = map[which];
    staff = window.bdemrStaffList[index];
    app.staffId.innerHTML = staff.id;
    app.staffName.innerHTML = staff.name;
    app.staffDesignation.innerHTML = staff.designation;
    app.staffProfileImage.src = staff.profileImage;
    app.staffEmail.innerHTML = staff.email;
    app.staffPhoneNumber.innerHTML = staff.phoneNumber;
    app.staffBloodGroup.innerHTML = staff.bloodGroup;
    app.personalWebSiteLink.href = staff.personalWebSiteLink;
    app.linkedinLink.href = staff.linkedinLink;
    return app.gitHubLink.href = staff.gitHubLink;
  } else {
    return console.log('not found');
  }
});
