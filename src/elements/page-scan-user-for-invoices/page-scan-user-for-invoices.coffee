Polymer {
  is: 'page-scan-user-for-invoices'

  behaviors: [
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.commonComputes
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

    invoiceList:
      type: Array
      notify: true
      value: null

    scannedUser:
      type: Object
      value: null
    
    isQrCodeActive:
      type: Boolean
      value: false

  _resetQrCode:()->
    @set 'isQrCodeActive', true
    @set 'invoiceList', null
  
  _onQrCodeChanged: (e)->
    code = e.detail.result.text
    if code
      @_loadInvoice code
    
  
  _loadInvoice: (code)->

    data = {
      patientSerial: code
      organizationId: @organization.idOnServer
      apiKey: @user.apiKey
    }

    @set "isLoading", true
    @set 'isQrCodeActive', false

    @loadingCounter += 1
    @callApi '/bdemr--patient-invoice-get-api', data, (err, response)=>
      @set "isLoading", false
      if response.hasError
        # @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        invoiceList = response.data
        notCompletedInvoiceList = (item for item in invoiceList when item.flags.markAsCompleted isnt true)
        @set 'invoiceList', invoiceList
        @set 'invoiceListWithoutCompleted', notCompletedInvoiceList
        # console.log 'invoice list', @invoiceList
  
  _startScanning: ()->
    @set 'isQrCodeActive', true


  navigatedIn: ->
    console.log @organization, @user

  navigatedOut: ->
    @set 'isQrCodeActive', false
   
  
    
    

}