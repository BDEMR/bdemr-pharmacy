
Polymer {

  is: 'page-select-organization'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    isLoading:
      type: Boolean
      value: false

    user:
      type: Object
      notify: true
      value: null

    localStrgOrgObj:
      type: Object
      notify: true
      value: null

    organizationsIBelongToList:
      type: Array
      value: -> []
    
    selectedOrganizationIndex:
      type: Number
      notify: true
      value: 0

    selectedUserRoleIndex:
      type: Number
      notify: true
      value: 0
      
    
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
    
  _loadUser:()->
    userList = app.db.find 'user'
    

    if userList.length is 1
      @user = userList[0]

  organizationSelected: (e)->
    return unless e.detail.value
    selectedOrganizationId = e.detail.value
    selectedOrganization = @organizationsIBelongToList.find (item)=> item.idOnServer is selectedOrganizationId
    console.log {selectedOrganization}
    if selectedOrganization
      @set 'selectedOrganization', selectedOrganization
      @set 'userRoleList', selectedOrganization.userRoleList
  
  $notUndefined: (value)-> if value? then true else false

  _checkOrganizationActivation: (daysLeft, cbfn)->
    if daysLeft < 0
      @domHost.navigateToPage '#/activate/type:organization'
      return

    if daysLeft <= 7
      @domHost.showModalPrompt "Your Organization account will expire in #{daysLeft} days. Click 'Confirm' to Navigate Activate page.", (answer)=>
        if answer is true
          @domHost.navigateToPage '#/activate/type:organization'
          return
        else
          cbfn()
    
    if daysLeft > 7
      cbfn()

    

  navigatedIn: ->
    @_loadUser()
    @_findOrganizationsUserBelongsTo @user.apiKey
    @isUserAgent = @domHost.isUserAgent
    console.log 'agent' ,@isUserAgent
    

    
  navigatedOut: ->
    @isOrganizationValid = false
    @memberSearchResultList = []
    @memberList = []

  _findOrganizationsUserBelongsTo: (apiKey)->
    @isLoading = true
    @callApi '/bdemr-organization-list-those-user-belongs-to-new', {apiKey: apiKey}, (err, response)=>
      @isLoading = false
      if err
        return @domHost.showModalDialog 'Server is not responding'
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @organizationsIBelongToList = response.data.organizationObjectList
        # @mappedOrganizationList = response.data.organizationObjectList.map (item)-> {label: item.name, value: item.idOnServer}
  
  expiredWarningClass: (daysLeft)->
    return 'expired' if daysLeft < 7
  _getUserInfo: ()->
    @domHost.toggleModalLoader 'Getting your Information...'
    @callApi '/get-user-info', { apiKey: @user.apiKey, organizationId: @organization.idOnServer }, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        user = response.data
        user.fullName = @$getFullName user.name
        user.apiKey = @user.apiKey

        @set 'user', user
        console.log 'user', @user

  navigateWithOrganizationSelected: ->

    if @selectedOrganization
      @_callToGetSelectedOrgFullInfo @selectedOrganization.idOnServer, (organization)=>
        organization.daysLeft = @selectedOrganization.daysLeft
        organization.accountExpiresOnDate = @selectedOrganization.accountExpiresOnDate
        # cleared organization collection and add insert new organization object
        app.db.remove 'organization', item._id for item in app.db.find 'organization'
        app.db.insert 'organization', organization

        @_checkOrganizationActivation organization.daysLeft, =>

          selectedUserRole = @userRoleList[@selectedUserRoleIndex]
          if selectedUserRole
            @_getUserRoleDetails selectedUserRole, organization, =>
              console.log 'roleList' , @roleList
              @domHost.navigateToPage "#/pharmacy-manager"
              window.location.reload()
          else
            if @isUserAgent
              @domHost.navigateToPage "#/pharmacy-manager"
              window.location.reload()
            else
              @domHost.navigateToPage "#/pharmacy-manager"
              window.location.reload()

    else
      @domHost.showModalDialog "Chose an Organization to Continue"

  _getUserRoleDetails: (selectedRole, organization, cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: organization.idOnServer
      roleId: selectedRole.serial
    @callApi '/bdemr-get-user-role-details-from-belong-organization', data , (err, response)=>
      if err
        return @domHost.showModalDialog 'Server is not responding'
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        # selectedOrganization = @organizationsIBelongToList[@selectedOrganizationIndex]
        organization.userActiveRole = response.data
        @roleList=organization.userActiveRole
        app.db.upsert 'organization', organization, ({idOnServer})=> organization.idOnServer is idOnServer 
        cbfn()


  _callToGetSelectedOrgFullInfo: (organizationId, cbfn)->
    data = {
      apiKey: @user.apiKey
      organizationId: organizationId
    }
    @callApi '/get-organization-info', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        organization = response.data
        cbfn organization


  createOrganizationButtonPressed: ->
     @domHost.navigateToPage "#/organization-editor/organization:new"

  joinOrganizationButtonPressed: ->
     @domHost.navigateToPage "#/join-organization"

  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false
}
