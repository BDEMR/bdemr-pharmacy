
Polymer {
  
  is: 'page-create-operation-list'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    otManagementObject:
      type: Object
      value: ()-> {}

    otTemplateObject:
      type: Object
      value: ()-> {}

    otStatusList:
      type: Array
      value: [
        "Booked"
        "Awaiting"
        "Started"
        "Finished"
        "Patient in recovery"
        "Patient in bed"
      ]

    surgeryPriorityList:
      type: Array
      value: [
        "1A Within 1 hour"
        "1B within 8 hour"
        "1C within 24 hour"
        "2 within 48 hours"
        "3 within 72 hours in recovery"
      ]

    departmentList:
      type: Array
      value: [
        "Cardiothoracic Surgery"
        "Colon and Rectal Surgery"
        "General Surgery"
        "Medical and Surgical Gynecology"
        "Neurosurgery in recovery"
        "Ophthalmology"
        "Orthopedic Surgery"
        "Otolaryngology (Head & Neck)"
        "Plastic and Reconstructive Surgery"
        "Transplantation"
        "Urology"
        "Vascular Center"
        "OB & Gynae"
      ]

    otStatusIndex:
      type: Number
      value: 0

    surgeryPriorityIndex:
      type: Number
      value: 0

    user:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: null

    patientSearchQuery:
      type: String
      value: -> ""
      observer: 'patientSearchInputChanged'   
         
    matchingPatientdata:
      type: Array
      notify: true
      value: ()-> []

    operationNameArr:
      type: Array
      value: -> []

    anaesthesiaValues:
      type: Array
      value: [
        {label: 'General anaesthesia', value: 'General anaesthesia'}
        {label: 'General & Epidural anaesthesia', value: 'General & Epidural anaesthesia'}
        {label: 'General & Nerve block', value: 'General & Nerve block'}
        {label: 'Spinal anaesthesia', value: 'Spinal anaesthesia'}
        {label: 'Epidural anaesthesia', value: 'Epidural anaesthesia'}
        {label: 'Caudal anaesthesia', value: 'Caudal anaesthesia'}
        {label: 'Nerve block', value: 'Nerve block'}
        {label: 'Sedation', value: 'Sedation'}
        {label: 'Other', value: 'Other'}
      ]


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      # console.log @user


  navigatedIn: ->
    @_loadUser()
    @organization = @getCurrentOrganization()
    console.log @organization
    @loadExistingOrJustCreatedOtManagementLists()

    params = @domHost.getPageParams()
    # console.log params
    #this load Ot Management is for edit purpose.
    @_loadOperationNameList()
    returningFromOTEditor = JSON.parse localStorage.getItem 'returning_from_generic_editor'
    localStorage.removeItem 'returning_from_generic_editor'

    updatedTemplateContent = JSON.parse localStorage.getItem 'updated_template_content'
    localStorage.removeItem 'updated_template_content'

    
    if params['OtManagementSerial']
      @_loadOtManagementList params['OtManagementSerial'], (templateSerial)=>
        @_loadOtTemplateList templateSerial, ()=>
          @_setUpdatedTemplateContent returningFromOTEditor, updatedTemplateContent
    else
      unless returningFromOTEditor
        @_makeOtManagementObject()
        @_makeOtTemplateObject()
      @_setUpdatedTemplateContent returningFromOTEditor, updatedTemplateContent
    
  
  _setUpdatedTemplateContent: (returningFromOTEditor, updatedTemplateContent)->
    if returningFromOTEditor
      @set 'otTemplateObject.data.templateContent', updatedTemplateContent
  

  _makeOtManagementObject: ()->
    @otManagementObject = {
      serial: @generateSerialForOt()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data: {
        nameOfTheOrganization: @organization.name
        nameOfTheInstitution: ""
        nameOfTheDepartment: ""
        operationDate: null
        nameOfThePatient: ""
        typeOfAnaesthesia: ''
        patientId: ""
        operationName: ""
        theaterName: ""
        specialNotes: ""
        surgeon: {
          name:""
          id: ""
        }
        assistantSurgeon1:{
          name:""
          id: ""
        }
        assistantSurgeon2: {
          name:""
          id: ""
        }
        assistantSurgeon3: {
          name:""
          id: ""
        }
        anaesthesist: {
          name:""
          id: ""
        }
        assistantAnaesthesist1:{
          name:""
          id: ""
        }
        assistantAnaesthesist2: {
          name:""
          id: ""
        }
        assistantAnaesthesist3: {
          name:""
          id: ""
        }
        pediatrician: {
          name:""
          id: ""
        }
        startTime: ""
        endTime: ""
        expectedTime: ""
        otTemplateSerial: null
      }
   
    }
    @customOperationDate = ""
    @otStatusIndex = 0
    @surgeryPriorityIndex = 0


  _makeOtTemplateObject: ()->
    @otTemplateObject = {
      serial: @generateSerialForOtTemplate()
      otManagementObjectSerial: null
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      patientSerial: null
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      templateCreatedFrom: 'clinic-app-ot-management'
      data: {
        templateName: ''
        templateContent: ''
      }
    }


  _setOperationDateTime: ->
    return unless @customOperationDate
    if @customOperationDate
      operationDate = new Date("#{@customOperationDate}")
    @set 'otManagementObject.data.operationDate', operationDate.getTime()
    @customOperationDate = ""

  otManagementStatusChanged: (e)->
    @otManagementObject.data.otStatus = @otStatusList[@otStatusIndex]

  surgeryPriorityChanged: (e)->
    @otManagementObject.data.surgeryPriorityStatus = @surgeryPriorityList[@surgeryPriorityIndex]

  otFormIsValid: ()->
    unless @customOperationDate
      @domHost.showModalDialog 'Please select or write the Operation Date'
      return false

    unless @otManagementObject.data.nameOfTheInstitution
      @domHost.showModalDialog 'Please write the name of the Institution'
      return false

    unless @otManagementObject.data.nameOfTheDepartment
      @domHost.showModalDialog 'Please write the name of the Department'
      return false

    unless @otManagementObject.data.nameOfThePatient
      @domHost.showModalDialog 'Please write the name of the Patient'
      return false

    unless @otManagementObject.data.operationName
      @domHost.showModalDialog 'Please write the name of the Operation'
      return false

    # unless @otManagementObject.data.anaesthesist.name
    #   @domHost.showModalDialog 'Please write the name of the Anaesthesist'
    #   return false
    
    # unless @otManagementObject.data.surgeon.name
    #   @domHost.showModalDialog 'Please write the name of the Surgeon'
    #   return false 
    
    unless @otManagementObject.data.theaterName
      @domHost.showModalDialog 'Please write the name of the Theatre'
      return false

    return true

  saveOtButtonPressed: ()->
    @set 'otManagementObject.data.otTemplateSerial', @otTemplateObject.serial
    @set 'otTemplateObject.otManagementObjectSerial', @otManagementObject.serial

    console.log 'ot management obj', @otManagementObject
    console.log 'ot template obj', @otTemplateObject

    if @otFormIsValid()
      @otManagementObject.lastModifiedDatetimeStamp = lib.datetime.now()
      @otTemplateObject.lastModifiedDatetimeStamp = lib.datetime.now()
      @_setOperationDateTime()
      app.db.upsert 'ot-management', @otManagementObject, ({serial})=> @otManagementObject.serial is serial
      app.db.upsert 'patient-template-record', @otTemplateObject, ({serial})=> @otTemplateObject.serial is serial
      @domHost.showModalDialog "--OPERATION DATA SAVED-- Please change or add necessary information to create another OT Schedule Or Click on Cancel to exit"
      # console.log app.db.find 'ot-management'

  
  _loadOtManagementList:(OtIdentifier, cbfn)->
    list = app.db.find 'ot-management', ({serial})-> serial is OtIdentifier
    if list.length > 0
      @set 'otManagementObject', list[0]
      console.log @otManagementObject
      @set 'customOperationDate', @$getFormattedDate @otManagementObject.data.operationDate, 'mm/dd/yyyy'
      cbfn @otManagementObject.data.otTemplateSerial if cbfn
    else
      @domHost.showModalDialog 'No OT List Found'

  
  _loadOtTemplateList:(templateIdentifier, cbfn)->
    list = app.db.find 'patient-template-record', ({serial})-> serial is templateIdentifier
    if list.length > 0
      @set 'otTemplateObject', list[0]
      cbfn() if cbfn
    else
      @domHost.showModalDialog 'Template Not Found'
  

  _searchUser: (searchQuery, id)->
    # Doctor Search
    @callApi '/bdemr-doctor-search', {searchQuery: searchQuery, apiKey: @user.apiKey}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length > 0
          userSuggestionArray = ({text:"#{item.name}--(#{item.email} | #{item.phone})", value:item} for item in data)
          @$$("#" + id).suggestions userSuggestionArray
        else
          @domHost.showToast 'No Match Found'

  onlineSearchEnterKeyPressedForSurgeon: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.surgeon.name
      @_searchUser @otManagementObject.data.surgeon.name, "surgeonUserSearch"

  surgeonSelected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.surgeon.name', user.name
    @set 'otManagementObject.data.surgeon.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForAnaesthesist: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.anaesthesist.name
      @_searchUser @otManagementObject.data.anaesthesist.name, "anaesthesistUserSearch"

  anaesthesistSelected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.anaesthesist.name', user.name
    @set 'otManagementObject.data.anaesthesist.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForPediatrician: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.pediatrician.name
      @_searchUser @otManagementObject.data.pediatrician.name, "pediatricianUserSearch"

  pediatricianSelected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.pediatrician.name', user.name
    @set 'otManagementObject.data.pediatrician.id', user.idOnServer
    # @$$("#userSearch").text = ""


  onlineSearchEnterKeyPressedForAssistantSurgeon1: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantSurgeon1.name
      @_searchUser @otManagementObject.data.assistantSurgeon1.name, "assistantSurgeon1Search"

  assistantSurgeon1Selected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantSurgeon1.name', user.name
    @set 'otManagementObject.data.assistantSurgeon1.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForAssistantSurgeon2: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantSurgeon2.name
      @_searchUser @otManagementObject.data.assistantSurgeon2.name, "assistantSurgeon2Search"

  assistantSurgeon2Selected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantSurgeon2.name', user.name
    @set 'otManagementObject.data.assistantSurgeon2.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForAssistantSurgeon3: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantSurgeon3.name
      @_searchUser @otManagementObject.data.assistantSurgeon3.name, "assistantSurgeon3Search"

  assistantSurgeon3Selected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantSurgeon3.name', user.name
    @set 'otManagementObject.data.assistantSurgeon3.id', user.idOnServer
    # @$$("#userSearch").text = ""


  onlineSearchEnterKeyPressedForAssistantAnaesthesist1: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantAnaesthesist1.name
      @_searchUser @otManagementObject.data.assistantAnaesthesist1.name, "assistantAnaesthesist1Search"

  assistantAnaesthesist1Selected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantAnaesthesist1.name', user.name
    @set 'otManagementObject.data.assistantAnaesthesist1.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForAssistantAnaesthesist2: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantAnaesthesist2.name
      @_searchUser @otManagementObject.data.assistantAnaesthesist2.name, "assistantAnaesthesist2Search"

  assistantAnaesthesist2Selected: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantAnaesthesist2.name', user.name
    @set 'otManagementObject.data.assistantAnaesthesist2.id', user.idOnServer
    # @$$("#userSearch").text = ""

  onlineSearchEnterKeyPressedForAssistantAnaesthesist3: (e)->
    if e.keyCode is 13
      return unless @otManagementObject.data.assistantAnaesthesist3.name
      @_searchUser @otManagementObject.data.assistantAnaesthesist3.name, "assistantAnaesthesist3Search"

  assistantAnaesthesist3Search: (e)->
    user = e.detail.value
    @set 'otManagementObject.data.assistantAnaesthesist3.name', user.name
    @set 'otManagementObject.data.assistantAnaesthesist3.id', user.idOnServer
    # @$$("#userSearch").text = ""


  patientSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    @debounce 'search-patient', ()=>
      @_patientSearch(searchQuery)
    , 1000

  
  _patientSearch: (searchQuery)->
    return unless searchQuery
    @$$("#patientSearch").items = []
    @fetchingPatientSearchResult = true;
    @callApi '/bdemr-patient-search-new', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingPatientSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @matchingPatientdata = response.data
        if @matchingPatientdata.length > 0
          @$$("#patientSearch").items = @matchingPatientdata
        else
          @domHost.showToast 'No Match Found'

  patientSelected: (e)->
    return unless e.detail.value
    patient = e.detail.value
    @set 'otTemplateObject.patientSerial', patient.serial
    @set 'otManagementObject.data.nameOfThePatient', patient.name
    @set 'otManagementObject.data.patientId', patient.phone

  _loadOperationNameList: ()->
    @domHost.getStaticData 'operationList', (list)=>
      for item in list
        @operationNameArr.push(item.name)

  CancelOtButtonPressed: (e)->
    @domHost.navigateToPage '#/operation-theater-management'

  ### Operation List Preview starts ###

  loadExistingOrJustCreatedOtManagementLists: ()->
    otManagementList = app.db.find 'ot-management', ({organizationId})=> organizationId is @organization.idOnServer
    otManagementList.sort (a, b)-> b.data.operationDate - a.data.operationDate
    @set 'otManagementList', otManagementList
    console.log @otManagementList

  getOtStatusListIndex: (status)->
    return @otStatusList.indexOf(status)
    # console.log status

  getSurgeryPriorityListIndex: (status)->
    return @surgeryPriorityList.indexOf(status)
    # console.log status

  otManagementStatusChangedFromTheTable: (e)->
    DropDownSelectedStatus = @otStatusList[e.detail.selected]
    item = e.model.item
    item.data.otStatus = DropDownSelectedStatus
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.update 'ot-management', item._id, item
    @loadExistingOrJustCreatedOtManagementLists()

  surgeryPriorityChangedFromTheTable: (e)->
    DropDownSelectedStatus = @surgeryPriorityList[e.detail.selected]
    item = e.model.item
    item.data.surgeryPriorityStatus = DropDownSelectedStatus
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.update 'ot-management', item._id, item
    @loadExistingOrJustCreatedOtManagementLists()

  editOtButtonPressed:(e)->
    console.log "Edit"
    @domHost.navigateToPage '#/create-operation-list/OtManagementSerial:' + e.model.item.serial

  deleteOtButtonPressed:(e)->
    {item, index} = e.model
    @splice 'otManagementList', index, 1
    app.db.remove 'ot-management', item._id
    console.log "Deleted"

  ### Operation List Preview Ends ###  
  

}
