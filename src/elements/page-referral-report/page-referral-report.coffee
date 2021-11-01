Polymer {

  is: 'page-referral-report'

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

    referralList:
      type: Array
      value: ()-> []
    
    matchingReferralList:
      type: Array
      value: ()-> []

    thirdPartySuperVisorList:
      type: Array
      value: ()-> []

    thirdPartyIdList:
      type: Array
      value: ()-> []

    totalReferralCommission:
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
  
  # _formatDateTime: (dateTime)->
  #   lib.datetime.format( dateTime, 'mmm d, yyyy')
  
  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>
      @loadingCounter--
      @loadSuperVisorList()

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
        thirdPartyIdList: @thirdPartyIdList
      }
    }
    @loadingCounter++
    @callApi '/bdemr--clinic-referral-report', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        invoiceItems = response.data
        @set 'matchingReferralList', invoiceItems
        console.log {@matchingReferralList}
        @_calculateTotalReferralCommission @matchingReferralList
        console.log 'referral list', @matchingReferralList

  filterBySuperVisorNameChanged: (e)->
    index = e.detail.selected;
    supervisor = @thirdPartySuperVisorList[index];
    thirdPartyList = supervisor.thirdPartyArr
    for item in thirdPartyList
      @thirdPartyIdList.push(item.thirdPartyId)
    return console.log {@thirdPartyIdList}
    # return @selectedCategorySerial = category.serial;

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

  _calculateTotalReferralCommission: (list)->
    totalReferralCommission = 0
    for item in list
      totalReferralCommission += parseInt item.totalAmountReceieved?=0
    @set 'totalReferralCommission', totalReferralCommission


  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'


  viewReferralInvoiceButtonPressed: (e)->
    item = e.model.item
    @domHost.navigateToPage '#/print-invoice/invoice:' + item.referenceNumber + '/patient:' + item.patientSerial

  resetButtonClicked: (e)->
    window.location.reload()

  loadSuperVisorList: ()->
    thirdPartySuperVisorList = app.db.find 'third-party-supervisor-list', ({organizationId})=> organizationId is @organization.idOnServer
    @set 'thirdPartySuperVisorList', thirdPartySuperVisorList
    console.log 'supervisor list', @thirdPartySuperVisorList

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()


}