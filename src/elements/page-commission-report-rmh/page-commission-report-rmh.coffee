Polymer {

  is: 'page-commission-report-rmh'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    organization:
      type: Object
      value: null

    productDetails:
      type: Object
      value: -> {}

    investigationList:
      type: Array
      value: -> []

    invoiceList:
      type: Array
      notify: true
      value: []

    matchingInvoiceList:
      type: Array
      notify: true
      value: []

    patientList:
      type: Array
      notify: true
      value: []

    percentageCalcArray:
      type: Array
      notify: true
      value: []   

    totalIncome:
      type: Number
      value: -> 0

    totalProfit:
      type: Number
      value: -> 0

    categoryList:
      type: Array
      value: -> [
        'All'
        'Investigation'
        'Doctor Fees'
        'Services'
        'Pharmacy'
        'Supplies'
        'Ambulance'
        'Package'
        'Other'
      ]

    loadingCounter:
      type: Number
      value: -> 0

    currentDateTime:
      type: Number
      value: lib.datetime.now()

    paymentLog:
      type: Object,
      notify: true,
      value: ()-> {}

    settings:
      type: Object,
      notify: true,
      value: null

    filteredInvestigationList:
      type: Array
      value: -> []

    patientSerialList:
      type: Array
      value: -> []

    itemNameSearchString:
      type: String
      value: ''
      observer: '_filterInvestigationListByName'

    percentageNumberString:
      type: String
      value: ''

    newtotalCommission:
      type: Number
      value: -> 0

    totalInvoiceDiscount:
      type: Number
      value: -> 0

    percentageForItem:
      type: Number
      value: -> 0

  observers: [
    '_calculateNetProfit(filteredInvestigationList)'
    '_calculateTotalIncome(filteredInvestigationList)'
  ]


  _isEmptyArray: (array)->
    return array? and array.length > 0

  navigatedIn: ->
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>
      @_makeNewPaymentLog()
      @_loadThirdPartyList ()=> null     
      @_loadInvoice organizationIdentifier
      @__calculateTotalItemPriceWithPercentage()
    @_loadSettings()


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  _loadOrganization: (cbfn)->
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    # Check if User belongs to this Organization
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }

    @loadingCounter += 1
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn @organization.idOnServer


  _loadSettings: ()->
    list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    @settings = {}
    if list.length
      @settings = list[0]
      if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
        if @organization and @organization.printSettings
          @settings.printDecoration =  @organization.printSettings


  _loadThirdPartyList: (cbfn)->
    @loadingCounter++
    @thirdPartyListLoading = true
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    }
    @callApi '/bdemr--get-organization-third-party-list', data, (err, response)=>
      @loadingCounter--
      @thirdPartyListLoading = false
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @set 'thirdPartyList', response.data
        cbfn()

  _loadPatientsAccordingToThirdParty: (invoiceList)->
    @patientListLoading = true

    # filtering invoices that has commission id
    if @selectedUserId
      filteredInvoiceList = invoiceList.filter (item) => item.commission.idOnServer is @selectedUserId
    else
      filteredInvoiceList = invoiceList.filter (item) => item.commission.idOnServer

    console.log filteredInvoiceList

    # now mapping a new array consisting all the patients of the particular third party
    patientListMap = filteredInvoiceList.map (item) => { 
      name: @$getFullName(item.patientName),
      phone: item.patientPhone, 
      serial: item.patientSerial 
    }

    # a simple function for removing duplicate patients from that new mapped patient list
    # we just need patients serial for search, name and phone for the dropdown
    seen = new Set()
    patientList = patientListMap.filter (item) => 
      duplicate = seen.has(item.serial)
      seen.add(item.serial)
      return !duplicate;
    console.log patientList
    @set 'patientList', patientList
    @patientListLoading = false

  thirdPartySelected: (e)->
    return unless e.detail.value
    @set 'patientList', []
    item = e.detail.value
    console.log item
    @selectedUserName = item.data.user.name
    @selectedUserPhone = item.data.user.phone
    @selectedUserId = item.data.user.idOnServer
    @_loadPatientsAccordingToThirdParty(@matchingInvoiceList)


  showPatientListBtnPrsd: (e)->
    @$$('#patientListDialog').toggle()


  _selectAllPatients: (e)->
    checked = e.target.checked
    for item, index in @patientList
      @set "patientList.#{index}.isSelected", checked
    console.log @patientList


  addPatientsFromList: (e)->
    patientSerialList = []
    for item in @patientList
      if item.isSelected
        patientSerialList.push item.serial
    console.log patientSerialList
    @set 'patientSerialList', patientSerialList
    @$$('#patientListDialog').toggle()

  patientSelected: (e)->
    return unless e.detail.value
    item = e.detail.value
    console.log item
    @selectedPatientSerial = item.serial
    @selectedPatientName = item.name
    @selectedPatientPhone = item.phone

  resetButtonClicked: ->
    @newtotalCommission = 0
    @percentageNumberString = ''
    @_makeNewPaymentLog()
    @domHost.reloadPage()

  searchButtonPressed: ()->
    unless @selectedUserId
      return @domHost.showModalDialog 'Select a third party!'
    @newtotalCommission = 0
    @percentageNumberString = ''
    @productDetails = {}
    @totalCommissionWithPercentage = 0
    @totalIncome = 0
    @investigationList = []
    @_loadInvoice @organization.idOnServer

  _loadInvoice: (organizationIdentifier)->
    data = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
      searchParameters: {
        thirdPartyIdOnServer: @selectedUserId or ''
        patientSerialList: @patientSerialList or []
        dateCreatedFrom: @startDate or ''
        dateCreatedTo: @endDate or ''
      }
    }
    console.log {data}
    @loadingCounter += 1
    @callApi 'bdemr--clinic-commission-report-for-rmh', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        invoiceItems = response.data
        @set 'invoiceList', invoiceItems
        @set 'matchingInvoiceList', invoiceItems
        console.log @matchingInvoiceList
        @_loadPatientsAccordingToThirdParty(invoiceItems)
        @_generateInvestigationReport()
        # if @startDate
        #   @endDate.setHours 24 + @endDate.getHours()
        #   filteredList = (item for item in @invoiceList when ( @startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= @endDate.getTime() ))
        #   @set 'matchingInvoiceList', filteredList          
  
  _generateInvestigationReport: (selectedCategory)->
    investigationMap = {}
    total = 0

    for invoice in @matchingInvoiceList
      if invoice.discount and invoice.discount > 0
        total = parseFloat invoice.discount + total 
      for item in invoice.data
        if item.tag and item.tag isnt '' or null
          if item.tag of investigationMap
            investigationMap[item.tag].count += parseInt item.qty
            investigationMap[item.tag].totalPrice += parseFloat item.price
          else
            investigationMap[item.tag] = item
            investigationMap[item.tag].count = parseInt item.qty
    @totalInvoiceDiscount = total

    # if @selectedUserId and @startDate
    #   for invoice in @matchingInvoiceList
    #     dataLength = invoice.data.length
    #     if invoice.commission != null and invoice.commission.idOnServer == @selectedUserId
    #       if invoice.discount and invoice.discount > 0
    #         total = parseFloat invoice.discount + total
    #       for item in invoice.data
    #         if item.tag and item.tag isnt '' or null
    #           if item.tag of investigationMap
    #             investigationMap[item.tag].count += parseInt item.qty
    #             investigationMap[item.tag].totalPrice += parseFloat item.price
    #           else
    #             investigationMap[item.tag] = item
    #             investigationMap[item.tag].count = parseInt item.qty
    #   @totalInvoiceDiscount = total

    # else if @selectedUserId
    #   for invoice in @matchingInvoiceList
    #     dataLength = invoice.data.length
    #     if invoice.commission != null and invoice.commission.idOnServer == @selectedUserId
    #       if invoice.discount and invoice.discount > 0
    #         total = parseFloat invoice.discount + total
    #       for item in invoice.data
    #         if item.tag and item.tag isnt '' or null
    #           if item.tag of investigationMap
    #             investigationMap[item.tag].count += parseInt item.qty
    #             investigationMap[item.tag].totalPrice += parseFloat item.price
    #           else
    #             investigationMap[item.tag] = item
    #             investigationMap[item.tag].count = parseInt item.qty
                
    #   @totalInvoiceDiscount = total

    # else
    #   for invoice in @matchingInvoiceList
    #     if invoice.discount and invoice.discount > 0
    #       total = parseFloat invoice.discount + total 
    #     for item in invoice.data
    #       if item.tag and item.tag isnt '' or null
    #         if item.tag of investigationMap
    #           investigationMap[item.tag].count += parseInt item.qty
    #           investigationMap[item.tag].totalPrice += parseFloat item.price
    #         else
    #           investigationMap[item.tag] = item
    #           investigationMap[item.tag].count = parseInt item.qty
    #   @totalInvoiceDiscount = total      


    console.log 'Total Discount', @totalInvoiceDiscount 
    investigationList = (value for own key, value of investigationMap)
    @set 'investigationList', investigationList
    @set 'filteredInvestigationList', investigationList
    console.log 'investigation list', investigationList
    if !investigationList.length
      @domHost.showModalDialog "No possible data found for calculation"

  getBoolean: (data)-> if data then true else false

  calculateProfit: (item)->
    return 0 unless item
    totalCost = item.count * (item.actualCost ?= 0)
    totalReceived = item.count * item.price
    return totalReceived - totalCost

  calculateIncome: (item)-> 
    return 0 unless item
    return item.count * item.price

  calculateItemTotalCost: (item) -> 
    return 0 unless item
    return item.count * (item.actualCost ?= 0)

  _calculateNetProfit: ->
    totalProfit = 0
    for item in @filteredInvestigationList
      totalProfit += @calculateProfit item
    @set 'totalProfit', totalProfit

  _calculateTotalIncome: ->
    totalIncome = 0
    for item in @filteredInvestigationList
      totalIncome += item.totalPrice

    if totalIncome > 0
      @set 'totalIncome', totalIncome
    else
      return 0

  _filterInvestigationListByName: ()->
    lib.util.delay 200, ()=>
      console.log 'search string', @itemNameSearchString
      if @itemNameSearchString?
        tempStr = @itemNameSearchString.trim()
        if tempStr is ''
          @set 'filteredInvestigationList', @investigationList
        else
          regex = new RegExp "\\b#{tempStr}", 'gi'
          tempList = @investigationList.filter (item)->
            return true if regex.test item.name
          @set 'filteredInvestigationList', tempList

        console.log 'filtered investigation list ', @filteredInvestigationList  
      else
        return
      

  categorySelected: (e)->
    selectedIndex = e.detail.selected
    switch selectedIndex
      when 0 then @_generateInvestigationReport()
      when 1 then @_generateInvestigationReport 'investigation'
      when 2 then @_generateInvestigationReport 'doctor-fees'
      when 3 then @_generateInvestigationReport 'services'
      when 4 then @_generateInvestigationReport 'pharmacy'
      when 5 then @_generateInvestigationReport 'supplies'
      when 6 then @_generateInvestigationReport 'ambulance'
      when 7 then @_generateInvestigationReport 'package'
      when 8 then @_generateInvestigationReport 'other'

  invoiceCustomSearchClicked: (e)->
    @totalIncome = 0
    @startDate = null
    @endDate = null
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23, 59, 59, 999)
    @set 'startDate', startDate.getTime()
    @set 'endDate', endDate.getTime()
    # endDate.setHours 24 + endDate.getHours()
    # filteredList = (item for item in @invoiceList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    # @set 'matchingInvoiceList', filteredList
    # @_generateInvestigationReport()
    
  invoiceSearchClearButtonClicked: (e)->
    @startDate = null
    @endDate = null
    # @set 'matchingInvoiceList', @invoiceList
    # @_generateInvestigationReport()
    

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    unless @selectedUserId and @totalCommissionWithPercentageMinusDiscount
      return @domHost.showModalDialog "Choose a Third party and Finish giving commission percentage"
    @currentDateTime = lib.datetime.now()
    @_finalizePaymentLog()
    console.log @paymentLog
    if @paymentLog.serial isnt null
      @_callThirdPartyAddCommissionPaymentLogApi()
      @_saveAsExpenseInvoice()
      @_payAllInvoicesSelected ()=>
        localStorage.setItem 'paymentDetails', JSON.stringify(@paymentLog)
        window.location = '#/print-commission-payment-details'

  # _calculateCommissionWithPercentage: (e)->
  #   if e.keyCode == 13
  #     console.log @percentageNumberString
  #     commissionPercentage = parseInt(@percentageNumberString)
  #     totalCommissionWithPercentage = parseFloat(@totalIncome) * commissionPercentage / 100
  #     @set 'newtotalCommission', totalCommissionWithPercentage
  #     return

  #   else return

  preparePercentageOfAnItem: (e)->
    return unless e.model.item
    item = e.model.item
    if @percentageCalcArray.length
      for tag in @percentageCalcArray
        if tag.tag == item.tag
          @domHost.showModalDialog "Already Given"
          @$$('#dialogAddPercentage').toggle(); 
    productDetails = {
      tag: item.tag
      price: item.totalPrice
      percentagePrice: null
    }
    @set 'productDetails', productDetails
    @$$('#dialogAddPercentage').toggle();    

  _addPercentage: (e)->
    return unless @percentageForItem
    if e.keyCode == 13
      @percentageForItem = parseInt @percentageForItem
      if @percentageForItem > 50
        @percentageForItem = null
        return @domHost.showModalDialog 'Cannot be more than 50%'
      else
        afterPrcntgPrice = @productDetails.price * @percentageForItem / 100
        @set 'productDetails.percentagePrice', afterPrcntgPrice
        @set 'productDetails.percentage', @percentageForItem
        if afterPrcntgPrice > 0
          @percentageCalcArray.push @productDetails

        console.log @percentageCalcArray

        @percentageForItem = null
        @__calculateTotalItemPriceWithPercentage()
        @$$('#dialogAddPercentage').close();

    else return

  __calculateTotalItemPriceWithPercentage: (e)->
    return unless @percentageCalcArray.length
    total = 0
    for item in @percentageCalcArray
      total += item.percentagePrice

    @totalCommissionWithPercentage = total
    @totalCommissionWithPercentageMinusDiscount = total - @totalInvoiceDiscount
    

  _makeNewPaymentLog: ()->
    log = {
      serial: null
      createdDatetimeStamp: null,
      createdBy: @user.name,
      createdByUserSerial: @user.serial,
      organizationId: @organization.idOnServer
      thirdPartyName: '',
      thirdPartyPhone: null,
      thirdPartyId: null,
      patientName: ''
      patientPhone: null
      totalCommission: null,
      totalDiscount: null,
      finalAmount: null
      data: []
      matchingInvoiceList: []
      percentageCalcArray: []
    }
    @set 'paymentLog', log
    console.log @paymentLog

  _finalizePaymentLog: ()->
    if @paymentLog.createdByUserSerial and @selectedUserName
      @paymentLog.serial = @generateSerialForRmhCmsnPaymentLog()
      @paymentLog.thirdPartyName = @selectedUserName
      @paymentLog.thirdPartyPhone = @selectedUserPhone
      @paymentLog.thirdPartyId = @selectedUserId
      @paymentLog.patientName = @selectedPatientName
      @paymentLog.patientPhone = @selectedPatientPhone
      @paymentLog.data = @filteredInvestigationList
      @paymentLog.totalCommission = @totalCommissionWithPercentage
      @paymentLog.totalDiscount = @totalInvoiceDiscount
      @paymentLog.finalAmount = @totalCommissionWithPercentageMinusDiscount
      @paymentLog.createdDatetimeStamp = lib.datetime.now()
      @paymentLog.matchingInvoiceList = @matchingInvoiceList
      @paymentLog.percentageCalcArray = @percentageCalcArray
    else
      return

  _callThirdPartyAddCommissionPaymentLogApi: ()->
    data =
      apiKey: @user.apiKey
      payment: @paymentLog

    @callApi '/bdemr--clinic-rmh-add-or-update-commission-payment-log', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        return console.log "payment added"

  _saveAsExpenseInvoice: ()-> 
    expense = {
      serial: @generateSerialForExpense(),
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: @user.serial,
      organizationId: @organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: lib.datetime.now(),
      invoiceType: 'general',
      category: 'commission',
      totalBilled: parseFloat(@totalCommissionWithPercentageMinusDiscount),
      discount: 0,
      vatOrTax: 0,
      totalAmountPaid: parseFloat(@totalCommissionWithPercentageMinusDiscount),
      flags: {
        flagAsError: false,
        markAsCompleted: false
      },
      data: [{
        name: 'Commission to ' + @selectedUserName,
        category: 'commission',
        qty: 1,
        unitPrice: parseFloat(@totalCommissionWithPercentageMinusDiscount)
      }],
      customerDetails: {
        name: @selectedUserName || '',
        phone: @selectedUserPhone || '',
        address: ''
      }
    }

    payload = 
      apiKey: @user.apiKey,
      expense: expense

    @callApi '/bdemr--clinic-add-expense-from-expense-manager', payload, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        return console.log "expense added"


  _payAllInvoicesSelected: (cbfn)->
    serialListOfInvoices = []


    for item in this.matchingInvoiceList
      if !item.commission.isPaid
        serialListOfInvoices.push(item.serial)

    # for (let i = 0; i < this.matchingCommissionList.length; i++) {
    #   if (!this.matchingCommissionList[i].commission?.isPaid?) {
    #     serialListOfInvoices.push(this.matchingCommissionList[i].serial)
    #   }
    # }
    console.log serialListOfInvoices
    if !serialListOfInvoices.length
      @domHost.showModalDialog "No Invoices found to be paid"
    else
      data = {
        apiKey: this.user.apiKey,
        serialList: serialListOfInvoices,
        paymentDate: lib.datetime.now()
      }
      console.log data
      @callApi '/bdemr--clinic-update-commission-paid-status-for-rmh', data, (err, response)=> 
        console.log 'error', err
        console.log 'response', response
        if err
          return @domHost.showModalDialog err.message
        if response.hasError
          return @domHost.showModalDialog response.error.message
        else 
          # this.searchButtonPressed()
          # return @domHost.showModalDialog 'Updated Successfully'
          cbfn()

}
