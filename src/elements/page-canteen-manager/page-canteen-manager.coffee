Polymer {
  is: 'page-canteen-manager'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    hideEditForm:
      type: Boolean
      value: true

    EDIT_MODE:
      type: Boolean
      value: false
    
    IMPORT_DONE:
      type: Boolean
      value: false
    
    isBulkImportHidden:
      type: Boolean
      value: true

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    inventory:
      type: Array
      value: []
    
    product:
      type: Object
      value: {}
    
    selectedCategory:
      type: String
      value: 'canteen'
    
    filterBy:
      type: Object
      value: {
        category: 'canteen'
        fromDate: null
        toDate: null
      }
    
    itemSearchQuery:
      type: String
      value: ''
      observer: 'itemSearchInputChanged'
    
    activeItem:
      observer: '_activeItemChanged'
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  

  _validateCanteenForm: ()->
    isInputName = @$$("#productSearch").validate()
    isInputActualCost = @$$("#inputActualCost").validate()
    isInputPrice = @$$("#inputPrice").validate()

    if isInputName and isInputActualCost and isInputPrice
      return true

    return false
  
  _resetProductObject: ()->
    @product =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      category: @selectedCategory
      favoriteByUserIdList: []
      actualCost: 0
      price: 0
      quantity: 1
      name: ''

      flags:
        isPublic: true
        isActive: true
    
    @set 'EDIT_MODE', false
  
  _showNewProductForm: ()->
    @_clearProduct()
    @set 'hideEditForm', false
  
  _closeEditForm: ()->
    @set 'hideEditForm', true
  
  _clearProduct: ()->
    @_resetProductObject()
  

  _activeItemChanged: (item)->
    console.log 'selected item', item
    if (@inventory && @inventory.length > 0)
      if item
        console.log this.$.list
        this.$.list.selectedItems = [item] or [];
        @set 'hideEditForm', false
        @set 'EDIT_MODE', true
        @set 'product', item
      else
        @set 'hideEditForm', true
  
  _callGetInventory:(filterBy, cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: filterBy

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-inventory', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        data = response.data
        @set 'inventory', data
        cbfn()

  _callSetInventoryItemApi: (product, cbfn)->
    data =
      apiKey: @user.apiKey
      product: product

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-set-inventory-item', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        message = response.data.message
        if message is 'UPDATE_SUCCESS'
          @domHost.showToast 'Updated Succesfully!'
        
        if message is 'INSERT_SUCCESS'
          @domHost.showToast 'Added Succesfully!'
        
        cbfn()
    

  _setProduct: ()->
    if @_validateCanteenForm()
      @product.category = @selectedCategory
      @_callSetInventoryItemApi @product, =>
        if @EDIT_MODE
          ## fix :: need to set this by find index of selected item
          for item, index in @inventory
            if item._id is @product._id
              @set 'inventory.#{index}', @product
              break
        else
          @unshift 'inventory', @product
        @_resetProductObject()
        @_closeEditForm()
        # @_callGetInventory @filterBy, => null
  
  _callDeleteInventoryItemApi: (product, cbfn)->
    data =
      apiKey: @user.apiKey
      productId: product._id
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-delete-inventory-item', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        message = response.data.message
        if message is 'SUCCESS'
          @domHost.showToast 'Deleted!'
        cbfn()
  
  _deleteProduct:()->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        @_callDeleteInventoryItemApi @product, =>
          @_resetProductObject()
          @_callGetInventory @filterBy, => null
  

  onFilterTapped: ()->
    @_callGetInventory @filterBy, =>
      @_resetProductObject()
  
  onClearFilterTapped: ()->
    @set 'filterBy', {
      category: @selectedCategory
      fromDate: null
      toDate: null
    }
    @_callGetInventory @filterBy, => null
  
  showBulkImportForm: ()->
    @set 'isBulkImportHidden', false
    @_resetBulkImport()
  
  showFilterForm: ()->
    @set 'isBulkImportHidden', true


  # bulk import - start
  _resetBulkImport:()->
    @set 'IMPORT_DONE', false
    @set 'bulkImportLog', null
    @set 'isLoading', false
    @$$('#inputCsvFile').value = ''
    @bulkImport =
      organizationId: @organization.idOnServer
      data: []
    
  
  openFile: (e)->
    @set 'bulkImportLog', null
    reader = new FileReader
    file = e.target.files[0]

    fileType = file.name.split('.').pop()
    console.log fileType

    unless fileType is "csv"
      @domHost.showWarningToast 'Supports CSV Format only!'
      @$$('#inputCsvFile').value = ''
      return

    if file.size > @maximumFileSizeAllowedInBytes
      @domHost.showWarningToast 'Please provide a file less than 1mb in size.'
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

  _callInventoryBulkImportApi: (data, cbfn)->
    data.apiKey = @user.apiKey
    @set 'isLoading', true
    @domHost.callApi '/bdemr-organization-inventory-bulk-import', data, (err, response)=>
      @set 'isLoading', false
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        @set 'IMPORT_DONE', true
        @set 'bulkImportLog', response.data
        cbfn()
  
  onBulkImportBtnPressed: ()->
    console.log @bulkImport
    unless @bulkImport.data.length > 0
      @domHost.showToast 'No Data Availale!'
      return
    
    # unless @bulkImport.data.length <= 500
    #   @_resetBulkImport()
    #   @domHost.showWarningToast 'You can import only 500 investigations at a time!'
    #   return

    @_callInventoryBulkImportApi @bulkImport, =>
      @_callGetInventory @filterBy, => null
  
  onClearImportBulkBtnPressed: ()->
    @_resetBulkImport()


  # bulk import - end
      
  _downloadDemoTemplate: ()->
    window.open('../../app/assets/organization-product-bulk-import-demo.csv')

  _flatInvestigationItems: (inventory, cbfn)->
    list = []

    for product in inventory
      if product.category is 'investigation'
        console.log product.investigationList.length
        for item in product.investigationList
          obj = product
          obj.testName = item.name
          obj.unitList = item.unitList
          obj.referenceRange = item.referenceRange
          # delete obj.investigationList
          list.push obj
      else
        list.push product
    
    cbfn list

  # export - start
  _preparePatientJsonData: (inventory) ->
    # console.log inventory
    @_flatInvestigationItems inventory, (modifiedInventory) =>
      console.log {modifiedInventory}
      exportableList = modifiedInventory.map (item) =>
        return {
          'name': item.name or ''
          'actualCost': parseFloat item.actualCost or 0
          'price': parseFloat item.price or 0
          'isActive': if item.flags.isActive then 'yes' else 'no' 
          'isPublic': if item.flags.isPublic then 'yes' else 'no' 
          'testName': item.testName or ''
          'testUnit': if item.unitList?.length > 0 then item.unitList[0] else ''
          'testReferenceRange': item.referenceRange or ''
          'medicineGenericName': item.genericName or ''
          'medicineForm': item.form or ''
          'medicineForm': item.form or ''
          'medicineManufacturer': item.manufacturer or ''
          'medicineDoseDirection': item.doseDirection or ''
          'medicineRoute': item.route or ''
          'medicineDirection': item.direction or ''
        }
          
      return exportableList
  
  downloadCsv: (csv, exportedFilenmae) ->
    blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    link = document.createElement("a")
    url = URL.createObjectURL(blob)
    link.setAttribute("href", url)
    link.setAttribute("download", exportedFilenmae)
    link.style.visibility = 'hidden'
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

  _exportBtnPressed: (e)->
    data = @_preparePatientJsonData @inventory

    csvString = Papa.unparse(data);
    fileName = @organization.name.replace(' ', '_') + '_product_list.csv'

    @downloadCsv(csvString, fileName);

  # export - end

  itemSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    # @debounce 'search-item', ()=>
      
    # , 100

    @_productSearch searchQuery

  
  _productSearch: (searchQuery)->
    return unless searchQuery
    @$$("#productSearch").items = []
    @fetchingInventorySearchResult = true;
    @callApi '/bdemr-search-organization-inventory', { apiKey: @user.apiKey, searchQuery: searchQuery, category: @selectedCategory}, (err, response)=>
      @fetchingInventorySearchResult = false
      if response.hasError
        console.log response.error.message
      else
        data = response.data
        if data.length > 0
          @$$("#productSearch").items = data
  
  itemSelected: (e)->
    return unless e.detail.value
    item = e.detail.value
    product = @product
    @set 'product', {}

    object =
      name: item.name
      itemId: item.itemId
      category: item.category
    
    if item.category is 'medicine'
      object.genericName = item.genericName or ''
      object.form = item.form or ''
      object.manufacturer = item.manufacturer or ''
    
    if item.category is 'investigation'
      object.investigationList = item.investigationList
    
    Object.assign product, object
    console.log product
    @set 'product', product

  navigatedIn: ->
    @_callGetInventory @filterBy, =>
      @_resetProductObject()

  goToCanteenInvoice: ()->
    @domHost.navigateToPage("#/canteen-invoice-editor/location:canteen/invoice:new")

    

} 