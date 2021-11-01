
Polymer {

  is: 'page-patient-stay-print-preview'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
  ]

  properties:

    isVisitValid: 
      type: Boolean
      notify: false
      value: false

    isPatientValid:
      type: Boolean
      notify: false
      value: false      

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    visit:
      type: Object
      notify: true
      value: null

    isPatientStayValid:
      type: Boolean
      notify: false
      value: false

    patientStay:
      type: Object
      notify: true
      value: null


    settings:
      type: Object
      notify: true

  ## SETTINGS ======================================================================================

  _makeSettings: ->
    settings = 
      serial: 'only'
      isSyncEnabled: false
      printDecoration: 
        leftSideLine1: 'My Institution'
        leftSideLine2: 'My Institution Address'
        leftSideLine3: 'My Institution Contact'
        rightSideLine1: 'My Name'
        rightSideLine2: 'My Degrees'
        rightSideLine3: 'My Contact'
        footerLine: 'A simple message on the bottom'
        logoDataUri: null
      billingTargetEmailAddress: ''
      nsqipTargetEmailAddress: ''
      monetaryUnit: 'BDT'

  _getSettings: ->
    list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    if list.length
      @settings = list[0]
      if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
        if @organization.printSettings
          @settings.printDecoration = @organization.printSettings      
    else
      @domHost.showModalDialog 'No Settings Found'


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      console.log @user


  getFullName:(data)->
    honorifics = ''
    first = ''
    last = ''
    middle = ''

    if data.honorifics  
      honorifics = data.honorifics + ". "
    if data.first
      first = data.first
    if data.middle
      middle = " " + data.middle
    if data.last
      last = " " + data.last
      
    return honorifics + first + middle + last 

  makeAddress: (addressList)->
    return unless addressList
    if addressList.length
      address = addressList[0]
      return address.addressLine1?="" + address.addressLine2?="" + address.flat?="" + address.floor?="" + address.plot?="" + address.block?="" + address.road?="" + address.village?="" + address.union?="" + address.subDistrict?="" + address.district?="" + address.cityOrTown?="" 

    else
      return ""


  _loadPatient: ()->
    previewPatientObject = JSON.parse localStorage.getItem 'previewPatientStayPatientObject'
    if previewPatientObject
      @set 'patient', previewPatientObject
      @isPatientValid = true
      console.log 'loaded patient', @patient
    else
      @isPatientValid = false
      @_notifyInvalidPatient()


  $of: (a, b)->
    unless b of a
      a[b] = null
    return a[b]


  printButtonPressed: (e)->
    window.print()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  _notifyInvalidPatientStay: ->
    @isPatientStayValid = false
    @domHost.showModalDialog 'Invalid Patient Stay'


  _loadPatientStay: ()->
    previewPatientStay = JSON.parse localStorage.getItem 'previewPatientStayObject'
    if previewPatientStay
      @set 'patientStay', previewPatientStay
      @isPatientStayValid = true
      console.log 'loaded preview', @patientStay
    else
      @isPatientStayValid = false
      @_notifyInvalidPatientStay()
    

  _isEmptyString: (data)->
    if data is null or data is '' or data is 'undefined'
      return true
    else
      return false

  _computeTotalDaysCount: (endDateTimeStamp, startDateTimeStamp)->
    oneDay = 1000*60*60*24;
    diffMs = endDateTimeStamp - startDateTimeStamp
    return Math.round(diffMs/oneDay); 

  _returnSerial: (index)->
    index+1

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age

  navigatedIn: ->
    @organization = @getCurrentOrganization()
    @_loadUser()
    @_getSettings()    
    
    @_loadPatient()
    @_loadPatientStay()


  navigatedOut: ->
    # @visit = {}
    # @patient = {}
    # @patientStay = {}
    # @isVisitValid = false
    @isPatientValid = false
    @isPatientStayValid = false

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')

  _formatDate: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  calculateLengthOfStay: (admissionDate, dischargeDate)->
    diff = lib.datetime.diff (new Date dischargeDate), (new Date admissionDate)
    return diff/(1000*60*60*24)

}
