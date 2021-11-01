Polymer {
  is: 'page-access-management'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    
    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    selectedUser:
      type: Object
      value: null
    
    userSearchQuery:
      type: String
      value: -> ""
      observer: 'userSearchInputChanged'
    
    privilegeList:
      type: Array
      value: []
    
    activeItem:
      observer: '_activeItemChanged'
  

  _activeItemChanged: (e, item)->
    copyItem = lib.util.deepCopy e

    if (this.userList && this.userList.length > 0)
      if e
        this.$.userList.selectedItems = [copyItem] or []

        selectedUser = copyItem

        selectedUser.privilegeList = @_getUserPrivilegeList selectedUser.specialPrivilegedAccessIdList

        @set 'selectedUser', copyItem
      else
        @selectedUser = null
       
  _getUserPrivilegeList: (idList)->
    return @privilegeList if idList.length is 0

    list = @privilegeList.map (item) =>
      if idList.includes item.id
        item.isSelected = true

      return item
    
    return list
  
  _getUserPrivilegesByString: (idList)->
    return '' if idList.length is 0
    str = ''

    @privilegeList.forEach (item) =>
      console.log idList.includes item.id
      if idList.includes item.id
        str += item.name + ", "
    
    index = str.lastIndexOf ", "

    str = str.substring 0, index 

    console.log str
    
    return str
   
  userSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    @debounce 'search-user', ()=>
      @_userSearch(searchQuery)
    , 1000

  
  _userSearch: (searchQuery)->
    return unless searchQuery
    @$$("#userSearch").items = []
    @fetchingUserSearchResult = true;
    @callApi '/bdemr-access-management-user-search', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingUserSearchResult = false
      if response.hasError
        # @domHost.showModalDialog response.error.message
        @domHost.showToast 'No Match Found!'
        @_clearSelectedUserData()
      else
        @matchingUserdata = response.data
        console.log @matchingUserdata
        if @matchingUserdata.length > 0
          @$$("#userSearch").items = @matchingUserdata
          
  userSelected: (e)->
    return unless e.detail.value

    selectedUser = e.detail.value

    selectedUser.privilegeList = @_getUserPrivilegeList selectedUser.specialPrivilegedAccessIdList

    @set "selectedUser", e.detail.value
  
  _clearSelectedUserData: ()->
    @set "userSearchQuery", ''
    @set "selectedUser", null
    @$$("#userSearch").value = ""
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _getPrivilegedFeatureListForAccessManagement: ()->
    data =
      apiKey: @user.apiKey

    @callApi '/get-privileged-feature-list-for-access-management', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'privilegeList', response.data

  _saveUserAccess: ()->
    console.log @selectedUser.privilegeList
    selectedAccessIdList = @selectedUser.privilegeList.filter (item) => item.isSelected

    console.log @selectedUser, selectedAccessIdList
    if selectedAccessIdList.length is 0
      return @domHost.showToast "Please check atleast one privileged item first!"
    
    accessIdList = selectedAccessIdList.map (item) => item.id

    @_callSetUserAccessApi accessIdList, =>
      @_callGetAllUserThatHaveLimitedAccess()

  _callSetUserAccessApi: (accessIdList, cbfn)->
    data =
      apiKey: @user.apiKey
      specialPrivilegedAccessIdList: accessIdList
      selectedUserId: @selectedUser.userId
      hasLimitedAccess: @selectedUser.hasLimitedAccess

    @callApi '/bdemr-set-user-access', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast "Updated Successfully."
        cbfn()
  
  _getPrivilegesForUsers: (userList)->
    newList = []
    for user in userList
      user.privileges = @_getUserPrivilegesByString user.specialPrivilegedAccessIdList
      newList.push user
    
    return newList;

  
  _callGetAllUserThatHaveLimitedAccess: ()->
    data =
      apiKey: @user.apiKey

    @callApi '/get-all-user-that-have-limited-access', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        userList = response.data
        userList = @_getPrivilegesForUsers userList

        console.log userList
        @set 'userList', response.data
      
  navigatedIn: ->
    @_getPrivilegedFeatureListForAccessManagement()
    @_callGetAllUserThatHaveLimitedAccess()

    
} 