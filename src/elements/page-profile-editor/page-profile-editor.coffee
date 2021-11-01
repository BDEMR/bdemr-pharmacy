
Polymer {

  is: 'page-profile-editor'

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
      value: -> app.db.find('user')[0]

    organization:
      type: Object
      notify: true
      value: -> app.db.find('organization')[0]

    genderList:
      type: Array
      value: -> ['male', 'female', 'other']
    
    bloodGroupList:
      type: Array
      value: -> [ "A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]

    divisionIndex:
      type: Number
      value: -1
      notify: true

    districtIndex:
      type: Number
      value: -1
      notify: true

    districtList:
      type: Array
      value: -> []
      notify: true

    divisionList:
      type: Array
      value: -> [
        {
            divisionName: "Barisal"
            districtList: [
                "Barguna",
                "Barisal",
                "Bhola",
                "Jhalokati",
                "Patuakhal",
                "Pirojpur"
            ]
        }
        {
            divisionName: "Chittagong"
            districtList: [
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
            ]
        }
        {
            divisionName: "Dhaka"
            districtList: [
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
                "Tangail "
            ]
        }
        {
            divisionName: "Khulna"
            districtList: [
                "Bagerhat",
                "Chuadanga",
                "Jessore",
                "Jhenaidah",
                "Khulna",
                "Kushtia",
                "Magura",
                "Meherpur",
                "Narail",
                "Satkhira"
            ]
        }
        {
            divisionName: "Mymensingh"
            districtList: [
                "Jamalpur",
                "Mymensingh",
                "Netrakona",
                "Sherpur"
            ]
        }
        {
            divisionName: "Rajshahi"
            districtList: [
                "Bogra",
                "Joypurhat",
                "Naogaon",
                "Natore",
                "Nawabganj",
                "Pabna",
                "Rajshahi",
                "Sirajganj"
            ]
        }
        {
            divisionName: "Rangpur"
            districtList: [
                "Dinajpur",
                "Gaibandha",
                "Kurigram",
                "Lalmonirhat",
                "Nilphamari",
                "Panchagarh",
                "Rangpur",
                "Thakurgaon"
            ]
        }
        {
            divisionName: "Sylhet"
            districtList: [
                "Habiganj",
                "Moulvibazar",
                "Sunamganj",
                "Sylhet"
            ]
        }
      ]

    selectedRole:
      type: Object
      value: null
    
    newAddress:
      type: Object
      value: {
        emailOrPhone: ''
        code: ''
        type: 'phone number'
        icon:'icons:settings-phone'
      }
    
    selectedRoleIndex:
      type: Number
      value: -1
      observer: '_roleChanged'
    
    roles:
      type: Array
      value: []

    profileImage:
      type: String
      value: null
      notify: true

    maximumImageSizeAllowedInBytes:
      type: Number
      value: 1000 * 1000


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    console.log @user
    @_setUserInfo()


  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @_callSetUserProfileImage dataUri
        
  
  _callSetUserProfileImage: (dataUri)->
    attachment =
      mainStorage: 'server'
      apiKey: (app.db.find 'user')[0].apiKey
      dataURI: dataUri
      userSerial: @user.serial

    console.log 'attachment', attachment

    @set 'isUploading', true
    @callApi '/bdemr-set-user-profile-image', attachment, (err, response)=>
      @set 'isUploading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'profileImage', dataUri
        @set 'user.profileImage', dataUri
        @user.fileNameOnServer = response.data.fileNameOnServer
        

  onDivisionChange: (e)->
    @set 'districtIndex', -1
    districtList = @divisionList[@divisionIndex].districtList
    lib.util.delay 5, ()=>
      @set 'districtList', districtList


  _getUserInfo: ()->
    @domHost.toggleModalLoader 'Getting your Information...'
    @callApi '/get-user-info', { apiKey: @user.apiKey, organizationId: @organization.idOnServer }, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        user = response.data
        user.fullName = @$getFullName user.name
        user.apiKey = @user.apiKey

        if user.profileImage
          @set 'profileImage', user.profileImage
        else
          @set 'profileImage', 'images/avatar.png'

        @set 'user', user
        console.log 'user', @user
  


  _isUserADoctor: (user)->
    unless user.roles?
      return false
    isDoctor = false
    user.roles.forEach (role)=>
      roleName = ''
      if role and role.roleName then roleName = role.roleName.toLowerCase()
      if roleName is 'doctor'
        isDoctor = true
    console.log 'is user a doctor ',isDoctor
    return isDoctor

  _setUserInfo: ()->
    @domHost.toggleModalLoader 'Updating Profile...'
    @callApi '/set-user-info', { apiKey: @user.apiKey, data: @user }, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_getUserInfo()
  

  _insertAddressObject: ()->
    @push 'user.addressList',
      {
        addressTitle: 'Personal'
        addressType: 'personal'
        flat: ''
        floor: ''
        plot: ''
        block: ''
        road: ''
        village: ''
        addressUnion: ''
        subdistrictName: ''
        addressDistrict: ''
        addressPostalOrZipCode: ''
        addressCityOrTown: ''
        addressDivision: ''
        addressAreaName: ''
        addressLine1: ''
        addressLine2: ''
        stateOrProvince: ''
        addressCountry: "Bangladesh"
      }

  _spliceAddress:(e)->
    index = e.model.index
    @splice 'user.addressList', index, 1

  _insertRoleObject:(roleName, roleType, requiredData)->
    @push 'user.roles',
      {
        roleName: roleName
        roleType: roleType
        isActivated: true
        requiredData: requiredData
      }

  _spliceRole:(e)->
    index = e.model.index
    @splice 'user.roles', index, 1


  _insertSpecializationObject: ()->
    @push 'user.specializationList',
      {
        specializationTitle: ''
      }

  _spliceSpecialization:(e)->
    index = e.model.index
    @splice 'user.specializationList', index, 1

  _insertEmploymentObject: ()->
    @push 'user.employmentDetailsList',
      {
        currentPosition: ''
        institutionName: ''
        institutionAddress: ''
        institutionWebsiteLink: ''
      }

  _spliceEmployment:(e)->
    index = e.model.index
    @splice 'user.employmentDetailsList', index, 1

  _insertDegreeObject: ()->
    @push 'user.degreeList',
      {
        degreeTitle: ''
        degreeInstitution: ''
        degreeDetails: ''
        degreeYear: null
      }

  _spliceDegree:(e)->
    index = e.model.index
    @splice 'user.degreeList', index, 1
  
  _insertAwardListObject: ()->
    @push 'user.awardList',
      {
        awardTitle: ''
        awardWebUrl: ''
        awardDetails: ''
        awardYear: null
      }

  _spliceAward:(e)->
    index = e.model.index
    @splice 'user.awardList', index, 1
  
  _insertPublicationObject: ()->
    @push 'user.publicationList',
      {
        publicationTitle: ''
        publicationUrl: ''
      }

  _splicePublication:(e)->
    index = e.model.index
    @splice 'user.publicationList', index, 1

  _insertFaxNumberObject: ()->
    @push 'user.faxNumberList',
      {
        faxNumber: ''
        faxNumberType: ''
      }

  _spliceFaxNumber:(e)->
    index = e.model.index
    @splice 'user.faxNumberList', index, 1

  _insertSocialConnectionListObject: ()->
    @push 'user.socialConnectionList',
      {
        socialConnectionTitle: ''
        socialConnectionUrl: ''
      }

  _spliceSocialConnectionList:(e)->
    index = e.model.index
    @splice 'user.socialConnectionList', index, 1

  _insertWebSiteObject:(e)->
    @push 'user.websiteList',
      {
        websiteTitle: ''
        websiteUrl: ''
      }

  _spliceWebSite:(e)->
    index = e.model.index
    @splice 'user.websiteList', index, 1

  # ======================== Roles Related codes ==================

  _addNewRolePressed: (e)-> 
    return this.$$('#dialogAddRoleDetails').toggle();  

  _roleChanged:(index)->
    if !@roles
      @_resetRoles =>
        selectedRole = @roles[index]
    
    selectedRole = @roles[index]
    
    @set 'selectedRole', selectedRole
    @set 'user.isBmdcNumberVerified', false

    console.log "Deatils on the role user clicked", selectedRole

  _resetRoles: (cbfn) ->
    @roles = [
      # Doctor
      {
        roleType: 'doctor'
        roleName: 'Doctor'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'bmdc-type'
            label: 'BMDC Type',
            value: ''
            key: 'bmdcType'
          }
          {
            inputType: 'text',
            type:'bmdc-number'
            label: 'BMDC Registration Number',
            value: ''
            key: 'bmdcRegNumber'
          }
          {
            inputType: 'number',
            type:'mbbs-passed-year'
            label: 'MBBS/BDS Passed Year',
            value: ''
            key: 'mbbsPassedYear'
          }
          {
            inputType: 'text',
            type:'mbbs-passed-institution'
            label: 'MBBS/BDS Passed Institution',
            value: ''
            key: 'mbbsPassedInstitution'
          }
          {
            inputType: 'text',
            type:'doctor-type'
            label: 'Doctor Type',
            value: ''
            key: 'doctorType'
          }
        ]
      }
      # Physician(Non BMDC)
      {
        roleType: 'physician-non-bmdc'
        roleName: 'Physician(Non BMDC)'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'doctor-type'
            label: 'Doctor Type',
            value: ''
            key: 'doctorType'
          }
        ]
      }
      # Patient
      {
        roleType: 'patient'
        roleName: 'Patient'
        requiredData: []
        isActivated: true
      }

      # Student
      {
        roleType: 'student'
        roleName: 'Student'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'student-year'
            label: 'Student Year',
            value: ''
            key: 'studentInstitutionYear'
          }
          {
            inputType: 'text',
            type:'student-institution'
            label: 'Current Instituion',
            value: ''
            key: 'studentInstitutionName'
          }
        ]
      }

      # Agent
      {
        roleType: 'agent'
        roleName: 'Agent'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'applied-district'
            label: 'Applied District Name',
            value: ''
            key: 'agentAppliedDistrictName'
          }
          {
            inputType: 'text',
            type:'nid'
            label: 'National ID',
            value: ''
            key: 'nationalIdCardNumber'
          }
        ]
      }

      # Clinic owner
      {
        roleType: 'clinic-owner'
        roleName: 'Institution Admin'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'nid'
            label: 'National ID',
            value: ''
            key: 'nationalIdCardNumber'
          }
        ]
      }

      # Doctor Assistant
      {
        roleType: 'doctor-assistant'
        roleName: 'Doctor Assistant'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'nid'
            label: 'National ID',
            value: ''
            key: 'nationalIdCardNumber'
          }
        ]
      }

      # Clinic Staff
      {
        roleType: 'clinic-staff'
        roleName: 'Hospital/Clinic Staff'
        isActivated: true
        requiredData: [
          {
            inputType: 'text',
            type:'staff-type'
            label: 'Staff Type',
            value: ''
            key: 'clinicStaffType'
          }
          {
            inputType: 'text',
            type:'nid'
            label: 'National ID',
            value: ''
            key: 'nationalIdCardNumber'
          }
        ]
      }

      # Nurse
      {
        roleType: 'nurse'
        roleName: 'Nurse'
        isActivated: true
        requiredData: []
      }
    ]
    cbfn()

  roleSubmitBtnPressed: (e)->

    for item in @selectedRole.requiredData
      unless item.value
        return @domHost.showToast 'Please Fill Up Required Information!'

    unless @selectedRole.roleType
      return @domHost.showToast 'Please Fill Up Required Information!'

    @_insertRoleObject(@selectedRole.roleName, @selectedRole.roleType, @selectedRole.requiredData)
    return this.$$('#dialogAddRoleDetails').close();

  # ======================== Roles Related codes End ==================
  _resetEmailOrPhoneObject: (type, icon)->
    @set 'newAddress', {
      emailOrPhone: ''
      code: ''
      type: type
      icon: icon
    }

  _showAddPhoneNumberDialog:()->
    @_resetEmailOrPhoneObject 'phone number', 'cons:settings-phone'
    @$$('#dialogAddEmailOrPhone').toggle()
  
  _showAddEmaliAddressDialog:()->
    @_resetEmailOrPhoneObject 'email', 'communication:email'
    @$$('#dialogAddEmailOrPhone').toggle()

  _addAndVerifyNewEmailOrPhoneNumber: ()->

    if @newAddress.type is 'phone number'
      unless 10 < @newAddress.emailOrPhone.length < 15
        return @domHost.showToast 'Phone Number should be 11 to 14 digit long!'
    
    if @newAddress.type is 'email'
      emailReg = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      isThatValidEmail = emailReg.test(String(@newAddress.emailOrPhone).toLowerCase())

      if !isThatValidEmail
        return @domHost.showToast 'Phone Number should be 11 to 14 digit long!'
    
    unless @newAddress.code.length is 6
      return @domHost.showToast 'Verification Code should be 6 digit long!'
    
    @_callVerifyAndSetUserEmailOrPhoneNumber @newAddress.emailOrPhone, @newAddress.code, =>
      @$$('#dialogAddEmailOrPhone').close()
  
  _callVerifyAndSetUserEmailOrPhoneNumber: (emailOrPhone, code, cbfn)->
    data =
      emailOrPhone: emailOrPhone
      code: code
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Verifying...'
    @callApi '/bdemr-verify-and-set-user-phone-or-email', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast response.data.message
        @_getUserInfo()
        cbfn()
  
  # _callSendVerificationRequest: (cbfn)->
  #   data =
  #     apiKey: @user.apiKey

  #   @domHost.toggleModalLoader 'Sending verification request...'
  #   @callApi '/send-bmdc-verification-request', data, (err, response)=>
  #     @domHost.toggleModalLoader()
  #     if response.hasError
  #       @domHost.showModalDialog response.error.message
  #     else
  #       @domHost.showToast response.data.message
  #       cbfn()

  
  # _sendVerificationRequest: ()->
  #   @_callSendVerificationRequest =>
      

  navigatedIn: ->
    @_getUserInfo()
    @_resetRoles =>
      console.log "Roles Loaded"
      


}
