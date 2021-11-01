
Polymer {
  
  is: 'page-invoice-report'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    user:
      type: Object
      value: {}
    
    organization:
      type: Object
      value: {}

    invoiceList:
      type: Array
      notify: true
      value: []
    
    filteredInvoiceList:
      type: Array
      value: -> []

    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    totalInvoiceBilled:
      type: Number
      computed: '_calculateTotalInvoiceBilled(filteredInvoiceList)'
    
    totalCashback:
      type: Number
      computed: '_calculateTotalCashBack(filteredInvoiceList)'

    totalAvailableBalance:
      type: Number
      computed: '_calculateTotalAvailableBalance(totalInvoiceIncome, totalInvoiceBilled, totalCashback)'
    
    totalAdvanceBalance:
      type: Number
      computed: '_calculateTotalAdvanceBalance(filteredInvoiceList)'
    
    totalAvailableDue:
      type: Number
      computed: '_calculateTotalDueBalance(totalInvoiceIncome, totalInvoiceBilled)'

    totalDiscount:
      type: Number
      computed: '_calculateTotalDiscount(filteredInvoiceList)'

    totalInvoiceIncome:
      type: Number
      computed: '_calculateTotalInvoiceIncome(filteredInvoiceList)'
    
    totalProfit:
      type: Number
      value: 0

    totalDue:
      type: Number
      computed: '_calculateTotalDue(totalInvoiceBilled, totalAmountReceieved)'

    categoryList:
      type: Array
      value: -> [
        'All'
        'Investigation'
        'Doctor Fees'
        'Services'
        'Supplies'
        'Ambulance'
        'Package'
        'Other'
      ]

    showDuesOnly:
      type: Boolean
      value: -> false

    showFreeOnly:
      type: Boolean
      value: -> false
    
    loadingCounter:
      type: Number
      value: -> 0

    currentDateTime:
      type: Number
      value: lib.datetime.now()

    settings:
      type: Object,
      notify: true,
      value: null
    
    patientStatusArray:
      type: Array
      value: -> [{label:'Indoor Patient', value:'indoor'}, {label:'Outdoor Patient', value:'outdoor'}, {label:'Emergency Patient', value:'emergency'}]

    patientStatus:
      type: String
      value: null

    patientNameSearchString:
      type: String
      value: ''

    patientPhoneSearchString:
      type: String
      value: ''

    saveInvoiceReportToLocalStorage: 
      type: Object,
      value: {}

  observers: [
    'filteringParametersChanged(patientNameSearchString, patientPhoneSearchString, searchString)',
  ]

  _calculateAdvance: (bill=0, paid=0, previouseDue=0, cashback=0)->
    amount = paid - bill - cashback - previouseDue
    return 0 if Math.sign(amount) is -1
    return amount
  
  _calculateTotalAdvanceBalance:(invoiceList)->
    return invoiceList.reduce (total, invoice)->
      amount = parseFloat(invoice.paid) - parseFloat(invoice.totalBilled) - parseFloat(invoice.cashBackPaid) - parseFloat(invoice.previouseDue)
      amount = if Math.sign(amount) is -1 then 0 else amount
      return amount + total
    ,0

  _calculateAvailableBalance: (bill=0, paid=0, availableBalance=0, cashBackPaid=0, previouseDue=0)->
    
    bill = if Number.isNaN(bill) then 0 else parseFloat bill
    paid = if Number.isNaN(paid) then 0 else parseFloat paid
    availableBalance = if Number.isNaN(paid) then 0 else parseFloat availableBalance
    cashBackPaid = if Number.isNaN(cashBackPaid) then 0 else parseFloat cashBackPaid
    previouseDue = if Number.isNaN(previouseDue) then 0 else parseFloat previouseDue

    bill = bill + previouseDue

    totalAvailableBalance = (paid + availableBalance) - cashBackPaid

    return totalAvailableBalance - bill if (totalAvailableBalance > bill)
    
    return 0


  filteringParametersChanged: (patientNameSearchString, patientPhoneSearchString, searchString)->
    lib.util.delay 300, ()=>
      tempPatientName = if patientNameSearchString then patientNameSearchString.trim().toLowerCase() else ''
      tempPatientPhone = if patientPhoneSearchString then patientPhoneSearchString.trim() else ''
      tempCategoryName = if searchString then searchString.trim() else ''
      tempList = @invoiceList.filter (item)=>
        
        nameFlag = phoneFlag = categoryFlag = false
        
        if (item.patientName) and ((tempPatientName is '') or (tempPatientName isnt '' and @$getFullName(item.patientName).toLowerCase().includes tempPatientName))
          nameFlag = true

        if (item.patientPhone) and ((tempPatientPhone is '') or (tempPatientPhone isnt '' and item.patientPhone.includes tempPatientPhone)) 
          phoneFlag = true

        if (item.category isnt 'undefined') and ((tempCategoryName is '') or (tempCategoryName isnt '' and item.category.includes tempCategoryName)) 
          categoryFlag = true
        
        return nameFlag and phoneFlag and categoryFlag
      
      @set 'filteredInvoiceList', tempList
      
      console.log 'filtered list', @filteredInvoiceList


  
  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  calculateTotalAvailableBalance: (a,b)->
    console.log a,b
    return a+b;
  
  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer
      @_loadMemberList ()=> null
      @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
        @set 'settings', settings         
      @loadingCounter--
    # @_loadSettings()

  navigatedOut: ->
    @showDuesOnly = false
    @showFreeOnly = false
    @dateCreatedFrom = ''
    @dateCreatedTo = ''
    @selectedOrganizationId = ''
    # @searchString = ''
    @selectedCategory = ''

  
  getBoolean: (data)-> if data then true else false

  _calculateTotalInvoiceIncome: (invoiceList)->
    return invoiceList.reduce (total, invoice)->
      # return parseFloat(invoice.totalAmountReceieved?=0) + total
      return parseFloat(invoice.paid?=0) + total
    ,0
  
  _calculateTotalAvailableBalance: (totalInvoiceIncome, totalInvoiceBilled, totalCashback)->
    total = totalInvoiceIncome - (totalInvoiceBilled + totalCashback)
    return 0 if Math.sign(total) is -1
    return total
  

  _calculateTotalDueBalance: (a, b)->
    total = b - a
    return 0 if Math.sign(total) is -1
    return total


  _calculateTotalInvoiceBilled: (invoiceList)->
    return invoiceList.reduce (total, invoice)->
      return parseFloat(invoice.totalBilled?=0) + total
    ,0
  
  _calculateTotalCashBack: (invoiceList)->
    return invoiceList.reduce (total, invoice)->
      return parseFloat(invoice.cashBackPaid?=0) + total
    ,0
  
  _calculateTotalDiscount: (invoiceList)->
    return invoiceList.reduce (total, invoice)->
      return parseFloat(invoice.discount?=0) + total
    ,0

  _calculateTotalProfit: (invoiceList)->
    totalProfit = 0
    for item in invoiceList
      totalProfit += @calculateProfit item
    @set 'totalProfit', totalProfit

  _calculateTotalDue: (totalInvoiceBilled, totalAmountReceieved)->
    due = totalInvoiceBilled - totalAmountReceieved
    return 0 if Math.sign(due) is -1
    return due

    # return invoiceList.reduce (total, invoice)=>
    #   return @calculateDue(invoice.totalBilled, invoice.totalAmountReceieved, invoice.previouseDue, invoice) + total
    # ,0

  calculateDue: (billed = 0, amtReceived = 0, previouseDue=0, invoice)-> 
    return if !invoice

    due = (billed - amtReceived) + previouseDue

    deductFromBalance = invoice.availableBalance - @_calculateAvailableBalance(invoice.totalBilled, invoice.paid, invoice.availableBalance, invoice.cashBackPaid, invoice.previouseDue)

    due = due - deductFromBalance

    if due > 0 then return due else return 0

  calculateProfit: (invoice)->
    return 0 unless invoice
    totalCost = 0
    for item in invoice.data
      total = (item.actualCost ?= 0) * item.qty
      totalCost += total
    return invoice.totalAmountReceieved - totalCost
  
  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  
  # _loadSettings: ()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   @settings = {}
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization and @organization.printSettings
  #         @settings.printDecoration =  @organization.printSettings

  _loadOrganization: (cbfn)->
    currentOrganization = @getCurrentOrganization()
    @loadingCounter++
    data = { 
      apiKey: @user.apiKey
      idList: [ currentOrganization.idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn()


  resetButtonClicked: -> @domHost.reloadPage()

  organizationSelected: (e)->
    organizationId = e.detail.value
    @set('selectedOrganizationId', organizationId)

  memberSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @selectedUserSerial = user.serial
  
  _loadChildOrganizationList: (organizationIdentifier)-> 
    @loadingCounter++
    query = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    }
    @callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      @loadingCounter--
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        @set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = @$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: @organization.name, value: @organization.idOnServer }]
        organizationSelectorComboBox.value = @organization.idOnServer

  filterByDateClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', (startDate.getTime())
    @set 'dateCreatedTo', (endDate.getTime())

  filterByDateClearButtonClicked: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0
    
  viewInvoiceButtonPressed: (e)->
    item = e.model.item
    @domHost.navigateToPage '#/print-invoice/invoice:' + item.referenceNumber + '/patient:' + item.patientSerial

  editInvoiceButtonPressed: (e)->
    item = e.model.item
    console.log item
    @domHost.showModalInput "Patient already exists. Please enter patient PIN to import", "0000", (answer)=>
      if answer    
        @_importPatient item.patientSerial, answer, (patient)=>
          @domHost.navigateToPage '#/create-invoice/invoice:' + item.serial + '/patient:' + item.patientSerial


  # ==============================
  # Edit invoice parts start --
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
        cbfn patient

  removePatientIfAlreadyExist: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      patient = list[0]
      app.db.remove 'patient-list', patient._id
      return
    else
      return

  # Edit invoice parts ENDS
  # ==============================

  deleteInvoiceBtnClicked: (e)->
    { item, index } = e.model
    @domHost.showModalPrompt "Are you sure you want to Delete?", (answer)=>
      if answer
        data = {
          serial: item.serial,
          apiKey: @user.apiKey          
        }
        @callApi 'bdemr--patient-invoice-delete-api', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog 'Could not delete this invoice, Something went Wrong'
          else
            @splice 'filteredInvoiceList', index, 1
            @domHost.showWarningToast 'Deleted'
            @searchButtonClicked()


  # categorySelected: (e)->
  #   selectedIndex = e.detail.selected
  #   switch selectedIndex
  #     when 0 then @selectedCategory = ''
  #     when 1 then @selectedCategory = 'investigation'
  #     when 2 then @selectedCategory = 'doctor-fees'
  #     when 3 then @selectedCategory = 'services'
  #     when 4 then @selectedCategory = 'supplies'
  #     when 5 then @selectedCategory = 'ambulance'
  #     when 6 then @selectedCategory = 'package'
  #     when 7 then @selectedCategory = 'other'

  
  resetButtonClicked: -> return @domHost.reloadPage()
  
  _loadMemberList: (cbfn)->
    @loadingCounter++
    @memberListLoading = true
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      @loadingCounter--
      @memberListLoading = false
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @set 'memberList', response.data.matchingUserList
        cbfn()
  
  searchButtonClicked: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: []
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        # searchString: @searchString
        patientStatus: @patientStatus
        category: @selectedCategory
        showDuesOnly: @showDuesOnly
        showFreeOnly: @showFreeOnly
        createdByUserSerial: @selectedUserSerial?=""
      }
    }

    # search parent+child when selecting all
    if !@selectedOrganizationId
      organizationIdList = @childOrganizationList.map (item)-> item.value
      organizationIdList.splice(0, 1, @organization.idOnServer)
      query.organizationIdList = organizationIdList
    else
      query.organizationIdList = [@selectedOrganizationId]

    @loadingCounter += 1
    @callApi '/bdemr--clinic-invoice-report', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        invoiceItems = response.data
        @set 'invoiceList', invoiceItems
        @set 'filteredInvoiceList', invoiceItems
        console.log 'invoice list', @filteredInvoiceList



  setInvoiceReportToLocalStorage: (data)->
    
    @set 'saveInvoiceReportToLocalStorage', data
    localStorage.setItem 'saveInvoiceReportToLocalStorage', JSON.stringify(@saveInvoiceReportToLocalStorage)

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'

  _printButtonPressed: ()->
    @setInvoiceReportToLocalStorage @filteredInvoiceList
    @currentDateTime = lib.datetime.now()
    @domHost.navigateToPage "#/invoice-report-print-preview"
  
  _prepareInvoiceReportJsonData: (rawReport) ->
    return rawReport.map (item) => {
      'Serial': item.referenceNumber or ''
      'Date': @$formatDate item.createdDatetimeStamp
      'Category': item.category or ''
      'Patient Name': @$getFullName item.patientName or ''
      'Patient Mobile': item.patientPhone or ''
      'Referred Doctor': item?.referralDoctor?.name or ''
      'Discount': item.discount or 0
      'Vat/Tax': item.vatOrTax or 0
      'Billed': item.totalBilled or 0
      'Received': item.totalAmountReceieved or 0
      'Due': @calculateDue item.totalBilled, item.totalAmountReceieved, item.previouseDue, item
      'Next Payment Date': @$formatDate(item.nextPaymentDate)
    }
  
  downloadCsv: (csv, exportedFilenmae)->
    blob = new Blob [csv], { type: 'text/csvcharset=utf-8' }
    link = document.createElement "a"
    url = URL.createObjectURL blob
    link.setAttribute "href", url
    link.setAttribute "download", exportedFilenmae
    link.style.visibility = 'hidden'
    link.target = '_blank'
    document.body.appendChild link
    link.click()
    document.body.removeChild link

  _exportButtonClicked: ()->
    data = null
    data = @_prepareInvoiceReportJsonData @filteredInvoiceList
    preppedData = data
    csvString = Papa.unparse(preppedData)
    @downloadCsv csvString, 'invoice-report-export.csv'



}
