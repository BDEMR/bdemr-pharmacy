
Polymer {
  is: 'page-accounts-manager'

  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.commonComputes
  ]

  properties:
    selectedPage:
      type: Number
      value: 2

    selectedExpensePage:
      type: Number
      value: 0

    user:
      type: Object
      value: {}

    organization:
      type: Object
      value: {}
    
    matchingIncomeList:
      type: Array
      value: []
    
    incomeList:
      type: Array
      value: []

    incomeItem:
      type: Object
      value: {}

    totalIncome:
      type: Number
      value: 0

    totalProfit:
      type: Number
      value: 0

    matchingExpenseList:
      type: Array
      value: []
    
    expenseList:
      type: Array
      value: []

    expenseItem:
      type: Object
      value: {}

    totalGeneralExpense:
      type: Number
      value: 0

    salarySheet:
      type: Array
      value: []

    salaryExpense:
      type: Object
      value: {}

    salaryExpenseList:
      type: Array
      value: []

    matchingSalaryExpenseList:
      type: Array
      value: []

    totalSalaryExpense:
      type: Number
      value: 0

    matchingutilityExpenseList:
      type: Array
      value: []
    
    utilityExpenseList:
      type: Array
      value: []

    utilityExpenseItem:
      type: Object
      value: {}
    
    totalUtilitiesExpense:
      type: Number
      value: 0

    combinedExpenseList:
      type: Array
      computed: '_makeCombinedExpenseList(matchingExpenseList, matchingSalaryExpenseList, matchingUtilityExpenseList)'
    
    totalExpense:
      type: Number
      notify: true
      computed: '_calculateTotalExpense(totalGeneralExpense, totalSalaryExpense, totalUtilitiesExpense)'

    grossProfit:
      type: Number
      computed: '_calculateGrossProfit(totalProfit, totalExpense)'

    isLoading:
      type: Boolean
      value: true

  observers: [
    '_calculateTotalProfit(matchingIncomeList.splices)'
    '_calculateTotalIncome(matchingIncomeList.splices)'
  ]
    
  # Utils

  _activeItemChanged: (item)->
    this.$.incomeListGrid.selectedItems = if item then [item] else []
  
  _sortByDate: (a, b)->
    return b.createdDatetimeStamp - a.createdDatetimeStamp
     
  _formatDate: (dateTime)->
    return "" unless dateTime
    lib.datetime.format (new Date dateTime), 'mmm d, yyyy HH:MM'

  _isListEmpty: (list)->
    return false unless Array.isArray(list)
    return true if list.length is 0
    return false

  _addCurrentTime: (dateValue)->
    hh = (new Date).getHours()
    mm = (new Date).getMinutes()
    return (new Date "#{dateValue} #{hh}:#{mm}").getTime()
  
  
  ready: -> 
    # HACK, because of Vaadin
    @navigatedIn()
  
  navigatedIn: ->
    params = @domHost.getPageParams()
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=> 
      @_resetIncomeForm()
      @_resetExpenseForm()
      @_resetUtilityExpenseForm()
      @_loadExpenseData()
      @_loadSalaryExpenseData()
      @_resetSalaryEntryForm()
      @salaryEntryDatetimeStamp = lib.datetime.mkDate new Date
      @_loadUtilityExpenseData()
      @_loadIncomeData organizationIdentifier, ()=>
        @_loadBalanceSheetForCurrentMonth()

  _checkUserAccess: (userIdOnServer, userList)->
    found = false
    for item in userList
      if item.id is userIdOnServer
        if item.isAdmin
          found = true
          break
    
    unless found 
      @_notifyInvalidAccess()
      return
  
  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

 _loadOrganization: (cbfn)->
    idOnServer = @getCurrentOrganization().idOnServer
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        # @_checkUserAccess @user.idOnServer, response.data.matchingOrganizationList[0].userList
        cbfn response.data.matchingOrganizationList[0].idOnServer

  
  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'

  _notifyInvalidAccess: ->
    @domHost.showModalPrompt 'You Do Not Have Access To This Page!', ()=>
      @domHost.navigateToPreviousPage()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _uniqueInvoiceArray: (arr...)->
    concatenatedArray = [].concat arr...
    map = {}
    uniqueArr = []
    for item in concatenatedArray
      unless item.serial of map
        map[item.serial] = item
    for key, value of map
      uniqueArr.push value
    return uniqueArr
  
  calculateItemProfit: (invoice)->
    return unless invoice
    totalCost = 0
    for item in invoice.data
      total = (item.actualCost ?= 0) * item.qty
      totalCost += parseInt total
    return invoice.totalAmountReceieved - totalCost
  
  _loadIncomeData: (organizationIdentifier, cbfn)->

    @_loadInvoiceFromServer organizationIdentifier, (invoiceListFromServer)=>
      
      invoiceListFromLocal = app.db.find 'patient-invoice', ({organizationId})-> organizationId is organizationIdentifier

      combinedInvoiceList = @_uniqueInvoiceArray(invoiceListFromServer, invoiceListFromLocal)

      otherIncome = app.db.find 'organization-other-income', ({organizationId})=> organizationId is @organization.idOnServer

      invoiceToIncome = []
      for item in combinedInvoiceList
        invoiceItem = {
          invoiceSerial: item.serial
          patientSerial: item.patientSerial
          createdDatetimeStamp: item.createdDatetimeStamp
          lastModifiedDatetimeStamp: item.lastModifiedDatetimeStamp
          data:
            name: item.referenceNumber or item.serial
            category: item.category or 'Invoice'
            value: 0
            profit: @calculateItemProfit item
        }
        if item.commission?.amount
          invoiceItem.data.value = ((item.totalAmountReceieved?=0) - item.commission.amount)
        else
          invoiceItem.data.value = item.totalAmountReceieved ? 0
        

        invoiceToIncome.push invoiceItem

      @incomeList = [].concat invoiceToIncome, otherIncome
      @set 'matchingIncomeList', @incomeList

      cbfn()

    
  _loadInvoiceFromServer: (organizationIdentifier, cbfn)->  
    @isLoading = true
    data =
      apiKey: @user.apiKey
      organizationId: organizationIdentifier

    @callApi 'bdemr-clinic-app-get-organization-invoice', data, (err, response)=>
      unless response.hasError
        cbfn response.data
      @isLoading = false

  
  _resetIncomeForm: ->
    incomeItem = {
      serial: @generateSerialForIncomeItem()
      createdDatetimeStamp: lib.datetime.mkDate new Date
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: ""
        category: ""
        value: 0
        profit: 0
    }
    @set 'incomeItem', incomeItem


  addToIncomeButtonClicked: ->
    #TODO: Validation
    income = @get 'incomeItem'
    
    income.data.value = income.data.profit = parseInt income.data.value
    income.lastModifiedDatetimeStamp = lib.datetime.now()
    income.createdDatetimeStamp = @_addCurrentTime income.createdDatetimeStamp
    app.db.upsert 'organization-other-income', income, ({serial})=> serial is income.serial
    
    index = @matchingIncomeList.findIndex (item)=>
      item.serial is income.serial
    
    if index > -1
      @splice 'matchingIncomeList', index, 1, income
    else
      @push 'matchingIncomeList', income
    
    @_resetIncomeForm()


  isIncomeItemInvoice: (item)->
    # console.log item
    return true if 'invoiceSerial' of item
    return false

  editIncomeItemButtonClicked: (e)->
    {item, index} = e.model
    incomeItem = {
      serial: item.serial
      createdDatetimeStamp: lib.datetime.mkDate item.createdDatetimeStamp
      lastModifiedDatetimeStamp: null
      createdByUserSerial: item.createdByUserSerial
      lastModifiedBy: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: item.data.name
        category: item.data.category
        value: item.data.value
    }
    @set 'incomeItem', incomeItem

  
  viewInvoiceButtonClicked: (e)->
    e.preventDefault()
    invoice = e.model.item
    @domHost.navigateToPage '#/print-invoice/invoice:' + invoice.referenceNumber + '/patient:' + invoice.patientSerial

  _calculateTotalIncome: ()->
    totalIncome = 0
    for item in @matchingIncomeList
      totalIncome += parseInt item.data.value ?= 0
    @set 'totalIncome', totalIncome

  _calculateTotalProfit: ()->
    totalProfit = 0
    for item in @matchingIncomeList
      totalProfit += parseInt item.data.profit ?= 0
    @set 'totalProfit', totalProfit
  

  incomeListCustomSearchClicked: (e)->
    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    filteredList = (item for item in @incomeList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    @set 'matchingIncomeList', filteredList
    
  incomeListSearchClearButtonClicked: (e)->
    @set 'matchingIncomeList', @incomeList


  # EXPENSE SECTION
  # =================================================================
  
  _loadExpenseData: ->
    @expenseList = app.db.find 'organization-other-expense', ({organizationId})=> organizationId is @organization.idOnServer
    @set 'matchingExpenseList', @expenseList
    @_calculateTotalGeneralExpense @expenseList

  _resetExpenseForm: ->
    expenseItem = {
      serial: @generateSerialForExpenseItem 'GE'
      createdDatetimeStamp: lib.datetime.mkDate new Date
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: ""
        category: ""
        qty: 0
        unitCost: 0
        totalCost: 0
    }
    @set 'expenseItem', expenseItem
  
  _addToExpenseButtonClicked: ->
    #TODO: Validation
    @expenseItem.lastModifiedDatetimeStamp = lib.datetime.now()
    @expenseItem.createdDatetimeStamp = @_addCurrentTime @expenseItem.createdDatetimeStamp
    @expenseItem.data.totalCost = @expenseItem.data.qty * @expenseItem.data.unitCost
    app.db.upsert 'organization-other-expense', @expenseItem, ({serial})=> serial is @expenseItem.serial
    @push 'expenseList', @expenseItem
    @_loadExpenseData()
    @_resetExpenseForm()

  editGeneralExpenseItemButtonClicked: (e)->
    {item, index} = e.model
    expenseItem = {
      serial: item.serial
      createdDatetimeStamp: lib.datetime.mkDate item.createdDatetimeStamp
      lastModifiedDatetimeStamp: null
      createdByUserSerial: item.createdByUserSerial
      lastModifiedBy: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: item.data.name
        category: item.data.category
        qty: item.data.qty
        unitCost: item.data.unitCost
        totalCost: 0
    }
    @set 'expenseItem', expenseItem 

  _calculateTotalGeneralExpense: (list)->
    totalGeneralExpense = 0
    for item in list
      totalGeneralExpense += parseInt item.data.totalCost?=0
    @set 'totalGeneralExpense', totalGeneralExpense
  

  expenseListCustomSearchClicked: (e)->
    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    filteredList = (item for item in @expenseList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    @set 'matchingExpenseList', filteredList
    
  expenseListSearchClearButtonClicked: (e)->
    @set 'matchingExpenseList', @expenseList


  # SALARY SECTION
  # =================================================

  _resetSalaryEntryForm: ->
    @salaryExpense = 
      serial: @generateSerialForExpenseItem 'OnlySalaryItem'
      name: ""
      position: ""
      monthlyAmount: 0
      paidAmount: 0

  _loadSalaryExpenseData: ->
    @salaryExpenseList = app.db.find 'organization-salary-expense', ({organizationId})=> organizationId is @organization.idOnServer
    @set 'matchingSalaryExpenseList', @salaryExpenseList
    @_calculateTotalSalaryExpense @salaryExpenseList
  
  _addToSalarySheetButtonClicked: ->
    salary = @salaryExpense

    index = @salarySheet.findIndex (item)=>
      item.serial is salary.serial
    
    if index > -1
      @splice 'salarySheet', index, 1, salary
    else
      @push 'salarySheet', salary

    @_resetSalaryEntryForm()
      

  _addToSalaryExpenseButtonClicked: ->
    unless @salarySheet.length
      @domHost.showModalDialog 'Salary Sheet is empty!'
      return

    salaryEntry = {
      serial: @generateSerialForExpenseItem 'SE'
      createdDatetimeStamp: @_addCurrentTime @salaryEntryDatetimeStamp
      lastModifiedDatetimeStamp: lib.datetime.now
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: "Salary for #{@$mkDate @salaryEntryDatetimeStamp}"
        category: 'Salary'
        salarySheet: @salarySheet
        totalCost: 0
    }

    for item in salaryEntry.data.salarySheet
      salaryEntry.data.totalCost += parseInt item.paidAmount?=0

    app.db.upsert 'organization-salary-expense', salaryEntry, ({serial})=> serial is salaryEntry.serial
    @salarySheet = []
    
    @_loadSalaryExpenseData()

    @salaryEntryDatetimeStamp = lib.datetime.mkDate new Date



  editSalarySheetItemButtonClicked: (e)->
    {item, index} = e.model
    salaryExpense = 
      serial: item.serial
      name: item.name
      position: item.position
      monthlyAmount: item.monthlyAmount
      paidAmount: item.paidAmount

    @set 'salaryExpense', salaryExpense

    @set 'salaryEntryDatetimeStamp', lib.datetime.mkDate new Date
  
  deleteSalarySheetItemButtonClicked: (e)->
    {item, index} = e.model
    @splice 'salarySheet', index, 1
  
  copySalaryItemButtonClicked: (e)->
    {item, index} = e.model
    @set 'salarySheet', item.data.salarySheet

  _calculateTotalSalaryExpense: (list)->
    totalSalaryExpense = 0
    for item in list
      totalSalaryExpense += parseInt item.data.totalCost
    @set 'totalSalaryExpense', totalSalaryExpense  

  # Utitliy and Bill SECTION
  # =================================================

  _loadUtilityExpenseData: ->
    @utilityExpenseList = app.db.find 'organization-utility-expense', ({organizationId})=> organizationId is @organization.idOnServer
    @set 'matchingUtilityExpenseList', @utilityExpenseList
    @_calculateTotalUtilityExpense @utilityExpenseList

  _resetUtilityExpenseForm: ->
    expenseItem = {
      serial: @generateSerialForExpenseItem 'EU'
      createdDatetimeStamp: lib.datetime.mkDate new Date
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: ""
        category: ""
        totalCost: 0
    }
    @set 'utilityExpenseItem', expenseItem
  
  _addToUtilityExpenseButtonClicked: ->
    #TODO: Validation
    @utilityExpenseItem.lastModifiedDatetimeStamp = lib.datetime.now()
    @utilityExpenseItem.createdDatetimeStamp = @_addCurrentTime @utilityExpenseItem.createdDatetimeStamp
    app.db.upsert 'organization-utility-expense', @utilityExpenseItem, ({serial})=> serial is @utilityExpenseItem.serial
    @push 'utilityExpenseList', @utilityExpenseItem
    @_loadUtilityExpenseData()
    @_resetUtilityExpenseForm()

  editUtilityExpenseItemButtonClicked: (e)->
    {item, index} = e.model
    expenseItem = {
      serial: item.serial
      createdDatetimeStamp: lib.datetime.mkDate item.createdDatetimeStamp
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      organizationId: @organization.idOnServer
      data:
        name: item.data.name
        category: item.data.category
        totalCost: item.data.totalCost
    }
    @set 'utilityExpenseItem', expenseItem 

  _calculateTotalUtilityExpense: (list)->
    totalUtilitiesExpense = 0
    for item in list
      totalUtilitiesExpense += parseInt item.data.totalCost?=0
    @set 'totalUtilitiesExpense', totalUtilitiesExpense
  

  utilityExpenseListCustomSearchClicked: (e)->
    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    filteredList = (item for item in @utilityExpenseList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    @set 'matchingUtilityExpenseList', filteredList
    @_calculateTotalUtilityExpense @matchingUtilityExpenseList
    
  utilityExpenseListSearchClearButtonClicked: (e)->
    @set 'matchingUtilityExpenseList', @utilityExpenseList
    @_calculateTotalUtilityExpense @utilityExpenseList


  # Net Profit SECTION
  # =================================================

  _loadBalanceSheetForCurrentMonth: ->
    currentDate = @$mkDate new Date
    [year, month, date] = currentDate.split("-")
    @.$.balanceSheetMonthInput.value = "#{year}-#{month}"
    {startDate, endDate} = @_makeDateFromMonth currentDate
    @_filterBalanceSheetByDate(startDate, endDate)
  
  _makeCombinedExpenseList: (expenseList, salaryExpenseList, utilityExpenseList)->
    return [].concat expenseList, salaryExpenseList, utilityExpenseList

  
  _calculateTotalExpense: (totalGeneralExpense = 0, totalSalaryExpense = 0, totalUtilitiesExpense = 0)->
    return (totalGeneralExpense + totalSalaryExpense + totalUtilitiesExpense)
  
  _calculateGrossProfit: (totalIncome = 0, totalExpense = 0)->
    return (totalIncome - totalExpense)

  ifLoss: (grossProfit)->
    return true unless grossProfit > 0
    return false

  _makeDateFromMonth: (dateValue)->
    [ year, month ] = dateValue.split("-")
    monthEndDate = 0
    switch month
      when "01" then monthEndDate = 31
      when "02"
        if month is "02"
          if year%4 then monthEndDate = 28 else monthEndDate = 29
      when "03" then monthEndDate = 31
      when "04" then monthEndDate = 30
      when "05" then monthEndDate = 31
      when "06" then monthEndDate = 30
      when "07" then monthEndDate = 31
      when "08" then monthEndDate = 31
      when "09" then monthEndDate = 30
      when "10" then monthEndDate = 31
      when "11" then monthEndDate = 30
      when "12" then monthEndDate = 31
    startDate = "#{year}-#{month}-01 00:00"
    endDate = "#{year}-#{month}-#{monthEndDate} 23:59"
    return {startDate: startDate, endDate: endDate}
  
  getBalanceSheetByMonthClicked: (e)->
    {startDate, endDate} = @_makeDateFromMonth e.target.value
    @_filterBalanceSheetByDate(startDate, endDate)

  grossProftCustomSearchClicked: (e)->
    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    @_filterBalanceSheetByDate(startDate, endDate)

  grossProftSearchClearButtonClicked: ()-> 
    @_loadBalanceSheetForCurrentMonth()

  _filterBalanceSheetByDate: (startDate, endDate)->
    startDate = new Date startDate
    endDate = new Date endDate
    
    @matchingExpenseList = filteredGeneralExpenseList = (item for item in @expenseList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    
    @matchingUtilityExpenseList = filteredUtilityExpenseList = (item for item in @utilityExpenseList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))

    @matchingSalaryExpenseList = filteredSalaryExpenseList = (item for item in @salaryExpenseList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    
    @_calculateTotalGeneralExpense filteredGeneralExpenseList
    @_calculateTotalSalaryExpense filteredSalaryExpenseList
    @_calculateTotalUtilityExpense filteredUtilityExpenseList
    
    matchingIncomeList = (item for item in @incomeList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    @set 'matchingIncomeList', matchingIncomeList
    console.log @matchingIncomeList

    # TotalIncome is autocalculated with Observers


}
