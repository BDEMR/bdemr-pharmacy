Polymer {

  is: 'page-patient-manager'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    qrCode:
      type: String
      value: ''

    isQrCodeActive:
      type: Boolean
      value: false

    selectedSearchViewIndex:
      type: Number
      notify: true
      value: 0
      observer: 'subViewIndexChanged'

    selectedTabPageIndex:
      type: Number
      notify: true
      value: 0

    searchContextDropdownSelectedIndex: 
      type: Number
      notify: true
      value: 1

    isAdvancedSearchEnabled: 
      type: Boolean
      notify: true
      value: false

    advancedSearchParameters:
      type: Object
      notify: true
      value:
        createdDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        initialVisitDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        lastVisitDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        admissionDate:
          enabled: false
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()
        handledDate:
          lowerBound: lib.datetime.mkDate lib.datetime.now()
          upperBound: lib.datetime.mkDate lib.datetime.now()

    arbitaryCounter:
      type: Number
      notify: true
      value: 0

    matchingPatientList:
      type: Array
      notify: true
      value: []

    searchFieldMainInput: 
      type: String
      notify: true
      value: ''
      
    user:
      type: Object
      notify: true
      value: null

    currentDateFilterStartDate:
      type: Number

    currentDateFilterEndDate:
      type: Number

    resultedPatientList:
      type: Array
      notify: true
      value: []

    matchingVisitedPatientLogList:
      type: Array
      notify: true
      value: []

    filteredPatientVisitedPatientLogList:
      type: Array
      notify: true
      value: []

    organizationsIBelongToList:
      type: Array
      value: -> []

    conflictedPatientList:
      type: Array
      value: -> []
    
    recordStatsList:
      type: Array
      value: -> []
    
    statsList:
      type: Array
      value: -> []
    
    childOrganizationList:
      type: Array
      notify: true
      value: []

    loading:
      type: Boolean
      value: false
    
    loadingForPcc:
      type: Boolean
      value: false
    
    loadingForNwdr:
      type: Boolean
      value: false
    
    # nwdr - start 

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
      value: -> []
    
    searchQuery:
      type: Object
      value: {}

    nwdrPatientCounter:
      type: Number
      value: 0
    
    dateCreatedFrom:
      type: String
      value: null
    
    dateCreatedTo:
      type: String
      value: null

    # nwdr - end

    # pcc - end 
    pccPatientList:
      type: Array
      notify: true
      value: []

    selectedDateRangeIndexForPcc:
      type: Number
      value: 0
      notify: true
      observer: 'selectedDateRangeIndexChangedForPcc'

    dayRangeTypeListForPcc:
      type: Array
      notify: true
      value: -> []

    pccPatientCounter:
      type: Number
      value: 0
    
    dateCreatedFromForPcc:
      type: String
      value: null
    
    dateCreatedToForPcc:
      type: String
      value: null
    
    # org - end 
    userPatientList:
      type: Array
      notify: true
      value: []

    selectedDateRangeIndexForUser:
      type: Number
      value: 0
      notify: true
      observer: 'selectedDateRangeIndexChangedForUser'

    dayRangeTypeListForUser:
      type: Array
      notify: true
      value: -> []

    userPatientCounter:
      type: Number
      value: 0
    
    dateCreatedFromForUser:
      type: String
      value: null
    
    dateCreatedToForUser:
      type: String
      value: null
    
    barcode:
      type: String
      value: null
      observer: '_barcodeChanged'

    selectedGender: String
    selectedOrganizationId: String
  
  _resetSearchQuery: ()->
    @set 'searchQuery', {
      name: ''
      phoneNumber: ''
      emailAddress: ''
      serial: ''
      nationalIdCardNumber: ''
      patientIdByOrganization: ''
    }

  _loadUser:(cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      cbfn()

  loadConflictedPatientList: ()->
    list = app.db.find 'conflicted-patient-list'
    @conflictedPatientList = list
    # console.log 'conflictedPatientList', @conflictedPatientList

  checkAndUpdateConflictedPatientData: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#conflicted-patient-repeater'

    index = repeater.indexForElement el
    patient = @conflictedPatientList[index]

    @_importPatient patient.data.serial, patient.doctorAccessPin, (importedPatientLocalId)=>
      # console.log 'PATIENT', patient
      @updatePatientSerialOnExisitingRecords patient.data.serial, patient.oldSerial, =>
        @_removeLocalPatient patient.oldSerial, =>
          @loadConflictedPatientList()
          @domHost.showToast 'Patient Data Updated!'


  _removeLocalPatient: (oldSerial, cbfn)->
    id = (app.db.find 'conflicted-patient-list', ({oldSerial})-> oldSerial is oldSerial)[0]._id
    app.db.remove 'conflicted-patient-list', id

    id = (app.db.find 'patient-list', ({serial})-> serial is oldSerial)[0]._id
    app.db.remove 'patient-list', id

    console.log 'Deleted'
    cbfn()


  checkAndupdateSerialOnCollection: (newSerial, oldSerial, collectionName)->
    list = app.db.find collectionName, ({patientSerial})-> patientSerial is oldSerial

    if list.length > 0
      for item in list
        item.patientSerial = newSerial
        app.db.update collectionName, item._id, item


  updatePatientSerialOnExisitingRecords: (patientActualSerial, patientOldSerial, cbfn)->
    collectionMap = ['unregsitered-patient-details', 'doctor-visit', 'covid-test-result', 'visit-advised-test', 'patient-test-results', 'patient-gallery--local-attachment', 'patient-gallery--online-attachment', 'in-app-notification', 'local-patient-pin-code-list', 'patient-invoice', 'visit-patient-stay', 'visited-patient-log', 'pcc-records', 'ndr-records', 'offline-patient-pin']

    for collectionName in collectionMap
      @checkAndupdateSerialOnCollection patientActualSerial, patientOldSerial, collectionName

    cbfn()


  _organizationNavigatedIn: ->
    data = { 
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-organization-list-those-user-belongs-to', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @organizationsIBelongToList = response.data.organizationObjectList

  onPageIndexChange: ()->
    if @selectedSearchViewIndex is 1
      @listAllImportedAndOfflinePatientsPressed()


  # REGION :: stats - start ------>

  _loadAppStats: (cbfn)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      daysRange: @_createDateRange()
      userSerial: @user.serial
    }
    @callApi '/bdemr--get-clinic-app-stats', data, (err, response)=>
      # console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_makeNdrPccStats response.data
        @_makeObjectForStats response.data
        @_makeUserPatientStats response.data
        cbfn()
  
  _createDateRange: ()->
    daysRange = {}
   
    #today
    today = new Date()
    daysRange.today = today
    daysRange.todayStart = today.setHours(0, 0, 0, 0)
    daysRange.todayEnd = today.setHours(23, 59, 59, 999)

    #yesterday
    yesterday = new Date(new Date().setDate(new Date().getDate()-1))
    daysRange.yesterdayStart = yesterday.setHours(0, 0, 0, 0)
    daysRange.yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

    #thisWeek
    thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
    thisWeekEnd = new Date()
    daysRange.thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
    daysRange.thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

    #last30days
    last30Days = new Date(new Date().setDate(new Date().getDate()-30))
    today = new Date()
    daysRange.last30DaysStart = last30Days.setHours(0, 0, 0, 0)
    daysRange.last30DaysEnd = today.setHours(23, 59, 59, 999)

    return daysRange
  
  

  _makeNdrPccStats: (stats)->
    pccNdrStats = stats.pccNdrStats

    dayRangeTypeList = [
      {
        type: 'Today'
        daysCount: 0
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.ndrTodaysPatientsCount
        patientCount: pccNdrStats.ndrTodaysPatientsCount
        bgColor: 'bg indigo'
      }
      
      {
        type: 'All'
        recordLabel: 'Records'
        patientLabel: 'Patients'
        daysCount: -1
        recordCount: pccNdrStats.ndrAllTimeRecordCount
        patientCount: pccNdrStats.ndrAllTimePatientsCount
        bgColor: 'bg brown'
      }

      {
        type: 'Yesterday'
        daysCount: 1
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.ndrYesterdayPatientsCount
        patientCount: pccNdrStats.ndrYesterdayPatientsCount
        bgColor: 'bg gray'
      }

      {
        type: 'This week'
        daysCount: 7
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.ndrWeeklyRecordCount
        patientCount: pccNdrStats.ndrWeeklyPatientsCount
        bgColor: 'bg green'
      }

      {
        type: 'This month'
        daysCount: 30
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.ndrMonthlyRecordCount
        patientCount: pccNdrStats.ndrMonthlyPatientsCount
        bgColor: 'bg blue'
      }

      {
        type: 'Custom Date'
        daysCount: -1
        recordLabel: ''
        patientLabel: ''
        bgColor: 'bg purple'
      }
    ]

    @set 'dayRangeTypeList', dayRangeTypeList

    pccNdrStats = stats.pccNdrStats

    dayRangeTypeListForPcc = [
      {
        type: 'Today'
        daysCount: 0
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.pccTodaysPatientsCount
        patientCount: pccNdrStats.pccTodaysPatientsCount
        bgColor: 'bg indigo'
      }
      
      {
        type: 'All'
        recordLabel: 'Records'
        patientLabel: 'Patients'
        daysCount: -1
        recordCount: pccNdrStats.pccAllTimeRecordCount
        patientCount: pccNdrStats.pccAllTimePatientsCount
        bgColor: 'bg brown'
      }

      {
        type: 'Yesterday'
        daysCount: 1
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.pccYesterdayPatientsCount
        patientCount: pccNdrStats.pccYesterdayPatientsCount
        bgColor: 'bg gray'
      }

      {
        type: 'This week'
        daysCount: 7
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.pccWeeklyRecordCount
        patientCount: pccNdrStats.pccWeeklyPatientsCount
        bgColor: 'bg green'
      }

      {
        type: 'This month'
        daysCount: 30
        recordLabel: 'Records'
        patientLabel: 'Patients'
        recordCount: pccNdrStats.pccMonthlyRecordCount
        patientCount: pccNdrStats.pccMonthlyPatientsCount
        bgColor: 'bg blue'
      }

      {
        type: 'Custom Date'
        daysCount: 0
        recordLabel: ''
        patientLabel: ''
        bgColor: 'bg purple'
      }
    ]

    @set 'dayRangeTypeListForPcc', dayRangeTypeListForPcc

    # console.log @dayRangeTypeList
  
  _makeObjectForStats:(stats)->
    
    statsList = [
      {
        name: 'Patients Registered by Me'
        type: 'user-patient-status'
        herf: ''
        templateType: 'default'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        list: [
          {
            name: 'Today';
            count: stats.patientStats.todayTotalPatientCount
          }
          {
            name: 'Yesterday'
            count: stats.patientStats.yesterdayTotalPatientCount
          }
          {
            name: 'This Week'
            count: stats.patientStats.weeklyTotalPatientCount
          }
          {
            name: 'This month'
            count: stats.patientStats.last30DaysTotalPatientCount
          }
          {
            name: 'Alltime'
            count: stats.patientStats.allTimeTotalPatientCount
          }
        ]
      } 
      {
        name: "Today's Chamber Booking Statistics"
        type: 'organization-chamber-status'
        herf: 'booking'
        templateType: 'multi'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        list: stats.chamberStats
      }
    
    ]
    # console.log {statsList}
    @set 'statsList', statsList
  
  _getTodaysDateString:()->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day

    return [year, month, day].join('-')
  
  goToSelectedPage: (e)->
    { stats } = e.model
    {chamber} = e.model
    console.log chamber
    if stats.type is 'organization-chamber-status'
      @domHost.navigateToPage '#/' + stats.herf

    if stats.type is 'user-operation-status'
      @domHost.navigateToPage '#/' + stats.herf

  goToSelectedOrganizationSpecificRecordsPage: (e)->
    { feature } = e.model
    @domHost.navigateToPage '#/' + feature.herf
  
  # REGION :: stats - end ------>

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1
  
  _loadOrganization: (cbfn)->
    @organization = (app.db.find 'organization')[0]
    cbfn()

  subViewIndexChanged: (value)->
    if value is 2
      @_listVisitedPatientLog()


  # REGION :: NDR Patient List - start ------>
  selectedDateRangeIndexChanged: (selectedPageIndex)->
   
    # Today
    if selectedPageIndex is 0
      today = new Date()
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', todayStart
      @set 'dateCreatedTo', todayEnd

    # All
    if selectedPageIndex is 1
      @set 'dateCreatedFrom', null
      @set 'dateCreatedTo', null

    if selectedPageIndex is 2
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', yesterdayStart
      @set 'dateCreatedTo', yesterdayEnd

    if selectedPageIndex is 3

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', thisWeekStart
      @set 'dateCreatedTo', thisWeekEnd

    if selectedPageIndex is 4

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFrom', last30Days
      @set 'dateCreatedTo', today

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

  _loadOrganizationWiseNwdrSpecifiPatientList: ()->

    query =
      apiKey: this.user.apiKey
      organizationIdList: []
      searchParameters:
        dateCreatedFrom: this.dateCreatedFrom
        dateCreatedTo: this.dateCreatedTo

    query.organizationIdList.push this.organization.idOnServer

    @loadingForNwdr = true

    @callApi '/get-organization-specific-nwdr-patient-list', query, (err, response) =>
      @loadingForNwdr = false

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
  
  # REGION :: NDR Patient List - end ------>

  # REGION :: PCC Patient List - start ------>
  selectedDateRangeIndexChangedForPcc: (selectedPageIndexForPcc)->
   
    # Today
    if selectedPageIndexForPcc is 0
      today = new Date()
      # console.log today.setHours(23, 59, 59)
      # console.log today.setHours(23, 59, 59, 999)
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForPcc', todayStart
      @set 'dateCreatedToForPcc', todayEnd

    # All
    if selectedPageIndexForPcc is 1
      @set 'dateCreatedFromForPcc', null
      @set 'dateCreatedToForPcc', null

    if selectedPageIndexForPcc is 2
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForPcc', yesterdayStart
      @set 'dateCreatedToForPcc', yesterdayEnd

    if selectedPageIndexForPcc is 3

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForPcc', thisWeekStart
      @set 'dateCreatedToForPcc', thisWeekEnd

    if selectedPageIndexForPcc is 4

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForPcc', last30Days
      @set 'dateCreatedToForPcc', today

    if @user and @organization

      @_loadOrganizationWisePccSpecificPatientList()

  filterByDateClickedForPcc: (e)->
    startDate = new Date(e.detail.startDate)
    startDate.setHours(0, 0, 0, 0)
    endDate = new Date(e.detail.endDate)
    endDate.setHours(23, 59, 59, 999)
    @set 'dateCreatedFromForPcc', startDate.getTime()
    @set 'dateCreatedToForPcc', endDate.getTime()

  filterByDateClearButtonClickedForPcc:()->
    @dateCreatedFromForPcc = 0
    @dateCreatedToForPcc = 0

  filterButtonClickedForPcc: ()->
    @_loadOrganizationWisePccSpecificPatientList()

  _loadOrganizationWisePccSpecificPatientList: ()->
 
    query =
      apiKey: this.user.apiKey
      organizationIdList: []
      searchParameters:
        dateCreatedFrom: this.dateCreatedFromForPcc
        dateCreatedTo: this.dateCreatedToForPcc

    query.organizationIdList.push this.organization.idOnServer


    @laodingForPcc = true
    @callApi '/get-organization-specific-pcc-patient-list', query, (err, response) =>
      if err or !response
        return @domHost.showModalDialog 'Server Error'
      if response.hasError
        @pccPatientList = []
        @set 'pccPatientCounter', 0
        return
      else
        @pccPatientList = response.data

        @set 'pccPatientCounter', response.data.length
      @laodingForPcc = false
  
  _checkIfPatientAvailableOrImport:(patientSerial, cbfn)->
    localPatientList = app.db.find 'patient-list', ({serial})-> serial is patientSerial

    if localPatientList.length is 1
      patient = localPatientList[0]
      cbfn patient
      return
    else
      @domHost.showModalInput "Please enter patient PIN", "0000", (answer)=>
        if answer
          @_importPatient patientSerial, answer, (importedPatientLocalId)=>

            patient = (app.db.find 'patient-list', ({serial})-> serial is patientSerial)[0]

            savePinOffline = { serial: patientSerial, pin: answer}
            app.db.insert 'offline-patient-pin', savePinOffline
            cbfn patient
    

  viewNdrPatient: (e)->
    index = e.model.index
    patientSerial = @nwdrPatientList[index].serial
    @_checkIfPatientAvailableOrImport patientSerial, (patient)=>
      @goPatientViewPage patient
  
  viewPccPatient: (e)->
    index = e.model.index
    patientSerial = @pccPatientList[index].serial
    @_checkIfPatientAvailableOrImport patientSerial, (patient)=>
      @goPatientViewPage patient
  
  # REGION :: PCC Patient List - end ------>

  # REGION :: Org Patient List - start ------>
  _makeUserPatientStats: (stats)->

    userPatientStats = [
      {
        type: 'Today'
        daysCount: 0
        patientLabel: 'Patients'
        patientCount: stats.patientStats.todayTotalPatientCount
        bgColor: 'bg indigo'
      }
      
      {
        type: 'All'
        patientLabel: 'Patients'
        daysCount: -1
        patientCount: stats.patientStats.allTimeTotalPatientCount
        bgColor: 'bg brown'
      }

      {
        type: 'Yesterday'
        daysCount: 1
        patientLabel: 'Patients'
        patientCount: stats.patientStats.yesterdayTotalPatientCount
        bgColor: 'bg gray'
      }

      {
        type: 'This week'
        daysCount: 7
        patientLabel: 'Patients'
        patientCount: stats.patientStats.weeklyTotalPatientCount
        bgColor: 'bg green'
      }

      {
        type: 'This month'
        daysCount: 30
        patientLabel: 'Patients'
        patientCount: stats.patientStats.last30DaysTotalPatientCount
        bgColor: 'bg blue'
      }

      {
        type: 'Custom Date'
        daysCount: 0
        recordLabel: ''
        patientLabel: ''
        bgColor: 'bg purple'
      }
    ]

    @set 'userPatientStats', userPatientStats
  
  selectedDateRangeIndexChangedForUser: (selectedPageIndexForUser)->
   
    # Today
    if selectedPageIndexForUser is 0
      today = new Date()
      # console.log today.setHours(23, 59, 59)
      # console.log today.setHours(23, 59, 59, 999)
      todayStart = today.setHours(0, 0, 0, 0)
      todayEnd = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForUser', todayStart
      @set 'dateCreatedToForUser', todayEnd

    # All
    if selectedPageIndexForUser is 1
      @set 'dateCreatedFromForUser', null
      @set 'dateCreatedToForUser', null

    if selectedPageIndexForUser is 2
      yesterday = new Date(new Date().setDate(new Date().getDate()-1))

      yesterdayStart = yesterday.setHours(0, 0, 0, 0)
      yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForUser', yesterdayStart
      @set 'dateCreatedToForUser', yesterdayEnd

    if selectedPageIndexForUser is 3

      thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
      thisWeekEnd = new Date()

      thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
      thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForUser', thisWeekStart
      @set 'dateCreatedToForUser', thisWeekEnd

    if selectedPageIndexForUser is 4

      last30Days = new Date(new Date().setDate(new Date().getDate()-30))
      today = new Date()

      last30Days = last30Days.setHours(0, 0, 0, 0)
      today = today.setHours(23, 59, 59, 999)

      @set 'dateCreatedFromForUser', last30Days
      @set 'dateCreatedToForUser', today

    if @user and @organization

      @_loadUserPatientList()

  filterByDateClickedForUser: (e)->
    startDate = new Date(e.detail.startDate)
    startDate.setHours(0, 0, 0, 0)
    endDate = new Date(e.detail.endDate)
    endDate.setHours(23, 59, 59, 999)
    @set 'dateCreatedFromForUser', startDate.getTime()
    @set 'dateCreatedToForUser', endDate.getTime()

  filterByDateClearButtonClickedForPcc:()->
    @dateCreatedFromForUser = 0
    @dateCreatedToForUser = 0

  filterButtonClickedForUser: ()->
    @_loadUserPatientList()

  _loadUserPatientList: ()->

    query =
      apiKey: this.user.apiKey
      searchParameters: 
        dateCreatedFrom: this.dateCreatedFromForUser
        dateCreatedTo: this.dateCreatedToForUser
      
    @loading = true

    @callApi '/get-user-patient-list', query, (err, response) =>
      @loading = false
      # console.log response
      if err or !response
        return @domHost.showModalDialog 'Server Error'
      if response.hasError
        @pccPatientList = []
        @set 'userPatientCounter', 0
        return
      else
        @set 'userPatientList', response.data
        @set 'userPatientCounter', response.data.length
      
      
  

  viewUserPatient: (e)->
    index = e.model.index
    patientSerial = @userPatientList[index].serial
    @_checkIfPatientAvailableOrImport patientSerial, (patient)=>
      @goPatientViewPage patient

  # REGION :: User Patient List - end ------>

  initBarcode:()->
    # console.log 'hello form init barcode'
    # console.log @$$('#scanner')

    Quagga.init {
      inputStream:
        name: 'Live'
        type: 'LiveStream'
        target: @$$('.scanner')
      decoder: readers: [ 'code_128_reader' ]
    }, (err) ->
      if err
        # console.log err
        return
      # console.log 'Initialization finished. Ready to start'
      Quagga.start()
      return
  
  _onQrCodeChanged: (e)->
    code = e.detail.result.text
    if code.length is 6
      @_callCheckPatientQrCode code

    if code.length > 0
      @_callCheckPatientQrCodeStatic code
    
  
  _callCheckPatientQrCode: (code) ->
    data = { 
      apiKey: @user.apiKey
      code: code
    }
    @callApi '/check-patients-qrcode', data, (err, response)=>
      if response.hasError
        @_dismissQrcodeDialog()
        @domHost.showModalDialog response.error.message
      else
        patient = response.data
        @_importPatient patient.serial, patient.doctorAccessPin, (importedPatient)=>
          # savePinOffline = { serial: patient.serial, pin: answer}
          # app.db.insert 'offline-patient-pin', savePinOffline
          @_dismissQrcodeDialog()
          @goPatientViewPage importedPatient
  
  _callCheckPatientQrCodeStatic: (code) ->
    data = { 
      apiKey: @user.apiKey
      code: code
    }
    @callApi '/check-patients-qrcode-static', data, (err, response)=>
      if response.hasError
        @_dismissQrcodeDialog()
        @domHost.showModalDialog response.error.message
      else
        patient = response.data
        @_importPatient patient.serial, patient.doctorAccessPin, (importedPatient)=>
          # savePinOffline = { serial: patient.serial, pin: answer}
          # app.db.insert 'offline-patient-pin', savePinOffline
          @_dismissQrcodeDialog()
          @goPatientViewPage importedPatient


  navigatedIn: ->
    @_resetSearchQuery()
    @_loadUser =>

      @_loadOrganization =>
        # console.log @organization
        # unless @organization
        #   return @domHost.navigateToPage "#/select-organization"
        
        @_loadAppStats =>
          @_loadUserPatientList()
          @_loadOrganizationWiseNwdrSpecifiPatientList()
          @_loadOrganizationWisePccSpecificPatientList()
          @set 'selectedDateRangeIndexForUser', 0
          @set 'selectedDateRangeIndex', 0
          @set 'selectedDateRangeIndexForPcc', 0


        patientList = app.db.find 'patient-list', ({isForUseranizationOnly})-> isForUseranizationOnly is true
        for patient in patientList
          app.db.remove 'patient-list', patient._id

        @_organizationNavigatedIn()

        @loadConflictedPatientList()

        # @domHost.setCurrentPatientsDetails null

        if @domHost.__patientView__oneTimeSearchFilter
          @oneTimeSearchFilter = @domHost.__patientView__oneTimeSearchFilter

        params = @domHost.getPageParams()

        if params['selected']
          @set "selectedSearchViewIndex", parseInt params['selected']
        else
          @set "selectedSearchViewIndex", 0

          
        if params['filter'] and params['filter'] is 'today-only'
          @domHost.modifyCurrentPagePath '#/patient-manager'
          @searchFieldMainInput = ''
          @isAdvancedSearchEnabled = false
          @set 'advancedSearchParameters.createdDate.enabled', true
          @set 'advancedSearchParameters.createdDate.lowerBound', lib.datetime.mkDate lib.datetime.now()
          @set 'advancedSearchParameters.createdDate.upperBound', lib.datetime.mkDate lib.datetime.now()
          @listAllImportedAndOfflinePatientsPressed null
        else if params['filter'] and params['filter'] is 'clear'
          @domHost.modifyCurrentPagePath '#/patient-manager'
          @isAdvancedSearchEnabled = false
          @searchFieldMainInput = ''
          @listAllImportedAndOfflinePatientsPressed null

        else if params['query']
          @searchFieldMainInput = params['query']
          @searchOnlineButtonPressed()
          # @importPatientPressed()

        else if params['unregsiterd']
          @searchFieldMainInput = params['unregsiterd']
          @searchOfflineButtonPressed()

        else
          @listAllImportedAndOfflinePatientsPressed null
        
        # @initBarcode()


  searchButtonPressed: (e)->
    if @searchContextDropdownSelectedIndex is 1
      @_searchOnline()
    else
      @_searchOffline()

  listAllImportedAndOfflinePatientsPressed: (e)->
    @searchFieldMainInput = ''
    @searchContextDropdownSelectedIndex = 0
    @searchButtonPressed null    

  searchOfflineButtonPressed: (e)->
    if @searchFieldMainInput.length is 0
      return @domHost.showModalDialog "Please enter something to search with."
    @searchContextDropdownSelectedIndex = 0
    @searchButtonPressed null

  searchOnlineEnterKeyPressed: (e)->
    return unless e.keyCode is 13
    @_searchOnline()
  
  searchByFieldBtnPressed: ()->
    @searchContextDropdownSelectedIndex = 1
    @searchButtonPressed nul
  
  searchOnlineButtonPressed: (e)->
    @searchContextDropdownSelectedIndex = 1
    @searchButtonPressed null
    

  _searchOnline: ->
    @matchingPatientList = []
    @arbitaryCounter++

    @callApi '/bdemr-patient-search-by-field', { apiKey: @user.apiKey, searchQuery: @searchQuery}, (err, response)=>
      @arbitaryCounter--
      @_resetSearchQuery()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        matchingPatientList = response.data
        for patient in matchingPatientList
          patient.flags = {
            isImported: false
            isLocalOnly: false
            isOnlineOnly: false
          }
          localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.serial
          if localPatientList.length is 0
            patient.flags.isOnlineOnly = true
          else
            patient.flags.isImported = true
            patient._tempLocalDbId = localPatientList[0]._id
        @matchingPatientList = matchingPatientList
        # console.log 'matchingPatientList', @matchingPatientList
  
  _searchOffline: ->
    @arbitaryCounter++
    ## Basic Search
    searchFieldMainInput = @searchFieldMainInput

    if searchFieldMainInput.length is 0  and false
      patientList = app.db.find 'patient-list'
    else
      patientList = app.db.find 'patient-list', ({serial, name, email, phone, nIdOrSsn, hospitalNumber, initialVisitDate, lastVisitDate, admissionDate})=>
  
        if @oneTimeSearchFilter
          condition1 = (''+serial) is ('' + @oneTimeSearchFilter)
          condition2 = false
          condition3 = false
          condition4 = false
          condition5 = false
        else
          condition1 = (name.first.indexOf searchFieldMainInput) > -1
          condition2 = (email.indexOf searchFieldMainInput) > -1
          condition3 = (phone.indexOf searchFieldMainInput) > -1
          condition4 = (serial.indexOf searchFieldMainInput) > -1
          condition5 = try (nIdOrSsn.indexOf searchFieldMainInput) > -1 catch ex then false
          ## NOTE:
          # Found to be commented out on master when shafayet merged
          # his interoperability issues branch. shafayet did not comment 
          # this out.

        isAdvancedSearchPassed = true

        ## Advanced Search
        isAdvancedSearchEnabled = @isAdvancedSearchEnabled
        if isAdvancedSearchEnabled
          if @advancedSearchParameters.initialVisitDate.enabled
            left = new Date @advancedSearchParameters.initialVisitDate.lowerBound
            middle = new Date initialVisitDate
            right = new Date @advancedSearchParameters.initialVisitDate.upperBound
            if left.getTime() <= middle.getTime() <= right.getTime()
              isAdvancedSearchPassed = true
            else
              isAdvancedSearchPassed = false
          else if @advancedSearchParameters.lastVisitDate.enabled
            left = new Date @advancedSearchParameters.lastVisitDate.lowerBound
            middle = new Date lastVisitDate
            right = new Date @advancedSearchParameters.lastVisitDate.upperBound
            if left.getTime() <= middle.getTime() <= right.getTime()
              isAdvancedSearchPassed = true
            else
              isAdvancedSearchPassed = false
          else if @advancedSearchParameters.admissionDate.enabled
            left = new Date @advancedSearchParameters.admissionDate.lowerBound
            middle = new Date admissionDate
            right = new Date @advancedSearchParameters.admissionDate.upperBound
            if left.getTime() <= middle.getTime() <= right.getTime()
              isAdvancedSearchPassed = true
            else
              isAdvancedSearchPassed = false

        return (condition1 or condition2 or condition3 or condition4 or condition5 ) and isAdvancedSearchPassed

    @oneTimeSearchFilter = null

    ## Modify Results
    for patient in patientList
      unless 'flags' of patient
        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isLocalOnly = true

    ## Show results
    @matchingPatientList = patientList
    @arbitaryCounter--


  clearSearchResultsClicked: (e)->
    @matchingPatientList = []

  moreOptionsPressed: (e)->
    @domHost.showModalDialog 'You can search records (instead of patients) by many other options including diseases from the "Record Manager" option from the left menu.'

  newPatientFabPressed: (e)->
    # @domHost.navigateToPage '#/patient-editor/patient:new'
    @domHost.navigateToPage '#/patient-signup'

  newPCCPatient: (e)->
    # @domHost.navigateToPage '#/preconception-record/record:new/patients:new'
    @domHost.navigateToPage '#/patient-signup'

  ## ------------------ import / publish start

  _getPinForLocalPatient: (patientIdentifier)->
    list = app.db.find 'local-patient-pin-code-list', ({patientSerial})=> patientSerial is patientIdentifier
    if list.length is 1
      pin = list[0].pin
      return pin
    else return null

  _savePinForLocalPatient: (pin, patientSerial)->
    patientPinObject = {}
    patientPinObject.organizationId = @organization.idOnServer
    patientPinObject.patientSerial = patientSerial
    patientPinObject.pin = pin

    app.db.upsert 'local-patient-pin-code-list', patientPinObject, ({patientSerial})=> patientPinObject.patientSerial is patientSerial

  _publishPatient: (patient, pin, cbfn)->
    @callApi '/bdemr-patient-publish', {patient: patient, pin: pin}, (err, response)=>
      if response.hasError
        if response.error.message is 'U_PIN_ERR'
          @domHost.showModalInput "Please enter correct patient PIN", "0000", (answer)=>
            if answer
              @_publishPatient patient, answer, cbfn
        else
          @domHost.showModalDialog response.error.message
      else
        if response.data.status is 'success'

          pin = @_getPinForLocalPatient patient.serial

          @_importPatient patient.serial, pin, (importedPatientLocalId)=>
            app.db.remove 'patient-list', patient._id
            @searchContextDropdownSelectedIndex = 0
            @oneTimeSearchFilter = patient.serial
            @searchButtonPressed null
        else
          # console.log response.data
          @domHost.showModalDialog ("Unkown response " + response.data.status)

  publishPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.showModalPrompt "Publishing will overwrite remote changes (if any). Continue?", (answer)=>
      if answer
        @_publishPatient patient, null, (updatedPatient)=>
          # console.log 'publishing completed', updatedPatient

  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-import-patient-data', {apiKey: @user.apiKey, serial: serial, pin: pin, organizationId: @organization.idOnServer, userName: @user.name}, (err, response)=>
      # console.log "bdemr-patient-import-new", response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        
        patient = response.data.patient

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


        @_importPatientData patient.serial, _id, =>
          cbfn patient

  _importPatientData: (serial, _id, cbfn)->
    @domHost.toggleModalLoader 'Importing Patient Data. Please Wait...'
    collectionNameMap = {
      'bdemr--doctor-visit': 'doctor-visit',
      'bdemr--patient-type-logs': 'patient-type-logs',
      'bdemr--patient-invoice': 'patient-invoice',
      'bdemr--patient-stay': 'visit-patient-stay',
      'bdemr--visit-advised-test': 'visit-advised-test',
      'bdemr--patient-gallery--online-attachment': 'patient-gallery--online-attachment',
      'bdemr--pcc-records': 'pcc-records',
      'bdemr--patient-test-results': 'patient-test-results',
      'bdemr--ndr-records': 'ndr-records',
      'bdemr--covid-test-result': 'covid-test-result',
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
  
  _callImportPatients: (patient)->
    offlinePin = @_getPinForLocalPatient patient.serial

    if patient.idOnServer
      if offlinePin
        @_importPatient patient.serial, offlinePin, (importedPatient)=>
          @searchFieldMainInput = ''
          @searchContextDropdownSelectedIndex = 0
          @oneTimeSearchFilter = patient.serial
          @listAllImportedAndOfflinePatientsPressed null
          @goPatientViewPage importedPatient
      else
        @domHost.showModalInput "Please enter patient PIN", "0000", (answer)=>
          if answer
            @_importPatient patient.serial, answer, (importedPatient)=>
              @searchFieldMainInput = ''
              @searchContextDropdownSelectedIndex = 0
              @oneTimeSearchFilter = patient.serial
              @listAllImportedAndOfflinePatientsPressed null
              savePinOffline = { serial: patient.serial, pin: answer}
              app.db.insert 'offline-patient-pin', savePinOffline
              @goPatientViewPage importedPatient

    else
      @_importPatient patient.serial, null, (importedPatient)=>
        @searchFieldMainInput = ''
        @searchContextDropdownSelectedIndex = 0
        @oneTimeSearchFilter = patient.serial
        @listAllImportedAndOfflinePatientsPressed null

  importPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'
    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @_callImportPatients patient
  

  goPatientViewPage: (patient)->
    # console.log {patient}
    @domHost.setCurrentPatientsDetails patient
    @createdPatientVisitedLog patient
    @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:0'
    @domHost.selectedPatientPageIndex = 5




  importLatestPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.showModalPrompt "Fetching latest will discard local changes. Continue?", (answer)=>
      if answer
        app.db.remove 'patient-list', patient._id
        @importPatientPressed e

  putInWaitlistTapped: (e)->

    { organization } = e.model

    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    window.waitListTempPatient = patient
    
    return @domHost.navigateToPage "#/put-patient-to-waitlist/organization:#{organization.idOnServer}/patient:#{patient.serial}"


    # @domHost.showModalInput "Department/Waitlist/Subwaitlist [optional]", "None", (answer)=>
    #   return unless typeof answer is 'string'
    #   obj = {
    #     apiKey: @user.apiKey
    #     patientSerial: patient.serial
    #     patientNameManuallyEntered: patient.name
    #     details: answer
    #     organizationId: organization.idOnServer
    #   }
    #   @callApi '/bdemr-organization-waitlist-add-entry', obj, (err, response)=>
    #     if response.hasError
    #       @domHost.showModalDialog response.error.message
    #     else
    #       @domHost.showModalDialog response.data


  ## ------------------ import / publish end

  


  viewPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    # console.log 'PATIENT', patient

    @createdPatientVisitedLog patient

    @domHost.setCurrentPatientsDetails patient

    # @domHost.navigateToPage '#/visit-editor/visit:new/patient:' + patient.serial
    @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:0'
    @domHost.selectedPatientPageIndex = 5

  # editPatientPreconceptionRecord: (e)->
  #   el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
  #   el.opened = false
  #   repeater = @$$ '#patient-list-repeater'

  #   index = repeater.indexForElement el
  #   patient = @matchingPatientList[index]

  #   @domHost.navigateToPage '#/preconception-record/patients:' + patient.serial


  editPatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.navigateToPage  '#/patient-editor/patient:' + patient.serial

  
  addPatientTemplate: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'
    index = repeater.indexForElement el
    patient = @matchingPatientList[index]
    @domHost.navigateToPage  '#/patient-template/patient:' + patient.serial


  deletePatientPressed: (e)->
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.showModalPrompt 'Are you sure?', (answer)=>
      if answer is true
        _id = patient._id
        if not _id and _id isnt 0
          _id = patient._tempLocalDbId
        app.db.remove 'patient-list', (_id)
        @searchButtonPressed null

  $or: (a, b)-> a or b

  $log: (obj)->
    # console.log obj


  searchResultFilterByDateClicked: (e)->
    if @resultedPatientList.length is 0
      @resultedPatientList = @matchingPatientList

    @currentDateFilterStartDate = e.detail.startDate
    @currentDateFilterEndDate = e.detail.endDate

    startDate = new Date e.detail.startDate
    endDate = new Date e.detail.endDate
    endDate.setHours 24 + endDate.getHours()
    filterdList = (item for item in @resultedPatientList when (startDate.getTime() <= (new Date item.lastModifiedDatetimeStamp).getTime() <= endDate.getTime()))
    @matchingPatientList = filterdList

  searchResultFilterByDateClearButtonClicked: (e)->
    @currentDateFilterStartDate = null
    @currentDateFilterEndDate = null
    @matchingPatientList = @resultedPatientList
    @resultedPatientList = []

  viewPatient: (e)->
    
    el = @locateParentNode e.target, 'PAPER-MENU-BUTTON'
    el.opened = false
    repeater = @$$ '#patient-list-repeater'

    index = repeater.indexForElement el
    patient = @matchingPatientList[index]

    @domHost.setCurrentPatientsDetails patient
    @createdPatientVisitedLog patient
    # @domHost.navigateToPage '#/visit-editor/visit:new/patient:' + patient.serial
    @domHost.selectedPatientPageIndex = 5
    @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:0'


  # Visted Patient Log
  # ================================

  createdPatientVisitedLog: (patient)->

    now = lib.datetime.now()
    
    visitedPatientLogObject = {
      createdByUserId: @user.idOnServer
      organizationId: @organization.idOnServer
      serial: @generateSerialForVisitedPatientLog()
      patientSerial: patient.serial
      patientName: patient.name
      createdDatetimeStamp: now
      visitedDateTimeStamp: now
      lastModifiedDatetimeStamp: now
    }

    data = {
      apiKey: @user.apiKey
      log: visitedPatientLogObject
    }
    @loading = true
    @callApi '/bdemr--create-visited-patient-log', data, (err, response)=>
      @loading = false
      return @domHost.showWarningToast err.message if err
      return @domHost.showWarningToast response.error.message if response.hasError

   
  # a_listVisitedPatientLog: () ->
  #   list = app.db.find 'visited-patient-log'
  #   console.log list
  #   logList = [].concat list
  #   logList.sort (left, right)->
  #     return -1 if left.visitedDateTimeStamp > right.visitedDateTimeStamp
  #     return 1 if left.visitedDateTimeStamp < right.visitedDateTimeStamp
  #     return 0

  #   @matchingVisitedPatientLogList = logList
  #   console.log @matchingVisitedPatientLogList

  _calculateDateOfBirthFromAge:(age)->
    unless age
      return ''
    uptoHour = 24*60*60*1000
    yearTimeInMS = Math.round (Number.parseInt(age)*365*uptoHour)
    dobTime = (new Date).getTime()-yearTimeInMS
    dobDate = new Date ((new Date).setTime(dobTime))
    # tempDOB_Y = dobDate.getFullYear()
    # tempDOB_M = (dobDate.getMonth()+1).toString()
    # if tempDOB_M.length is 1 then tempDOB_M = "0#{tempDOB_M}"

    generatedDOB = "#{dobDate.getFullYear()}-12-31"
    console.log 'date of birth from age : ', generatedDOB
    return generatedDOB



  _listVisitedPatientLog:()->
    query = {
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      dateCreatedFrom: @filterLogByDateCreatedFrom?=''
      dateCreatedTo: @filterLogByDateCreatedTo?=''
      filterPatientName: @filterLogByPatientName?=''
      filterPatientDOB: @_calculateDateOfBirthFromAge @filterLogByPatientAge
      filterPatientAddress: @filterLogByPatientAddress?=''
    }
    # console.log 'visit log query', query
    @loading = true
    @callApi '/bdemr--get-visited-patient-logs', query, (err, response)=>
      @loading = false
      return @domHost.showModalDialog err.message if err
      return @domHost.showModalDialog response.error.message if response.hasError

      visitedLogList = response.data
      visitedLogList.sort (left, right)->
        return -1 if left.visitedDateTimeStamp > right.visitedDateTimeStamp
        return 1 if left.visitedDateTimeStamp < right.visitedDateTimeStamp
        return 0
      @set('matchingVisitedPatientLogList', visitedLogList)
      # console.log 'visited logs', @matchingVisitedPatientLogList
    

  viewPatientPressedFromLog: (e)->
    # el = @locateParentNode e.target, 'PAPER-BUTTON'
    # el.opened = false
    # repeater = @$$ '#visited-patient-log-repeater'

    # index = repeater.indexForElement el
    # patient = @matchingVisitedPatientLogList[index]
    patient = e.model.item

    localPatientList = app.db.find 'patient-list', ({serial})-> serial is patient.patientSerial

    if localPatientList.length
      localPatient = localPatientList[0]

      visitedPatientLogObject = {
        createdByUserSerial: @user.serial
        serial: @generateSerialForVisitedPatientLog()
        patientSerial: patient.patientSerial
        patientName: patient.patientName
        visitedDateTimeStamp: lib.datetime.now()
        lastModifiedDatetimeStamp: lib.datetime.now()
      }

      app.db.insert 'visited-patient-log', visitedPatientLogObject
      @domHost.setCurrentPatientsDetails localPatient
      @domHost.navigateToPage '#/patient-viewer/patient:' + patient.patientSerial
      

    else
      @domHost.showModalInput "Please enter patient PIN", "0000", (answer)=>
        if answer
          @_importPatient patient.patientSerial, answer, (importedPatientLocalId)=>
            @searchFieldMainInput = ''
            @searchContextDropdownSelectedIndex = 0
            @oneTimeSearchFilter = patient.patientSerial
            @listAllImportedAndOfflinePatientsPressed null

       @selectedSearchViewIndex = 0


  searchResultFilterByDateClearButtonClickedForPatientLog: ->
    @filterLogByDateCreatedFrom = ''
    @filterLogByDateCreatedTo = ''

  searchResultFilterByDateClickedForPatientLog: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'filterLogByDateCreatedFrom', startDate.getTime()
    @set 'filterLogByDateCreatedTo', endDate.getTime()


  searchVisitedLog: ()->
    @_listVisitedPatientLog()


  _isEmptyArray: (length)->
    if length is 0
      return true
    else
      return false
  
  _showQrCodeDialog: ()->
    @set 'isQrCodeActive', true
    @$$('#dialogShowQrCode').toggle()
  
  _dismissQrcodeDialog:()->
    @set 'isQrCodeActive', false
    # @set 'barcode', null
    @$$('#dialogShowQrCode').close()
  
  _callCheckOrganizationSpecificPatientId: (code, cbfn) ->
    data = { 
      apiKey: @user.apiKey
      patientId: code
      organizationId: @organization.idOnServer
    }
    @callApi '/bdemr-check-organization-specific-patient-id', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patient = response.data
        cbfn patient
  
  _barcodeChanged:(code)->
    # console.log {code}
    # if code
    #   @_dismissBarcode()
    #   @_callCheckOrganizationSpecificPatientId code, (patient)=>
    #     @_callImportPatients patient
    

}
