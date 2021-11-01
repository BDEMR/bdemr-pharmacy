
Polymer {

  is: 'page-print-test-adviced'

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

    isPrescriptionValid:
      type: Boolean
      notify: false
      value: false

    isNoteValid:
      type: Boolean
      notify: false
      value: false

    isNextVisitValid:
      type: Boolean
      notify: false
      value: false

    isTestAdvisedValid:
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

    prescription:
      type: Object
      notify: true
      value: null

    doctorNote:
      type: Object
      notify: true
      value: null

    nextVisit:
      type: Object
      notify: true
      value: null

    testAdvised:
      type: Object
      notify: true
      value: null

    matchingPrescribedMedicineList:
      type: Array
      notify: true
      value: []

    doctorInstitutionList:
      type: Array
      notify: true
      value: []

    doctorSpecialityList:
      type: Array
      notify: true
      value: []

    doctorInstitutionSelectedIndex:
      type: Number
      notify: true
      value: 0

    doctorSpecialitySelectedIndex:
      type: Number
      notify: true
      value: 0

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
    # console.log userList
    if userList.length is 1
      @user = userList[0]

      # if userList[0].employmentDetailsList is not '[]'

      for employmentDetails in userList[0].employmentDetailsList
        @push 'doctorInstitutionList', employmentDetails.institutionName

      # if userList[0].specializationList is not '[]'

      for specializationDetails in userList[0].specializationList
        @push 'doctorSpecialityList', specializationDetails.specializationTitle


  getFullName:(data)->
    if data.honorifics is null
      data.honorifics = ''
    if data.last is null
      data.last = ''

    unless data.first is null
      return data.honorifics + " " + data.first + " " + data.last


  _makeNewTestAdvise: ()->
    
    @masterAdvisedTestObj =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: null
      visitSerial: null
      patientSerial: null
      doctorName: null
      doctorSpeciality: null
      data:
        testAdvisedList: []


  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  # printPrescriptionPressed: (e)->
  #   params = @domHost.getPageParams()

  #   if params['prescription'] != 'new'
  #     @domHost.navigateToPage '#/print-record/prescription:' + @prescription.serial + '/patient:' + @patient.serial

  $findCreator: (creatorSerial)-> 'me'

  _institutionSelectedIndexChanged: ()->
    return if @doctorInstitutionSelectedIndex is null
    item = @doctorInstitutionList[@doctorInstitutionSelectedIndex]
    @visit.hospitalName = item

  _specialitySelectedIndexChanged: ()->
    return if @doctorSpecialitySelectedIndex is null
    item = @doctorSpecialityList[@doctorSpecialitySelectedIndex]
    @visit.doctorSpeciality = item


  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  _notifyInvalidVisit: ->
    @isVisitValid = false
    @domHost.showModalDialog 'Invalid Visit Provided'

  _loadVisit: (visitIdentifier)->
    list = app.db.find 'doctor-visit', ({serial})-> serial is visitIdentifier
    if list.length is 1
      @isVisitValid = true
      @visit = list[0]

      unless @visit.advisedTestSerial is null
        @_loadTestAdvised @visit.advisedTestSerial

      return true
    else
      @_notifyInvalidVisit()
      return false
  _loadTestAdvised: (advisedTestSerial)->

    list = app.db.find 'visit-advised-test', ({serial})-> serial is advisedTestSerial
    # console.log list
    if list.length is 1
      @isTestAdvisedValid = true
      @testAdvised = list[0]
      console.log "testAdvisedObj: ", @testAdvised
      return true
    else
      @isTestAdvisedValid = false
      return false

  # _loadTestAdvised: (advisedTestSerial)->

  #   list = app.db.find 'visit-advised-test', ({serial})-> serial is advisedTestSerial
  #   # console.log list
  #   if list.length is 1
  #     @isTestAdvisedValid = true
  #     @testAdvised = list[0]
  #     return true
  #   else
  #     @isTestAdvisedValid = false
  #     return false

    # console.log "testAdvisedObj: ", @testAdvised


  createNewTestPressed: ()->
    params = @domHost.getPageParams()

    if params['visit'] is 'new'
      @_saveVisit()

    @domHost.navigateToPage  '#/test-adviced-editor/visit:' + @visit.serial + '/patient:' + @patient.serial + '/test-adviced:new'

  editTestAdvisedPressed: (e)->
    @domHost.navigateToPage  '#/test-adviced-editor/visit:' + @visit.serial + '/patient:' + @patient.serial + '/test-adviced:' + @testAdvised.serial


  _isEmpty: (data)->
    if data is 0
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

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

  printButtonPressed: (e)->
    window.print()

  navigatedIn: ->

    @_loadUser()
    @organization = @getCurrentOrganization()    

    params = @domHost.getPageParams()

    @_makeNewTestAdvise()

    unless params['visit']
      @_notifyInvalidVisit()
      return

    unless params['patient']
      @_notifyInvalidPatient()
      return
    else
      @_loadPatient(params['patient'])


    if params['visit'] is 'new'
      @_makeNewVisit()
    else
      @_loadVisit(params['visit'])

    @_getSettings()

  navigatedOut: ->
    @visit = {}
    @patient = {}
    @isVisitValid = false
    @isPatientValid = false
    @isTestAdvisedValid = false
    @doctorInstitutionList = []
    @doctorSpecialityList = []

  _formatDateTime: (dateTime)->
    # console.log dateTime
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')


}
