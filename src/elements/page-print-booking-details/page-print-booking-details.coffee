
Polymer {

  is: 'page-print-booking-details'

  behaviors: [
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.translating
  ]

  properties:

    myBooking:
      type: Object
      value: ()-> {}
    
  
  navigatedIn: ->
    myBooking = JSON.parse(localStorage.getItem("bookingDetails"))
    @_getFormattedChamberTime(myBooking)
    console.log myBooking

  arrowBackButtonPressed: (e)->
    window.history.back()

  _getFormattedChamberTime: (booking)->
    timeslotString = booking.timeSlot
    startEnd = timeslotString.split('to')
    processedTimeSlot = "#{@$formatTimeString startEnd[0].trim()} to #{@$formatTimeString startEnd[1].trim()}"
    booking.timeSlot = processedTimeSlot
    @set 'myBooking', booking
    return

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age

  _formatDateTime: (dateTimeInMs)->
    lib.datetime.format((new Date dateTimeInMs), 'mmm d, yyyy h:MMTT')
  
  _computeTotalDaysCount: (endDate, startDate)->
    return 'As Needed' unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    diffMs = endDate - startDate
    return Math.round(diffMs / oneDay)

  printButtonPressed: ()->
    window.print()

}
