Polymer {

  is: 'page-internal-inventory-transaction-print'

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

    isRecordValid:
      type: Boolean
      value: false

    record:
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

  _notifyInvalidRecord:() ->
    @isRecordValid = false
    @domHost.showModalDialog 'Invalid record!'

  loadRecord: (recordIdentifier) ->
    list = app.db.find 'organization-internal-inventory-transaction', ({serial}) -> serial is recordIdentifier

    if list.length is 1
      @record = list[0]
      @isRecordValid = true
    else
      @_notifyInvalidRecord()
    
    console.log @record

  navigatedIn: ->
    console.log 'hre'

    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"

    params = @domHost.getPageParams()

    @_loadUser()
    @_getSettings()
    
    if params['record']
      @loadRecord params['record']
    else
      @_notifyInvalidRecord()


  navigatedOut: ->
    @patient = null
    @isPatientValid = false
    @testResults = null

}
