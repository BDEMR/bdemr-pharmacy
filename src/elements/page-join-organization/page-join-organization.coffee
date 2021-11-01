
Polymer {

  is: 'page-join-organization'

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

    organization:
      type: Object
      notify: true
      value: null

    organizationSearchResultList:
      type: Array
      value: -> []

    parentList:
      type: Array
      value: -> []


  navigatedIn: ->
    @_loadUser()
  

  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false
    @organizationSearchResultList = []
    @parentList = []
  

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      console.log 'user', @user


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    params = @domHost.getPageParams()
    if params['organization'] is 'new'
      @_createOrganization =>
        @domHost.showToast 'Organization Created'
        @arrowBackButtonPressed()
    else
      @_updateOrganization =>
        @domHost.showToast 'Organization Updated'
        @arrowBackButtonPressed()
  
  # Custom function to convert facility labels strings into pascal case strings
  toCamelCase: (str) -> 
    strArray = str.split(' ')
    strToBeLowerCassed = strArray.shift()
    lowerCaseOperation = strToBeLowerCassed.toLowerCase()
    strArray2 = strArray.unshift(lowerCaseOperation)
    joinedString = strArray.join('')
    return joinedString

  addOtherFacilities: (e)->
    if e.which is 13
      return unless @facilities
      newFacility = {
        label: @facilities
        key: @toCamelCase(@facilities)
        isChecked: false
      }
      @push 'organization.otherFacilitiesList', newFacility
      console.log @organization.otherFacilitiesList
      @facilities = ""

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  _createOrganization: (cbfn)->
    data = Object.assign @organization, {apiKey: @user.apiKey}
    @callApi '/bdemr-organization-create', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  _updateOrganization: (cbfn)->
    currentOrganization = @getCurrentOrganization()
    if currentOrganization.idOnServer is @organization.idOnServer
      app.db.upsert 'organization', currentOrganization, ({idOnServer})=> currentOrganization.idOnServer is idOnServer
      
    data = Object.assign @organization, {apiKey: @user.apiKey, organizationId: @organization.idOnServer}
    @callApi '/bdemr-organization-update', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()


  searchOrganizationTapped: (e)->
    data = { 
      apiKey: @user.apiKey
      searchString: @organizationSearchString
    }
    @callApi '/bdemr-joining-organization-search', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'organizationSearchResultList', response.data.organizationList
        console.log 'matching organizations', @organizationSearchResultList



  _makeJoiningRequestObject: (organizationJoining, currentUser)->
    joiningRequest = {
      organizationId: organizationJoining.idOnServer
      requestingUserId: currentUser.idOnServer
      requestingDateTime: lib.datetime.now()
      isResolved: false
      isAccepted: false
      resolvingUserId: null
      resolvingDateTime: null
    }
    return joiningRequest

  
  joinOrganizationTapped: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    repeater = @$$ '#organization-list-repeater'
    index = repeater.indexForElement el
    joiningOrg = @organizationSearchResultList[index]
    console.log 'pressed org', joiningOrg

    @domHost.showModalPrompt "Send joining request to #{joiningOrg.name} (Serial: #{joiningOrg.serial})?", (answer)=>
      if answer
        request = @_makeJoiningRequestObject(joiningOrg, @user)
        console.log 'joining request', request
        data = {
          apiKey: @user.apiKey
          joiningRequest: request
        }
        @callApi '/bdemr-joining-organization-request', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            @set "organizationSearchResultList.#{index}.isJoiningRequestPending", true
            @domHost.showModalDialog 'Request sent successfully!'
  

  $in: (value, list)-> 
    value in list

  _loadOrganization: (idOnServer)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        organization = response.data.matchingOrganizationList[0]

        if typeof organization.serial is 'undefined'
          organization.serial = ''
        
        @set 'organization', organization
        @set 'isOrganizationValid', true
        @_loadParentList()
        if !@organization.printSettings
          @organization.printSettings = @getprintSettingsObject()

  _loadParentList: ->
    data = { 
      apiKey: @user.apiKey
      idList: @organization.parentOrganizationIdList
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'parentList', response.data.matchingOrganizationList

}
