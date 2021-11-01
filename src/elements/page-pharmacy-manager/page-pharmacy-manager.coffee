Polymer {
  is: 'page-pharmacy-manager'
  
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

    productReStockAlertArr:
      type: Array
      value: ()-> []

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
      value: 'medicine'
    
    filterBy:
      type: Object
      value: {
        category: 'medicine'
        fromDate: null
        toDate: null
      }
    
    itemSearchQuery:
      type: String
      value: ''
      observer: 'itemSearchInputChanged'
    
    doseList:
      type: Array
      value: -> [
        "1+1+1"
        "1+0+1"
        "0+0+1"
        "1+0+0"
        "1+1+1+1"
        "2+2+2"
        "2+0+2"
        "0+0+2"
        "2+0+0"
        "1/2+1/2+1/2"
        "1/2+0+1/2"
        "0+0+1/2"
        "1/2+0+0"
        "1/4+1/4+1/4"
        "1/4+0+1/4"
        "0+0+1/4"
        "1/4+0+0"
        "1/4+1/4+1/4+1/4"
        "3 Times Daily"
        "4 Times Daily"
        "2 Times Daily"
        "1 Time Daily"
        "1 Time Daily In The Morning"
        "1 Time Daily At Night"
      ]
    
    directionList:
      type: Array
      value: [
        'Anytime'
        'Before Meal'
        'After Meal'
        'Full Stomach'
        'Empty Stomach'
      ]
    
    medicineFormList:
      type: Array
      value: [
        'Tablet'
        'Injection'
        'Syrup'
        'Drop'
        'Capsule'
        'Suspension'
        'I.V Injection'
        'I.M injection'
        'S/C Injection'
        'PR (Per Rectal)'
        'Suppository'
        'Solution'
        'Ointment'
        'Cream'
        'Skin Patch'
        'Custom'
      ]
    
    routeList:
      type: Array
      value: [
        'Oral'
        'I.V injection'
        'I.M injection'
        'PR (Per Rectal)'
        'S/L'
        'S/C'
        'Nebulizer'
        'Inhaler'
        'Topical application skin'
        'Topical application ear'
        'Topical application eye'
        'Intravaginal'
        'Transdermal'
        'Custom'
      ]

    hideOriginalCreatedProductInvoiceButton:
      type: Boolean
      value: false

    customExpiryDate: String    
    activeItem:
      observer: '_activeItemChanged'
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  

  _validateMedicineForm: ()->
    isInputName = @$$("#productSearch").validate()
    isInputActualCost = @$$("#inputActualCost").validate()
    isInputPrice = @$$("#inputPrice").validate()

    # isInputQuantity = @$$("#inputQuantity").validate()
    # isInputBatchNumber = @$$("#inputBatchNumber").validate()
    # isInputGenericName = @$$("#inputGenericName").validate()
    # isInputManufacturer = @$$("#inputManufacturer").validate()
    return isInputName and isInputActualCost and isInputPrice


  _resetQuantityTransaction: ()->
    @set 'qtyTransaction', {
      quantity: 0
      remarks: 'stock'
      addedByUserName: @user.name
      addedAt: null
      addedbyUserId: @user.idOnServer
    }
  
  _addNewQuantity: ()->
    console.log @product
    if !@product.logs
      @product.logs = []

    @qtyTransaction.addedAt = lib.datetime.now()

    quantity = parseInt @qtyTransaction.quantity
    productQty = @product.quantity or 0
    productQty += quantity

    console.log 
 
    @set "product.quantity", productQty
    @push "product.logs", @qtyTransaction

    @_resetQuantityTransaction()


  
  _resetProductObject: ()->
    @_resetQuantityTransaction()
    @product =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      category: @selectedCategory
      favoriteByUserIdList: []
      supplier: ''
      expiryDate: null
      hasQuantity: true
      alertQuantity: 0
      expireAlertDays: 0
      actualCost: 0
      price: 0
      quantity: 1
      name: ''

      flags:
        isPublic: true
        isActive: true

    @customExpiryDate = ""

    @set 'EDIT_MODE', false

  _setExpiryDate: ()->
    return unless @customExpiryDate
    expiryDateProduct = +new Date("#{@customExpiryDate}")
    @set 'product.expiryDate', expiryDateProduct
    @customExpiryDate = ""

  convertToDateString: (dateObject)->
    isoStringArr = dateObject.toISOString().split('T')
    console.log isoStringArr
    return isoStringArr[0]

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
        if item.expiryDate
          expiryDateObj = new Date item.expiryDate
          expiryDateString = @convertToDateString(expiryDateObj)
          @set 'customExpiryDate', expiryDateString        
        console.log this.$.list
        this.$.list.selectedItems = [item] or [];
        @set 'hideEditForm', false
        @set 'EDIT_MODE', true
        @set 'product', item
        @_resetQuantityTransaction()
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
        @_parseInventory data
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
    if @_validateMedicineForm()
      @_setExpiryDate()      
      @product.category = @selectedCategory
      @product.expireDaysLeft = @_computeDaysLeft @product.expiryDate
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
      category: 'medicine'
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
          'category': item.category or ''
          'actualCost': parseFloat item.actualCost or 0
          'price': parseFloat item.price or 0
          'quantity': item.quantity or 0
          'tag': item.tag or ''
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
          'vendorName': item.vendorName or ''
          'supplier': item.supplier or ''
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



  # _classForQuantityAlert functions returns danger as value and used on a span element for tye danger style
  _classForQuantityAlert: (item)->
    return '' if !item
    qty = item.quantity
    alertQty = item.alertQuantity

    if typeof qty or alertQty is 'string'
      qty = parseInt qty
      alertQty = parseInt alertQty
   
    return "danger" if qty <= alertQty
    return ''

  # _computeDaysLeft function returns a numeric value that is calculated using created DateTimeStamp and  expiryDate dateTimeStamp
  _computeDaysLeft: (expiryMs)->
    expiryDate = new Date(expiryMs)
    addedDate = lib.datetime.now()
    addedDate = new Date()
    diffMs = expiryDate.getTime() - addedDate.getTime()
    @diffMsRounded = Math.round(diffMs/(24*60*60*1000))
    return @diffMsRounded


  # parsing quantity and alertQuantity to integer values of its found in string form
  _parseInventory: (inventory)->
    return '' if !inventory
    parsedInvArr = []
    for item in inventory
      if typeof item.quantity or item.alertQuantity is 'string'
        item.quantity = parseInt item.quantity
        item.alertQuantity = parseInt item.alertQuantity
        parsedInvArr.push(item)
    
    @_calculateAlerts parsedInvArr

  # produces an array consisting of item that has hit alert values of either quantity and/or expiry date
  _calculateAlerts: (inventory)->
    productReStockAlertArr = []
    for item in inventory
      if item.quantity <= item.alertQuantity
        item.quantityAlert = true
        productReStockAlertArr.push(item)
      if item.expireDaysLeft <= item.expireAlertDays
        item.expireDateAlert = true
        unless productReStockAlertArr.includes item
          productReStockAlertArr.push(item)

    console.log productReStockAlertArr
    @set 'productReStockAlertArr', productReStockAlertArr

  _viewAlertBoxButtonClicked: (e)->
    @$$('#dialogAlertBox').toggle()
    return

  navigatedIn: ->
    console.log @organization
    # only for Shamsun Nahar Clinic start
    if @organization.idOnServer is '6129c836bd6d475eb7b85d0a'
      console.log 'Shamsun Nahar Organization Found'
      @hideOriginalCreatedProductInvoiceButton = true
    # only for Shamsun Nahar Clinic end

    @_callGetInventory @filterBy, =>
      @_resetProductObject()

  goToPharmacyInvoice: ()->
    @domHost.navigateToPage("#/pharmacy-invoice-editor/location:pharmacy/invoice:new")

  goToOutPatientInvoice: ()->
    @domHost.navigateToPage("#/outpatient-invoice")

  goToRefundInvoice: ()->
    @domHost.navigateToPage("#/accounts-refund-invoice")

  goToSupplierInvoice: ()->
    @domHost.navigateToPage("#/supplier-invoice-editor/organization:" + @organization.idOnServer + '/supplier:new')

    

} 