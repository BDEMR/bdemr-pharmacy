
Polymer {

  is: 'page-print-preview-individual-invoice'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:

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

  navigatedIn: ->
    console.log 'inside print preview navigated in'
    @_loadUser()
    @organization = @getCurrentOrganization()
    @_getSettings()
    @_loadInvoice()
    @_loadPatient()
    @_loadInvoicePrintType()
    console.log 'loaded patient', @patient
    console.log 'loaded invoice', @invoice
    

  navigatedOut: ->
    @settings = {}
    @patient = {}
    @invoice = {}
    @isVisitValid = false
    @isPatientValid = false

  _getSettings: ->
    list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    if list.length
      @settings = list[0]
      if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
        if @organization.printSettings
          @settings.printDecoration = @organization.printSettings
    else
      @domHost.showModalDialog 'No Settings Found'
  
  _loadUser:()->
    userList = app.db.find 'user'
    # console.log userList
    if userList.length is 1
      @user = userList[0]

  _loadPatient: ()->
    previewPatient = JSON.parse localStorage.getItem 'previewPatientObject'
    if previewPatient
      @set 'patient', previewPatient
    else
      @_notifyInvalidPatient()

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

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'No Patient details available for this invoice!'


  _loadInvoice: ()->
    previewInvoice = JSON.parse localStorage.getItem 'previewInvoiceObject'
    if previewInvoice
      @set 'invoice', previewInvoice
    else
      @_notifyInvalidInvoice()
    
    

  _notifyInvalidInvoice: ->
    @domHost.showModalDialog 'Invalid Invoice Provided'


  _computeTotalDaysCount: (endDateTimeStamp, startDateTimeStamp)->
    oneDay = 1000*60*60*24;
    diffMs = endDateTimeStamp - startDateTimeStamp
    return Math.round(diffMs/oneDay); 

  _returnSerial: (index)->
    index+1

  _computeAge: (dateString)->
    
    # previous code, not used anymore, instead global computeAge is used
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
      return due
    else
      return 0

  $calculateGrossTotalToTwoDecimal: (totalBilled=0, discount=0, vattax=0)->
    return app.behaviors.commonComputes.$toTwoDecimalPlace (totalBilled+discount-vattax)

}
