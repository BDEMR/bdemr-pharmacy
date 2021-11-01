Polymer {
  
  is: 'page-chamber-patients'

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
    addRemarks:
      type: String
      value: ''

    isQrCodeActive:
      type: Boolean
      value: false
    
    activeUserList:
      type: Array
      value: []
  
    user:
      type: Object
      value: -> (app.db.find 'user')[0]

    organization:
      type: Object
      value: null
    
    chamberShortCode:
      type: Object
      value: null
      
    timeSlotAvailability:
      type: Object
      value: null

    isDefault:
      type: Boolean
      value: false
    isLoading:
      type: Boolean
      value: false
    
    tokenObject:
      type: Object
      value: null
    activeItem:
      observer: '_itemsChanged'
    patientSearchQuery:
      type: String
      value: -> ""
      observer: 'patientSearchInputChanged'   
         
    matchingPatientdata:
      type: Array
      notify: true
      value: ()-> []

    # COPIED THESE CODES BELOW FROM CHAMBER MANAGER TO SHOW THE CHAMBER STAT TABLE IN CHAMBER-PATIENTS PAGE TOO
    matchingChamberList:
      type: Array
      notify: true
      value: ->[]

    chamberSearchString: 
      type: String
      notify: true
      value: ''   
    # End of copied codes for chamber-stat

    scheduleForMonth:
      type: Array
      value: -> []
    hideDone :
      type: Boolean
      value:true
    agentHide :
      type: Boolean
      value:true
    
    bookingList:
      type: Array,
      value: []
    
  listeners:
    'active-users': '_activeUsersHandler'


  showAgentDetails:(e)->
    @set 'agentHide',false

  showChamberDetails:()->
    @$$('#chamber-details').toggle()
  _itemsChanged: ()-> 
    console.log 'selected item', @schedule.bookingList
    this.$.visitList.items = @schedule.bookingList

  _activeUsersHandler: (e)->
    activeUserList = e.detail.activeUserList
    console.log {activeUserList}
    return if !@schedule
    for book, index in @schedule.bookingList
      isOnline = activeUserList.some (item) => book.patientId is item.userId
      @set "schedule.bookingList.#{index}.isOnline", isOnline
      if book.agentId
        isAgentOnline = activeUserList.some (item) => book.agentId is item.userId
        @set "schedule.bookingList.#{index}.isAgentOnline", isAgentOnline

  _notify: (patientId, message)->
    user = @getCurrentUser()
    request = {
      operation: 'notify-single'
      apiKey: user.apiKey
      notificationCategory: 'general'
      notificationMessage: message
      notificationTargetId: patientId
      sender: user.name
    }
    @domHost.socket.emit 'message', request
    
  _getChamber: (cbfn)->
    data = { 
      apiKey: this.user.apiKey
      organizationId: @organization.idOnServer
    }
    @isLoading = true
    this.callApi '/bdemr--get-all-organization-chamber', data, (err, response)=>
      @isLoading = false
      if err
        return this.domHost.showModalDialog err.message
      if response.hasError
        return this.domHost.showModalDialog response.error.message
      
      chamberList = response.data
      for chamber in chamberList
        if chamber.shortCode is this.chamberShortCode
          this.chamber = chamber
          break
      if !this.chamber
        @domHost.toggleModalLoader()
        @domHost.navigateToPage '#/chamber-manager'

      cbfn()
      
  _getScheduleForMonth: (monthString, chamberSerial, cbfn)->
    data = { 
      apiKey: this.user.apiKey
      monthString
      chamberSerial
    }
    @isLoading = true
    this.callApi '/bdemr-booking--doctor--get-schedule-for-month', data, (err, response)=>
      @isLoading = false
      if err
        return this.domHost.showModalDialog err.message
      if response.hasError
        return this.domHost.showModalDialog response.error.message
      
      if response.data.length
        @set 'scheduleForMonth', response.data
        cbfn()
      else
        this.scheduleForMonth = []
        cbfn()

  _getMonthString: ->
    array = this.dateString.split '-'
    array.pop()
    return array.join '-'
  
  _filterScheduleByStatus: (bookingList)->
    return bookingList if bookingList.length is 0
    bookedList = []
    otherList = []

    for item in bookingList
      if item.status is "booked"
        bookedList.push item
      else
        otherList.push item

    return bookedList.concat otherList
  chamberSelected:(e)->
    index = e.detail.selected
    @chamberSelectedData = @matchingChamberList[index]
     
  _getScheduleForDate: (dateString, cbfn)->
    monthString = this._getMonthString()
    this._getScheduleForMonth monthString, this.chamber.serial, =>
      selectedSchedule = null
      for schedule in this.scheduleForMonth
        if dateString is schedule.dateString
          selectedSchedule = schedule
          selectedSchedule.timeSlotList = this._generateTimeSlotList(this.chamber.startTimeString, this.chamber.endTimeString, this.chamber.bookingSlotSizeInMinutes)
      if selectedSchedule
        selectedSchedule.bookingList = @_filterScheduleByStatus selectedSchedule.bookingList
        @set "schedule", selectedSchedule
      if this.schedule
        this._computeTimeSlotAvailability()
      console.log {selectedSchedule}
      # console.log this.schedule
      cbfn()

  _setScheduleForDate: (schedule, cbfn)->
    data = { 
      apiKey: this.user.apiKey
    }
    Object.assign(data, schedule)
    @isLoading = true
    this.callApi '/bdemr-booking--doctor--set-schedule-for-date', data, (err, response)=>
      @isLoading = false
      if err
        return this.domHost.showModalDialog err.message
      if response.hasError
        return this.domHost.showModalDialog response.error.message
      cbfn()
    
  
  _callSendSmsUsingOrganization: (entry)->
    message = "#{this.user.name} of #{this.chamber.name} created an appointment for you on #{this.dateString} at #{entry.timeSlot.replace(/\-/g,':')}"

    data =
      apiKey: @getCurrentUser().apiKey
      receiverUserId: entry.patientId
      phoneNumber: entry.patientPhone
      smsBody: message
      organizationId: @organization.idOnServer

    @isLoading = true
    @callApi '/bdemr--send-sms-using-organization', data, (err, response)=>
      @isLoading = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog 'Successfuly Sent'
  
  sendSMSButtonClicked: (e)->
    entry = @actionData
    @_callSendSmsUsingOrganization entry

  # _searchOnline: ->
  #   @matchingPatientList = []
  #   @isLoading = true
  #   @callApi '/bdemr-patient-search', { apiKey: @user.apiKey, searchQuery: @searchPatientInput}, (err, response)=>
  #     @isLoading = false
  #     if response.hasError
  #       @domHost.showModalDialog response.error.message
  #     else  
  #       if response.data.length is 0
  #         @domHost.showToast 'No Patient Found'
  #         return
  #       @matchingPatientList = response.data
        
  # searchPatientTapped: (e)->
  #   this._searchOnline()

  # searchPatintKeyPressed: (e)->
  #   if e.which is 13
  #     this._searchOnline()
  
  addPatientTapped: (e)->
    { patient } = e.model
    @newBookingEntry patient, 'booked', =>
      @matchingPatientList = ""

  patientSelected: (e)->
    return unless e.detail.value
    @isLoading = true
    patient = e.detail.value
    # console.log {patient}
    @newBookingEntry patient, 'booked', =>
      @$$("#patientSearch").value = null
      this._getScheduleForDate this.dateString, =>
        @isLoading = false
    

  patientSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    @debounce 'search-patient', ()=>
      @_patientSearch(searchQuery)
    , 1000

  
  _patientSearch: (searchQuery)->
    return unless searchQuery
    @$$("#patientSearch").items = []
    @fetchingPatientSearchResult = true;
    @callApi '/bdemr-patient-search-new', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingPatientSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @matchingPatientdata = response.data
        if @matchingPatientdata.length > 0
          @$$("#patientSearch").items = @matchingPatientdata
        else
          @domHost.showToast 'No Match Found'

  _calculateAppoinmentCallForPatient: (bookedPatientList)->
    awaitingPatientList = (item for item in bookedPatientList when item.status isnt 'completed')
    return unless awaitingPatientList.length
    awaitingPatientList.sort (a, b)-> a.bookedDatetimeStamp - b.bookedDatetimeStamp
    for item, index in awaitingPatientList
      if index is 0
        @_notify item.patientId, 'You are Next'
      else
        @_notify item.patientId, "You are number #{index+1}"
  
  newBookingEntry: (patient, currentStatus, cbfn)->
    newEntry = {
      patientId: patient.idOnServer
      patientFullName: @$getFullName patient.name
      patientEmail: patient.email
      patientPhone: patient.phone
      patientSerial: patient.serial # extra
      patientProfilePicture: patient.profileImage
      timeSlot: @_getAvailableTimeSlot()
      paymentStatus: 'manual' # 'manual', 'online-pending', 'online-successful', 'online-failure'
      status: currentStatus # 'booked','awaiting', 'completed', 'require-second-visit', 'canceled'
      bookedByUserType: 'doctor'
      bookedType: null
      bookedByUserId: this.user.idOnServer
      bookedDatetimeStamp: (new Date).getTime()
      activityLog: [{
        status: currentStatus
        createdDateTimeStamp: lib.datetime.now()
        createdByUserId: @user.idOnServer
      }]
    }

    this.push('schedule.bookingList', newEntry)
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        message = "#{this.user.name} of #{this.chamber.name} created an appointment for you on #{this.dateString} at #{newEntry.timeSlot.replace(/\-/g,':')}"
        messageToDoctor = "#{this.user.name} of #{this.chamber.name} has booked a patient named #{newEntry.patientFullName} #{this.dateString} at #{newEntry.timeSlot.replace(/\-/g,':')}"
        this._notify(newEntry.patientId, message)
        this._notify(newEntry.bookedByUserId, messageToDoctor)
        this._calculatePatientsBookingStatusCount this.schedule.bookingList
        cbfn()


  _getAvailableTimeSlot: ()->
    alreadyBookedSlotList = @schedule.bookingList.map (booking)=>
      return booking.timeSlot
    # console.log 'already booked slots', alreadyBookedSlotList

    availableTimeSlotList = @schedule.timeSlotList.filter (timeSlot)=>
      return !alreadyBookedSlotList.includes timeSlot
    # console.log 'available slots', availableTimeSlotList
    if availableTimeSlotList.length
      return availableTimeSlotList[0]
    else
      return @schedule.timeSlotList[@schedule.timeSlotList.length-1]

    


  setPatientStatusTapped: (e)->
    { entry } = e.model   
    e.model.set('entry.status', @patientStatus)
    unless e.model.entry.activityLog?.length
      e.model.set('entry.activityLog', [])
    if e.model.entry.activityLog?.length
      e.model.push('entry.activityLog', {
        status: @patientStatus
        createdDateTimeStamp: lib.datetime.now()
        createdByUserId: @user.idOnServer
      })
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        message = "#{this.user.name} of #{this.chamber.name} changed your status to #{this.patientStatus} #{this.dateString}"
        this._notify(entry.patientId, message)
        this._calculateAppoinmentCallForPatient this.schedule.bookingList
        this._calculatePatientsBookingStatusCount this.schedule.bookingList
        null
  
  patientArrivedTapped: (e)->
    
    { entry } = e.model   
    # console.log entry
    e.model.set('entry.status', 'awaiting')
    if e.model.entry.activityLog
      e.model.push('entry.activityLog', {
        status: 'awaiting'
        createdDateTimeStamp: lib.datetime.now()
        createdByUserId: @user.idOnServer
      })
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        this._calculatePatientsBookingStatusCount this.schedule.bookingList
        null
  
  _transferBalance: (patientId, agentId, transactionId, serviceChargeIncluded, cbfn)->
    data =
      apiKey: @user.apiKey
      patientId: patientId
      agentId: agentId
      transactionId: transactionId
      serviceChargeIncluded: serviceChargeIncluded

    @callApi '/bdemr-wallet-transfer-balance', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        cbfn()
  addRemarksTapped: (e)->
    entry = @actionData
    console.log entry 

    @$$('#action-modal').toggle()
    @addRemarksClicked (answer)=>
      if answer
        entry.remarks = @addRemarks
        this._setScheduleForDate this.schedule, =>
          this._getScheduleForDate this.dateString, =>
              message = "#{this.user.name} of #{this.chamber.name} added remarks  on #{this.dateString}"
              this._notify(entry.patientId, message)
              if entry.agentId
                this._notify(entry.agentId, message)
              this._calculateAppoinmentCallForPatient this.schedule.bookingList
              this._calculatePatientsBookingStatusCount this.schedule.bookingList

  addRemarksClicked:(cbfn)->
    @$$('#remarksDialog').toggle()
    @addRemarksClosedCallback = cbfn
  
  markAsDoneTapped: (e)->
    entry = @actionData
    console.log entry 

    @$$('#action-modal').toggle()
    @markAsDoneClicked (answer)=>
      if answer
        if entry.paymentStatus != 'online-pending' or 'manual'
          entry.status= 'completed'

          { transactionId, patientId, agentId, serviceChargeIncluded } = entry;

          console.log entry

          console.log { transactionId, patientId, agentId, serviceChargeIncluded }

          if entry.activityLog
            entry.activityLog.push {
              status: 'completed'
              createdDateTimeStamp: lib.datetime.now()
              createdByUserId: @user.idOnServer
            }
          
          this._setScheduleForDate this.schedule, =>
            this._getScheduleForDate this.dateString, =>
              message = "#{this.user.name} of #{this.chamber.name} completed your appointment on #{this.dateString}"
              this._notify(entry.patientId, message)
              if entry.agentId
                this._notify(entry.agentId, message)
              this._calculateAppoinmentCallForPatient this.schedule.bookingList
              this._calculatePatientsBookingStatusCount this.schedule.bookingList
              if entry.paymentStatus != 'online-pending' or 'manual'
                this._transferBalance patientId, agentId, transactionId, serviceChargeIncluded, =>
                  null
        
  requiresSecondVisitTapped: (e)->
    # { entry } = e.model   
    entry = @actionData
    @$$('#action-modal').toggle()
    entry.status= 'require-second-visit'
    if entry.activityLog
      entry.activityLog.push {
        status: 'require-second-visit'
        createdDateTimeStamp: lib.datetime.now()
        createdByUserId: @user.idOnServer
      }
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        message = "#{this.user.name} of #{this.chamber.name} completed your appointment on #{this.dateString} and required a second visit"
        this._notify(entry.patientId, message)
        this._calculatePatientsBookingStatusCount this.schedule.bookingList
        null

  doctorCancelTapped: (e)->
    # { entry } = e.model
    entry = @actionData
    @$$('#action-modal').toggle()

    # console.log 'entry obj after cancel tapped', entry
    entry.status='canceled'
    if entry.activityLog
      entry.activityLog.push {
        status: 'canceled'
        createdDateTimeStamp: lib.datetime.now()
        createdByUserId: @user.idOnServer
      }
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        message = "#{this.user.name} of #{this.chamber.name} canceled your appointment on #{this.dateString}"
        this._notify(entry.patientId, message)
        this._calculatePatientsBookingStatusCount this.schedule.bookingList
        null

  
  
  setTimeSlotTapped: (e)->
    { entry } = e.model   
    # console.log(entry._selectedTimeSlotIndex)
    return unless entry._selectedTimeSlotIndex > -1
    newTimeSlot = this.schedule.timeSlotList[entry._selectedTimeSlotIndex]
    oldTimeSlot = entry.timeSlot
    e.model.set('entry.timeSlot', newTimeSlot)
    this._setScheduleForDate this.schedule, =>
      this._getScheduleForDate this.dateString, =>
        message = "#{this.user.name} of #{this.chamber.name} changed your timeslot on #{this.dateString} from (#{oldTimeSlot}) to (#{newTimeSlot})"
        this._notify(entry.patientId, message)
  
  _returnSerial: (index)->
    index+1
  

  # view patient data from chamber - start
  _importPatient: (serial, pin, cbfn)->
    @isLoading = true
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      @isLoading = false
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
    @isLoading = true
    @callApi '/bdemr--get-patient-data-on-import', data, (err, response)=>
      @isLoading = false
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
  
  goPatientViewPage: (patient)->
    
    @domHost.setCurrentPatientsDetails patient
    @createdPatientVisitedLog patient
    @today= @formatDate
    visitSerial= 'new'
    # window.open('#/patient-viewer/patient:' + patient.serial + '/selected:0')
    window.localStorage.setItem('navigate',this.chamberShortCode)
    window.localStorage.setItem('newVisitButton', 'remove')
    window.localStorage.setItem('dateString',this.dateString)
    @domHost.navigateToPage '#/visit-editor/visit:' + visitSerial + '/patient:' + patient.serial
    # @domHost.navigateToPage '#/patient-viewer/patient:' + patient.serial + '/selected:0'
    @domHost.selectedPatientPageIndex = 0

  createdPatientVisitedLog: (patient)->

    visitedPatientLogObject = {
      createdByUserSerial: @user.serial
      serial: @generateSerialForVisitedPatientLog()
      patientSerial: patient.serial
      patientName: patient.name
      visitedDateTimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
    }

    app.db.insert 'visited-patient-log', visitedPatientLogObject



  getDateString: ()->
    dateString = this.dateString
    dateString = dateString.split('-')
    dateString = dateString.join('')
    return dateString
    
  cancelAction:()->
    @actionData=[]

  viewChamberPatient: (e)->
    entry = @actionData
    patientSerial = @actionData.patientSerial
    @$$('#action-modal').toggle()
    if(entry.visitSerial)
      @_checkIfPatientAvailableOrImport patientSerial, (patient)=>
        @domHost.setCurrentPatientsDetails patient
        @createdPatientVisitedLog patient
        window.localStorage.setItem('newVisitButton', 'remove')
        window.localStorage.setItem('navigate',this.chamberShortCode)
        window.localStorage.setItem('dateString',this.dateString)
        window.localStorage.setItem('referralDoctor', entry.referralDoctor)
        @domHost.navigateToPage '#/visit-editor/visit:' + entry.visitSerial + '/patient:' + patientSerial

    else
      @_checkIfPatientAvailableOrImport patientSerial, (patient)=>
        if entry.originalPayload
          if entry.originalPayload.agentName
            window.localStorage.setItem('patientId', entry.patientId)
            window.localStorage.setItem('bookedDatetimeStamp', entry.bookedDatetimeStamp)
            window.localStorage.setItem('scheduleId', @schedule._id)
            window.localStorage.setItem('referralDoctor', entry.referralDoctor)

            
          else
            window.localStorage.removeItem('patientId')
            window.localStorage.removeItem('bookedDatetimeStamp')
            window.localStorage.removeItem('scheduleId')
            window.localStorage.setItem('referralDoctor', entry.referralDoctor)

            
        else
          window.localStorage.removeItem('patientId')
          window.localStorage.removeItem('bookedDatetimeStamp')
          window.localStorage.removeItem('scheduleId')
          window.localStorage.setItem('referralDoctor', entry.referralDoctor)

          
     
          
        @goPatientViewPage patient
      
  
  generateToken: (e)->
    entry = @actionData
    @set 'tokenObject', null

    token =
      serial: null
      createdDateTimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      organizationId: @organization.idOnServer
      data:
        organizationName: @organization.name
        patientSerial: entry.patientSerial
        patientName: entry.patientFullName
        patientPhone: entry.patientPhone
        departmentName: null
        roomNumber: null
        chamber:
          name: @chamber.name
          shortCode: @chamber.shortCode
    
    # console.log token

    @set 'tokenObject', token

    @$$('#tokenDialog').toggle();
  setDefaultChamber:()->
    window.localStorage.setItem('defaultChamberCode',this.chamberShortCode)
    window.localStorage.setItem('dateString',this.dateString)
    @defaultChamberCode =  window.localStorage.getItem('defaultChamberCode')
   

  
  _callSetGenerateTokenApi: (cbfn)->
    data =
      apiKey: @user.apiKey
      token: @tokenObject
      date: @getDateString()
      
    @isLoading = false
    this.callApi '/bdemr-generate-token-set', data, (err, response)=>
      @isLoading = false
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        cbfn response.data.tokenId
  
  tokenDialogConfirm:(e)->
    unless @tokenObject.data.departmentName and @tokenObject.data.roomNumber
      @domHost.showToast 'Please fillup requrired fields!'
      return

    @_callSetGenerateTokenApi (tokenId)=>
      @domHost.navigateToPage '#/token-preview/id:' + tokenId
      @$$('#tokenDialog').close();
  addRemarksConfirm:(e)->
    console.log @addRemarks
    unless @addRemarks
      @domHost.showToast 'Please fillup requrired fields!'
      return
    @$$('#remarksDialog').close();

  navigateToChamber: ()->
    @domHost.navigateToPage '#/chamber-manager'
  startVideoChatWithPatient: (e)->
    entry = e.model.item
    console.log 'patient id in chamber', entry

    return unless entry.patientId
    @domHost.initiateVideoCallToPatient entry.patientId
  startVideoChatViaPatient: (e)->
    entry = @actionData
    return unless entry.patientId
    # console.log 'patient id in chamber', entry.patientId
    @domHost.initiateVideoCallToPatient entry.patientId
  reloadPage: ()->
    window.location.reload()
  startVideoChatViaAgent: (e)->
    entry  = e.model.item
    console.log 'patient id in chamber', entry
    return @domHost.showModalDialog "Invalid/Missing AgentID!" unless entry.agentId
    # console.log 'patient id in chamber', entry.patientId
    @domHost.initiateVideoCallToPatient entry.agentId


  ## qr code - start
  _showQrCodeDialog: ()->
    @set 'isQrCodeActive', true
    @$$('#dialogShowQrCode').toggle()
  
  _dismissQrcodeDialog:()->
    @set 'isQrCodeActive', false
    # @set 'barcode', null
    @$$('#dialogShowQrCode').close()
  
  _onQrCodeChanged: (e)->
    code = e.detail.result.text
    if code.length > 0
      @_callCheckPatientQrCode code
    
  
  _callCheckPatientQrCode: (code) ->
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
        @newBookingEntry patient, 'awaiting', =>
          @_dismissQrcodeDialog()
  ## qr code - end

  updatePatientOnlineStatus: ()->
    activeUserList = @domHost.activeUserList
    for book, index in @schedule.bookingList
      isOnline = activeUserList.some (item) => book.patientId is item.userId
      @set "schedule.bookingList.#{index}.isOnline", isOnline
      if book.agentId
        isAgentOnline = activeUserList.some (item) => book.agentId is item.userId
        @set "schedule.bookingList.#{index}.isAgentOnline", isAgentOnline

  _goToDisplayQueue: ()->
    url = "https://clinic.bdemr.com/app/#/patients-queue/chamber:#{@chamber.serial}"
    window.open url, '_blank'

  # view patient data from chamber - end
  navigatedIn: ->
    @domHost.toggleModalLoader 'Loading, please wait...'
    # this.dateString =  this.domHost.getPageParams()['date']
    
    organization = @getCurrentOrganization()
    if organization
      @set 'organization', organization
      # if window.localStorage.getItem('navigate')
      #   @_getChamberList @organization.idOnServer, ()=> null
      #   this.chamberShortCode=window.localStorage.getItem('navigate')
      #   window.localStorage.removeItem('navigate')
      # else
      @_getChamberList @organization.idOnServer, ()=> null
        # if !window.localStorage.getItem('navigate')
       
      if this.domHost.getPageParams()['chamber'] && this.domHost.getPageParams()['date']
              this.chamberShortCode = this.domHost.getPageParams()['chamber']
              this.dateString =  this.domHost.getPageParams()['date']
              
      
        
      else
          if window.localStorage.getItem('defaultChamberCode')
            this.chamberShortCode = window.localStorage.getItem('defaultChamberCode')
            this.dateString = window.localStorage.getItem('dateString')
            
            @defaultChamberCode =  window.localStorage.getItem('defaultChamberCode')
            this.domHost.navigateToPage "#/chamber-patients/chamber:#{this.chamberShortCode}/date:#{this.dateString}"
          else
            this.domHost.navigateToPage "#/chamber-manager"
            window.location.reload()
          # window.localStorage.removeItem('navigate')
          # window.localStorage.removeItem('dateString')
      if @defaultChamberCode
          if @defaultChamberCode is this.chamberShortCode
            @isDefault = true
          else
            @isDefault = false
      
    else
      @domHost.navigateToPage '#/select-organization'
    # @_getDefaultChember()
    


    this._getChamber =>
      this._getScheduleForDate this.dateString, =>
        this.createDefaultSchedule this.dateString, =>
          this._calculatePatientsBookingStatusCount(this.schedule.bookingList)
          this.loadNewPatientFromChamber()
          this.updatePatientOnlineStatus()
          @domHost.toggleModalLoader()

        
            
        

  _calculatePatientsBookingStatusCount: (bookingList)->
    this.availableSlot = 0
    this.awatingPatientCount = 0
    this.completedPatientCount = 0
    this.secondVisitPatientCount = 0
    this.availableSlot= this.getFreeSlots(this.timeSlotAvailability)
    return unless bookingList.length
    for item in bookingList
      if item.status is 'awaiting'
        this.awatingPatientCount++
      if item.status is 'completed'
        this.completedPatientCount++
      if item.status is 'require-second-visit'
        this.secondVisitPatientCount++

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPage "#/chamber-manager"

  chamberPatientsListPrintButtonPressed: (e)->
    this.domHost.navigateToPage "#/print-chamber-patients/chamber:#{this.chamberShortCode}/date:#{this.dateString}"

  _computeTimeSlotAvailability: ->

    map = {}
    
    for timeSlot in this.schedule.timeSlotList
      map[timeSlot] = 0

    for booking in this.schedule.bookingList
      unless booking.timeSlot of map
        map[booking.timeSlot] = 0
      map[booking.timeSlot] += 1

    # console.log "TimeSlot MAP", map
    freeSchedule = []
    for timeSlot, count of map
      freeSchedule.push {
        timeSlot
        availableCount: (this.chamber.maximumVisitorPerBookingSlot - count)
      }
    this.timeSlotAvailability = freeSchedule


  _changeStatusColorForPatientChamberBooking: (statusData)->
    if statusData is "booked"
      return "status booked"
    if statusData is "awaiting"
      return "status awaiting"
    else if statusData is "completed"
      return "status completed"
    else if statusData is "require-second-visit"
      return "status require-second-visit"
    else if statusData is 'canceled'
      return "status canceled" 
    else
      return 'status'

  # Collect Sample Modal

  showSampleClicked: (cbfn)->
    @$$('#sample-modal').toggle()
    @sampleModalDoneCallBack = cbfn
  
  collectSampleClicked: (e)->
    { entry } = e.model
    @showSampleClicked (answer)=>
      if answer
        if e.model.entry.sampleTaken?.length
          e.model.push('entry.sampleTaken', @sample)
        else
          e.model.set('entry.sampleTaken', [@sample])
        if e.model.entry.activityLog?.length
          e.model.push('entry.activityLog', {
            status: "sample taken: #{@sample.id}-#{@sample.type}"
            createdDateTimeStamp: lib.datetime.now()
            createdByUserId: @user.idOnServer
          })
        @sample = null
      else
        @sample = null
        
  sampleModalClosed: (e)->
    if e.detail.confirmed
      @sampleModalDoneCallBack true
    else
      @sampleModalDoneCallBack false
    @sampleModalDoneCallBack = null

  showAvailableSlot: ()->
    @$$('#available-slot').toggle()
  # Time Slot Modal
  actionPressed:(e)->
    @actionData = e.model.item
    console.log 'actionData',@actionData
    @$$('#action-modal').toggle()
  
  showTimeSlotClicked: (cbfn)->
    @$$('#time-slot-modal').toggle()
    @timeSlotModalDoneCallBack = cbfn

  markAsDoneClicked :(cbfn)->
    @$$('#mark-asDone-modal').toggle()
    @markAsDoneClosedCallback = cbfn
  showChamber: (cbfn)->
    @$$('#select-chamber').toggle()
    @chamberClosedCallback = cbfn
  showSelectedChamber:(e)->
    @_getChamberList @organization.idOnServer, ()=> null

    @showChamber (answer)=>
      if answer
        
        # console.log 'chamberdata ',chamberData
        @isLoading = true
        this.chamberShortCode= @chamberData.shortCode
        this._getChamber =>
          this._getScheduleForDate this.dateString, =>
            this.createDefaultSchedule this.dateString, =>
              this._calculatePatientsBookingStatusCount(this.schedule.bookingList)
              this.loadNewPatientFromChamber()
              this.updatePatientOnlineStatus()
              @isLoading = false
  
  setTimeSlotClicked: (e)->
    entry = e.model.item
    console.log 'entry',entry
    @showTimeSlotClicked (answer)=>
      if answer
        newTimeSlot = this.timeSlot
        oldTimeSlot = entry.timeSlot
        console.log 'newtime',newTimeSlot
        entry.timeSlot= newTimeSlot
        

        console.log 'entry.timeSlot',entry.timeSlot

        this._setScheduleForDate this.schedule, =>
          this._getScheduleForDate this.dateString, =>
            message = "#{this.user.name} of #{this.chamber.name} changed your timeslot on #{this.dateString} from (#{oldTimeSlot}) to (#{newTimeSlot})"
            this._notify(entry.patientId, message)
      else
        timeSlot = ''
        
  timeSlotModalClosed: (e)->
    if e.detail.confirmed
      @timeSlotModalDoneCallBack true
    else
      @timeSlotModalDoneCallBack false
    @timeSlotModalDoneCallBack = null
  markAsDoneClosed: (e)->
    if e.detail.confirmed
      
      console.log 'detais', e.detail
      @markAsDoneClosedCallback true
    else
      @markAsDoneClosedCallback false
    @markAsDoneClosedCallback = null
  addRemarksClosed: (e)->
    if e.detail.confirmed
      
      console.log 'detais', e.detail
      @addRemarksClosedCallback true
    else
      @addRemarksClosedCallback false
    @addRemarksClosedCallback = null


  
  newPatientButtonPressed: ()->
    @domHost.navigateToPage '#/patient-signup/chamber:' + @chamberShortCode
  
  loadNewPatientFromChamber: ()->
    patientIdentifier = window.localStorage.getItem('newPatientSerialFromChamber')

    if patientIdentifier
      list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
      if list.length is 1
        patient = list[0]
        @newBookingEntry patient, 'booked', =>
          window.localStorage.setItem('newPatientSerialFromChamber', null)

  
  _generateTimeSlotList: (startTimeString, endTimeString, bookingSlotSizeInMinutes)->
    start = (new Date ("2000-01-01T" + startTimeString))
    end = (new Date ("2000-01-01T" + endTimeString))
    timeSlotList = []
    while (start.getTime() < end.getTime())
      startTimeString = this.$mkTime(start)
      start.setMinutes(start.getMinutes() + parseInt(bookingSlotSizeInMinutes))
      endTimeString = this.$mkTime(start)
      timeSlotList.push("#{startTimeString} to #{endTimeString}")
    return timeSlotList
  
  createDefaultSchedule: (dateString, cbfn)->
    if !this.schedule
      schedule = {
        chamberSerial: this.chamber.serial
        chamberName: this.chamber.name
        organizationName: @organization.name
        doctorId: this.chamber.doctorId
        organizationId: @organization.idOnServer
        dateString: dateString
        startTimeString: this.chamber.startTimeString
        endTimeString: this.chamber.endTimeString
        isCanceled: false
        isRescheduled: false
        rescheduleDelayInMinutes: 0
        timeSlotList: this._generateTimeSlotList(this.chamber.startTimeString, this.chamber.endTimeString, this.chamber.bookingSlotSizeInMinutes)
        bookingList:[]
        
      }
      console.log schedule
      this._setScheduleForDate schedule, =>
        this._getScheduleForDate dateString, =>
          cbfn()
    else
      cbfn()
  
  goToChamberCalanderView: (e)->
    this.domHost.navigateToPage "#/chamber/which:#{this.chamber.shortCode}"
    
    # window.location.reload()

  # COPIED THESE CODES BELOW FROM CHAMBER MANAGER TO SHOW THE CHAMBER-STAT TABLE IN CHAMBER-PATIENTS PAGE. Removed codes that are not necessary
  _getChamberList: (organizationIdentifier, cbfn)->
    data = { 
      apiKey: this.user.apiKey
      organizationId: organizationIdentifier
      dateString: (new Date()).toISOString().split('T')[0]
    }
    this.isLoading = true
    this.callApi '/bdemr-booking--clinic--get-chamber-schedule-report', data, (err, response)=>
      this.isLoading = false
      if response.hasError
        # this.domHost.showModalDialog response.error.message
        this.domHost.navigateToPage "#/chamber-manager"
        window.location.reload()

      else if response.data
        matchingChamberList = response.data
        if matchingChamberList.length is 0
          this.domHost.navigateToPage "#/chamber-manager"
          window.location.reload()

        else

          matchingChamberList.sort (a, b)->
            return -1 if a.name < b.name
            return 1 if a.name > b.name
            return 0        
          @set 'matchingChamberList', matchingChamberList
          console.log 'mathcng',this.matchingChamberList

        cbfn()
      else
        this.matchingChamberList = []
        cbfn()

  searchChamberTapped: (e)->
    return @domHost.showModalDialog 'Please type your search' unless @chamberSearchString
    data = { 
      apiKey: @user.apiKey
      searchString: @chamberSearchString
      organizationId: this.organization.idOnServer
      dateString: (new Date()).toISOString().split('T')[0]
    }
    # this.isLoading = true;
    @callApi '/bdemr-booking--clinic--get-chamber-schedule-report', data, (err, response)=>
      # this.isLoading = false;
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'matchingChamberList', response.data

  clearSearchResultsClicked: (e)->
    @matchingChamberList = []

  getFreeSlots: (freeSlots)->
    return 0 unless freeSlots?.length 
    return freeSlots.reduce (total, freeSlot)->
      return total += freeSlot.availableCount
    , 0

  formatDate: ()->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day
    return [year, month, day].join('-')

  viewChamberSchedule: (e)->
    @chamberData = e.model.item
    @$$('#select-chamber').toggle()
    this.domHost.navigateToPage "#/chamber-patients/chamber:#{@chamberData.shortCode}/date:#{this.dateString}"
    this.schedule.bookingList=[]
    this.chamberShortCode= @chamberData.shortCode
    this._getChamber =>
          this._getScheduleForDate this.dateString, =>
            this.createDefaultSchedule this.dateString, =>
              this._calculatePatientsBookingStatusCount(this.schedule.bookingList)
              this.loadNewPatientFromChamber()
              this.updatePatientOnlineStatus()
              @isLoading = false
   
          # @domHost.toggleModalLoader()
    # today = this.formatDate()
    # this.domHost.navigateToPage "#/chamber-patients/chamber:#{@chamberSelectedData.shortCode}/date:#{today}"
    # window.location.reload()

  viewTodaysPatient: (e)->
    {item} = e.model
    dateString = (new Date()).toISOString().split('T')[0]
    this.domHost.navigateToPage "#/chamber-patients/chamber:#{item.shortCode}/date:#{dateString}"

  # End of copied codes for chamber-stat table

}