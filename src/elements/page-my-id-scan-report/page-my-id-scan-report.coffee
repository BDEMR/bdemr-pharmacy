Polymer {
  is: 'page-my-id-scan-report'
  
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

    reports:
      type: Array
      value: []
  

  _callGetMyIdScanReport: ()->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-user-id-scan-logs', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'reports', []
      else
        @set 'reports', response.data
  
  navigatedIn: ->
    @_callGetMyIdScanReport()

    
} 