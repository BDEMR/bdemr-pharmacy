""" Manage organization joining requests sent from join-organization
- requests can be accepted, rejected and/or profiles can be viewed and verified.

"""

Polymer {
  
  is: 'page-manage-joining-request'

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
    
    organization:
      type: Object
      value: {}

    pendingRequestList:
      type: Array
      value: -> []

    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    loadingCounter:
      type: Number
      value: -> 0


  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  navigatedIn: ->
    @_loadUser()
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer, ()=>
        @fetchPendingJoiningRequest()
    

  navigatedOut: ->
    @dateCreatedFrom = ''
    @dateCreatedTo = ''
    @selectedOrganizationId = ''

  getBoolean: (data)-> if data then true else false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  

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
    @set('selectedOrganizationId', organizationId)


  _loadChildOrganizationList: (organizationIdentifier, cbfn)-> 
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
      cbfn() if cbfn


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
    
  viewRequestDetailsButtonPressed: (e)->
    item = e.model.item
    console.log 'view request', item
    @domHost.navigateToPage '#/view-user-profile/userId:' + item.requestingUserId

  resetButtonClicked: -> return @domHost.reloadPage()
  

  fetchPendingJoiningRequest: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: []
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        showOnlyPending: true
        # searchString: @searchString
      }
    }

    # search parent+child when selecting all
    if !@selectedOrganizationId
      organizationIdList = @childOrganizationList.map (item)-> item.value
      organizationIdList.splice(0, 1, @organization.idOnServer)
      query.organizationIdList = organizationIdList
    else
      query.organizationIdList = [@selectedOrganizationId]

    @loadingCounter += 1
    @callApi '/bdemr-joining-organization-request-fetch-for-organization', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        requestList = response.data
        @set 'pendingRequestList', requestList
        console.log 'pending request list', @pendingRequestList


  acceptRequestButtonPressed: (e)->
    return unless e.model.item
    request = e.model.item
    @_resolveRequest(request, true)
    return


  rejectRequestButtonPressed: (e)->
    return unless e.model.item
    request = e.model.item
    @_resolveRequest(request, false)
    return

  
  _resolveRequest: (request, isAccepted)->
    request.isResolved = true
    request.isAccepted = isAccepted
    request.resolvingUserId = @user.idOnServer
    request.resolvingDateTime = lib.datetime.now()

    delete request['requestingUserInfo']
    console.log 'resolved request', request

    @callApi '/bdemr-joining-organization-request-resolve', { apiKey: @user.apiKey, joiningRequest: request }, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log 'request is resolved'
        if isAccepted
          @domHost.showToast 'Request Accepted'
        else
          @domHost.showToast 'Request Rejected'
        @fetchPendingJoiningRequest()
      return


}
