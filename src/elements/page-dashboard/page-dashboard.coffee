
Polymer {

  is: 'page-dashboard'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:
    languageSelectedIndex: 
      type: Number
      value: app.lang.defaultLanguageIndex
      notify: true
      observer: 'languageSelectedIndexChanged'

    daysLeft:
      type: Number
      value: 0


    managePatientLinkList:
      type: Array
      value: -> [
        {
          title: 'New Patient'
          subTitle: 'Create'
          info: ''
          imagePath: 'images/icons/add_user.png'
          urlPath: '#/patient-signup'
          accessId: ''
        }
        {
          title: 'FOLLOW UP'
          subTitle: 'Patient'
          info: ''
          imagePath: 'images/icons/ico_history_and_physical.png'
          urlPath: '#/patient-manager/selected:0'
          accessId: ''
        }

        # {
        #   title: 'Create '
        #   subTitle: 'New Patient'
        #   info: ''
        #   imagePath: 'assets/img/partners/badas.jpg'
        #   urlPath: '#/patient-signup'
        #   accessId: ''
        # }
        
        # {
        #   title: 'Patients Log'
        #   subTitle: 'patient history from'
        #   info: ''
        #   imagePath: 'images/icons/ico_history_and_physical.png'
        #   urlPath: '#/patient-manager/selected:1'
        #   accessId: ''
        # }
      ]


    sortcutList:
      type: Array
      value: -> [
        # {
        #   title: 'Report Manager'
        #   info: ''
        #   icon: 'icons:open-in-new'
        #   urlPath: '#/reports-manager'
        #   accessId: ''
        # }
        {
          title: 'Agent Panel'
          icon: 'icons:account-box'
          info: ''
          imagePath: 'images/icons/add_user.png'
          urlPath: '#/agent-panel'
          accessId: ''
        }
        {
          title: 'Bill View'
          icon: 'extra-icons:billview'
          info: ''
          imagePath: 'images/icons/bill view.svg'
          urlPath: '#/sample-invoice'
          accessId: ''
        }
        {
          title: 'Chamber Manager'
          icon: 'extra-icons:chamber'
          info: ''
          imagePath: 'images/icons/chamber.svg'
          urlPath: '#/chamber-manager'
          accessId: ''
        }
        # {
        #   title: 'Medicine Dispension'
        #   icon: 'icons:open-in-new'
        #   info: ''
        #   urlPath: '#/medicine-dispension'
        #   accessId: ''
        # }
        {
          title: 'Assistant Manager'
          icon: 'extra-icons:assistant'
          info: ''
          imagePath: 'images/icons/assistant.svg'
          urlPath: '#/assistant-manager'
          accessId: ''
        }
        # {
        #   title: 'Search Records'
        #   icon: 'icons:open-in-new'
        #   info: ''
        #   urlPath: '#/search-record'
        #   accessId: ''
        # }
        {
          title: 'Invoice Manager'
          icon: 'extra-icons:invoice'
          info: ''
          imagePath: 'images/icons/invoice.svg'
          urlPath: '#/invoice-manager'
          accessId: ''
        }
        # {
        #   title: 'Booking and Searvices'
        #   icon: 'icons:open-in-new'
        #   info: ''
        #   urlPath: '#/booking'
        #   accessId: ''
        # }
        {
          title: 'Commission Report'
          icon: 'extra-icons:commission'
          info: ''
          imagePath: 'images/icons/commission.svg'
          urlPath: '#/commission-report'
          accessId: ''
        }
        {
          title: 'Attendance Manager'
          icon: 'extra-icons:attendence'
          info: ''
          imagePath: 'images/icons/attendance.svg'
          urlPath: '#/attendance-manager'
          accessId: ''
        }
        {
          title: 'Pharmacy Manager'
          icon: 'extra-icons:pharmacy'
          info: ''
          imagePath: 'images/icons/pharmacy.svg'
          urlPath: '#/pharmacy-manager'
          accessId: ''
        }
        {
          title: 'Organization Manager'
          icon: 'extra-icons:organization'
          info: ''
          imagePath: 'images/icons/org manager.svg'
          urlPath: '#/organization-manager'
          accessId: ''
        }
        {
          title: 'Send Notification'
          icon: 'extra-icons:notification'
          info: ''
          imagePath: 'images/icons/notification.svg'
          urlPath: '#/notification-panel'
          accessId: ''
        }
        # {
        #   title: 'My Wallet'
        #   icon: 'icons:open-in-new'
        #   info: ''
        #   urlPath: '#/wallet'
        #   accessId: ''
        # }
        # {
        #   title: 'Send Feedback'
        #   icon: 'icons:open-in-new'
        #   info: ''
        #   urlPath: '#/send-feedback'
        #   accessId: ''
        # }
        {
          title: 'Settings'
          icon: 'extra-icons:settings'
          info: ''
          imagePath: 'images/icons/settings.svg'
          urlPath: '#/settings'
          accessId: ''
        }
      ]



    user:
      type: Object
      value: -> (app.db.find 'user')[0]

    organization:
      type: Object
      notify: true
      value: null

    childOrganizationList:
      type: Array
      notify: true
      value: []

    loading:
      type: Boolean
      value: false

    nwdrPatientList:
      type: Array
      notify: true
      value: []

    selectedDateRangeIndex:
      type: Number
      value: 0
      notify: true
      observer: 'selectedDateRangeIndexChanged'

    dayRangeTypeList:
      type: Array
      notify: true
      value: -> [
        {
          type: 'Today'
          daysCount: 0
        }

        {
          type: 'Yesterday'
          daysCount: 1
        }

        {
          type: 'Last 7 days'
          daysCount: 7
        }

        {
          type: 'Last 30days'
          daysCount: 30
        }

        {
          type: 'Custom Date'
          daysCount: -1
        }
      ]

    nwdrPatientCounter: Number
    dateCreatedFrom: String
    dateCreatedTo: String
    selectedGender: String
    selectedOrganizationId: String


  goToUrlForManagePatientList: (e)->
    index = e.model.index
    item = @managePatientLinkList[index]
    window.location = item.urlPath

  goToUrlForShortcutNav: (e)->
    index = e.model.index
    item = @sortcutList[index]
    window.location = item.urlPath

  ready: -> @version = app.config.clientVersion


  selectedDateRangeIndexChanged: (selectedPageIndex)->
   
    # console.log selectedPageIndex
    if selectedPageIndex is 0
      today = new Date()
      # console.log today.setHours(23, 59, 59)
      # console.log today.setHours(23, 59, 59, 999)
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', todayStart
      @set 'dateCreatedTo', todayEnd

    if selectedPageIndex is 1
      
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', yesterdayStart
      @set 'dateCreatedTo', yesterdayEnd

    if selectedPageIndex is 2

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', thisWeekStart
      @set 'dateCreatedTo', thisWeekEnd

    if selectedPageIndex is 3

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', last30Days
      @set 'dateCreatedTo', today

    if @user and @organization

      @_loadOrganizationWiseNwdrSpecifiPatientList()

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1

  organizationSelected: (e)->
    organizationId = e.detail.value
    @set 'selectedOrganizationId', organizationId

    if @user and @organization
      @_loadOrganizationWiseNwdrSpecifiPatientList()

  filterByDateClicked: (e)->
    startDate = new Date(e.detail.startDate)
    startDate.setHours(0, 0, 0, 0)
    endDate = new Date(e.detail.endDate)
    endDate.setHours(23, 59, 59, 999)
    @set 'dateCreatedFrom', startDate.getTime()
    @set 'dateCreatedTo', endDate.getTime()

  filterByDateClearButtonClicked:()->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0

  filterButtonClicked: ()->
    @_loadOrganizationWiseNwdrSpecifiPatientList()

  _loadOrganization: (cbfn)->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
      @_loadChildOrganizationList @organization.idOnServer

    cbfn()

  _loadChildOrganizationList: (organizationIdentifier)->
    @organizationLoading = true

    query =
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier

    @callApi '/bdemr--get-child-organization-list', query, (err, response) =>
      if err
        return @domHost.showModalDialog 'Server is not responding'
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @organizationLoading = false
        organizationList = response.data
        @set 'childOrganizationCounter', organizationList.length
        if organizationList.length
          mappedValue = organizationList.map (item) => ({ label: item.name, value: item._id })

          mappedValue.unshift { label: 'All', value: '' }

          @set 'childOrganizationList', mappedValue
        else
          @domHost.showToast 'No Child Organization Found'

  _loadOrganizationWiseNwdrSpecifiPatientList: ()->

    query =
      apiKey: this.user.apiKey
      organizationIdList: []
      searchParameters:
        dateCreatedFrom: this.dateCreatedFrom || lib.datetime.now()
        dateCreatedTo: this.dateCreatedTo || lib.datetime.now()


    if !this.selectedOrganizationId
      organizationIdList = this.childOrganizationList.map (item) => item.value
      organizationIdList.splice 0, 1
      query.organizationIdList = organizationIdList
      query.organizationIdList.push this.organization.idOnServer
    else
      query.organizationIdList = this.selectedOrganizationId

    @callApi '/get-organization-specific-nwdr-patient-list', query, (err, response) =>
      if err or !response
        return @domHost.showModalDialog 'Server Error'
      if response.hasError
        @nwdrPatientList = []
        @set 'nwdrPatientCounter', 0
        return
      else
        @nwdrPatientList = response.data

        @set 'nwdrPatientCounter', response.data.length

  viewPatientNdrRecordList: (e)->
    patient = e.model.item
    @domHost.navigateToPage '#/ndr-record-list/patient:' + patient.serial
  
  
  navigatedIn: ->
    
    # Sync User Settings if availble or set as default settings. this is required.
    # @domHost._syncUserSettings ()=>
    #   list = app.db.find 'settings', ({serial})=> @user.serial is serial
    #   if list.length is 0
    #     @saveDefaultSettings()

    metrics = @getDashboardMetrics()

    @user = (app.db.find 'user')[0]

    # @newPatientCount = metrics.newPatientCount
    # @totalPatientCount = metrics.totalPatientCount
    # @newRecordCount = metrics.newRecordCount
    # @totalRecordCount = metrics.totalRecordCount
    # @totalUnpaidInvoiceCount = metrics.totalUnpaidInvoiceCount
    @daysLeft = metrics.daysLeft

    # if @daysLeft < 0
    #   @domHost.navigateToPage '#/activate'
    #   return

    currentOrganization = @getCurrentOrganization()
    unless currentOrganization
      return @domHost.navigateToPage "#/select-organization"

    @_loadOrganization =>
      @_loadOrganizationWiseNwdrSpecifiPatientList()
      @set 'selectedDateRangeIndex', 0


  languageSelectedIndexChanged: ->
    value = @supportedLanguageList[@languageSelectedIndex]
    @setActiveLanguage value

  $getString1: (daysLeft, LANG)->
    if LANG is 'en-us'
      return "Your license for Doctor App will <br>expire in #{daysLeft} days."
    else if LANG is 'bn-bd'
      daysLeft = @$TRANSLATE_NUMBER daysLeft, LANG
      return "আপনার Doctor App এর লাইসেন্স বাতিল <br>হতে #{daysLeft} দিন বাকি আছে।"
    else
      return "TRANSLATION_FAILED"

  viewNewPatientsTapped: (e)->
    @domHost.navigateToPage '#/patient-manager/filter:today-only'

  viewNewRecordsTapped: (e)->
    @domHost.navigateToPage '#/record-manager/filter:today-only'

  viewAllRecordsTapped: (e)->
    @domHost.navigateToPage '#/record-manager/filter:clear'

  viewAllPatientsTapped: (e)->
    @domHost.navigateToPage '#/patient-manager/filter:clear'

  viewUnpaidInvoicesTapped: (e)->
    @domHost.navigateToPage '#/invoices/unpaid-only'

  purchaseAnaesMonTapped: (e)->
    window.open 'https://my.bdemr.com/#/apps/anaesmon/purchase'

  renewAnaesMonTapped: (e)->
    @domHost.navigateToPage '#/activate'

  sampleCodeJumpTapped: (e)->
    @callApi '/bdemr-get-sample', { sampleCode: @sampleCodeToJump }, (err, response) =>
      if err
        return @domHost.showModalDialog 'Server is not responding'
      if response.hasError
        return @domHost.showModalDialog response.error.message
      
      # console.log(response)
      _pluggable = response.data.data.testAdvisedList[0].sample._pluggable
      patientSerial = response.data.patientSerial

      @_importPatient patientSerial, 'DISREGARD-ME', ()=>
        # console.log("PATIENT IMPORTED")

        localStorage.setItem("testResultObjectList", _pluggable)
        @domHost.navigateToPage '#/test-results/test-results:multi/patient:' + response.data.patientSerial


  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      # console.log "bdemr-patient-import-new", response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patientList = response.data

        if patientList.length isnt 1
          return @domHost.showModalDialog 'Unknown error occurred.'
        patient = patientList[0]

        # patientPinObject = {patientSerial: serial, pin: pin}
        # @_savePinForLocalPatient pin, patient.serial
        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isImported = true

        @removePatientIfAlreadyExist patient.serial
        _id = app.db.insert 'patient-list', patient


        @_importPatientData patient.serial, _id, cbfn

  _importPatientData: (serial, _id, cbfn)->
    @domHost.toggleModalLoader 'Importing Patient Data. Please Wait...'
    collectionNameMap = {
      'bdemr--doctor-visit': 'doctor-visit',
      'bdemr--patient-invoice': 'patient-invoice',
      'bdemr--patient-stay': 'visit-patient-stay',
      'bdemr--visit-advised-test': 'visit-advised-test',
      'bdemr--patient-gallery--online-attachment': 'patient-gallery--online-attachment',
      'bdemr--pcc-records': 'pcc-records',
      'bdemr--patient-test-results': 'patient-test-results',
      'bdemr--ndr-records': 'ndr-records',
    }

    data = {
      apiKey: @user.apiKey
      client: 'clinic'
      knownPatientSerialList: [ serial ]
    }
    @callApi '/bdemr--get-patient-data-on-import', data, (err, response)=>
      @domHost.toggleModalLoader()
      if err
        return @domHost.showModalDialog(err)
      else if response.hasError 
        return @domHost.showModalDialog(response.error.message)
      else 
        app.db.__allowCommit = false
        for item, index in response.data
          # console.log item.collection
          collectionName = collectionNameMap[item.collection];
          delete item.collection
          if index is (response.data.length - 1) 
            app.db.__allowCommit = true
          app.db.upsert(collectionName, item, ({ serial })=> item.serial is serial)
        
        app.db.__allowCommit = true
        cbfn(_id)
  
  removePatientIfAlreadyExist: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier

    if list.length is 1
      patient = list[0]
      app.db.remove 'patient-list', patient._id
      return
    else
      return


}
