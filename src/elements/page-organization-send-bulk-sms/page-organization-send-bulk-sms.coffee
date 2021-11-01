
Polymer {

  is: 'page-organization-send-bulk-sms'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    pageIndex:
      type: Number
      value: 0
    
    logs:
      type: Array
      value: []

    newSmsInput:
      type: String
      value: ''

    user:
      type: Object
      notify: true
      value: (app.db.find 'user')[0]

    selectedPage: 
      type: Number
      value: 0
    
    selectedGroupIndex:
      type: Number
      value: -1
      observer: '_observeSelectedGroupIndexChanged'
    
    groupList:
      type: Array
      value: []

    organization:
      type: Object
      value: (app.db.find 'organization')[0]

    audienceList:
      type: Array
      value: []
    
    selectedAudienceList:
      type: Array
      value: []
    
    audience:
      type: Object
      value: {}
    
    filterBy:
      type: Object
      value: {
        fromDate: null
        toDate: null
      }
  
  _observeSelectedGroupIndexChanged: (index)->
    console.log index
    return if index is -1
    if index is 0
      @set "selectedAudienceList", @audienceList
      console.log {@selectedAudienceList}
      return

    selectedGroupName = @groupList[index]
    console.log @audienceList
    list = @audienceList.filter (item) => item.group is selectedGroupName
    @set "selectedAudienceList", list


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _resetAudienceObject: ()->
    @audience =
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      lastModifiedByUserId: @user.idOnServer
      createdByUserId: @user.idOnServer
      organizationId: @organization.idOnServer
      list: []
      groups: []
      
  _getOrganizationAudienceList: () ->
    data =  
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
    @domHost.toggleModalLoader 'Please wait...'
    @callApi '/bdemr-get-organization-audience-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @_resetAudienceObject()
        @set "audienceList", []
      else
        audience = response.data
        @audienceList = audience.list
        @audience = audience
        if audience.groups.length > 0
          @groupList = lib.array.unique audience.groups
  
  _getBulkSMSLogs: ->
    data =  
      apiKey: @user.apiKey
      filterBy: @filterBy

    @domHost.toggleModalLoader 'Please wait...'
    @callApi '/bdemr-get-bulk-sms-logs', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set "logs", []
      else
        @set "logs", response.data


  onFilterTapped: ->
    @_getBulkSMSLogs()

  navigatedIn: ->
    @_getOrganizationAudienceList => null

  _callUpdateAudienceListApi: (audienceList, cbfn)->
    @audience.list = audienceList
    @audience.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @callApi '/bdemr-organization-set-audience-list', @audience, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()
    
  addAudiencesTapped: (e)->
    return if !@newAudienceRawInput
    reg = new RegExp('/^[0-9]*$/')
    list = @newAudienceRawInput.split('\n')
    list = lib.array.unique list
    newAudienceList = []
    list = list.filter (phoneNumber) => phoneNumber.length is 11
      .forEach (phoneNumber, index) =>
        # console.log phoneNumber.match(/^[0-9]+$/)
        # if phoneNumber.match(/^[0-9]+$/)
        newAudienceList.push { phone: phoneNumber, name: '', group: '', isSelected: false }
    
    audienceList = @audienceList.concat newAudienceList

    # @set "audienceList", newAudienceList
    
    @newAudienceRawInput = ""

    @_callUpdateAudienceListApi audienceList, => @_getOrganizationAudienceList()
  
  _someItemHasBeenSelected: (audienceList)->
    list = audienceList.filter (item) => item.isSelected
    return false if list.length is 0
    return true
  
  _clearSelection: (e)->
    audienceList = []
    audienceList = audienceList.concat @audienceList
    for item, index in audienceList
      audienceList[index].isSelected = false

    @set "audienceList", audienceList
  
  _selectAll: (e)->
    # e.preventDefault()
    audienceList = []
    for item, index in @audienceList
      item.isSelected = true
      audienceList.push item

    @set "audienceList", []
    

    console.log audienceList

    @set "audienceList", audienceList


  _deleteAll: (e)->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        audienceList = []
        @_callUpdateAudienceListApi audienceList, => @set "audienceList", []

  deleteSelectedAudiences: (e)->
    unless @_someItemHasBeenSelected @audienceList
      return @domHost.showToast "Please select first!"
      
    audienceList = []
    audienceList = audienceList.concat @audienceList
    audienceList = audienceList.filter (item) => !item.isSelected

    @_callUpdateAudienceListApi audienceList, => @set "audienceList", audienceList
  
  _upsertGroupName: (name)->
    groupNames = @audience.groups
    groupNames.push name
    uniqueGroupNames = lib.array.unique @audience.groups
    console.log {uniqueGroupNames}
    @set "audience.groups", uniqueGroupNames
  
  _updateAudianceListByGroupName: (groupName, cbfn)->
    groupName = groupName.toLowerCase()
    for item, index in @audienceList
      if item.isSelected
        item.group = groupName
        @set "audienceList.#{index}", item

    # @set "audienceList", updatedList
    # @_upsertGroupName groupName
    @_clearSelection()

    cbfn()

  
  addSelectedAudiencesToGroup:(e)->
    unless @_someItemHasBeenSelected @audienceList
      return @domHost.showToast "Please select first!"
    
    @domHost.showModalInput "Please enter group Name", "", (answer)=>
      if answer.length > 1
        @_updateAudianceListByGroupName answer, =>
          @_callUpdateAudienceListApi @audienceList, => null
      else
        @domHost.showToast "Invalid/Cancelled Group Name!"
  

  _togglePhoneNumberSelection: (e)->
    { index } = e.model
    { checked } = e.target
    @audienceList[index].isSelected = checked

    console.log @audienceList[index]


  sendSmsTapped: ->
    @responseList = []
    count = 0
    done = 0
    hasShownError = false

    it1 = new lib.util.Iterator @selectedAudienceList

    count = @selectedAudienceList.length

    it1.forEach (next, index, audience)=>
      data = { 
        apiKey: @user.apiKey
        organizationId: @organization.idOnServer
        receiverUserId: null, 
        phoneNumber: audience.phone ,
        smsBody: @newSmsInput
        organizationName: ''
      }
      @callApi '/send-individual-sms', data, (err, response)=>
        if response.hasError
          # if !hasShownError
          #   @domHost.showModalDialog response.error.message
          #   hasShownError = true
          @domHost.showToast "Failed #{audience.phone}"
          # @push 'responseList', "FAILED #{audience.phone} - #{response.error.message}"

          @push 'responseList', "FAILED #{audience.phone}"
          done += 1
        else
          done += 1
          @domHost.showToast "Processed #{done} out of #{count}"
          @push 'responseList', "OK #{audience.phone}"

        next()

    it1.finally =>
      if (done is count)
        # @_createBlankAudience()
        # @_loadAudienceList()
        @domHost.showModalDialog "All messages processed"
  
  _getStatsClass: (status)->
    if status is 'success'
      return 'success'
    else
      return 'danger'


  sendSmsTappedNew: ->
    unless @audienceList.length
      return @domHost.showToast "No Audience has been selected!"
    
    unless @newSmsInput.length
      return @domHost.showToast "SMS body can not be empty!"
    
    data =
      apiKey: @user.apiKey
      audienceList: @audienceList
      smsBody: @newSmsInput
      organizationId: @organization.idOnServer

    @callApi '/bdemr-internal-send-bulk-sms', data, (err, response)=>
      
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set "newSmsInput", ''
        @logs = response.data
        @$$("#dialogLogs").toggle()

        # @domHost.showModalDialog 'Success: ' + successCounter + ', Failed: ' + failedCounter

  _getEstimatePerSMSCost:(smsBody)->
    smsBodyLen = smsBody.length
    perSmsCharge = 1.23
    characterCountPerSMS = [160, 306, 459, 612, 765, 918]
    smsCount = 0

    for perSmsLen, index in characterCountPerSMS
      if smsBodyLen <= perSmsLen
        smsCount = index + 1
        break
    return smsCount * perSmsCharge

}         
