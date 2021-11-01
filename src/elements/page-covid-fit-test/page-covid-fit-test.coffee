""" COVID fit test
- mask fit test entries can be added with different parameters. If fit test result is unfit, two more fields become available, 'retest required?' and 'reasons'
- table entries can be filtered by participant, company, model, test by and result
- each entry can be printed using a predefined format

"""


Polymer {
  
  is: 'page-covid-fit-test'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    user:
      type: Object
      value: {}

    covidRespiratorTestObject:
      type: Object
      value: {}
    
    addedRespiratorTestList:
      type: Array
      notify: true
      value: []
    
    filteredAddedRespiratorTestList:
      type: Array
      value: -> []
    
    customRespiratorList:
      type: Array
      value: -> []

    defaultRespiratorList:
      type: Array
      value: [
        'DL2'
        'DL3'
        'DS2'
        'DS3'
        'FFP2'
        'KN-95'
        'KMOEL'
        'KP-95'
        'N-95'
        'Others'
        'P2'
        'P3'
        'Surgical Mask'
        'Unverified Mask'
      ]

    fitTestResultOptions:
      type: Array
      value: [
        'Fit'
        'Unfit'
      ]

    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    loadingCounter:
      type: Number
      value: -> 0

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    facepieceModelOptions:
      type: Array
      value: -> [
        'Own'
        'Pool'
        'Test'
      ]
    
    kitOptions:
      type: Array
      value: -> [
        'FT - 10 (sweet)'
        'FT - 30 (bitter)'
      ]

    retestRequiredOptions:
      type: Array
      value: -> [
        'Yes'
        'No'
      ]

    passAchievedDate:
      type: Number
      value: -> 0

    patientStatus:
      type: String
      value: null

    respiratorTestNameSearchString:
      type: String
      value: ''

    respiratorTestCompanySearchString:
      type: String
      value: ''
    
    respiratorTestModelSearchString:
      type: String
      value: ''

    respiratorTestUserSearchString:
      type: String
      value: ''
    
    respiratorTestResultSearchString:
      type: String
      value: ''
    
    searchedUserList:
      type: Array
      value: []
    
    isRetestAndReasonVisible:
      type: Boolean
      value: false


  observers: [
    'filteringParametersChanged(respiratorTestNameSearchString, respiratorTestCompanySearchString, respiratorTestModelSearchString, respiratorTestUserSearchString, respiratorTestResultSearchString)'
    # '_userSearchTrigger(covidRespiratorTestObject.data.name)'
    '_updatedRetestAndReasonVisibility(covidRespiratorTestObject.data.result)'
  ]


  filteringParametersChanged: (respiratorTestNameSearchString, respiratorTestCompanySearchString, respiratorTestModelSearchString, respiratorTestUserSearchString, respiratorTestResultSearchString)->
    lib.util.delay 300, ()=>
      tempName = if respiratorTestNameSearchString then respiratorTestNameSearchString.trim().toLowerCase() else ''
      tempCompany = if respiratorTestCompanySearchString then respiratorTestCompanySearchString.trim().toLowerCase() else ''
      tempModel = if respiratorTestModelSearchString then respiratorTestModelSearchString.trim().toLowerCase() else ''
      tempUser = if respiratorTestUserSearchString then respiratorTestUserSearchString.trim().toLowerCase() else ''
      tempResult = if respiratorTestResultSearchString then respiratorTestResultSearchString.trim().toLowerCase() else ''
      
      tempList = @addedRespiratorTestList.filter (item)=>
        nameFlag = companyFlag = modelFlag = userFlag = resultFlag = false
        if (item.data.name) and ((tempName is '') or (tempName isnt '' and item.data.name.toLowerCase().includes tempName))
          nameFlag = true
        
        if (item.data.company.name) and ((tempCompany is '') or (tempCompany isnt '' and item.data.company.name.toLowerCase().includes tempCompany))
          companyFlag = true
        
        if (item.data.customRespiratorSize) and ((tempModel is '') or (tempModel isnt '' and item.data.customRespiratorSize.toLowerCase().includes tempModel))
          modelFlag = true
        
        if (item.data.testConductedBy.name) and ((tempUser is '') or (tempUser isnt '' and item.data.testConductedBy.name.toLowerCase().includes tempUser))
          userFlag = true
        
        if (item.data.result) and ((tempResult is '') or (tempResult isnt '' and item.data.result.toLowerCase().includes tempResult))
          resultFlag = true

        return nameFlag and companyFlag and modelFlag and userFlag and resultFlag
      
      @set 'filteredAddedRespiratorTestList', tempList
      console.log 'filtered list', @filteredAddedRespiratorTestList


  userSelectedFromList: (e)->
    user = e.detail.value
    console.log 'selected user', user
    @set 'covidRespiratorTestObject.participantId', user.idOnServer
    @set 'covidRespiratorTestObject.data.name', user.name
  

  seachUserFromSystem: (e)->
    if e.keyCode is 13
      return unless @covidRespiratorTestObject.data.name
      @_searchUser @covidRespiratorTestObject.data.name


  # _userSearchTrigger: (searchQuery)->
  #   @debounce 'search-user', ()=>
  #     unless (searchQuery and searchQuery.length >= 2)
  #       return 
  #     @_searchUser searchQuery
  #   , 300

  _searchUser: (searchQuery)->
    data = 
      apiKey: @user.apiKey
      searchQuery: searchQuery

    console.log 'user query', data
    @callApi '/bdemr-patient-search-new', data, (err, response)=>
      @arbitaryCounter--
      @patientExists = false
      if response.hasError
        @domHost.showModalDialog response.error.message
        # @set 'searchedUserList', []
      else
        userList = response.data
        if userList.length > 0
          userSuggestionArray = ({text:"#{item.name}--(#{item.phone})", value:item} for item in userList)
          @$$("#userNameFieldId").suggestions userSuggestionArray
        else
          @domHost.showToast 'No Match Found!'
        
        console.log 'fetched user list', userList

        # remove all signup-patient properties from @patient and keep only neccessary ones from existing patient info
        # Object.keys(@patient).forEach (prop)=>
        #   if prop isnt 'phone' 
        #     delete @patient[prop]
        
        # @set 'patient.name', @_getFullName tempPatient.name
        # @set 'patient.dateOfBirth', tempPatient.dateOfBirth
        # @set 'patient.gender', tempPatient.gender
        # @set 'patient.addressList', tempPatient.addressList
        # @set 'patient.serial', tempPatient.serial
        # # delete above properties from tempPatient first, then assign to have identical
        # # Object.assign @patient, tempPatient
        # console.log 'imported patient', @patient

  

  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer
      @_loadMemberList ()=> null
      # @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
      #   @set 'settings', settings
      @_loadCovidFitTestList @user.serial
      @_makeNewTestEntryObject()

      @loadingCounter--
    # @_loadSettings()

  navigatedOut: ->

  
  getBoolean: (data)-> if data then true else false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  # _loadSettings: ()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   @settings = {}
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization and @organization.printSettings
  #         @settings.printDecoration =  @organization.printSettings

  _loadOrganization: (cbfn)->
    
    @loadingCounter++
    data = { 
      apiKey: @user.apiKey
      idList: [ @organization.idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn()


  resetButtonClicked: -> @domHost.reloadPage()

  organizationSelected: (e)->
    return unless e.detail.value
    organization = e.detail.value
    console.log 'selected org', organization
    unless organization.label.toLowerCase() is 'all'
      @set 'covidRespiratorTestObject.data.company', {name: organization.label, organizationId: organization.value}
    else
      @set 'covidRespiratorTestObject.data.company', {}

  memberSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    console.log 'selected member', user
    @set 'covidRespiratorTestObject.data.testConductedBy', user
  
  _loadChildOrganizationList: (organizationIdentifier)-> 
    @loadingCounter++
    query = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    }
    @callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      @loadingCounter--
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        @set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = @$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: @organization.name, value: @organization.idOnServer }]
        organizationSelectorComboBox.value = @organization.idOnServer

  filterByDateClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', (startDate.getTime())
    @set 'dateCreatedTo', (endDate.getTime())

  filterByDateClearButtonClicked: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0
    
  printTestButtonPressed: (e)->
    item = e.model.item
    console.log 'selected test', item
    @domHost.navigateToPage '#/print-respirator-fit-test/report:' + item.serial

  editInvoiceButtonPressed: (e)->
    item = e.model.item
    console.log item
    @domHost.showModalInput "Patient already exists. Please enter patient PIN to import", "0000", (answer)=>
      if answer    
        @_importPatient item.patientSerial, answer, (patient)=>
          @domHost.navigateToPage '#/create-invoice/invoice:' + item.serial + '/patient:' + item.patientSerial


  # ==============================
  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      console.log response
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
        @removePatientIfAlreadyExist patient.serial
        _id = app.db.insert 'patient-list', patient
        cbfn patient

  removePatientIfAlreadyExist: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      patient = list[0]
      app.db.remove 'patient-list', patient._id
      return
    else
      return

  # Edit invoice parts ENDS
  # ==============================

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


  resetButtonClicked: -> return @domHost.reloadPage()
  
  _loadMemberList: (cbfn)->
    @loadingCounter++
    @memberListLoading = true
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      @loadingCounter--
      @memberListLoading = false
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @set 'memberList', response.data.matchingUserList
        cbfn()
  

  _updatedRetestAndReasonVisibility: (fitTestResult)->
    unless fitTestResult
      return @set 'isRetestAndReasonVisible', false
    
    return @set 'isRetestAndReasonVisible', fitTestResult.toLowerCase() is 'unfit'

  # =================== Add Entry ===================

  _duplicateCustomrespiratorModel: (makeModel)->
    return @customRespiratorList.some (item)=>
      return item is makeModel

  saveCustomRespiratorFitTestModel: (makeModel)->
    return unless makeModel
    return if @_duplicateCustomrespiratorModel makeModel

    object =
      serial: @generateSerialForCustomCovidRespiratorModel()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: makeModel

    app.db.insert 'custom-covid-respirator-fit-test', object


  _loadCovidFitTestList: (userIdentifier)->
    list = app.db.find 'covid-respirator-fit-test'
    customList = app.db.find 'custom-covid-respirator-fit-test', ({createdByUserSerial})=> userIdentifier is createdByUserSerial

    @set 'addedRespiratorTestList', list
    @set 'customRespiratorList', @defaultRespiratorList.concat customList.map (item)=>
      return item.data.name
    console.log 'custom models', @customRespiratorList

    @set 'filteredAddedRespiratorTestList', list
    console.log 'fit test list', @filteredAddedRespiratorTestList


  _makeNewTestEntryObject: ()->
    @covidRespiratorTestObject =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data: {}


  addEntryClicked: ()->
    @saveCustomRespiratorFitTestModel @covidRespiratorTestObject.data.customRespiratorSize
    @covidRespiratorTestObject.serial = @generateSerialForCovidRespirator()
    @covidRespiratorTestObject.createdDatetimeStamp = lib.datetime.now()
    @covidRespiratorTestObject.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.insert 'covid-respirator-fit-test', @covidRespiratorTestObject
    @domHost.reloadPage()


  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'



}
