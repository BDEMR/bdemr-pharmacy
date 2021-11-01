
Polymer {
  
  is: 'page-nwdr-reports'

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
      value: -> (app.db.find 'user')[0]

    organization:
      type: Object
      notify: true
      value: null

    childOrganizationList:
      type: Array
      notify: true
      value: []

    loading:
      type: Boolean
      value: false

    nwdrPatientList:
      type: Array
      notify: true
      value: []

    selectedDateRangeIndex:
      type: Number
      value: 0
      notify: true
      observer: 'selectedDateRangeIndexChanged'

    dayRangeTypeList:
      type: Array
      notify: true
      value: -> [
        {
          type: 'Today'
          daysCount: 0
        }

        {
          type: 'Yesterday'
          daysCount: 1
        }

        {
          type: 'Last 7days'
          daysCount: 7
        }

        {
          type: 'Last 30days'
          daysCount: 30
        }

        {
          type: 'Custom Date'
          daysCount: -1
        }
      ]

    nwdrPatientCounter: Number
    dateCreatedFrom: String
    dateCreatedTo: String
    selectedGender: String
    selectedOrganizationId: String

  selectedDateRangeIndexChanged: (selectedPageIndex)->
   
    console.log selectedPageIndex
    if selectedPageIndex is 0
      today = new Date()
      # console.log today.setHours(23, 59, 59)
      # console.log today.setHours(23, 59, 59, 999)
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', todayStart
      @set 'dateCreatedTo', todayEnd

    if selectedPageIndex is 1
      
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', yesterdayStart
      @set 'dateCreatedTo', yesterdayEnd

    if selectedPageIndex is 2

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', thisWeekStart
      @set 'dateCreatedTo', thisWeekEnd

    if selectedPageIndex is 3

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', last30Days
      @set 'dateCreatedTo', today

    if @user and @organization

      @_loadOrganizationWiseNwdrSpecifiPatientList()




  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1


  organizationSelected: (e)->
    organizationId = e.detail.value
    @set 'selectedOrganizationId', organizationId

    if @user and @organization
      @_loadOrganizationWiseNwdrSpecifiPatientList()

  filterByDateClicked: (e)->
    startDate = new Date(e.detail.startDate)
    startDate.setHours(0, 0, 0, 0)
    endDate = new Date(e.detail.endDate)
    endDate.setHours(23, 59, 59, 999)
    @set 'dateCreatedFrom', startDate.getTime()
    @set 'dateCreatedTo', endDate.getTime()

  filterByDateClearButtonClicked:()->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0

  filterButtonClicked: ()->
    @_loadOrganizationWiseNwdrSpecifiPatientList()

  _loadOrganization: (cbfn)->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
      @_loadChildOrganizationList @organization.idOnServer

    cbfn()


  _loadChildOrganizationList: (organizationIdentifier)->
    @organizationLoading = true

    query =
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier

    @callApi '/bdemr--get-child-organization-list', query, (err, response) =>
      console.log response
      @organizationLoading = false
      organizationList = response.data
      @set 'childOrganizationCounter', organizationList.length
      if organizationList.length
        mappedValue = organizationList.map (item) => ({ label: item.name, value: item._id })

        mappedValue.unshift { label: 'All', value: '' }

        @set 'childOrganizationList', mappedValue
      else
        @domHost.showToast 'No Child Organization Found'

   _loadOrganizationWiseNwdrSpecifiPatientList: ()->

    query =
      apiKey: this.user.apiKey
      organizationIdList: []
      searchParameters:
        dateCreatedFrom: this.dateCreatedFrom || lib.datetime.now()
        dateCreatedTo: this.dateCreatedTo || lib.datetime.now()


    if !this.selectedOrganizationId
      organizationIdList = this.childOrganizationList.map (item) => item.value
      organizationIdList.splice 0, 1
      
      query.organizationIdList = organizationIdList
      query.organizationIdList.push this.organization.idOnServer


    else
      query.organizationIdList = this.selectedOrganizationId



    @callApi '/get-organization-specific-nwdr-patient-list', query, (err, response) =>
      console.log response
      if response.hasError
        @nwdrPatientList = []
        @set 'nwdrPatientCounter', 0
      else
        @nwdrPatientList = response.data

        @set 'nwdrPatientCounter', response.data.length

  viewPatientNdrRecordList: (e)->
    patient = e.model.item
    @domHost.navigateToPage '#/ndr-record-list/patient:' + patient.serial

   
  navigatedIn: ->
    @_loadOrganization =>
      @_loadOrganizationWiseNwdrSpecifiPatientList()
      @set 'selectedDateRangeIndex', 0
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

 
}
