
Polymer {

  is: 'page-print-respirator-fit-test'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    fitTestReport:
      type: Object
      notify: true
      value: null

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    loadingCounter:
      type: Number
      notify: true
      value: -> 0


  navigatedIn: ->
    @_loadUser()
    console.log @organization
    console.log @settings

    params = @domHost.getPageParams()
    unless params['report']
      return
    
    @_loadFitTestReport params['report']



  loadOrganization: (orgId)->
    data = {
      apiKey: @user.apiKey
      organizationId: orgId
    }
    @callApi '/get-organization-info', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        organization = response.data
        @set 'organization', organization
        console.log @organization

  
  navigatedOut: ->
    @settings = {}
    @fitTestReport = {}

  # _getSettings: ->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization.printSettings
  #         @settings.printDecoration = @organization.printSettings
  #   else
  #     @domHost.showModalDialog 'No Settings Found'
  
  _loadUser:()->
    userList = app.db.find 'user'
    # console.log userList
    if userList.length is 1
      @user = userList[0]


  $of: (a, b)->
    unless b of a
      a[b] = null
    return a[b]


  printButtonPressed: (e)->
    window.print()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'No Patient details available for this invoice!'


  _isBothRetestAndReasonVisible: (fitTestResult)->
    return unless fitTestResult
    return fitTestResult.toLowerCase() is 'unfit'

  _isRetestReasonVisible: (isretestRequired)->
    return unless isretestRequired
    return isretestRequired.toLowerCase() is 'yes'

  _loadFitTestReport: (reportIdentifier)->
    @loadingCounter++
    list = app.db.find 'covid-respirator-fit-test', ({serial})-> serial is reportIdentifier
    if list.length is 1
      @set 'fitTestReport', list[0]
      console.log 'fit test report', @fitTestReport
      @loadingCounter--


  _notifyInvalidInvoice: ->
    @domHost.showModalDialog 'Invalid Invoice Provided'


  _returnSerial: (index)->
    index+1

  getBoolean: (data)-> if data then true else false
  
}
