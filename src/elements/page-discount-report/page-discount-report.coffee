
Polymer {
  
  is: 'page-discount-report'

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
      notify: true
      value: (app.db.find 'organization')[0]

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]     

    invoiceList:
      type: Array
      value: []

    discountFromList:
      type: Array
      notify: true
      value: []

    matchingDiscountedInvoiceList:
      type: Array
      notify: true
      value: []

    totalDiscount:
      type: Number
      value: 0

    fundList:
      type: Array
      value: ()-> []

    loadingCounter:
      type: Number
      value: 0

    discountByItemList:
      type: Array
      value: ()-> [
        "Doctor"
        "Organization"
        "Management"
        "Staff"
      ]
    
    currentDateTime:
      type: Number
      value: lib.datetime.now()


  _isEmptyArray: (array)->
    return array? and array.length > 0
  
  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  
  navigatedIn: ->
    @loadingCounter++
    @domHost._syncOnlyPatientInvoice ()=>
      @_loadUser()
      @_loadOrganization (organizationIdentifier)=>    
        @_loadFunds organizationIdentifier
        @loadingCounter--


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _loadOrganization: (cbfn)->
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn @organization.idOnServer


  _loadFunds: (organizationIdentifier)->
    @loadingCounter++
    data =
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    @callApi 'bdemr--clinic-get-discount-fund-list', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'fundList', response.data

    
  filterByFunds: (e)->
    index = e.detail.selected
    fund = @fundList[index]
    @selectedFundSerial = fund.serial
 
  filterUsingDiscountBy: (e)->
    index = e.detail.selected
    if index is 0
      @discountByItem = 'doctor'
    if index is 1
      @discountByItem = 'organization'
    if index is 2
      @discountByItem = 'management'
    if index is 3
      @discountByItem = 'staff'

    
  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'


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
    
  _calculateTotalDiscount: (list)->
    totalDiscount = 0
    for item in list
      totalDiscount += parseInt item.discount?=0
    @set 'totalDiscount', totalDiscount

  _calculateGeneralDiscount: (discount, specialDiscount)->
    totalGeneralDiscount = discount - specialDiscount
  
  searchButtonClicked: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: [@organization.idOnServer]
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        serial: @selectedFundSerial
        discountBy: @discountByItem
      }
    }
    @loadingCounter++
    @callApi '/bdemr--clinic-discount-report', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        invoiceItems = response.data
        @set 'matchingDiscountedInvoiceList', invoiceItems
        @_calculateTotalDiscount @matchingDiscountedInvoiceList
        

  viewCommissionButtonPressed: (e)->
    item = e.model.item
    @domHost.navigateToPage '#/print-invoice/invoice:' + item.referenceNumber + '/patient:' + item.patientSerial

  resetButtonClicked: (e)->
    window.location.reload()

  
  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()
    
  
    
}
