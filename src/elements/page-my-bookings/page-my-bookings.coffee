Polymer {
  is: 'page-my-bookings'

  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.apiCalling    
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.translating
  ]
  
  properties:
    myBookingList: 
      type: Array
      value: []

    selectedView:
      type: Number
      value: -> 0

    invoice:
      type: Object
      value: -> {}

    # isUserAgent:
    #   type: Boolean
    #   value: false

    bookingStatusList:
      type: Array
      value: [
        "All"
        "Booked"
        "Completed"
        "Requires-Second-Visit"
      ]

  
  navigatedIn: ()->
    @user = (app.db.find 'user')[0]
    console.log @user

    @loadAgentBookingList()
    

    

  _sortByDate: (a, b)->
    if a.bookedDatetimeStamp < b.bookedDatetimeStamp
      return 1
    if a.bookedDatetimeStamp > b.bookedDatetimeStamp
      return -1

   _returnSerial: (index)->
    index+1

  _formatDateTime: (dateTime)->
    lib.datetime.format dateTime, 'mmm d, yyyy h:MMTT'
  
  _isEmptyTable: (list)->
    return true if list.length <= 0


  loadAgentBookingList: ()->
    data = { 
      apiKey: @user.apiKey
    }
    this.domHost.callApi '/bdemr-booking--agent--get-my-appointments', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        this.myBookingList = []
        myBookingList = response.data
        this.myBookingList = myBookingList
        this.filteredMyBookingList = myBookingList

        #sort booking list
        @myBookingList.sort (prev, after)->
          return (new Date after.dateString).getTime() - (new Date prev.dateString).getTime()

        @filteredMyBookingList.sort (prev, after)->
          return (new Date after.dateString).getTime() - (new Date prev.dateString).getTime()
      else
        this.myBookingList = []
        this.filteredMyBookingList = []

      console.log 'my booking list ', this.myBookingList
  
  visitCustomSearchClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours 0,0,1
    endDate = new Date e.detail.endDate
    endDate.setHours 23,59,59
    myBookingList = (item for item in @myBookingList when (startDate.getTime() <= (new Date item.bookedDatetimeStamp).getTime() <= endDate.getTime()))
    @set 'myBookingList', myBookingList
    
  visitSearchClearButtonClicked: (e)->
    window.location.reload()

  
  acceptButtonPressed: (e)->
    item = e.model.item
    console.log item
    data = {
      dateString: item.dateString
      chamberSerial: item.chamberSerial
      apiKey: @user.apiKey
      patientId: @user.idOnServer
      status: 'accepted'
    }
    @callApi 'bdemr-booking--patient-accept-reject-online-booking', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        @domHost.showModalDialog 'Booking Accepted!'
        window.location.reload()


  rejectButtonPressed: (e)->
    item = e.model.item
    console.log item
    data = {
      dateString: item.dateString
      chamberSerial: item.chamberSerial
      apiKey: @user.apiKey
      patientId: @user.idOnServer
      status: 'rejected'
    }
    @callApi 'bdemr-booking--patient-accept-reject-online-booking', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        @domHost.showModalDialog 'Booking Rejected!'
        window.location.reload()

  goBackToPreviousView: ->
    @set 'invoice', {}
    @selectedView = 0  
  
  calculateDue: (billed, received)->
    return 'Fully Paid' unless billed - received
    return billed - received

  printButtonPressed: -> window.print()

  printBookingDetails: (e)->
    item = e.model.__data__.item
    console.log 'Selected CHAMBER', item
    localStorage.setItem 'bookingDetails', JSON.stringify(item)
    window.location = '#/print-booking-details'

  _bookingStatusSelected: ()->
    if @bookingStatusSelectedIndex is @bookingStatusList.length-1
      @set 'selectedStatus', ''
    else
      item = @get ['bookingStatusList', @bookingStatusSelectedIndex]
      @set 'selectedStatus', item
      console.log @selectedStatus

  filterButtonClicked: ()->
    searchParameters = {
      searchString: @selectedStatus.toLowerCase()
    }

    if @selectedStatus isnt 'All'
      filteredMyBookingList = @myBookingList.filter (item) =>
        return true if searchParameters.searchString is item.status.toLowerCase()

    if @selectedStatus is 'All'
      filteredMyBookingList = @myBookingList

    if @selecteStatus is '' or undefined or null
      return

    console.log filteredMyBookingList
    @set 'filteredMyBookingList', filteredMyBookingList
}