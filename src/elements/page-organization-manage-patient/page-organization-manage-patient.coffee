
Polymer {

  is: 'page-organization-manage-patient'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false

    organization:
      type: Object
      notify: true
      value: null

    matchingPatientList:
      type: Array
      value: -> []

    indoorBalance:
      type: Number
      value: 800

    outdoorBalance:
      type: Number
      value: 200

  $add: (a, b)-> parseInt(a) + parseInt(b)

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  navigatedIn: ->
    @_loadUser()
    @_loadWallet()
    
    params = @domHost.getPageParams()
    if params['organization']
      @_loadOrganization params['organization']
    else
      @_notifyInvalidOrganization()
    
  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false

  _loadOrganization: (idOnServer)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]

        @set 'isOrganizationValid', true
        @_loadPatientList()

  searchOnlineButtonPressed: (e)->
    @searchContextDropdownSelectedIndex = 1
    @searchButtonPressed()

  onlineSearchEnterKeyPressed: (e)->
    if e.keyCode is 13
      return unless @searchFieldMainInput
      @_searchOnline @searchFieldMainInput

  _searchOnline: (searchQuery)->
    @callApi '/bdemr-patient-search', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else if response.data.length is 0
        @domHost.showToast 'No Patient Found with that Search'
        @searchFieldMainInput = ""
      else
        matchingPatientList = response.data
        for patient in matchingPatientList
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
        
        userSuggestionArray = ({text:"#{item.name}--#{item.email}--#{item.phone}", value:item} for item in matchingPatientList)
        # Populating Suggestion Array for Autocomplete
        @$$("#userSearch").suggestions userSuggestionArray

  userSelected: (e)->
    e.stopPropagation()
    patient = e.detail.value
    @searchFieldMainInput = ""
    patient.organizationId = @organization.idOnServer
    @addPatient patient

  addPatient: (patient)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: patient.idOnServer
      outdoorBalance: @outdoorBalance
      indoorBalance: @indoorBalance
    }
    @callApi '/bdemr-organization-add-patient', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'Patient Added Successfully'
        @_loadPatientList()
        @_loadWallet()

  _loadPatientList: ->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      searchString: ""
    }
    @callApi '/bdemr-organization-list-patient', data, (err, response)=>
      if response.hasError
        @domHost.showToast response.error.message
      else
        console.log response.data.matchingPatientList
        @set 'matchingPatientList', response.data.matchingPatientList

  removePatientPressed: (e)->
    {patient, index} = e.model
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: patient.patientId
    }
    @callApi '/bdemr-organization-remove-patient', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @splice 'matchingPatientList', index, 1

  viewPatientExpenseHistoryPressed: (e)->
    { patient, index } = e.model
    text = ["Outdoor Expenses:"]
    for expense in patient.outdoorTransactionHistory
      text.push (expense.notes + " - " + expense.amountInBdt + " BDT - " + @$mkDate(expense.createDatetimeStamp))
    text.push ''
    text.push "Indoor Expenses:"
    for expense in patient.indoorTransactionHistory
      text.push (expense.notes + " - " + expense.amountInBdt + " BDT - " + @$mkDate(expense.createDatetimeStamp))
    @domHost.showModalDialog text

  ## Role Manager - end

}
