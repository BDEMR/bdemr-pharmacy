
Polymer {
  
  is: 'page-chamber'

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
      value: null
    
    chamber:
      type: Object
      value: null

    chamberName:
      type: Object
      value: null

    chamberShortCode:
      type: Object
      value: null


  _notify: (phone, email, message)->
    data = { 
      phone,
      email
      category: "Chamber"
      message
    }
    this.callApi '/extern-scheduler-add-notification', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message

  _getChamber: (cbfn)->
    data = { 
      apiKey: this.user.apiKey
      organizationId: this.organization.idOnServer
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
            this.chamberName = chamber.name
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
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        this.scheduleForMonth = []
        scheduleForMonth = response.data 
        this.scheduleForMonth = scheduleForMonth
        cbfn()
      else
        this.scheduleForMonth = []
        cbfn()

  _getMonthString: ->
    array = this.fullDateString.split '-'
    array.pop()
    return array.join '-'

  _refreshSchedule: (cbfn)->
    monthString = this._getMonthString()
    this._getScheduleForMonth monthString, this.chamber.serial, =>
      this._generateCalendar()
      cbfn()
  
  _generateCalendar: ->
    monthString = this._getMonthString()
    [ year, month ] = monthString.split '-'
    date = new Date(year, month, 0)
    daysInMonth = (date.getDate())
    date.setHours(24)
    date.setMonth(date.getMonth()-1)
    firstDay = date.getDay()
    this.calendar = []
    calendar = []
    for dayName in ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
      entry = {
        type: 'dayName'
        dayName
      }
      calendar.push(entry)
    for day in [0...firstDay]
      entry = {
        type: 'skip'
      }
      calendar.push(entry)
    daysInMonth += 1
    for date in [1...daysInMonth]
      entry = {
        date
        type: 'date'
      }
      dateString = monthString + '-' + (if date < 10 then '0' else '') + date
      entry.status = 'empty'
      for schedule in this.scheduleForMonth
        if dateString is schedule.dateString
          if schedule.isCanceled
            entry.status = 'canceled'
          else
            entry.status = 'ready'
      calendar.push(entry)
    fillerCount = (43 - (daysInMonth + firstDay)) % 7
    for day in [0...(fillerCount + 8)]
      entry = {
        type: 'skip'
      }
      calendar.push(entry)
    this.calendar = calendar

  refreshScheduleForMonthTapped: (e)->
    this._refreshSchedule =>
      null

  _generateTimeSlotList: (startTimeString, endTimeString, bookingSlotSizeInMinutes)->
    start = (new Date ("2000-01-01T" + startTimeString))
    end = (new Date ("2000-01-01T" + endTimeString))
    timeSlotList = []
    while (start.getTime() < end.getTime())
      startTimeString = this.$mkTime(start)
      start.setMinutes(start.getMinutes() + parseInt(bookingSlotSizeInMinutes))
      endTimeString = this.$mkTime(start)
      timeSlotList.push("#{startTimeString} to #{endTimeString}")
    return timeSlotList

  _setScheduleForDate: (schedule, cbfn)->
    data = { 
      apiKey: this.user.apiKey
    }
    Object.assign(data, schedule)
    this.callApi '/bdemr-booking--doctor--set-schedule-for-date', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        cbfn()

  createScheduleTapped: (e)->
    { entry } = e.model
    
    schedule = {
      chamberSerial: this.chamber.serial
      chamberName: this.chamber.name
      organizationName: @organization.name
      doctorId: this.chamber.doctorId
      dateString: this._getMonthString() + '-' + (if entry.date < 10 then '0' else '') + entry.date
      startTimeString: this.chamber.startTimeString
      endTimeString: this.chamber.endTimeString
      isCanceled: false
      isRescheduled: false
      rescheduleDelayInMinutes: 0
      timeSlotList: this._generateTimeSlotList(this.chamber.startTimeString, this.chamber.endTimeString, this.chamber.bookingSlotSizeInMinutes)
      bookingList:[]
    }

    console.log schedule
    this._setScheduleForDate schedule, =>
      this._refreshSchedule =>
        null

  cancelScheduleTapped: (e)->
    { entry } = e.model
    dateString = this._getMonthString() + '-' + (if entry.date < 10 then '0' else '') + entry.date
    selectedSchedule = null
    for schedule in this.scheduleForMonth
      if dateString is schedule.dateString
        selectedSchedule = schedule
    selectedSchedule.isCanceled = true
    this._setScheduleForDate selectedSchedule, =>
      this._refreshSchedule =>
        for entry in selectedSchedule.bookingList
          message = "#{this.user.name} of #{this.chamberName} canceled all appointments on #{dateString}"
          this._notify(entry.patientPhone, entry.patientEmail, message)
        null

  reinstateScheduleTapped: (e)->
    { entry } = e.model
    dateString = this._getMonthString() + '-' + (if entry.date < 10 then '0' else '') + entry.date
    selectedSchedule = null
    for schedule in this.scheduleForMonth
      if dateString is schedule.dateString
        selectedSchedule = schedule
    selectedSchedule.isCanceled = false
    this._setScheduleForDate selectedSchedule, =>
      this._refreshSchedule =>
        for entry in selectedSchedule.bookingList
          message = "#{this.user.name} of #{this.chamberName} reinstated all appointments on #{dateString}"
          this._notify(entry.patientPhone, entry.patientEmail, message)
        null

  rescheduleScheduleTapped: (e)->
    { entry } = e.model
    e.model.set('entry.rescheduleDelayInMinutes', 0)
    e.model.set('entry.status', 'rescheduling')

  saveReschedulingScheduleTapped: (e)->
    { entry } = e.model
    dateString = this._getMonthString() + '-' + (if entry.date < 10 then '0' else '') + entry.date
    selectedSchedule = null
    for schedule in this.scheduleForMonth
      if dateString is schedule.dateString
        selectedSchedule = schedule
    selectedSchedule.rescheduleDelayInMinutes = entry.rescheduleDelayInMinutes
    this._setScheduleForDate selectedSchedule, =>
      this._refreshSchedule =>
        for entry in selectedSchedule.bookingList
          message = "#{this.user.name} of #{this.chamberName} rescheduled all appointments on #{dateString} by #{selectedSchedule.rescheduleDelayInMinutes} minutes"
          this._notify(entry.patientPhone, entry.patientEmail, message)
        null

  managePatientsScheduleTapped: (e)->
    { entry } = e.model
    dateString = this._getMonthString() + '-' + (if entry.date < 10 then '0' else '') + entry.date
    # window.localStorage.setItem('navigate',this.chamberShortCode)
    # window.localStorage.setItem('dateString',dateString)

    this.domHost.navigateToPage "#/chamber-patients/chamber:#{this.chamberShortCode}/date:#{dateString}"

  navigatedIn: ->
    organization = @getCurrentOrganization()
    if organization
      @set 'organization', organization
    else
      @domHost.navigateToPage '#/select-organization'
      
    this.chamberShortCode = this.domHost.getPageParams()['which']
    this.fullDateString = this.$mkDate((new Date))
    this._getChamber =>
      this._refreshSchedule =>
        null
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  isToday: (dateNumber)->
    today = (new Date).getDate()
    if dateNumber is today then true else false

}
