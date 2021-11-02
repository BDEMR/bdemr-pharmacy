
Polymer {
  
  is: 'page-top-sheet'

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
      notify: true
      value: (app.db.find 'organization')[0]

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0] 

    topSheetEntryObject:
      type: Object
      value: {}

    isLoading:
      type: Boolean
      value: false

    topSheetEntryList:
      type: Array
      value: -> []

    topSheetEntryListOriginal:
      type: Array
      value: -> []

    sumTotalCashHandover:
      type: Number
      computed: 'getSumTotalCashHandover(topSheetEntryList)'

    sumTotalFundDiscount:
      type: Number
      computed: 'getSumTotalFundDiscount(topSheetEntryList)'

    addedDate:
      type: String
      value: ''

    currentDateTime:
      type: Number
      value: lib.datetime.now()

  

  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    return 1 if a.addedOn < b.addedOn
    return -1 if a.addedOn > b.addedOn
    return 0
  
  $isAdmin: (userId, userList)->
    for user in userList
      if userId is user.id
        return user.isAdmin
        break
    return false

  _getTotalPaid: (paid = 0, lastPaid = 0)->
    return (parseInt paid) + (parseInt lastPaid)

  
  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  navigatedIn: ->
    @isLoading = true
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>    
      @isLoading = false
      @_makeNewTopSheetEntryObject()
      @getTopSheetEntryList()
      

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _loadOrganization: (cbfn)->
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        
        cbfn()

  
  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'

  getSumTotalCashHandover: (entryList)->
    totalCash = entryList.reduce (total, item)=> 
      return total += (parseFloat item.totalCashHandover)
    , 0
    return totalCash.toFixed(2)

  getSumTotalFundDiscount: (entryList)->
    totalCash = entryList.reduce (total, item)=> 
      return total += (parseFloat item.totalFundDiscount)
    , 0
    return totalCash.toFixed(2)
  

  getTopSheetEntryList: ()-> 
    @loadingCounter++
    @topSheetEntryListOriginal = app.db.find('top-sheet-entry-list', ({ organizationId }) => organizationId is @organization.idOnServer)
    @topSheetEntryList = @topSheetEntryListOriginal
    @loadingCounter--
    @topSheetEntryList.sort (left, right)=>
      return 1 if left.addedOn < right.addedOn
      return -1 if left.addedOn > right.addedOn
      return 0
    console.log @topSheetEntryList
  
  filterByDateClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', (startDate.getTime())
    @set 'dateCreatedTo', (endDate.getTime())

  filterByDateClearButtonClicked: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0
    @getTopSheetEntryList()
  
  searchButtonClicked: ()->

    searchParameters = {
      dateCreatedFrom: @dateCreatedFrom?=""
      dateCreatedTo: @dateCreatedTo?=""
      searchString: @searchString.toLowerCase()
    }

    console.log 'from date', searchParameters.dateCreatedFrom
    console.log 'to date', searchParameters.dateCreatedTo
    console.log 'search string', searchParameters.searchString


    filteredTopSheetEntryList = []

    if @dateCreatedFrom
      filteredTopSheetEntryList = @topSheetEntryListOriginal.filter (item) =>
        return true if (searchParameters.dateCreatedFrom <= item.addedOn <= searchParameters.dateCreatedTo)

    if @searchString
      filteredTopSheetEntryList = @topSheetEntryListOriginal.filter (item) =>
        return true if (searchParameters.searchString is item.name.toLowerCase()) or (searchParameters.searchString is item.mobile)

    if @dateCreatedFrom and @searchString
      filteredTopSheetEntryList = @topSheetEntryListOriginal.filter (item) =>
        return true if (searchParameters.dateCreatedFrom <= item.addedOn <= searchParameters.dateCreatedTo) and (searchParameters.searchString is item.name.toLowerCase() or searchParameters.searchString is item.mobile)
    
    filteredTopSheetEntryList.sort (left, right)=>
      return 1 if left.addedOn < right.addedOn
      return -1 if left.addedOn > right.addedOn
      return 0

    console.log 'filtered top sheet entry list', filteredTopSheetEntryList
    @set 'topSheetEntryList', filteredTopSheetEntryList


  _addNewEntryButtonClicked: (e)-> 
    return this.$$('#dialogAddNewEntry').toggle();
  
  _makeNewTopSheetEntryObject: ()-> 
    topSheetEntryObject = {
      createdDatetimeStamp: null,
      lastModifiedDatetimeStamp: null,
      organizationId: @organization.idOnServer,
      serial: null,
      name: '',
      mobile: '',
      addedOn: null
      totalBilled: null,
      totalDiscount: null,
      totalFundDiscount: null,
      totalDue: null,
      totalCashHandover: null,
    }

    @addedDate = ''
    @set 'topSheetEntryObject', topSheetEntryObject


  _validateTopSheetEntryInputs: ()->
    # name
    if @topSheetEntryObject.name? and @topSheetEntryObject.name.trim() isnt ''
      @topSheetEntryObject.name = @topSheetEntryObject.name.trim()
    else
      return false

    # mobile
    if @topSheetEntryObject.mobile? and @topSheetEntryObject.mobile.trim() isnt ''
      @topSheetEntryObject.mobile = @topSheetEntryObject.mobile.trim()
    else
      return false

    # added on
    if @addedDate? and @addedDate.trim() isnt ''
      @topSheetEntryObject.addedOn = (new Date @addedDate.trim()).getTime()
    else
      return false

    # total billed
    if @topSheetEntryObject.totalBilled? and @topSheetEntryObject.totalBilled.trim() isnt ''
      @topSheetEntryObject.totalBilled = @topSheetEntryObject.totalBilled.trim()
    else
      return false

    # total discount
    if @topSheetEntryObject.totalDiscount? and @topSheetEntryObject.totalDiscount.trim() isnt ''
      @topSheetEntryObject.totalDiscount = @topSheetEntryObject.totalDiscount.trim()
    else
      return false

    # total fund discount
    if @topSheetEntryObject.totalFundDiscount? and @topSheetEntryObject.totalFundDiscount.trim() isnt ''
      @topSheetEntryObject.totalFundDiscount = @topSheetEntryObject.totalFundDiscount.trim()
    else
      return false

    # total due
    if @topSheetEntryObject.totalDue? and @topSheetEntryObject.totalDue.trim() isnt ''
      @topSheetEntryObject.totalDue = @topSheetEntryObject.totalDue.trim()
    else
      return false

    # total cash in drawer
    if @topSheetEntryObject.totalCashHandover? and @topSheetEntryObject.totalCashHandover.trim() isnt ''
      @topSheetEntryObject.totalCashHandover = @topSheetEntryObject.totalCashHandover.trim()
    else
      return false

    return true



  _addTopSheetEntry: ()->
    unless @_validateTopSheetEntryInputs()
      return @domHost.showModalDialog 'Please Enter All Information in the form'

    @topSheetEntryObject.createdDatetimeStamp = lib.datetime.now()
    @topSheetEntryObject.lastModifiedDatetimeStamp = lib.datetime.now()
    if !@topSheetEntryObject.serial
      @topSheetEntryObject.serial = @generateSerialForTopSheetEntry()
    
    app.db.insert 'top-sheet-entry-list', @topSheetEntryObject
    console.log 'top sheet entry object', @topSheetEntryObject
    @_makeNewTopSheetEntryObject()
    @getTopSheetEntryList()
    return this.$$('#dialogAddNewEntry').close();


  # _deleteEntry:(e)->
  #   {item, index} = e.model
  #   @domHost.showModalPrompt "Are you sure?", (answer)=>
  #     if answer
  #       @splice 'topSheetEntryList', index, 1
  #       app.db.remove 'top-sheet-entry-list', item._id
  #       app.db.insert 'top-sheet-entry-list--deleted', item
  #       console.log "Deleted"
  #       return


  resetButtonClicked: (e)->
    window.location.reload()    
    

  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()

  
}
