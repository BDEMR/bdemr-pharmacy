""" Manage COVID lockdown areas
- only ab@bdemr.com is given live access for CRUD operations & doctor1@doctor1.com for dev mode
- an area along with its level can be added into current list. Level of an area can be updated and/or deleted from action

"""


Polymer {
  
  is: 'page-manage-covid-lockdown'

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
    
    loadingCounter:
      type: Number
      value: -> 0

    currentDateTime:
      type: Number
      value: lib.datetime.now()

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
   
    lockDownAreaSearchString:
      type: String
      value: ''
      # observer: 'filteringParametersChanged'
    
    addedLockDownAreas:
      type: Array
      value: []
    
    lockDownLevels:
      type: Array
      value: [
        'Red'
        'Yellow'
        'Green'
      ]
    
    authorizedUsers:
      type: Array
      value: ['doctor1@doctor1.com']

    editingAreaObject:
      type: Object
      value: {}


  # filteringParametersChanged: (patientNameSearchString)->
  #   lib.util.delay 300, ()=>
  #     tempPatientName = if patientNameSearchString then patientNameSearchString.trim().toLowerCase() else ''
  #     tempPatientPhone = if patientPhoneSearchString then patientPhoneSearchString.trim() else ''

  #     tempList = @invoiceList.filter (item)=>
  #       nameFlag = phoneFlag = false
  #       if (item.patientName) and ((tempPatientName is '') or (tempPatientName isnt '' and @$getFullName(item.patientName).toLowerCase().includes tempPatientName))
  #         nameFlag = true
  #       if (item.patientPhone) and ((tempPatientPhone is '') or (tempPatientPhone isnt '' and item.patientPhone.includes tempPatientPhone)) 
  #         phoneFlag = true
  #       return nameFlag and phoneFlag
      
  #     @set 'filteredInvoiceList', tempList
  #     console.log 'filtered list', @filteredInvoiceList


  
  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  

  navigatedIn: ->
    @_loadUser  =>
      unless @user.email in [ 'ab@bdemr.com', 'doctor1@doctor1.com' ]
        return @domHost.navigateToPage '#/page-error-404'
      @_loadLockDownAres =>


  getBoolean: (data)-> if data then true else false

  _loadUser:(cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
    cbfn() if cbfn

  # _loadSettings: ()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   @settings = {}
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization and @organization.printSettings
  #         @settings.printDecoration =  @organization.printSettings


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
  

  _loadLockDownAres: (cbfn)->
    query = {
      apiKey: @user.apiKey
    }
    @loadingCounter += 1
    @callApi '/bdemr--get-covid-lockdown-areas', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        @addedLockDownAreas = response.data
        console.log 'lockdown areas', @addedLockDownAreas
        cbfn() if cbfn

  updateLockDownArea: (area)->
    query = {
      apiKey: @user.apiKey
      area: area
    }
    @loadingCounter += 1
    @callApi '/bdemr--add-covid-lockdown-areas', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        @_loadLockDownAres =>
          @set 'newLockdownArea', ''
          @set 'newLockdownAreaLevel', ''
          @domHost.showToast response.data.message


  addToListButtonClicked: ()->
    addingContent = {
      createdAt: lib.datetime.now()
      createdById: @user.idOnServer
      createdByName: @user.name
      area: @newLockdownArea or ''
      level: @newLockdownAreaLevel or ''
      isArchived: false
      logs: []
    }
    addingContent.logs.push {
      createdBy: @user.name
      createdAt: addingContent.createdAt
      action: 'add'
      message: "#{@user.name} created area on #{@$formatDate addingContent.createdAt}"
    }
    @updateLockDownArea  addingContent
    


  editAreaBtnClicked: (e)->
    # @set 'tokenObject', null
    # @set 'tokenObject', token
    @set 'editingAreaObject', e.model.item
    console.log 'editing area before', @editingAreaObject
    @$$('#editAreaLevelDialog').toggle()

  
  editAreaLevelConfirmed:(e)->
    console.log 'editing area after', @editingAreaObject
    @editingAreaObject.logs.push {
      createdBy: @user.name
      createdAt: lib.datetime.now()
      action: 'edit'
      message: "#{@user.name} edited level to #{@editingAreaObject.level} on #{@$formatDate lib.datetime.now()}"
    }

    @updateLockDownArea @editingAreaObject
    @set 'editingAreaObject', null
    @$$('#editAreaLevelDialog').close()

  
  deleteAreaBtnClicked: (e)->
    deletingContent = e.model.item
    deletingContent.logs.push {
      createdBy: @user.name
      createdAt: lib.datetime.now()
      action: 'delete'
      message: "#{@user.name} deleted area on #{@$formatDate lib.datetime.now()}"
    }
    deletingContent.isArchived = true
    console.log 'deleting', deletingContent
    @updateLockDownArea deletingContent

  
}
