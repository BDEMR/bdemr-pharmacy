Polymer {

  is: 'page-operation-theater-management'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    otManagementList:
      type: Array
      value: ()-> []

    matchingOtManagementList:
      type: Array
      value: ()-> []

    organization:
      type: Object
      notify: true
      value: null

    user:
      type: Object
      notify: true
      value: null

    childOrganizationList:
      type: Array
      notify: true
      value: -> []

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

    otStatusIndex:
      type: Number
      value: 0

    surgeryPriorityIndex:
      type: Number
      value: 0

    loadingCounter:
      type: Number
      value: 0


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  navigatedIn: ->
    @_loadUser()
    @loadingCounter++
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer
      @loadingCounter--


   ### Operation theatre management start ###

  createOtListTapped: ()->
    @domHost.navigateToPage '#/create-operation-list'

  getOtStatusListIndex: (status)->
    return @otStatusList.indexOf(status)
    # console.log status
    
  getSurgeryPriorityListIndex: (priority)->
    return @surgeryPriorityList.indexOf(priority)
    # console.log status

  otManagementStatusChanged: (e)->
    DropDownSelectedStatus = @otStatusList[e.detail.selected]
    item = e.model.item
    item.data.otStatus = DropDownSelectedStatus
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.update 'ot-management', item._id, item


  surgeryPriorityChanged: (e)->
    DropDownSelectedStatus = @surgeryPriorityList[e.detail.selected]
    item = e.model.item
    item.data.surgeryPriorityStatus = DropDownSelectedStatus
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.update 'ot-management', item._id, item

  

  sendNotificationPressed:(e)->
    item = e.model.item
    patientName = @$getFullName(item.data.nameOfThePatient)
    message = "Patient: " + patientName + " , Operation Name: " + item.data.operationName + " , Theater Name: " + item.data.theaterName + ", Status: " + item.data.otStatus
    @_sendNotification(message, item.data.surgeon.id)
    @_sendNotification(message, item.data.assistantSurgeon1.id)
    @_sendNotification(message, item.data.assistantSurgeon2.id)
    @_sendNotification(message, item.data.assistantSurgeon3.id)
    @_sendNotification(message, item.data.anaesthesist.id)
    
   
  _sendNotification:(message, targetId)->
    return unless targetId
    user = @getCurrentUser()
    request = {
      operation: 'notify-single'
      apiKey: user.apiKey
      notificationCategory: 'general'
      notificationMessage: message
      notificationTargetId: targetId
      sender: user.name
    }
    @domHost.socket.emit 'message', request

  editOtButtonPressed:(e)->
    console.log "Edit"
    @domHost.navigateToPage '#/create-operation-list/OtManagementSerial:' + e.model.item.serial
  

  deleteOtButtonPressed:(e)->
    {item, index} = e.model
    console.log item, index
    @domHost.showModalPrompt "Are you sure you want to Delete?", (answer)=>
      if answer
        data = {
          id: item._id,
          apiKey: @user.apiKey          
        }
        @callApi 'bdemr--clinic-ot-list-delete', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog 'Could not delete this Operation Schedule, Something went Wrong'
          else
            @splice 'matchingOtManagementList', index, 1
            @domHost.showWarningToast 'Deleted'
            @searchButtonClicked()

  ### Operation Theatre Management Ends ###

  ### Search System ###

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
  
  searchButtonClicked: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: []
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        searchString: @searchString.toLowerCase()
        departmentSearchString: @departmentSearchString.toLowerCase()
      }    
    }
    
    # search parent+child when selecting all
    if !this.selectedOrganizationId
      organizationIdList = this.childOrganizationList.map (item)-> item.value
      organizationIdList.splice(0, 1, this.organization.idOnServer)
      query.organizationIdList = organizationIdList
    else
      query.organizationIdList = [this.selectedOrganizationId]

    @loadingCounter += 1
    @callApi '/bdemr--clinic-load-ot-list', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        matchingOtManagementList = response.data
        matchingOtManagementList.sort (a, b)-> b.data.operationDate - a.data.operationDate
        @set 'matchingOtManagementList', matchingOtManagementList
 

  _loadOrganization: (cbfn)->
    currentOrganization = @getCurrentOrganization()
    @loadingCounter++
    data = { 
      apiKey: @user.apiKey
      idList: [ currentOrganization.idOnServer ]
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

  organizationSelected: (e)->
    organizationId = e.detail.value;
    this.set('selectedOrganizationId', organizationId)

  _loadChildOrganizationList: (organizationIdentifier)-> 
    @loadingCounter++
    query = {
      apiKey: this.user.apiKey
      organizationId: organizationIdentifier
    }
    this.callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      @loadingCounter--
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        this.set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = this.$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: this.organization.name, value: this.organization.idOnServer }]
        organizationSelectorComboBox.value = this.organization.idOnServer

  resetButtonClicked: (e)->
    window.location.reload()    
}