Polymer {
  is: 'page-organization-qrcode'

  behaviors: [
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]

  properties:
    code:
      type: String
      value: null
    
    organization:
      type: Object
      value: (app.db.find 'organization')[0]

    user:
      type: Object
      value: (app.db.find 'user')[0]
    
    timeDiff: 
      type: Number
      value: 0
      notify: true
    
    displayCounter:
      type: String
      value: ''


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
    

  _getRemainingTime: ()->
    this.timeDiff = this.timeDiff - 1000
    if this.timeDiff > 0
      lib.util.delay 1000, ()=>
        seconds = Math.floor (this.timeDiff / 1000)
        ss = seconds % 60
        minutes = Math.floor (seconds / 60)
        mm = minutes % 60 
        hours = Math.floor (minutes / 60)
        hh = hours
        @set 'displayCounter', "Expire in #{hours}:#{mm}:#{ss}"
        @_getRemainingTime()
    else
      @set 'displayCounter', "Code Expired!"
      location.reload()
  
  nextCount: ()->
    this.timeDiff = this.timeDiff - 1000
    if(this.timeDiff > 0)
      this.async this.nextCount, null, 1000
  

  _getOrganizationQrCode: ()->
    @set 'code', ''
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @set 'displayCounter', "Generating Code..."
    @domHost.callApi '/get-organization-qr-code', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        @set 'code', response.data.code
        @timeDiff = response.data.timeDiff
        @_getRemainingTime()
   
  navigatedIn: ->
    @_getOrganizationQrCode()

}