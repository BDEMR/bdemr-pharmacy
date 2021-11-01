
Polymer {

  is: 'page-print-commission-payment-details'

  behaviors: [
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.translating
  ]

  properties:
    payment:
      type: Object
      value: ()-> {}
    
    matchingInvoiceList:
      type: Array
      value: ()-> []

    percentageCalcArray:
      type: Array
      value: ()-> []

    finalArr:
      type: Array
      value: ()-> []

    totalAmount:
      type: Number
      value: -> 0

  navigatedIn: ->
    @_loadUser()
    @currentDateTime = lib.datetime.now()
    payment = JSON.parse(localStorage.getItem("paymentDetails"))
    @set 'payment', payment
    @set 'matchingInvoiceList', payment.matchingInvoiceList
    @set 'percentageCalcArray', payment.percentageCalcArray
    console.log payment
    @_calculateTotalAmount()
    @_sortInRMHWay()

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    window.history.back()

  _calculateTotalAmount: ->
    totalAmount = 0
    for item in @payment.data
      totalAmount += item.totalPrice

    if totalAmount > 0
      @set 'totalAmount', totalAmount
    else
      return 0

  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'
  

  printButtonPressed: ()->
    window.print()


  _sortInRMHWay: ()->
    console.log @matchingInvoiceList
    console.log @percentageCalcArray

    patientList = []
    billingArr = []
    tagMap = {}

    for invoice in @matchingInvoiceList
      if !patientList.includes(invoice.patientSerial)
        patientList.push invoice.patientSerial

    for patientSerial in patientList
      obj = 
        patientSerial: patientSerial
        tags: []
        discount: 0
      @matchingInvoiceList.forEach (invoice) ->
        if invoice.patientSerial == patientSerial
          obj.discount += invoice.discount    
          invoice.data.forEach (item) ->
            if item.tag isnt '' or null
              item.tag = item.tag.split(" ")
              item.tag = item.tag.join("")
              item.tag = item.tag.toLowerCase()
              obj.tags.push(item)
          obj.patientName = invoice.patientName
          obj.patientPhone = invoice.patientPhone

      billingArr.push obj

    finalArr = billingArr.map (item) ->
      finalObj = 
        { 
          patientSerial: item.patientSerial
          patientName: item.patientName
          patientPhone: item.patientPhone
          discount: item.discount
        }
      item.tags.forEach (obj) ->
        if obj.tag of finalObj
          finalObj[obj.tag] = finalObj[obj.tag] + obj.price
        else
          finalObj[obj.tag] = obj.price
        
      return finalObj
    console.log finalArr
    @set 'finalArr', finalArr


}
