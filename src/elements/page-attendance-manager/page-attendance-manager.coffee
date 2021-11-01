Polymer {

  is: 'page-attendance-manager'

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


    loadingCounter:
      type: Number
      value: 0

    currentDateTime:
      type: Number
      value: lib.datetime.now()

    settings:
      type: Object,
      notify: true,
      value: null
    
    selectedPage:
      type: Number
      value: 0

    # Manage Session Releated Codes Starts  
    
    academicSessionList:
      type: Array
      value: ()-> []

    # Manage Session Releated Codes Ends  

    # Manage Group - Start

    groupList:
      type: Array
      value: ()-> []

    # Manage Group - End

    # Attendee List - Start
    attendeeList:
      type: Array
      value: ()-> []
    # Attendee List - End


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
    @loadingCounter++
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>
      @_getActivityLogs()
      @loadingCounter--

  _loadUser: ()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  
  _loadOrganization: (cbfn)->
    @loadingCounter++
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
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




  # ============== Manage Session Codes - start ==============

  filterByDateClickedFromManageSession: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'startDateForSession', (startDate.getTime())
    @set 'endDateForSession', (endDate.getTime())

  filterByDateClearButtonClickedFromManageSession: ->
    @startDateForSession = 0
    @endDateForSession = 0

  showAllSessionTapped: ()->
    query = {
      apiKey: @user.apiKey
      payload: 
        organizationId: @organization.idOnServer
        filterBy: {
          fromDate:  @startDateForSession
          toDate: @endDateForSession
        }
    }
    @loadingCounter++
    @callApi '/get-organization-attendance-sessions', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        academicSessionList = response.data
        @set 'academicSessionList', academicSessionList
        console.log 'Academic Session list', @academicSessionList

  createNewSessionTapped: ()->
    @domHost.navigateToPage '#/academic-session-editor/organization:' + @organization.idOnServer + '/session:new'        

  viewSessionButtonPressed: (e)->
    item = e.model.item
    console.log item
    localStorage.setItem 'SESSION_TIMER_START', Date.now()
    @domHost.navigateToPage '#/manage-academic-session/session:' + item._id


  editSessionButtonPressed: (e)->
    item = e.model.item
    @domHost.navigateToPage '#/academic-session-editor/organization:' + @organization.idOnServer + '/session:' + item._id

  deleteSessionBtnClicked: (e)->
    item = e.model.item
    console.log item
    @domHost.showModalPrompt "Are you sure you want to Delete?", (answer)=>
      if answer  
        query = {
          apiKey: @user.apiKey
          payload:
            organizationId: @organization.idOnServer
            sessionId: item._id
        }
        @loadingCounter++
        @callApi '/delete-organization-attendance-session', query, (err, response)=>
          @loadingCounter--
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            console.log 'Session Deleted Successfully'
            @showAllSessionTapped()


  # ============== Manage Session Codes - end ==============




  # ============== Manage Group Codes - start ==============
  createGroupsPressed: (e)->
    @domHost.navigateToPage '#/manage-group-editor/organization:' + @organization.idOnServer + '/group:new'


  editGroupPressed: (e)->
    return unless e.model.item
    selectedGroup = e.model.item
    console.log 'editing group', selectedGroup
    @domHost.navigateToPage '#/manage-group-editor/organization:' + @organization.idOnServer + '/group:' + selectedGroup._id


  deleteGroupPressed: (e)->
    return unless e.model.item
    selectedGroup = e.model.item
    console.log 'deleting group', selectedGroup
    @_deleteGroupById selectedGroup._id


  _deleteGroupById: (groupId)->
    query = {
      apiKey: @user.apiKey
      payload:
        organizationId: @organization.idOnServer
        groupId: groupId
    }
    @loadingCounter++
    @callApi '/delete-organization-attendance-group', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_fetchGroups()
  

  showGroupsPressed: (e)->
    @_fetchGroups()


  _fetchGroups: ()->
    query = {
      apiKey: @user.apiKey
      payload:
        organizationId: @organization.idOnServer
    }
    @loadingCounter++
    @callApi '/get-organization-attendance-groups', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'groupList', response.data
        console.log 'group list', @groupList



  # ============== Manage Group Codes - end ==============


  # ============== All Attendee list - Codes Start ==============


  filterByDateClickedFromAttendeeList: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', (startDate.getTime())
    @set 'dateCreatedTo', (endDate.getTime())
    console.log @dateCreatedFrom, @dateCreatedTo

  filterByDateClearButtonClickedFromAttendeeList: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0

  showAllAttendeeTapped: ()->
    query = {
      apiKey: @user.apiKey
      payload: 
        organizationId: @organization.idOnServer
        filterBy: {
          fromDate:  @dateCreatedFrom
          toDate: @dateCreatedTo
        }
    }
    @loadingCounter++
    @callApi '/get-organization-attendees-stats', query, (err, response)=>
      @loadingCounter--
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        attendeeList = response.data
        @set 'attendeeList', attendeeList
        console.log 'Attendee List', @attendeeList


  # ============== All Attendee List - Codes End ==============


  resetButtonClicked: (e)->
    window.location.reload()

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()

    @domHost.addActivityLog 'attendance', 'session-print', 'add', {
      createdByUserSerial: @userSerial,
      createdDatetimeStamp: lib.datetime.now()
    }
  
  _getActivityLogs: ->
    activityLogs = app.db.find 'activity', ({type})=> 'attendance' is type
    console.log {activityLogs}
    @set 'activityLogs', activityLogs


}