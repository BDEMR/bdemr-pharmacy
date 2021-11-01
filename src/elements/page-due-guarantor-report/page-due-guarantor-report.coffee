Polymer {

  is: 'page-due-guarantor-report'

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

    filterDate:
      type: Object
      value: {}

    guarantorList:
      type: Array
      value: []
    
    matchingGuarantorList:
      type: Array
      value: []

    totalDueTakenByGuarantor:
      type: Number
      value: 0

    loadingCounter:
      type: Number
      value: 0

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


  _calculateDueAndFormatCurrency: (billed, received)->
    return @$formatCurrency @_calculateDue billed, received


  _calculateDue: (billed, received)->
    if received >= billed
      return 0
    else
      return billed-received

  _hasDue: (billed, received)->
    return billed > received
  
  # _formatDateTime: (dateTime)->
  #   lib.datetime.format( dateTime, 'mmm d, yyyy')
  
  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>
      @loadingCounter--


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  
  _loadOrganization: (cbfn)->
    @loadingCounter++
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn @organization.idOnServer    

  searchButtonClicked: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: [@organization.idOnServer]
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        searchString: @searchString
      }
    }
    @loadingCounter++
    @callApi '/bdemr--clinic-due-guarantor-report', query, (err, response)=>
      @set 'matchingGuarantorList', []
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        invoiceItems = response.data
        @set 'matchingGuarantorList', invoiceItems
        console.log 'due guarantor list', @matchingGuarantorList
        
      @_calculateTotalDueTakenByGuarantor @matchingGuarantorList



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

  _calculateTotalDueTakenByGuarantor: (list)->
    tempTotalDue = 0
    for item in list
      tempTotalDue += @_calculateDue item.totalBilled, item.totalAmountReceieved
    @set 'totalDueTakenByGuarantor', tempTotalDue


  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'

  resetButtonClicked: (e)->
    window.location.reload()

  viewInvoiceButtonPressed: (e)->
    item = e.model.item
    @domHost.navigateToPage '#/print-invoice/invoice:' + item.referenceNumber + '/patient:' + item.patientSerial

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()


}