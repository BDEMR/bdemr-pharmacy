
Polymer {

  is: 'page-activate'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.dbUsing
  ]

  properties:

    selectedPage:
      type: Number
      value: 0
    
    isLoading:
      type: Boolean
      value: false

    activationCode: 
      type: String
      notify: true
      value: ''
      observer: 'activationCodeChanged'

    isValid: 
      type: Boolean
      notify: true
      value: false

    daysWorth:
      type: Number
      notify: true
      value: 0

    daysLeft:
      type: Number
      notify: true
      value: 0
    
    activationType:
      type: Object
      value: null
    
    organization:
      type: Object
      value: -> (app.db.find 'organization')[0]
  
  arrowBackButtonPressed: ->
    @domHost.navigateToPreviousPage();
  
  activationCodeChanged: ->
    @isValid = false
    @daysWorth = 0
  
  expiredWarningClass: (daysLeft)->
    return 'expired' if daysLeft < 7

  checkButtonPressed: (e)->
    { apiKey } = (app.db.find 'user')[0]

    @set 'isLoading', true
    @callApi '/check-activation-key', { key: @activationCode, apiKey: apiKey, type: @activationType }, (err, response)=>
      @set 'isLoading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @isValid = true
        @daysWorth = response.data.daysWorth

  activateButtonPressed: (e)->
    { apiKey } = (app.db.find 'user')[0]

    @set 'isLoading', true

    query = 
      key: @activationCode, 
      apiKey: apiKey, 
      type: @activationType
    
    if (query.type is 'organization')
      query.organizationId = @organization.idOnServer

    @callApi '/activate-activation-key', query, (err, response)=>
      @set 'isLoading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        if @activationType isnt 'organization'
          user = (app.db.find 'user')[0]
          user.accountExpiresOnDate = response.data.accountExpiresOnDate
          app.db.update 'user', user._id, user
          @domHost.navigateToPage '#/dashboard'
          @domHost.showModalDialog 'Activation Successful.'
        else
          @domHost.navigateToPage '#/select-organization'
          @domHost.showModalDialog 'Activation Successful.'

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  navigatedIn: ->
    params = @domHost.getPageParams()
    @set "activationType", null

    if params['type'] is 'organization'
      @set "activationType", 'organization'
      if (app.db.find 'organization').length is 0
        @domHost.navigateToPage '#/select-organization'
        return
      organization = (app.db.find 'organization')[0]
      dt = new Date organization.accountExpiresOnDate
      now = new Date lib.datetime.mkDate lib.datetime.now()
      diff = (lib.datetime.diff dt, now)
      if diff > 0
        @daysLeft = Math.floor (diff / 1000 / 60 / 60 / 24)
      @activationCode = ''

    else
      @set "activationType", 'user'
      if (app.db.find 'user').length is 0
        @domHost.logoutPressed()
        return
      user = (app.db.find 'user')[0]
      dt = new Date user.accountExpiresOnDate
      now = new Date lib.datetime.mkDate lib.datetime.now()
      diff = (lib.datetime.diff dt, now)
      if diff > 0
        @daysLeft = Math.floor (diff / 1000 / 60 / 60 / 24)
      @activationCode = ''

  logoutPressed: (e)->
    @removeAllUserInfo()
    @domHost.navigateToPage '#/login'


}
