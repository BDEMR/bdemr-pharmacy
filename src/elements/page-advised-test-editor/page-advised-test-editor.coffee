
Polymer {

  is: 'page-advised-test-editor'


  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:

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
      value: -> (app.db.find 'user')[0]

    patient:
      type: Object
      notify: true
      value: null

    visit:
      type: Object
      notify: true
      value: null

    addedInvestigationList:
      type: Array
      notify: true
      value: []

    testAdvisedObject:
      type: Object
      notify: true
      value: {}
    
    selectedInvestigation:
      type: Object
      value: null
      observer: 'selectedInvestigationChanged'

  _makeNewAddedInvestigationObject: (data)->
    object = {}
    objectStatus = {}
    objectStatus.hasTestResults = false
    objectStatus.testResultsSerial = null
    objectStatus.invoiceSerial = null

    object.investigationName = data.name
    object.investigationIdOnServer = data._id
    object.hasGroupTest = data.hasGroupTest
    object.testList = data.investigationList
    object.testGroupList = data.testGroupList
    object.price = data.price
    object.actualCost = data.actualCost
    object.status = objectStatus
    object.serial = @generateSerialForTestAdvisedInvestigation()
    object.suggestedInstitutionName = ''

    return object

  selectedInvestigationChanged: (selectedInvestigation)->
    console.log selectedInvestigation
    if selectedInvestigation
      @unshift 'addedInvestigationList', @_makeNewAddedInvestigationObject @selectedInvestigation
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
    else
      return @_notifyInvalidPatient()
  
  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle
    return 'not provided yet'

  ## Make New Object
  _makeNewTestAdvisedObject: ()->
    @testAdvisedObject =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      visitSerial: null
      patientSerial: @patient.serial
      doctorName: @user.name
      doctorSpeciality: @getDoctorSpeciality()
      organizationId: @currentOrganization.idOnServer
      clientCollectionName: 'visit-advised-test'
      data:
        testAdvisedName: null
        testAdvisedList: []
      availableToPatient: true
      
    @isTestAdvisedValid = true
      

  ## Load Test Advised Data
  _loadAdvisedTest: (adviseTestIdentifier)->

    list = app.db.find 'visit-advised-test', ({serial})-> serial is adviseTestIdentifier
    if list.length is 1
      @isTestAdvisedValid = true
      @testAdvisedObject = list[0]
      console.log "ADVISED TEST: ", @testAdvisedObject
      @addedInvestigationList = list[0].data.testAdvisedList
      return true
    else
      @_notifyInvalidTestAdvised()
      return false


      
  _notifyInvalidTestAdvised: ->
    @isTestAdvisedValid = false
    @domHost.showModalDialog 'Invalid Test Advised Provided'

  _deleteTest: (e) ->
    index = e.model.index
    @splice('addedInvestigationList', index, 1)
    @domHost.showToast 'Deleted Successfully!'
  
  _markAsFavorite: (e) ->
    index = e.model.index
    console.log @addedInvestigationList[index]
    investigationId = @addedInvestigationList[index].investigationIdOnServer
    
    @domHost.callApi '/bdemr-investigation-set-as-favorite', { apiKey: @user.apiKey, investigationId: investigationId }, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showSuccessToast response.data.message
  
  _syncOnlyTestAdvised: (cbfn)->
    @domHost._newSync cbfn

  saveButtonPressed: (e)->
    @saveAdvisedTest =>
      @_callSetVisitAdvisedTestApi =>
        @arrowBackButtonPressed()
        @domHost.showToast "Test Advised added!"
  
  _callSetVisitAdvisedTestApi: (cbfn)->
    @testAdvisedObject.apiKey = @user.apiKey
    @callApi '/bdemr-set-advised-test', @testAdvisedObject, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  saveAdvisedTest: (cbfn)->
    # console.log @testAdvisedObject
    unless @addedInvestigationList.length is 0
      @testAdvisedObject.data.testAdvisedList = @addedInvestigationList

      if @visit.advisedTestSerial is null
        @testAdvisedObject.serial = @generateSerialForTestAdvised()

        ## updated current visit object
        @visit.advisedTestSerial = @testAdvisedObject.serial
        @_saveVisit()
     
      # Updated Advised Test List
      @testAdvisedObject.lastModifiedDatetimeStamp = lib.datetime.now()
      # app.db.upsert 'visit-advised-test', @testAdvisedObject, ({serial})=> @testAdvisedObject.serial is serial
      
      @set 'comboBoxInvestigationInputValue', null
      
      # @domHost.showToast 'Test Added.'
      cbfn()

  _makeNewVisit: (cbfn)->
    @visit =
      serial: null
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
      hospitalName: @currentOrganization.name
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
      recordTitle: 'Advised Test'
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

  _saveVisit: ()->
    @visit.serial = @generateSerialForVisit()
    @visit.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'doctor-visit', @visit, ({serial})=> @visit.serial is serial

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

    
  navigatedIn: ->
    @set 'addedInvestigationList', []

    params = @domHost.getPageParams()

    @currentOrganization = @getCurrentOrganization()
    unless @currentOrganization
      return @domHost.navigateToPage "#/select-organization"

    # Load Patient
    unless params['patient']
      @_notifyInvalidPatient()
      return
    else
      @_loadPatient params['patient']
    
    # Load Test Advised
    unless params['record']
      @_notifyInvalidTestAdvised()
      return
    else
      if params['record'] is 'new'
        @_makeNewTestAdvisedObject()
        @_makeNewVisit()
      else 
        @_loadAdvisedTest params['record']


  navigatedOut: ->
    @patient = {}
    ## Advised Test
    @isTestAdvisedValid = false
    @testAdvisedObject = {}
    @matchingFavoriteInvestigationList = []
    @investigationDataList = []


}
