Polymer {
  is: 'page-patients-queue'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    organization:
      type: Object
      value: (app.db.find 'organization')[0]
    
    user:
      type: Object
      value: (app.db.find 'user')[0]
  


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _notifyInvalidChamber: ->
      @domHost.showModalDialog 'Invalid Chamber!'

  

  _callCheckTodaysPatientsQueueByChamber:(chamberSerial)->

    data =
      chamberSerial: chamberSerial
      apiKey: @user.apiKey

    @loading = true
    @domHost.callApi '/bdemr-check-todays-patients-queue-by-chamber', data, (err, response)=>
      console.log response
      @loading = false
      if response.hasError
        @set 'availableQueue', []
        @domHost.showWarningToast response.error.message
      else
        data = response.data
        @set 'availableQueue', data
        @_reloadWindow()
      
  _reloadWindow: ()->
    lib.util.delay 30000, ()=>
      location.reload()

  navigatedIn: ->
    params = @domHost.getPageParams()
    if params['chamber']
      chamberSerial = params['chamber']
      @_callCheckTodaysPatientsQueueByChamber chamberSerial
    else
      @_notifyInvalidChamber()
  
  



} 