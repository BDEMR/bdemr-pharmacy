
Polymer {

  is: 'page-view-user-profile'

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
      value: -> app.db.find('user')[0]

    organization:
      type: Object
      value: -> app.db.find('organization')[0]
  
    profileUser:
      type: Object
      value: null

    requestingUserId:
      type: String
      value: null

    profileImage:
      type: String
      value: null
      notify: true


  _notifyInvalidUserId: ->
    @showModal 'Invalid User ID Provided'

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _getUserInfo: ()->
    data = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      @requestingUserId
    }
    @domHost.toggleModalLoader 'Getting user Information...'
    @callApi '/bdemr-joining-organization-request-user-info', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        profileUser = response.data
        profileUser.fullName = @$getFullName profileUser.name
        if profileUser.profileImage
          @set 'profileImage', profileUser.profileImage
        else
          @set 'profileImage', 'images/avatar.png'

        @set 'profileUser', profileUser
        console.log 'profile user', profileUser

  

  navigatedIn: ->
    params = @domHost.getPageParams()
    unless params['userId']
      @_notifyInvalidUserId()
      return
    @requestingUserId = params['userId']
    console.log 'parsed user id', @requestingUserId
    @_getUserInfo()


  verifyUserButtonPressed: ()->
    @domHost.showModalPrompt "Verify this user?", (answer)=>
        if answer
          @_verifyUser()


  _verifyUser: ()->
    data = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: @requestingUserId
      profileVerifiedDateTime: lib.datetime.now()
    }
    @callApi '/bdemr-organization-verify-user-within', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog 'User Verified'
        @domHost.navigateToPage '#/organization-manage-users/organization:' + @organization.idOnServer


}
