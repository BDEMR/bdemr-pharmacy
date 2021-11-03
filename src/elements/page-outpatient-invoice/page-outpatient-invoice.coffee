###
  Business logic:
    - 
###

Polymer {
  is: 'page-outpatient-invoice'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    
    availableBalance:
      type: Number
      value: 0
    
    previouseDue:
      type: Number
      value: 0

    EDIT_MODE:
      type: Boolean
      value: false

    patientWalletBalance:
      type: Number
      value: 0
    
    deductFromWallet:
      type: Number
      value: 0

    user:
      type: Object
      notify: true
      value: (app.db.find 'user')[0]

    patient:
      type: Object
      notify: true
      value: -> {}

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
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

    previousInvoiceDataList:
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

    HideGnrtNmbrBtn:
      type: Boolean
      value: true

    isLoading:
      type: Boolean
      value: false

    customPhnNmbrObj:
      type: Object
      notify: true
      value: null

    printTypeArray:
      type: Array
      value: -> ['Cash/Original', 'Duplicate', 'Final Bill']

    patientStatusArray:
      type: Array
      value: -> [{label:'Indoor Patient', value:'indoor'}, {label:'Outdoor Patient', value:'outdoor'}, {label:'Emergency Patient', value:'emergency'}]

    customDeliveryDate: String 
    customDeliveryTime: String
    customNextPaymentDate: String

    categories:
      type: Array
      value: []
    
    inventoryItemSearchQuery:
      type: String
      value: -> ""
      observer: 'inventoryItemSearchInputChanged'

    showCategoryAndItemSearch:
      type: Boolean
      value: true

    patientExists:
      type: Boolean
      value: false

    showPatientContactDetails:
      type: Boolean
      value: false

    referenceByList:
      type: Object
      value: -> {}

    commissionObject:
      type: Object
      value: -> {}
    

  observers: [
    'calculateGrossPrice(invoice.data.*)'
    '_calculateTotalAmtReceived(invoice.paid, invoice.lastPaid)'
    '_calculateCommissionFromPercentage(commissionPercentage)'
    '_patientPhoneSearchQuery(patient.phone)'
  ]

  _onDeductFromValueChanged: (e)->
    value = e.target.value
    deductFromWallet = parseInt value
    patientWalletBalance = parseInt @patientWalletBalance

    if deductFromWallet > patientWalletBalance
      @set "invoice.deductFromWallet", 0
      @set "computedAvailableWalletBalance", patientWalletBalance
      return

    @set "computedAvailableWalletBalance", patientWalletBalance - deductFromWallet
    @invoice.deductFromWallet = deductFromWallet


  _getFullName:(data)->
    if typeof data is "object"
      honorifics = ''
      first = ''
      last = ''
      middle = ''

      if data.honorifics  
        honorifics = data.honorifics + ". "
      if data.first
        first = data.first
      if data.middle
        middle = " " + data.middle
      if data.last
        last = " " + data.last
        
      return honorifics + first + middle + last

    else return data


  # compute function - start
  calculateAge: (e)->
    selectedDate = e.detail.value
    console.log 'selected age : ', selectedDate

    # extending computeAge() from common-computes
    today = new Date()
    birthDate = new Date selectedDate
    yearDiff = today.getFullYear() - birthDate.getFullYear()
    monthDiff = today.getMonth() - birthDate.getMonth()
    dateDiff = today.getDate() - birthDate.getDate()

    console.log 'initial year diff : ', yearDiff
    console.log 'initial month diff : ', monthDiff
    console.log 'initial date diff : ', dateDiff

    if monthDiff is 0
      if dateDiff < 0
        yearDiff-- unless yearDiff is 0
        monthDiff = 11
    else if monthDiff < 0
      yearDiff-- unless yearDiff is 0
      monthDiff = 12 - Math.abs monthDiff
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0
    else
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0


    console.log 'year diff : ', yearDiff
    console.log 'month diff : ', monthDiff

    @set 'ageInYears', yearDiff
    @set 'ageInMonths', monthDiff

  makeDOBFromYMD: (e)->
    uptoHour = 24*60*60*1000
    yearTimeInMS = Math.round (@ageInYears*365.25*uptoHour) # 365.25 to account for leap years
    monthTimeInMS = Math.round (@ageInMonths*30.5*uptoHour) # 30.5 to account for 30/31 days
    
    dobTime = (new Date).getTime()-yearTimeInMS-monthTimeInMS
    dobDate = new Date ((new Date).setTime(dobTime))
    tempDOB_Y = dobDate.getFullYear()
    tempDOB_M = (dobDate.getMonth()+1).toString()

    if tempDOB_M.length is 1 then tempDOB_M = "0#{tempDOB_M}"

    console.log 'year ', tempDOB_Y
    console.log 'month ', tempDOB_M

    @set 'patient.dateOfBirth', "#{tempDOB_Y}-#{tempDOB_M}-01"
    return
  
  
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
      patientSerial: null # add later
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
    console.log 'extracted investigations', list
    return list

  _callSetVisitAdvisedTestApi: (cbfn)->
    @testAdvisedObject.apiKey = @user.apiKey
    @callApi '/bdemr-set-advised-test', @testAdvisedObject, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  saveAdvisedTest: (cbfn)->
    @testAdvisedObject.lastModifiedDatetimeStamp = lib.datetime.now()
    for item in @testAdvisedObject.data.testAdvisedList
      if item.status.invoiceSerial = null or 'undefined'
        item.status.invoiceSerial = @invoice.serial
      else
        return
    # app.db.upsert 'visit-advised-test', @testAdvisedObject, ({serial})=> @testAdvisedObject.serial is serial
    console.log {@testAdvisedObject}
    @_callSetVisitAdvisedTestApi =>
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
  
  getPatientAvailableBalance: ()->
    data = {
      apiKey: @user.apiKey
      patientSerial: @patient.serial
      organizationId: @organization.idOnServer
    }

    @callApi '/bdemr-get-patient-available-balance', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set "availableBalance", response.data.totalAvailableBalance
        @set "previouseDue", response.data.totalAvailableDue


  showPatientPreviousInvoiceItems: ()->
    if !@patient.serial
      return @domHost.showToast 'Please Select Patient First!'    
    data = {
      apiKey: @user.apiKey
      patientSerial: @patient.serial
    }

    @callApi '/bdemr--clinic-show-patient-previous-invoice-items', data, (err, response)=>
      if response.hasError
        # console.log response
        @domHost.showToast response.error.message
      else
        list = response.data
        @set 'previousInvoiceDataList', list
        @invoice.previousInvoiceData = list
        @invoice.finalBill = true
        console.log "list", list
          


  showPatientMedicine: ()->
    console.log {@patient}
    if !@patient.serial
      return @domHost.showToast 'Please Select Patient First!'

    @getPatientCurrentMedicationList @patient.serial, =>
      @$$("#showPatientMedicaitonDialog").toggle()
      # lib.util.delay 500, =>
      #   @$$("#showPatientMedicaitonDialog").center()
  
  getPatientCurrentMedicationList: (patientSerial, cbfn)->
    data = {
      apiKey: @user.apiKey
      patientSerial: patientSerial
    }

    @callApi '/bdemr-get-patient-current-medication-list', data, (err, response)=>
      if response.hasError
        # console.log response
        @domHost.showToast response.error.message
      else
        @selectedPatientMedicationList = response.data
        cbfn()
  
  addItemFromPatientMedication: (e)->
    console.log 'med list', @selectedPatientMedicationList
    for medicine in @selectedPatientMedicationList
      if medicine.isSelected
        item = {}
        item.name = medicine.data.brandName
        item.qty = 1
        item.price = medicine.price?= 0
        item.actualCost = item.actualCost?= 0
        item.totalPrice = medicine.price?= 0
        item.tag = item.tag?= 'medicine'
        @push 'invoice.data', item
    
    console.log @invoice
  
  _returnSerial: (index)->
    index+1

  _computeTotalDaysCount: (endDate, startDate)->
    return (@$TRANSLATE("As Needed", @LANG)) unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    diffMs = endDate - startDate
    x =  Math.round(diffMs / oneDay)
    return @$TRANSLATE_NUMBER(x, @LANG)
  
  _getDiscountedPrice: (discountAmount=0, discountType=0, price=0, qty=1)->
    price = price * qty

    console.log {discountAmount, discountType, price, qty}
    
    return price if !discountAmount

    # temporary commented out for quick fix on H&H request for discount was not working
    # return price if !discountType

    discountAmount = parseFloat discountAmount

    return price if Math.sign(discountAmount) is -1

    # temporary commented out for quick fix on H&H request for discount was not working
    # return price - ((price * discountAmount) / 100) if discountType is 'Percentage'
    
    return parseInt(price - discountAmount)

  navigatedIn: ->

    refreshpageFlag = JSON.parse localStorage.getItem 'refreshPage'
    # console.log 'inside navigated in. refresh page flag', refreshpageFlag
    # @set "HideGnrtNmbrBtn", true
    # @set "availableBalance", 0
    # @set "previouseDue", 0
    @_makeNewInvoice()
    
    if refreshpageFlag and !refreshpageFlag.value
      console.log 'returning from preview, DONT REFRESH'
      localStorage.removeItem 'refreshPage'
      @_loadUser()
      @_loadOrganization null
    else
      params = @domHost.getPageParams()
      @_loadUser()
      @_loadOrganization =>
        console.log 'organization', @organization

        @_makePatientSignupObject()

        @_makeNewCommissionObject()
        @_makeNewTestAdvisedObject()
        @set 'hasTestAdvisedAdded', false
        @set 'showCategoryAndItemSearch', true


        @_getInvestigationList @organization.idOnServer, =>
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
          @_loadInvoiceReferenceByList @organization.idOnServer
          @_callGetThirdPartiesApi()
          @_getCategories()


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  

  _loadOrganization: (cbfn)->
    organization = (app.db.find 'organization')[0]
    data = { 
      apiKey: @user.apiKey
      idList: [ organization.idOnServer ]
    }
    @domHost.toggleModalLoader 'Please Wait...'
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]

        @set 'isOrganizationValid', true
        @_loadMemberList()
        cbfn() if cbfn
  

  # search patient by phone
  _patientPhoneSearchQuery: (searchQuery)->
    return if @patientExists
    @debounce 'search-patient-by-phone', ()=>
      unless (searchQuery and searchQuery.length >= 11)
        @patientExists = false
        return 
      @_searchPatientByPhone searchQuery
    , 300

  _searchPatientByPhone: (searchQuery)->
    data = 
      apiKey: @user.apiKey
      searchQuery: searchQuery

    console.log 'query', data
    @callApi '/bdemr-patient-search-new', data, (err, response)=>
      @arbitaryCounter--
      @patientExists = false
      if response.hasError
        # @domHost.showModalDialog response.error.message
      else
        matchingPatientList = response.data
        if matchingPatientList.length > 0
          existingPatient = matchingPatientList[0]
          console.log 'existing patient', existingPatient
          @domHost.showModalInput "Patient already exists. Please enter patient PIN to import", "0000", (answer)=>
            if answer
              @HideGnrtNmbrBtn = false
              @initiateExistingPatient existingPatient.serial, answer, (patientIdentifier)=>
                list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
                if list.length is 1
                  @isPatientValid = true
                  tempPatient = list[0]
                  console.log 'temp patient after loading', tempPatient

                  # remove all signup-patient properties from @patient and keep only neccessary ones from existing patient info
                  Object.keys(@patient).forEach (prop)=>
                    if prop isnt 'phone' 
                      delete @patient[prop]
                  

                  @set 'patient.name', @_getFullName tempPatient.name
                  @set 'patient.dateOfBirth', tempPatient.dateOfBirth
                  @set 'patient.gender', tempPatient.gender
                  @set 'patient.addressList', tempPatient.addressList
                  @set 'patient.serial', tempPatient.serial
                  @set 'patient.idOnServer', tempPatient.idOnServer

                  @getPatientAvailableBalance()

                  # delete above properties from tempPatient first, then assign to have identical
                  # Object.assign @patient, tempPatient



                  console.log 'imported patient', @patient
                else
                  @_notifyInvalidPatient()
        
    
  navigatedOut: ->
    @_makeNewInvoice()
    refreshpageFlag = JSON.parse localStorage.getItem 'refreshPage'
    console.log 'inside navigated out. refresh page flag', refreshpageFlag
    unless refreshpageFlag
      console.log 'going to different page'
      @printTypeValue = null
      @set 'invoice', {}
      @set "invoiceGrossPrice", 0
      @set "invoiceDiscount",  0
      @set "invoiceVatOrTax", 0
      @set 'discountType', 0
    

      


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
    @domHost.toggleModalLoader 'Please Wait...'
    @callApi 'bdemr--clinic-get-discount-fund-list', data, (err, response)=>
      @domHost.toggleModalLoader()
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
    @domHost.toggleModalLoader 'Please Wait...'
    @callApi 'bdemr--clinic-deduct-discount-fund', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log "Fund Deduction Executed"
        cbfn()

  # Modal
  # ===================================

  addCustomItemToInvoiceButtonPressed: ->
    # @.$.customItemModal.toggle()
    @domHost.navigateToPage '#/manage-unit-price'

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
    # OLD
    # @set 'invoiceSourceDataList', []
    # # inventoryList = ({name: item.data.name, price: item.data.sellingPrice, actualCost: item.data.buyingPrice, category: 'medicine'} for item in @inventoryList)
    # @_loadMedicineCompositionList (medicineSourceDataList)=>
    #   # Getting All Prices Together
    #   console.log @investigations
    #   concatList = [].concat @investigations,  @servicePriceList.data, @otherPriceList.data, @packagePriceList.data, @supplyPriceList.data, @ambulancePriceList.data, medicineSourceDataList
    #   autocompleteList = ({label: item.name, value: item} for item in concatList)
    #   @set 'invoiceSourceDataList', autocompleteList

    # NEW
    @filterCategory = 'all'
    @selectedCategory = null
    @_searchInventoryItem ''
  

  invoiceItemAutocompleteSelected: (e)->
    e.target.selectedItem = null
    return unless e.detail.value
    item = e.detail.value
    console.log 'selected item', item

    if @invoice.data.length
      for investigation in @invoice.data
        if investigation.investigationIdOnServer is item.value._id
          return @domHost.showModalDialog 'Item already exists' 

    if @testAdvisedObject.serial is null
      @testAdvisedObject.serial = @generateSerialForTestAdvised()
    
    newObj = @_makeNewAddedInvestigationObject item.value

    @testAdvisedObject.data.testAdvisedList.push newObj

    initialPrice = item.value?.price?= 0
    initialActualCost = item.value?.actualCost?= 0
    initialQty = 1
    initialTotalPrice = item.price?= (initialPrice * initialQty)

    @push 'invoice.data', {
      itemId: item.value._id
      name: newObj.investigationName
      visitSerial: null
      discountAmount: item.value.discountAmount?= 0
      discountType: item.value.discountType
      discountedPrice: @_getDiscountedPrice item.value.discountAmount, item.value.discountType, initialPrice, initialQty
      advisedTestSerial: @testAdvisedObject.serial
      investigationSerial: newObj.serial
      investigationIdOnServer: newObj.investigationIdOnServer
      price: initialPrice
      actualCost: initialActualCost
      totalPrice: initialTotalPrice
      qty: initialQty
      stock: item.quantity
      category: item.value?.category
      location: item.value?.location
      tag: item.value.tag or ''
    }

    # @$$("#invoiceSearchInput").value = null
    console.log 'invoice', @invoice

  
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
    data =
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
      createdByUserSerial: userSerial
    
    @callApi 'bdemr--organization-patient-invoice-category-list', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        invoiceCategoryList = response.data
        console.log invoiceCategoryList
        if invoiceCategoryList.length is 0
          @set 'invoiceCategoryList', @_makeNewInvoiceCategoryList organizationIdentifier, userSerial
        else
          @set 'invoiceCategoryList', invoiceCategoryList[0]  

    # list = app.db.find 'invoice-category-list', ({organizationId, createdByUserSerial})=> organizationId is organizationIdentifier and createdByUserSerial is userSerial
    # if list.length
    #   @set 'invoiceCategoryList', list[0]
    # else
    #   @set 'invoiceCategoryList', @_makeNewInvoiceCategoryList organizationIdentifier, userSerial
    # console.log 'invocie category', @invoiceCategoryList

  _loadInvoiceReferenceByList: (organizationIdentifier)->
    list = app.db.find 'invoice-reference-by-list', ({organizationId})=> organizationId is organizationIdentifier
    if list.length
      @set 'referenceByList', list[0]
    else
      @set 'referenceByList', @_makeNewReferenceByList organizationIdentifier
    
    console.log 'Reference BY', @referenceByList
    

  _loadInvestigationPriceList: (organizationIdentifier)->
    investigationPriceList = (app.db.find 'investigation-price-list', ({organizationId})-> organizationId is organizationIdentifier)

    if investigationPriceList.length > 0
      @investigationPriceList = investigationPriceList[0]


  _getInvestigationList:(organizationId, cbfn)->
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-investigation-list-new', { apiKey: @user.apiKey, organizationId: organizationId }, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @showWarningToast response.error.message
      else
        data = response.data
        @set 'investigations', data
        cbfn()

  
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
    # @domHost.getStaticData 'medicineCompositionList', (medicineCompositionList)=>
    #   brandNameMap = {}
    #   for item in medicineCompositionList
    #     brandNameMap[item.brandName] = null
    #   generatedMedicineList = ({data: {name: item, buyingPrice: 0, sellingPrice: 0, qty: 1}} for item in Object.keys brandNameMap)

    inventory = app.db.find 'organization-inventory', ({organizationId})-> organizationId is organizationIdentifier
    @medicineInventory = inventory
      

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
  
 
  _getNextInvoiceRef: (cbfn)->
    query =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @callApi '/bdemr-clinic-app--organization-invoice--get-next-ref-number', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
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
      createdDatetimeStamp: null
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      patientSerial: null # add later
      patientName: null # add later
      patientPhone: null # add later
      patientEmail: null # add later
      patientSecondaryPhone: null
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      modificationHistory: []
      lastModifiedDatetimeStamp: null
      invoiceType: 'patient'
      category: ''
      advancePayment: 0
      remainingBalance: 0
      totalBilled: 0
      paid: null
      previouseDue: 0
      lastPaid: null
      discount: null
      discountItemWise: null
      totalAmountReceieved: null
      cashBackPaid: 0
      finalBill: false
      flags:
        flagAsError: false
        markAsCompleted: false
      data: []
      previousInvoiceData: []
      commission: []
      availableToPatient: true
      reportDeliveryDateTime: null
      nextPaymentDate: null
      referralDoctor: {
        name: ""
        mobile: ""
        id: ""
      }
      remarks: ""
      referenceBy: ''
      discountBy: ""
      discountFromFund: {}
      vatOrTax: 0
      dueGuarantor: {
        name: ""
        phone: ""
        email: ""
        role: ""
        id: ""
      }
      patientStatus: 'outdoor'
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
    # objectStatus.invoiceSerial = null # previous
    objectStatus.invoiceSerial = @invoice.serial # new

    object.investigationName = data.name
    object.investigationIdOnServer = data._id
    object.hasGroupTest = data.hasGroupTest
    object.testList = data.investigationList
    object.testGroupList = data.testGroupList
    object.price = data.price
    object.actualCost = data.actualCost
    object.discountAmount = data.discountAmount
    object.discountType = data.discountType
    object.status = objectStatus
    object.serial = @generateSerialForTestAdvisedInvestigation()
    object.suggestedInstitutionName = ''
    
    object.category = data.category # added for new investigation checking
    console.log object
    return object
  
  addInvestigationToListButtonClicked: (e)->
    item = e.model.item
    console.log {item}

    if @testAdvisedObject.serial is null
      @testAdvisedObject.serial = @generateSerialForTestAdvised()
    
    newObj = @_makeNewAddedInvestigationObject item

    @testAdvisedObject.data.testAdvisedList.push newObj

    @push 'invoice.data', {
      name: newObj.investigationName
      visitSerial: null
      discountAmount: item.value.discountAmount?= 0
      discountType: item.value.discountType
      advisedTestSerial: @testAdvisedObject.serial
      investigationSerial: newObj.serial
      price: item.price?= 0
      actualCost: item.actualCost?= 0
      totalPrice: item.price?= 0
      qty: 1
      tag: item.tag
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
    due = @_calculateDue(@invoice.totalBilled, @invoice.paid, 0, @availableBalance, @previouseDue, @isDue)
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
    console.log model.item
    quantity = parseInt model.item.stock
    value = parseInt e.target.value
    if value > 1 && value <= quantity
      model.set 'item.qty', value
      model.set 'item.totalPrice', ( parseInt model.item.price * parseInt value)
      model.set 'item.discountedPrice', @_getDiscountedPrice model.item.discountAmount, model.item.discountType, model.item.price, parseInt value
    else 
      @domHost.showWarningToast "Item Quantity cant be greater than Stock Quantity!"
      model.set 'item.qty', 1
      model.set 'item.totalPrice', model.item.price
      model.set 'item.discountedPrice', @_getDiscountedPrice model.item.discountAmount, model.item.discountType, model.item.price, 1
  

  discountAmountChanged: (e)->
    model = e.model
    discountAmount = parseFloat e.target.value
    model.set 'item.discountAmount', discountAmount
    model.set 'item.discountedPrice', @_getDiscountedPrice discountAmount, model.item.discountType, model.item.price, model.item.qty

    
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
      return total += (item.price * item.qty) - item.discountAmount
      # return total += item.price * item.qty
      # return total += item.discountedPrice
    , 0
    
    @set "invoiceGrossPrice", price
    @calculateNewDiscount()
    @calculateNewVatTax()
    @calculateTotalBilled()
    # @calculateCommission()
  
  
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


  _calculateAvailableBalance: (bill=0, paid=0, availableBalance=0, cashBackPaid=0, previouseDue=0)->
    bill = if Number.isNaN(bill) then 0 else parseFloat bill
    paid = if Number.isNaN(paid) then 0 else parseFloat paid
    availableBalance = if Number.isNaN(paid) then 0 else parseFloat availableBalance
    cashBackPaid = if Number.isNaN(cashBackPaid) then 0 else parseFloat cashBackPaid
    previouseDue = if Number.isNaN(previouseDue) then 0 else parseFloat previouseDue

    bill = bill + previouseDue

    totalAvailableBalance = (paid + availableBalance) - cashBackPaid
    
    if (totalAvailableBalance > bill)
      return totalAvailableBalance = totalAvailableBalance - bill
    
    return 0


  _calculateDue: (total=0, paid=0, lastPaid=0, availableBalance=0, previouseDue=0, isDue)->
    # advancePayment = if Number.isNaN(advancePayment) then 0 else parseFloat advancePayment
    total = if Number.isNaN(total) then 0 else parseFloat total
    paid = if Number.isNaN(paid) then 0 else parseFloat paid
    lastPaid = if Number.isNaN(lastPaid) then 0 else parseFloat lastPaid
    availableBalance = if Number.isNaN(paid) then 0 else parseFloat availableBalance
    previouseDue = if Number.isNaN(previouseDue) then 0 else parseFloat previouseDue

    isDue = true

    due = total - (paid + lastPaid + availableBalance)

    # due = due + previouseDue

    if due > 0 then return due else return 0

      
  _calculateRemainingBalanceFromAdvance: (advancePayment=0, totalBilled=0, cashBackPaid=0)->
    advancePayment = parseInt advancePayment
    advancePayment = 0 if Number.isNaN(advancePayment)
    totalBilled = parseInt totalBilled
    totalBilled = 0 if Number.isNaN(totalBilled)
    cashBackPaid = parseInt cashBackPaid
    cashBackPaid = 0 if Number.isNaN(cashBackPaid)
    if advancePayment > 0 and totalBilled >= 0
      balance = ( advancePayment - (totalBilled + cashBackPaid) )
      @set 'invoice.remainingBalance', balance
      if balance > 0 then return balance else return 0
    else
      return null

  _calculateTotalAmtReceived: (paid=0, lastPaid=0)->
    paid = parseFloat paid
    lastPaid = parseFloat lastPaid
    @debounce 'totalReceived', ()=>
      paid = if Number.isNaN(paid) then 0 else parseFloat paid
      lastPaid = if Number.isNaN(lastPaid) then 0 else parseFloat lastPaid
      totalAmountReceieved = paid + lastPaid
      @set 'invoice.totalAmountReceieved', totalAmountReceieved
    ,10

  _calculateCommissionFromPercentage: (commissionPercentage)->
    amount = (@commissionObject.billed * commissionPercentage) / 100
    @set 'commissionObject.amount', amount
    
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
  
  # INVOICE Reference By COMBO BOX STARTS
  # =====================================================  
  
  _makeNewReferenceByList: (organizationIdentifier)->
    return {
      serial: @generateSerialForReferenceByList()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      organizationId: organizationIdentifier
      data: []
    }
  
  referenceByCustomValueSet: (e)->
    e.preventDefault()
    value = e.detail
    return unless value
    @push 'referenceByList.data', value
    @referenceByList.lastModifiedDatetimeStamp = lib.datetime.now()
    @set 'invoice.referenceBy', value

  # INVOICE REFERRAL DOCTOR COMBO BOX ENDS    


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
        discountAmount: item.data.discountAmount?= 0
        discountType: item.data.discountType
        discountedPrice: 0
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
            discountAmount: item.data.discountAmount?= 0
            discountType: item.data.discountType
            discountedPrice: 0
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
    console.log 'inside update advised test'
    console.log 'invoice', @invoice
    console.log 'invoice data', invoiceData
    return cbfn() if !invoiceData

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
    console.log invoice
    return if invoice.data.length is 0
    data = invoice.data
    console.log {data}    
    filterItems = data.map (item) => { productId: item.itemId, reduceQty: item.qty }
    
    apiData =
      apiKey: this.user.apiKey
      list: filterItems
      organizationId: @organization.idOnServer
      addedByUserName: this.user.name
  
    @callApi '/bdemr-cmh-reduce-organization-inventory-item', apiData, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log 'Successfully reduced item quantity'

    # OLD CALL
    # for item in invoice.data
    #   if 'inventorySerial' of item
    #     doc = (app.db.find 'organization-inventory', ({serial})=> serial is item.inventorySerial)[0]
    #     console.log doc
    #     doc.data.qty -= item.qty
    #     app.db.update 'organization-inventory', doc._id, doc

  _assignInvoiceRef: (referenceNumber, cbfn)->
    return cbfn referenceNumber if referenceNumber

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

  _callInvoiceAddUpdateApi: (invoiceData, cbfn)->
    data =
      apiKey: this.user.apiKey
      invoice: invoiceData
  
    @callApi '/bdemr--clinic-add-update-invoice', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn response.data.data
  
  _callDeductFromPatientWalletBalanceApi: (patientId, amountInBdt, invoiceSerial, organizationId, notes)->
    data = { apiKey: this.user.apiKey, amountInBdt, invoiceSerial, organizationId, notes, patientId }
    console.log {data}
    @callApi '/bdemr--deduct-from-patient-wallet-balance', data, (err, response)=>
      return


   _saveInvoice: (markAsCompleted, cbfn)->

    if !@invoice.freePatient
      unless (@invoice.totalBilled > 0) or ( @invoice.totalAmountReceieved > 0)
        return @domHost.showToast 'Invoice should have bill or paid amount atleast!'
    
    @invoice.availableBalance = @availableBalance
    @invoice.cashBackPaid = parseFloat @invoice.cashBackPaid
    @invoice.previouseDue = @previouseDue

    if @invoice.discountItemWise is null
      total = 0
      for item in @invoice.data
        if item.discountAmount
          total += item.discountAmount
      @set 'invoice.discountItemWise', total

    unless @invoice.serial
      @invoice.serial = @generateSerialForInvoice @organization.idOnServer

    unless @invoice.createdDatetimeStamp
      @invoice.createdDatetimeStamp = lib.datetime.now()

    @domHost.toggleModalLoader('Please Wait Saving')
    @isLoading = true
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
    

    # if @invoice.commission
    #   @_callThirdPartyAddCommissionApi @invoice.commission._id, @invoice.commission.amount
      


    # Saving Custom Invoice Category List
    app.db.upsert 'invoice-category-list', @invoiceCategoryList, ({serial})=> serial is @invoiceCategoryList.serial

    # Saving Custom Reference by List
    app.db.upsert 'invoice-reference-by-list', @referenceByList, ({serial})=> serial is @referenceByList.serial
  

    @_callInvoiceAddUpdateApi @invoice, (updatedInvoice)=>
    
      if @invoice.discountFromFund?.serial and markAsCompleted
        @_deductDiscountAmountFromFund @invoice.discountFromFund.serial, @invoice.discountFromFund.amount, ()=> null
      
      # if @invoice.deductFromWallet > 0
      #   @_callDeductFromPatientWalletBalanceApi(@patient.idOnServer, @invoice.deductFromWallet, @invoice.serial, @organization.idOnServer, "Charged from Invoice: #{@invoice.serial}")

      if @testAdvisedObject.serial
        @testAdvisedObject.data.testAdvisedList = @_extractInvestigationFromInvoiceData()

        if @testAdvisedObject.data.testAdvisedList.length > 0
          @saveAdvisedTest =>
            invoiceDataAfterSync = {invoiceSerial: @invoice.serial, invoiceData: @invoice.data}
            lib.localStorage.setItem 'INVOICE_DATA_AFTER_SYNC', JSON.stringify invoiceDataAfterSync
            
            @_syncOnlyTestAdvised (errMessage)=>
              if errMessage
                return @domHost.showModalDialog errMessage
              else
                invoiceDataAfterSync = JSON.parse lib.localStorage.getItem 'INVOICE_DATA_AFTER_SYNC'
                @_updateAdvisedTestForInvoice invoiceDataAfterSync.invoiceSerial, invoiceDataAfterSync.invoiceData, ()=>
                  # @_makeNewInvoice()
                  @domHost.showToast 'Invoice Saved Successfully'
                  cbfn updatedInvoice
                  return


      @domHost.showToast 'Invoice Saved Successfully'
      # @_makeNewInvoice()
      @isLoading = false

      @domHost.toggleModalLoader()
      cbfn updatedInvoice
      return
      

  # =====================================================================

  # commissionTypeChanged: (e)->
  #   @invoice.commission.category = @commissionCategoryList[@commissionCategoryIndex]

  _notifyInvalidPatient: ->
    @showModal 'Invalid Patient Provided'

  _notifyInvalidOrganization: ->
    @showModal 'No Organization is Present. Please Select an Organization first.'
  
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
    console.log 'third parties', @thirdParties


  _callGetThirdPartiesApi: ()->
    data = 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    @domHost.toggleModalLoader('Loading...')
    @callApi '/bdemr--get-organization-third-party-short-list', data, (err, response)=> 
      console.log(response)
      @domHost.toggleModalLoader()
      if response.hasError
        return @domHost.showModalDialog(response.error.message);
      else
        @formatThirdPartyData response.data
        return

  ## Third Party - end
  
  


  ## load organization member list & assign due guarantor list from here

  _loadMemberList: ->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @domHost.toggleModalLoader 'Please Wait...'
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        members = response.data.matchingUserList
        
        @assignIfMemberHaveRole members

  assignIfMemberHaveRole: (members)->
    newlist = []
    organization = Object.assign {}, @organization

    # using for loops to match organization rolelist to memberUserlist
    if organization.roleList?.length
      for role in organization.roleList
        for user in role.userList
          for member in members
            if user.id is member.idOnServer
              newlist.push {
                name: member.name
                phone: member.phone
                email: member.email
                role: role.title
                idOnServer: member.idOnServer
              }
    @set 'members', newlist
    @$$("#guarantorSearch").items = @members

  dueGuarantorSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @set 'invoice.dueGuarantor.name', user.name
    @set 'invoice.dueGuarantor.phone', user.phone
    @set 'invoice.dueGuarantor.id', user.idOnServer  
    @set 'invoice.dueGuarantor.role', user.role  

  # ================ Load left panel data from mange unit price ================
  _getCategories: ()->
    @categories = [
      {
        name: 'all'
        data: null
      }
      {
        name: 'investigation'
        investigationList: [
          {
            name: ''
            referenceRange: ''
            unitList: []
            isProtected: true
          }
        ]
      }
      {
        name: 'medicine'
        data: 
          genericName: null
          medicineType: null
          manufacturer: null
      }
      {
        name: 'CT SCAN'
        data: null
      }
      {
        name: 'MRI'
        data: null
      }        
      {
        name: 'services'
        data: null
      }
      {
        name: 'supply'
        data: null
      }
      {
        name: 'ambulance'
        data: null
      }
      {
        name: 'packages'
        data: null
      }
      {
        name: 'doctor-visit'
        data: null
      }
      {
        name: 'others'
        data: null
      }
    ]
  
  categorySelected: (e) ->
    return unless e.detail.value
    category = e.detail.value
    console.log 'selected category', category
    @set 'selectedCategory', category
    @filterByInventoryItem = ''
    @set 'invoiceSourceDataList', []
    # @_loadItemsForSelectedCategory category.name

  inventoryItemSearchInputChanged: (searchQuery)->
    @debounce 'search-inventory-item', ()=>
      return unless searchQuery
      @_searchInventoryItem searchQuery
    , 300

  _searchInventoryItem: (searchQuery)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: 
        category: if @selectedCategory and @selectedCategory.name isnt 'all' then @selectedCategory.name else null
        name: searchQuery.trim()

    console.log 'query', data
    @fetchingInventoryItemSearchResult = true;
    @domHost.callApi '/bdemr-get-organization-inventory', data, (err, response)=>
      @fetchingInventoryItemSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'invoiceSourceDataList', []
        items = response.data
        # # sort items by name
        # items.sort (prev, after)->
        #   return -1 if prev.name < after.name
        #   return 1 if prev.name > after.name
        #   return 0
        autocompleteList = ({label: item.name, price:item.price, quantity:item.quantity, value: item} for item in items)
        
        # remove any item that is quantifiable and quantity is zero
        for item, index in autocompleteList
          if item.value.hasQuantity && item.quantity <= 0
            delete autocompleteList[index]
        
        @set 'invoiceSourceDataList', autocompleteList
        console.log 'source list', @invoiceSourceDataList


  _loadItemsForSelectedCategory: (categoryName)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: {category:categoryName}
    console.log 'query', data
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-inventory', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        items = response.data
        console.log 'items for cat', items
  

  
  togglePatientContactDetails: ()->
    @showPatientContactDetails = !@showPatientContactDetails 
  
  # ================ outpatient signup and save invoice ================

  initiateExistingPatient: (patientSerial, doctorAccessPin, cbfn)->
    @_importPatient patientSerial, doctorAccessPin, (patient)=>
        @_memorizePinForNewPatient patientSerial, doctorAccessPin
        cbfn patientSerial

  signupPatientAndProcessInvoice: (cbfn)->
    # signup patient if new
    if @patientExists
      @updateInvoiceObjectsWithNewPatient @patient
      console.log 'updated invoice with existing patient', @invoice
      cbfn()
    else
      @signupPatient (patientSerial)=>
        console.log 'signup complete'
        newPatient = @_loadPatient patientSerial
        @updateInvoiceObjectsWithNewPatient newPatient
        console.log 'updated invoice after signup', @invoice
        cbfn()
    
  
  _loadPatient: (patientIdentifier)->
    @set 'patient', {}
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @set 'patient', list[0]
      return @patient
    else
      @_notifyInvalidPatient()

  updateInvoiceObjectsWithNewPatient: (newPatient)->
    console.log {newPatient}
    @invoice.patientSerial = newPatient.serial
    @set 'invoice.patientName', newPatient.name
    @set 'invoice.patientPhone', newPatient.phone
    @set 'invoice.patientEmail', newPatient.email
    @set 'testAdvisedObject.patientSerial', newPatient.serial


  saveAndCompleteInvoiceButtonClicked: ()->
    @signupPatientAndProcessInvoice =>
      @_saveInvoice markAsCompleted = true, (updatedInvoice)=>
        @refreshEverything()

  saveInvoiceButtonClicked: ()->
    @signupPatientAndProcessInvoice =>
      @_saveInvoice markAsCompleted = false, (updatedInvoice)=>
        @refreshEverything()

  savePlusPrintInvoiceButtonClicked: ()->
    @signupPatientAndProcessInvoice =>
      @_saveInvoice markAsCompleted = false, (updatedInvoice)=>
        console.log 'printing next...'
        # store the print type
        if @printTypeValue?
          localStorage.setItem 'invoicePrintType', JSON.stringify @printTypeArray[@printTypeValue]
        else
          # remove previous set value, if any
          localStorage.removeItem 'invoicePrintType'
        
        console.log @patient

        @domHost.navigateToPage '#/print-invoice/invoice:' + updatedInvoice.referenceNumber + '/patient:' + @patient.serial
        @refreshEverything()


  _makePatientSignupObject: ()->
    console.log 'hello from _makePatientSignupObject'

    patient =
      name: null
      phone: null
      repeatPhone: null
      email: null
      repeatEmail: null
      dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      gender: 'male'
      profileImage: null
      nationalIdCardNumber: null
      organizationId: null
      password: '123456'
      doctorAccessPin: '0000'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer

      additionalPhoneNumber: null
      effectiveRegion: null
      bloodGroup: null
      allergy: null
      drugAllergy:
        value: null
        list: []
        
      emmergencyContact: 
        name: null
        relation: null
        phoneNumber: null

      addressList: [
        {
          addressTitle: 'Personal'
          addressType: 'personal'
          flat: null
          floor: null
          plot: null
          block: null
          road: null
          village: null
          addressUnion: null
          subdistrictName: null
          addressDistrict: null
          addressPostalOrZipCode: null
          addressCityOrTown: null
          addressLine1: null
          addressLine2: null
          stateOrProvince: null
          addressCountry: null
        }
      ]

      employmentDetailsList: []
      belongOrganizationList: []

      expenditure: null
      profession: null
      education: null

      patientSpouseName: null
      patientFatherName: null
      patientMotherName: null
      maritalAge: null
      maritalStatus: null
      numberOfFamilyMember: 0
      numberOfChildren: 0
      recordSpecificPatientIdList: []

      patientType: 'Regular'
    @patient = patient
  
  signupPatient: (cbfn)->
    console.log 'creating patient', @patient
    unless @patient.name and @patient.dateOfBirth and @patient.gender and @patient.phone
      @domHost.showModalDialog 'Please Fill Up Required Information for Patient.'
      return
    
    @patient.name = @$makeNameObject @patient.name
    @patient.organizationId = @organization.idOnServer
    @patient.organizationSerial = @organization.serial or @organization.name.slice(0, 4)
    
    @_callBdemrAppPatientPartialSignupApi @patient, (patientSerial, doctorAccessPin)=>
      @_importPatient patientSerial, doctorAccessPin, (patient)=>
        @_memorizePinForNewPatient patientSerial, doctorAccessPin

        @createdPatientVisitedLog patient
        # @goPatientViewPage patient
        # @domHost.showToast 'Patient Created Successfully!'

        # load patient object
        cbfn patientSerial
  

  _callBdemrAppPatientPartialSignupApi: (data, cbfn) ->
    data.apiKey = @user.apiKey
    @domHost.toggleModalLoader 'Patient Signup in progress, please wait...'  
    @callApi '/onsite-bdemr-app-patient-signup-partial', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        patientId = response.data.patientId
        doctorAccessPin = response.data.doctorAccessPin
        patientSerial = response.data.patientSerial
        cbfn patientSerial, doctorAccessPin

  
  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patientList = response.data

        if patientList.length isnt 1
          return @domHost.showModalDialog 'Unknown error occurred.'
        patient = patientList[0]

        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isImported = true
        @removePatientIfAlreadyExist patient.serial
        _id = app.db.insert 'patient-list', patient
        @patientExists = true
        cbfn patient

  removePatientIfAlreadyExist: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      patient = list[0]
      app.db.remove 'patient-list', patient._id
      return
    else
      return
  
  _memorizePinForNewPatient: (patientSerial, doctorAccessPin)->
    patientPinObject = {}
    patientPinObject.organizationId = @organization.idOnServer
    patientPinObject.patientSerial = patientSerial
    patientPinObject.pin = doctorAccessPin
    console.log 'patientPinObject', patientPinObject
    app.db.upsert 'local-patient-pin-code-list', patientPinObject, ({patientSerial})=> patientPinObject.patientSerial is patientSerial


  createdPatientVisitedLog: (patient)->
    now = lib.datetime.now()
    
    visitedPatientLogObject = {
      createdByUserId: @user.idOnServer
      organizationId: @organization.idOnServer
      serial: @generateSerialForVisitedPatientLog()
      patientSerial: patient.serial
      patientName: patient.name
      createdDatetimeStamp: now
      visitedDateTimeStamp: now
      lastModifiedDatetimeStamp: now
    }

    data = {
      apiKey: @user.apiKey
      log: visitedPatientLogObject
    }
    @loading = true
    @callApi '/bdemr--create-visited-patient-log', data, (err, response)=>
      @loading = false
      return @domHost.showWarningToast err.message if err
      return @domHost.showWarningToast response.error.message if response.hasError
  
  goPatientViewPage: (patient)->
    params = @domHost.getPageParams()
    if params['chamber']
      window.localStorage.setItem('newPatientSerialFromChamber', patient.serial)
      @arrowBackButtonPressed()
    else
      @domHost.setCurrentPatientsDetails patient
      @createdPatientVisitedLog patient
      @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:5'
      @domHost.selectedPatientPageIndex = 5


  generateNumberBtnClicked: (e)->
    data = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    }
    
    @loading = true
    @callApi '/generate-number-for-patient-signup-phone-field', data, (err, response)=>
      @loading = false
      if err 
        return @domHost.showWarningToast err.message if err
      else 
        @set 'customPhnNmbrObj', response.data
        @set 'patient.phone', @customPhnNmbrObj.patientId
        @set 'HideGnrtNmbrBtn', false
        

  # CMH third party work here
  _makeNewCommissionObject: ()->
    commissionObject = {
      name: ''
      serial: null
      phone: null
      email: ''
      address: ''
      billed: null
      amount: null
    }
    @set 'commissionObject', commissionObject


  thirdPartySelected: (e)->
    @_makeNewCommissionObject()
    @commissionPercentage = null
    unless e.detail.value
      return
    item = e.detail.value
    @set 'commissionObject', item.value

  addtoInvoiceCommission: (e)->
    if @commissionObject.serial
      @invoice.commission.push @commissionObject
      @domHost.showSuccessToast 'Commission Added'
    else
      return

  # CMH third party work done


  # Generate Random Patient Phone Number using Organization serial dates and patient counter start

  _generateRandomNumberUsingOrgSerialDateString: ()->

    data = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    }
    
    @loading = true
    @callApi '/generate-random-number-for-patient-signup-with-org-serial-datestring', data, (err, response)=>
      @loading = false
      if err 
        return @domHost.showWarningToast err.message if err
      else

        number = response.data
        if number < 11
          return @domHost.showModalDialog "10 digit number generated please generate again"
        @set 'patient.phone', number.patientId

  # Generate Random Patient Phone Number using Organization serial dates and patient counter end

  refreshEverything: ()->
    window.location.reload()
    # refreshpageFlag = JSON.parse localStorage.getItem 'refreshPage'

    # @set "HideGnrtNmbrBtn", true
    # @set "availableBalance", 0
    # @set "previouseDue", 0
    # @set 'hasTestAdvisedAdded', false
    # @set 'showCategoryAndItemSearch', true

    # @_makeNewInvoice()
    # @_makePatientSignupObject()
    # @_makeNewCommissionObject()
    # @_makeNewTestAdvisedObject()


  showPrintPreviewButtonPressed: ()->
    console.log 'print preview pressed'
    
    # remove first if exists
    localStorage.removeItem 'previewInvoiceObject'
    localStorage.removeItem 'previewPatientObject'
    localStorage.removeItem 'refreshPage'

    localStorage.setItem 'previewInvoiceObject', JSON.stringify @invoice
    localStorage.setItem 'previewPatientObject', JSON.stringify @patient
    localStorage.setItem 'refreshPage', JSON.stringify {value: false}

    # store the print type
    if @printTypeValue?
      localStorage.setItem 'invoicePrintType', JSON.stringify @printTypeArray[@printTypeValue]
    
    @domHost.navigateToPage '#/print-preview-individual-invoice'


}