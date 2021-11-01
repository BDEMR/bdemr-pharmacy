Polymer {
  is: 'my-pass-id-list'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    selectedIndex:
      type: Number
      value: 0

    list:
      type: Array
      value: [
        { name: 'Mahmudul Hasan', expireDatetimeStamp: '', purpose: '' },
      ]

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    reports:
      type: Array
      value: []
  

  _callGetMyPassScanReport: ()->
    data =
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-user-pass-scan-logs', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'reports', []
      else
        @set 'reports', response.data

  _callGetAllMyPassCards: ()->
    data =
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-all-my-pass-card-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'list', []
      else
        @set 'list', response.data

  _ontapItem: (e)->
    { item } = e.model
    @set "selectedItem", item
    @$$("#dialogShowBarcode").toggle()

  navigatedIn: ->
    @_callGetAllMyPassCards()
    @_callGetMyPassScanReport()
    
} 