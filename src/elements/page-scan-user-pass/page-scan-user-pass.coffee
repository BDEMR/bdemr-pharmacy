Polymer {
  is: 'page-scan-user-pass'

  behaviors: [
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.translating
  ]


  properties:
    isLoading:
      type: Boolean
      value: false

    user:
      type: Object
      value: (app.db.find 'user')[0]
    
    organization:
      type: Object
      value: (app.db.find 'organization')[0]

    scannedUser:
      type: Object
      value: null
    
    categoryList:
      type: Array
      value: ['Category 1', 'Category 2', 'Category 3']
    
    reasonList:
      type: Array
      value: ['Reason 1', 'Reason 2', 'Reason 3']
    
    isQrCodeActive:
      type: Boolean
      value: false

  _resetQrCode:()->
    @set 'isQrCodeActive', true
    @set 'scannedUser', null
  
  _onQrCodeChanged: (e)->
    code = e.detail.result.text
    if code
      @_getUserPassProfile code
    
  
  _getUserPassProfile: (code) ->
    data = 
      apiKey: @user.apiKey
      code: code
      organizationId: @organization.idOnServer

    @set "isLoading", true
    @set 'isQrCodeActive', false
    
    @callApi '/bdemr-verify-pass-code', data, (err, response)=>
      @set "isLoading", false
      if response.hasError
        if response.error.message is 'CODE_EXPIRED'
          @domHost.showModalDialog "Your Passed Expired Already!"
        else
          @domHost.showModalDialog response.error.message
      else
        data = response.data
        @set "scannedUser", data
  
  _startScanning: ()->
    @set 'isQrCodeActive', true
    
  
  _onSaveBtnPressed: ()->
    data =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      scannedUserId: @scannedUser.idOnServer
      reason: @scannedUser.reason
      purpose: @scannedUser.purpose
      category: @scannedUser.category
      apiKey: @user.apiKey
      code: @scannedUser.code

    @callApi '/bdemr-set-pass-scan-logs', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast "Saved Successfully!"
        @_resetQrCode()

  navigatedIn: ->

  navigatedOut: ->
    @set 'isQrCodeActive', false
   
  
    
    

}