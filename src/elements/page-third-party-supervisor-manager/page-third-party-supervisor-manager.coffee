
Polymer {
  
  is: 'page-third-party-supervisor-manager'

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

    thirdPartySupObj:
      type: Object
      value: {}
   
    newThirdParty:
      type: Object
      value: {}

    isLoading:
      type: Boolean
      value: false

    thirdPartySuperVisorList:
      type: Array
      value: -> []

    thirdPartyPaymentListFiltered:
      type: Array
      value: -> []

    supervisorSearchQuery:
      type: String
      value: -> ""
      observer: 'userSearchInputChanged'

    thirdPartyUserSearchQuery:
      type: String
      value: -> ""
      observer: 'userSearchInputChanged'

  

  navigatedIn: ->
    @isLoading = true
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>    
      @isLoading = false
      @_makeNewThirdPartySuperVisor()
      @_addNewThirdParty()
      @loadSuperVisorList()
     


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _loadOrganization: (cbfn)->
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        
        cbfn()
    
  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'

  _makeNewThirdPartySuperVisor: ()->
    @thirdPartySupObj = {
      serial: @generateSerialForThirdPartySuperVisor()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      superVisorName: ''
      superVisorMobile: ''
      superVisorId: null 
      thirdPartyArr: []
    }

  _addNewThirdParty: ()->
    @newThirdParty = {
      thirdPartyName: ''
      thirdPartyMobile: ''
      thirdPartyId: null
    }
    

  _addAnotherThirdParty: ()->
    @_addNewThirdParty()

  userSearchInputChanged: (searchQuery)->
    @debounce 'search-user', ()=>
      @_searchUser(searchQuery)
    , 500
  
  _searchUser: (searchQuery)->
    return unless searchQuery
    @fetchingUserSearchResult = true;
    @callApi '/bdemr-user-search-for-notification', { searchString: searchQuery}, (err, response)=>
      @fetchingUserSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length > 0
          if @supervisorSearchQuery then  @$$("#userSearch").items = data
          if @thirdPartyUserSearchQuery then  @$$("#thirdPartyUserSearch").items = data
        else
          @domHost.showToast 'No Match Found'
  

  superVisorSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @set 'thirdPartySupObj.superVisorName', user.name
    @set 'thirdPartySupObj.superVisorMobile', user.phone
    @set 'thirdPartySupObj.superVisorId', user.idOnServer  

  thirdPartySelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @set 'newThirdParty.thirdPartyName', user.name
    @set 'newThirdParty.thirdPartyMobile', user.phone
    @set 'newThirdParty.thirdPartyId', user.idOnServer
    @push "thirdPartySupObj.thirdPartyArr", @newThirdParty
    @_addNewThirdParty()

  showSupervisorDialog: ()->
    @$$('#addNewSuperVisorObj').open()
    
  addThirdPartyAndSuperVisorBtnPressed: ()->
    console.log @thirdPartySupObj
    @thirdPartySupObj.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'third-party-supervisor-list', @thirdPartySupObj, ({serial})=> @thirdPartySupObj.serial is serial
    @$$('#addNewSuperVisorObj').close()
    window.location.reload()

  _returnSerial: (index)->
    index+1


  loadSuperVisorList: ()->
    thirdPartySuperVisorList = app.db.find 'third-party-supervisor-list', ({organizationId})=> organizationId is @organization.idOnServer
    @set 'thirdPartySuperVisorList', thirdPartySuperVisorList
    console.log @thirdPartySuperVisorList  

  deleteButtonPressed:(e)->
    {item, index} = e.model
    @splice 'thirdPartySuperVisorList', index, 1
    app.db.remove 'third-party-supervisor-list', item._id
    console.log "Deleted"

  editButtonPressed:(e)->
    @domHost.showModalDialog '▲ This Feature is Under Developement ▲'

}