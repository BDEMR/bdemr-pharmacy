Polymer {
  is: "page-test-results-editor"
  
  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]
  
  properties:
    selectedReportedDoctorPage:
      type: Number
      notify: true
      value: 0

    selectedCheckedByUserPage:
      type: Number
      notify: true
      value: 0

    user:
      type: Object
      notify: true
      value: {}

    patient:
      type: Object
      notify: true
      value: {}

    organization:
      type: Object
      notify: true
      value: {}

    settings:
      type: Object
      notify: true
      value: {}

    visit:
      type: Object
      notify: true
      value: {}
    
    testResultTemplateObject:
      type: Object
      value: ()-> {}

    isPatientValid:
      type: Boolean
      notify: false
      value: true

    newInvestigationTestResults:
      type: Object
      notify: true
      value: {}

    advisedTestResults:
      type: Object
      notify: true
      value: {}

    identifiedAdvisedTest:
      type: Object
      notify: true
      value: {}

    selectedInvestigationPage:
      type: Number
      notify: true
      value: 0

    selectedResultsPage:
      type: Number
      notify: true
      value: 0

    investigationList:
      type: Array
      notify: true
      value: null

    investigationSelectedIndex:
      type: Number
      value: 0

    investigationSelectedIndexForCustomField:
      type: Number
      value: 0

    selectedInvestigationObject:
      type: Object
      notify: true
      value: null

    newTestListArray:
      type: Array
      notify: true
      value: []

    machingUserAddedInstitutionList:
      type: Array
      notify: true
      value: []

    matchingFavoriteTestList:
      type: Array
      notify: true
      value: []

    matchingUserAddedReportedDoctorList:
      type: Array
      notify: true
      value: []

    matchingUserAddedCheckedByUserList:
      type: Array
      notify: true
      value: []

    customInvestigatinoTestList:
      type: Array
      notify: true
      value: []

    getSelectedChildTestList:
      type: Array
      notify: true
      value: []

    customInvestigatinTestName:
      type: String
      notify: true
      value: null

    customInvestigationObj:
      type: Object
      notify: true
      value: null

    customInvestigationTestList:
      type: Array
      notify: true
      value: []

    customInvestigationTestObj:
      type: Object
      notify: true
      value: null


    customUnitTypeValue:
      type: String
      notify: true
      value: null

    testUnitSelecttedIndex:
      type: Number
      notify: true
      value: 0

    selectedInvestigationTestList:
      type: Array
      notify: true
      value: []

    checkedTestList:
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

    currentDate:
      type: String
      notify: true
      value: ()->
        dateTime = lib.datetime.now()
        return lib.datetime.format((new Date dateTime), 'mm/dd/yyyy')

    investigationSourceDataList:
      type: Array
      notify: true
      value: []

    selectedTestResult:
      type: Object
      notify: true
      value: {}

    reportedDoctorObj:
      type: Object
      notify: true
      value: -> {}

    checkedByUserObj:
      type: Object
      notify: true
      value: -> {}


    # === Doctor Finder [START] ===

    matchingDoctorList:
      type: Array
      notify: true
      value: []

    matchingCheckedByUserList:
      type: Array
      notify: true
      value: []

    hasSearchBeenPressed:
      type: Boolean
      notify: true
      value: true

    hasSearchBeenPressedForCheckedByUser:
      type: Boolean
      notify: true
      value: true
    # === Doctor Finder [END] ===

    isDownloading:
      type: Boolean
      value: false
    
    isUploading:
      type: Boolean
      value: false
    
    rangeTypes:
      type: Array
      value: ['normal', 'high', 'low', 'positive', 'negative', 'inconclusive']


  ## Test Results - start

  _makeNewVisit: ()->
    visit =
      serial: @generateSerialForVisit()
      idOnServer: null
      source: 'local'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      doctorsPrivateNote: ''
      patientSerial: @patient.serial
      recordType: 'doctor-visit'
      doctorName: @user.name
      hospitalName: @organization.name
      hospitalId: @organization.idOnServer
      doctorSpeciality: null
      prescriptionSerial: null
      doctorNotesSerial: null
      nextVisitSerial: null
      advisedTestSerial: null
      patientStaySerial: null
      invoiceSerial: null
      historyAndPhysicalRecordSerial: null
      diagnosisSerial: null
      identifiedSymptomsSerial: null
      examinationSerial: null
      recordTitle: 'Test Results'
      vitalSerial: {
        bp: null
        hr: null
        bmi: null
        rr: null
        spo2: null
        temp: null
      }
      testResults: {
        serial: null
        name: null
        attachmentSerialList: []
      }

    return visit

  _makeReportedDoctorObject: ()->
    @reportedDoctorObj =
      reportedDoctorSerial: @user.serial
      reportedDoctorName: @user.name
      showOnPrintPreview: true
      reportedDoctorSpeciality: @getDoctorSpeciality()

  _makeCheckedByObject: ()->
    @checkedByUserObj =
      checkedByUserSerial: @user.serial
      checkedByUserName: @user.name
      showOnPrintPreview: true
      checkedByUserSpeciality: @getDoctorSpeciality()

  _makeNewFavoriteTest: ()->
    @favoriteTestObj =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      testName: ''

  _makeNewSelectedInvestigation: ()->
    @selectedInvestigationObject =
      name: null
      investigationList: []
      

  _makeNewCustomInvestigation: ()->
    @customInvestigationObj =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      data:
        name: ''
        unitList: []
        referenceRange: ''


  _makeNewUserAddedInstitution: ()->
    @userAddedInsitutionObj =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      visitSerial: @visit.serial
      patientSerial: @patient.serial
      data:
        institutionName: ''

  _getInstitutionName:()->

    list = app.db.find 'settings'
  
    unless list.length is 0
      @settings = list[0]
      if @settings.institutionName
        return @settings.institutionName
      else
        return ''

    return ''

  _getFullName:(data)->

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
      
  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle
    return ''




  _investigationSelectedIndexChanged: ()->

    return if @investigationSelectedIndex is null

    @_makeNewSelectedInvestigation()

    @set 'checkedTestList', []


    @set 'selectedInvestigationObject.name', @investigationList[@investigationSelectedIndex].name
   
    for item in @investigationList[@investigationSelectedIndex].investigationList
      itemObject = {
        name: item.name
        referenceRange: item.referenceRange
        unitList: item.unitList
        isChecked: false
      }

      @push 'selectedInvestigationObject.investigationList', itemObject




  # _addUserAddedNewInstitutionBtnPressed: (e) ->
  #   unless @userAddedInsitutionObj.data.institutionName is ''
  #     @userAddedInsitutionObj.serial = @generateSerialForUserAddedInstituion()
  #     @userAddedInsitutionObj.createdDatetimeStamp = lib.datetime.now()
  #     @userAddedInsitutionObj.lastModifiedDatetimeStamp = lib.datetime.now()
  #     app.db.upsert 'user-added-institution-list', @userAddedInsitutionObj, ({serial})=> @userAddedInsitutionObj.serial is serial
  #     @domHost.showToast 'Institution Added!.'

  #     @_makeNewUserAddedInstitution()

  #     @_listUserAddedInstitution(@user.serial)

  # _listUserAddedInstitution: (userIdentifier) ->

  #   list = app.db.find 'user-added-institution-list', ({createdByUserSerial})=> userIdentifier is createdByUserSerial

  #   institutionList = [].concat list
  #   institutionList.sort (left, right)->
  #     return -1 if left.createdDatetimeStamp < right.createdDatetimeStamp
  #     return 1 if left.createdDatetimeStamp > right.createdDatetimeStamp
  #     return 0


  #   @machingUserAddedInstitutionList = institutionList


  loadInvestigationList: (userIdentifier)->
    console.log @investigationList
    
    # Pushed User Added Custom Investigation on Investigation List 
    customInvestigationlist = app.db.find 'custom-investigation-list', ({createdByUserSerial})=> userIdentifier is createdByUserSerial

    for investigationCategory, index in @investigationList
      if investigationCategory.name is 'custom'
        @push "investigationList.#{index}.investigationList", customInvestigationlist


    @investigationList.sort (left, right)->
      return -1 if left.name < right.name
      return 1 if left.name > right.name
      return 0


    for itemObject in @investigationList

      unless typeof itemObject.investigationList is 'undefined'
        unless itemObject.investigationList.length is 0
          for item in itemObject.investigationList
            if typeof item.name is 'string'

              object = {
                text: item.name,
                value: item
              }

              @push "investigationSourceDataList", object

    console.log @investigationSourceDataList


  investigationItemAutocompleteSelected: (e)->
    investigationObject = e.detail.value
    console.log investigationObject

    testObject = {
      datePerform: lib.datetime.mkDate new Date
      testName: investigationObject.name
      institutionName: @organization.name
      institutionId: @organization.idOnServer
      testResult: null
      testUnit: null
      testUnitList: investigationObject.unitList
      unitSelectedIndex: 0
      checkedTestIndex: 0
      reportedDoctorSerial: null
      reportedDoctorName: null
      reportedDoctorSpeciality: null
      reportedDoctorSelectedIndex: 0
      checkedByUserSerial: null
      checkedByUserName: null
      checkedByUserSpeciality: null
      checkedByUserSelectedIndex: 0
      referenceRange: investigationObject.referenceRange
    }

    @set 'checkedTestList', []

    @push 'checkedTestList', testObject

    
    @set 'newInvestigationTestResults.investigationName', investigationObject.name
    @set 'selectedInvestigationTestList', []
    @selectedInvestigationTestList = @checkedTestList

    
    @.$.investigationSearchInput.clear()


  _addInvestigationButtonPressed: (e)->

    # console.log @checkedTestList

    if @checkedTestList.length is 0
      @domHost.showToast 'Please Select One Test Atleast!'
      return

    else
      getNewTestInvestigatioName = @investigationList[@investigationSelectedIndex].name
      @set 'newInvestigationTestResults.investigationName', getNewTestInvestigatioName
      @set 'selectedInvestigationTestList', []
      @selectedInvestigationTestList = @checkedTestList
      # console.log 'selectedInvestigationTestList', @selectedInvestigationTestList

    

  tempButtonClearSelectedInvestigationList: (e)->
    @set 'selectedInvestigationTestList', []
    

  InvestigationItemCheckboxChanged: (e)->

    el = @locateParentNode e.target, 'PAPER-CHECKBOX'

    repeater = @$$ '#investigation-list-repeater'
    index = repeater.indexForElement el


    if e.target.checked

      testObject = {
        datePerform: lib.datetime.mkDate new Date
        testName: @selectedInvestigationObject.investigationList[index].name
        institutionName: @organization.name
        institutionId: @organization.idOnServer
        testResult: null
        testUnit: null
        testUnitList: @selectedInvestigationObject.investigationList[index].unitList
        unitSelectedIndex: 0
        checkedTestIndex: index
        reportedDoctorSerial: null
        reportedDoctorName: null
        reportedDoctorSpeciality: null
        reportedDoctorSelectedIndex: 0
        checkedByUserSerial: null
        checkedByUserName: null
        checkedByUserSpeciality: null
        checkedByUserSelectedIndex: 0        
        referenceRange: @selectedInvestigationObject.investigationList[index].referenceRange
      }

      @push 'checkedTestList', testObject

      # console.log 'Added:', @checkedTestList

    else
      for test in @checkedTestList
        if test.checkedTestIndex is index
          # console.log test.checkedTestIndex

          for checkedTest, checkedTestIndex in @checkedTestList
            if @selectedInvestigationObject.investigationList[index].name is checkedTest.testName
              @splice 'checkedTestList', checkedTestIndex, 1
              # console.log 'removed', @checkedTestList
              return

    






  _onAddNewUnitButtonClicked:(e)->
    @push 'customInvestigationTestObj.unitList', @customUnitTypeValue
    @set 'customUnitTypeValue', null 

  _onDeleteUnitButtonPressed: (e)->
    index = e.model.index
    @splice 'customInvestigationTestObj.unitList', index, 1

  _onAddNewTestButtonClicked: (e)->
    @push 'customInvestigationTestList', @customInvestigationTestObj
    @set 'customInvestigationTestObj', []

  _testUnitSelecttedIndexChanged: (e)->

    selectedTestIndex = e.model.index

    selectedUnitIndex = @selectedInvestigationTestList[selectedTestIndex].unitSelectedIndex

    unitName  = @selectedInvestigationTestList[selectedTestIndex].testUnitList[selectedUnitIndex]


    @selectedInvestigationTestList[selectedTestIndex].testUnit = unitName

    # console.log @selectedInvestigationTestList


  _advisedTestUnitSelecttedIndexChanged: (e)->

    selectedTestIndex = e.model.index

    selectedUnitIndex = @advisedTestResults.data.testList[selectedTestIndex].unitSelectedIndex


    unitName  = @advisedTestResults.data.testList[selectedTestIndex].testUnitList[selectedUnitIndex]

    # console.log unitName


    @advisedTestResults.data.testList[selectedTestIndex].testUnit = unitName

    # console.log @advisedTestResults




  _addNewCustomInvestigationBtnPressed: (e)->
    if @customInvestigationObj.data.name is ''
      @domHost.showToast 'Please Type Investigation Name First!'
    else 
      @customInvestigationObj.serial = @generateSerialForCustomInvestigation
      @customInvestigationObj.createdDatetimeStamp = lib.datetime.now()
      @customInvestigationObj.lastModifiedDatetimeStamp = lib.datetime.now()

      @_saveCustomInvestigation @customInvestigationObj

      testObject = {
        datePerform: lib.datetime.mkDate new Date
        testName: @customInvestigationObj.data.name
        institutionName: @organization.name
        institutionId: @organization.idOnServer
        testResult: null
        testUnit: null
        testUnitList: @customInvestigationObj.data.unitList
        unitSelectedIndex: 0
        checkedTestIndex: 0
        reportedDoctorSerial: null
        reportedDoctorName: null
        reportedDoctorSpeciality: null
        reportedDoctorSelectedIndex: 0
        checkedByUserSerial: null
        checkedByUserName: null
        checkedByUserSpeciality: null
        checkedByUserSelectedIndex: 0        
        referenceRange: @customInvestigationObj.data.referenceRange
      }

      @set 'checkedTestList', []

      @push 'checkedTestList', testObject

      
      @set 'newInvestigationTestResults.investigationName', @customInvestigationObj.data.name
      @set 'selectedInvestigationTestList', []
      @selectedInvestigationTestList = @checkedTestList


      # @loadInvestigationList @user.serial

  _saveCustomInvestigation: (data)->
    app.db.upsert 'custom-investigation-list', data, ({serial})=> data.serial is serial

    # console.log app.db.find 'custom-investigation-list'
    


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @showModal 'Invalid Patient Provided'

  _returnSerial: (index)->
    index+1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mm-d-yyyy')


  _makeNewInvestigationTestResults: ->

    @newInvestigationTestResults =
      serial: @generateSerialForTestResuts()
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      hospitalId: @organization.idOnServer
      hospitalName: @organization.name
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      advisedTestSerial: null
      investigationSerial: null
      investigationName: ''
      attachmentSerialList: []
      advisedDoctorSerial: null
      advisedDoctorName: null
      advisedDoctorSpeciality: null
      availableToPatient: false
      data:
        testList: []
        status: null
        flags:
          flagAsError: false

    @set 'selectedInvestigationTestList', []


  _loadTestResults: (testIdentifier)->
    list = app.db.find 'patient-test-results', ({serial})-> serial is testIdentifier
 
    if list.length is 1
      @isTestValid = true
      @testResultObjectList = list
      console.log 'advisedTestResults', @advisedTestResults
      # @visit.doctorName = @advisedTestResults.advisedDoctorName
      # @visit.doctorSpeciality = @advisedTestResults.advisedDoctorSpeciality

      # console.log @visit
      return true
    else
      @_notifyInvalidTest()
      return false

    

  cancelButtonClicked: (e)->
    @arrowBackButtonPressed()

  deleteUnsavedAdvisedTestResults: (data)->
    id = (app.db.find 'patient-test-results', ({serial})-> serial is data.serial)[0]._id
    app.db.remove 'patient-test-results', id


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
    

  _notifyInvalidTest:() ->
    @isTestValid = false
    @domHost.showModalDialog 'Invalid Test Provided!'

  _notifyInvalidPatient:() ->
    @isPatientValid= false
    @domHost.showModalDialog 'Invalid Patient Provided!'


  addTestsForAdvsiedTestButtonClicked: (e)->

    console.log @advisedTestResults

    @visit.serial = @generateSerialForVisit()

    
    ##TODO - Validation message
    for test in @advisedTestResults.data.testList
      if !test.testResult
        @domHost.showToast 'Please Enter All Test Results First!'
        return false

    fn = =>
      @visit.testResults.serial = @advisedTestResults.serial
      @visit.testResults.name = @advisedTestResults.investigationName
      @visit.recordTitle = @advisedTestResults.investigationName
      @visit.testResults.attachmentSerialList = @advisedTestResults.attachmentSerialList

      @advisedTestResults.lastModifiedDatetimeStamp = lib.datetime.now()
      @advisedTestResults.createdDatetimeStamp = lib.datetime.now()
    
      @_saveTestResults @advisedTestResults

      @_updateAdvisedTestForResultedTests @advisedTestResults.advisedTestSerial, @advisedTestResults.investigationSerial, @advisedTestResults.serial
        

      # @visit.doctorSerial = @identifiedAdvisedTest.doctorSerial
      # @visit.doctorName = @identifiedAdvisedTest.doctorName
      # @visit.doctorSpeciality = @identifiedAdvisedTest.doctorSpeciality
      @visit.hospitalName = @identifiedAdvisedTest.hospitalName

      @_saveVisit()

      console.log @advisedTestResults

      @domHost.showToast 'Record Updated!'
      @arrowBackButtonPressed()

    this._spendUploadCoin (err)=>
      if (err)       
        @domHost.showModalPrompt (err.error.message + ". Charge the patient?"), (answer)=>
          if answer
            this._chargePatient @patient.idOnServer, 5, 'Payment BDEMR Clinic Generic', (err)=>
              if (err)
                @domHost.showModalDialog("Unable to charge the patient. The patient does not have sufficient balance.")
                return
              fn()
      else
        fn()        

  _updateAdvisedTestForResultedTests: (advisedTestIdentifier, investigationSerial, testResultsSerial)->
    list = app.db.find 'visit-advised-test', ({serial})-> serial is advisedTestIdentifier
    if list.length is 1
      @identifiedAdvisedTest = list[0]
      for investigation, investigationIndex in @identifiedAdvisedTest.data.testAdvisedList
        if investigation.serial is investigationSerial
          @identifiedAdvisedTest.data.testAdvisedList[investigationIndex].status.hasTestResults = true
          @identifiedAdvisedTest.data.testAdvisedList[investigationIndex].status.testResultsSerial = testResultsSerial

          @identifiedAdvisedTest.lastModifiedDatetimeStamp = lib.datetime.now()
          
          app.db.upsert 'visit-advised-test', @identifiedAdvisedTest, ({serial})=> @identifiedAdvisedTest.serial is serial
      return true

    else
      # @domHost.showToast 'Warning! No Advised Test Found!'
      return false





  addNewTestResultsButtonClicked: ->
    # console.log @newInvestigationTestResults

    @newInvestigationTestResults.data.testList = @selectedInvestigationTestList

    # console.log @newInvestigationTestResults.data.testList.length

    # TODO - Validation message
    if @newInvestigationTestResults.data.testList.length is 0
      @domHost.showToast 'Please Select An Investigation!'
      return

    else
      for test in @newInvestigationTestResults.data.testList
        unless test.testResult
          @domHost.showToast 'Please Enter All Data!'
          return


    ##TODO
    @visit.serial = @generateSerialForVisit()

    @newInvestigationTestResults.lastModifiedDatetimeStamp = lib.datetime.now()
    @newInvestigationTestResults.createdDatetimeStamp = lib.datetime.now()
    @newInvestigationTestResults.visitSerial = @visit.serial

  
    @visit.testResults.serial = @newInvestigationTestResults.serial
    @visit.testResults.name = @newInvestigationTestResults.investigationName
    @visit.recordTitle = @newInvestigationTestResults.investigationName
    @visit.testResults.attachmentSerialList = @newInvestigationTestResults.attachmentSerialList

    console.log @visit

    @_saveVisit()
    @_saveTestResults @newInvestigationTestResults

    @domHost.showToast 'Added Successfully'
    @_makeNewInvestigationTestResults()
    @arrowBackButtonPressed()


  getTestResultsSerial:()->
    return @advisedTestResults.serial

  _pushAttachmentData: (data)->
    path = 'testResultObjectList.' + @ARBITARY_INDEX_1 + '.attachmentSerialList'
    @push path, data.serial


  getTempTestResultsData: ()->
    testResultObjectList = localStorage.getItem("testResultObjectList", testResultObjectList)
    testResultObjectList = JSON.parse(testResultObjectList)
    if testResultObjectList.length is 0
      @_notifyInvalidTest()
    else
      @set 'testResultObjectList', testResultObjectList

    console.log 'test Result Object', @testResultObjectList

  showReportedDoctorDialog: (e)->
    # @ARBITARY_INDEX_1 = e.model.index
    # console.log 'ARBITARY_INDEX_1', @ARBITARY_INDEX_1
    @$$('#dialogReportedDoctor').toggle()
    @$$('#dialogReportedDoctor').center()

  showCheckedByUserDialog: (e)->
    @$$('#dialogCheckedByUser').toggle()
    @$$('#dialogCheckedByUser').center()

  showRefRangeDialog: (e) ->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#test-result-list-repeater'
    @ARBITARY_INDEX_1 = repeater.indexForElement el
    @ARBITARY_INDEX_2 = e.model.index

    console.log 'ARBITARY_INDEX_1', @ARBITARY_INDEX_1
    console.log 'ARBITARY_INDEX_2', @ARBITARY_INDEX_2

    @referenceRangeValue = @testResultObjectList[@ARBITARY_INDEX_1].data.testList[@ARBITARY_INDEX_2].referenceRange

    @$$('#dialogReferenceRange').toggle()

  updateTestRefRange: (e)->
    path = "testResultObjectList." + @ARBITARY_INDEX_1 + ".data.testList." + @ARBITARY_INDEX_2 + ".referenceRange"
    @set path, @referenceRangeValue
    @$$('#dialogReferenceRange').close()
    

  changeTestDate: ()->



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

  addReportedDoctorDetailsOnTestResultObject: (object, cbfn)->
    object.reportedDoctorName = @reportedDoctorObj.reportedDoctorName
    object.reportedDoctorSerial = @reportedDoctorObj.reportedDoctorSerial
    object.reportedDoctorSpeciality = @reportedDoctorObj.reportedDoctorSpeciality
    object.showReportedByUserNameOnPrintPreview = @reportedDoctorObj.showOnPrintPreview
    cbfn object
    return

  addCheckedByUserDetailsOnTestResultObject: (object, cbfn)->
    object.checkedByUserName = @checkedByUserObj.checkedByUserName
    object.checkedByUserSerial = @checkedByUserObj.checkedByUserSerial
    object.checkedByUserSpeciality = @checkedByUserObj.checkedByUserSpeciality
    object.showCheckedByUserNameOnPrintPreview = @checkedByUserObj.showOnPrintPreview
    cbfn object
    return

  saveButtonPressed: (e)->
    @testResultTemplateObject.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-template-record', @testResultTemplateObject, ({serial})=> @testResultTemplateObject.serial is serial

    counter = 0
    # return console.log 'testResultObjectList', @testResultObjectList
    testResultObjectList = @testResultObjectList

    it1 = new lib.util.Iterator testResultObjectList
    it1.forEach (next, index, result)=>
      counter++
      result.lastModifiedDatetimeStamp = lib.datetime.now()
      @addReportedDoctorDetailsOnTestResultObject result, (modifiedTestResult)=>
        @addCheckedByUserDetailsOnTestResultObject result, (modifiedTestResult)=>
          @_createVisitRecordForTestResult modifiedTestResult, (visitObject)=>
            # @_callAddTestResultApi modifiedTestResult, visitObject, =>
            @_saveNewTestResults modifiedTestResult, =>
              @_saveVisit visitObject
              @_updateAdvisedTestForTestResults modifiedTestResult, =>
                next()
    it1.finally =>
      @domHost.showToast counter + ' Results Saved!'
      @arrowBackButtonPressed()
                


  _callAddTestResultApi: (testResultObject, visitObject, cbfn)->
    data = {
      testResultObject: testResultObject
      visitObject: visitObject
      apiKey: @user.apiKey
    }

    console.log 'test result', data

    @callApi '/bdemr-add-test-results', data, (err, response)=>
      console.log response
      if response.hasError
        console.log response.error.message
      else
        console.log response

      cbfn()

  _saveNewTestResults: (data, cbfn)->
    data.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-test-results', data, ({serial})=> data.serial is serial
    cbfn()


  _createVisitRecordForTestResult: (testResultObject, cbfn)->
    visitRecord = @_makeNewVisit()

    visitRecord.testResults.serial = testResultObject.serial
    visitRecord.testResults.name = testResultObject.investigationName

    visitRecord.recordTitle = testResultObject.investigationName
    
    #to do
    visitRecord.testResults.attachmentSerialList = testResultObject.attachmentSerialList
    ##

    cbfn visitRecord
    return 

    # @_saveVisit visitRecord

  _saveVisit: (data)->
    data.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'doctor-visit', data, ({serial})=> data.serial is serial


  _updateAdvisedTestForTestResults: (object, cbfn)->
    console.log object
    data = {
      advisedTestSerial: object.advisedTestSerial
      testResultSerial: object.serial
      investigationSerial: object.investigationSerial
      userId: @user.idOnServer
      apiKey: @user.apiKey
    }

    @callApi '/bdemr-update-advised-test-for-test-result', data, (err, response)=>

      # if response.hasError
      #   @domHost.showModalDialog response.error.message
      #   console.log response
      # else
        
      cbfn()



  showAttachmentDialog: (e)->
    @ARBITARY_INDEX_1 = e.model.index
    @selectedTestResult = {}
    @selectedTestResult = @testResultObjectList[@ARBITARY_INDEX_1]
    body = document.querySelector('body')
    @domHost.appendChild(@$.dialogAttachement);

    @_loadAttachmentList @selectedTestResult.serial

    @_openLocalDataUriDb()
    @_makeBlankAttachment()
    @_updateSpaceCalculation()

    @set "newAttachment.title", @testResultObjectList[@ARBITARY_INDEX_1].investigationName

    @$$("#dialogAttachement").toggle()
    @$$("#dialogAttachement").center()

  tempSaveTestResults: ()->
    localStorage.setItem("testResultObjectList", JSON.stringify @testResultObjectList)

  updateAdvisdTest: (identifiedobject)->

  _getUploadCoinCount: ->
    data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    }
    # console.log(data)
    @callApi '/bdemr-organization-get-upload-coin-count', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        this.uploadCoin = parseInt(response.data)

  _addRange: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#test-result-list-repeater'
    investigationIndex = repeater.indexForElement el
    testIndex = e.model.index
    path = "testResultObjectList.#{investigationIndex}.data.testList.#{testIndex}.resultRanges"
    console.log path
    @push path, {
      label: ''
      value: ''
    }




  # psedo lifecycle callback
  navigatedIn: ()->
    returningFromOTEditor = JSON.parse localStorage.getItem 'returning_from_generic_editor'
    localStorage.removeItem 'returning_from_generic_editor'

    updatedTemplateContent = JSON.parse localStorage.getItem 'updated_template_content'
    localStorage.removeItem 'updated_template_content'

    if returningFromOTEditor
      @set 'testResultTemplateObject.data.templateContent', updatedTemplateContent
    else
      params = @domHost.getPageParams()
      @_loadUser()
      @_loadUserAddedReportedDoctorList @user.serial
      @_loadUserAddedCheckedByList @user.serial
      # @_getSettings()
      if params['patient']
        @_loadPatient params['patient']
      else
        @_notifyInvalidPatient()

      @_loadOrganization()
      this._getUploadCoinCount()
      @_loadWallet =>
        this.uploadCoinsToPurchase = 0
        price = 5
        this.uploadCoinsMaximumPurchaseable = Math.floor (this.walletBalance / price)
      
      unless params['test-results']
        @_notifyInvalidTest()
        return
      
      if params['test-results']
        if params['test-results'] is 'multi'
          @getTempTestResultsData()
        else
          @_loadTestResults params['test-results']
          @_loadAttachmentList params['test-results']
        
      # Load Data --------------->
      # @domHost.getStaticData 'investigationList', (investigationList)=>
      #   @investigationList = investigationList
      #   @loadInvestigationList @user.serial
      @_makeReportedDoctorObject()
      @_makeCheckedByObject()
      @_makeNewFavoriteTest()
      @_makeNewSelectedInvestigation()
      @_makeNewCustomInvestigation()
      # @_makeNewUserAddedInstitution()
      # @_openLocalDataUriDb()
      # @_makeBlankAttachment()
      # @_updateSpaceCalculation()
      @_makeTestResultTemplateObject()
    



  _clearWhenLeaving: ()->
    @user = {}
    @patient = {}
    @isTestValid = false
    @isPatientValid = false
    @advisedTestIdentifier = {}
    @newInvestigationTestResults = {}
    @attachmentList = []
  

  navigatedOut: ->
    toGenericTemplate = JSON.parse localStorage.getItem 'to_generic_template'
    localStorage.removeItem 'to_generic_template'
    unless toGenericTemplate
      @_clearWhenLeaving()

  _isEmptyString: (data)->
    if data is null or data is 'undefined' or data is ''
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data is 0
      return true
    else
      return false


  _makeTestResultTemplateObject: ()->
    @testResultTemplateObject = {
      serial: @generateSerialForOtTemplate()
      testResultSerial: null
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      patientSerial: @patient.serial
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      templateCreatedFrom: 'clinic-app-test-result'
      data: {
        templateName: ''
        templateContent: ''
      }
      sendToPatient: false

    }

  # Gallary [START]
  # ================================

  _updateSpaceCalculation: ->
    if @localDataUriDb
      taken = @localDataUriDb.computeTotalSpaceTaken()
      used = 1 - ((@maximumLocalDataUriDbSizeInChars - taken) / @maximumLocalDataUriDbSizeInChars)
      @localDataUsedPercentage = Math.floor ((used) * 100)

  _openLocalDataUriDb: ->

    localDataUriDb = new lib.DatabaseEngine {
      name: 'local-data-uri-db'
      storageEngine: lib.localStorage
      serializationEngine: lib.json
      config:
        commitDelay: 0
    }

    localDataUriDb.initializeDatabase { removeExisting: false }

    localDataUriDb.defineCollection {
      name: 'local-attachment'
    }

    @localDataUriDb = localDataUriDb

    sessionDataUriDb = new lib.DatabaseEngine {
      name: 'session-data-uri-db'
      storageEngine: lib.tabStorage
      serializationEngine: lib.json
      config:
        commitDelay: 0
    }

    sessionDataUriDb.initializeDatabase { removeExisting: false }

    sessionDataUriDb.defineCollection {
      name: 'local-attachment'
    }

    @sessionDataUriDb = sessionDataUriDb

  
  
  _makeBlankAttachment: ->
    @set 'newAttachment', {
      title: ''
      description: ''
      dataUri: ''
      originalName: null 
      originalType: null
      sizeInBytes: 0
      sizeInChars: 0
      isImage: false
      isLoaded: false
      progress: 0
    }

  _loadAttachmentList: (testResultsIdentifier)->

    localAttachmentList = app.db.find 'patient-gallery--local-attachment', ({testResultsSerial})-> testResultsSerial is testResultsIdentifier
    @set 'attachmentList', localAttachmentList

    onlineAttachmentList = app.db.find 'patient-gallery--online-attachment', ({testResultsSerial})-> testResultsSerial is testResultsIdentifier
    console.log testResultsIdentifier
    if onlineAttachmentList.length
      @set 'isDownloading', true
    lib.util.iterate onlineAttachmentList, (next, index, item)=>
      @callApi 'bdemr/get-uploaded-file', {attachmentId: item.data.attachmentId}, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          
          @push 'attachmentList', response.data
          next()
    .finally =>
      @set 'isDownloading', false
      @$$("#dialogAttachement").center()
    

  _saveAttachment: (attachment)->
    app.db.upsert 'patient-gallery--local-attachment', attachment, ({serial})=> attachment.serial is serial
  

    

  $toMega: (value)-> (Math.ceil ((value / 1000 / 1000) * 100)) / 100

  $getImageSrc: (attachment)->
    if attachment.mainStorage is 'local'
      list = @localDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial
      if list.length > 0
        return list[0].dataUri
      else
        return 'assets/not-found.png'
    else if attachment.mainStorage is 'server'
      return attachment.dataURI
    else if attachment.mainStorage is 'session'
      list = @sessionDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial
      if list.length > 0
        return list[0].dataUri
      else
        return 'assets/not-found.png'


  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog "Please provide a file less than #{Math.floor(@maximumImageSizeAllowedInBytes / 1000 / 1000)}mb in size."
      return

    reader.readAsDataURL file

    reader.onprogress = (e)=>
      console.log 'onprogress'
      @set 'newAttachment.progress', ((e.loaded / e.total) * 100)

    reader.onload = =>
      console.log 'onload'
      dataUri = reader.result
      @set 'newAttachment.isImage', file.type.indexOf('image/') > -1

      @set 'newAttachment.sizeInBytes', file.size
      # @set 'newAttachment.title', file.name
      @set 'newAttachment.dataUri', dataUri
      @set 'newAttachment.originalType',  file.type
      @set 'newAttachment.originalName', file.name
      @set 'newAttachment.sizeInChars', dataUri.length
      
      @set 'newAttachment.isLoaded', true

      @$$("#dialogAttachement").center()

  _prepareAtachment: (testResultSerial) ->
    { 
      description
      dataUri
      isImage
      title
      originalName
      originalType
      sizeInBytes
      sizeInChars
    } = @newAttachment

    attachment = {
      serial: @generateSerialForAttachmentBlob()
      attSyncSerial: @generateSerialForAttachmentSync()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      mainStorage: null # could be 'server' or 'local' or 'session'
      title
      description
      # dataUri
      isImage
      originalName
      originalType
      sizeInBytes
      sizeInChars
      organizationId: @organization.idOnServer
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      belongToPatientSerial: @patient.serial
      testResultSerial: testResultSerial
    }

    return attachment

  uploadPressed: (e)->

    testResultSerial = @testResultObjectList[@ARBITARY_INDEX_1].serial

    attachment = @_prepareAtachment testResultSerial
    attachment.mainStorage = 'server'
    attachment.apiKey = (app.db.find 'user')[0].apiKey
    attachment.dataURI = @newAttachment.dataUri
    @set 'isUploading', true
    @callApi 'bdemr/file-uploader', attachment, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        attachment._id = response.data.attachmentId
        @push 'attachmentList', attachment

        @$$("#dialogAttachement").center()
        @_pushAttachmentData attachment
        # following syncable object signature
        onlineAttachment = 
          serial: attachment.attSyncSerial
          createdDatetimeStamp: 0
          lastModifiedDatetimeStamp: attachment.lastModifiedDatetimeStamp
          lastSyncedDatetimeStamp: 0
          patientSerial: @patient.serial
          testResultsSerial: @selectedTestResult.serial
          data:
            attachmentId: response.data.attachmentId

        console.log onlineAttachment
        
        # Saving the attachment ref
        app.db.upsert 'patient-gallery--online-attachment', onlineAttachment, ({serial})=> serial is onlineAttachment.serial
        @set 'isUploading', false
        @domHost._syncOnlyPatientGallery ()=>
          @_makeBlankAttachment()
          @tempSaveTestResults()


  saveLocallyPressed: (e)->
    attachment = @_prepareAtachment()
    attachment.mainStorage = 'local' 

    uploadData = {
      attachmentSerial: attachment.serial
      dataUri: @newAttachment.dataUri
    }

    currentSize = @localDataUriDb.computeTotalSpaceTaken()
    maxSize = @maximumLocalDataUriDbSizeInChars
    sizeLeft = maxSize - currentSize
    sizeNeededForThisAttachment = (JSON.stringify uploadData).length

    if sizeLeft < sizeNeededForThisAttachment
      extraNeeded = sizeNeededForThisAttachment - sizeLeft
      message = "Sorry. Can not save image. Your browser needs #{@$toMega(extraNeeded)}MB additional storage."
      @domHost.showModalDialog message
    else
      @localDataUriDb.insert 'local-attachment', uploadData
      @push 'attachmentList', attachment
      @$$("#dialogAttachement").center()
      @_saveAttachment attachment
      @_makeBlankAttachment()
      @_updateSpaceCalculation()
  
  keepUntilBrowserClosedPressed: (e)->
    attachment = @_prepareAtachment()
    attachment.mainStorage = 'session' 

    uploadData = {
      attachmentSerial: attachment.serial
      dataUri: @newAttachment.dataUri
    }

    currentSize = @sessionDataUriDb.computeTotalSpaceTaken()
    maxSize = 50 * 1000 * 1000
    sizeLeft = maxSize - currentSize
    
    sizeNeededForThisAttachment = (JSON.stringify uploadData).length

    if sizeLeft < sizeNeededForThisAttachment
      extraNeeded = sizeNeededForThisAttachment - sizeLeft
      message = "Sorry. Can not save image. Your browser needs #{@$toMega(extraNeeded)}MB additional storage."
      @domHost.showModalDialog message
    else
      try
        @sessionDataUriDb.insert 'local-attachment', uploadData  
        @push 'attachmentList', attachment
        @$$("#dialogAttachement").center()
        @_makeBlankAttachment()
      catch e
        message = "Sorry. Can not save image. Your browser do not have enough memory."
        @domHost.showModalDialog message

  deletePressed: (e)->
    { attachmentIndex, attachment } = e.model
    if attachment.mainStorage is 'local'
      attachmentData = (@localDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial)
      if attachmentData.length > 0
        @localDataUriDb.remove 'local-attachment', attachmentData[0]._id
      app.db.remove 'patient-gallery--local-attachment', attachment._id
      @splice 'attachmentList', attachmentIndex, 1
      @_updateSpaceCalculation()
    else if attachment.mainStorage is 'session'
      attachmentData = (@sessionDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial)
      if attachmentData.length > 0
        @sessionDataUriDb.remove 'local-attachment', attachmentData[0]._id
      app.db.remove 'patient-gallery--local-attachment', attachment._id
      @splice 'attachmentList', attachmentIndex, 1
    else
      @callApi 'bdemr/delete-uploaded-file', {attachmentId: attachment._id}, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          attachmentData = (app.db.find 'patient-gallery--online-attachment', ({serial})-> serial is attachment.attSyncSerial)
          if attachmentData.length > 0
            app.db.remove 'patient-gallery--online-attachment', attachmentData[0]._id
            @splice 'attachmentList', attachmentIndex, 1
            app.db.insert 'patient-gallery--online-attachment--deleted', { serial: attachmentData[0].serial }


  downloadPressed: (e)->
    attachment = e.model.attachment
    src = @$getImageSrc attachment

    if (src.indexOf 'data:') is 0
      blob = dataURItoBlob src
      objectURL = window.URL.createObjectURL blob, { type: attachment.originalType }
    else
      objectURL = src

    identifier = attachment.originalName
    a = window.document.createElement 'a'
    a.href = objectURL
    a.target = '_blank'
    a.download = identifier
    document.body.appendChild a
    a.click()
    document.body.removeChild a

  # === Gallary [END] ===


  # === User Added Reported Doctor [START] ===

  addFundsTapped: (e)->
    this.addBalanceTapped(e)

  getMoreUploadCoinTapped: (e)->
    count = parseInt(this.uploadCoinsToPurchase)
    max = parseInt(this.uploadCoinsMaximumPurchaseable)
    price = 5

    if (count > max)
      this.domHost.showModalDialog("You do not have enough balance to purchase this many coins.")
      return

    this._chargeUser (count * price), 'Payment BDEMR Doctor Generic', (err)=>
      if (err)
        @domHost.showModalDialog("You do not have sufficient balance.")
        return

      data = {
        apiKey: this.user.apiKey,
        organizationId: this.organization.idOnServer
        count: count
      }

      @callApi '/bdemr-organization-purchase-upload-coin', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          window.location.reload()

  _spendUploadCoin:(cbfn)->
    data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
      count: 1
    }

    @callApi '/bdemr-organization-spend-upload-coin', data, (err, response)=>
      if response.hasError
        cbfn(response)
      else
        cbfn()

  _loadOrganization: ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      # unless 'uploadCoin' of organizationList[0]
      #   organizationList[0].uploadCoin = 0
      @set 'organization', organizationList[0]


  _loadUserAddedReportedDoctorList: (userIdentifier)->

    list = app.db.find 'user-added-reported-doctor-list', ({createdByUserSerial})-> createdByUserSerial is userIdentifier

    list.sort (left, right)->
      return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
      return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
      return 0

    @matchingUserAddedReportedDoctorList = list

    # console.log 'matchingUserAddedReportedDoctorList', @matchingUserAddedReportedDoctorList



  _onReportedDoctorItemDeleteBtnPressed: (e)->
    index = e.model.index
    item = @matchingUserAddedReportedDoctorList[index]

    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
        id = (app.db.find 'user-added-reported-doctor-list', ({serial})-> serial is item.serial)[0]._id

        app.db.remove 'user-added-reported-doctor-list', id
        app.db.insert 'user-added-reported-doctor-list--deleted', { serial: item.serial }
        # @splice 'prescribedMedicineList', index, 1
        @domHost.showToast 'Deleted!'
        @_loadUserAddedReportedDoctorList @user.serial

  _onReportedDoctorItemAddBtnPressed: (e)->
    index = e.model.index
    doctor = @matchingUserAddedReportedDoctorList[index]

    console.log doctor
    @setReportedDoctor doctor.data
    @$$('#dialogReportedDoctor').close()



  # === User Added Reported Doctor [END] ===



  # === Doctor Finder [START] ===
    

  searchOnlineButtonPressed: (e)->
    @matchingDoctorList = []
    @callApi '/bdemr-doctor-search', { apiKey: @user.apiKey, searchQuery: @searchFieldMainInput}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        matchingDoctorList = response.data
        for patient in matchingDoctorList
          patient.flags = {
            isImported: false
            isLocalOnly: false
            isOnlineOnly: false
          }
          localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.serial
          if localPatientList.length is 0
            patient.flags.isOnlineOnly = true
          else
            patient.flags.isImported = true
            patient._tempLocalDbId = localPatientList[0]._id
        @matchingDoctorList = matchingDoctorList
        # console.log @matchingDoctorList

  _onClickAddAsAdvisedDoctor: (e)->
    el = @locateParentNode e.target, 'PAPER-ITEM'
    el.opened = false
    repeater = @$$ '#doctor-list-repeater'

    index = repeater.indexForElement el
    doctorObject = @matchingDoctorList[index]

  
  setReportedDoctor: (doctor)->
    @set 'reportedDoctorObj.reportedDoctorName', doctor.name
    @set 'reportedDoctorObj.reportedDoctorSerial', doctor.serial
    if doctor.specializationList.length > 0
      @set 'reportedDoctorObj.reportedDoctorSpeciality', doctor.specializationList[0].specializationTitle
    else
      @set 'reportedDoctorObj.reportedDoctorSpeciality', ''


    # @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorName", doctor.name
    # @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSerial", doctor.serial
    # if doctor.specializationList.length > 0
    #   @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSpeciality", doctor.specializationList[0].specializationTitle
    # else
    #   @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSpeciality", ''

  _onClickAddToReportedDoctor: (e)->
    el = @locateParentNode e.target, 'PAPER-ITEM'
    el.opened = false
    repeater = @$$ '#doctor-list-repeater'
    index = repeater.indexForElement el
    doctor = @matchingDoctorList[index]

    @setReportedDoctor doctor
    @_checkForDuplicateOrSaveReportedDoctor doctor

    @domHost.showToast 'Added on Reported Doctor List.'
    @$$('#dialogReportedDoctor').close()
  
  makeNewReportedDoctorObject: (doctor)->
    object = 
      serial: @generateSerialForUserAddedReportedDoctor()
      createdByUserSerial: @user.serial
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      data: 
        serial: doctor.serial
        name: doctor.name
        specializationList: doctor.specializationList

    return object

  _checkForDuplicateOrSaveReportedDoctor: (doctor)->
    list = app.db.find 'user-added-reported-doctor-list'
    console.log list

    if list.length > 0
      for item in list
        if item.data.doctorSerial is doctor.serial
          return
        else
          @saveReportedDoctor @makeNewReportedDoctorObject doctor
    else
      @saveReportedDoctor @makeNewReportedDoctorObject doctor
    
    @_loadUserAddedReportedDoctorList @user.serial
        
  saveReportedDoctor: (data)->
    console.log "here"
    app.db.upsert 'user-added-reported-doctor-list', data, ({serial})=> data.serial is serial


  _testReportedDoctorSelectedIndexChanged: (e)->

    selectedTestIndex = e.model.index
    # console.log 'selectedTestIndex', selectedTestIndex

    selectedReportedDoctorIndex = @advisedTestResults.data.testList[selectedTestIndex].reportedDoctorSelectedIndex

    @advisedTestResults.data.testList[selectedTestIndex].reportedDoctorSerial = @matchingUserAddedReportedDoctorList[selectedReportedDoctorIndex].data.doctorSerial
    @advisedTestResults.data.testList[selectedTestIndex].reportedDoctorName = @matchingUserAddedReportedDoctorList[selectedReportedDoctorIndex].data.doctorName

    if @matchingUserAddedReportedDoctorList[selectedReportedDoctorIndex].data.specializationList.length isnt 0

      @advisedTestResults.data.testList[selectedTestIndex].reportedDoctorSpeciality = @matchingUserAddedReportedDoctorList[selectedReportedDoctorIndex].data.specializationList[0].specializationTitle
    else
      @advisedTestResults.data.testList[selectedTestIndex].reportedDoctorSpeciality = ''





  # === Doctor Finder [END] ===


  # === User Added For Checked By User [Start] ===

  _loadUserAddedCheckedByList: (userIdentifier)->

    list = app.db.find 'user-added-checked-by-user-list', ({createdByUserSerial})-> createdByUserSerial is userIdentifier

    list.sort (left, right)->
      return -1 if left.createdDatetimeStamp > right.createdDatetimeStamp
      return 1 if left.createdDatetimeStamp < right.createdDatetimeStamp
      return 0

    @matchingUserAddedCheckedByUserList = list

    # console.log 'matchingUserAddedReportedDoctorList', @matchingUserAddedReportedDoctorList



  _onCheckedByUserItemDeleteBtnPressed: (e)->
    index = e.model.index
    item = @matchingUserAddedCheckedByUserList[index]

    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
        id = (app.db.find 'user-added-checked-by-user-list', ({serial})-> serial is item.serial)[0]._id

        app.db.remove 'user-added-checked-by-user-list', id
        app.db.insert 'user-added-checked-by-user-list--deleted', { serial: item.serial }
        # @splice 'prescribedMedicineList', index, 1
        @domHost.showToast 'Deleted!'
        @_loadUserAddedCheckedByList @user.serial

  _onCheckedByUserItemAddBtnPressed: (e)->
    index = e.model.index
    checkedByUser = @matchingUserAddedCheckedByUserList[index]

    console.log checkedByUser
    @setCheckedByUser checkedByUser.data
    @$$('#dialogCheckedByUser').close()



  # === User Added For Checked By User [END] ===



  # === Doctor Finder For Checked By User  [START] ===
    

  searchForCheckedByUserOnlineButtonPressed: (e)->
    @matchingCheckedByUserList = []
    @callApi '/bdemr-doctor-search', { apiKey: @user.apiKey, searchQuery: @searchFieldForCheckedByUserMainInput}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        matchingCheckedByUserList = response.data
        for patient in matchingCheckedByUserList
          patient.flags = {
            isImported: false
            isLocalOnly: false
            isOnlineOnly: false
          }
          localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.serial
          if localPatientList.length is 0
            patient.flags.isOnlineOnly = true
          else
            patient.flags.isImported = true
            patient._tempLocalDbId = localPatientList[0]._id
        @matchingCheckedByUserList = matchingCheckedByUserList
        # console.log @matchingDoctorList

  
  setCheckedByUser: (doctor)->
    @set 'checkedByUserObj.checkedByUserName', doctor.name
    @set 'checkedByUserObj.checkedByUserSerial', doctor.serial
    if doctor.specializationList.length > 0
      @set 'checkedByUserObj.checkedByUserSpeciality', doctor.specializationList[0].specializationTitle
    else
      @set 'checkedByUserObj.checkedByUserSpeciality', ''


    # @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorName", doctor.name
    # @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSerial", doctor.serial
    # if doctor.specializationList.length > 0
    #   @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSpeciality", doctor.specializationList[0].specializationTitle
    # else
    #   @set "testResultObjectList." + @ARBITARY_INDEX_1 + ".reportedDoctorSpeciality", ''

  _onClickAddToCheckedByUser: (e)->
    el = @locateParentNode e.target, 'PAPER-ITEM'
    el.opened = false
    repeater = @$$ '#checked-by-user-list-repeater'
    index = repeater.indexForElement el
    doctor = @matchingCheckedByUserList[index]

    @setCheckedByUser doctor
    @_checkForDuplicateOrSaveCheckedByUser doctor

    @domHost.showToast 'Added on Reported Doctor List.'
    @$$('#dialogCheckedByUser').close()
  
  makeNewCheckedByUserObject: (doctor)->
    object = 
      serial: @generateSerialForUserAddedCheckedByUser()
      createdByUserSerial: @user.serial
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      data: 
        serial: doctor.serial
        name: doctor.name
        specializationList: doctor.specializationList

    return object

  _checkForDuplicateOrSaveCheckedByUser: (doctor)->
    list = app.db.find 'user-added-checked-by-user-list'
    console.log list

    if list.length > 0
      for item in list
        if item.data.doctorSerial is doctor.serial
          return
        else
          @saveCheckedByUser @makeNewCheckedByUserObject doctor
    else
      @saveCheckedByUser @makeNewCheckedByUserObject doctor
    
    @_loadUserAddedCheckedByList @user.serial
        
  saveCheckedByUser: (data)->
    console.log "here is checked by"
    app.db.upsert 'user-added-checked-by-user-list', data, ({serial})=> data.serial is serial


  _testCheckedByUserIndexChanged: (e)->

    selectedTestIndex = e.model.index
    # console.log 'selectedTestIndex', selectedTestIndex

    selectedCheckedByUserIndex = @advisedTestResults.data.testList[selectedTestIndex].checkedByUserSelectedIndex

    @advisedTestResults.data.testList[selectedTestIndex].checkedByUserSerial = @matchingUserAddedReportedDoctorList[selectedCheckedByUserIndex].data.doctorSerial
    @advisedTestResults.data.testList[selectedTestIndex].checkedByUserName = @matchingUserAddedReportedDoctorList[selectedCheckedByUserIndex].data.doctorName

    if @matchingUserAddedReportedDoctorList[selectedCheckedByUserIndex].data.specializationList.length isnt 0

      @advisedTestResults.data.testList[selectedTestIndex].checkedByUserSpeciality = @matchingUserAddedReportedDoctorList[selectedCheckedByUserIndex].data.specializationList[0].specializationTitle
    else
      @advisedTestResults.data.testList[selectedTestIndex].checkedByUserSpeciality = ''



  # === Doctor Finder For Checked By User [END] ===

  clearSearchResultsClicked: (e)->
    @matchingDoctorList = []
    @matchingCheckedByUserList = []

  testResultsAvailableToPatientCheckBoxChanged: (e)->
    if e.target.checked
      @advisedTestResults.availableToPatient = true
    else
      @advisedTestResults.availableToPatient = false

    
  # ====== READ FROM MACHINE _ START ==========

  callLocalPostApi: (url, data, cbfn)->
    data = {} unless typeof data is 'object'
    data.__meta = 
      clientIdentifier: app.config.clientIdentifier
      clientVersion: app.config.clientVersion
      clientPlatform: app.config.clientPlatform
    data = lib.json.stringify data
    lib.network.request url, 'POST', data, (error, response)->
      return cbfn error if error
      return cbfn null, (lib.json.parse response.target.responseText)

  readFromMachineTapped:(e)->
    console.log(this.testResultObjectList);

    machineElaborationMap = {
      "WBC": "WBC"
      "LYM#": "Lymphocytes #"
      "LYM%": "Lymphocytes"
      "MON#": "Monocytes #"
      "MON%": "Monocytes"
      "NEU#": "Neutrophils #"
      "NEU%": "Neutrophils"
      "EOS#": "Eosinophils #"
      "EOS%": "Eosinophils"
      "BAS#": "Basophils #"
      "BAS%": "Basophils"
      "ALY#": "Atypical Lymphocytes #"
      "ALY%": "Atypical Lymphocytes %"
      "LIC#": "Large Immature Cell #"
      "LIC%": "Large Immature Cell %"
      "RBC": "RBC"
      "HGB": "HB"
      "HCT": "HCT"
      "MCV": "MCV"
      "MCH": "MCH"
      "MCHC": "MCHC"
      "RDW": "RDW"
      "PLT": "Platelets Count"
      "MPV": "MPV"
      "PCT": "Plateletcrit"
      "PDW": "Platelet Distribution Width"
      "CRP": "C Reactive Protein"

      "Alb BCG":"Albumin"
      "Crea Enz.":"Creatinine"
      "HDL Plus":"HDL"
      "ALP Plus":"Serum Alkaline Phosphatase"
      "CRP":"CRP"
      "IgE":"IgE"
      "ALT":"SGPT (ALT)"
      "D. Bil":"Bilirubin (Direct)"
      "LDH":"LDH"
      "Amylase":"Amylase"
      "Gluc GP":"Glucose"
      "LDL-Chol":"LDL"
      "AST":"SGOT (AST)"
      "Hb-Sl":"Haemoglobin "
      "Lipase":"Lipase"
      "Ca":"Calcium"
      "HbA1c_NGSP":"HbA1c"
      "Magnesium":"Magnesium"
      "Chol":"Cholesterol"
      "HbA1c_Sl":"HbA1c"
      "Pi":"phpsphatase (Po4)"
      "T Bil":"Bilirubin (Total)"
      "T Prot Plus":"T.Protein"
      "Trigly":"Triglycerides"
      "UrAC2":"Uric Acid"
      "Urea":"Urea"

      "CA125":"CA125"
      "CA15-3":"CA15-3"
      "FT3":"FT3"
      "FT4":"FT4"
      "Ferr":"Ferr"
      "TSH":"TSH"
      "Testestorane":"Testestorane"
      "Prolactin":"Prolactin"
      "FSH":"FSH"
      "LH":"LH"
      "CA 19-9":"CA 19-9"
      "T3":"T3"
      "T4":"T4"
      "HCG":"HCG"
      "B HCG":"Beta Human Chorionic Gonadotropin"
    }

    elaborationMap = {
      "MCV":"M.C.V."
      "MCH":"M.C.H."
      "RBC": "Red blood cells"
      "RDW": "Red cell distribution width (RDW)"
      "PLT": "Platelet Count"
      "HGB": "Haemoglobin"
      "HCT": "Haematocrit"
      "WBC": "white Cell Count"
      "MPV": "M.P.V."

      "Alb BCG":"Albumin"
      "Crea Enz.":"Creatinine"
      "HDL Plus":"HDL"
      "ALP Plus":"Serum Alkaline Phosphatase"
      "CRP":"CRP"
      "IgE":"IgE"
      "ALT":"SGPT (ALT)"
      "D. Bil":"Bilirubin (Direct)"
      "LDH":"LDH"
      "Amylase":"Amylase"
      "Gluc GP":"Glucose"
      "LDL-Chol":"LDL"
      "AST":"SGOT (AST)"
      "Hb-Sl":"Haemoglobin "
      "Lipase":"Lipase"
      "Ca":"Calcium"
      "HbA1c_NGSP":"HbA1c"
      "Magnesium":"Magnesium"
      "Chol":"Cholesterol"
      "HbA1c_Sl":"HbA1c"
      "Pi":"phpsphatase (Po4)"
      "T Bil":"Bilirubin (Total)"
      "T Prot Plus":"T.Protein"
      "Trigly":"Triglycerides"
      "UrAC2":"Uric Acid"
      "Urea":"Urea"

      "CA125":"CA125"
      "CA15-3":"CA15-3"
      "FT3":"FT3"
      "FT4":"FT4"
      "Ferr":"Ferr"
      "TSH":"TSH"
      "Testestorane":"Testestorane"
      "Prolactin":"Prolactin"
      "FSH":"FSH"
      "LH":"LH"
      "CA 19-9":"CA 19-9"
      "T3":"T3"
      "T4":"T4"
      "HCG":"HCG"
      "B HCG":"Beta Human Chorionic Gonadotropin"
    }

    this.callLocalPostApi 'http://localhost:8020/get-reading', {}, (err, data)=>
      if err
        this.domHost.showModalDialog("Error reading data")
        return

      if data.length is 0
        this.domHost.showModalDialog("No data could be read")
        return
      { testResultList, suspectedPathologyList } = data[0]

      if this.testResultObjectList.length is 0
        this.domHost.showModalDialog("No Compatible Test Results Found")
        return
      
      index1 = 0
      mismatchedResultList = []
      testResultList.forEach (machineResult)=>
        elaboratedName = machineElaborationMap[machineResult.testCode]
        index2 = -1
        if elaboratedName
          index2 = this.testResultObjectList[index1].data.testList.findIndex (test)=>
            return test.testName is elaboratedName

        if index2 > -1
          this.set("testResultObjectList.#{index1}.data.testList.#{index2}.testResult", parseFloat(machineResult.measurement))
          this.set("testResultObjectList.#{index1}.data.testList.#{index2}.testUnit", machineResult.unit)
        else
          mismatchedResultList.push machineResult

      comments = "Other results: \n"      
      list = mismatchedResultList.map (machineResult)=>
        { testCode, measurement, unit } = machineResult
        elaboratedName = machineElaborationMap[testCode]
        return "#{testCode} (#{elaboratedName}) #{measurement} #{unit}"
      comments += list.join('\n')

      if suspectedPathologyList.length > 0
        comments += "\n\nAutomatically suspected pathologies: \n"
        comments += suspectedPathologyList.join(', ')
     
      this.set("testResultObjectList.#{index1}.data.overallComment", comments)



  # ====== READ FROM MACHINE _ START ==========

  

}