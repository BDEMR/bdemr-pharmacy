""" My-Attendance-Session
- user can view all upcoming sessions and view/join them
- in the statistics tab, summary statistics show the summary of sessions in terms of type and completed/pending ones
- session statistics can be filtered using types

"""

Polymer {
  
  is: 'page-my-attendance-sessions'

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
    
    myAttendanceSessions:
      type: Array
      value: -> []

    myUpcomingAttendanceSessions:
      type: Array
      value: -> []
    
    myCompletedAttendanceSessions:
      type: Array
      value: -> []

    mySessionTypes:
      type: Array
      value: [
        'General Lecture',
        'Special Lecture',
        'Additional Lecture',
        'Demonstration',
        'Outdoor Placement',
        'Operation Theatre Placement',
        'Community Placement',
        'Morning Ward Placement',
        'Evening Ward Placement',
        'Emergency Placement'
      ]

    selectedPage:
      type: Number
      value: 0

    loadingCounter:
      type: Number
      value: -> 0

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    minutesBeforeJoin:
      type: Number
      value: 1
    
    mySummarySessionStatistics:
      type: Object
      value: {}
    
    rawSessionStatistics:
      type: Array
      value: []
    
    filteredSessionStatistics:
      type: Array
      value: []

    presenterFilteringString:
      type: String
      value: ''

    subjectFilteringString:
      type: String
      value: ''

    
  observers: [
    'filterPresenterSubject(presenterFilteringString, subjectFilteringString)'
  ]


  filterPresenterSubject: (presenterFilteringString, subjectFilteringString)->
    lib.util.delay 300, ()=>
      tempPresenterName = if presenterFilteringString then presenterFilteringString.trim().toLowerCase() else ''
      tempSubject = if subjectFilteringString then subjectFilteringString.trim().toLowerCase() else ''

      tempList = @rawSessionStatistics.filter (item)=>
        presenterFlag = subjectFlag = false
        if (item.presenter.name) and ((tempPresenterName is '') or (tempPresenterName isnt '' and item.presenter.name.toLowerCase().includes tempPresenterName))
          presenterFlag = true

        if (item.subject) and ((tempSubject is '') or (tempSubject isnt '' and item.subject.toLowerCase().includes tempSubject)) 
          subjectFlag = true

        return presenterFlag and subjectFlag
      
      @set 'filteredSessionStatistics', tempList
      console.log 'filtered list', @filteredSessionStatistics
    


  
  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer
      @fetchMyAttendanceSessions()
      @fetchMyAttendanceSessionStatistics @sessionFilteringType, @sessionStatisticsFrom, @sessionStatisticsTo, true
      @loadingCounter--

  navigatedOut: ->
    @dateCreatedFrom = ''
    @dateCreatedTo = ''
    @selectedOrganizationId = ''

  getBoolean: (data)-> if data then true else false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  _loadOrganization: (cbfn)->
    
    @loadingCounter++
    data = { 
      apiKey: @user.apiKey
      idList: [ @organization.idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn()


  resetButtonClicked: -> @domHost.reloadPage()


  organizationSelected: (e)->
    organizationId = e.detail.value
    @set('selectedOrganizationId', organizationId)


  _loadChildOrganizationList: (organizationIdentifier)-> 
    @loadingCounter++
    query = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    }
    @callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      @loadingCounter--
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        @set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = @$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: @organization.name, value: @organization.idOnServer }]
        organizationSelectorComboBox.value = @organization.idOnServer


  joinAttendanceSession: (e)->
    session = e.model.item
    console.log 'session ', session
    # TODO

  viewAttendanceSession: (e)->
    session = e.model.item
    console.log 'session ', session
    @domHost.navigateToPage '#/view-academic-session/session:' + session._id 


  _checkUserAccess: (accessId)->
    # console.log 'accessId', accessId
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return false

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true

  
  resetButtonClicked: -> return @domHost.reloadPage()
  
  fetchMyAttendanceSessions: ()->
    query = {
      apiKey: @user.apiKey
    }

    @loadingCounter += 1
    @callApi '/get-my-attendance-sessions', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loadingCounter -= 1
      else
        @loadingCounter -= 1
        allSessions = response.data

        @set 'myUpcomingAttendanceSessions',  allSessions.filter (session)=>
          return session.date > Date.now()

        @set 'myCompletedAttendanceSessions', allSessions.filter (session)=>
          currentAttendee = session.attendees.find (attendee)=>
            return attendee.attendeeId is @user.idOnServer
          unless currentAttendee
            return false
          return session.date < Date.now() and currentAttendee.isPresent

        @set 'myAttendanceSessions', allSessions
        console.log 'all sessions', allSessions
        console.log 'upcoming sessions', @myUpcomingAttendanceSessions
        console.log 'completed sessions', @myCompletedAttendanceSessions


  fetchMyAttendanceSessionStatistics: (sessionType, dateFrom, dateTo, isSummary=false)->
    query = {
      apiKey: @user.apiKey
      payload: {
        filterBy: {
          fromDate: dateFrom or '',
          toDate: dateTo or '',
          type: sessionType or ''
        }
      }
    }

    @loadingCounter += 1
    @callApi '/get-my-sessions-stats', query, (err, response)=>
      @loadingCounter -= 1
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        stat = response.data
        console.log('raw stat', stat)
        if isSummary
          tempSummaryStat = {}
          stat.list.forEach (sessionType)=>
            unless tempSummaryStat[sessionType.type]
              tempSummaryStat[sessionType.type] = {present: 0, absent: 0}
            if sessionType.isPresent
              tempSummaryStat[sessionType.type].present += 1
            else
              tempSummaryStat[sessionType.type].absent += 1

          typeStats = Object.keys(tempSummaryStat).map (typeStat)=>
            return {type: typeStat, presentCount: tempSummaryStat[typeStat].present, absentCount: tempSummaryStat[typeStat].absent}

          @set 'mySummarySessionStatistics.stats', typeStats
          @set 'mySummarySessionStatistics.totalCount', stat.totalCount
          @set 'mySummarySessionStatistics.totalPresentCount', stat.totalPresentCount
          
        else
          @set 'rawSessionStatistics', stat.list
          @set 'filteredSessionStatistics', stat.list
          console.log 'filtered session statistics', @filteredSessionStatistics


        
  _getSessionAttendeeStatus: (session)->
    return unless session
    if session.date > Date.now()
      return 'Upcoming'
    else if session.date < Date.now() and session.isPresent
      return 'Completed'
    else 
      return 'Absent'

  createUpcomingDummyData: ()->
    dummyData = [1,2,3,4,5].map (item)=>
      return {
        title: "title-#{item}"
        type: "type-#{item}"
        startAt: new Date()
        endAt: (new Date()).setMinutes 50 #(new Date()).setMinutes (item+36)
      }
    @set 'myUpcomingAttendanceSessions', dummyData
    console.log 'upcoming session', @myUpcomingAttendanceSessions
  
  createCompletedDummyData: ()->
    dummyData = [1,2,3,4,5].map (item)=>
      return {
        title: "title-#{item}"
        type: "type-#{item}"
        startAt: new Date()
        endAt: (new Date()).setMinutes 50 #(new Date()).setMinutes (item+36)
      }
    @set 'myCompletedAttendanceSessions', dummyData
    console.log 'completed session', @myCompletedAttendanceSessions


  isJoinVisible: (session)->
    return unless session
    currentMills = Date.now()
    sessionStartMills = session.startTime
    sessionEndMills = session.endTime
    return (sessionEndMills > currentMills) and ((currentMills + @minutesBeforeJoin*60*1000) >= sessionStartMills)
    # return sessionEndMills > currentMills


  filterByDateClickedSessionStat: (e)->
    startDate = new Date(e.detail.startDate)
    startDate.setHours(0,0,0,0)
    endDate = new Date(e.detail.endDate)
    endDate.setHours(23,59,59,999)
    @set 'sessionStatisticsFrom', (startDate.getTime())
    @set 'sessionStatisticsTo', (endDate.getTime())

  filterByDateClearButtonClickedSessionStat: ()->
    @sessionStatisticsFrom = ''
    @sessionStatisticsTo = ''


  filterStatisticsPressed: (e)->
    @fetchMyAttendanceSessionStatistics @sessionFilteringType, @sessionStatisticsFrom, @sessionStatisticsTo

}
