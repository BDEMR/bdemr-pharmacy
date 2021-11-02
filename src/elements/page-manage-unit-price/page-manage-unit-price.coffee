Polymer {
  is: 'page-manage-unit-price'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    discountTypes:
      type: Array
      value: ['Amount', 'Percentage']

    hideEditForm:
      type: Boolean
      value: true
    
    productPage:
      type: Number
      value: -> 0
    
    selectedSubViewIndex:
      type: Number
      value: 0

    EDIT_MODE:
      type: Boolean
      value: false
    
    IMPORT_DONE:
      type: Boolean
      value: false
    
    isBulkImportHidden:
      type: Boolean
      value: true
    
    bulkImport:
      type: Object
      value: {}

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: -> (app.db.find 'organization')[0]
    
    inventory:
      type: Array
      value: []

    categories:
      type: Array
      value: []
    
    product:
      type: Object
      value: {}
    
    selectedCategory:
      type: String
      value: ''
    
    filterBy:
      type: Object
      value: {
        category: null
        fromDate: null
        toDate: null
      }
    
    itemSearchQuery:
      type: String
      value: ''
      observer: 'itemSearchInputChanged'
    
    organizationItemSearchQuery:
      type: String
      value: null
      observer: 'organizationItemSearchInputChanged'
    
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
    
    organizationMatchingResults:
      type: Array
      value: []
    
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
    
    visitTypeList:
      type: Array
      value: -> ['First Visit', 'Second Visit', 'Report Analysis']
    
    remarks:
      type: Array
      value: -> ['sold', 'restock']
      
    activeItem:
      observer: '_activeItemChanged'
    
    TOTAL_ACTUAL_COST:
      type: Number
      value: 0
    
    hasAllSelected:
      type: Boolean
      value: false
      observer: '_observerAllSelected'
    
    nonQuantifiableCategories:
      type: Array
      value: ['investigation', 'packages']

  _getDiscountedPrice: (discountAmount=0, discountType=0, price=0)->
    
    return price if !discountAmount
    return price if !discountType

    discountAmount = parseFloat discountAmount

    return price if Math.sign(discountAmount) is -1

    return price - ((price * discountAmount) / 100) if discountType is 'Percentage'

    return parseInt(price - discountAmount)


  _observerAllSelected: (hasAllSelected)->
    inventory = {}
    for item, index in @inventory
      if hasAllSelected
        @set "inventory.#{index}.isSelected", true
      else
        @set "inventory.#{index}.isSelected", false
  
  _deleteAllSelectedInvestigation: ()->
    deletedItems = @inventory.filter (item) => item.isSelected
    if deletedItems.length is 0
      return @domHost.showToast 'Select One or More Products.'

    @domHost.showModalPrompt "#{deletedItems.length} product(s)  will be permanantly deleted. Are you sure?", (answer)=>
      if answer
        @domHost.toggleModalLoader "Deleting..."
        for item, index in deletedItems
          @_callDeleteInventoryItemApi item._id, => null
        
        @domHost.toggleModalLoader()
            

        @_resetProductObject()
        @_callGetInventory @filterBy, => null

  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _getCategories: ()->
    @categories = [
      {
        name: 'investigation'
        investigationList: []
      }
      {
        name: 'medicine'
        data:
          batch: null
          genericName: null
          medicineType: null
          manufacturer: null
      }
      {
        name: 'services'
        data: null
      }
      {
        name: 'supply'
        data: null
      }
      {
        name: 'ambulance'
        data: null
      }
      {
        name: 'packages'
        data: null
      }
      {
        name: 'doctor-visit'
        data: null
      }
      {
        name: 'canteen'
        data: null
      }
      {
        name: 'others'
        data: null
      }
    ]
  
  _onProductChange: ()->
    return if @product.category isnt 'packages'
    return if !@product.packageItems
    return if @product.packageItems.length is 0
    items = @product.packageItems
    totalCost = 0
    for item in items
      totalCost += item.price
    
    @set 'price.actualCost', totalCost
  
  _validateProductForm: ()->

    isCategory = @$$("#inputCategory").validate()
    isInputName = @$$("#productSearch").validate()
    # isInputActualCost = @$$("#inputActualCost").validate()
    isInputPrice = @$$("#inputPrice").validate()

    # isInputQuantity = @$$("#inputQuantity").validate()

    return isCategory and isInputName and isInputPrice

    # if isCategory and isInputName and isInputActualCost and isInputPrice and isInputQuantity
    #   categoryValue = @$$("#inputCategory").value

    #   if categoryValue is 'medicine'
    #     # isInputBatchNumber = @$$("#inputBatchNumber").validate()

    #     isInputGenericName = @$$("#inputGenericName").validate()
    #     isInputManufacturer = @$$("#inputManufacturer").validate()
        
    #     if isInputGenericName and isInputManufacturer
    #       return true

    #     return false
    #   else 
    #     return true

    # return false

  
  categorySelected: (e) ->
    if (this.categories && this.categories.length > 0)
      category = e.detail.value

      if category?.name is 'investigation' and !@EDIT_MODE
        @set 'product.investigationList', category.investigationList
      
      # check if selected category is in nonQuantifiableCategories 
      if category?.name in @nonQuantifiableCategories
        @set 'product.hasQuantity', false
      else
        @set 'product.hasQuantity', true
        
  
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
    @set 'EDIT_MODE', false
    @_resetQuantityTransaction()
    
    @product =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      category: 'medicine'
      favoriteByUserIdList: []
      actualCost: 0
      discountType: 'Amount'
      discountAmount: 0
      price: 0
      quantity: 0     
      hasQuantity: true
      name: ''
      tag: ''
      supplier: ''
      expiryDate: null
      alertQuantity: 0
      expireAlertDays: 0
      packageItems: []
      otherFields: []
      isPublic: true
      isActive: true
      hasGroupTest: false
      testGroupList: []
      logs: []
      investigationList: []
    

  _addMoreFields: ()->
    @push 'product.otherFields', {
      label: ''
      value: ''
    }
    
  _showNewProductForm: ()->
    @_resetProductObject()
    @set 'hideEditForm', false
    # @$$('#organizationProductSearch').items = []
    # @$$('#organizationProductSearch').value = null
  
  _closeEditForm: ()->
    @set 'hideEditForm', true
  
  _clearProduct: ()->
    @_resetProductObject()
    
  
  # _selectedItemsChanged: (selectedItems)->

  convertToDateString: (dateObject)->
    isoStringArr = dateObject.toISOString().split('T')
    console.log isoStringArr
    return isoStringArr[0]


  _activeItemChanged: (item)->
    console.log 'selected item', item
    if (@inventory && @inventory.length > 0)
      if item
        if item.expiryDate
          expiryDateObj = new Date item.expiryDate
          expiryDateString = @convertToDateString(expiryDateObj)
          @set 'customExpiryDate', expiryDateString        
        
        this.$.list.selectedItems = [item] or [];
        @set 'hideEditForm', false
        @set 'EDIT_MODE', true
        @set 'productPage', 0
        @set 'product', item
        @_resetQuantityTransaction()
      else
        @set 'hideEditForm', true
    
  

  # category - investigaiton - start

  _addNewTest: ()->

    @push 'product.investigationList', {
      name: ''
      value: ''
      referenceRange: ''
      unitList: []
      isProtected: false
    }
  
  _deleteTest: (e)->
    index = e.model.index
    @splice 'product.investigationList', index, 1
  

  _addNewGroup: ()->
    @push 'product.testGroupList', {
      testGroupName: '',
      investigaitonList: [
        {
          name: ''
          value: ''
          referenceRange: ''
          unitList: []
          isProtected: false
        }
      ]
    }
  
  _deleteGroup: (e)->
    index = e.model.groupIndex
    @splice 'product.testGroupList', index, 1
  

  _addNewTestToGroup: (e)->

    groupIndex = e.model.groupIndex

    console.log groupIndex

    console.log @product

    @push "product.testGroupList.#{groupIndex}.investigaitonList", {
      name: ''
      referenceRange: ''
      unitList: []
      isProtected: false
    }
  
  _deleteTestFromGroup: (e)->
    groupIndex = e.model.groupIndex
    index = e.model.index
    @splice "product.testGroupList.#{groupIndex}.investigaitonList", index, 1

  # category - investigaiton - end

  _callGetTags:()->

    @domHost.callApi '/bdemr-get-common-product-tags', { apiKey: @user.apiKey }, (err, response)=>
      if response.hasError
        @set 'tags', []
      else
        data = response.data
        @set 'tags', data

  _callGetInventory:(filterBy, cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filterBy: filterBy
      addedByUserName: @user.name

    @domHost.toggleModalLoader 'Loading Inventory...'
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
    return unless @_validateProductForm()

    if @product.category is 'investigation'
      if @product.hasGroupTest
        return @domHost.showToast 'Please add atleast one test group!' if @product.hasGroupTest and (@product.testGroupList.length is 0)
        return @domHost.showToast 'Test Group Must have name!' unless @product.testGroupList[0].testGroupName
      else
        return @domHost.showToast 'Please add atleast one test!' if @product.investigationList.length is 0
        return @domHost.showToast 'Test Must have name!' unless @product.investigationList[0].name

    # @product.category = @selectedCategory
    @_callSetInventoryItemApi @product, =>
      if @EDIT_MODE
        selectedIndex = 0
        ## fix :: need to set this by find index of selected item
        for item, index in @inventory
          if item._id is @product._id
            selectedIndex = index
            break
  
        product = @product         
        path = 'inventory.' + selectedIndex
        @set path, product


      else
        @unshift 'inventory', @product
      @_resetProductObject()
      @_closeEditForm()
      # @_callGetInventory @filterBy, => null
  
  _callDeleteInventoryItemApi: (productId, cbfn)->
    data =
      apiKey: @user.apiKey
      productId: productId
      organizationId: @organization.idOnServer
    @domHost.callApi '/bdemr-delete-inventory-item', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        cbfn()
  
  _deleteProduct:()->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        @domHost.toggleModalLoader "Deleting #{@product.name}..."
        @_callDeleteInventoryItemApi @product._id, =>
          @domHost.toggleModalLoader()
          @_resetProductObject()
          @_callGetInventory @filterBy, =>
            
  

  onFilterTapped: ()->
    @_callGetInventory @filterBy, =>
      @_resetProductObject()
  
  onClearFilterTapped: ()->
    @set 'filterBy', {}
    @_callGetInventory @filterBy, => null
  
  showBulkImportForm: ()->
    @$$("#dialogBulkImport").toggle()
    @$$("#dialogBulkImport").center()
    @_resetBulkImport()
  
  showFilterForm: ()->
    @set 'isBulkImportHidden', true


  # bulk import - start
  _resetBulkImport:()->
    @set 'IMPORT_DONE', false
    @set 'bulkImportLog', null
    @set 'isLoading', false
    @$$('#inputCsvFile').value = ''
    @set 'bulkImport', {
      organizationId: @organization.idOnServer
      addedByUserName: @user.name
      data: []
    }
      
    
  
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
        console.log {result}
        @set 'bulkImport.data', result.data
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
    
    if @bulkImport.data.length is 0
      @domHost.showToast 'No Data Available!'
      return
    
    # unless @bulkImport.data.length <= 500
    #   @_resetBulkImport()
    #   @domHost.showWarningToast 'You can import only 500 investigations at a time!'
    #   return
    
    @domHost.toggleModalLoader "Importing #{@bulkImport.data.length} Products. It may take few minutes or more!"
    @_callInventoryBulkImportApi @bulkImport, =>
      @_callGetInventory @filterBy, =>
        @domHost.toggleModalLoader()
  
  onClearImportBulkBtnPressed: ()->
    @_resetBulkImport()


  # bulk import - end
      
  _downloadDemoTemplate: ()->
    window.open('../../assets/product-bulk-import-template-with-demo.csv')

  _flatInvestigationItems: (inventory, cbfn)->
    list = []

    for product in inventory
      if product.category is 'investigation'

        { name, actualCost, price, tag, category } = product

        if product.hasGroupTest
          for group in product.testGroupList
            for investigation in group.investigaitonList
              { unitList, referenceRange } = investigation
              if investigation.name.length > 0
                list.push { name, testGroupName: group.testGroupName, testName: investigation.name, unitList, referenceRange, name, actualCost, price, tag, category }
            
        else
          if product.investigationList?
            for item in product.investigationList
              { unitList, referenceRange } = item
              list.push { name, testName: item.name, unitList, referenceRange, name, actualCost, price, tag, category }
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
          'testName': item.testName or ''
          'testUnit': if item.unitList?.length > 0 then item.unitList[0] else ''
          'testReferenceRange': item.referenceRange or ''
          'testGroupName': item.testGroupName or ''
          'medicineGenericName': item.genericName or ''
          'medicineForm': item.form or ''
          'medicineForm': item.form or ''
          'medicineManufacturer': item.manufacturer or ''
          'medicineDoseDirection': item.doseDirection or ''
          'medicineRoute': item.route or ''
          'medicineDirection': item.direction or ''
          'description': item.description or ''
          'batchNumber': item.batchNumber or ''
          'vendorName': item.vendorName or ''
          'authorName': item.authorName or ''
          'manufacturDate': item.manufacturDate or ''
          'expiredDate': item.expiredDate or ''
          'contactNumber': item.contactNumber or ''
          'url': item.url or ''
          'location': item.location or ''
          'dealDetails': item.dealDetails or ''
          'expireAlertDays': item.expireAlertDays or ''
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
    unless searchQuery.length > 1
      return

    @debounce 'search-product', ()=>
      @_productSearch searchQuery
    , 500

    
  
  _productSearch: (searchQuery)->
    return unless searchQuery
    @$$("#productSearch").items = []

    @_callSearchSystemInventoryApi searchQuery, => null
  
  _callSearchSystemInventoryApi: (searchQuery, cbfn)->

    data =
      apiKey: @user.apiKey
      searchQuery: searchQuery
      category: @product.category

    @fetchingInventorySearchResult = true;
    @callApi '/bdemr-search-system-inventory', data, (err, response)=>
      @fetchingInventorySearchResult = false
      if response.hasError
        console.log response.error.message
      else
        data = response.data
        if data.length > 0
          @$$("#productSearch").items = data
        
      cbfn()
  

  _onKeyUpSearchOrganizationProduct: (e)->
    console.log 
    searchQuery = e.target.value
    return unless searchQuery.length > 1

    if e.code is "Enter"
      @_organizationProductSearch searchQuery
      return
   
    @_organizationProductSearch searchQuery
    return
  

  organizationItemSearchInputChanged: (searchQuery)->
    return unless searchQuery
    return unless searchQuery.length > 1
    
    # @debounce 'organization-search-product', ()=>
    #   @_organizationProductSearch searchQuery
    # , 500

     @_organizationProductSearch searchQuery

  
  
  _organizationProductSearch: (searchQuery)->
    # return if @product.category is 'packages'
    return unless searchQuery
    # @$$("#organizationProductSearch").items = []
    @_callSearchOrganizationInventoryApi searchQuery, => null

  _callSearchOrganizationInventoryApi: (searchQuery, cbfn)->
    # @$$("#organizationProductSearch").items = []

    data =
      apiKey: @user.apiKey
      searchQuery: searchQuery
      organizationId: @organization.idOnServer

    @fetchingInventorySearchResult = true;
    @callApi '/bdemr-search-organization-inventory', data, (err, response)=>
      @fetchingInventorySearchResult = false
      if response.hasError
        console.log response.error.message
      else
        data = response.data
        if data.length > 0
          @set 'organizationMatchingResults', data
        
      cbfn()
  

  _addItemOnPackage: ()->
    @set 'organizationMatchingResults', []
    @push 'product.packageItems', {
      name: ''
      price: 0
    }
  
  itemForPackageSelected: (e)->
    e.preventDefault()
    return unless e.detail.value
    item = e.detail.value
    index = e.model.index

    items = []
    items = items.concat @product.packageItems
    items[index] = item

    @set 'product.packageItems', items
    @set 'product.actualCost', @_calcTotalPrice @product.packageItems

    console.log @product
    

  _deletePackageItem: (e)->
    index = e.model.index
    console.log index
    console.log @product

    @splice 'product.packageItems', index, 1
    @set 'product.actualCost', @_calcTotalPrice @product.packageItems


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
      object.investigationList = []
    
    Object.assign product, object

    @set 'product', product
  
  _calcTotalActualCost: (productList)->
    console.log "_calcTotalActualCost", productList
    totalCost = 0
    return totalCost if !productList
    return totalCost if productList.length is 0

    for item in productList
      totalCost += parseFloat item.actualCost
    
    return totalCost

  _calcTotalPrice: (productList)->
    console.log "_calcTotalPrice", productList
    totalCost = 0
    return totalCost if !productList
    return totalCost if productList.length is 0

    for item in productList
      totalCost += parseFloat item.price
    
    return totalCost
  

  navigatedIn: ->
    console.log 'hello from navigatedIn'
    @_callGetInventory @filterBy, =>
      @_getCategories()
      @_callGetTags()
      @_resetProductObject()
      @_resetBulkImport()

    

} 