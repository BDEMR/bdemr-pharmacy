
Polymer {

  is: 'page-blank-prescription'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:

    hideOnBlankPrint:
      type: Boolean
      value: false
    
    doctorName:
      type: String
      value: null

    isVisitValid: 
      type: Boolean
      notify: false
      value: false

    isPatientValid:
      type: Boolean
      notify: false
      value: false      

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    invoice:
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

    printType:
      type: String
      value: ''

    isPrintTypeAvailable:
      type: Boolean
      value: false

    isFullPaid:
      type: Boolean
      value: false
    
    address:
      type: String
      value: null

  checkIfDoctorFeesAvailable: (data)->
    return false if data.length is 0
    product = data.filter (item) => item.category is 'doctor-visit'
    return false if product.length is 0
    return false if product.length > 1
    return true if product.length is 1

  getDoctorNameIfDoctorFeesAvailable: (data)->
    return null if data.length is 0
    product = data.filter (item) => item.category is 'doctor-visit'
    return null if product.length is 0
    return null if product.length > 1
    return product[0].name if product.length is 1
  
  _calculateTotalBill: (data)->
    console.log data
    return 0 if !data
    accumulator = 0
    for item in data
      accumulator = accumulator + (parseFloat(item.price) * parseInt(item.qty))
    return accumulator

  navigatedIn: ->
    
    @_loadUser()
    params = @domHost.getPageParams()
    unless params['invoice']
      @_notifyInvalidVisit()
      return
    @_loadInvoice params['invoice'], ()=>
      @set 'doctorName', @getDoctorNameIfDoctorFeesAvailable @invoice.data
      if @invoice.patientSerial
        @_loadPatient @invoice.patientSerial

    @_loadInvoicePrintType()
    # @organization = @getCurrentOrganization()
    # @_getSettings()
    # @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
    #   @set 'settings', settings          

  navigatedOut: ->
    # @settings = {}
    @patient = {}
    @invoice = {}
    @isVisitValid = false
    @isPatientValid = false

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

  _loadPatient: (patientIdentifier)->
    patient = @$loadPatientLocallyBySerial patientIdentifier
    if !patient
      @_getPatientInfoBySerial patientIdentifier, => null
    
    console.log {patient}

    @set 'patient', patient

    @set "address", @$getAddress patient

  _getPatientInfoBySerial: (patientSerial, cbfn)->
    @loadingCounter++
    data = { apiKey: @user.apiKey, patientSerial }
    @callApi '/bdemr-get-patient-info-by-serial', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        # @domHost.showModalDialog response.error.message
        @_notifyInvalidPatient()
      else
        patient = response.data
        @set 'patient', patient
        return cbfn()    

  _loadInvoicePrintType: ()->
    storedPrintType = localStorage.getItem 'invoicePrintType'
    if storedPrintType?
      @printType = JSON.parse storedPrintType
      @isPrintTypeAvailable = true
    else
      @isPrintTypeAvailable = false

  $of: (a, b)->
    unless b of a
      a[b] = null
    return a[b]


  printButtonPressed: (e)->
    window.print()
  
  blankPagePrintButtonPressed: (e)->
    @set "hideOnBlankPrint", true
    window.print()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'No Patient details available for this invoice!'


  _loadInvoice: (invoiceIdentifier, cbfn)->

    @loadingCounter++
    list = app.db.find 'patient-invoice', ({serial})-> serial is invoiceIdentifier
    if list.length is 1
      @set 'invoice', list[0]
      console.log @invoice
      @loadingCounter--
      return cbfn()
    else  
      data = {
        apiKey: @user.apiKey
        invoiceSerial: invoiceIdentifier
      }
      @callApi '/bdemr--clinic-get-single-invoice', data, (err, response)=>
        @loadingCounter--
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          invoice = response.data[0]
          @set 'invoice', invoice
          return cbfn()

  _notifyInvalidInvoice: ->
    @domHost.showModalDialog 'Invalid Invoice Provided'


  _computeTotalDaysCount: (endDateTimeStamp, startDateTimeStamp)->
    oneDay = 1000*60*60*24;
    diffMs = endDateTimeStamp - startDateTimeStamp
    return Math.round(diffMs/oneDay); 

  _returnSerial: (index)->
    index+1

  # previous code, not used anymore, instead global computeAge is used
  # _computeAge: (dateString)->
    # today = new Date()
    # birthDate = new Date dateString
    # age = today.getFullYear() - birthDate.getFullYear()
    # m = today.getMonth() - birthDate.getMonth()

    # if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
    #   age--

    # return age


  getBoolean: (data)-> if data then true else false
  
  
  $fromListOrCustom: (list, index, custom)->
    if index is list.length - 1
      return custom
    else
      return list[index]

  possiblePaymentStatusses:
    notBilled: 'Not Billed'
    unpaid: 'Unpaid'
    partiallyPaid: 'Partially Paid'
    fullyPaid: 'Fully Paid'

  $toReadbleStatus: (status)-> @possiblePaymentStatusses[status]

  $calculateDue: (advancePayment=0, billed=0, received=0)->
    advancePayment = parseInt advancePayment
    billed = parseInt billed
    received = parseInt received
    
    advancePayment = 0 if Number.isNaN(advancePayment)
    billed = 0 if Number.isNaN(billed)
    received = 0 if Number.isNaN(received)
    
    if billed > 0 and advancePayment < billed
      due = billed - (received)
      due = parseInt due
      if due == 0
        @isFullPaid = true
      else
        @isFullPaid = false
      return due
    else
      return 0

  $calculateGrossTotalToTwoDecimal: (totalBilled=0, discount=0, vattax=0)->
    console.log totalBilled, discount, vattax
    return app.behaviors.commonComputes.$toTwoDecimalPlace (totalBilled-(discount+vattax))

}
