
Polymer {

  is: 'page-patient-signup'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: {}

    organization:
      type: Object
      notify: true
      value: {}


    patient:
      type: Object
      notify: true
      value: -> {}

    selectedPage:
      type: Number
      value: 0

    verifyPhoneNumber:
      type: Object
      notify: true
      value: -> {}

    ageInYears:
      type: Number
      value: 0

    ageInMonths:
      type: Number
      value: 0


    errorMsg:
      type: String
      notify: true
      value: null

    successMsg:
      type: String
      notify: true
      value: null

    errorMsg2:
      type: String
      notify: true
      value: null

    successMsg2:
      type: String
      notify: true
      value: null

    disableRepeatPhoneNumber:
      type: Boolean
      notify: true
      value: true

    errorMsg3:
      type: String
      notify: true
      value: null

    successMsg3:
      type: String
      notify: true
      value: null


    maximumImageSizeAllowedInBytes:
      type: Number
      value: 1000 * 1000

    disableNextBtn:
      type: Boolean
      value: true
      notify: true

    addClassOnNextBtn:
      type: String
      value: ''
      notify: true

    isPhoneNumberAvailable:
      type: Boolean
      value: false
      notify: true

    profileImage:
      type: String
      value: null
      notify: true
    
    bloodGroupList:
      type: Array
      value: -> [ "A+", "A-", "B+", "B-", "O+","O-", "AB+", "AB-"]

    
    divisionList:
      type: Array
      value: -> [ "Barisal", "Chittagong", "Dhaka", "Khulna", "Mymensingh","Rajshahi", "Rangpur", "Sylhet"]

    districtList:
      type: Array
      value: -> [
        "Barguna",
        "Barisal",
        "Bhola",
        "Jhalokati",
        "Patuakhal",
        "Pirojpur"
        "Bandarban",
        "Brahmanbaria",
        "Chandpur",
        "Chittagong",
        "Comilla",
        "Cox's Bazar",
        "Feni",
        "Khagrachhari",
        "Lakshmipur",
        "Noakhali",
        "Rangamati"
        "Dhaka",
        "Faridpur",
        "Gazipur",
        "Gopalganj",
        "Kishoreganj",
        "Madaripur",
        "Manikganj",
        "Munshiganj",
        "Narayanganj",
        "Narsingdi",
        "Rajbari",
        "Shariatpur",
        "Tangail ",
        "Bagerhat",
        "Chuadanga",
        "Jessore",
        "Jhenaidah",
        "Khulna",
        "Kushtia",
        "Magura",
        "Meherpur",
        "Narail",
        "Satkhira",
        "Jamalpur",
        "Mymensingh",
        "Netrakona",
        "Sherpur",
        "Bogra",
        "Joypurhat",
        "Naogaon",
        "Natore",
        "Nawabganj",
        "Pabna",
        "Rajshahi",
        "Sirajganj",
        "Dinajpur",
        "Gaibandha",
        "Kurigram",
        "Lalmonirhat",
        "Nilphamari",
        "Panchagarh",
        "Rangpur",
        "Thakurgaon",
        "Habiganj",
        "Moulvibazar",
        "Sunamganj",
        "Sylhet"
      ]


    organization:
      type: Object
      notify: true
      value: null

    professionList:
      type: Array
      value: -> ['Employed', 'Unemployed', 'Home Maker', 'Student', 'Retired']

    expenditureList:
      type: Array
      value: -> ['bellow 10,000', '10,000-20,000', '20,000-30,000', '30,000-40,000', '40,000-50,000', '50,000 & Above']

    maritalStatusList:
      type: Array
      value: -> ['Married', 'Unmarried', 'Divorced', 'Widowed', 'Widower', 'Separated']

    educationTypeList:
      type: Array
      value: -> ['No formal education', '1-5 years', '5-10 years', '10 to 12 years', '12 to 16', 'More than 16 years']
    
    patientTypeList:
      type: Array
      value: -> ['Regular', 'VIP', 'Employee', 'Political', 'Police Case', 'Free Patient']



  # compute function - start
  calculateAge: (e)->
    selectedDate = e.detail.value
    console.log 'selected age : ', selectedDate

    # extending computeAge() from common-computes
    today = new Date()
    birthDate = new Date selectedDate
    yearDiff = today.getFullYear() - birthDate.getFullYear()
    monthDiff = today.getMonth() - birthDate.getMonth()
    dateDiff = today.getDate() - birthDate.getDate()

    console.log 'initial year diff : ', yearDiff
    console.log 'initial month diff : ', monthDiff
    console.log 'initial date diff : ', dateDiff

    if monthDiff is 0
      if dateDiff < 0
        yearDiff-- unless yearDiff is 0
        monthDiff = 11
    else if monthDiff < 0
      yearDiff-- unless yearDiff is 0
      monthDiff = 12 - Math.abs monthDiff
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0
    else
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0


    console.log 'year diff : ', yearDiff
    console.log 'month diff : ', monthDiff

    @set 'ageInYears', yearDiff
    @set 'ageInMonths', monthDiff


    ## original code
    # selectedDate = e.detail.value
    # selectedDateYear = (new Date selectedDate).getFullYear()
    # currentYear = (new Date).getFullYear()
    # age = currentYear - selectedDateYear
    # console.log age;
    # if age is 0
    #   age = null
    # @ageInYears = age


  # makeDOBFromYears: (e)->
  #   age = e.target.value
  #   dateInYear = (new Date).getFullYear()
  #   dateInYear -= parseInt age
  #   @set 'patient.dateOfBirth', "#{dateInYear}-01-01"

  makeDOBFromYMD: (e)->
    uptoHour = 24*60*60*1000
    yearTimeInMS = Math.round (@ageInYears*365.25*uptoHour) # 365.25 to account for leap years
    monthTimeInMS = Math.round (@ageInMonths*30.5*uptoHour) # 30.5 to account for 30/31 days
    
    dobTime = (new Date).getTime()-yearTimeInMS-monthTimeInMS
    dobDate = new Date ((new Date).setTime(dobTime))
    tempDOB_Y = dobDate.getFullYear()
    tempDOB_M = (dobDate.getMonth()+1).toString()

    if tempDOB_M.length is 1 then tempDOB_M = "0#{tempDOB_M}"

    console.log 'year ', tempDOB_Y
    console.log 'month ', tempDOB_M

    @set 'patient.dateOfBirth', "#{tempDOB_Y}-#{tempDOB_M}-01"
    return



  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @set 'profileImage', dataUri
      @set 'patient.profileImage', dataUri

  # compute function - end

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  # offline sign up - start
  _mimicPatientImport: (patient, cbfn)->
    patient.flags = {
      isImported: false
      isLocalOnly: false
      isOnlineOnly: false
    }
    patient.flags.isImported = true
    app.db.insert 'patient-list', patient
    cbfn()
  

  # offline sign up - end

  

  
  # Import patient (from server) - start
  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patientList = response.data

        if patientList.length isnt 1
          return @domHost.showModalDialog 'Unknown error occurred.'
        patient = patientList[0]

        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isImported = true

        @removePatientIfAlreadyExist patient.serial
        
        _id = app.db.insert 'patient-list', patient
        cbfn patient
  # Import patient (from server) - end
  

  _gotoPatientDetailsPage: (patientId)->
    @domHost.navigateToPage "#/patient-view/patient:" + patientId

  
  
  removePatientIfAlreadyExist: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier

    if list.length is 1
      patient = list[0]
      app.db.remove 'patient-list', patient._id
      return
    else
      return
  
  createdPatientVisitedLog: (patient)->

    visitedPatientLogObject = {
      createdByUserSerial: @user.serial
      serial: @generateSerialForVisitedPatientLog()
      patientSerial: patient.serial
      patientName: patient.name
      visitedDateTimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
    }

    app.db.insert 'visited-patient-log', visitedPatientLogObject

  goPatientViewPage: (patient)->
    params = @domHost.getPageParams()
    if params['chamber']
      window.localStorage.setItem('newPatientSerialFromChamber', patient.serial)
      @arrowBackButtonPressed()
    else
      @domHost.setCurrentPatientsDetails patient
      @createdPatientVisitedLog patient
      @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:0'
      @domHost.selectedPatientPageIndex = 5
  

  nextBtnPressed: ()->
    console.log 'creating patient', @patient
    unless @patient.name and @patient.dateOfBirth and @patient.gender and @patient.phone and @patient.password and @patient.doctorAccessPin
      @domHost.showToast 'Please Fill Up Required Information'
      return

    if @patient.phone
      if @patient.repeatPhone isnt @patient.phone
        @domHost.showToast 'Repeated Phone Number Not Matched!'
        return

    if @patient.email
      if @patient.repeatEmail isnt @patient.email
        @domHost.showToast 'Repeated Email Not Matched!'
        return
    
    @patient.name = @$makeNameObject @patient.name

    console.log 'PATINET NAME', @patient.name

    @patient.organizationId = @organization.idOnServer
    @patient.organizationSerial = @organization.serial or @organization.name.slice(0, 4)
    
    @_callBdemrAppPatientPartialSignupApi @patient, (patientSerial, doctorAccessPin)=>
      @_importPatient patientSerial, doctorAccessPin, (patient)=>
        @_memorizePinForNewPatient patientSerial, doctorAccessPin
        @goPatientViewPage patient
        @domHost.showToast 'Patient Created Successfully!'

       

  _createTemporaryOfflinePatient: (patient, cbfn)->
    serial = '' + (new Date).getTime() + '-' + (Math.floor(Math.random() * 10000) + 10000)
    patient.serial = serial
    patient.isTemporaryOfflinePatient = true
    lib.util.delay 0, => cbfn patient

    @_createTemporaryOfflinePatient @patient, (patient)=>
      @_memorizePinForNewPatient patient
      @_mimicPatientImport patient
      @domHost.showModalDialog "Patient Created Successfully!"

  getAddressObject:()->
    addressList = [
      {
        addressTitle: 'Personal'
        addressType: 'personal'
        flat: null
        floor: null
        plot: null
        block: null
        road: null
        village: null
        addressUnion: null
        subdistrictName: null
        addressDistrict: null
        addressPostalOrZipCode: null
        addressCityOrTown: null
        addressLine1: null
        addressLine2: null
        stateOrProvince: null
        addressCountry: 'Bangladesh'
      }
    ]

    return addressList

  _mimicImportPatient: (item, cbfn)->
    patient = 
          
      idOnServer: null
      source: 'online'
      lastSyncedDatetimeStamp: 0
      lastModifiedDatetimeStamp : lib.datetime.mkDate lib.datetime.now()
      createdDatetimeStamp: lib.datetime.mkDate lib.datetime.now()
      createdByUserSerial: @user.serial
      serial: @generateSerialForOfflinePatient()
      name: item.name
      email: item.email or ''
      phone: item.phone or ''
      additionalPhoneNumber: item.additionalPhoneNumber or ''
      profileImage: null

      patientType: 'Regular'
      dateOfBirth: item.dateOfBirth or ''
      effectiveRegion: item.effectiveRegion or ''
      gender: item.gender  or ''
      bloodGroup: item.bloodGroup  or ''
      allergy: item.allergy or ''
      drugAllergy: item.drugAllergy or {value: null, list: []}
      emmergencyContact: item.emmergencyContact or {}

      addressList: item.addressList or @getAddressObject()

      nationalIdCardNumber: item.nationalIdCardNumber or ''

      employmentDetailsList: []


      belongOrganizationList: item.belongOrganizationList or []

      expenditure: item.expenditure or ''
      profession: item.profession or ''

      
      patientSpouseName: item.patientSpouseName or ''
      patientFatherName: item.patientFatherName or ''
      patientMotherName: item.patientFatherName or ''
      maritalAge: item.maritalAge or ''
      maritalStatus: item.maritalStatus or ''
      numberOfFamilyMember: item.numberOfFamilyMember or ''
      numberOfChildren: item.numberOfChildren or ''
      recordSpecificPatientIdList: []

      doctorAccessPin: item.doctorAccessPin or '0000'
      password: item.password or '123456'
      organizationId: item.organizationId
      organizationSerial: item.organizationSerial


      flags:
        isImported: true
        isLocalOnly: false
        isOnlineOnly: false

      isTemporaryOfflinePatient: true
      
      userAlreadyExist: false

    cbfn patient
    return



  offlineSignup: ()->
    console.log @patient
    unless @patient.name and @patient.dateOfBirth and @patient.gender and @patient.phone and @patient.password and @patient.doctorAccessPin
      @domHost.showToast 'Please Fill Up Required Information'
      return

    if @patient.phone
      if @patient.repeatPhone isnt @patient.phone
        @domHost.showToast 'Repeated Phone Number Not Matched!'
        return

    if @patient.email
      email = @patient.email

      emailRegex =  /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      emailTest = emailRegex.test email
      
      if emailTest is false
        @domHost.showToast 'Please provide valid Email Address!'
        return

      else if @patient.repeatEmail isnt @patient.email
        @domHost.showToast 'Repeated Email Not Matched!'
        return
    
    @patient.name = @$makeNameObject @patient.name

    console.log 'PATINET NAME', @patient.name

    @patient.organizationId = @organization.idOnServer
    @patient.organizationSerial = @organization.serial
    
    @_mimicImportPatient @patient, (patient)=>
      console.log 'patient', patient
      app.db.insert 'patient-list', patient
      @_memorizePinForNewPatient patient.serial, patient.doctorAccessPin
      @goPatientViewPage patient
      @domHost.showToast 'Patient Created Successfully in Offline!'


  verifyBtnPressed: ()->
    @_callVerifyPatientPhoneNumber @verifyPhoneNumber, =>
      patientId = @verifyPhoneNumber.patientId
      @_callBdemrAppPatientCompleteSignupApi patientId



  _memorizePinForNewPatient: (patientSerial, doctorAccessPin)->

    patientPinObject = {}
    patientPinObject.organizationId = @organization.idOnServer
    patientPinObject.patientSerial = patientSerial
    patientPinObject.pin = doctorAccessPin

    console.log 'patientPinObject', patientPinObject
      
    app.db.upsert 'local-patient-pin-code-list', patientPinObject, ({patientSerial})=> patientPinObject.patientSerial is patientSerial


  _callBdemrAppPatientPartialSignupApi: (data, cbfn) ->

    data.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Patient Signup in progress, please wait...'  
    @callApi '/bdemr-app-patient-signup-partial', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patientId = response.data.patientId
        doctorAccessPin = response.data.doctorAccessPin
        patientSerial = response.data.patientSerial

        # @verifyPhoneNumber.patientId = patientId
        # @set 'selectedPage', 1
        console.log patientSerial, doctorAccessPin

        cbfn patientSerial, doctorAccessPin

  _checkIfMobileNumberAvailable: (e)->
    # console.log '@patient.phone', @patient.phone
    unless @patient.phone is null
      length = @patient.phone.length
      # console.log 'length', length

      if ((length is 11) or (length is 13) or (length is 14))
        @_callBdemrAppCheckUserProvidedPhoneNumber()
      else
        @set 'errorMsg', null
        @set 'successMsg', null
        @checkNextBtnStatus true


  _callBdemrAppCheckUserProvidedPhoneNumber: ()->
    data = {}
    data.phone = @patient.phone
    data.apiKey = @user.apiKey

    @callApi '/bdemr-check-user-provided-phone-number', data, (err, response)=>
      console.log response
      if !response.hasError
        if response.data.isNumberInUse
          @set 'errorMsg', response.data.message
          @set 'successMsg', null
          @set 'isPhoneNumberAvailable', false
          @set 'disableRepeatPhoneNumber', true
        else
          @set 'errorMsg', null
          @set 'successMsg', response.data.message
          @set 'isPhoneNumberAvailable', true
          @set 'disableRepeatPhoneNumber', false
      
      @checkNextBtnStatus()

  checkNextBtnStatus: ()->
    # console.log 'patient', @patient

    unless @patient.name and @patient.dateOfBirth and @patient.gender and @patient.phone
      @set 'disableNextBtn', true
      @set 'addClassOnNextBtn', ''
      return

    if @isPhoneNumberAvailable
      @set 'disableNextBtn', false
    else
      @set 'disableNextBtn', true

    @changeNextBtnClass @disableNextBtn

  changeNextBtnClass: (disabled) ->
    if disabled
      @set 'addClassOnNextBtn', ''
    else
      @set 'addClassOnNextBtn', 'btn success'

    

  _callBdemrAppPatientCompleteSignupApi: (patientId)->
    data = {}
    data.patientId = patientId
    data.apiKey = @user.apiKey

    @callApi '/bdemr-app-patient-signup-complete', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog 'Patient Created Successfully!'
        @domHost.navigateToPage '#/patient-manager/query:' + @patient.phone

  _callVerifyPatientPhoneNumber: (data, cbfn) ->
    data.apiKey = @user.apiKey

    console.log data

    @callApi '/bdemr-verify-patient-phone-number', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  _checkForPhoneNumberMatch: (e)->

    length = @patient.repeatPhone.length

    if ((length is 11) or (length is 13) or (length is 14))
      if (@patient.repeatPhone is @patient.phone)
        @set "successMsg2", "Phone Number Matched!"
        @set "errorMsg2", null
      else
        @set "errorMsg2", "Phone Number Not Matched!"
        @set "successMsg2", null

  _checkForEmailMatch: (e)->

    if @patient.email
      emailRegex =  /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      emailTest = emailRegex.test @patient.email
      if emailTest
        if (@patient.repeatEmail is @patient.email)
          @set "successMsg3", "Email Address Matched!"
          @set "errorMsg3", null
        else
          @set "errorMsg3", "Email Address Not Matched!"
          @set "successMsg3", null



  _makePatientSignupObject: ()->
    patient =
      name: null
      phone: null
      repeatPhone: null
      email: null
      repeatEmail: null
      dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      gender: 'male'
      profileImage: null
      nationalIdCardNumber: null
      organizationId: null
      password: '123456'
      doctorAccessPin: '0000'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer

      additionalPhoneNumber: null
      effectiveRegion: null
      bloodGroup: null
      allergy: null
      drugAllergy:
        value: null
        list: []
        
      emmergencyContact: 
        name: null
        relation: null
        phoneNumber: null

      addressList: [
        {
          addressTitle: 'Personal'
          addressType: 'personal'
          flat: null
          floor: null
          plot: null
          block: null
          road: null
          village: null
          addressUnion: null
          subdistrictName: null
          addressDistrict: null
          addressPostalOrZipCode: null
          addressCityOrTown: null
          addressLine1: null
          addressLine2: null
          stateOrProvince: null
          addressCountry: null
        }
      ]

      employmentDetailsList: []
      belongOrganizationList: []

      expenditure: null
      profession: null
      education: null

      patientSpouseName: null
      patientFatherName: null
      patientMotherName: null
      maritalAge: null
      maritalStatus: null
      numberOfFamilyMember: 0
      numberOfChildren: 0
      recordSpecificPatientIdList: []

      patientType: 'Regular'

    @set 'patient', patient

    @verifyPhoneNumber =
      patientId: null
      typedSmsVerificationCode: null
  
  addAnotherDrugAllergy: (e)->
    @push "patient.drugAllergy.list", {
      type: ''
    }

  deleteDrugAllergy: (e)->
    index = e.model.index
    @splice "patient.drugAllergy.list", index, 1



    

  navigatedIn: ->
    @user = (app.db.find 'user')[0]
    @set 'selectedPage', 0
    @set 'profileImage', 'images/avatar.png'

    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"

    @_makePatientSignupObject()

    console.log 'setting up patient', @patient

  navigatedOut: ->
    # console.trace 'navigatedOut'
    @patient = null
    @isPatientValid = false
    @set "EDIT_MODE_ON", false


}
