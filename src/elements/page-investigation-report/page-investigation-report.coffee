
Polymer {

  is: 'page-investigation-report'

  behaviors: [ 
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.commonComputes
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: null

    loading:
     type: Boolean
     value: -> false

    reportResults:
      type: Array
      value: -> []
    
    testResultStatusList:
      type: Array
      value: -> [
        "All",
        "Complete",
        "Not Complete"
      ]

    testResultDeliveryStatusList:
      type: Array
      value: -> [
        "All",
        "Delivered",
        "Not Delivered"
      ]

    dateCreatedFrom: String
    dateCreatedTo: String
    


  navigatedIn: ->
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @set 'user', userList[0]


    
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

  
  resetButtonClicked: -> @domHost.reloadPage()


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

  filterByTestResultStatus: (e)->
    index = e.detail.selected
    if index is 0
      @testResultStats = 'all'
    if index is 1
      @testResultStats = 'complete'
    if index is 2
      @testResultStats = 'not complete'

  filterByTestResultDeliveryStatus: (e)->
    index = e.detail.selected
    if index is 0
      @testResultDeliveryStats = 'all'
    if index is 1
      @testResultDeliveryStats = 'delivered'
    if index is 2
      @testResultDeliveryStats = 'not delivered'
   

  deliveredButtonClicked: (e)->
    item = e.model.item
    data = {
      apiKey: @user.apiKey
      investigationSerial: item.serial
      deliveryDateTime: lib.datetime.now()
    }

    @callApi '/bdemr--clinic-update-test-advise-list-for-delivery', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log 'Successfully updated'
        @searchButtonClicked()
  

  searchButtonClicked: ->
    @reportResults = []
    
    query = {
      apiKey: @user.apiKey
      organizationIdList: [@organization.idOnServer]
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        testResultStatus: @testResultStats
        testResultDeliveryStatus: @testResultDeliveryStats
      }
    }
    
    @loading = true
    @callApi '/bdemr--clinic-investigation-report', query, (err, response)=>
      @loading = false
      if err
        return @domHost.showModalDialog err.message
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        reportResults = response.data
        reportResults.sort (a, b)-> b.createdDatetimeStamp - a.createdDatetimeStamp
        @set 'reportResults', reportResults
        console.log {@reportResults}

}
