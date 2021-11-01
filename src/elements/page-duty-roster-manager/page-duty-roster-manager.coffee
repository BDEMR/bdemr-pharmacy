Polymer {
  is: 'page-duty-roster-manager'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    hasChildOrganization:
      type: Boolean
      value: false

    hideEditForm:
      type: Boolean
      value: true
    
    hideScheduleAreaForm:
      type: Boolean
      value: true

    EDIT_MODE:
      type: Boolean
      value: false

    selectedRosterIndex:
      type: Number
      value: 0
    
    organizationLoading:
      type: Boolean
      value: true
    
    selectedPageIndex:
      type: Number
      value: -1
      observer: '_selectedPageIndexChanged'

    filterBy:
      type: Object
      value:
        location: null
        role: null
        fromDate: null
        toDate: null

    dayCount:
      type: Number
      value: 0

    hideEditForm:
      type: Boolean
      value: true

    EDIT_MODE:
      type: Boolean
      value: false

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    roster:
      type: Object
      value: {}
    
    colors:
      type: Array
      value: ['default', 'red', 'pink', 'purple', 'deep-purple', 'indigo', 'blue', 'light-blue', 'cyan', 'teal', 'green', 'light-green', 'lime', 'yellow', 'amber', 'orange', 'deep-orange', 'brown', 'grey', 'blue-grey']
    
    locations:
      type: Object
      value: {}
    
    slots:
      type: Object
      value: {}
    
    onHoliday:
      type: Object
      value: {}
    
    holidayTypes:
      type: Array
      value: ['Sick leave', 'Casual leave', 'Earn leave', 'Complementary leave', 'Compassionate leave', 'Maternity leave', 'Paternity Leave', 'Leave of absense', 'Other']

    roles:
      type: Array
      value: []
    
    member:
      type: Object
      value: {}
    
    availableMembers:
      type: Array
      value: []
    
    dayRange:
      type: Array
      value: ['Last Week', 'Last Month', 'Today', 'Yesterday', 'Choose Dates']

    selectedRole:
      type: String
      value: null

    
    matchingRosters:
      type: Array
      value: []
    
    matchingReports:
      type: Array
      value: []
    
    activeItem:
      observer: '_activeItemChanged'
    
    availableRoles:
      type: Array
      value: []
    
    selectedDateRangeIndex:
      type: Number
      value: -1
      observer: '_selectedDateRangeIndexChanged'
    
    presentStatus:
      type: Array
      value: ['Present', 'Absent', 'Holiday']

    memberActiveItem:
      observer: '_openScheduleArea'
    
    copySlot:
      type: Object
      value: {}
    
    selectedFromSlotIndex:
      type: Number
      value: -1
      observer: '_onSelectedFromSlotItemChanged'
    
    selectedToSlotIndex:
      type: Number
      value: -1
      observer: '_onSelectedToSlotItemChanged'
  
  _onSelectedFromSlotItemChanged: (index)->
    return if index < 0
    slot = @slots.list[index]
    members = @roster.members
    filteredMembers = members.filter (member) => 
      if (member.slotId is slot.id)
        member.isSelected = true
        member.isConflicted = false
        return member

    @set 'copySlot.fromSlot', slot
    @set 'copySlot.members', filteredMembers
  
  _onSelectedToSlotItemChanged: (index)->
    return if index < 0
    slot = @slots.list[index]
    @set 'copySlot.toSlot', slot
  
  _onTapApplySlotCloneConfig: (e)->
    unless @copySlot.toSlot
      @domHost.showToast 'Please Select Which Slot you want to copy to!'
      return
    
    unless @copySlot.fromSlot
      @domHost.showToast 'Please Select Which slot you want to copy from!'
      return
      
    unless @copySlot.members.length > 0
      @domHost.showToast 'There is no member available to Clone!'
      return
    
    if @copySlot.fromSlot.id is @copySlot.toSlot.id
      @domHost.showToast 'You can not copy same slot members!'
      return

    members = []
    members = @copySlot.members
    for member in members
      delete member.isSelected
      delete member.isConflicted
      member.slotId = @copySlot.fromSlot.id
      @set 'roster.members', member
    

    @domHost.showToast 'Slot Cloned Successfully!'
    
     



  _closeScheduleArea: ()->
    @set 'hideScheduleAreaForm', true

  _openScheduleArea: (e)->
    return if !e
    console.log e
    @set 'hideScheduleAreaForm', false
    @set 'selectedMember', e
  
  _computeHolidayStatus: (holiday, holidayCount, rosterDate)->
    if holidayCount is 0
      return ''

    startDate = (new Date holiday.startDate).setHours(0, 0, 0, 0)
    endDate = (new Date holiday.endDate).setHours(23, 59, 59, 999)
    rosterDate = new Date rosterDate

    if startDate < rosterDate < endDate
      return "On Holiday"
  
  _computeHolidayType: (holiday, holidayCount, rosterDate)->
    if holidayCount is 0
      return ''

    startDate = (new Date holiday.startDate).setHours(0, 0, 0, 0)
    endDate = (new Date holiday.endDate).setHours(23, 59, 59, 999)
    rosterDate = new Date rosterDate

    if startDate < rosterDate < endDate
      return holiday.type
  
  _computeHolidayDates: (holiday, holidayCount, rosterDate)->
    if holidayCount is 0
      return ''

    startDate = (new Date holiday.startDate).setHours(0, 0, 0, 0)
    endDate = (new Date holiday.endDate).setHours(23, 59, 59, 999)
    rosterDate = new Date rosterDate

    if startDate < rosterDate < endDate
      return "#{holiday.startDate} to #{holiday.endDate}"

  _onDateValueChange: (e)->
    newDate = e.target.value
    index = e.model.index

    @matchingRosters[index].date = newDate
    
  _addOnHolidayScheduleMemberChanged: (e)->
    console.log e
    return if !e.detail.value
    member = e.detail.value
    index = e.model.index
    item = @onHoliday.list[index]

    item.name = member.name
    item.id = member.id
    item.role = member.role

    @set 'onHoliday.list.#{index}', item

  _getOrganizatonRoles: (cbfn)->
    # console.log @organization
    # extractRoleNamesOnly = @organization.roleList.map (item) => role.title
    # @set 'availableRoles', extractRoleNamesOnly

    # console.log @availableRoles

    data =
      organizationId: @organization.idOnServer
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-get-organization-roles', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        @set 'availableRoles', data
        cbfn()

  
  _getLocations: (organizationId, cbfn)->
    data =
      organizationId: @organization.idOnServer
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-get-organization-locations', data, (err, response)=>
      if response.hasError
        msg = response.error.message
        if msg is 'NO_DATA_FOUND'
          @_resetLocationObject()
          cbfn()
        else
          @domHost.showModalDialog response.error.message
      else
        data = response.data
        @set 'locations', data
        cbfn()
  
  _getSlot: (organizationId, cbfn)->
    @set 'slots', {}
    data =
      organizationId: @organization.idOnServer
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-get-organization-slot', data, (err, response)=>
      if response.hasError
        msg = response.error.message
        if msg is 'NO_DATA_FOUND'
          @_resetSlotObject()
          cbfn()
        else
          @domHost.showModalDialog response.error.message
      else
        data = response.data
        @set 'slots', data
        cbfn()
  
  _getOnHoliday: (organizationId, cbfn)->
    @set 'onHoliday', {}
    data =
      organizationId: @organization.idOnServer
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-get-organization-members-on-holiday', data, (err, response)=>
      if response.hasError
        msg = response.error.message
        if msg is 'NO_DATA_FOUND'
          @_resetOnHolidayObject()
          cbfn()
        else
          @domHost.showModalDialog response.error.message
      else
        data = response.data
        @set 'onHoliday', data
        cbfn()
  
  _setLocations: (organizationId, cbfn)->
    data =
      data: @locations
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-set-organization-locations', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.newData
        @set 'locations', data
        cbfn()
  
  _setSlot: (organizationId, cbfn)->
    data =
      data: @slots
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-set-organization-slot', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.newData
        @set 'slots', data
        cbfn()
  
  _setOnHoliday: (organizationId, cbfn)->
    data =
      data: @onHoliday
      apiKey: @user.apiKey
      
    @domHost.callApi '/bdemr-set-organization-members-on-holiday', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.newData
        @set 'onHoliday', data
        cbfn()

  generateRandomString : ( randomStringLength ) ->
    randomString = ''
    characterList = []
    for item in [0..25]
      characterList.push String.fromCharCode( 'a'.charCodeAt() + item )
    for item in [0..25]
      characterList.push String.fromCharCode( 'A'.charCodeAt() + item )
    for item in [0..9]
      characterList.push String.fromCharCode( '0'.charCodeAt() + item )

    len = characterList.length
    for item in [ 1..randomStringLength ]
      idx = ( Math.floor ( Math.random() * 10000363 ) ) % 10000019
      idx %= len
      randomString += characterList[ idx ]

    return randomString

  
  filterMemberBySlot: (list, slotId) ->
    return if !list

    filterList = []

    for item in list
      if item.slotId is slotId
        filterList.push item

    # filterList = list.map(item) => item.slotId is slotId

    # console.log filterList

    return filterList

  
  _checkNightDutyLastNight: (member, selectedRosterDate, cbfn)->
    date = new Date selectedRosterDate
    date = date.setHours(0, 0, 0, 0)
    date = new Date(date)
    yesterdayString = date.getFullYear() + "-" + (date.getMonth() + 1) + "-" + (date.getDate() - 1)

    rosters = []
    rosters = rosters.concat @matchingRosters

    yesterdayRoster = null
    for roster in rosters
      if (roster.role is member.role) and (roster.date is yesterdayString)
        yesterdayRoster = roster
        break
    
    console.log {yesterdayRoster}

    if yesterdayRoster is null
      return cbfn false
      
    if yesterdayRoster.members.length is 0
      return cbfn false
      
        
    members = yesterdayRoster.members
    memberObject = null
    for item in members
      if item.id is member.id
        memberObject = item
        break

    if !memberObject
      return cbfn false
      

    isThatNightSlot = false

    slots = @slots.list
    slotObject = null
    for slot in slots
      if slot.id is memberObject.slotId
        slotObject = slot
        break
    
    if !slotObject
      return cbfn false
      

    startTime = parseInt (slotObject.startTime.substring(0,1))
    endTime = parseInt (slotObject.endTime.substring(0,1))

    console.log { memberObject, slotObject, startTime, endTime }


    if startTime > endTime
      return cbfn true
      
    
    return cbfn false
    

  _checkIfMemberExistAlready: (members, newMember, cbfn)->
    memberExist = false
    for member in members
      if member.id is newMember.id
        memberExist = true
        break
    
    cbfn memberExist


  _addMemberToRoster: (e)->
    e.preventDefault()

    index = e.model.index
    value = e.detail.value
    return if !value

    { id, name, role, roleSerial } = value

    # todo :: check if member already exisit
    # todo :: check if member have duty last night

    @set "roster.members.#{index}.name", name
    @set "roster.members.#{index}.role", role

    @roster.members[index].roleSerial = roleSerial
    @roster.members[index].id = id
  

    

  _addMemberToSlot: (e)->
    return if !e.detail.value

    newMember = e.detail.value
    index = e.model.index
    selectedSlot = e.model.__data__.slot
    selectedRoster = @matchingRosters[index]
    members = selectedRoster.members 

    @_checkIfMemberExistAlready members, newMember, (memberExist)=>
      @_checkNightDutyLastNight newMember, selectedRoster.date, (hasDutyLastNight)=>

        if memberExist and hasDutyLastNight
          @domHost.showModalPrompt 'This Member Already exist & had a duty last night.', (answer)=>
            if answer2
              @addMemberToSlot index, selectedSlot, newMember
              return
        
        if memberExist
          @domHost.showModalPrompt 'This Member Already exist!', (answer)=>
            if answer
              @addMemberToSlot index, selectedSlot, newMember
              return
        
        if hasDutyLastNight
          @domHost.showModalPrompt 'This Member had a duty last Night!', (answer)=>
            if answer
              @addMemberToSlot index, selectedSlot, newMember
              return
        
        if !memberExist and !hasDutyLastNight
          @addMemberToSlot index, selectedSlot, newMember
          return
        
        @$$("#input-#{index}-#{selectedSlot.id}").value = null
        

          
    
    

  addMemberToSlot: ( index, selectedSlot, newMember)->

    newMember.slotId = selectedSlot.id

    # push member
    { slotId, name, id } = newMember
    path = 'matchingRosters.' + index + '.members'

    isAbsent = false
    @push path, { slotId, name, id, isAbsent }

    # clear input
    @$$("#input-#{index}-#{selectedSlot.id}").value = null


  _removeMemberFromSlot: (e)->

    member = e.model.__data__.member
    index = e.path[6].__data__.index # hack. roster index
    e.stopPropagation()

    rosterIndex = index

    console.log {index, rosterIndex}

    return if rosterIndex < 0

    members = @matchingRosters[rosterIndex].members

    memberIndex = 0
    for item, index in members
      if (item.id is member.id) and (item.slotId is member.slotId)
        memberIndex = index
        break

    path = 'matchingRosters.' + rosterIndex + '.members'

    @splice path, memberIndex, 1
  
  _toggleAbsentMemberFromSlot: (e)->
    member = e.model.__data__.member
    index = e.path[6].__data__.index # hack. roster index
    e.stopPropagation()

    rosterIndex = index

    console.log {index, rosterIndex}

    return if rosterIndex < 0

    roster = @matchingRosters[rosterIndex]

    members = []
    members = members.concat roster.members

    memberIndex = 0
    for item, index in members
      if (item.id is member.id) and (item.slotId is member.slotId)
        memberIndex = index
        break

    path = 'matchingRosters.' + rosterIndex + '.members.' + memberIndex

    member = members[memberIndex]

    member.isAbsent = !member.isAbsent
    
    @set path, member

    roster.members[memberIndex] = member

    @_callSetRosterByDateApi roster, =>
      # @_callGetOrganizationDutyRoster => null
 
  _changeValueFromSelection:(e)->
    return if !e.detail.value
      
    member = e.model.__data__.item
    value = e.detail.value.name
    index = e.model.__data__.index
    id = e.model._nodes[0].id
    key = (id.split('-'))[0]
    member[key] = value

    for item, index in @roster.list
      if item.memberId is member.memberId
        @roster.list[index] = member
        break
    
    # update color of cell
    color = @_getColor value
    label = e.model._nodes[2]
    oldToken = label.classList[1]
    label.classList.replace oldToken, color


  _changeValue: (e)->
    return if !e.target.value

    member = e.model.__data__.item
    value = e.target.value
    id = e.target.id
    key = (id.split('-'))[0]
    member[key] = value

    for item, index in @roster.list
      if item.memberId is member.memberId
        @roster.list[index] = member
        break
    
    # update color of cell
    color = @_getColor value
    label = e.model._nodes[2]
    oldToken = label.classList[1]
    label.classList.replace oldToken, color
      


  # _selectedDateChanged: (date)->
  #   console.log date, @locations
  #   if @locations && @locations.length is 0
  #     return
  #   if date
  #     @_callGetRosterByDateApi date, (hasFound)=>
  #       if !hasFound
  #         @_resetRosterObject @selectedDate, @roster.list
          
  #   # else
  #   #   @set 'selectedDate', @_getDay @dayCount

  _getLocationName: (locationId)->
    # console.log {locationId}
    # if locationId
    #   for item in @locations
    #     if item.id is locationId
    #       return item.value
    #   return ''
    # return ''
  
  _getColor: (value)->
    return 'default' if !value
    return 'default' if !@locations.list 
    for item in @locations.list
      if item.name is value
        return item.color

    return 'default'
  

  _addLocation: ()->
    # console.log {@locations}
    @push 'locations.list', {
      name: ''
      color: ''
    }
  
  _deleteLocation: (e)->
    index = e.model.index
    @splice 'locations.list', index, 1
  
  _addSlot: ()->
    # console.log {@locations}
    @push 'slots.list', {
      id: @slots.list.length
      name: ''
      startTime: '06:00'
      endTime: '07:00'
    }
  
  _getDateString:(dayCount)->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

    day = parseInt day
    day = day + dayCount

    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day

    return [year, month, day].join('-')
  
  _addOnHolidaySchedule: ()->
    console.log {@onHoliday}
    @push 'onHoliday.list', {
      name: ''
      id: ''
      role: ''
      startDate: @_getDateString 0
      endDate: @_getDateString 0
      note: ''
      type: ''
      isAccepted: false
    }

  _isAbsent: (isAbsent)->
    return 'danger' if isAbsent
  
  _checkIsMemberOnHoliday: (memberId, rosterDate) ->
    rosterDate = new Date rosterDate
    onHoliday = false

    return onHoliday if @onHoliday.list.length is 0

    for item in @onHoliday.list
      if item.id is memberId
        startDate = (new Date item.startDate).setHours(0, 0, 0, 0)
        endDate = (new Date item.endDate).setHours(23, 59, 59, 999)

        if startDate < rosterDate < endDate
          onHoliday = true
    
    return onHoliday
  
  _computeOnHolidayType: (memberId, rosterDate) ->
    rosterDate = new Date rosterDate
    type = ''

    return type if @onHoliday.list.length is 0

    for item in @onHoliday.list
      if item.id is memberId
        startDate = (new Date item.startDate).setHours(0, 0, 0, 0)
        endDate = (new Date item.endDate).setHours(23, 59, 59, 999)

        if startDate < rosterDate < endDate
          type = item.type
    
    return type
  
  _computeOnHolidayDates: (memberId, rosterDate) ->
    rosterDate = new Date rosterDate
    dates = ''

    return dates if @onHoliday.list.length is 0

    for item in @onHoliday.list
      if item.id is memberId
        startDate = (new Date item.startDate).setHours(0, 0, 0, 0)
        endDate = (new Date item.endDate).setHours(23, 59, 59, 999)

        if startDate < rosterDate < endDate
          dates = "#{item.startDate} - #{item.endDate}"
    
    return dates
  
  _deleteSlot: (e)->
    index = e.model.index
    @splice 'slots.list', index, 1
  
  _deleteOnHoliday: (e)->
    index = e.model.index
    @splice 'onHoliday.list', index, 1
  
  _onLocationColorChange: (e)->
    index = e.model.index
    console.log {index}

  _saveLocation: ()->
    @_setLocations @organization.idOnServer, =>
      @domHost.showToast "Location Saved!"
      @$$("#dialogLocation").close()

  _saveSlot: ()->
    
    @_setSlot @organization.idOnServer, =>
      @domHost.showToast "Slots Saved!"
      @$$("#dialogSlot").close()
      # @window.location.reload()
  
  _saveOnHoliday: ()->
    
    @_setOnHoliday @organization.idOnServer, =>
      @domHost.showToast "Saved!"
      @$$("#dialogOnHoliday").close()
      # @window.location.reload()
  
  
  _saveMemberSlot: ()->
    @$$("#dialogShowMemberSlot").toggle()
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _validateMemberScheduelForm: ()->

    isRole = @$$("#inputRole").validate()
    isInputName = @$$("#inputName").validate()

    if isRole and isInputName
      return true

    return false
  

  addRosterBtnPressed: ()->
    @_clearRosterForm()
    @set 'hideEditForm', false
  

  _removeMember: (e)->
    index = e.model.index
    @splice 'roster.members', index, 1
  
  _onTapShowCloneASlotDialog: ()->
    @$$("#dialogCopySlotMembers").toggle()

  _addMember: ()->
    @set 'slotFilterString', ''
    @unshift 'roster.members', {
      slotId: -1
      slotName: ''
      name: ''
      id: ''
      isAbsent: true
      isLate: false
      lateInMinutes: 0
      location: ''
      roleSerial: ''
      role: ''
    }
  
  _onTapDuplicateMember: (e)->
    index = e.model.index
    member = @roster.members[index]
    @set 'slotFilterString', ''
    
    @push 'roster.members', {
      slotId: member.slotId
      slotName: member.slotName
      name: ''
      id: ''
      isAbsent: true
      location: member.location
      roleSerial: ''
      role: ''
    }




  _resetRosterObject: ()->
    roster =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      date: @_getDay 0
      members: []

    @set 'roster', roster
  
    console.log @roster

    @set 'EDIT_MODE', false


  _deleteRoster: (e)->


    if @roster._id
      @_callDeleteRosterApi @roster._id, =>
        @splice 'matchingRosters', @ARBITARY_INDEX, 1
        @_closeRosterEditForm()
    else
      @splice 'matchingRosters', @ARBITARY_INDEX, 1
  
  _callDeleteRosterApi: (rosterId, cbfn)->
    data = 
      apiKey: @user.apiKey
      rosterId: rosterId
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-delete-duty-roster', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        console.log response.error.message
      else
        message = response.data.message
        if message is "DELETE_SUCCESS"
          @domHost.showToast 'Roster has been Deleted!'

        cbfn()

  # _onSelctedSlotItemChanged: (e)->
  #   slotName = e.detail.value
  #   index = e.model.index
  #   console.log slotName, index
  #   @set "roster.members.#{index}.slotName", slotName
  
  _getFixedSlots:()->
    list = []
    i = 0
    while i < 24
      list.push {
        id: i + 1
        name: 'Slot ' + (i + 1)
        startTime: '00:00'
        endTime: '00:00'
      }
      i++
    return list
  
  _resetSlotObject: ()->
    slots =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      list: []

    @set 'slots', slots

  _resetOnHolidayObject: ()->
    onHoliday =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      list: []

    @set 'onHoliday', onHoliday
  
  _resetLocationObject: ()->
    locations =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      list: []

    @set 'locations', locations

  _makeNewMemberSlotObject: (member)->

    return {
      name: member.name
      memberId: member.memberId
      isPublic: true
      role: member.role
      roleSerial: member.roleSerial
      hour01: ''
      hour02: ''
      hour03: ''
      hour04: ''
      hour05: ''
      hour06: ''
      hour07: ''
      hour08: ''
      hour09: ''
      hour10: ''
      hour11: ''
      hour12: ''
      hour13: ''
      hour14: ''
      hour15: ''
      hour16: ''
      hour17: ''
      hour18: ''
      hour19: ''
      hour20: ''
      hour21: ''
      hour22: ''
      hour23: ''
      hour00: ''
    }
 
  _activeItemChanged: (item)->
    copyItem = lib.util.deepCopy item

    if copyItem
      # @set 'ARBITARY_INDEX', index
      @set 'hideEditForm', false
      @set 'slotFilterString', ''
      @set 'EDIT_MODE', true
      @set 'roster', copyItem
    else
      @set 'hideEditForm', true

  _callGetOrganizationDutyRoster:(cbfn)->
    data =
      apiKey: @user.apiKey
      organizationIdList: []
      filterBy: @filterBy

    if @organization.idOnServer is 'all-organization-include-parent'
      for item in @childOrganizationList
        data.organizationIdList.push item.value
    else
      data.organizationIdList.push @organization.idOnServer


    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-duty-roster', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        msg = response.error.message
        if msg is 'NO_DATA_FOUND'
          # @_addRoster()
          @set 'matchingRosters', []
          cbfn()
      else
        data = response.data
        @set 'matchingRosters', data
        cbfn()
  
  _callGetOrganizationMemberByRoleApi:(cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-member-by-role', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'availableMembers', response.data.members
        cbfn()
  
  _callGetMemberDutyReportsApi:(cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: @filterBy
  
    console.log data

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-member-duty-reports', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        message = response.error.message
        if message is 'NO_DATA_FOUND'
          @domHost.showModalDialog "No Report Found. Please Try Different Dates!"
        else
          @domHost.showModalDialog response.error.message
        @set 'matchingReports', []
      else
        @set 'matchingReports', response.data.filteredMembers

        cbfn()
  
  _filterAvailableMembersByRole: (roleName, rosterMembers, slotId)->

    rosterMembers = if rosterMembers then rosterMembers else []

    # filter by roleName
    allMembers = @availableMembers
    filterByRoleName = allMembers.filter (item) => item.role is roleName

    # filter roster members by slot id
    filterRosterMembersBySlot = rosterMembers.filter (item) => item.slotId is slotId
    

    availableMembers = filterByRoleName.filter (member) =>
      hasFound = false

      for item in filterRosterMembersBySlot
        if item.id is member.id
          hasFound = true

      return member if !hasFound
      
    
    # console.log {filterByRoleName, filterRosterMembersBySlot, availableMembers}
    
    

    return availableMembers
  
  _onTapCloneRoster: ()->
    roster =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      date: @roster.date
      members: @roster.members

    @_upsertRoster roster
  
  _onTapAddOrUpdateRoster: ()->
    @_upsertRoster @roster

  _upsertRoster: (roster)->
    @_callSetRosterByDateApi roster, =>
      @_closeRosterEditForm()
      @_callGetOrganizationDutyRoster => null
  
  
  saveButtonPressed: (e)->
    rosters = []
    rosters = @matchingRosters


    console.log {rosters}
    for roster in rosters
      @_callSetRosterByDateApi roster, => null

  _callSetRosterByDateApi: (data, cbfn)->
    console.log data
    date = ''
    date = new Date data.date
    date = date.setHours(0, 0, 0, 0)
    
    data.date = date

    data.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-set-duty-roster', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        message = response.error.message
        if message is 'DUPLICATE_ROSTER_DATE_FOUND'
          @domHost.showModalDialog "Warning! You can't create multiple roster at same date. Tip: Change Roster Date and Try again."
      else
        message = response.data.message
        
        if message is 'UPDATE_SUCCESS'
          @domHost.showToast 'Updated Succesfully!'
        
        if message is 'INSERT_SUCCESS'
          @roster = response.data.roster
          @domHost.showToast 'Added Succesfully!'

        cbfn()
  
  _showLocationDialog: ()->
    console.log {@locations}
    @$$("#dialogLocation").toggle()
    @$$("#dialogLocation").center()
  
  _showSlotDialog: ()->
    @$$("#dialogSlot").toggle()
    @$$("#dialogSlot").center()
  
  _showOnHolidayDialog: ()->
    @$$("#dialogOnHoliday").toggle()
  
  _getDay: (dayCount)->
    console.log {dayCount}

    # ms = lib.datetime.now() + (86400000 * count)

    day = new Date(new Date().setDate(new Date().getDate() + dayCount))
    # day = new Date(date)
    
    dd = day.getDate()
    mm = day.getMonth() + 1
    yyyy = day.getFullYear()

    if dd < 10
      dd = '0'+ dd
    if mm < 10
      mm = '0' + mm

    date = yyyy + '-' + mm + '-'+ dd

    return date

  nextDateBtnPressed: ()->
    dayCount = @dayCount + 1
    selectedDate = @_getDay dayCount
    @set 'selectedDate', selectedDate
    @set 'dayCount', dayCount
  
  prevDateBtnPressed: ()->
    dayCount = @dayCount - 1
    selectedDate = @_getDay dayCount
    @set 'selectedDate', selectedDate
    @set 'dayCount', dayCount
  
  _onCellContentChange: (e)->
    console.log e
  
  _formatReportStatistics: ()->
    reportStats = [
      {
        label: 'Members'
        count: 0
      }
      {
        label: 'Slots'
        count: 0
      }
      {
        label: 'Present'
        count: 0
      }
      {
        label: 'Absent'
        count: 0
      }
    ]

    list = @matchingReports
    reportStats[0].count = list.length
    for item in list
      reportStats[1].count += (item.absentCount + item.presentCount)
      reportStats[2].count += item.presentCount
      reportStats[3].count += item.absentCount
    
    @set 'reportStats', reportStats
      


  
  _getReports: ()->
    unless @organization.idOnServer
      @domHost.showToast 'Please Select Organization First!'
      return
      
    unless @filterBy.fromDate or @filterBy.toDate
      @domHost.showToast 'Please Select a Date Range!'
      return

    @_callGetMemberDutyReportsApi =>
      @_formatReportStatistics()
  

  onFilterTapped: ()->
    if @selectedPageIndex is 0
      @_callGetOrganizationDutyRoster => null
    
    if @selectedPageIndex is 1
      @_getReports()
  
  # rosterSlotSelected: (e)->
  #   return if !e.detail.value
  #   slot = e.detail.value
  #   @set 'rosterSelectedSlot', slot
  #   members = []
  #   members = @roster.members
  #   filterMembers = members.filter (member) => member.slotId is slot.id
  #   @set 'filterMembers', filterMembers
  
  organizationSelected: (e)->
    console.log e
    @set 'isLoaded', false
    @set 'matchingRosters', []
    @set 'matchingReports', []

    if !@organization
      @organization = (app.db.find 'organization')[0]
    
    if !@user
      @user = (app.db.find 'user')[0]

    if @organization.idOnServer
      @_getSlot @organization.idOnServer, =>
        @_getLocations @organization.idOnServer, =>
          @_getOnHoliday @organization.idOnServer, =>
              @_getOrganizatonRoles =>
                @_callGetOrganizationMemberByRoleApi =>
                  @set 'isLoaded', true
  
  _loadChildOrganizationList: (organizationIdentifier, cbfn) ->
    query =
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    @set 'organizationLoading', true
    @callApi '/bdemr--get-child-organization-list', query, (err, response) =>
      @set 'organizationLoading', false
      organizationList = response.data
      @set 'childOrganizationCounter', organizationList.length
      organizationSelectorComboBox = @$$("#organizationSelector")
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({label: 'All', value: 'all-organization-include-parent'})
        mappedValue.unshift({label: @organization.name, value: @organization.idOnServer})
        @set('childOrganizationList', mappedValue)
        organizationSelectorComboBox.value = @organization.idOnServer

        @set 'hasChildOrganization', true
      else
        organizationSelectorComboBox.items = [{ label: @organization.name, value: @organization.idOnServer }]
        organizationSelectorComboBox.value = @organization.idOnServer

        @set 'hasChildOrganization', false
      
      cbfn()
  
  _showNewRosterForm: ()->
    @_clearProduct()
    @set 'hideEditForm', false
  
  _closeRosterEditForm: ()->
    hideEditForm = @hideEditForm
    @set 'hideEditForm', !hideEditForm
  
  _clearRosterForm: ()->
    @_resetRosterObject()
  
  _computeTotalCount: (slotId, members)->
    count = 0
    members.filter (item) =>
      count++ if item.slotId is slotId
    return count
  
  _computeAbsentCount: (slotId, members)->
    count = 0
    members.filter (item) =>
      if item.slotId is slotId
        count++ if item.isAbsent
    return count
  
  _computePresentCount: (slotId, members)->
    count = 0
    members.filter (item) =>
      if item.slotId is slotId
        count++ if !item.isAbsent
    return count


  _computeOrganizationName: (organizationId)->
    if !@childOrganizationList
      return @organization.name
    for item in @childOrganizationList
      return item.label if item.value is organizationId
  
  _selectedDateRangeIndexChanged: (selectedPageIndex)->
    
    if selectedPageIndex is 0

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'filterBy.fromDate', thisWeekStart
      @set 'filterBy.toDate', thisWeekEnd

    if selectedPageIndex is 1

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'filterBy.fromDate', last30Days
      @set 'filterBy.toDate', today
    
    # Today
    if selectedPageIndex is 2
      today = new Date()
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'filterBy.fromDate', todayStart
      @set 'filterBy.toDate', todayEnd
    
    # yesterday
    if selectedPageIndex is 3
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'filterBy.fromDate', yesterdayStart
      @set 'filterBy.toDate', yesterdayEnd
    
    if selectedPageIndex is 4
      return

    if @organization.idOnServer

      if @selectedPageIndex is 0
        @_callGetOrganizationDutyRoster => null
      
      if @selectedPageIndex is 1
        @_getReports()

  _selectedPageIndexChanged: (selectedPageIndex)->
    if @selectedPageIndex is 0
      @_callGetOrganizationDutyRoster => null
    
    if @selectedPageIndex is 1
      @_getReports()
      
  
  editorHasOpened: (hasOpened)->
    # console.log hasOpened
    if hasOpened
      return ''
    return 'open'
  
  _onTapShowCloneRosterDialog: ()->
    @$$("#dialogCloneRoster").toggle()
    @roster
  
  _getSlotNameById: (slotId)->
    console.log slotId
    if slotId is 'undefined'
      return
    slots = @slots.list
    for slot in slots
      if slot.id is slotId
        return "(#{slot.name})"
    return ''
  
  navigatedIn: ->
    @_loadChildOrganizationList @organization.idOnServer, =>
      @set 'selectedDateRangeIndex', 0
      @set 'selectedPageIndex', 0

      console.log @organization

} 