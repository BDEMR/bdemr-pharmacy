Polymer {

  is: 'page-store-audit-preview'

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

    isAuditValid:
      type: Boolean
      value: false

    audit:
      type: Object
      notify: true
      value: null

    settings:
      type: Object
      notify: true
      value: {}

  _getSettings: ->
    list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    if list.length > 0
      @settings = list[0]
      if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
        if @organization.printSettings
          @settings.printDecoration = @organization.printSettings      
    else
      @domHost.showModalDialog 'No Settings Found'      

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  printButtonPressed: (e)->
    window.print()

  
  _sortByDate: (a, b)->
    if a.date < b.date
      return 1
    if a.date > b.date
      return -1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')

  _returnSerial: (index)->
    index+1

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _notifyInvalidAudit:() ->
    @isAuditValid = false
    @domHost.showModalDialog 'Invalid audit!'

  _getAudit: (auditId)->
    @_getAuditApi auditId, =>
      null
  
  calcMissingAmount: (physicallyFound, inStock)->
    physicallyFound = parseInt physicallyFound
    return inStock - physicallyFound

  _getAuditApi: (auditIdentifier, cbfn)->
    data = 
      apiKey: @user.apiKey
      auditId: auditIdentifier
      organizationId: @organization.idOnServer
    
    @set 'isLoading', true
        
    @callApi '/get-organization-store-audit', data, (err, response)=>
      console.log response
      @set 'isLoading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @audit = response.data
        @set 'isAuditValid', true
        cbfn()
  

  navigatedIn: ->
    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"

    params = @domHost.getPageParams()

    @_loadUser()
    @_getSettings()
    
    if params['id']
      @_getAudit params['id']
    else
      @_notifyInvalidAudit()


  navigatedOut: ->
 

}
