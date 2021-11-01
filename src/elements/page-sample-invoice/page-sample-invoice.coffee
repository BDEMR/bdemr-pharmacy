Polymer {
  is: 'page-sample-invoice'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
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
      value: -> 0

    discountFundType:
      type: Number
      value: -> 0

    discountFromFund:
      type: Object
      value: -> {}

    customNextPaymentDate:
      type: String
      value: -> ''
    
    investigationPriceList:
      type: Object
      notify: true
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }
    
    investigations:
      type: Array
      value: []

    servicePriceList:
      type: Object
      notify: true
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }

    supplyPriceList:
      type: Object
      notify: true
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }

    ambulancePriceList:
      type: Object
      notify: true
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }

    packagePriceList:
      type: Object
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: [] 
      }
    
    otherPriceList:
      type: Object
      notify: true
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }

    inventoryList:
      type: Object
      value: -> {
        serial: null
        lastModifiedDatetimeStamp: null
        data: []
      }

    invoiceSourceDataList:
      type: Array
      value: []

    thirdPartyUserList:
      type: Array
      value: -> []

    fluidTypeList:
      type: Array
      value: -> ['NS','RL','Plasmalyte','D5','D5 NS','NS with 20 mmol KCL']
    
    transfusionTypeList:
      type: Array
      value: -> ['Albumin','Voluven','Volulyte','Pentastarch','Dextran','RCC','Platelet','FFP','Cryo(Bottle)','Cryo(Unit)']

    invoiceCategoryList:
      type: Object
      value: -> {}

    invoiceGrossPrice:
      type: Number
      notify: true
      value: -> 0
    
    invoiceDiscount:
      type: Number
      value: -> 0
      observer: 'discountInputChanged'
    
    invoiceVatOrTax:
      type: Number
      notify: true
      value: -> 0
      observer: 'vatTaxInputChanged'

    invoiceRemaingBalanceFromAdvance:
      type: Number
      notify: true
      computed: '_calculateRemainingBalanceFromAdvance(invoice.advancePayment, invoice.totalBilled, invoice.cashBackPaid)'

    customUnit:
      type: Object
      value: -> {}

    commissionCategoryList:
      type: Array
      value: -> []

    commissionCategoryIndex:
      type: Number
      value: 0    

    fundList:
      type: Array
      value: -> []

    today:
      type: String
      value: -> new Date().toISOString().split('T')[0]

    doctorSearchQuery:
      type: String
      value: -> ""
      observer: 'doctorSearcInputChanged'

    generalDiscountPercentageLimit:
      type: Number
      value: -> 100

    minimumPaymentPercentageLimit:
      type: Number
      value: -> 0
    
    selectedThirdParty:
      type: Object
      value: -> null
    
    thirdParties:
      type: Array
      value: -> []
    
    selectedInvestigation:
      type: Object
      value: null
      observer: 'selectedInvestigationChanged'
    
    addedInvestigationList:
      type: Array
      notify: true
      value: []
    
    members:
      type: Array
      value: []
    
    testAdvisedObject:
      type: Object
      notify: true
      value: {}
    
    hasTestAdvisedAdded:
      type: Boolean
      value: false

    printTypeArray:
      type: Array
      value: -> ['Cash/Original', 'Duplicate', 'Final Bill']

    patientStatusArray:
      type: Array
      value: -> [{label:'Indoor Patient', value:'indoor'}, {label:'Outdoor Patient', value:'outdoor'}]

    customDeliveryDate: String 
    customDeliveryTime: String
    customNextPaymentDate: String


      
  observers: [
    'calculateGrossPrice(invoice.data.*)'
    '_calculateTotalAmtReceived(invoice.advancePayment, invoice.paid, invoice.lastPaid)'
    '_calculateCommissionFromPercentage(commissionPercentage)'
  ]

  
  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false
      
  selectedInvestigationChanged: (selectedInvestigation)->
    if selectedInvestigation
      @unshift 'addedInvestigationList', @_makeNewAddedInvestigationObject @selectedInvestigation

  _makeNewTestAdvisedObject: ()->
    @testAdvisedObject =
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      visitSerial: null
      patientSerial: @patient.serial
      doctorName: 'self'
      doctorSpeciality: null
      organizationId: @organization.idOnServer
      clientCollectionName: 'visit-advised-test'
      data:
        testAdvisedName: null
        testAdvisedList: []
      availableToPatient: true
      
    @isTestAdvisedValid = true


  _extractInvestigationFromInvoiceData:()->
    list = []
    @testAdvisedObject.data.testAdvisedList.forEach (test)=>
      for item in @invoice.data
        if item.category is 'investigation'
          if test.serial is item.investigationSerial
            list.push test
    console.log 'after list:', list
    return list

  saveAdvisedTest: (cbfn)->
    @testAdvisedObject.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'visit-advised-test', @testAdvisedObject, ({serial})=> @testAdvisedObject.serial is serial
    cbfn()

  # UTIL
  isEmpty: (array)->
    return false if array is undefined or array is null 
    if array.length then return true else return false


  convertToTimeString: (dateObject)->
    hour = dateObject.getHours()
    if hour.toString().length is 1
      hour = '0' + hour
    minute = dateObject.getMinutes()
    if minute.toString().length is 1
      minute = '0' + minute
    timeString = hour + ':' + minute
    return timeString

  convertToDateString: (dateObject)->
    isoStringArr = dateObject.toISOString().split('T')
    console.log isoStringArr
    return isoStringArr[0]


  navigatedIn: ->
    
    params = @domHost.getPageParams()
    @_loadUser()

    @_loadOrganization =>
      console.log {@organization}
      @_makeNewInvoice @organization.idOnServer

      @_getInvestigationList @organization.idOnServer
      @_loadFunds @organization.idOnServer
      @_loadCommissionCategoryList @organization.idOnServer
      # @_loadInvestigationPriceList @organization.idOnServer
      @_loadDoctorFeesPriceList @organization.idOnServer
      @_loadServicePriceList @organization.idOnServer
      @_loadMedicineInventory @organization.idOnServer
      @_loadSupplyPriceList @organization.idOnServer
      @_loadAmbulancePriceList @organization.idOnServer
      @_loadPackagePriceList @organization.idOnServer
      @_loadOtherPriceList @organization.idOnServer
      @_loadThirdPartyUserAutocompleteList @organization.idOnServer
      @_loadInvoiceCategoryList @organization.idOnServer, @user.serial
      @_loadItemSearchAutoComplete()
      @_loadOrganizationSettings @organization.idOnServer

      @_callGetThirdPartiesApi()

    
  navigatedOut: ->
    @set 'invoice', {}
    @set "invoiceGrossPrice", 0
    @set "invoiceDiscount",  0
    @set "invoiceVatOrTax", 0
    @set 'discountType', 0

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _checkUserAccess: (accessId)->
    # console.log 'accessId', accessId
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return false

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true
  
  doctorSearcInputChanged: (searchQuery)->
    @debounce 'search-patient', ()=>
      @_searchDoctor(searchQuery)
    , 300
  
  _searchDoctor: (searchQuery)->
    return unless searchQuery
    @fetchingDoctorSearchResult = true;
    @callApi '/bdemr-doctor-search', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingDoctorSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length > 0
          @$$("#doctorSearch").items = data
        else
          @domHost.showToast 'No Match Found'
  

  referredDoctorSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @set 'invoice.referralDoctor.name', user.name
    @set 'invoice.referralDoctor.mobile', user.phone
    @set 'invoice.referralDoctor.id', user.idOnServer

  
  _loadOrganization: (cbfn)->
    organization = (app.db.find 'organization')[0]

    data = { 
      apiKey: @user.apiKey
      idList: [ organization.idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]

        @set 'isOrganizationValid', true
        cbfn()
  
  
  
  _loadOrganizationSettings: (organizationIdentifier)->
    list = app.db.find 'organization-settings', ({ serial })=> serial is organizationIdentifier
    if list.length
      organizationSettings = list[0]
      @set 'generalDiscountPercentageLimit', parseFloat organizationSettings.data.generalDiscountPercentageLimit
      @set 'minimumPaymentPercentageLimit', parseFloat organizationSettings.data.minimumPaymentPercentageLimit
      @set 'invoiceVatOrTax', parseFloat organizationSettings.data.vatOrTaxPercentage
  
  _loadInvoice: (invoiceIdentifier)->
    list = app.db.find 'patient-invoice', ({serial})=> serial is invoiceIdentifier
    if list.length
      @set 'invoice', list[0]

      if @invoice.nextPaymentDate
        nextPaymentDateObject = new Date @invoice.nextPaymentDate
        nextPaymentDateString = @convertToDateString(nextPaymentDateObject)
        @set 'customNextPaymentDate', nextPaymentDateString

      if @invoice.reportDeliveryDateTime
        deliveryDateObject = new Date @invoice.reportDeliveryDateTime
        deliveryDateString = @convertToDateString(deliveryDateObject)
        @set 'customDeliveryDate', deliveryDateString
        deliveryTimeString = @convertToTimeString(deliveryDateObject)
        @set 'customDeliveryTime', deliveryTimeString

      if @invoice.discount
        @set 'invoiceDiscount', @invoice.discount

      if @invoice.vatOrTax
        vatOrTaxPercentage = (@invoice.vatOrTax / @invoiceGrossPrice)*100
        @set 'invoiceVatOrTax', vatOrTaxPercentage

      unless @invoice.advancePayment
        @set 'invoice.advancePayment', 0
      
    else
      @domHost.showModalDialog 'No Invoice Found'
  
  _loadFunds: (organizationIdentifier)->
    data =
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    @callApi 'bdemr--clinic-get-discount-fund-list', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'fundList', response.data
  
  _loadCommissionCategoryList: ()->
    @commissionCategoryList = app.db.find 'commission-category-list', ({ organizationId }) => organizationId is @organization.idOnServer

  discountfundSelected: (e)->
    index = e.detail.selected
    fund = @fundList[index]
    @invoice.discountFromFund.name = fund.name
    @invoice.discountFromFund.serial = fund.serial

  commissionCategorySelected: (e)->
    index = e.detail.selected
    category = @commissionCategoryList[index]
    @invoice.commission.category = category.name
    @invoice.commission.commissionCategorySerial = category.serial
 
    

  getSpecialDiscountPercentage: (value)->
    if @discountType
      return 0 unless value > @generalDiscountPercentageLimit and @fundList.length
      return @$toTwoDecimalPlace(value - @generalDiscountPercentageLimit)
    else
      discountPercent = @convertDiscountAmountToPercentage(value)
      return 0 unless discountPercent > @generalDiscountPercentageLimit and @fundList.length
      return @$toTwoDecimalPlace(discountPercent - @generalDiscountPercentageLimit)
   

  _deductDiscountAmountFromFund: (serial, fundDiscountAmt, cbfn)->

    data =
      apiKey: @user.apiKey
      serial: serial
      invoiceDiscountAmount: fundDiscountAmt
    console.log {data}
    @callApi 'bdemr--clinic-deduct-discount-fund', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log "Fund Deduction Executed"
        cbfn()

  # Modal
  # ===================================

  addCustomItemToInvoiceButtonPressed: ->
    @.$.customItemModal.toggle()

  customUnitAddButtonClicked: (e)->
    nameField = @.$.customUnitNameField
    costField = @.$.customUnitCostField
    priceField = @.$.customUnitPriceField

    tempName = nameField.value.trim()
    if tempName is ''
      @domHost.showToast 'Item name required!'
      return
    unless priceField.value
      return priceField.validate()
    data = {
      name: tempName
      actualCost: costField.value?=0
      price: priceField.value?=0
      qty: 1
      totalPrice: priceField.value?=0
    }
    @push 'invoice.data', data
    nameField.value = ""
    costField.value = priceField.value = null
    @.$.customItemModal.close()
  
  
  
  # AUTOCOMPLETE SEARCH
  # ===========================================
  
  _loadItemSearchAutoComplete: ->
    # inventoryList = ({name: item.data.name, price: item.data.sellingPrice, actualCost: item.data.buyingPrice, category: 'medicine'} for item in @inventoryList)

    @_loadMedicineCompositionList (medicineSourceDataList)=>
      # Getting All Prices Together
      concatList = [].concat @investigations,  @servicePriceList.data, @otherPriceList.data, @packagePriceList.data, @supplyPriceList.data, @ambulancePriceList.data, medicineSourceDataList

      autocompleteList = ({label: item.name, value: item} for item in concatList)

      @set 'invoiceSourceDataList', autocompleteList

  invoiceItemAutocompleteSelected: (e)->
    return unless e.detail.value
    item = e.detail.value
    item.qty = 1
    item.totalPrice = item.price
    @push 'invoice.data', item
    # console.log item
    # @.$.invoiceSearchInput.clear()
  
  # =============================================
  
  _loadMedicineCompositionList: (cbfn)->
    @domHost.getStaticData 'medicineCompositionList', (medicineCompositionList)=>
      brandNameMap = {}
      for item in medicineCompositionList
        brandNameMap[item.brandName] = null
      brandNameSourceDataList = ({name: item, price: null, category: 'medicine', actualCost: null} for item in Object.keys brandNameMap)

      cbfn brandNameSourceDataList

  
  _loadThirdPartyUserAutocompleteList: (organizationIdentifier)->
    @thirdPartyUserList = app.db.find 'third-party-user-list', ({organizationId})-> organizationId is organizationIdentifier
    @thirdPartyUserListNameSourceMap = @thirdPartyUserList.filter((item)-> item.name).map((item)-> return {text: item.name, value: item.serial})
    @thirdPartyUserListMobileSourceMap = @thirdPartyUserList.filter((item)-> item.mobile).map((item)-> return {text: item.mobile, value: item.serial})
  
  _loadInvoiceCategoryList: (organizationIdentifier, userSerial)->
    list = app.db.find 'invoice-category-list', ({organizationId, createdByUserSerial})=> organizationId is organizationIdentifier and createdByUserSerial is userSerial
    if list.length
      @set 'invoiceCategoryList', list[0]
    else
      @set 'invoiceCategoryList', @_makeNewInvoiceCategoryList organizationIdentifier, userSerial

  _loadInvestigationPriceList: (organizationIdentifier)->
    investigationPriceList = (app.db.find 'investigation-price-list', ({organizationId})-> organizationId is organizationIdentifier)

    if investigationPriceList.length > 0
      @investigationPriceList = investigationPriceList[0]
  
  _getInvestigationList:(organizationId)->
    @domHost.callApi '/bdemr-get-organization-investigation-list', { apiKey: @user.apiKey, organizationId: organizationId }, (err, response)=>
      console.log response
      if response.hasError
        @showWarningToast response.error.message
      else
        data = response.data
        @set 'investigations', data

  
  _loadDoctorFeesPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    doctorFeesPriceList = app.db.find 'doctor-fees-price-list', ({organizationId})-> organizationId is organizationIdentifier

    if doctorFeesPriceList.length > 0
      @doctorFeesPriceList = doctorFeesPriceList[0]

  
  _loadServicePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    servicePriceList = app.db.find 'service-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if servicePriceList.length > 0
      @servicePriceList = servicePriceList[0]
    


  _loadMedicineInventory: (organizationIdentifier)->
    @domHost.getStaticData 'medicineCompositionList', (medicineCompositionList)=>
      brandNameMap = {}
      for item in medicineCompositionList
        brandNameMap[item.brandName] = null
      generatedMedicineList = ({data: {name: item, buyingPrice: 0, sellingPrice: 0, qty: 1}} for item in Object.keys brandNameMap)

      inventory = app.db.find 'organization-inventory', ({organizationId})-> organizationId is organizationIdentifier
      @medicineInventory = [].concat inventory, generatedMedicineList
      

  _loadSupplyPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    supplyPriceList = app.db.find 'supply-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if supplyPriceList.length > 0
      @supplyPriceList = supplyPriceList[0]
     

  _loadAmbulancePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    ambulancePriceList = app.db.find 'ambulance-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if ambulancePriceList.length > 0
      @ambulancePriceList = ambulancePriceList[0]
    

  _loadPackagePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    packagePriceList = app.db.find 'package-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if packagePriceList.length > 0
      @packagePriceList = packagePriceList[0]
    
  
  _loadOtherPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    otherPriceList = app.db.find 'other-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if otherPriceList.length > 0
      @otherPriceList = otherPriceList[0]  
  
  # TOGGLE COLLAPSE
  toggleInvestigation: (e)-> @.$.investigation.toggle()
  toggleDoctorFees: (e)-> @.$.doctorFees.toggle()
  toggleServcie: (e)-> @.$.service.toggle()
  toggleSupply: (e)-> @.$.supply.toggle()
  togglePharmacy: (e)-> @.$.pharmacy.toggle()
  toggleAmbulance: (e)-> @.$.ambulance.toggle()
  togglePackage: (e)-> @.$.package.toggle()
  toggleOther: (e)-> @.$.other.toggle()

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
      serial: @generateSerialForInvoice @organization.idOnServer
      referenceNumber: null
      createdDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      modificationHistory: []
      lastModifiedDatetimeStamp: null
      category: ''
      advancePayment: 0
      totalBilled: 0
      paid: null
      lastPaid: null
      discount: null
      totalAmountReceieved: null
      cashBackPaid: null
      flags:
        flagAsError: false
        markAsCompleted: false
      data: []
      commission: null
      availableToPatient: true
      reportDeliveryDateTime: null
      nextPaymentDate: null
      referralDoctor: {
        name: ""
        mobile: ""
        id: ""
      }
      discountBy: ""
      discountFromFund: {}
      vatOrTax: 0
      patientStatus: null
    }
    @commissionCategoryIndex = 0 
    @customDeliveryDate = ""
    @customDeliveryTime = ""
    @customNextPaymentDate = ""

    @set 'invoice', invoice
  
  
  
  _setReportDeliveryDateTime: ->
    return unless @customDeliveryDate
    if @customDeliveryTime
      deliveryDateTime = new Date("#{@customDeliveryDate} #{@customDeliveryTime}")
    else
      deliveryDateTime = new Date("#{@customDeliveryDate}")
    @set 'invoice.reportDeliveryDateTime', deliveryDateTime.getTime()
    @customDeliveryDate = ""
    @customDeliveryTime = ""

  _setNextPaymentDate: ->
    return unless @customNextPaymentDate
    paymentDate = +new Date("#{@customNextPaymentDate}")
    @set 'invoice.nextPaymentDate', paymentDate
    @customNextPaymentDate = ""

  addToListButtonClicked: (e)->
    item = e.model.item
    console.log {item}
    item.qty = 1
    item.price = item.price?= 0
    item.totalPrice = item.price?= 0
    item.category = item.category?= ''
    @push 'invoice.data', item
  
  _makeNewAddedInvestigationObject: (data)->
    object = {}
    objectStatus = {}
    objectStatus.hasTestResults = false
    objectStatus.testResultsSerial = null
    objectStatus.invoiceSerial = null

    object.investigationName = data.name
    object.investigationIdOnServer = data._id
    object.testList = data.investigationList
    object.price = data.price
    object.actualCost = data.actualCost
    object.status = objectStatus
    object.serial = @generateSerialForTestAdvisedInvestigation()
    object.suggestedInstitutionName = ''

    return object
  
  # addInvestigationToListButtonClicked: (e)->
  #   item = e.model.item

  #   if @testAdvisedObject.serial is null
  #     @testAdvisedObject.serial = @generateSerialForTestAdvised()
    
  #   newObj = @_makeNewAddedInvestigationObject item

  #   @testAdvisedObject.data.testAdvisedList.push newObj

    @push 'invoice.data', {
      name: newObj.investigationName
      visitSerial: null
      advisedTestSerial: @testAdvisedObject.serial
      investigationSerial: newObj.serial
      price: item.price?= 0
      actualCost: item.actualCost?= 0
      totalPrice: item.price?= 0
      qty: 1
      category: 'investigation'
    }

    

    

  addInventoryItemToListButtonClicked: (e)->
    doc = e.model.item.data
    item = {}
    if 'serial' of e.model.item
      item.inventorySerial = e.model.item.serial
    item.name = doc.name
    item.qty = 1
    item.actualCost = doc.buyingPrice?=0
    item.price = doc.sellingPrice?=0
    item.totalPrice = doc.sellingPrice?=0
    item.category = 'pharmacy'
    @push 'invoice.data', item

  
  deleteInvoiceItem: (e)->
    @splice 'invoice.data', e.model.index, 1
  
  
  lastPaymentChanged: (e)->
    el = e.target
    due = @_calculateDue(@invoice.totalBilled, @invoice.paid, 0, @isDue)
    if el.value > due
      el.invalid = true

  
  itemUnitPriceChanged: (e)->
    value = parseInt e.target.value
    return if value < 0
    el = @locateParentNode e.target, 'PAPER-ITEM'
    repeater = @$$ '#invoice-item-repeater'
    index = repeater.indexForElement el
    model = repeater.modelForElement el
    invoiceItem = @invoice.data[index]
    invoiceItem.price = value
    invoiceItem.totalPrice = value * invoiceItem.qty
    model.set 'item.totalPrice', (value * model.item.qty)
    @splice 'invoice.data', index, 1, invoiceItem

  itemCommissionPriceChanged:(e)->
    value = parseInt e.target.value
    return if value < 0
    el = @locateParentNode e.target, 'PAPER-ITEM'
    repeater = @$$ '#invoice-item-repeater'
    index = repeater.indexForElement el
    model = repeater.modelForElement el
    invoiceItem = @invoice.data[index]
    invoiceItem.commission = value
    model.set 'item.commission', value
    unless @invoice.commission
      @invoice.commission = {amount: 0}
    @splice 'invoice.data', index, 1, invoiceItem
  
  quantityChanged: (e)->
    model = e.model
    value = parseInt e.target.value
    if value > 1
      model.set 'item.qty', value
      model.set 'item.totalPrice', ( parseInt model.item.price * parseInt value)
    else 
      model.set 'item.qty', 1
      model.set 'item.totalPrice', model.item.price
    

  vatTaxInputChanged: (vatOrTax)->
    vatOrTaxtAmt = (@invoiceGrossPrice * vatOrTax) / 100
    @set "invoice.vatOrTax", vatOrTaxtAmt
    @calculateTotalBilled()
    # @set 'invoiceVatOrTax', value

  convertDiscountPercentageToAmount:(percentage)->
    return ( @invoiceGrossPrice * percentage )/ 100

  convertDiscountAmountToPercentage: (amount)->
    return ( amount * 100 ) / @invoiceGrossPrice
  
  discountTypeChanged:->
    if @invoiceDiscount
      @discountInputChanged(@invoiceDiscount)
  
  discountInputChanged: (value)->
    value = parseFloat value
    if @discountType is 0
      # discount is amount
      discountPercentage = @convertDiscountAmountToPercentage(value)
      @set "invoice.discount", value
    else
      # discount is percentage
      discountPercentage = value;
      discountAmt = @convertDiscountPercentageToAmount(value)
      console.log {discountAmt, @invoiceGrossPrice, value}
      @set "invoice.discount", discountAmt

    @calculateTotalBilled()
    if discountPercentage > @generalDiscountPercentageLimit and @fundList.length
      @set 'discountFundType', 1
      fundDiscountPercentage = discountPercentage - @generalDiscountPercentageLimit
      fundDiscountAmt = ( @invoiceGrossPrice * fundDiscountPercentage) / 100
      @set 'invoice.discountFromFund.amount', fundDiscountAmt
    else
      @set 'discountFundType', 0
      @set 'invoice.discountFromFund.amount', 0
  
  calculateNewDiscount: ()->
    return unless @invoiceDiscount
    discountAmt = if @discountType then @convertDiscountPercentageToAmount(@invoiceDiscount) else @invoiceDiscount
    @set "invoice.discount", discountAmt
    @calculateTotalBilled()

  calculateNewVatTax: ()->
    return unless @invoiceVatOrTax
    vatOrTaxtAmt = (@invoiceGrossPrice * @invoiceVatOrTax) / 100
    @set "invoice.vatOrTax", vatOrTaxtAmt
    @calculateTotalBilled()

  calculateGrossPrice: ->
    return unless @invoice.data
    price = @invoice.data.reduce (total, item)->
      return total += item.price * item.qty
    , 0
    @set "invoiceGrossPrice", price
    @calculateNewDiscount()
    @calculateNewVatTax()
    @calculateTotalBilled()
    @calculateCommission()
  
  
  calculateTotalBilled: ()->
    @debounce 'total', ()=>
      price = @invoiceGrossPrice
      discount = @invoice.discount
      vatOrTax = @invoice.vatOrTax
      if discount
        price = price - discount
      if vatOrTax
        price = price + vatOrTax
      @set 'invoice.totalBilled', price
    ,10

  calculateCommission:()->
    @debounce 'totalCommission', ()=>
      totalCommission = @invoice.data.reduce (total, item)->
          return total += item.commission or 0
        , 0
      console.log {totalCommission}
      @set 'invoice.commission.amount', totalCommission
    ,10


  _calculateDue: (advancePayment=0, total=0, paid=0, lastPaid=0, isDue)->
    advancePayment = if Number.isNaN(advancePayment) then 0 else parseFloat advancePayment
    total = if Number.isNaN(total) then 0 else parseFloat total
    paid = if Number.isNaN(paid) then 0 else parseFloat paid
    lastPaid = if Number.isNaN(lastPaid) then 0 else parseFloat lastPaid
    
    if total > 0 and advancePayment < total
      isDue = true
      due = total- (paid + lastPaid + advancePayment)
      if due > 0 then return due else return 0
    else
      isDue = false
      return 0

      
  _calculateRemainingBalanceFromAdvance: (advancePayment=0, totalBilled=0, cashBackPaid=0)->
    advancePayment = parseInt advancePayment
    advancePayment = 0 if Number.isNaN(advancePayment)
    totalBilled = parseInt totalBilled
    totalBilled = 0 if Number.isNaN(totalBilled)
    cashBackPaid = parseInt cashBackPaid
    cashBackPaid = 0 if Number.isNaN(cashBackPaid)
    if advancePayment > 0 and totalBilled > 0
      balance = ( advancePayment - (totalBilled + cashBackPaid) )
      if balance > 0 then return balance else return 0
    else
      return null

  _calculateTotalAmtReceived: (advancePayment=0, paid=0, lastPaid=0)->
    @debounce 'totalReceived', ()=>
      paid = if Number.isNaN(paid) then 0 else parseFloat paid
      lastPaid = if Number.isNaN(lastPaid) then 0 else parseFloat lastPaid
      advancePayment = if Number.isNaN(advancePayment) then 0 else parseFloat advancePayment
      totalAmountReceieved = paid + lastPaid + advancePayment
      @set 'invoice.totalAmountReceieved', totalAmountReceieved
    ,10

  _calculateCommissionFromPercentage: (commissionPercentage)->
    return unless @invoice.commission?.billed
    amount = (@invoice.commission.billed * commissionPercentage) / 100
    @set 'invoice.commission.amount', amount
    
  cashBackButtonClicked: ->
    balance = @_calculateRemainingBalanceFromAdvance(@invoice.advancePayment, @invoice.totalBilled)
    if balance > 0
      @set 'invoice.cashBackPaid', balance

  revertCashBack: -> @set 'invoice.cashBackPaid', 0

  $shouldShowCashBackButton: (balance)->
    console.log balance
    if balance then return true else return false

  _makeNewThirdPartyUser: (name, mobile)->
    return {
      serial: @generateSerialForThirdPartyUser()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      name: name
      mobile: mobile
    }

  thirdPartyUserNameSelected: (e)->
    serial = e.detail.value
    if serial
      thirdPartyUserArr = @thirdPartyUserList.filter (item)-> item.serial is serial
      if thirdPartyUserArr.length
        selectedThirdPartyUser = thirdPartyUserArr[0]
        @set 'invoice.commission.mobile', selectedThirdPartyUser.mobile?=""
        @set 'invoice.commission.address', selectedThirdPartyUser.address?=""

  thirdPartyUserMobileSelected: (e)-> 
    serial = e.detail.value
    if serial
      thirdPartyUserArr = @thirdPartyUserList.filter (item)-> item.serial is serial
      if thirdPartyUserArr.length
        selectedThirdPartyUser = thirdPartyUserArr[0]
        @set 'invoice.commission.name', selectedThirdPartyUser.name?=""
        @set 'invoice.commission.address', selectedThirdPartyUser.address?=""

  # INVOICE CATEGORY COMBO BOX
  # =====================================================

  _makeNewInvoiceCategoryList: (organizationIdentifier, userSerial)->
    return {
      serial: @generateSerialInvoiceCategory()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserSerial: userSerial
      organizationId: organizationIdentifier
      data: []
    }
  
  invoiceTypeCustomValueSet: (e)->
    e.preventDefault()
    value = e.detail
    return unless value
    @push 'invoiceCategoryList.data', value
    @invoiceCategoryList.lastModifiedDatetimeStamp = lib.datetime.now()
    @set 'invoice.category', value

  # INVOICE CATEGORY COMBO BOX ENDS
  
  # COMMISSION TYPE COMBO BOX STARTS
  # ============================================

  commissionTypeCustomValueSet: (e)->
    e.preventDefault()
    value = e.detail
    return unless value
    @set 'invoice.commission.type', value

  # COMMISSION TYPE COMBO BOX ENDS

  # ===========================================================
  # ADD INVESTIGATION TO INVOICE
  # ===========================================================
  
  _mergeDuplicateTestWithHighestPrice: (list)->
    testNameMap = {}
    for item in list
      if item.name in testNames
        if item.name of testNameMap
          price = testNameMap[item.name]
          if item.price < price
            testNameMap[item.name] = item.price
        else
          testNameMap[item.name] = item.price
    return testNameMap
  
  _addSelectedTestAdviseToInvoice: (invoice, selectedTestList)->
    # Merging Duplicates with Highest Price
    # testNameMap = @_mergeDuplicateTestWithHighestPrice(@investigationPriceList.data)
    console.log {selectedTestList}
    for item in selectedTestList
      @push 'invoice.data', {
        name: item.data.investigationName
        visitSerial: item.visitSerial
        advisedTestSerial: item.advisedTestSerial
        investigationSerial: item.data.serial
        price: item.data.price?= 0
        actualCost: item.data.actualCost?= 0
        totalPrice: item.data.price?= 0
        qty: 1
        category: 'investigation'
      }
    
    # Adding Custom Investigation
    unless selectedTestList.length is invoice.data.length
      invoiceMade = (item.name for item in invoice.data)
      for item in selectedTestList
        unless item.name in invoiceMade
          test = {
            qty: 1
            name: item.data.investigationName
            visitSerial: item.visitSerial?=""
            advisedTestSerial: item.advisedTestSerial
            investigationSerial: item.data.serial
            price: 0
            actualCost: 0
            totalPrice: 0
            category: 'investigation'
          }
          @push 'invoice.data', test
    
    # Adding Modification history for this invoice
    modificationHistoryItem =
      userSerial: @user.serial
      lastModifiedDatetimeStamp: lib.datetime.now()
    
    @push 'invoice.modificationHistory', modificationHistoryItem
    @set 'invoice.lastModifiedDatetimeStamp', lib.datetime.now()

    console.log @invoice
  
  
  # ===========================================================
  # SAVING INVOICE
  # ===========================================================

  _validateInvoice: (invoice)->
    return true if invoice.freePatient
    minimumPayment = if @minimumPaymentPercentageLimit then ((invoice.totalBilled * @minimumPaymentPercentageLimit) / 100) else 0
    unless invoice.data.length
      @domHost.showModalDialog 'Add some item into invoice'
      return false
    if minimumPayment and invoice.totalAmountReceieved < minimumPayment
      @domHost.showModalDialog "Please pay minimum #{minimumPayment} BDT"
      return false
    if 0 > @invoiceVatOrTax > 100
      @domHost.showModalDialog 'Percentage can not be greater than 100'
      return false
    if @generalDiscountPercentageLimit and @convertDiscountAmountToPercentage(invoice.discount) > @generalDiscountPercentageLimit and @fundList.length
      unless @invoice.discountFromFund?.serial
        @domHost.showModalDialog 'Please Select Special Discount Fund'
        return false
    if invoice.totalAmountReceieved > invoice.totalBilled
      @domHost.showModalDialog 'Received Amount can not be greater than Total Billed'
      return false
    return true
  
  
  _updateAdvisedTestForInvoice: (invoiceSerial, invoiceData, cbfn)->
    updatedAdviseListWithInvoice = {
      apiKey: @user.apiKey
      data: []
    }
    
    for item in invoiceData
      if 'advisedTestSerial' of item
        updatedAdviseListWithInvoice.data.push {
          invoiceSerial: invoiceSerial
          investigationSerial: item.investigationSerial
          advisedTestSerial: item.advisedTestSerial
        }
    
    if updatedAdviseListWithInvoice.data.length
      @callApi '/bdemr-update-test-advise-list-for-invoice', updatedAdviseListWithInvoice, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          cbfn()
        
  
  _saveThirdPartyCommissionUser: (invoice)->
    thirdPartyUserName = invoice.commission.name
    thirdPartyUserMobile = invoice.commission.mobile
    thirdPartyUserFound = @thirdPartyUserList.some (item)=> item.name is thirdPartyUserName or item.mobile is thirdPartyUserMobile
    # for item in @thirdPartyUserList
    #   if item.name is thirdPartyUserName or item.mobile is thirdPartyUserMobile
    #     thirdPartyUserFound = true
    #     break
    unless thirdPartyUserFound
      app.db.insert 'third-party-user-list', @_makeNewThirdPartyUser(thirdPartyUserName, thirdPartyUserMobile)
  
  _reduceInventoryItems: (invoice)->
    for item in invoice.data
      if 'inventorySerial' of item
        doc = (app.db.find 'organization-inventory', ({serial})=> serial is item.inventorySerial)[0]
        console.log doc
        doc.data.qty -= item.qty
        app.db.update 'organization-inventory', doc._id, doc

  _assignInvoiceRef: (referenceNumber, cbfn)->
    if referenceNumber
      cbfn(null)
    else
      @_getNextInvoiceRef (refNumber)=>
        referenceNumber = @_makeInvoiceRef refNumber
        cbfn(referenceNumber)
  
  _addModificationHistory: ->
    now = lib.datetime.now()
    modificationHistory =
      userSerial: @user.serial
      lastModifiedDatetimeStamp: now
    @invoice.modificationHistory.push modificationHistory
    @invoice.lastModifiedDatetimeStamp = now
  
  
  
  makeFreePatientButtonClicked: ->
    @set 'invoice.totalBilled',0;
    @set 'invoice.freePatient', true;

  _callThirdPartyAddCommissionApi: (thirdPartyId, commissionAmount)->
    data =
      apiKey: this.user.apiKey
      thirdPartyId: thirdPartyId
      commissionAmount: commissionAmount
      organizationId: @organization.idOnServer
      logType: 'Commission Added'
  
    @callApi '/bdemr--organization-third-party-add-commission', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        return
  
  _syncOnlyTestAdvised: (cbfn)->
    @domHost._newSync cbfn
  
  _saveInvoice: (markAsCompleted, cbfn)->
  
    return unless @_validateInvoice @invoice
    params = @domHost.getPageParams()

    if markAsCompleted
      @invoice.flags.markAsCompleted = true
      @invoice.flags.flagAsError = !@invoice.flags.markAsCompleted
    

    
    @_addModificationHistory()
    
    # check for inventory items and reduce
    @_reduceInventoryItems @invoice

    # Save Unique Third Party Commission User
    # @_saveThirdPartyCommissionUser @invoice
    
    # Saving report delivery date time
    if @customDeliveryDate
      @_setReportDeliveryDateTime()

    # Saving next payment date time
    if @customNextPaymentDate
      @_setNextPaymentDate()
    

    if @invoice.commission
      @_callThirdPartyAddCommissionApi @invoice.commission._id, @invoice.commission.amount
      


    # Saving Custom Invoice Category List
    # app.db.upsert 'invoice-category-list', @invoiceCategoryList, ({serial})=> serial is @invoiceCategoryList.serial
    
    # Assign a referenceNumber if not present
    @_assignInvoiceRef @invoice.referenceNumber, (refNumber)=>
      
      @invoice.referenceNumber = refNumber if refNumber

      app.db.upsert 'patient-invoice', @invoice, ({serial})=> serial is @invoice.serial
      
      
      if @invoice.discountFromFund?.serial and markAsCompleted
        @_deductDiscountAmountFromFund @invoice.discountFromFund.serial, @invoice.discountFromFund.amount, ()=> null
      
      if params['testAdviseAdded']
        @_updateAdvisedTestForInvoice @invoice.serial, @invoice.data, ()=>
          @domHost.showToast 'Invoice Saved Successfully'
          cbfn @invoice.serial
      

      if @testAdvisedObject.serial
        @testAdvisedObject.data.testAdvisedList = @_extractInvestigationFromInvoiceData()

        if @testAdvisedObject.data.testAdvisedList.length > 0
          @saveAdvisedTest =>
            @_syncOnlyTestAdvised (errMessage)=>
              if errMessage
                return @domHost.showModalDialog errMessage;

              @_updateAdvisedTestForInvoice @invoice.serial, @invoice.data, ()=>
                console.log 'three'
                @domHost.showToast 'Invoice Saved Successfully'
                cbfn @invoice.serial

  # =====================================================================

  # commissionTypeChanged: (e)->
  #   @invoice.commission.category = @commissionCategoryList[@commissionCategoryIndex]

  _notifyInvalidOrganization: ->
    @showModal 'No Organization is Present. Please Select an Organization first.'
  
  saveAndCompleteInvoiceButtonClicked: ->
    @_saveInvoice markAsCompleted = true, (invoiceSerial)=>
      @domHost.navigateToPreviousPage()

  saveInvoiceButtonClicked: ()->
    @_saveInvoice markAsCompleted = false, (invoiceSerial)=>
      @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    @_saveInvoice markAsCompleted = false, (invoiceSerial)=>
      @domHost.navigateToPreviousPage()

  _chargeWalletContextual: (context)->
    chargeDoc = {
      patientId: @patient.idOnServer
      amount: @invoice.totalAmountReceieved
      purpose: "Invoice Bill"
      organizationId: @organization.idOnServer
      context
    }

    @_chargePatientContextual chargeDoc, (err)=>
      if (err)
        @domHost.showModalDialog("Unable to charge the patient. #{err.message}")
      else
        @domHost.showModalDialog "Successfully Charged"
  
  chargeIndoorWalletButtonPressed: ->
    @_chargeWalletContextual 'indoor'

  chargeOutdoorWalletButtonPressed: ->
    @_chargeWalletContextual 'outdoor'

  arrowBackButtonPressed: ->
    @domHost.navigateToPreviousPage()
  
  

  ## Third Party - start

  formatThirdPartyData: (data)->
    modifiedData = []
    for item in data
      modifiedData.push {label: item.name, value: item}
    @set 'thirdParties', modifiedData

    console.log modifiedData


  _callGetThirdPartiesApi: ()->
    data = 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    @domHost.toggleModalLoader('Updating..')
    @callApi '/bdemr--get-organization-third-party-short-list', data, (err, response)=> 
      console.log(response)
      @domHost.toggleModalLoader()
      if response.hasError
        return @domHost.showModalDialog(response.error.message);
      else
        @formatThirdPartyData response.data
        return

  ## Third Party - end
  
  savePlusPrintInvoiceButtonClicked: ()->
    @_saveInvoice markAsCompleted = false, (invoiceSerial)=>
      # store the print type
      if @printTypeValue?
        localStorage.setItem 'invoicePrintType', JSON.stringify @printTypeArray[@printTypeValue]
      else
        # remove previous set value, if any
        localStorage.removeItem 'invoicePrintType'
      @domHost.navigateToPage '#/print-invoice/invoice:' + invoiceSerial + '/patient:' + @patient.serial


}