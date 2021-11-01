
Polymer {

  is: 'page-organization-editor'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    selectedPage:
      type: Number
      notify: true
      value: 0
    
    organizationType:
      type: Array
      value: ['Hospital', 'Shop', 'Pharmacy', 'Chamber', 'Other']

    user:
      type: Object
      notify: true
      value: null
    
    countryWithCitiesList:
      type: Array
      value: []
    
    selectedCountryCitiesList:
      type: Array
      value: []
    
    printSettings:
      type: Object
      notify: true
      value: null

    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false
   
    moreOptionList: 
      type: Boolean
      value: false

    organization:
      type: Object
      notify: true
      value: null

    maximumLogoImageSizeAllowedInBytes:
      type: Number
      value: 1000 * 1000

    parentSearchResultList:
      type: Array
      value: -> []

    orgHeaderImg:
      type: String
      value: null
      notify: true

    orgFooterImg:
      type: String
      value: null
      notify: true

    otherFacilitiesArray:
      type: Array
      value: -> [
        {
          label:"Emergency Facilities",
          key: "emergencyFacilities",
          isChecked: false
        }
        {
          label: "AC Available",
          key: "acAvailable",
          isChecked: false
        }
        {
          label: "Online Appointment"
          key: "onlineAppointment",
          isChecked: false
        }
        {
          label:"Cabin Available",
          key: "cabinAvailable",
          isChecked: false
        }
        {
          label:"Advanced Patient Monitoring Cardiac",
          key: "advancedPatientMonitoringCardiac",
          isChecked: false
        }
        {
          label: "Anaesthesia Machine",
          key: "anaesthesiaMachine",
          isChecked: false
        }
        {
          label: "Histo Pathology Facility",
          key: "histoPathologyFacility",
          isChecked: false
        }
        {
          label: "MRI Facility",
          key: "mriFacility",
          isChecked: false
        }
        {
          label: "CT Scan Facility",
          key: "ctScanFacility",
          isChecked: false
        }
        {
          label: "Ultrasound Facility", 
          key: "ultrasoundFacility",
          isChecked: false
        }
        {
          label: "Pathology Facility",
          key: "pathologyFacility",
          isChecked: false
        }
        {
          label: "Blood Transfusion Facility",
          key: "bloodTransfusionFacility",
          isChecked: false
        }
        {
          label: "Ambulance Facility",
          key: "ambulanceFacility",
          isChecked: false
        }
        {
          label: "Labour Delivery",
          key: "labourDelivery",
          isChecked: false
        }
        {
          label: "Operation Facility",
          key: "operationFacility",
          isChecked: false
        }
        {
          label: "Served Corona Patients",
          key: "servedCoronPatients",
          isChecked: false
        }
      ]

    parentList:
      type: Array
      value: -> []


  ready: ->
    @_preloadData()
  

  _preloadData: ->
    @async => @_loadCountryCityFromSystem()

  navigatedIn: ->
    @_loadUser()
   
    params = @domHost.getPageParams()
    if params['organization']
      if params['organization'] is 'new'
        @_makeNewOrganization()
      else
        @_loadOrganization params['organization']
        
    else
      @_notifyInvalidOrganization()
    
  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false
    @parentSearchResultList = []
    @parentList = []
  
  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  getprintSettingsObject:()->
    return {
      headerLine: ''
      leftSideLine1: ''
      leftSideLine2: ''
      leftSideLine3: ''
      rightSideLine1: ''
      rightSideLine2: ''
      rightSideLine3: ''
      footerLine: ''
    }

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    params = @domHost.getPageParams()
    if params['organization'] is 'new'
      @_createOrganization =>
        @domHost.showToast 'Organization Created'
        @arrowBackButtonPressed()
    else
      @_updateOrganization =>
        @domHost.showToast 'Organization Updated'
        @arrowBackButtonPressed()
    
  _makeNewOrganization: ->
    @organization = 
      idOnServer: null
      serial: null
      name: ''
      type: ''
      address: ''
      logoDataUri: ''
      phone: ''
      country: ''
      city: ''
      emergencyPhone: ''
      faxNumber: ''
      email: ''
      effectiveRegion: ''
      numberOfMBBSDoctorsOnStaff: null
      numberOfRegisteredNurseOnStaff: null
      numberOfRegisteredMidWifeOnStaff: null
      parentOrganizationIdList: []
      otherFacilitiesList: @otherFacilitiesArray
      markAsPccOrganization: false
      markAsNwdrOrganization: false
      printSettings: @getprintSettingsObject()
    @isOrganizationValid = true

  # Custom function to convert facility labels strings into pascal case strings
  toCamelCase: (str) -> 
    strArray = str.split(' ')
    strToBeLowerCassed = strArray.shift()
    lowerCaseOperation = strToBeLowerCassed.toLowerCase()
    strArray2 = strArray.unshift(lowerCaseOperation)
    joinedString = strArray.join('')
    return joinedString

  addOtherFacilities: (e)->
    if e.which is 13
      return unless @facilities
      newFacility = {
        label: @facilities
        key: @toCamelCase(@facilities)
        isChecked: false
      }
      @push 'organization.otherFacilitiesList', newFacility
      console.log @organization.otherFacilitiesList
      @facilities = ""

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  _createOrganization: (cbfn)->
    data = Object.assign @organization, {apiKey: @user.apiKey}
    @callApi '/bdemr-organization-create', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  _updateOrganization: (cbfn)->
    currentOrganization = @getCurrentOrganization()
    if currentOrganization.idOnServer is @organization.idOnServer
      app.db.upsert 'organization', currentOrganization, ({idOnServer})=> currentOrganization.idOnServer is idOnServer
      
    data = Object.assign @organization, {apiKey: @user.apiKey, organizationId: @organization.idOnServer}
    @callApi '/bdemr-organization-update', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()


  searchParentOrganizationTapped: (e)->
    data = { 
      apiKey: @user.apiKey
      searchString: @parentOrganizationSearchString
    }
    @callApi '/bdemr-organization-search', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'parentSearchResultList', response.data.matchingOrganizationList

  $in: (value, list)-> 
    value in list

  addParentTapped: (e)->
    { parent } = e.model
    @push 'organization.parentOrganizationIdList', parent.idOnServer
    @push 'parentList', parent
    @splice 'parentSearchResultList', (@parentSearchResultList.indexOf parent), 1

  removeParentTapped: (e)->
    { parent } = e.model
    @splice 'organization.parentOrganizationIdList', (@organization.parentOrganizationIdList.indexOf parent.idOnServer), 1
    @splice 'parentList', (@parentList.indexOf parent), 1

  # _loadOrganization: (idOnServer)->
  #   data = { 
  #     apiKey: @user.apiKey
  #     idList: [ idOnServer ]
  #   }
  #   @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
  #     console.log response
  #     if response.hasError
  #       @domHost.showModalDialog response.error.message
  #     else
  #       unless response.data.matchingOrganizationList.length is 1
  #         @domHost.showModalDialog "Invalid Organization"
  #         return
  #       organization = response.data.matchingOrganizationList[0]

  #       if typeof organization.serial is 'undefined'
  #         organization.serial = ''
        
  #       @set 'organization', organization
  #       @set 'isOrganizationValid', true
  #       @_loadParentList()
  #       if !@organization.printSettings
  #         @organization.printSettings = @getprintSettingsObject()

  _loadOrganization: (idOnServer)->
    data = {
      apiKey: @user.apiKey
      organizationId: idOnServer
    }
    @callApi '/get-organization-info', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        organization = response.data
        @set 'organization', organization
        @set 'isOrganizationValid', true
        @_loadParentList()
        if !@organization.printSettings
          @organization.printSettings = @getprintSettingsObject()        
        console.log @organization

  _loadParentList: ->
    data = { 
      apiKey: @user.apiKey
      idList: @organization.parentOrganizationIdList
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'parentList', response.data.matchingOrganizationList

  logoInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]
    if file.size > 1000000
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return
    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @set 'organization.logoDataUri', dataUri


  headerFileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @_callSetOrganizationHeaderImage dataUri
      
  _callSetOrganizationHeaderImage: (dataUri)->
    attachment =
      mainStorage: 'server'
      apiKey: @user.apiKey
      dataURI: dataUri
      userSerial: @user.serial
      organizationId: @organization.idOnServer
      imgType: 'header-image'

    console.log 'attachment', attachment

    @set 'isUploading', true
    @callApi '/bdemr--organization-print-set-header-image', attachment, (err, response)=>
      @set 'isUploading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'orgHeaderImg', dataUri
        @set 'organization.printSettings.headerLogoDataUri', dataUri
        @organization.headerFileNameOnServer = response.data.fileNameOnServer



  footerFileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @_callSetOrganizationFooterImage dataUri
      
  _callSetOrganizationFooterImage: (dataUri)->
    attachment =
      mainStorage: 'server'
      apiKey: @user.apiKey
      dataURI: dataUri
      userSerial: @user.serial
      organizationId: @organization.idOnServer
      imgType: 'footer-image'

    console.log 'attachment', attachment

    @set 'isUploading', true
    @callApi '/bdemr--organization-print-set-footer-image', attachment, (err, response)=>
      @set 'isUploading', false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'orgFooterImg', dataUri
        @set 'organization.printSettings.footerLogoDataUri', dataUri
        @organization.footerFileNameOnServer = response.data.fileNameOnServer


  # headerFileInputChanged: (e)->
  #   reader = new FileReader
  #   file = e.target.files[0]

  #   if file.size > @maximumLogoImageSizeAllowedInBytes
  #     @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
  #     return

  #   reader.readAsDataURL file
  #   reader.onload = =>
  #     dataUri = reader.result
  #     @set 'organization.printSettings.headerLogoDataUri', dataUri

  # footerFileInputChanged: (e)->
  #   reader = new FileReader
  #   file = e.target.files[0]

  #   if file.size > @maximumLogoImageSizeAllowedInBytes
  #     @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
  #     return

  #   reader.readAsDataURL file
  #   reader.onload = =>
  #     dataUri = reader.result
  #     @set 'organization.printSettings.footerLogoDataUri', dataUri

  toggleMoreOptions: (e)-> @$$("#moreOptionList").toggle()


  _countrySelected: (e)->
    return unless e.detail.value
    selectedCountry = e.detail.value
    console.log 'selected country', selectedCountry
    @set 'selectedCountryCitiesList', []
    @set 'selectedCountryCitiesList', selectedCountry.cities
    unless selectedCountry.name is @organization.country
      @set 'organization.city', ''


  _loadCountryCityFromSystem: (userIdentifier)->
    @set 'countryWithCitiesList', []
    @domHost.getStaticData 'countryCityList', (countryCityList)=>
      # unless countryCityList.length is 0
      #   for item in countryCityList
      #     unless item.name is ''
      #       object = {}
      #       object.label = item.name
      #       object.value = item   
      #       @push "countryWithCitiesList", object
      @set 'countryWithCitiesList', countryCityList

      # # get all custom symptoms
      # customSymptomslist = app.db.find 'custom-symptoms-list', ({createdByUserSerial})=> userIdentifier is createdByUserSerial
      
      # # pushed all custom symptoms on master investigatin list
      # unless customSymptomslist.length is 0
      #   for item in customSymptomslist
      #     customObject = {}
      #     customObject.category = item.data?.category or 'Custom'
      #     customObject.label = item.data.name
      #     customObject.value = item.data.name
      #     # console.log investigation
      #     @push "symptomsDataList", customObject

      @countryWithCitiesList.sort (left, right)->
        return -1 if left.label < right.label
        return 1 if left.label > right.label
        return 0
      # @_generateSymptomCategory @symptomsDataList

  removeHeaderImageBtnPrsd: (e)->
    if @organization.printSettings.headerLogoDataUri is '' or @organization.headerFileNameOnServer is ''
      return @domHost.showModalDialog 'There is no image to be removed'
    else
      data = {
        apiKey: @user.apiKey
        fileNameOnServer: @organization.headerFileNameOnServer
      }
      @callApi '/bdemr--clinic-remove-org-header-image', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          @set 'organization.printSettings.headerLogoDataUri', null
          @set 'organization.headerFileNameOnServer', ''
          @domHost.showModalDialog 'Image removed'

  removeFooterImageBtnPrsd: (e)->
    if @organization.printSettings.footerLogoDataUri is '' or @organization.footerFileNameOnServer is ''
      return @domHost.showModalDialog 'There is no image to be removed'
    else
      data = {
        apiKey: @user.apiKey
        fileNameOnServer: @organization.footerFileNameOnServer
      }
      @callApi '/bdemr--clinic-remove-org-footer-image', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          @set 'organization.printSettings.footerLogoDataUri', null
          @set 'organization.footerFileNameOnServer', ''
          @domHost.showModalDialog 'Image removed'


}
