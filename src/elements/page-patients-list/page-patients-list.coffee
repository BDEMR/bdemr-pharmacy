
Polymer {
  is: 'page-patients-list'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    page: 
      type: Number
      value:0
      
    pages: Array

    hideEditForm:
      type: Boolean
      value: true

    EDIT_MODE:
      type: Boolean
      value: false
    category:
      type: Object
      value: {
        category: 'Patients'
        
      }
 
    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    inventories:
      type: Array
      value: -> [
        
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '26'
          createdDatetimeStamp:'2021-05-02'
          icon: 'extra-icons:settings'
          category: 'patient'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:'2020-09-05'
          age: '262'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '263'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '264'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '265'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:'2017-08-01'
          age: '266'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '267'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:'2020-05-02'
          age: '268'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '269'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:'2016-12-15'
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:''
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '26'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '26'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          createdDatetimeStamp:'2021-08-12'
          age: '26'
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '26'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
        {
          name: 'Mahmudul Hassan'
          address : 'Dhaka,Bangladesh'
          number: '0171111111'
          gender: 'male'
          age: '26'
          createdDatetimeStamp:''
          icon: 'extra-icons:settings'
        }
      ]
    
    inventory:
      type: Array
      value: []
    

    
    
    filterBy:
      type: Object
      value: {
        category: 'medicine'
        fromDate: null
        toDate: null
      }
    patients:
      type: Array
      value: []
    search:
      type: Array
      value: []
      
    itemSearchQuery:
      type: String
      value: ''
      observer: 'itemSearchInputChanged'
    activeItem:
      observer: '_itemsChanged'
  
    
  
        
  # _load: -> asyncStuff(done ->this.$.scrollTheshold.clearTriggers())
  
        

  # _didRespond: (e)-> 
  #    people = e.detail.response.results

  #    people.forEach((person)-> this.$.list.push('inventories', person))
        
  #    this.$.scrollTheshold.clearTriggers()
      
  
  
 

    
  _isSelected: (page, item)-> 
      @page is item - 1
     

  _select: (e)->
      @page = e.model.item - 1
      @_itemsChanged()
        

  _next:-> 
      @page = Math.min(@pages.length - 1, @page + 1)
     
      console.log 'selected item', @page
      @_itemsChanged()
        

  _prev: -> 
      @page = Math.max(0, @page - 1)
      @_itemsChanged()
        

  _itemsChanged: ()-> 
    console.log 'selected item', @inventories
    
    if @category.category is 'Patients'
        @patients =@inventories
        if not @pages
          @pages = Array.apply(null,{length : Math.ceil(@patients.length/ this.$.list.pageSize)}).map((item, index) -> index + 1)
            
        start = @page * this.$.list.pageSize
        end = (@page + 1) * this.$.list.pageSize
        console.log 'selected start', start
        console.log 'selected end', end
        this.$.list.items = @patients[start...end]
    else if @category.category is'Search'
        if not @pages
          @pages = Array.apply(null,{length : Math.ceil(@search.length/ this.$.list.pageSize)}).map((item, index) -> index + 1)
              
        start = @page * this.$.list.pageSize
        end = (@page + 1) * this.$.list.pageSize
        console.log 'selected start', start
        console.log 'selected end', end
        this.$.list.items = @search[start...end]

    
    
    
    

     
  
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
  

   
  # _activeItemChanged: (inventories,page)->
   
    
  #   if (@inventory && @inventory.length > 0)
  #     if item
  #       if item.expiryDate
  #         expiryDateObj = new Date item.expiryDate
  #         expiryDateString = @convertToDateString(expiryDateObj)
  #         @set 'customExpiryDate', expiryDateString        
  #       console.log this.$.list
  #       this.$.list.selectedItems = [item] or [];
  #       @set 'hideEditForm', false
  #       @set 'EDIT_MODE', true
  #       @set 'product', item
  #     else
  #       @set 'hideEditForm', true
    
 
 _resetProductObject: ()->
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


  _callGetInventory:(filterBy, cbfn)->
      # startDate = new Date(@filterBy.fromDate);
      # endDate   = new Date(@filterBy.toDate);
      # console.log 'resultdata', startDate
      # console.log 'resultdata', endDate

      # resultProductData = @inventories.filter((a)->  
      #   date = new Date(a.createdDatetimeStamp)
      #   date >= startDate and date <= endDate)
      # console.log 'resultdata', resultProductData
      # @set 'inventories', resultProductData
      # @_parseInventory resultProductData
            


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
      startDate = new Date(@filterBy.fromDate);
      endDate   = new Date(@filterBy.toDate);
      console.log 'resultdata', startDate
      console.log 'resultdata', endDate

      resultProductData = @inventories.filter((a)->  
        date = new Date(a.createdDatetimeStamp)
        date >= startDate and date <= endDate)
      console.log 'resultdata', resultProductData
      @set 'search', resultProductData
      @_parseInventory resultProductData, =>
      @_resetProductObject()
      @set 'category',{category:'Search'}
      @page = 0
      @pages=null
      @_itemsChanged()
      
    
  
  onClearFilterTapped: ()->
    @set 'category',{category:'Patients'}
    @page = 0
    @pages=null
    @_itemsChanged()
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


  #

  
  
  

  # export - end

  itemSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    # @debounce 'search-item', ()=>
      
    # , 100

    @_productSearch searchQuery

  
  _productSearch: (searchQuery)->
    return unless searchQuery
    @$$("#productSearch").inventories = []
    @fetchingInventorySearchResult = true;
    @callApi '/bdemr-search-organization-inventory', { apiKey: @user.apiKey, searchQuery: searchQuery, category: @selectedCategory}, (err, response)=>
      @fetchingInventorySearchResult = false
      if response.hasError
        console.log response.error.message
      else
        data = response.data
        if data.length > 0
          @$$("#productSearch").inventories = data
  
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
    @_callGetInventory @filterBy, =>
      @_resetProductObject()

  goToPharmacyInvoice: ()->
    @domHost.navigateToPage("#/pharmacy-invoice-editor/location:pharmacy/invoice:new")

  goToSupplierInvoice: ()->
    @domHost.navigateToPage("#/supplier-invoice-editor/organization:" + @organization.idOnServer + '/supplier:new')

    

} 