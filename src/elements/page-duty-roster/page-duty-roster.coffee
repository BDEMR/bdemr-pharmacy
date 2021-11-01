Polymer {
  is: 'page-duty-roster'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    selectedRosterIndex:
      type: Number
      value: 0

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

    roles:
      type: Array
      value: []
    
    member:
      type: Object
      value: {}
    
    availableMembers:
      type: Array
      value: []

    
    selectedRole:
      type: String
      value: null

    
    matchingRosters:
      type: Array
      value: []
    
    activeItem:
      observer: '_activeItemChanged'
    
    availableRoles:
      type: Array
      value: []
    

  _addOnHolidayScheduleMemberChanged: (e)->
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
  
  _addMemberToSlot: (e)->
    return if !e.detail.value

    newMember = e.detail.value
    index = e.model.index
    selectedSlot = e.model.__data__.slot
    members = @matchingRosters[index].members

    # console.log {index, selectedSlot, members}

    # if members.length > 0

    #   # duplication check
    #   for member in members
    #     if (member.slotId is selectedSlot.id) and (member.id is newMember.id)
    #       # clear input
    #       @$$("#input-#{index}-#{selectedSlot.id}").value = null
    #       @domHost.showToast(member.name + " already Added to " + selectedSlot.name)
    #       return

    newMember.slotId = selectedSlot.id

    # push member
    { slotId, name, id } = newMember
    path = 'matchingRosters.' + index + '.members'
    @push path, { slotId, name, id }

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
      


  _selectedDateChanged: (date)->
    console.log date, @locations
    if @locations && @locations.length is 0
      return
    if date
      @_callGetRosterByDateApi date, (hasFound)=>
        if !hasFound
          @_resetRosterObject @selectedDate, @roster.list
          
    # else
    #   @set 'selectedDate', @_getDay @dayCount

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
  
  _getTodaysDateString:()->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

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
      startDate: @_getTodaysDateString()
      endDate: @_getTodaysDateString()
    }
  
  _checkOnHolidayStatus: (memberId, rosterDate) ->
    # console.log { memberId, rosterDate }
    rosterDate = (new Date rosterDate).setHours(0, 0, 0, 0)
    onHoliday = false

    for item in @onHoliday.list
      if item.id is memberId
        startDate = (new Date item.startDate).setHours(0, 0, 0, 0)
        endDate = (new Date item.endDate).setHours(23, 59, 59, 999)

        if startDate <= rosterDate <= endDate
          onHoliday = true
    
    if onHoliday
      return 'danger'
    else
      return ''
  
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
    @_addRoster()
  

  _addRoster: ()->
    roster =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      date: ''
      location: ''
      members: []

    @push 'matchingRosters', roster


  _deleteRoster: (e)->
    index = e.model.index
    roster = @matchingRosters[index]
    if roster._id
      @_callDeleteRosterApi roster._id, =>
        @splice 'matchingRosters', index, 1
    else
      @splice 'matchingRosters', index, 1
  
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
    console.log {item}
    # if (this.roster.list && this.roster.list.length > 0)
    #   this.$.list.selectedItems = [item] or []
    #   console.log this.$.list
    #   @set 'member', item
    #   @$$("#dialogShowMemberSlot").toggle()

  _callGetOrganizationDutyRoster:(cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: @filterBy

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
  
  saveButtonPressed: (e)->
    for roster in @matchingRosters
      @_callSetRosterByDateApi roster, => null

  _callSetRosterByDateApi: (data, cbfn)->
    data.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-set-duty-roster', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        message = response.data.message
        
        # if message is 'UPDATE_SUCCESS'
        #   @domHost.showToast 'Updated Succesfully!'
        
        # if message is 'INSERT_SUCCESS'
        #   @roster = response.data.roster
        #   @domHost.showToast 'Added Succesfully!'

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
  

  onFilterTapped: ()->
    @_callGetOrganizationDutyRoster => null
  
  navigatedIn: ->
    @set 'isLoaded', false
    @_getSlot @organization.idOnServer, =>
      @_getLocations @organization.idOnServer, =>
        @_getOnHoliday @organization.idOnServer, =>
          @_callGetOrganizationDutyRoster =>
            @_getOrganizatonRoles =>
              @_callGetOrganizationMemberByRoleApi =>
                @set 'isLoaded', true
            
          # @set 'selectedDate', @_getDay @dayCount
          # console.log @locations
} 