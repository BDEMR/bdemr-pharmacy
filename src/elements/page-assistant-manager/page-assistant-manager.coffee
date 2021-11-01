
Polymer {
  
  is: 'page-assistant-manager'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    selectedTabPageIndex:
      type: Number
      notify: true
      value: 0

    searchContextDropdownSelectedIndex: 
      type: Number
      notify: true
      value: 1

    isAdvancedSearchEnabled: 
      type: Boolean
      notify: true
      value: false

    advancedSearchParameters:
      type: Object
      notify: true
      value:
        createdDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        initialVisitDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        lastVisitDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        admissionDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        handledDate:
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()

    hasSearchBeenPressed:
      type: Boolean
      notify: true
      value: true


    matchingAssistantList:
      type: Array
      notify: true
      value: []

    searchFieldMainInput: 
      type: String
      notify: true
      value: ''

    user:
      type: Object
      value: null


  navigatedIn: ->

    @domHost.setCurrentPatientsName null
    @user = (try (app.db.find 'user')[0] catch ex then null) or null

    if @user.isUsingAsAssistant is true
      @domHost.navigateToPage '#/dashboard'
    # if @domHost.__patientView__oneTimeSearchFilter
    #   @oneTimeSearchFilter = @domHost.__patientView__oneTimeSearchFilter

    params = @domHost.getPageParams()
    if params['filter'] and params['filter'] is 'clear'
      @domHost.modifyCurrentPagePath '#/assistant-manager'
      # @isAdvancedSearchEnabled = false
      @searchFieldMainInput = ''
      @listAllImportedAndOfflinePatientsPressed null
    else
      @listAllImportedAndOfflinePatientsPressed null

  searchButtonPressed: (e)->
    if @searchContextDropdownSelectedIndex is 1
      @_searchOnline()
    else
      @_searchOffline()

  listAllImportedAndOfflinePatientsPressed: (e)->
    @searchFieldMainInput = ''
    @searchContextDropdownSelectedIndex = 0
    @searchButtonPressed null    

  searchAllAssistantButtonPressed: (e)->
    @matchingAssistantList = []
    { apiKey } = (app.db.find 'user')[0]
    @callApi '/bdemr-doctor-assistant-search', {searchQuery: @searchFieldMainInput, apiKey: apiKey}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        matchingAssistantList = response.data
        # for assistant in matchingAssistantList
        #   assistant.flags = {
        #     isDoctorsAssistant: false
        #   }
          # localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.serial
          # if localPatientList.length is 0
          #   patient.flags.isOnlineOnly = true
          # else
          #   patient.flags.isImported = true
          #   patient._tempLocalDbId = localPatientList[0]._id
        @matchingAssistantList = matchingAssistantList

  searchOnlineButtonPressed: (e)->
    @searchContextDropdownSelectedIndex = 1
    @searchButtonPressed null

  _searchOnline: ->
    @matchingAssistantList = []
    { apiKey } = (app.db.find 'user')[0]
    @callApi '/bdemr-doctor-assistant-search', {searchQuery: @searchFieldMainInput, apiKey: apiKey, special: 'none' }, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        matchingAssistantList = response.data
        # for assistant in matchingAssistantList
        #   assistant.flags = {
        #     isDoctorsAssistant: false
        #   }
          # localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.serial
          # if localPatientList.length is 0
          #   patient.flags.isOnlineOnly = true
          # else
          #   patient.flags.isImported = true
          #   patient._tempLocalDbId = localPatientList[0]._id
        @matchingAssistantList = matchingAssistantList
  
  _searchOffline: ->
    ## Basic Search
    searchFieldMainInput = @searchFieldMainInput

    if searchFieldMainInput.length is 0  and false
      patientList = app.db.find 'patient-list'
    else
      patientList = app.db.find 'patient-list', ({serial, name, email, phone, nIdOrSsn, hospitalNumber, initialVisitDate, lastVisitDate, admissionDate})=>
  
        if @oneTimeSearchFilter
          condition1 = (''+serial) is ('' + @oneTimeSearchFilter)
          condition2 = false
          condition3 = false
          condition4 = false
          condition5 = false
          condition6 = false
        else
          condition1 = (name.indexOf searchFieldMainInput) > -1
          condition2 = (email.indexOf searchFieldMainInput) > -1
          condition3 = (phone.indexOf searchFieldMainInput) > -1
          condition4 = (serial.indexOf searchFieldMainInput) > -1
          condition5 = try (nIdOrSsn.indexOf searchFieldMainInput) > -1 catch ex then false
          ## NOTE:
          # Found to be commented out on master when shafayet merged
          # his interoperability issues branch. shafayet did not comment 
          # this out.
          condition6 = (hospitalNumber.indexOf searchFieldMainInput) > -1 

        isAdvancedSearchPassed = true

        return (condition1 or condition2 or condition3 or condition4 or condition5 or condition6)

    @oneTimeSearchFilter = null

    ## Modify Results
    for patient in patientList
      unless 'flags' of patient
        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isLocalOnly = true

    ## Sort Results
    ''

    @matchingPatientList = patientList


  clearSearchResultsClicked: (e)->
    @matchingAssistantList = []

  moreOptionsPressed: (e)->
    @domHost.showModalDialog 'You can search records (instead of patients) by many other options including diseases from the "Record Manager" option from the left menu.'

  # newPatientFabPressed: (e)->
  #   @domHost.navigateToPage '#/patient-editor/patient:new'

  ## ------------------ import / publish start

  _publishPatient: (patient, pin, cbfn)->
    @callApi '/bdemr-patient-publish', {patient: patient, pin: pin}, (err, response)=>
      if response.hasError
        if response.error.message is 'U_PIN_ERR'
          @domHost.showModalInput "Please enter correct patient PIN", "0000", (answer)=>
            if answer
              @_publishPatient patient, answer, cbfn
        else
          @domHost.showModalDialog response.error.message
      else
        if response.data.status is 'success'
          @_importPatient patient.serial, pin, (importedPatientLocalId)=>
            app.db.remove 'patient-list', patient._id
            @searchContextDropdownSelectedIndex = 0
            @oneTimeSearchFilter = patient.serial
            @searchButtonPressed null
        else
          # console.log response.data
          @domHost.showModalDialog ("Unkown response " + response.data.status)

  publishPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.showModalPrompt "Publishing will overwrite remote changes (if any). Continue?", (answer)=>
      if answer
        @_publishPatient patient, null, (updatedPatient)=>
          # console.log 'publishing completed', updatedPatient

  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import', {serial: serial, pin: pin}, (err, response)=>
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
        _id = app.db.insert 'patient-list', patient
        cbfn _id

  addAsMyAssistantPressed: (e)->
    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
        el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
        el.opened = false
        repeater = @$$ '#assistant-list-repeater'

        index = repeater.indexForElement el
        assistant = @matchingAssistantList[index]

        { apiKey } = (app.db.find 'user')[0]
        @callApi '/bdemr-doctor-assistant-set-as-assistant', {assistantId: assistant.idOnServer, apiKey: apiKey}, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            # console.log response.data
            if response.data is 'ok'
              @_searchOnline()
              @domHost.showModalDialog 'successfully added'
              # assistantList = response.data
            else
              console.log 'Response data has error'

  removeFromMyAssistantPressed: (e)->
    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
        el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
        el.opened = false
        repeater = @$$ '#assistant-list-repeater'

        index = repeater.indexForElement el
        assistant = @matchingAssistantList[index]

        { apiKey } = (app.db.find 'user')[0]
        @callApi '/bdemr-doctor-assistant-remove-as-assistant', {assistantId: assistant.idOnServer, apiKey: apiKey}, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            # console.log response.data
            if response.data is 'ok'
              @domHost.showModalDialog 'successfully removed'
              # @searchAllAssistantButtonPressed()
              # assistantList = response.data
            else
              console.log 'Response data has error'



  $or: (a, b)-> a or b

  $log: (obj)->
    # console.log obj


  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false
}
