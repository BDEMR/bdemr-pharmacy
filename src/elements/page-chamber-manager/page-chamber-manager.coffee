
Polymer {
  
  is: 'page-chamber-manager'

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


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      # console.log @user


  navigatedIn: ->
    @_loadUser()
    @organization = @getCurrentOrganization()
    @_getChamberList @organization.idOnServer, ()=> null

  _getChamberList: (organizationIdentifier, cbfn)->
    data = { 
      apiKey: this.user.apiKey
      organizationId: organizationIdentifier
      dateString: (new Date()).toISOString().split('T')[0]
    }
    console.log 'api data', data
    this.loading = true;
    this.callApi '/bdemr-booking--clinic--get-chamber-schedule-report', data, (err, response)=>
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
        cbfn()
      else
        this.matchingChamberList = []
        cbfn()
  
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
        @set 'matchingChamberList', []
        console.log response.error.message
      else
        @set 'matchingChamberList', response.data

  clearSearchResultsClicked: (e)->
    @matchingChamberList = []

  getFreeSlots: (freeSlots)->
    return 0 unless freeSlots?.length 
    return freeSlots.reduce (total, freeSlot)->
      return total += freeSlot.availableCount
    , 0

  getTotalFreeSlots: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)=>
      return total += @getFreeSlots chamber.freeSlots
    ,0

  getTotalBooked: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)->
      return total += chamber.bookedPatient?=0
    ,0

  getTotalAwaiting: (chamberList)->
    return 0 unless chamberList?.length 
    return chamberList.reduce (total, chamber)->
      return total += chamber.awaitingPatient?=0
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

  viewChamberSchedule: (e)->
    { item } = e.model
    today = this.formatDate()
    this.domHost.navigateToPage "#/chamber-patients/chamber:#{item.shortCode}/date:#{today}"
    # window.location.reload()


  viewTodaysPatient: (e)->
    {item} = e.model
    dateString = (new Date()).toISOString().split('T')[0]
    this.domHost.navigateToPage "#/chamber-patients/chamber:#{item.shortCode}/date:#{dateString}"

  newPatientPressed: (e)->
    @domHost.navigateToPage '#/patient-signup'

  goBookingAndServices: (e)->
    @domHost.navigateToPage '#/booking'

  goToChamberStatistics: ()->
    @domHost.navigateToPage '#/chamber-statistics'

  _returnIndex: (index)->
    index+1    

}
