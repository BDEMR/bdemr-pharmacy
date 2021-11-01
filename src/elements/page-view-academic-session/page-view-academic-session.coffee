Polymer {

  is: 'page-view-academic-session'

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
      value: (app.db.find 'organization')[0]

    filterDate:
      type: Object
      value: {}

    loading:
      type: Boolean
      value: false

    attendanceTaken:
      type: Boolean
      value: false
    
    isQrCodeActive:
      type: Boolean
      value: false

    settings:
      type: Object,
      notify: true,
      value: null

    academicSessionList:
      type: Object
      value: ()-> {}

    attendeeName: String

  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1

  # _formatDateTime: (dateTime)->
  #   lib.datetime.format( dateTime, 'mmm d, yyyy')

  navigatedIn: ->
    @params = @domHost.getPageParams()
    @loading = true
    @_loadUser()
    @_loadOrganization =>
      @_loadSession @params['session']
      @loading = false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  _loadOrganization: (cbfn)->
    @loading = true
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response) =>
      @loading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn @organization.idOnServer 

  arrowBackButtonPressed: () -> 
    @domHost.navigateToPreviousPage()
  
  _notifyInvalidOrganization: ->
    domHost.showModalDialog "No Organization is Present. Please Select an Organization first."

  _loadSession: (sessionIdentifier)->
    query = {
      apiKey: @user.apiKey
      payload:
        organizationId: @organization.idOnServer
        sessionId: sessionIdentifier
    }
    @loading = true
    @callApi '/get-organization-attendance-session', query, (err, response)=>
      @loading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        academicSessionList = response.data
        @set 'academicSessionList', academicSessionList
        console.log 'Academic Session list', @academicSessionList


  # ======= QR CODE STARTS ==========

  _resetQrCode:()->
    @set 'isQrCodeActive', true
    @set 'attendanceTaken', false
  
  _onQrCodeChanged: (e)->
    code = e.detail.result.text
    if code
      @takeAttendance code
    
  
  takeAttendance: (code)->
    console.log code
    data = {
      apiKey: @user.apiKey,
      payload: {
        attendeeId: @user.idOnServer,
        isPresent: true,
        sessionId: code
      }
    }
    @callApi '/take-attendee-attendance-organization-session', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog "ATTENDANCE TAKEN!"
        @set 'attendanceTaken', true
  
  _startScanning: ()->
    @set 'isQrCodeActive', true

  # ======= QR CODE ENDS ==========

}
