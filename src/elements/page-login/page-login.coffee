
Polymer {
  is: 'page-login'

  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.commonComputes
  ]

  properties:
    isLoading:
      type: Boolean
      value: false

    selectedPage:
      type: Number
      value: 0

    formData: 
      type: Object
      notify: true
      value: -> {}

    userNewPasswordRequestData:
      type: Object
      value: null
    
    genderTypes:
      type: Array
      value: ['male', 'female', 'other']
    
    selectedRole:
      type: Object
      value: null
    
    selectedRoleIndex:
      type: Number
      value: 2
      observer: '_roleChanged'
    
    roles:
      type: Array
      value: []
    
    ageInYears:
      type: Number
      value: 0
    
    verification:
      type: Number
      value: {}
    
    successMsg:
      type: String
      value: -> ''
    
    isItEmail:
      type: false
      value: null

    
  _resetFormData: ( emailOrPhone, password )->
    formData =
      emailOrPhone: emailOrPhone
      password: password
      gender: 'male'
      # dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      dateOfBirth: lib.datetime.mkDate Date.now()
      doctorAccessPin: '0000'
      selectedRole: {}

    if app.mode is 'development'
      formData.emailOrPhone = '01234567890'
      formData.password = '123456'
    
    @set 'formData', formData
    @set 'verification', {
      code: ''
      userId: ''
      emailOrPhone: ''
    }
  

  navigatedIn: ->
    @_resetFormData null, null

    params = @domHost.getPageParams()
    if params["signup"] is "new"
      @_navigateToSingupForm()
    else
      @set 'selectedPage', 0
    

  # LOGIN - START ------------------------------------------------------------------>

  loginButtonPressed: ()->
    isInputEmailOrPhoneValid = @$$("#inputEmailOrPhone").validate()
    isInputPasswordValid = @$$("#inputPassword").validate()

    if isInputEmailOrPhoneValid and isInputPasswordValid
      @loginApiCalled()
  
  enterKeyPressed: (e)->
    if e.keyCode is 13 
      @loginButtonPressed()
    
  _checkUserActivation: (user, cbfn)->
    console.log user.mode
    if user.mode is 'dev'
      cbfn()
      return
    dt = new Date user.accountExpiresOnDate
    now = new Date lib.datetime.mkDate lib.datetime.now()
    daysLeft = Math.floor ((lib.datetime.diff dt, now) / 1000 / 60 / 60 / 24)
    if daysLeft < 0
      @domHost.navigateToPage '#/activate'
      return
    else
      cbfn()
  
  loginApiCalled: ()->
    loginData =
      emailOrPhone: @formData.emailOrPhone
      password: @formData.password

    # @domHost.toggleModalLoader 'Please Wait...'
    @set 'isLoading', true
    @callApi '/bdemr-app-login-new', loginData, (err, response)=>
      # @domHost.toggleModalLoader()
      @set 'isLoading', false
      if response.hasError
        isActivated = response.error.message.isActivated
        isVerified = response.error.message.isVerified
        if isVerified is false
          unverifiedUserId = response.error.message.userId
          @_navigateToVerificationForm unverifiedUserId
          return

        if isActivated is false
          @domHost.showModalDialog "User is Disabled!"
          return
       
        @domHost.showModalDialog response.error.message
        
      else
        user = response.data
        @loginDbAction user, @shouldRememberUser
        # @_checkUserActivation user, ()=>
        @domHost._callAfterUserLogsIn()
        @domHost.navigateToPage '#/pharmacy-manager'
  
  _navigateToSingupForm: ()->
    @set 'selectedPage', 1

  # <----- LOGIN - END

  # PASSWORD RESET - START ------------------------------------------------------------------>
  _navigateToResetPasswordForm: ()->
    @set 'selectedPage', 2
  
  _checkIfEmailOrPhoneValid:(value)->
    isPhone = (/^[0-9]{11,11}(-[0-9]*){0,1}$/.test(value))

    isEmail = /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value)
    
    console.log isPhone, isEmail

    return isPhone || isEmail
  
  _resetPasswordBtnPressed: ()->
    if @formData.emailOrPhone is null
      @domHost.showToast 'Please Type your email/phone first!'
      return
    
    if !@_checkIfEmailOrPhoneValid @formData.emailOrPhone
      @domHost.showModalDialog 'Please Enter valid email/phone!'
      return
    # @domHost.toggleModalLoader 'Please Wait...'
    @set 'isLoading', true
    @callApi '/user-new-password-request', { recoveryEmailOrPhone: @formData.emailOrPhone }, (err, response)=>
      # @domHost.toggleModalLoader()
      @set 'isLoading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'formData.password', ''
        @_navigateToLoginForm()
        @domHost.showModalDialog response.data
        
  # <----- PASSWORD RESET - END 

  # SIGNUP - START ------------------------------------------------------------------>
  _getTodayDate: ()-> new Date().toISOString().split('T')[0]

  calculateAge: (e)->
    selectedDate = e.detail.value
    selectedDateYear = (new Date selectedDate).getFullYear()
    currentYear = (new Date).getFullYear()
    age = currentYear - selectedDateYear
    # console.log age
    if age is 0
      age = null
    @ageInYears = age

  makeDOBFromYears: (e)->

    age = e.target.value
    dateInYear = (new Date).getFullYear()
    dateInYear -= parseInt age
    @set 'formData.dateOfBirth', "#{dateInYear}-01-01"

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
        roleType: 'nurse',
        roleName: 'Nurse',
        requiredData: [
          {
            inputType: 'text',
            type: 'nurse-pass-year',
            label: 'Passed Year',
            value: '',
            key: 'nursePassedYear',
          },
          {
            inputType: 'text',
            type: 'nurse-institution',
            label: 'Current Instituion',
            value: '',
            key: 'nurseCurrentInstitutionName',
          }
        ]
      }
    ]
    cbfn()

  _navigateToLoginForm: ()->
    @set 'selectedPage', 0
    @_resetFormData @formData.emailOrPhone, @formData.password
  
  _roleChanged:(index)->
    if !@roles
      @_resetRoles =>
        selectedRole = @roles[index]
    
    selectedRole = @roles[index]
    
    @set 'selectedRole', selectedRole

  
  _callPulicSignupApi: ()->
    # @domHost.toggleModalLoader 'Please Wait...'
    @set 'isLoading', true
    @callApi '/user-signup-public', @formData, (err, response)=>
      # @domHost.toggleModalLoader()
      @set 'isLoading', false
      if response.hasError
        if response.error.details.isJoi
          @domHost.showModalDialog response.error.details.details[0].message
        else
          @domHost.showModalDialog response.error.message
      else
        # @_navigateToSuccessSection 'Account Created Successfully!'
        unverifiedUserId = response.data.userId
        @_navigateToVerificationForm unverifiedUserId
        

  
  signupButtonPressed: (e)->
    unless @formData.fullName and @formData.dateOfBirth and @formData.gender and @formData.emailOrPhone and @formData.password and @formData.doctorAccessPin
      @domHost.showToast 'Please Fill Up Required Information!'
      return

    unless @selectedRole
      @domHost.showToast 'Please Select your role.'

    @formData.selectedRole = @selectedRole

    @_callPulicSignupApi()
  
  # <----- END SIGNUP

  # VERIICATION  - START ------------------------------------------------------------------>
  _navigateToVerificationForm: (unverifiedUserId)->
    unless unverifiedUserId
      @domHost.showModalDialog 'Missing/Invalid UserId. Unable to sent verification code to user.'
      
    @_callSendAccountVerificationCodeApi unverifiedUserId, (mode)=>
      @verification.userId = unverifiedUserId
      if mode is 'dev'
        @set 'selectedPage', 4
      else
        @set 'selectedPage', 3

  verifyButtonPressed: (e)->
    isInputVerificationValid = @$$("#inputVerification").validate()

    if isInputVerificationValid
      @verification.emailOrPhone = @formData.emailOrPhone
      @_callVerifyUserAccountApi()
    
  _callVerifyUserAccountApi: ()->
    # @domHost.toggleModalLoader 'Please Wait...'
    @set 'isLoading', true
    @callApi '/verify-user-account', @verification, (err, response)=>
      # @domHost.toggleModalLoader()
      @set 'isLoading', false
      if response.hasError
          @domHost.showModalDialog response.error.message
      else
        @_navigateToSuccessSection 'Account Verified!'
  
  _navigateToSuccessSection:( message )->
    @set 'successMsg', message
    @set 'selectedPage', 4
  

  _callSendAccountVerificationCodeApi: (userId, cbfn)->
    data =
      userId: userId
      emailOrPhone: @formData.emailOrPhone

    @set 'isLoading', true
    @callApi '/send-account-verification-code', data, (err, response)=>
      # @domHost.toggleModalLoader()
      @set 'isLoading', false
      if response.hasError
          @domHost.showModalDialog response.error.message
      else
        @set 'isItEmail', response.data.isItEmail
        mode = response.data.mode
        cbfn mode
        

  # <----- END VERIICATION

        

          

}
