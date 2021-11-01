Polymer {

  is: 'bdemr-investigation'

  behaviors: [ 
    app.behaviors.apiCalling
  ]

  properties:
    user:
      type: Object
      value: null
      reflectToAttribute: true
    
    organization:
      type: Object
      value: null
      reflectToAttribute: true
    
    investigationSearchQuery:
      type: String
      value: -> ""
      observer: 'investigationSearchInputChanged'
    
    searchCounter:
      type: Number
      value: -> 0
    
    searchResults:
      type: Array
      value: -> []
    
    newInvestigation:
      type: Object
      value: null
    
    inputInvestigationValue:
      type: String
      value: null
    
    selectedInvestigation:
      type: Object
      value: null
      notify: true
    
    isFavoriteOnly:
      type: Boolean
      value: false
    
    bulkImportLog:
      type: Object
      value: null
    
    isLoading:
      type: Boolean
      value: false
  
  _returnSerial: (index)->
    return index + 1
  
  showToast: (content)->
    @genericToastContents = content
    @$$('#toast1').open()

  genericToastTapped: (e)->
    @$$('#toast1').close()

  showSuccessToast: (content)->
    @genericToastContents = content
    @$$('#successToast').open()

  successToastTapped: (e)->
    @$$('#successToast').close()

  showWarningToast: (content)->
    @genericToastContents = content
    @$$('#warningToast').open()

  warningToastTapped: (e)->
    @$$('#warningToast').close()

  _isValueIsCustom: (length, query) ->
    console.log length, query, @inputInvestigationValue
    if (length is 0) and (query.length > 1 or  @inputInvestigationValue?.length > 1 )
      return true
    return false

  _formatTestList: (list)->
    if !Array.isArray(list)
      return ''

    count = 0
    testString = ''

    for item in list
      testString += item.name + ', '
    
    index = testString.lastIndexOf(",")

    if index != -1
      partOne = testString.substring 0, index
      partTwo = testString.substring index + 1, testString.length
      testString = partOne + partTwo
    
    return testString
    
  investigationSearchInputChanged: (searchQuery)->
    @debounce 'search-investigation', ()=>
      @_searchInvestigation(searchQuery)
    , 300

  _searchInvestigation: (searchQuery)->
   
    return unless searchQuery
    return unless searchQuery.length > 1

    # @searchCounter++
    # return unless @searchCounter is 1

    console.log(searchQuery)
    
    @fetchingInvestigationSearchResult = true;
    @domHost.callApi '/bdemr-investigation-search', { apiKey: @user.apiKey, organizationId: @organization.idOnServer, searchString: searchQuery, @isFavoriteOnly }, (err, response)=>
      console.log response
      @fetchingInvestigationSearchResult = false
      if response.hasError
        @showWarningToast response.error.message
      else
        data = response.data
        @set 'searchResults', data


  investigationSelected: (e)->
    return unless e.detail.value
    @set 'selectedInvestigation', e.detail.value
    @set 'inputInvestigationValue', ''
  
  makeNewInvestigation: ()->
    @newInvestigation =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      category: @selectedCategory
      actualCost: 0
      price: 0
      favoriteByUserIdList: []
      category: 'investigation'
      flags:
        isPublic: true
        isActive: true

      name: @inputInvestigationValue
      investigationList: [
        {
          name: @inputInvestigationValue
          referenceRange: ''
          unitList: []
          isProtected: true
        }
      ]
  
  newInvestigationBtnPressed: (e)->
    # if @inputInvestigationValue and ((typeof @inputInvestigationValue) is 'string') 
    @makeNewInvestigation()
    @$$('#dialogNewInvestigation').toggle()
  
  _addNewTest: ()->
    unless @user.idOnServer
      return @showWarningToast 'Invalid User or User not found!'

    @push 'newInvestigation.investigationList', {
      name: ''
      referenceRange: ''
      unitList: []
      isProtected: false
    }
  
  _deleteTest: (e)->
    index = e.model.index
    @splice 'newInvestigation.investigationList', index, 1
  
  _cancelInvestigation: (e)->
    @set 'selectedInvestigation', null
  
  _checkIfEveryTestHasName:(list)->
    for item in list
      if item.name.length < 1
        return false
    return true
  
  _callSetInventoryItemApi: (product, cbfn)->
    data =
      apiKey: @user.apiKey
      product: product

    @set 'isLoading', true
    @domHost.callApi '/bdemr-set-inventory-item', data, (err, response)=>
      @set 'isLoading', false
      console.log response
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        message = response.data.message
        investigation = response.data.item
        if message is 'UPDATE_SUCCESS'
          @domHost.showToast 'Updated Succesfully!'
        
        if message is 'INSERT_SUCCESS'
          @domHost.showToast 'Added Succesfully!'
        
        cbfn investigation

  _saveNewInvestigation: (e)->
    unless @newInvestigation.name and (@newInvestigation.name.length > 1)
      @showToast 'Please type valid investigation name.'
      return

    unless @newInvestigation.investigationList.length >= 1
      @showToast "Investigation need atleast one test!"
      return
    
    unless @_checkIfEveryTestHasName(@newInvestigation.investigationList)
      @showToast "Please Check if you missing any test name!"
      return
    
    @_callSetInventoryItemApi @newInvestigation, (investigation) =>
      @set 'selectedInvestigation', investigation
      @$$('#dialogNewInvestigation').toggle()
  

  _resetBulkImport:()->
    @set 'isLoading', false
    @$$('#inputCsvFile').value = ''
    @bulkImport =
      organizationId: @organization.idOnServer
      data: []
    
  _showBulkImportDialog: (e)->
    @set 'bulkImportLog', null
    @_resetBulkImport();
    @$$('#dialogInvestigationBulkImport').toggle()
    @$$('#dialogInvestigationBulkImport').center()
  
  openFile: (e)->
    @set 'bulkImportLog', null
    reader = new FileReader
    file = e.target.files[0]

    fileType = file.name.split('.').pop()
    console.log fileType

    unless fileType is "csv"
      @showWarningToast 'Supports CSV Format only!'
      @$$('#inputCsvFile').value = ''

    if file.size > @maximumLogoImageSizeAllowedInBytes
      @showWarningToast 'Please provide a file less than 1mb in size.'
      return
    reader.readAsText file
    reader.onload = =>
      data = reader.result
      @_convertToCsvFormat(data)
  
  _convertToCsvFormat: (data)->
    Papa.parse data, {
      quotes: false
      quoteChar: '"'
      escapeChar: '"'
      delimiter: ","
      header: true
      newline: "\r\n"
      skipEmptyLines: false,
      columns: null
      complete: (result) =>
        @bulkImport.data = result.data
    }
  
  _callInvestigationBulkImport: (data)->
    data.apiKey = @user.apiKey
    @set 'isLoading', true
    @domHost.callApi '/bdemr-investigation-bulk-import', data, (err, response)=>
      @set 'isLoading', false
      if response.hasError
        @showWarningToast response.error.message
      else
        @_resetBulkImport()
        @set 'bulkImportLog', response.data
  
  _bulkImportButtonPressed: ()->
    unless @bulkImport.data.length > 0
      @showToast 'Select CSV file first!'
      return

    @_callInvestigationBulkImport @bulkImport
  
  _downloadDemoTemplateBtnPressed: ()->
    window.open('../../app/assets/investigation-bulk-import-demo.csv')
    
}