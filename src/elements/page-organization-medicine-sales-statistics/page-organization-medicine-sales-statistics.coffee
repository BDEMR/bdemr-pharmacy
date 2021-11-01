
Polymer {

  is: 'page-organization-medicine-sales-statistics'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false

    organization:
      type: Object
      notify: true
      value: null

    marketShareList:
      type: Array
      value: -> []
    
    shouldSearchByBrandName:
      type: Boolean
      value: true

    searchFilterOrganizationIndex:
      type: Number
      value: -> 0

  setSearchByBrandName: (e)->
    @shouldSearchByBrandName = true
  
  setDontSearchByBrandName: (e)->
    @shouldSearchByBrandName = false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadOrganization: (idOnServer, cbfn)->
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
        @set 'isOrganizationValid', true
        cbfn()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  navigatedIn: ->
    @_loadUser()
    
    params = @domHost.getPageParams()
    unless params['organization']
      @_notifyInvalidOrganization()
      return

    @_loadOrganization params['organization'], =>
      'pass'
    
  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false
    @authorizedRecordList = []

  searchButtonTapped: (e)->
    @statistics = null
    @marketShareList = []
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filters: {
        shouldSearchByBrandName: @shouldSearchByBrandName
        searchFilterBrandName: @searchFilterBrandName or null
        searchFilterGenericName: @searchFilterGenericName or null
        searchFilterNameOfManufacturer: @searchFilterNameOfManufacturer or null
        searchFilterStartDate: @searchFilterStartDate or null
        searchFilterEndDate: @searchFilterEndDate or null
        searchFilterDistrictName: @searchFilterDistrictName or null
      }
    }
    @callApi '/bdemr-organization-get-medicine-sales-statistics', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @statistics = response.data.statistics
        @marketShareList = response.data.marketShareList

  $in: (value, list)-> 
    value in list
         
            
            
        
        
}
