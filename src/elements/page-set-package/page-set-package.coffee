Polymer {
  is: 'page-set-package'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]
  
  properties:
    user:
      type: Object
      notify: true
      value: {}
    
    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false

    organization:
      type: Object
      notify: true
      value: {}
    
    package:
      type: Object
      value:
        name: ""
        price: ""
        itemList: []

    investigationPriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []

    servicePriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []

    pharmacyPriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data:
          medicinePriceList: []
          fluidPriceList: []
          transfusionPriceList: []
          customPharmacyPriceList: []
        
    supplyPriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []

    ambulancePriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []

    packagePriceList:
      type: Object
      value:
        serial: null
        lastModifiedDatetimeStamp: null
        data: []     
    
    otherPriceList:
      type: Object
      notify: true
      value: 
        serial: null
        lastModifiedDatetimeStamp: null
        data: []


  navigatedIn: ->
    @_loadUser()
    params = @domHost.getPageParams()
    if params['organization']
      @_loadOrganization params['organization']
    else
      @_notifyInvalidOrganization()

  _loadData: ()->
    @_getInvestigationList @organization.idOnServer
    # @_loadInvestigationPriceList @organization.idOnServer
    @_loadServicePriceList @organization.idOnServer
    @_loadSupplyPriceList @organization.idOnServer
    @_loadAmbulancePriceList @organization.idOnServer
    @_loadPackagePriceList @organization.idOnServer
    @_loadOtherPriceList @organization.idOnServer
    @_loadDoctorFeesPriceList @organization.idOnServer
    @_loadMedicineInventory @organization.idOnServer

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _checkUserAccess: (userIdOnServer, userList)->
    found = false
    for item in userList
      if item.id is userIdOnServer
        if item.isAdmin
          found = true
          break
    
    if found then @_loadData() else @_notifyInvalidAccess()
  
  _loadOrganization: (idOnServer)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        @set 'isOrganizationValid', true
        @_checkUserAccess @user.idOnServer, response.data.matchingOrganizationList[0].userList

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  _notifyInvalidAccess: ->
    @domHost.showModalPrompt 'You Do Not Have Access To This Page!', ()=>
      @domHost.navigateToPreviousPage()
  
  _makePackage: ->
    @set 'package', {
      name: ""
      price: null
      actualCost: null
      category: 'package'
      itemList: []
    }
  
  
  _loadInvestigationPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    investigationPriceList = app.db.find 'investigation-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if investigationPriceList.length > 0
      @investigationPriceList = investigationPriceList[0]
    

  _getInvestigationList: (organizationId)->
    @domHost.callApi '/bdemr-get-organization-investigation-list', { apiKey: @user.apiKey, organizationId: organizationId }, (err, response)=>
      console.log response
      if response.hasError
        @showWarningToast response.error.message
      else
        data = response.data
        @investigationPriceList = data
        console.log {@investigationPriceList}


  # LOAD SERVICE PRICE LIST
  # -------------------------------------
  _loadServicePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    servicePriceList = app.db.find 'service-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if servicePriceList.length > 0
      @servicePriceList = servicePriceList[0]
    

  # LOAD DOCTOR FEES PRICE LIST
  # -------------------------------------
  _loadDoctorFeesPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    doctorFeesPriceList = app.db.find 'doctor-fees-price-list', ({organizationId})-> organizationId is organizationIdentifier

    if doctorFeesPriceList.length > 0
      @doctorFeesPriceList = doctorFeesPriceList[0]

  # LOAD MEDICINE INVENTORY PRICE LIST
  # -------------------------------------
  _loadMedicineInventory: (organizationIdentifier)->
    @domHost.getStaticData 'medicineCompositionList', (medicineCompositionList)=>
      brandNameMap = {}
      for item in medicineCompositionList
        brandNameMap[item.brandName] = null
      generatedMedicineList = ({data: {name: item, buyingPrice: 0, sellingPrice: 0, qty: 1}} for item in Object.keys brandNameMap)

      inventory = app.db.find 'organization-inventory', ({organizationId})-> organizationId is organizationIdentifier
      @medicineInventory = [].concat inventory, generatedMedicineList
  
  # LOAD SUPPLY PRICE LIST
  # -------------------------------------
  _loadSupplyPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    supplyPriceList = app.db.find 'supply-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if supplyPriceList.length > 0
      @supplyPriceList = supplyPriceList[0]
    
  
  # LOAD AMBULANCE PRICE LIST
  # -------------------------------------
  _loadAmbulancePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    ambulancePriceList = app.db.find 'ambulance-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if ambulancePriceList.length > 0
      @ambulancePriceList = ambulancePriceList[0]
    
  
  # LOAD PACKAGE PRICE LIST
  # -------------------------------------
  _loadPackagePriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    packagePriceList = app.db.find 'package-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if packagePriceList.length > 0
      @packagePriceList = packagePriceList[0]
    else
      @_makePackagePriceList (priceList)=>
        app.db.insert 'package-price-list', priceList
        @set 'packagePriceList', priceList

  _makePackagePriceList: (cbfn)->
    cbfn priceList = 
      serial: @generateSerialForPackagePriceList()
      organizationId: @organization.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      data: [
        {name: "Gall Bladder Operation Package", price: null, actualCost: null, category: 'package'}
        {name: "Appendicitis Operation Package", price: null, actualCost: null, category: 'package'}
        {name: "C/S Operation Package", price: null, actualCost: null, category: 'package'}
        {name: "Hysterectomy Operation Package", price: null, actualCost: null, category: 'package'}
        {name: "Tonsillectomy Operation Package", price: null, actualCost: null, category: 'package'}
        {name: "Health Checkup Laboratory Package", price: null, actualCost: null, category: 'package'}
        {name: "Endoscopy Package", price: null, actualCost: null, category: 'package'}      
      ]
  
  # LOAD OTHER PRICE LIST
  # -------------------------------------
  _loadOtherPriceList: (organizationIdentifier)->
    # Check if User already has a Price List
    otherPriceList = app.db.find 'other-price-list', ({organizationId})-> organizationId is organizationIdentifier
    
    if otherPriceList.length > 0
      @otherPriceList = otherPriceList[0]
    

  isEmpty: (array)->
    return false if array is undefined or array is null 
    if array.length then return true else return false
  
  # TOGGLE COLLAPSE
  toggleInvestigation: (e)-> @.$.investigation.toggle()
  toggleServcie: (e)-> @.$.service.toggle()
  togglePharmacy: (e)-> @.$.pharmacy.toggle()
  toggleSupply: (e)-> @.$.supply.toggle()
  toggleDoctorFees: (e)-> @.$.doctorFees.toggle()
  toggleAmbulance: (e)-> @.$.ambulance.toggle()
  toggleOther: (e)-> @.$.other.toggle()

  addToListButtonClicked: (e)->
    @push 'package.itemList', e.model.item

  packageItemPriceSelected: (e)->
    netPrice = e.model.item.price * (if e.model.item.qty then e.model.item.qty else 1)
    console.log netPrice
    if e.target.checked
      packagePrice = (parseInt @package.price or 0) + (parseInt netPrice or 0)
      @set 'package.price', packagePrice
    else
      @set 'package.price', (@package.price - (parseInt netPrice))

  qtyInput: (e)->
    model = e.model
    value = e.target.value
    if value > 1
      model.set 'item.qty', value
    else 
      model.set 'item.qty', 1

  deletePackageItem: (e)->
    @splice 'package.itemList', e.model.index, 1
    @set 'package.price', (@package.price - (parseInt e.model.item.price))
  
  _savePackage: ->
    @push 'packagePriceList.data', @package
    @packagePriceList.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'package-price-list', @packagePriceList, ({serial})=> serial is @packagePriceList.serial
    @_makePackage()
    @domHost.showToast 'Pacakge Created Successfully.'
  
  _checkValidity: (inputsToValidate, cbfn)->
    validationStatusList = []
    for item in inputsToValidate
      isValid = @.$$("##{item}").validate()
      validationStatusList.push isValid
    status = validationStatusList.every (value)->
      return value
    cbfn status  

  validate: (e)->
    e.target.validate()

  createPackageButtonClicked: ->
    if @package.itemList.length
      @_checkValidity ['packageName', 'packagePrice', 'packageCost'], (status)=>
        if status
          @_savePackage()
        else
          @domHost.showToast 'Enter Package Name and Price'
    else
      @domHost.showToast 'Enter Item into Package List'
  
  arrowBackButtonPressed: ->
    @domHost.navigateToPreviousPage()


  # REFACTOR TO DO
  # Data not fully cleared when switching Clinic, there is a flash of Previous Data when in and out of the page.
}