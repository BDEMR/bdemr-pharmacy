Polymer {

  is: 'page-manage-academic-session'

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
      value: (app.db.find 'user')[0]

    organization:
      type: Object
      value: (app.db.find 'organization')[0]

    filterDate:
      type: Object
      value: {}

    loading:
      type: Boolean
      value: false

    settings:
      type: Object,
      notify: true,
      value: null

    academicSessionList:
      type: Object
      value: ()-> {}

    attendeeList:
      type: Array
      value: ()-> []

    attendanceName: String
		
    sessionTimer:
      type: String
      value: "00:00:00"

    code:
      type: String
      value: null      


  _sortByDate: (a, b) ->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1

  navigatedIn: ->

    @params = @domHost.getPageParams()
    @loading = true
    @_loadOrganization =>
      @_loadMemberList()
      @_loadSession @params['session']
      @startSessionTimer()
      @reloadSessionInEveryFiveMinutes()
      @loading = false

  _loadOrganization: (cbfn) ->
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

  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'
  
  _editSessionButtonTapped: ->
    @domHost.navigateToPage '#/academic-session-editor/organization:' + @organization.idOnServer + '/session:' + @academicSessionList._id


  _loadSession: (sessionIdentifier) ->
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
        this._getAttendeeDetailInfo()

  _loadMemberList: ->
    data = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        members = response.data.matchingUserList
        @set 'attendeeList', members


  attendeeSelected: (e)->
    return unless e.detail.value
    item = e.detail.value
    attendeeDetails = {
      attendeeId: item.idOnServer
      minutesAwarded: 0
      isAwarded: false
      isPresent: false
      takenById: null
      takenByDatetimeStamp: null
      groupId: null
    }
    @academicSessionList.attendees.push(attendeeDetails)
    console.log @academicSessionList
    @_setSessionWithNewAttendeeDetail()


  _getAttendeeDetailInfo: ()->
    data = {
      apiKey: @user.apiKey
      payload:
        organizationId: @organization.idOnServer
        sessionId: @academicSessionList._id
    }
    @loading = true
    @callApi '/get-session-attendees-detail-info', data, (err, response)=>
      @loading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        result = response.data
        @set "academicSessionList.attendees", result
        console.log 'Academic Session list', @academicSessionList


  _setSessionWithNewAttendeeDetail: ()->
    data = {
      payload: @academicSessionList,
      apiKey: @user.apiKey
    }
    @callApi '/set-organization-attendance-session', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_getAttendeeDetailInfo()


  takeAttendanceButtonPressed: (e)->
    item = e.model.item
    console.log item
    data = {
      apiKey: @user.apiKey,
      payload: {
        attendeeId: item.attendeeId,
        isPresent: true,
        sessionId: @academicSessionList._id
      }
    }
    @callApi '/take-attendee-attendance-organization-session', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast "Attendance Taken"
        @_loadSession @params['session']


  reloadSessionInEveryFiveMinutes: ()->
    sessionTimer = window.setInterval ()=>
      @_loadSession @params['session']
      console.log 'Reloaded'
    , 300000

  startSessionTimer: ()->
    sessionTimer = window.setInterval ()=>
      @updateSessionTimer()
    , 1000

  updateSessionTimer: ()->
    startTime = localStorage.getItem 'SESSION_TIMER_START'

    endTime = Date.now()

    elapsed = endTime - startTime

    hour = Number.parseInt elapsed/(1000*60*60)
    tempElapsed = elapsed%(1000*60*60)

    minute = Number.parseInt tempElapsed/(1000*60)
    tempElapsed = tempElapsed%(1000*60)

    second = Number.parseInt tempElapsed/1000

    timerValue = "#{if hour < 10 then "0#{hour}" else hour}:#{if minute < 10 then "0#{minute}" else minute}:#{if second < 10 then "0#{second}" else second}"
    @set 'sessionTimer', timerValue

  _returnSerial: (index)->
    return index + 1

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

}
