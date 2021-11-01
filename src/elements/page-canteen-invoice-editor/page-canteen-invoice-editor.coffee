Polymer {
  is: 'page-canteen-invoice-editor'
  
  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]
  
  properties:
    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: null
    
    invoice:
      type: Object
      notify: true
      value: -> {}
        
    discountType:
      type: Number
      value: -> 1

    invoiceSourceDataList:
      type: Array
      value: []

    invoiceCategoryList:
      type: Object
      value: -> {}

    invoiceGrossPrice:
      type: Number
      value: -> 0
    
    invoiceDiscountAmt:
      type: Number
      notify: true
      value: -> 0

    customUnit:
      type: Object
      value: {}

    searchFieldValue: 
      type: String
      notify: true
      value: ''

    matchingPatientList:
      type: Array
      notify: true
      value: []

    showPatientSearchBox:
      type: Boolean
      notify: true
      value: true

    patient:
      type: Object
      notify: true
      value: null

    medicineInventory:
      type: Array
      notify: true
      value: -> []

    patientSearchQuery:
      type: String
      value: -> ""
      observer: 'patientSearcKeyPressed'

    importingPatientData:
      type: Boolean
      value: false

    medicineItemSearchQuery:
      type: String
      value: ''
      observer: 'medicineItemSearchInputChanged'

  observers: [
    'calculateTotalPrice(invoice.*)'
  ]

  # UTIL
  isEmpty: (array)->
    return false if array is undefined or array is null 
    if array.length then return true else return false

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age

  _isEmptyArray: (length)->
    if length is 0
      return true
    else
      return false

  _returnSerial: (index)->
    index+1

  _computeTotalDaysCount: (endDate, startDate)->
    return (@$TRANSLATE("As Needed", @LANG)) unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    diffMs = endDate - startDate
    x =  Math.round(diffMs / oneDay)
    return @$TRANSLATE_NUMBER(x, @LANG)


  # Search Patient - start

  _searchPatient: (searchQuery)->
    return unless searchQuery
    @$$("#patientSearch").invalid = false;
    @fetchingPatientSearchResult = true;
    @callApi '/bdemr--clinic-pharmacy-invoice-patient-search', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingPatientSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length
          @$$("#patientSearch").items = data
        else
          # @domHost.showToast 'No Match Found'
          @$$("#patientSearch").invalid = true;
  
  patientSearcKeyPressed: (searchQuery)->
    @debounce 'search-patient', ()=>
      @_searchPatient(searchQuery)
    , 700

  patientSelected: (e)->
    return unless e.detail.value
    @set 'showPatientSearchBox', false
    userId = e.detail.value
    @$$("#patientSearch")._clear()
    @$$("#addPatientDialog").close()
    @importSelectedPatient userId, => @patientSearchCleared()
      
        
  removePatient: ()->
    @set 'showPatientSearchBox', true
    @set 'patient', null

  
  patientSearchCleared: ->
    @patientSearchQuery = ""
    @$$("#patientSearch").cancel()
  
        
  importSelectedPatient: (userId, cbfn) ->
    data = {
      apiKey: @user.apiKey
      userId
    }
    @importingPatientData = true
    @callApi '/bdemr--clinic-pharmacy-invoice-get-patient-basic-details', data, (err, response)=>
      @importingPatientData = false
      if err
        return @domHost.showModalDialog 'Something went wrong with the Server.'
      else if response.hasError
        return @domHost.showModalDialog response.error.message
      else if !response.data.length
        return @domHost.showModalDialog 'No Patient Found'
      else
        @set 'patient', response.data[0]
      cbfn()

  showAddPatientDialog: ()->
    @patientSearchCleared()
    @$$("#addPatientDialog").toggle()

  # Search Patient - end

  # _loadOrganizationInventory:(organizationIdentifier)->
  #   inventoryItemList = app.db.find 'organization-inventory', ({organizationId})-> organizationId is organizationIdentifier
  #   @set 'inventoryItemList', inventoryItemList
  
  # _loadInternalInventory:(locationIdentifier)->
  #   inventoryItemList = app.db.find 'organization-internal-inventory', ({location})-> location.serial is locationIdentifier
  #   @set 'inventoryItemList', inventoryItemList

  # _loadMedicineInventory: (organizationIdentifier)->
  #   @domHost.getStaticData 'medicineCompositionList', (medicineCompositionList)=>
  #     brandNameMap = {}
  #     for item in medicineCompositionList
  #       brandNameMap[item.brandName] = null
  #     generatedMedicineList = ({label: item, value: {name: item, buyingPrice: 0, sellingPrice: 0, qty: 1}} for item in Object.keys brandNameMap)

  #     inventoryItemList = app.db.find 'organization-inventory', ({organizationId})-> organizationId is organizationIdentifier

  #     modifiedList = []

  #     for item in inventoryItemList
  #       object =
  #         label: item.data.name
  #         value:
  #           inventorySerial: item.serial
  #           name: item.data.name
  #           buyingPrice: item.data.buyingPrice
  #           sellingPrice: item.data.sellingPrice
  #           qty: item.data.qty
  #           category: 'pharmacy'
  #           batch: item.data.batch?=''

  #       modifiedList.push object

  #     @medicineInventory = [].concat modifiedList, generatedMedicineList


  medicineItemSelected: (e)->
    return unless e.detail.value
    selectedItem = e.detail.value
    console.log 'selected medicine', selectedItem
    {name, actualCost, price, batch, category} = selectedItem.value
    item = {}
    # if 'serial' of selectedItem
    #   item.inventorySerial = selectedItem.serial
    item.name = name
    item.qty = 1
    item.actualCost = actualCost?=0
    item.price = price?=0
    item.totalPrice = item.qty * item.price
    item.category = category
    item.batch = batch?=''
    item.id = selectedItem.value._id
    @push 'invoice.data', item
  
  # addSelectedMedicineToInvoice: ()->
  #   console.log @comboBoxMedicineInputValue
  #   if typeof @comboBoxMedicineInputValue is 'object'
  #     item = {}
  #     item.name = @comboBoxMedicineInputValue.name
  #     item.qty = @comboBoxMedicineInputValue.qty
  #     item.price = @comboBoxMedicineInputValue.sellingPrice
  #     item.totalPrice = @comboBoxMedicineInputValue.sellingPrice
  #     if @comboBoxMedicineInputValue.inventorySerial
  #       item.inventorySerial = @comboBoxMedicineInputValue.inventorySerial
  #     @push 'invoice.data', item
  #     @set 'comboBoxMedicineInputValue', null
  #   else
  #     @domHost.showToast 'Select a medicine first'


  printButtonPressed: ()->
    @_saveInvoice false, =>
      console.log @invoice
      @domHost.navigateToPage '#/print-invoice/invoice:' + @invoice.referenceNumber + '/patient:' + @invoice.patientSerial


  navigatedIn: ->
    params = @domHost.getPageParams()
    @_loadUser()
    @_loadOrganization()
    unless params['invoice']
      @domHost.showModalDialog 'No Invoice Found'
      return
    
    if params['invoice'] is 'new'
      @_makeNewInvoice @organization.idOnServer
    else
      @_loadInvoice params['invoice']
    
    
    
  navigatedOut: ->
    @set 'invoice', {}
    @set 'invoice.data', []
    @set "invoiceGrossPrice", 0
    @set "invoiceDiscountAmt",  0

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
    else
      return @_notifyInvalidPatient()
  
  _loadOrganization: (cbfn)->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
    else
      return @_notifyInvalidOrganization()

   
  
  _loadInvoice: (invoiceIdentifier)->
    list = app.db.find 'patient-invoice', ({serial})-> serial is invoiceIdentifier
    if list.length > 0
      @set 'invoice', list[0]
      @calculateTotalPrice()
    else
      @domHost.showModalDialog 'No Invoice Found'
  

  _getNextInvoiceRef: (cbfn)->
    query =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @callApi '/bdemr-clinic-app--organization-invoice--get-next-ref-number', query, (err, response)=>
      cbfn response.data.ref
  
  _makeInvoiceRef: (refNumber)->
    organizationNamePart = @organization.name.trim().split(" ")
    string = ""
    for item in organizationNamePart
      string += item.split("")[0]
    return "#{string}-#{refNumber}"  
  
  _makeNewInvoice: ->
    invoice = {
      serial: null
      referenceNumber: null
      createdDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      patientSerial: null
      patientName: null
      patientPhone: null
      patientEmail: null
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      modificationHistory: []
      lastModifiedDatetimeStamp: null
      category: 'canteen'
      advancePayment: null
      totalBilled: 0
      paid: null
      lastPaid: null
      discount: null
      vatOrTax: 0
      totalAmountReceieved: null
      cashBackPaid: null
      flags:
        flagAsError: false
        markAsCompleted: false
      data: []
      commission: {}
      availableToPatient: true
    }
    @set 'invoice', invoice


  deleteInvoiceItem: (e)->
    @splice 'invoice.data', e.model.index, 1
  
  
  discountTypeChanged: ->
    @calculateTotalPrice()

  lastPaymentChanged: (e)->
    el = e.target
    due = @_calculateDue(@invoice.totalBilled, @invoice.paid, 0)
    if el.value > due
      el.invalid = true

  
  itemUnitPriceChanged: (e)->
    value = parseInt e.target.value
    el = @locateParentNode e.target, 'PAPER-ITEM'
    repeater = @$$ '#invoice-item-repeater'
    index = repeater.indexForElement el
    model = repeater.modelForElement el
    invoiceItem = @invoice.data[index]
    invoiceItem.price = value
    invoiceItem.totalPrice = value * invoiceItem.qty
    model.set 'item.totalPrice', (value * model.item.qty)
    @splice 'invoice.data', index, 1, invoiceItem
  
  quantityChanged: (e)->
    model = e.model
    value = parseInt e.target.value

    if value > 1
      model.set 'item.qty', value
      model.set 'item.totalPrice', ( parseInt model.item.price * parseInt value)
      @calculateTotalPrice()
    else 
      model.set 'item.qty', 1
      model.set 'item.totalPrice', model.item.price
    

  calculateTotalPrice: ->
    # Checking Empty Object
    return unless Object.keys(@invoice).length

    price = 0
    discount = parseInt @invoice.discount?= 0

    for item in @invoice.data
      price += parseInt (item.price * item.qty)

    if discount
      if @discountType is 0
        discountAmt = (price * discount /100)
        priceAfterDiscount = price - discountAmt
      else
        discountAmt = discount
        priceAfterDiscount = price - discount
    else
      priceAfterDiscount = price

    @set "invoiceGrossPrice", price
    @set "invoiceDiscountAmt", discountAmt

    @set 'invoice.totalBilled', priceAfterDiscount

  _calculateDue: (advancePayment=0, total=0, paid=0, lastPaid=0)->
    advancePayment = parseInt advancePayment
    total = parseInt total
    paid = parseInt paid
    lastPaid = parseInt lastPaid
    
    advancePayment = 0 if Number.isNaN(advancePayment)
    total = 0 if Number.isNaN(total)
    paid = 0 if Number.isNaN(paid)
    lastPaid = 0 if Number.isNaN(lastPaid)
    
    if total > 0 and advancePayment < total
      return total- (paid + lastPaid + advancePayment)
    else
      return 0
      

  _calculateTotalAmtReceived: (advancePayment=0, paid=0, lastPaid=0, totalBilled=0)->
    advancePayment = parseInt advancePayment
    paid = parseInt paid
    lastPaid = parseInt lastPaid

    paid = 0 if Number.isNaN(paid)
    lastPaid = 0 if Number.isNaN(lastPaid)
    advancePayment = 0 if Number.isNaN(advancePayment)
    
    if advancePayment is totalBilled or advancePayment > totalBilled
      totalAmountReceieved = totalBilled
    else
      totalAmountReceieved = paid + lastPaid + advancePayment

    @set 'invoice.totalAmountReceieved', totalAmountReceieved
    return totalAmountReceieved


  # ===========================================================
  # SAVING INVOICE
  # ===========================================================

  _validateInvoice: (invoice)->
    unless invoice.data.length
      @domHost.showToast 'Add some item into invoice'
      return false
    if !invoice.totalAmountReceieved and !invoice.advancePayment?
      @domHost.showToast 'Please Add some amount in Paid Amount'
      return false
    return true
  
  
  # _reduceInventoryItems: (invoice)->
  #   console.log invoice.data
  #   for item in invoice.data
  #     if 'inventorySerial' of item
  #       doc = (app.db.find 'organization-inventory', ({serial})=> serial is item.inventorySerial)[0]
  #       doc.data.qty -= item.qty
  #       app.db.update 'organization-inventory', doc._id, doc

  _assignInvoiceRef: (referenceNumber, cbfn)->
    if referenceNumber
      cbfn(null)
    else
      @_getNextInvoiceRef (refNumber)=>
        referenceNumber = @_makeInvoiceRef refNumber
        cbfn(referenceNumber)
  
  _addModificationHistory: ->
    modificationHistory =
      userSerial: @user.serial
      lastModifiedDatetimeStamp: lib.datetime.now()
    @invoice.modificationHistory.push modificationHistory
    @invoice.lastModifiedDatetimeStamp = lib.datetime.now()
  
  
  _saveInvoice: (markAsCompleted, cbfn)->
    
    return unless @_validateInvoice @invoice
    
    if markAsCompleted
      @invoice.flags.markAsCompleted = true
    
    @_addModificationHistory()
    
    # check for inventory items and reduce
    # @_reduceInventoryItems @invoice

    if @patient
      @invoice.patientSerial = @patient.serial
      @invoice.patientName = @patient.name
      @invoice.patientPhone = @patient.phone
      @invoice.patientEmail = @patient.email
    
    unless @invoice.serial
      @invoice.serial = @generateSerialForInvoice @organization.idOnServer
    
    # Assign a referenceNumber if not present
    @_assignInvoiceRef @invoice.referenceNumber, (refNumber)=>
      @invoice.referenceNumber = refNumber if refNumber
      app.db.upsert 'patient-invoice', @invoice, ({serial})=> serial is @invoice.serial
      @_callReduceInventoryItemByInvoiceApi =>      
        @domHost.showToast 'Invoice Saved Successfully'
        cbfn()
        

  # =====================================================================

  _callReduceInventoryItemByInvoiceApi: (cbfn)->
    cbfn() if @invoice.data.length is 0
    data = @invoice.data
 
    filterItems = data.map (item) => { productId: item.id, reduceQty: item.qty }

    data =
      apiKey: this.user.apiKey
      list: filterItems
      organizationId: @organization.idOnServer
  
    @callApi '/bdemr-reduce-organization-inventory-item', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()


  addCustomItemToInvoiceButtonPressed: ->
    @.$.customItemModal.toggle()

  customUnitAddButtonClicked: (e)->
    nameField = @.$.customUnitNameField
    costField = @.$.customUnitCostField
    priceField = @.$.customUnitPriceField
    unless nameField.value
      return nameField.validate()
    unless priceField.value
      return priceField.validate()
    data = {
      name: nameField.value?=""
      actualCost: costField.value?=0
      price: priceField.value?=0
      qty: 1
      category: 'pharmacy'
      totalPrice: priceField.value?=0
    }
    @push 'invoice.data', data
    nameField.value = ""
    costField.value = priceField.value = null
    @.$.customItemModal.close()


  _notifyInvalidPatient: ->
    @showModal 'Invalid Patient Provided'

  _notifyInvalidOrganization: ->
    @showModal 'No Organization is Present. Please Select an Organization first.'
  
  saveAndCompleteInvoiceButtonClicked: ->
    @_saveInvoice markAsCompleted = true, => @domHost.navigateToPreviousPage()

  saveInvoiceButtonClicked: ()->
    @_saveInvoice false, => @domHost.navigateToPreviousPage()


  arrowBackButtonPressed: ->
    @domHost.navigateToPreviousPage()


  ###
    Medicine inventory load
  ###
  medicineItemSearchInputChanged: (searchQuery)->
    @debounce 'search-inventory-item', ()=>
      return unless searchQuery
      @_searchInventoryItem searchQuery
    , 300

  _searchInventoryItem: (searchQuery)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: 
        category: 'canteen'
        name: searchQuery.trim()

    console.log 'query', data
    @fetchingMedicineItemSearchResult = true;
    @domHost.callApi '/bdemr-get-organization-inventory', data, (err, response)=>
      @fetchingMedicineItemSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'inventoryItemList', []
        filteredAutocompleteList = []
        items = response.data

        for item in items
          if item.quantity > 0
            filteredAutocompleteList.push(item)

        autocompleteList = ({label: item.name, value: item} for item in filteredAutocompleteList)

        @set 'inventoryItemList', autocompleteList
        console.log 'source list', @inventoryItemList


}