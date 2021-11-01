Polymer {
  is: 'page-my-duty-roster'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    monthIndex:
      type: Number
      value: -> (new Date()).getMonth()
      observer: 'onMonthIndexChange'

    months:
      type: Array
      value: [
        {name: 'January', id: 1},
        {name: 'February', id: 2},
        {name: 'March', id: 3},
        {name: 'April', id: 4},
        {name: 'May', id: 5},
        {name: 'June', id: 6},
        {name: 'July', id: 7},
        {name: 'August', id: 8},
        {name: 'September', id: 9},
        {name: 'October', id: 10},
        {name: 'November', id: 11},
        {name: 'December', id: 12}
      ]

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    stats:
      type: Object
      value: null
    
    rosters:
      type: Array
      value: []
  
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  

  onMonthIndexChange: (index)->
    return if !@user
    @_callGetMyRosterAndReports()
  
  _computeTotalSlots: (a, b)->
    return a + b
  

  _callGetMyRosterAndReports: ()->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      monthId: @monthIndex

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-organization-get-my-roster-and-reports', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'rosters', []
        @set 'stats', null
        # @domHost.showModalDialog response.error.message
      else
        @set 'rosters', response.data.rosters
        @set 'stats', response.data.stats
  
  navigatedIn: ->
    @_callGetMyRosterAndReports()

    
} 