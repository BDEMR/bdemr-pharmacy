
Polymer {
  
  is: 'page-chamber-statistics'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    hasSearchBeenPressed:
      type: Boolean
      notify: true
      value: true

    matchingChamberList:
      type: Array
      notify: true
      value: ->[]

    chamberSearchString: 
      type: String
      notify: true
      value: ''

    organization:
      type: Object
      notify: true
      value: null

    user:
      type: Object
      notify: true
      value: null

    loading:
      type: Boolean
      value: false

    currentDateFilterStartDate:
      type: Number

    currentDateFilterEndDate:
      type: Number

    dateRangeProvided:
      type: Boolean
      value: false


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      # console.log @user


  navigatedIn: ->
    @_loadUser()
    @organization = @getCurrentOrganization()
    @_getChamberList()

  _getChamberList: ()->
    data = { 
      apiKey: this.user.apiKey
      organizationId: @organization.idOnServer
    }

    if @dateRangeProvided
      data.dateRangeProvided = true
      data.startDate = @currentDateFilterStartDate
      data.endDate = @currentDateFilterEndDate
    else
      data.dateString = (new Date()).toISOString().split('T')[0]


    this.loading = true;
    this.callApi '/bdemr-booking--clinic--get-chamber-statistics-report', data, (err, response)=>
      this.loading = false;
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        matchingChamberList = response.data
        matchingChamberList.sort (a, b)->
          return -1 if a.name < b.name
          return 1 if a.name > b.name
          return 0
        @set 'matchingChamberList', matchingChamberList
        console.log 'chamber list', @matchingChamberList

      else
        this.matchingChamberList = []
    
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPage "#/chamber-manager"

  searchChamberTapped: (e)->
    return @domHost.showModalDialog 'Please type your search' unless @chamberSearchString
    data = { 
      apiKey: @user.apiKey
      searchString: @chamberSearchString
      organizationId: this.organization.idOnServer
      dateString: (new Date()).toISOString().split('T')[0]
    }
    this.loading = true;
    @callApi '/bdemr-booking--clinic--get-chamber-schedule-report', data, (err, response)=>
      this.loading = false;
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'matchingChamberList', response.data

  clearSearchResultsClicked: (e)->
    @matchingChamberList = []

  getTotalBooked: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)->
      return total += chamber.bookedPatient?=0
    ,0

  getTotalCanceled: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)->
      return total += chamber.canceledPatient?=0
    ,0

  getTotalCompleted: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)->
      return total += chamber.completedPatient?=0
    ,0
  
  formatDate: ()->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day
    return [year, month, day].join('-')  

  # Filter by date
  filterStatByDate: (e)->
    
    @currentDateFilterStartDate = e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    @currentDateFilterEndDate = e.detail.endDate
    console.log 'start date', @currentDateFilterStartDate
    console.log 'end date', @currentDateFilterEndDate

    @dateRangeProvided = true
    @_getChamberList()

  filterStatByDateClear: (e)->
    @currentDateFilterStartDate = null
    @currentDateFilterEndDate = null
    @dateRangeProvided = false
    @_getChamberList()


  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

  _returnIndex: (index)->
    index+1

}
