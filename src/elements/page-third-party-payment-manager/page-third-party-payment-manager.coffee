
Polymer {
  
  is: 'page-third-party-payment-manager'

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

    thirdPartyPaymentObject:
      type: Object
      value: {}
   
    filterDate:
      type: Object
      value: {}

    isLoading:
      type: Boolean
      value: false

    thirdPartyPaymentList:
      type: Array
      value: -> []

    thirdPartyPaymentListFiltered:
      type: Array
      value: -> []
  

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  
  $isAdmin: (userId, userList)->
    for user in userList
      if userId is user.id
        return user.isAdmin
        break
    return false

  _getTotalPaid: (paid = 0, lastPaid = 0)->
    return (parseInt paid) + (parseInt lastPaid)

  
  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  navigatedIn: ->
    @isLoading = true
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>    
      @isLoading = false
      @_makeNewPayment()
      @searchButtonClicked()
      

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
        
        cbfn()
    
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

  
  searchButtonClicked: ()->
    # searchParameters = {
    #   dateCreatedFrom: @dateCreatedFrom?=""
    #   dateCreatedTo: @dateCreatedTo?=""
    #   mobileSearchString: @mobileSearchString.toLowerCase()
    # }    

    # if @dateCreatedFrom
    #   filteredThirdPartyPaymentList = @thirdPartyPaymentList.filter (item) =>
    #     return true if (searchParameters.dateCreatedFrom <= item.createdDatetimeStamp <= searchParameters.dateCreatedTo)

    # if @searchString
    #   filteredThirdPartyPaymentList = @thirdPartyPaymentList.filter (item) =>
    #     return true if (searchParameters.searchString is item.name.toLowerCase()) or (searchParameters.searchString is item.mobile)

    # if @dateCreatedFrom and @searchString
    #   filteredThirdPartyPaymentList = @thirdPartyPaymentList.filter (item) =>
    #     return true if (searchParameters.dateCreatedFrom <= item.createdDatetimeStamp <= searchParameters.dateCreatedTo) and (searchParameters.searchString is item.name.toLowerCase() or searchParameters.searchString is item.mobile)
    

    # console.log {filteredThirdPartyPaymentList}
    # @set 'thirdPartyPaymentList', filteredThirdPartyPaymentList

    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        mobileSearchString: @mobileSearchString.toLowerCase()
      }          
    }
    @callApi '/bdemr--clinic-third-party-payment-report', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        console.log data
        @set 'thirdPartyPaymentList', data


  _addNewPaymentButtonClicked: (e)-> 
    return this.$$('#dialogAddNewPayment').toggle();
  
  _makeNewPayment: ()-> 
    thirdPartyPaymentObject = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: null,
      organizationId: @organization.idOnServer,
      serial: null,
      name: '',
      mobile: '',
      address: '',
      billedDateFrom: null,
      billedDateTo: null,
      paymentDate: null
      paymentAmount: null,
    }
    customBilledDateFrom = ""
    customBilledDateTo = ""
    @set 'thirdPartyPaymentObject', thirdPartyPaymentObject

  _setBilledDateFrom: ()->
    return unless @customBilledDateFrom
    billedDate = new Date("#{@customBilledDateFrom}")
    @set 'thirdPartyPaymentObject.billedDateFrom', billedDate.getTime()
    @customBilledDateFrom = ""

  _setBilledDateTo: ()->
    return unless @customBilledDateTo
    billedDate = new Date("#{@customBilledDateTo}")
    @set 'thirdPartyPaymentObject.billedDateTo', billedDate.getTime()
    @customBilledDateTo = ""


  _addPaymentRequest: ()->
    unless @thirdPartyPaymentObject.name or @thirdPartyPaymentObject.billedDateFrom or @thirdPartyPaymentObject.paymentAmount
      return @domHost.showModalDialog 'Please Enter All Information in the form'

    @thirdPartyPaymentObject.lastModifiedDatetimeStamp = lib.datetime.now()
    @thirdPartyPaymentObject.paymentDate = lib.datetime.now()
    if !@thirdPartyPaymentObject.serial
      @thirdPartyPaymentObject.serial = @generateSerialForThirdPartyPayment()
      
    if @customBilledDateFrom
      @_setBilledDateFrom()

    if @customBilledDateTo
      @_setBilledDateTo()

    # app.db.insert 'third-party-payment-list', @thirdPartyPaymentObject
    data = { 
      apiKey: @user.apiKey
      thirdPartyPaymentObject: @thirdPartyPaymentObject  
    }
    @callApi '/bdemr--clinic-add-third-party-payment', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        console.log data

    console.log {@thirdPartyPaymentObject}
    @_makeNewPayment()
    @searchButtonClicked()
    return this.$$('#dialogAddNewPayment').close();


  _deletePayment:(e)->
    { item } = e.model
    console.log item
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        data = { 
          apiKey: @user.apiKey
          id: item._id
        }
        @callApi '/bdemr--clinic-delete-third-party-payment', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            @domHost.showToast "Payment Deleted"
            @searchButtonClicked()
            return


  resetButtonClicked: (e)->
    window.location.reload()    
    
}
