Polymer {
  is: 'page-scan-user-profile'

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
      @_getUserProfile code
    
  
  _getUserProfile: (code) ->
    data = 
      apiKey: @user.apiKey
      userSerial: code

    @set "isLoading", true
    @set 'isQrCodeActive', false
    
    @callApi '/get-user-public-info', data, (err, response)=>
      @set "isLoading", false
      if response.hasError
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
      category: @scannedUser.category
      apiKey: @user.apiKey

    @callApi '/bdemr-set-id-scan-logs', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast "Saved Successfully!"
        @_resetQrCode()

  navigatedIn: ->

  navigatedOut: ->
    @set 'isQrCodeActive', false
   
  
    
    

}