dataURItoBlob = (dataURI) ->
  byteString = atob(dataURI.split(',')[1])
  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  blob = new Blob([ ab ], type: mimeString)
  blob

Polymer {

  is: 'page-all-test-result-print'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    isPatientValid: 
      type: Boolean
      notify: false
      value: true

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    testResultsObject:
      type: Object
      notify: true
      value: null

    matchingAdvisedTestList:
      type: Array
      notify: true
      value: []

    matchingTestResultsList:
      type: Array
      notify: true
      value: []


    attachmentList:
      type: Array
      notify: false
      value: -> []

    newAttachment:
      type: Object
      notify: false
      value: null

    localDataUriDb:
      type: Object
      value: null

    maximumImageSizeAllowedInBytes: 
      type: Number
      value: 10 * 1000 * 1000

    maximumLocalDataUriDbSizeInChars: 
      type: Number
      value: 2 * 1000 * 1000

    localDataUsedPercentage:
      type: Number
      value: 0

    currentDateFilterStartDate:
      type: Number

    currentDateFilterEndDate:
      type: Number

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    showPrintDetails:
      type: Boolean

  # Helper
  # ================================

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  $findCreator: (creatorSerial)-> 'me'

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

  _computeTotalDaysCount: (endDate, startDate)->
    return (@$TRANSLATE("As Needed", @LANG)) unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    diffMs = endDate - startDate
    x =  Math.round(diffMs / oneDay)
    return @$TRANSLATE_NUMBER(x, @LANG)

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age

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

  _sortByDate: (a, b)->
    if a.date < b.date
      return 1
    if a.date > b.date
      return -1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1


  _createTestResultsObject:()->
    @testResultsObject = {
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: null
      patientSerial: null
      advisedTestSerial: null
      investigationSerial: null
      investigationName: null
      attachmentSerialList: []
      data:
        testList: []
        status: null

    }
      

  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadOrganization: ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]

  _loadTestAdvised: (patientSerialIdentifier)->

    advisedTestList = app.db.find 'visit-advised-test', ({patientSerial})-> patientSerial is patientSerialIdentifier
    # console.log advisedTestList

    extendedTestList =  []

    for advisedTest in advisedTestList
      for test in advisedTest.data.testAdvisedList
        unless test.status.hasTestResults
          testObject = {
            advisedTestSerial: advisedTest.serial
            createdDatetimeStamp: advisedTest.createdDatetimeStamp
            doctorName: advisedTest.doctorName
            doctorSpeciality: advisedTest.doctorSpeciality
            data: test
          }

          extendedTestList.push testObject

    extendedTestList.sort (left, right)->
      return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
      return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
      return 0

    @matchingAdvisedTestList = extendedTestList

    console.log 'matchingAdvisedTestList', @matchingAdvisedTestList

  _loadTestResults: (patientIdentifier)->
    console.log patientIdentifier

    testResultList = app.db.find 'patient-test-results', ({patientSerial})-> patientSerial is patientIdentifier
    console.log 'testResultList', testResultList
    testResultList.sort (left, right)->
      return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
      return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
      return 0

    @matchingTestResultsList = testResultList

    console.log 'matchingTestResultsList:', @matchingTestResultsList


    params = @domHost.getPageParams()

    if params['startDate'] isnt 'null' and params['startDate'] isnt 'undefined' and params['endDate'] isnt 'null' and params['endDate'] isnt 'undefined'
      startDate = new Date params['startDate']
      endDate = new Date params['endDate']

      endDate.setHours 24 + endDate.getHours()
      
      filterdTRList = []
      for testResult in @matchingTestResultsList
        for test in testResult.data.testList
          console.log 'test', test.datePerform
          if (startDate.getTime() <= (new Date test.datePerform).getTime() < endDate.getTime())
            filterdTRList.push testResult
      @matchingTestResultsList = filterdTRList


  _onClickTakeThisTestToResultPage: (e)->

    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#advised-test-list-repeater'

    index = repeater.indexForElement el
    investigation = @matchingAdvisedTestList[index]
    # console.log  investigation

    


    @testResultsObject.serial = @generateSerialForTestResuts()
    @testResultsObject.createdByUserSerial = @user.serial
    @testResultsObject.patientSerial = @patient.serial
    @testResultsObject.advisedTestSerial = investigation.advisedTestSerial
    @testResultsObject.investigationSerial = investigation.data.serial
    @testResultsObject.investigationName = investigation.data.investigationName

    

    for item in investigation.data.testList
      testObject = {
        datePerform: lib.datetime.now()
        testName: item.testName
        testUnitList: item.testUnitList
        referenceRange: item.referenceRange
        institutionName: @getInstitutionName()
        testResult: null
        testUnit: null
        reportedBy: @_getFullName @user.name
        unitSelectedIndex: 0
      }

      
      @push 'testResultsObject.data.testList', testObject


    @saveTestResult @testResultsObject


    @domHost.navigateToPage '#/test-results/test-results:' + @testResultsObject.serial + '/patient:' + @patient.serial

  getInstitutionName: ()->
    if typeof @settings is 'undefined'
      return ''
    else
      return @settings.institutionName

  _onCreateNewTestResultBtnPressed: (e)->
    @domHost.navigateToPage '#/test-results/test-results:new/patient:' + @patient.serial


  saveTestResult: (data)->
    app.db.upsert 'patient-test-results', data, ({serial})=> data.serial is serial
    @domHost.showToast 'Record Saved!'


  _notifyInvalidPatient: ->
    @isPatientValid = false
    @showModal 'Invalid Patient Provided'

  printTestResultsItemClicked: (e)->
    @domHost.showToast 'working progress!'
    # el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    # el.opened = false
    # repeater = @$$ '#test-results-list-repeater'
    # params = @domHost.getPageParams()

    # index = e.model.index
    # testResults = @matchingTestResultsList[index]

    # id = (app.db.find 'patient-test-results', ({serial})-> serial is testResults.serial)[0]._id


  printButtonPressed: (e)->
    window.print()
    
  deleteTestResultsItemClicked: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#test-results-list-repeater'
    params = @domHost.getPageParams()

    index = e.model.index
    testResults = @matchingTestResultsList[index]

    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
       
        id = (app.db.find 'patient-test-results', ({serial})-> serial is testResults.serial)[0]._id

        app.db.remove 'patient-test-results', id
        app.db.insert 'patient-test-results--deleted', { serial: testResults.serial }
        # @splice 'prescribedMedicineList', index, 1
        @domHost.showToast 'Record Deleted!'
        @_loadTestResults @patient.serial


  navigatedIn: ->

    params = @domHost.getPageParams()

    @_loadUser()
    @_loadOrganization()

    showPrintDetails = window.localStorage.getItem('showPrintSectionOnTestResult')
    @set 'showPrintDetails', showPrintDetails

    # @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
    #   @set 'settings', settings   
    @_createTestResultsObject()
    
    if params['patient']
      @_loadPatient params['patient']
    else
      @_notifyInvalidPatient()

    @_loadTestAdvised @patient.serial
    @_loadTestResults @patient.serial
    

        

  navigatedOut: ->
    @settings = {}
    @patient = null
    @isPatientValid = false
    @patient = null

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

    


}
