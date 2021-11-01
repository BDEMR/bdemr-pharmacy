Polymer {

  is: 'page-billing-report'

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
      notify: true
      value: (app.db.find 'organization')[0]

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]     

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

    filteredInvestigationList:
      type: Array
      value: -> []

    itemNameSearchString:
      type: String
      value: ''
      observer: '_filterInvestigationListByName'


  observers: [
    '_calculateNetProfit(filteredInvestigationList)'
    '_calculateTotalIncome(filteredInvestigationList)'
  ]


  _isEmptyArray: (array)->
    return array? and array.length > 0

  navigatedIn: ->
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=> 
      @_loadInvoice organizationIdentifier, 100, 1


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

  _loadInvoice: (organizationIdentifier, size, page)->
    data = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
      size: size
      page: page
    }
    @loadingCounter += 1
    @callApi 'bdemr-clinic-app-get-organization-invoice', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        invoiceItems = response.data
        @set 'invoiceList', invoiceItems
        @set 'matchingInvoiceList', invoiceItems
        @_generateInvestigationReport()
  
  _generateInvestigationReport: (selectedCategory)->
    investigationMap = {}
    if selectedCategory
      for invoice in @matchingInvoiceList
        for item in invoice.data
          if item.category is selectedCategory
            uid = parseInt(item.price-item.actualCost)
            item.uid = "#{item.name}-#{uid}"
            if item.uid of investigationMap
              investigationMap[item.uid].count += parseInt item.qty
            else
              investigationMap[item.uid] = item
              investigationMap[item.uid].count = parseInt item.qty
    else
      for invoice in @matchingInvoiceList
        for item in invoice.data
          uid = parseInt(item.price-item.actualCost)
          item.uid = "#{item.name}-#{uid}"
          if item.uid of investigationMap
            investigationMap[item.uid].count += parseInt item.qty
          else
            investigationMap[item.uid] = item
            investigationMap[item.uid].count = parseInt item.qty

    investigationList = (value for own key, value of investigationMap)
    @set 'investigationList', investigationList
    @set 'filteredInvestigationList', investigationList
    console.log 'investigation list', investigationList

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
      totalIncome += @calculateIncome item
    @set 'totalIncome', totalIncome

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
    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    filteredList = (item for item in @invoiceList when ( startDate.getTime() <= (new Date item.createdDatetimeStamp).getTime() <= endDate.getTime() ))
    @set 'matchingInvoiceList', filteredList
    @_generateInvestigationReport()
    
  invoiceSearchClearButtonClicked: (e)->
    @set 'matchingInvoiceList', @invoiceList
    @_generateInvestigationReport()
    

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()
  

}
