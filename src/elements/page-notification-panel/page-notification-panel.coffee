Polymer {
  is: 'page-notification-panel'

  behaviors: [
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.dbUsing
    app.behaviors.commonComputes
  ]
  
  properties:
    user:
      type: Object
      value: null
    organization:
      type: Object
      value: null
    selectedPage:
      type: Number
      value: -> 0
    selectedGroupMessageView:
      type: Number
      value: -> 0
    searchFieldMainInput: 
      type: String
      notify: true
      value: ''
    selectedUserId:
      type: String
      value: ''
    roleSelected:
      type: Number
      value: 0
    userGroup:
      type: Array
      value: -> []
    notificationGroupList:
      type: Array
      value: -> []
  
  
  navigatedIn: ->
    @_loadUser()
    @_loadOrganization()
    @loadGroupList()
  
  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadOrganization: ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
    else
      @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'
  
  
  _searchUser: (id, searchQuery)->
    return unless searchQuery
    @callApi '/bdemr-user-search-for-notification', {searchString: searchQuery}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length > 0
          userSuggestionArray = (item for item in data)
          @$$("##{id}").suggestions userSuggestionArray
        else
          @domHost.showToast 'No Match Found'
  
  userSearchEnterKeyPressed: (e)->
    return unless e.keyCode is 13
    if @selectedPage is 0 then id = 'userSearch' else id = 'groupUserSearch'
    searchQuery = @$$("##{id}").text
    @_searchUser(id, searchQuery)

  userSearchButtonPressed: ->
    if @selectedPage is 0 then id = 'userSearch' else id = 'groupUserSearch'
    searchQuery = @$$("##{id}").text
    @_searchUser(id, searchQuery)

  userSelected: (e)->
    @set 'selectedUserId', e.detail.value

  userAddedToGroup: (e)->
    user = e.detail.option
    if @userGroup.length > 10
      @domHost.showModalDialog "Can't send notification to more than 10 people"
      return
    if (@userGroup.findIndex (item)=> item.idOnServer is user.idOnServer) > -1
      @domHost.showModalDialog "User Already added"
      return
    @push 'userGroup', user
    @async => @$$("#groupUserSearch").clear()


  userSearchCleared: ->
    id = if @selectedPage is 0 then 'userSearch' else 'groupUserSearch'
    @$$("##{id}").clear()

  notificationSendButtonPressed: ->
    this._chargePatient @selectedUserId, 1, 'Payment BDEMR Doctor Generic', (err)=>
      if (err)
        @domHost.showModalDialog("Unable to charge the patient. #{err.message}")
        return
      @_sendNotification @selectedUserId, @notificationMessage
  
  groupNotificationSendButtonPressed: (e)->
    selectedGroup = e.model.item
    console.log selectedGroup
    unless selectedGroup.members.length 
      return @domHost.showToast 'The selected group has zero members. Create a new group with one or more members.'
    unless @groupNotificationMessage
      @domHost.showToast 'Write a message first to send as notification.'
      return
    
    for item in selectedGroup.members
      @_sendNotification item.idOnServer, @groupNotificationMessage
    
    lib.util.delay 100, ()=>
      @domHost.showToast 'Message sent'
      @groupNotificationMessage = ""

  _sendNotification: (userId, message)->  
    unless userId
      @domHost.showModalDialog 'target user id is missing'
    unless userId
      @domHost.showModalDialog 'target user id is missing'

    user = @getCurrentUser()
    request = {
      operation: 'notify-single'
      apiKey: user.apiKey
      notificationCategory: 'general'
      notificationMessage: message
      notificationTargetId: userId
      sender: user.name
    }
    @domHost.socket.emit 'message', request
    @domHost.showModalDialog 'Successfuly Sent'

  
  smsSendButtonPressed: (e)->
    unless @selectedUserId
      @domHost.showWarningToast 'Select an User from Search'
      return
    unless @notificationMessage
      @domHost.showWarningToast 'Write a message to be sent.'
      return

    @domHost.showModalPrompt 'SMS Sending will cost you 1.23 BDT/sms. Are you sure?', (done)=>
      if done
        data =
          apiKey: @getCurrentUser().apiKey
          receiverUserId: @selectedUserId
          phoneNumber: null
          smsBody: @notificationMessage
        
        @callApi '/send-individual-sms', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            @domHost.showModalDialog 'Successfuly Sent'

  arrowBackButtonPressed: (e)->
    window.location = '#/dashboard'

  loadGroupList: ->
    if @selectedGroupMessageView is 0
      @notificationGroupList = (app.db.find 'user-defined-notification-group')
  
  createNewGroupButtonPressed: -> @selectedGroupMessageView = 1
  backToSendGroupNotification: -> @selectedGroupMessageView = 0

  saveGroup: ->
    @$$("#groupName").validate()
    return unless @groupName and @userGroup.length
    group = 
      serial: @generateSerialForNotificationGroup()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      groupName: @groupName
      members: @userGroup
    app.db.insert 'user-defined-notification-group', group

    @groupName = ""
    @userGroup = []

    @selectedGroupMessageView = 0

  deleteList: (e)->
    {item, index} = e.model
    @domHost.showModalPrompt 'Are you sure to delete this list', (response)=>
      if response is true
        deleted = app.db.remove 'user-defined-notification-group', item._id
        if deleted
          @splice 'notificationGroupList', index, 1
          app.db.insert 'user-defined-notification-group--deleted', {serial:item.serial}
}