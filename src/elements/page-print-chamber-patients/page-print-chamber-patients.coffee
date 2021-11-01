
Polymer {
  
  is: 'page-print-chamber-patients'

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

    chamberShortCode:
      type: Object
      value: null

    timeSlotAvailability:
      type: Object
      value: null

    organization:
      type: Object
      notify: true
      value: null

    schedule:
      type: Object
      notify: true
      value: null

    bookedList:
      type: Array
      notify: true
      value: []

    
  _getChamber: (cbfn)->
    data = { 
      apiKey: this.user.apiKey
      organizationId: @organization.idOnServer
    }
    this.callApi '/bdemr--get-all-organization-chamber', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        this.chamber =  null
        chamberList = response.data
        for chamber in chamberList
          if chamber.shortCode is this.chamberShortCode
            this.chamber = chamber
        cbfn()
      else
        this.chamber = null
        cbfn()

  _getScheduleForMonth: (monthString, chamberSerial, cbfn)->
    data = { 
      apiKey: this.user.apiKey
      monthString
      chamberSerial
    }
    this.callApi '/bdemr-booking--doctor--get-schedule-for-month', data, (err, response)=>
      console.log response
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        this.scheduleForMonth = []
        scheduleForMonth = response.data 
        # this.scheduleForMonth = scheduleForMonth
        cbfn scheduleForMonth
      else
        # this.scheduleForMonth = []
        cbfn []

  _getMonthString: ->
    array = this.dateString.split '-'
    array.pop()
    return array.join '-'

  _getScheduleForDate: (dateString)->
    monthString = this._getMonthString()
    this._getScheduleForMonth monthString, this.chamber.serial, (scheduleForMonth) =>
      
      selectedSchedule = null
      for schedule in scheduleForMonth
        if dateString is schedule.dateString
          selectedSchedule = schedule
          break
      
      @schedule = null
      @schedule = selectedSchedule
      console.log "SCHEDULE before filtering", @schedule

      # filter schedule to remove canceled bookings
      filteredSchedule = @schedule.bookingList.filter (entry)=>
        entry.status.toLowerCase() isnt 'canceled'
      
      @bookedList = filteredSchedule
      console.log "booked list", @bookedList
      this._computeTimeSlotAvailability()


  _notifyInvalidOrganization: ->
    @showModal 'No Organization is Present. Please Select an Organization first.'

  _loadOrganization: ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
    else
      @_notifyInvalidOrganization()

  _returnSerial: (index)->
    index+1

  navigatedIn: ->
    @_loadOrganization()
    this.chamberShortCode = this.domHost.getPageParams()['chamber']
    this.dateString =  this.domHost.getPageParams()['date']
    this._getChamber =>
      this._getScheduleForDate this.dateString
      
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  printButtonPressed: (e)->
    window.print()

  _computeTimeSlotAvailability: ->
  
    map = {}
    
    for timeSlot in @schedule.timeSlotList
      map[timeSlot] = 0

    for booking in @schedule.bookingList
      unless booking.timeSlot of map
        map[booking.timeSlot] = 0
      map[booking.timeSlot] += 1

    freeSchedule = []
    for timeSlot, count of map
      freeSchedule.push {
        timeSlot
        availableCount: (this.chamber.maximumVisitorPerBookingSlot - count)
      }

    this.timeSlotAvailability = freeSchedule

    console.log this.timeSlotAvailability

}
