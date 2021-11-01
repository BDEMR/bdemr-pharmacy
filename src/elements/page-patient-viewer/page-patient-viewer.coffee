dataURItoBlob = (dataURI) ->
  byteString = atob(dataURI.split(',')[1])
  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)    i++
  blob = new Blob([ ab ], type: mimeString)
  blob

Polymer {

  is: 'page-patient-viewer'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    COUNTER:
      type: Number
      notify: true
      value: 0

    selectedAddTestPage:
      type: Number
      notify: true
      value: 0

    selectedTestResultPage:
      type: Number
      notify: true
      value: 0

    selectedPage:
      type: Number
      notify: true
      value: 0
    
    favoriteMedicineShownIndex:
      type: Number
      value: -1
      
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

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    testResultsObject:
      type: Object
      notify: true
      value: null

    matchingTestResultsList:
      type: Array
      notify: true
      value: []

    matchingPatientStayList:
      type: Array
      notify: true
      value: []

    invoiceList:
      type: Array
      value: []

    invoiceListWithoutCompleted:
      type: Array
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

    investigationPriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []

    selectedInvoiceIndex:
      type: Number
      value: null
      notify: true

    selectedTestList:
      type: Array
      value: []
      notify: true

    selectedTestListForInvoice:
      type: Array
      value: []

    investigationDataList:
      type: Array
      value: []
      notify: true
    
    nonResultedAdvisedTestList:
      type: Array
      value: []

    addedInvestigationList:
      type: Array
      value: []
      notify: true

    modifiedAdvisedTestList:
      type: Array
      value: []
      notify: true

    makingInvoiceLoading:
      type: Boolean
      value: -> false

    patientConsentFormList: 
      type: Array
      value: -> []

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    sample:
      type: Object,
      value: -> {
        id: ''
        type: ''
      }

    sampleTypeList:
      type: Array
      value: -> ['blood', 'urine', 'stool', 'pus', 'ascitic fluid', 'peritonial fluid', 'sputum', 'saliva', 'semen', 'rectal swab', 'throat swab', 'tissue for histopathology']

    sampleId:
      type: String
      value: ''

    sampleType:
      type: String
      value: ''
    
    lockdownAreas:
      type: Array
      value: []

    covidTestResultList:
      type: Array
      value: []


  # Helper
  # ================================

  _calculateDue: (billed, received)->
    if received >= billed
      return 0
    else
      return billed-received

  _hasDue: (billed, received)->
    return billed > received

  _areAllPaymentsCleared: (invoiceList)->
    for invoice in invoiceList
      return false if @_hasDue invoice.totalBilled, invoice.totalAmountReceieved
    return true

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
    # @domHost.navigateToPage '#/patient-manager/selected:0'

  $findCreator: (creatorSerial)-> 'me'

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  _isEmptyArray: (length)->
    if length is 0
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


  _compareFn: (left, op, right) ->
    if op is '<'
      return left < right
    if op is '>'
      return left > right
    if op is '=='
      return left == right
    if op is '>='
      return left >= right
    if op is '<='
      return left <= right
    if op is '!='
      return left != right

  getFullName:(data)->
    if typeof data is "object"
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

    else return data

  _sortByCreatedDate: (a, b)-> b.createdDatetimeStamp - a.createdDatetimeStamp
  
  _sortByDate: (a, b)->
    if a.lastModifiedDatetimeStamp < b.lastModifiedDatetimeStamp
      return 1
    if a.lastModifiedDatetimeStamp > b.lastModifiedDatetimeStamp
      return -1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1

  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle
    return ''

  _loadPatient: (patientIdentifier, cbfn)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    # console.log list
    if list.length is 1
      @isPatientValid = true
      @set 'patient', list[0]
      # console.log 'patient:', @patient
      if @patient.phone then @patientPhoneNumber = @patient.phone
      cbfn()
    else
      @_notifyInvalidPatient()

    

  _loadUser:(cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
    cbfn()

  _loadOrganization:(cbfn) ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
      @_loadTestResultUploadCountSummary();
    else
      @_notifyInvalidOrganization()

    cbfn()
  
  _loadTestResultUploadCountSummary: ->
    query = {
      "hospitalId": this.organization.idOnServer
    }
    this.callApi '/bdemr-clinic-app--get-upload-count-summary', query, (err, response)=>
      if err or response.hasError
        this.testResultUploadCount = 0;
        return
      list = response.data.uploadCountSummaryList
      if list.length is 1
        this.testResultUploadCount = list[0].testVisitCount
      else
        this.testResultUploadCount = 0;


  _loadTestResults: (patientIdentifier, organizationIdentifier)->
    # console.log patientIdentifier

    collectionName = 'bdemr--patient-test-results'
    data={
      apiKey : @user.apiKey
      patientSerial : patientIdentifier
      collectionName : collectionName
      hospitalId : organizationIdentifier
    }
    @callApi 'bdemr--get-patient-details', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          collectedData = response.data
          # console.log 'medicinelist',collectedData
   
          testResultList = collectedData
          testResultList.sort (left, right)->
            return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
            return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
            return 0

    

          @matchingTestResultsList = testResultList

    # console.log 'matchingTestResultsList', @matchingTestResultsList

    # for testResults, testResultIndex in @matchingTestResultsList
    #   @_getVisitDataForTestResults testResults.visitSerial, testResultIndex

    # console.log 'matchingTestResultsList', @matchingTestResultsList


  _getVisitDataForTestResults: (visitIdentifier, testResultIndex)->
    data={
      apiKey : @user.apiKey
      visitSerial : visitIdentifier
    }
    @domHost.toggleModalLoader('Loading data...')
    @callApi '/bdemr-get-doctor-visit-suggestion', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
        return
      else
        list = response.data
    if list.length is 1
      @matchingTestResultsList[testResultIndex].visitObject = list[0]


  
  _getInstitutionName:()->

    list = app.db.find 'settings'
    unless list.length is 0
      @settings = list[0]
      if @settings.institutionName
        return @settings.institutionName
      else
        return ''
    return ''

  _onCreateNewTestResultBtnPressed: (e)->
    @domHost.navigateToPage '#/advised-test/advised-test:new/patient:' + @patient.serial


  saveTestResult: (data)->
    app.db.upsert 'patient-test-results', data, ({serial})=> data.serial is serial
    @domHost.showToast 'Record Saved!'


  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'
  
  printTestResultsItemClicked: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#test-results-list-repeater'
    params = @domHost.getPageParams()

    index = e.model.index
    testResults = @matchingTestResultsList[index]

    id = (app.db.find 'patient-test-results', ({serial})-> serial is testResults.serial)[0]._id
    # console.log id

    @domHost.navigateToPage  '#/single-test-result-print/patient:' + @patient.serial + '/test-result:' + @testResultsObject.serial

  printAllTestResultsClicked: (e)->
    @domHost.navigateToPage  '#/all-test-result-print/patient:' + @patient.serial  + '/startDate:' + @currentDateFilterStartDate + '/endDate:' + @currentDateFilterEndDate
  

  testResultsCustomSearchClicked: (e)->
    @currentDateFilterStartDate = e.detail.startDate
    @currentDateFilterEndDate = e.detail.endDate

    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    # filterdTRList = (item for item in @matchingTestResultsList when (startDate.getTime() <= (new Date item.data.testList.datePerform).getTime() <= endDate.getTime()))
    
    filterdTRList = []
    for testResult in @matchingTestResultsList
      for test in testResult.data.testList
        # console.log 'test', test.datePerform
        if (startDate.getTime() <= (new Date test.datePerform).getTime() < endDate.getTime())
          filterdTRList.push testResult
    @matchingTestResultsList = filterdTRList
  
  testResultsSearchClearButtonClicked: (e)->
    @currentDateFilterStartDate = null
    @currentDateFilterEndDate = null

    params = @domHost.getPageParams()
    @_loadTestResults(params['patient'], @organization.idOnServer)


  previewTestResultsItemClicked: (e)->
    el = @locateParentNode e.target, 'PAPER-ITEM'
    el.opened = false
    repeater = @$$ '#test-results-list-repeater'

    index = repeater.indexForElement el
    
    testResult = @matchingTestResultsList[index]
    
    @domHost.navigateToPage '#/single-test-result-print/record:' + testResult.serial + '/patient:' + @patient.serial


  editTestResultsItemClicked: (e)->

    el = @locateParentNode e.target, 'PAPER-ITEM'
    el.opened = false
    repeater = @$$ '#test-results-list-repeater'

    index = repeater.indexForElement el
    testResults = @matchingTestResultsList[index]

    # console.log index
    @domHost.navigateToPage '#/test-results/test-results:' + testResults.serial + '/patient:' + @patient.serial

    

  # deleteTestResultsItemClicked: (e)->
  #   el = @locateParentNode e.target, 'PAPER-ITEM'
  #   el.opened = false
  #   repeater = @$$ '#test-results-list-repeater'
  #   params = @domHost.getPageParams()

  #   index = e.model.index
  #   testResults = @matchingTestResultsList[index]

  #   @domHost.showModalPrompt 'Are you sure?', (answer)=>
  #     if answer is true
       
  #       id = (app.db.find 'patient-test-results', ({serial})-> serial is testResults.serial)[0]._id

  #       app.db.remove 'patient-test-results', id
  #       app.db.insert 'patient-test-results--deleted', { serial: testResults.serial }
  #       # @splice 'prescribedMedicineList', index, 1
  #       @domHost.showToast 'Record Deleted!'
  #       @_loadTestResults @patient.serial, @organization.idOnServer

  _saveTestResults: (data)->
    app.db.upsert 'patient-test-results', data, ({serial})=> data.serial is serial

  flagAsErrorTestResultsItemClicked: (e)->
    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer
        el = @locateParentNode e.target, 'PAPER-ITEM'
        el.opened = false
        repeater = @$$ '#test-results-list-repeater'

        index = repeater.indexForElement el
        item = @matchingTestResultsList[index]

        item.data.flags =
          flagAsError: true

        @_saveTestResults item

        @_loadTestResults @patient.serial, @organization.idOnServer

        @domHost.showToast "Flagged Successfully!"


  # CONSENT FORM
  # ===============================

  _loadPatientConsentFormList: (patientIdentifier, organizationIdentifier) ->
    list = app.db.find 'patient-consent-form', ({patientSerial, organizationId})-> patientSerial is patientIdentifier and organizationId is organizationIdentifier
    @patientConsentFormList = list
    # console.log {list}
  
  addNewConsentFormClicked: ->
    @domHost.navigateToPage '#/patient-consent-form/patient:'+ @patient.serial
  
  viewConsentFormButtonClicked: (e)->
    {item} = e.model
    @domHost.navigateToPage '#/print-consent-form/serial:' + item.serial

  deleteConsentFormButtonClicked: (e)->
    {item, index} = e.model
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.remove 'patient-consent-form', item._id
    app.db.insert 'patient-consent-form--deleted', item
    @splice 'patientConsentFormList', index, 1


  # Patient Stay [START]
  # ================================
  _loadPatientStay: (collectionName, patientSerial,cbfn)->
      data = {
        apiKey: @user.apiKey
        patientSerial : patientSerial
        collectionName : collectionName
      }
      this.domHost.toggleModalLoader 'Please Wait'
      @callApi '/bdemr--get-patient-details', data, (err, response)=>
        this.domHost.toggleModalLoader()
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          collectedData = response.data
          cbfn collectedData
  _loadPatientStayList: (patientIdentifier) ->
    collectionName = "bdemr--patient-stay"
    @_loadPatientStay collectionName ,patientIdentifier ,(loadedData)=>
    # list = app.db.find 'visit-patient-stay', ({patientSerial})-> patientSerial is patientIdentifier
    
      patientStayList = [].concat loadedData
      patientStayList.sort (left, right)->
        return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
        return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
        return 0

      @set 'matchingPatientStayList', patientStayList


  


  ## Select Test - start
  _getNonResultedTestAdvised: (patientIdentifier, cbfn)->
    @set 'nonResultedAdvisedTestList', []

    data = {
      apiKey: @user.apiKey
      patientIdentifier: patientIdentifier
      userId: @user.idOnServer
    }
    @isLoading = true
    @callApi '/bdemr-non-resulted-advised-test-list', data, (err, response)=>
      @isLoading = false
      # console.log 'nonResultedAdvisedTestList', response.data
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        nonResultedAdvisedTestList = response.data
        # console.log nonResultedAdvisedTestList
        nonResultedAdvisedTestList.sort (left, right)->
          return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
          return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
          return 0
        
        console.log {nonResultedAdvisedTestList}
        @set 'nonResultedAdvisedTestList', nonResultedAdvisedTestList

        @_filterNonResultedAdvisedTestList @nonResultedAdvisedTestList

        cbfn()

  _filterNonResultedAdvisedTestList: (list)->
    @set 'modifiedAdvisedTestList', []
    for item in list
      unless typeof item.data.status.invoiceSerial is 'undefined'
        if item.data.status.invoiceSerial isnt null
          @push 'modifiedAdvisedTestList', item
    # console.log @modifiedAdvisedTestList


  _getCovidLockdownAreas: (cbfn)->
    query = {
      apiKey: @user.apiKey
    }
    @isLoading = true
    @callApi '/bdemr--get-covid-lockdown-areas', query, (err, response)=>
      @isLoading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'lockdownAreas', response.data
        console.log 'lockdown areas', @lockdownAreas
      cbfn()


  _highlightFromCovidRedZone: (lockdownAreas, patient)->
    return false unless patient
    return false unless patient.addressList[0]
    return false unless lockdownAreas.length
    addressLine = (patient.addressList[0].addressLine1 or "").toLowerCase()
    for lockDownArea in lockdownAreas
      return true if (addressLine.includes lockDownArea.area.toLowerCase()) and (lockDownArea.level.toLowerCase() is 'red')
    return false


  _getSelectedTestListData: ()->
    filteredList = []
    unless @nonResultedAdvisedTestList.length is 0
      for item in @nonResultedAdvisedTestList
        if item.checked is true
          filteredList.push item

      return filteredList


  ## Test Results - start
  makeTestResultObject: (testAdvise)->
    # console.log 'testAdvise', testAdvise

    testList = []
    groupTestList = []

    tempTestList = []
    if testAdvise.data.hasGroupTest
      if testAdvise.data?.testGroupList? 
        tempTestList = testAdvise.data.testGroupList
      else if testAdvise.data?.testAdvisedList?
        tempTestList = testAdvise.data.testAdvisedList      
    else
      if testAdvise.data?.testList? 
        tempTestList = testAdvise.data.testList
      else if testAdvise.data?.testAdvisedList?
        tempTestList = testAdvise.data.testAdvisedList
        
    
    console.log 'tempTestList', tempTestList

    # Making test result ready non groups
    if !testAdvise.data.hasGroupTest
      for item in tempTestList
        test =
          datePerform: lib.datetime.mkDate new Date
          testName: item.name
          testUnitList: item.unitList
          referenceRange: item.referenceRange
          institutionName: @organization.name
          sample: testAdvise.data.sample
          testResult: item.value
          testUnit: null
          comment: ''
          method: null
          resultRanges: []
          diagnosis: ''

        testList.push test

    # Making test result ready groups
    if testAdvise.data.hasGroupTest
      for group in tempTestList
        obj = {}
        obj.groupName = group.testGroupName
        obj.testList = []
        for item in group.investigaitonList
          test =
            datePerform: lib.datetime.mkDate new Date
            testName: item.name
            testUnitList: item.unitList
            referenceRange: item.referenceRange
            institutionName: @organization.name
            sample: testAdvise.data.sample
            testResult: item.value
            testUnit: null
            comment: ''
            method: null
            resultRanges: []
            diagnosis: ''

          obj.testList.push test
        groupTestList.push obj

    console.log 'groupTestList', groupTestList

    # Create test result object
    testResultsObject =
      serial: @generateSerialForTestResuts()
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      patientIdOnServer: @patient.idOnServer
      hospitalName: @organization.name
      hospitalId: @organization.idOnServer
      advisedTestSerial: testAdvise.advisedTestSerial
      advisedDoctorSerial: testAdvise.doctorSerial
      advisedDoctorName: testAdvise.doctorName
      advisedDoctorSpeciality: ''
      advisedTestCreatedDatetimeStamp: testAdvise.createdDatetimeStamp
      investigationSerial: testAdvise.data.serial
      investigationName: testAdvise.data.investigationName
      attachmentSerialList: []
      reportedDoctorSerial: @user.serial
      reportedDoctorName: @user.name
      reportedDoctorSpeciality: @getDoctorSpeciality()
      availableToPatient: false
      data:
        groupInvestigation: testAdvise.data.hasGroupTest
        overallComment: ''
        testList: testList
        groupTestList: groupTestList
        status: null
        flags:
          flagAsError: false
          seenByAdvisedDoctor: false
          seenByReportedDoctor: false

  _preCreateResult: ()->
    selectedTestList = @_getSelectedTestListData()
    # console.log 'selectedTestList', selectedTestList
    return if selectedTestList.length is 0
    testResultObjectList = []
    for item, index in selectedTestList
      # console.log 'index', index
      testResultObjectList.push @makeTestResultObject item
    return JSON.stringify(testResultObjectList)
    
  createResult: ()->
    #save temporally on localstorage
    testResultObjectList = @_preCreateResult()
    localStorage.setItem("testResultObjectList", testResultObjectList)
    @domHost.navigateToPage '#/test-results/test-results:multi/patient:' + @patient.serial

  ## Test Results - end

  goPatientEditPage: ()->
    @domHost.navigateToPage '#/patient-editor/patient:' + @patient.serial

  goPreconceptionRecordEditPage: ()->
    @domHost.navigateToPage '#/preconception-record/patients:' + @patient.serial

  goToPreconceptionRecordPreviewPage: ()->
    @domHost.navigateToPage '#/preview-preconception-record/patients:' + @patient.serial
  

  getPatientPccRecords: (patientIdentifier, organizationIdentifier, cbfn) ->
    data =
      apiKey: @user.apiKey
      patientSerial: patientIdentifier
      organizationId: organizationIdentifier

    @isLoading = true
    @callApi '/get-patient-pcc-records', data, (err, response)=>
      @isLoading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        list = response.data

        if list.length > 0
          list.sort (left, right)->
            return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
            return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
            return 0

          @matchingPccRecordList = list
        else
          @matchingPccRecordList = []


  loadPatientPccRecords: (patientIdentifier, cbfn) ->
    list = app.db.find 'pcc-records', ({patientSerial}) -> patientSerial is patientIdentifier

    # console.log list    
    if list.length > 0
      list.sort (left, right)->
        return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
        return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
        return 0

    @matchingPccRecordList = list

    cbfn()

  loadPatientNdrRecords: (patientIdentifier) ->
    list = app.db.find 'ndr-records', ({patientSerial}) -> patientSerial is patientIdentifier

    # console.log 'NDR records', list    
    if list.length > 0
      list.sort (left, right)->
        return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
        return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
        return 0

    @matchingNdrRecordList = list

  checkIfPatientHaveDiabeticsOrNot: ()->
    possibleDMStringList = ['Known Diabetes', 'DM', 'KNOWN DIABETES']
    if @matchingPccRecordList.length > 0
      for item in @matchingPccRecordList
        for string in possibleDMStringList
          if item.clinical?.pregnancyInfo?.glycemicStatus? is string
            localStorage.setItem("currentPatientGlycemicStatus", string)
            return
    else return

  _callBDEMRPatientDetailsUpdateApi: (patient) ->
    data =
      patient: patient
      apiKey: @user.apiKey
      
    @callApi '/bdemr-patient-details-update', data, (err, response)=>
      # console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'Patient Updated!'

  formatDate: (d)->

    month = d.getMonth()
    day = d.getDate().toString()
    year = d.getFullYear()
    year = year.toString().substr(-2)
    month = (month + 1).toString()

    if (month.length is 1)
      month = "0" + month
 
    if (day.length is 1)
      day = "0" + day
      
    # return the string "MMddyy"
    return day + month + year

  generateRandomString : ( randomStringLength ) ->
    randomString = ''
    characterList = []
    for item in [0..25]
      characterList.push String.fromCharCode( 'a'.charCodeAt() + item )
    for item in [0..25]
      characterList.push String.fromCharCode( 'A'.charCodeAt() + item )
    for item in [0..9]
      characterList.push String.fromCharCode( '0'.charCodeAt() + item )

    len = characterList.length
    for item in [ 1..randomStringLength ]
      idx = ( Math.floor ( Math.random() * 10000363 ) ) % 10000019
      idx %= len
      randomString += characterList[ idx ]

    return randomString

  generateRandomNumericString : ( randomStringLength ) ->
    randomString = ''
    characterList = []
    for item in [0..9]
      characterList.push String.fromCharCode( '0'.charCodeAt() + item )

    len = characterList.length
    for item in [ 1..randomStringLength ]
      idx = ( Math.floor ( Math.random() * 10000363 ) ) % 10000019
      idx %= len
      randomString += characterList[ idx ]

    return randomString


  generatedRecordSpecificRandomPatientId: (recordTypeIdentifier, cbfn)->
    ms = lib.datetime.now()
    d = new Date()
    date = @formatDate d

    data =
      apiKey: @user.apiKey
      organizationSerial: @organization.serial
      recordTypeIdentifier: recordTypeIdentifier
      date: date

    @callApi '/bdemr-get-record-specific-patient-id', data, (err, response)=>
      generatedPatientId = null

      if response.hasError
        console.log response.hasError
      else
        generatedPatientId = response.data.generatedPatientId

      cbfn generatedPatientId


  checkForRecordSpecificPatientId: (recordTypeIdentifier, cbfn)->
    recordSpecificIdList = []

    patientIdExist = false

    if ((typeof @patient.recordSpecificPatientIdList is 'undefined') or (@patient.recordSpecificPatientIdList is null))
      @patient.recordSpecificPatientIdList = []
    else
      recordSpecificIdList = @patient.recordSpecificPatientIdList

    if recordSpecificIdList.length > 0
      for item in recordSpecificIdList
        if item.recordType is recordTypeIdentifier
          patientIdExist = true
          break
        else
          patientIdExist = false

    cbfn patientIdExist
    return

  addRecordSpecificPatientId: (patientIdExist, recordTypeIdentifier, cbfn)->
    patient = @patient

    if !patientIdExist

      @generatedRecordSpecificRandomPatientId recordTypeIdentifier, (generatedPatinetId)=>

        object = {
          recordType: recordTypeIdentifier
          patientId: generatedPatinetId
        }

        patient.recordSpecificPatientIdList.push object

        app.db.upsert 'patient-list', patient, ({serial})=> patient.serial is serial

        @_callBDEMRPatientDetailsUpdateApi patient

        cbfn()

    cbfn()

  viewPccRecord: (e)->
    index = e.model.index
    record = @matchingPccRecordList[index]
    @domHost.navigateToPage "#/preview-preconception-record/record:" + record.serial

  editPccRecord: (e)->
    index = e.model.index
    record = @matchingPccRecordList[index]
    @domHost.navigateToPage "#/preconception-record/record:" + record.serial + "/patients:" + record.patientSerial

  getPatientIdForRecordType: (recordTypeIdentifier, list)->
    # console.log 'recordSpecificIdList', list

    if typeof list is 'undefined'
      return null
    
    else
      # console.log 'LENGTH', list.length
      # console.log 'recordTypeIdentifier', recordTypeIdentifier
      if list.length > 0
        for item in list
          if item.recordType is recordTypeIdentifier
            # console.log 'item.patientId', item.patientId
            return item.patientId
            break
           
        return null
      else
        return null

  addNewPccRecord: ()->
    patient = @patient
    @checkForRecordSpecificPatientId 'PCC', (patientIdExist)=>
      @addRecordSpecificPatientId patientIdExist, 'PCC', =>
        @domHost.navigateToPage "#/preconception-record/record:new" + "/patients:" + patient.serial

  viewNdrRecord: (e)->
    index = e.model.index
    record = @matchingNdrRecordList[index]
    @domHost.navigateToPage "#/preview-ndr/record:" + record.serial + "/patient:" + record.patientSerial

  editNdrRecord: (e)->
    index = e.model.index
    record = @matchingNdrRecordList[index]
    @domHost.navigateToPage "#/ndr/record:" + record.serial + "/patient:" + record.patientSerial

  addNewNdrRecord: ()->
    patient = @patient
    @checkForRecordSpecificPatientId 'NDR', (patientIdExist)=>
      @addRecordSpecificPatientId patientIdExist, 'NDR', =>
        @domHost.navigateToPage "#/ndr/record:new" + "/patient:" + patient.serial

  getOrganizationSpecificPatientSerial: (list)->
    
    orgId = @currentOrganization.idOnServer

    if list.length is 0
      @set 'orgSpecificPatientId', null
    else
      for item in list
        if item.organizationId is orgId
          @set 'orgSpecificPatientId', item.patientId

    # console.log 'orgSpecificPatientId', @orgSpecificPatientId

  editPatientBtnPressed: ()->
    @domHost.navigateToPage "#/patient-editor/patient:" + @patient.serial


  createPatientCardPressed: ()->
    @domHost.navigateToPage "#/print-patient-card/patient:" + @patient.serial

  
  createNewPatientCardPressed: ()->
    @domHost.navigateToPage "#/print-patient-card-new/patient:" + @patient.serial
  

  addNewAdvisedTest:()->
    @domHost.navigateToPage "#/advised-test-editor/patient:" + @patient.serial + "/record:" + "new"
  

  navigatedIn: ->
    # @COUNTER++
    # @domHost._syncOnlyPatientData =>
    # console.log 'inside navigated in'

    @selectedTestList = []

    params = @domHost.getPageParams()

    if params['selected']
      index = params['selected']
      index = parseInt index
      @set "selectedPage", index

    @_loadUser =>
      @_loadOrganization =>
        # @_getSettings()
        @_getCovidLockdownAreas =>
          if params['patient']
            @_loadPatient params['patient'], =>
              console.log @nonResultedAdvisedTestList
              @_getNonResultedTestAdvised @patient.serial, =>
                @_loadTestResults @patient.serial, @organization.idOnServer
                @_loadPatientStayList @patient.serial
                @_loadPatientConsentFormList @patient.serial, @organization.idOnServer
                @_loadInvoice @patient.serial, @organization.idOnServer
                # @_loadInvestigationPriceList @organization.idOnServer
                # @loadPatientPccRecords @patient.serial, =>
                @getPatientPccRecords @patient.serial, @organization.idOnServer, =>
                  @checkIfPatientHaveDiabeticsOrNot()
                @loadPatientNdrRecords @patient.serial
                console.log @nonResultedAdvisedTestList
                @_listCovidTests @patient.serial
          else
            @_notifyInvalidPatient()


  navigatedOut: ->
    @selectedTestList = []
    @selectedTestListForInvoice = []
    @patient = null
    @isPatientValid = false
    @patient = null
    @organization = null
    @nonResultedAdvisedTestList = []

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  # _isEmptyArray: (data)->
  #   if data is 0
  #     return true
  #   else
  #     return false

  # _checkIfItIsSingleLength: (data)->
  #   console.log data.length
  #   if data.length is 1
  #     return true
  #   if data.length > 1
  #     return false

  # _getSettings:()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or(@settings.settingsModifiedBy is 'organization')
  #       if @organization.printSettings
  #         @settings.printDecoration = @organization.printSettings      
  #   else
  #     @domHost.showModalDialog 'No Settings Found'

 
  ###
    @author Taufiq Ahmed
    @Description Show Patient's Invoice
    @created 03 APR 2017
    @updated 30 Oct 2017
  ###
  _loadInvoice: (patientSerialIdentifier, organizationIdentifier)->

    data = {
      patientSerial: patientSerialIdentifier
      organizationId: organizationIdentifier
      apiKey: @user.apiKey
    }
    @loadingCounter += 1
    @callApi '/bdemr--patient-invoice-get-api', data, (err, response)=>
      if response.hasError
        # @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        invoiceList = response.data
        notCompletedInvoiceList = (item for item in invoiceList when item.flags.markAsCompleted isnt true)
        @set 'invoiceList', invoiceList
        @set 'invoiceListWithoutCompleted', notCompletedInvoiceList
        # console.log 'invoice list', @invoiceList

    # previous code
    # @set 'invoiceList', []
    # @set 'invoiceListWithoutCompleted', []
    # if invoiceList.length > 0
    #   @set 'invoiceList', invoiceList
    # if notCompletedInvoiceList.length > 0
    #   @set 'invoiceListWithoutCompleted', notCompletedInvoiceList


  createNewInvoiceButtonClicked: (e)->
    @domHost.navigateToPage '#/create-invoice/invoice:new/patient:' + @patient.serial

  editInvoiceItemClicked: (e)->
    @domHost.navigateToPage '#/create-invoice/invoice:' + e.model.item.serial + '/patient:' + @patient.serial

  previewInvoiceItemClicked: (e)->
    @domHost.navigateToPage '#/print-invoice/invoice:' + e.model.item.serial + '/patient:' + @patient.serial
  
  invoiceMarkedAsCompleteButtonClicked: (e)->
    item = e.model.item
    item.flags.markAsCompleted = true
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-invoice', item, ({serial})=> item.serial is serial
    @_loadInvoice @patient.serial, @organization.idOnServer
    @$$('#invoiceMenuButton').close()
    
  flagAsErrorInvoiceItemClicked: (e)->
    @domHost.showModalPrompt 'Are you sure you want to Flag as Error?', (answer)=>
      if answer  
        item = e.model.item
        item.flags.flagAsError = true
        item.flags.markAsCompleted = !item.flags.flagAsError
        item.lastModifiedDatetimeStamp = lib.datetime.now()
        app.db.upsert 'patient-invoice', item, ({serial})=> item.serial is serial
        @_loadInvoice @patient.serial, @organization.idOnServer
        @$$('#invoiceMenuButton').close()
  
  ###
    @author Taufiq Ahmed
    @Description Add Current Investigation Name and Price to addTestToInvoice
    @created 02 APR 2017
  ###
  
  _mergeDuplicateTestWithHighestPrice: (list)->
    testNameMap = {}
    for item in list
      if item.name in testNames
        if item.name of testNameMap
          price = testNameMap[item.name]
          if item.price < price
            testNameMap[item.name] = item.price
        else
          testNameMap[item.name] = item.price
    return testNameMap
  
  addSelectedTestsToNewInvoiceButtonClicked: (e)->
    unless @selectedTestListForInvoice.length
      @domHost.showToast 'Select Some Test'
      return
    testAdviseURLPart = encodeURIComponent(JSON.stringify(@selectedTestListForInvoice))
    @domHost.navigateToPage '#/create-invoice/invoice:new' + '/patient:' + @patient.serial + '/testAdviseAdded:' + testAdviseURLPart

  goToInvoice: (e)->
    invoiceSerial =  e.model.item.data.status.invoiceSerial
    @domHost.navigateToPage '#/create-invoice/invoice:' + invoiceSerial + '/patient:' + @patient.serial
  

  # ==============================================
  # ADD TO EXISTING INVOICE
  # Deprecated for reducing complexity for user
  # by @Taufiq Ahmed
  
  # addSelectedTestsToInvoiceButtonClicked: ->
  #   unless @selectedTestListForInvoice.length
  #     @domHost.showToast 'Select Some Test'
  #     return
  #   invoice = e.model.invoice
  #   testNames = []
  #   for item in @selectedTestListForInvoice
  #     for testName in item.data.testList
  #       testNames.push testName
  #   @_addItemsToInvoice invoice, testNames, (invoiceSerial)=>
  #     @_updateAdvisedTestForInvoice invoiceSerial, ()=>
  #       @selectedTestListForInvoice = []
  #       @domHost.navigateToPage '#/create-invoice/invoice:' + invoiceSerial + '/patient:' + @patient.serial

    # el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    # el.close()
  # ======================================================
  
  advisedTestItemClicked: (e)->
    checked = e.target.checked
    item = e.model.item
    if checked
      @selectedTestListForInvoice.push item
    else
      index = (index for test, index in @selectedTestListForInvoice when item.data.serial is test.data.serial)[0]
      @selectedTestListForInvoice.splice index, 1
    # console.log @selectedTestListForInvoice


  # ================================================
  # SEND SMS
  # @author Taufiq Ahmed
  # @lastModified 31 Oct 2017
  # =================================================

  sendSmsButtonClicked: (e)->
    patientPhoneNumber = @patientPhoneNumber.split("-").join("")
    unless  patientPhoneNumber.length is 11
       @domHost.showWarningToast 'Invalid Phone Number Provided'
       return
    unless @smsBody
      @domHost.showWarningToast 'Write a message to be sent.'
      return
    
    data =
      apiKey: @getCurrentUser().apiKey
      receiverUserId: @patient.idOnServer
      phoneNumber: patientPhoneNumber
      smsBody: @smsBody

    @domHost.showModalPrompt 'SMS Sending will cost you 1.23 BDT/sms. Are you sure?', (done)=>
      if done
        @callApi '/send-individual-sms', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            @domHost.showModalDialog 'Successfuly Sent'


  # Collect Sample Modal
  showSampleClicked: (cbfn)->
    @$$('#sample-modal').toggle()
    @sampleModalDoneCallBack = cbfn

  collectSampleForAllSelectedClicked: (e)->
    selectedTestList = @_getSelectedTestListData()
    # console.log 'selectedTestList', selectedTestList
    return if selectedTestList.length is 0

    @sample = {
      id: @generateSerialForTestResutSamples(),
      type: ''
    }

    @showSampleClicked (answer)=>
      if !answer
        @sample = {
          id: ''
          type: ''
        }
        return

      _pluggable = @_preCreateResult()

      sample = @sample
      @sample = {
        id: ''
        type: ''
      }
      selectedTestList.forEach (item)=>
        # console.log(item)

        sampleObject = {
          createdByUserId: this.user.idOnServer
          createdDatetimeStamp: Date.now()
          id: sample.id
          type: sample.type
          _pluggable
        }
        item.data.sample = sampleObject
        item.data.status.sampleTaken = true
        
        data = {
          apiKey: this.user.apiKey
          advisedTestSerial: item.advisedTestSerial
          investigationSerial: item.data.serial
          sampleObject
        }
        @isLoading = true
        @callApi '/bdemr-update-advised-test-for-sample', data, (err, response)=>
          @isLoading = false
          unless response.hasError
            @domHost.showToast 'Sample Data Updated'
          @_getNonResultedTestAdvised @patient.serial, => null


  collectSampleClicked: (e)->
    { item } = e.model
    if item.data.status.sampleTaken?
      @sample = item.data.sample
      @sampleId = item.data.sample.id
      @sampleType = item.data.sample.type
    else
      @sampleId = ''
      @sampleType = ''

    @showSampleClicked (answer)=>
      if answer
        if @sampleId.trim() is '' or @sampleType.trim() is ''
          @domHost.showToast 'Provide Sample Id and Type!'
          @sample = 
            id: ''
            type: ''
          return
        else
          @sample.id = @sampleId
          @sample.type = @sampleType
        
        _pluggable = @_preCreateResult()
        sampleObject = {
          createdByUserId: this.user.idOnServer
          createdDatetimeStamp: Date.now()
          id: @sample.id
          type: @sample.type
          _pluggable
        }
        item.data.sample = sampleObject
        item.data.status.sampleTaken = true
        
        data = {
          apiKey: this.user.apiKey
          advisedTestSerial: item.advisedTestSerial
          investigationSerial: item.data.serial
          sampleObject
        }
        @isLoading = true
        @callApi '/bdemr-update-advised-test-for-sample', data, (err, response)=>
          @isLoading = false
          unless response.hasError
            @domHost.showToast 'Sample Data Updated'
          @sample = {
            id: ''
            type: ''
          }
          @_getNonResultedTestAdvised @patient.serial, => null
      else
        @sample = {
          id: ''
          type: ''
        }
        
  sampleModalClosed: (e)->
    if e.detail.confirmed
      @sampleModalDoneCallBack true
    else
      @sampleModalDoneCallBack false
    @sampleModalDoneCallBack = null

  _checkUserAccess: (accessId)->
    # console.log 'accessId', accessId
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return false

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true


  _listCovidTests: (patientIdentifier)->
    covidTestResultList = app.db.find 'covid-test-result', ({patientSerial})=> patientSerial is patientIdentifier
    covidTestResultList.sort (covidTestA, covidTestB)=>
      return -1 if covidTestA.createdDatetimeStamp > covidTestB.createdDatetimeStamp
      return 1 if covidTestA.createdDatetimeStamp < covidTestB.createdDatetimeStamp
      return 0
    @set 'covidTestResultList', covidTestResultList


  _getLatestCovidTestInfo: (covidTestResults, valuePath)->
    unless covidTestResults
      return 'N/A'
    if covidTestResults.length is 0
      return 'N/A'
    
    if valuePath is 'covidTestDate' or valuePath is 'covidTestResultDate'
      return @$formatDate covidTestResults[0]['data'][valuePath]
    return covidTestResults[0]['data'][valuePath]


}