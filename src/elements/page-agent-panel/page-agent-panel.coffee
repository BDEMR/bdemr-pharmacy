Polymer {
  is: 'page-agent-panel'

  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.apiCalling    
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.translating
  ]

  properties:
    selectedPatients:
      type: Object
      value: null
    
    patientSearchQuery:
      type: String
      value: -> ""
      observer: 'patientSearchInputChanged'

    dateString:
      type: String
      value: ()-> ""

    showOnlineDoctorsOnly:
      type: Boolean
      value: false
    
    selectedDoctorVisitFee:
      type: Number
      value: 0
      observer: 'selectedDoctorVisitFeeChanged'

    selectedBookingType:
      type: Number
      value: 0
      observer: 'selectedBookingTypeChanged'

    organizationSearchQuery:
      type: String
      value: -> ""
      observer: 'organizationSearchInputChanged'

    countryWithCitiesList:
      type: Array
      value: []
    
    selectedCountryCitiesList:
      type: Array
      value: []
    
    customCountryCityList:
      type: Array
      value: []

    organizationList:
      type: Array
      value: ()-> []

    chamberList:
      type: Array
      value: ()-> []
    
    selectedDoctor:
      type: Object
      value: null

    selectedChamber:
      type: Object
      value: null

    selectedTimeSlotFromSchduleDateDrpdwn:
      type: Array
      value: -> []

    selectedScheduleIdFromDateDropdown:
      type: String
      value: ""

    selectedSchedulePage:
      type: Number
      value: 0

    selectedDateString:
      type: String
      value: null

    otherFacilitiesList:
      type: Array
      value: ()-> []

    filteredSpecializationList:
      type: Array
      value: -> []
    
    agentRoleMemberList:
      type: Array
      value: ()-> []

    agentSearchQuery:
      type: String
      value: -> ""

    selectedAgentDetails:
      type: Object
      value: ()-> {}
    
    otherCharges:
      type: Object
      value: {
        govSourceCharge: 0
        bdmerServiceCharge: 0
        totalBillAmount: 0
        agentCharge: 0
      }
    
    degreeList:
      type: Array
      value: ->
        [
          { text: 'MBBS', value: null }
          { text: 'BDS', value: null }
        ]
    
    fetchingSpecializationList:
      type: Boolean
      value: false

    orgAddress: String
    orgPhone: String
    activeUserList: Object
    isUserAgent:
      type: Boolean
      value: false

    signupPatientDivHidden:
      type: Boolean
      value: true
    
  
  listeners:
    'active-users': '_activeUsersHandler'
  
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
        # @domHost.showModalDialog response.error.message
        @domHost.showToast 'No Match Found!'
        @_clearSelectedPatientData()
        @signupPatientDivHidden = false
      else
        @matchingPatientdata = response.data
        console.log @matchingPatientdata
        if @matchingPatientdata.length > 0
          @$$("#patientSearch").items = @matchingPatientdata
          
  
  patientSelected: (e)->
    return unless e.detail.value
    @set "selectedPatients", e.detail.value
  
  _clearSelectedPatientData: ()->
    @set "patientSearchQuery", ''
    @set "selectedPatients", null
    @$$("#patientSearch").value = ""
  

  _checkIfDoctorIsOnline: (showOnlineDoctorsOnly, chamber)->
    console.log {showOnlineDoctorsOnly, chamber}
    if showOnlineDoctorsOnly
      return true if chamber.isOnline
      return false
    return true
    
  selectedBookingTypeChanged: (bookingType)->
    console.log @selectedBookingType

  selectedDoctorVisitFeeChanged: (doctorFee)->
    govSourceChargePercentage = 5
    bdmerServiceCharge = 25
    doctorFee = parseFloat doctorFee
    agentCommissionPercentage = 12

    govSourceChargeAmount = ( doctorFee * govSourceChargePercentage ) / 100
    agentCommissionAmount = ( doctorFee * agentCommissionPercentage ) / 100

    @set "otherCharges.govSourceCharge", govSourceChargeAmount
    @set "otherCharges.bdmerServiceCharge", bdmerServiceCharge

    console.log {doctorFee, govSourceChargePercentage, bdmerServiceCharge}
    totalBillAmount = doctorFee + govSourceChargeAmount + bdmerServiceCharge

    totalBillAmount +=  agentCommissionAmount if @isUserAgent 

    @set "otherCharges.totalBillAmount", totalBillAmount
    @set "otherCharges.agentCharge", agentCommissionAmount


  _activeUsersHandler: (e)->
    console.log e
    @activeUserList = e.detail.activeUserList
    console.log {@activeUserList}
    return if !@chamberList
    for chamber, index in @chamberList
      isOnline = @activeUserList.some (item) => chamber.doctorId is item.userId
      @set "chamberList.#{index}.isOnline", isOnline

    if @selectedDoctor
      isSelectedDoctorIsOnline = @activeUserList.some (item) => @selectedDoctor.doctorId is item.userId
      @set "selectedDoctor.isOnline", isSelectedDoctorIsOnline

  $gte: (a, b)-> parseInt(a) >= parseInt(b)

  $diff: (a, b)-> parseInt(a) - parseInt(b)

  _getOrganizationDetailsFromLocal: ()->
    organization = window.localStorage.getItem("selectedOrganization")
    organization = JSON.parse(organization)
    if organization
      @isOrganizationPreselected = true
      @set 'filterByOrganizationId', organization.idOnServer
      @set 'filterByOrganizationName', organization.name
      @_loadSpecializationForOrganisation()
    else
      return


  ready: ->
    @_preloadData()
  
  
  _preloadData: ->
    @async => @_loadCountryCityFromSystem =>
      @_loadCustomCountryCityList()
    
  _loadCustomCountryCityList: ()->
    @domHost.callApi '/bdemr--get-all-custom-country-city', {}, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        customList = response.data
        @set 'customCountryCityList', customList
        console.log 'custom country city list', @customCountryCityList
        @customCountryCityList.forEach (customCountry)=>
          country = @countryWithCitiesList.find (currentCountry)=>
            return currentCountry.value.name is customCountry.name
          if country
            uniqueCities = {}

            country.value.cities.forEach (city)=>
              uniqueCities[city] = city
            
            customCountry.cities.forEach (city)=>
              uniqueCities[city] = city
            
            country.value.cities = Object.keys uniqueCities

  updateDoctorOnlineStatus: ()->
    activeUserList = @domHost.activeUserList
    for chamber, index in @chamberList
      isOnline = activeUserList.some (item) => chamber.doctorId is item.userId
      console.log {isOnline}
      @set "chamberList.#{index}.isOnline", isOnline
  
  goToMyBookings: ()->
    @domHost.navigateToPage '#/my-bookings'
  
  navigatedIn: ()->
    @user = (app.db.find 'user')[0]
    organization = @getCurrentOrganization()

    if organization
      @set 'organization', organization

    @isUserAgent = @domHost.isUserAgent
    console.log "@isUserAgent", @isUserAgent

    this.walletBalance = @domHost.walletBalance
    console.log @walletBalance

    this.searchBookingTapped(null)
    
    # @_getOrganizationDetailsFromLocal()
    @_loadMyBookings =>
      null

    
    # warningData = sessionStorage.getItem('warningShown')
    # if warningData
    #   this._loadMyBookings =>
    #     null
    # else
    #   @_showBookingWarningToUser()

  # ====================================== NEW BOOK START

  payFromWalletTapped: (e)->
    console.log {@selectedPatient}
    if @isUserAgent and !@selectedPatients
      return @domHost.showModalDialog "Select a Patient First!" 

    console.log 'BOOKING CHAMBER', @selectedDoctor

    {
      organizationName
      name     
      doctorId
      newPatientVisitFee
      serviceChargeIncluded
      _id
    } = @selectedDoctor
    dateString = @selectedDoctor.scheduleList[0].dateString

    console.log @selectedDoctor._selectedTimeSlotIndex

    return @domHost.showToast "Select a Timeslot First!" if @selectedDoctor._selectedTimeSlotIndex is undefined
    return @domHost.showToast "Select a Timeslot First!" if @selectedDoctor._selectedTimeSlotIndex is -1
      
    timeSlot = @selectedDoctor.scheduleList[0].timeSlotList[@selectedDoctor._selectedTimeSlotIndex].timeSlot

    details = {
      dateString
      doctorId
      patientId: @user.idOnServer
      chamberId: _id
      organizationName
      organizationId: @organization.idOnServer
      organizationAddrs: @organization.address
      chamberName: name
      timeSlot 
      serviceChargeIncluded
      patientFullName: this.user.name
      patientEmail: this.user.email
      patientPhone: this.user.phone
      patientSerial: this.user.serial
      patientAcceptedBooking: 'accepted'
      status: 'booked' # 'canceled'
      bookedType: 'self'
      bookingType: @selectedBookingType
      agentId: null
      bookedByUserType: 'patient'
      paymentStatus: 'online-pending' #, 'online-successful', 'online-failure'
      paymentAmount: @otherCharges.totalBillAmount
      # agentData: @selectedAgentDetails
    }
    console.log details
    notes = "#{@selectedDoctor.doctorPublicInfo.name} Consultation Fee"

    if @isUserAgent
      details.bookedType = 'agent'
      details.agentId = @user.idOnServer
      details.agentName = @user.name
      details.patientFullName = this.selectedPatients.name
      details.patientEmail = this.selectedPatients.email
      details.patientPhone = this.selectedPatients.phone
      details.patientSerial = this.selectedPatients.serial
      notes += " for #{details.patientFullName}"
      details.patientId = @selectedPatients.idOnServer
    
    this.domHost.toggleModalLoader "Please wait..."
    
    this._bookAppointment details, (schedule)=>
      this._chargeUser @otherCharges, details.patientId, schedule._id, notes, (transactionId)=>
        
        details.paymentStatus = 'online-successful-by-patient'
        details.bookedByUserType = 'patient'
        details.transactionId = transactionId

        if @isUserAgent
          details.paymentStatus = 'online-successful-by-agent'
          details.bookedByUserType = 'agent'
        
        this._bookAppointment details, (schedule2)=>
          # this._loadMyBookings =>
          this.domHost._loadWallet()
          this.domHost.toggleModalLoader()
          @$$('#doctorBookingDetailsDialog').close()
          @domHost.showModalDialog "Your Booking & Payment has been completed Successfully!"
            # this.searchBookingTapped(null)


  bookDoctorTapped: (e)->
    console.log {@selectedPatient}
    if @isUserAgent and !@selectedPatients
      return @domHost.showModalDialog "Select a Patient First!" 

    console.log 'BOOKING CHAMBER', @selectedDoctor

    {
      organizationName
      name     
      doctorId
      newPatientVisitFee
      serviceChargeIncluded
      _id
    } = @selectedDoctor
    dateString = @selectedDoctor.scheduleList[0].dateString

    console.log @selectedDoctor._selectedTimeSlotIndex

    return @domHost.showToast "Select a Timeslot First!" if @selectedDoctor._selectedTimeSlotIndex is undefined
    return @domHost.showToast "Select a Timeslot First!" if @selectedDoctor._selectedTimeSlotIndex is -1
      
    timeSlot = @selectedDoctor.scheduleList[0].timeSlotList[@selectedDoctor._selectedTimeSlotIndex].timeSlot

    details = {
      dateString
      doctorId
      patientId: @user.idOnServer
      chamberId: _id
      organizationName
      organizationId: @organization.idOnServer
      organizationAddrs: @organization.address      
      chamberName: name
      timeSlot 
      serviceChargeIncluded
      patientFullName: this.user.name
      patientEmail: this.user.email
      patientPhone: this.user.phone
      patientSerial: this.user.serial
      patientAcceptedBooking: 'accepted'
      status: 'booked' # 'canceled'
      bookedType: 'self'
      bookingType: @selectedBookingType
      agentId: null
      bookedByUserType: 'patient'
      paymentStatus: 'online-pending' #, 'online-successful', 'online-failure'
      paymentAmount: @otherCharges.totalBillAmount
      # agentData: @selectedAgentDetails
    }
    console.log details
    notes = "#{@selectedDoctor.doctorPublicInfo.name} Consultation Fee"

    if @isUserAgent
      details.bookedType = 'agent'
      details.agentId = @user.idOnServer
      details.agentName = @user.name
      details.patientFullName = this.selectedPatients.name
      details.patientEmail = this.selectedPatients.email
      details.patientPhone = this.selectedPatients.phone
      details.patientSerial = this.selectedPatients.serial
      notes += " for #{details.patientFullName}"
      details.patientId = @selectedPatients.idOnServer
    
    this.domHost.toggleModalLoader "Please wait..."
        
    this._bookAppointment details, (schedule)=>
      # this._loadMyBookings =>
      this.domHost._loadWallet()
      this.domHost.toggleModalLoader()
      @$$('#doctorBookingDetailsDialog').close()
      @domHost.showModalDialog "Your Booking & Payment has been completed Successfully!"
        # this.searchBookingTapped(null)

    
  _bookAppointment: (details, cbfn)->
    data = { 
      apiKey: this.user.apiKey
    }

    Object.assign(data, details)
    this.domHost.callApi '/bdemr-booking--patient--patient-book-appointment', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        cbfn response.data

  addBalanceTapped: (e)->
    chamber = e.model.__data__.selectedDoctor
    diff = this.$diff(@otherCharges.totalBillAmount, this.walletBalance)
    this.domHost.showModalInput "Enter amount in BDT", ( '' + diff ), (answer)=>
      if answer
        amount = parseInt answer
        if amount < 10
          this.domHost.showModalDialog "Insert an amount of 10 or more."
          return
        this._addFunds(amount)

  _addFunds: (amount)->
    query = {
      apiKey: (app.db.find 'user')[0].apiKey
      amountToAdd:amount
      currency: 'BDT'
      notes: 'Funding for "Booking"'
    }
    this.domHost.callApi '/bdemr-wallet-add-funds', query, (err, response)=>
      if (not err) and (not response.hasError)
        window.location = response.data.redirectionUrl.replace('//', 'https://')

  _showWalletFundingDialog: ->
    params = this.domHost.getPageParams()
    if 'funding' of params
      if params.funding is 'successful'
        this.domHost.showModalDialog "Thank you for your payment."
      else
        this.domHost.showModalDialog "Something went wrong with your payment. Please try again."

  _chargeUser: (otherCharges, patientId, scheduleId, purpose, cbfn)->
    query = {
      apiKey: (app.db.find 'user')[0].apiKey
      amountInBdt: otherCharges.totalBillAmount
      bdmerServiceCharge: otherCharges.bdmerServiceCharge
      govSourceCharge: otherCharges.govSourceCharge
      agentCommission: otherCharges.agentCharge
      doctorFees: @selectedDoctorVisitFee
      notes: purpose
      scheduleId: scheduleId
      patientId: patientId
      agentId: null
    }

    if @isUserAgent
      query.agentId = @user.idOnServer
    
    console.log {query}


    this.domHost.callApi '/bdemr-wallet-charge-user', query, (err, response)=>
      if err
        this.domHost.showModalDialog err
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        transactionId = response.data.transactionId
        console.log transactionId
      return cbfn(transactionId)

  _searchDoctorToBook: (filters, cbfn)->
    data = {}
    Object.assign(data, filters)
    @domHost.toggleModalLoader 'Please Wait...'
    this.domHost.callApi '/bdemr-public-booking--patient--search-doctor-to-book', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data.chamberList.length
        this.chamberList = []
        chamberList = response.data.chamberList
        # for chamber in chamberList
        #   chamber._selectedTimeSlotIndex = 0
        #   dateString = chamber.scheduleList[0].dateString
        #   if (this.myBookingList and this.myBookingList.length > 0)
        #     for myBooking in this.myBookingList
        #       if chamber.name is myBooking.chamberName and chamber.doctorId is myBooking.doctorId and myBooking.dateString is dateString and not myBooking.isCanceled
        #         chamber.alreadyHaveAnAppointment = true

        this.chamberList = chamberList
        this.updateDoctorOnlineStatus()
        console.log 'CHMABERS', chamberList
        ## reason - it takes time to load
        if chamberList.length
          for chamber in chamberList
            @_getLatestNamePictureOfDoctor(chamber.doctorPublicInfo.idOnServer)
        cbfn()
      else
        this.chamberList = []
        cbfn()


  _getLatestNamePictureOfDoctor: (doctorId)->
    query = {
      userIdOnServer: doctorId
    }
    @callApi '/bdemr--patient-booking-get-doctor-picture', query, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else
        details = response.data
        for chamber, index in this.chamberList
          # @set "chamberList.#{index}.doctorPublicInfo.name", details.name
          @set "chamberList.#{index}.doctorPublicInfo.profilePicture", details.profileImage

  _loadSpecializationForOrganisation: ()->
    data = {
      apiKey: this.user.apiKey
      organizationId: @filterByOrganizationId
    }
    @fetchingSpecializationList = true
    @domHost.callApi '/bdemr--patient-get-specializations-of-doctors-in-a-organization', data, (err, response)=>
      console.log 'error ', err
      console.log 'response ', response
      @fetchingSpecializationList = false
      if response.hasError
        this.domHost.showModalDialog response.error.message
        # clear previously loaded data
        @filteredSpecializationList = []
        @filterBySpecialization = ''

      else
        # all chambers info
        @set 'filteredSpecializationList', []        
        specList = response.data
        
        # for chamber in chambers
        #   unless specList.includes chamber.specialization
        #     specList.push chamber.specialization

        # sort specialization
        specList.sort (prev, after)->
          return -1 if prev < after
          return 1 if prev > after
          return 0;

        @set 'filteredSpecializationList', specList
        console.log 'filtered specs ', @filteredSpecializationList;


  organizationSearchInputChanged: (searchQuery)->
    @debounce 'search-organization', ()=>
      @_searchOrganization(searchQuery)
    , 300

  _searchOrganization: (searchQuery)->
    return unless searchQuery
    @fetchingOrganizationSearchResult = true;
    @domHost.callApi '/bdemr-organization-search', { apiKey: @user.apiKey, searchString: searchQuery }, (err, response)=>
      @fetchingOrganizationSearchResult = false
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.matchingOrganizationList
        if data.length > 0
          @$$("#organizationSearch").items = data


  # _loadMemberList: (organization)->
  #   data = { 
  #     organizationId: organization.id
  #     overrideWithIdList: (user.id for user in organization.userList)
  #     searchString: 'N/A'
  #   }
  #   @callApi '/bdemr-public-organization-get-users', data, (err, response)=>
  #     if response.hasError
  #       @domHost.showModalDialog response.error.message
  #     else
  #       @set 'memberList', response.data
  #       console.log 'member list', @memberList
  #       @_getMemberListByRole(@memberList, organization)
  

  # _getMemberListByRole: (userList, organization)->
  #   console.log 'user list', userList
  #   console.log 'organization', organization

  #   organizationCopy = Object.assign {}, organization

  #   if organizationCopy.roleList?.length
  #     memberListByRole = organizationCopy.roleList

  #     for organizationRole in memberListByRole
  #       for user in organizationRole.userList
  #         for member in userList
  #           if user.id is member.idOnServer
  #             Object.assign(user, member)
  

  #     @set 'memberListByRole', memberListByRole
  #     console.log {memberListByRole}
  

  organizationSelected: (e)->
    return unless e.detail.value
    organization = e.detail.value
    console.log 'selected org', organization

    # @_loadMemberList organization
    # agentRoleMemberList = []
    # roleList = []
    # roleList = organization.roleList
    # for item in roleList
    #   if item.type is 'Agent' or 'agent'
    #     agentRoleMemberList = item.userList
    # @set 'agentRoleMemberList', agentRoleMemberList
    
    @set 'otherFacilitiesList', organization.otherFacilitiesList
    @set 'orgAddress', organization.address
    @set 'orgPhone', organization.phone
    @set 'organizationLogo', organization.printSettings.headerLogoDataUri

    @set 'filterByOrganizationId', organization.id
    # @set 'filterByOrganizationName', organization.name

    # now call api to get specializatoin for this org
    @_loadSpecializationForOrganisation()

  specializationSelected: (e)->
    return unless e.detail.value
    specialization = e.detail.value
    console.log 'selected spec', specialization
    @set 'filterBySpecialization', specialization
    @_loadDoctorsForSpecializationAndOrganisation specialization


  _loadDoctorsForSpecializationAndOrganisation: (specialization)->
    data = {
      organizationId: @get 'filterByOrganizationId'
      specialization
    }
    
    @domHost.callApi '/bdemr--patient-get-doctors-of-specialization-in-an-organization', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
        # clear previously loaded data
        @filteredDoctorList = []
        @filterByDoctorName = ''

      else
        @filterByDoctorName = ''
        # doctors of specialization
        doctorList = response.data

        # sort doctors name
        doctorList.sort (prev, after)->
          return -1 if prev < after
          return 1 if prev > after
          return 0;

        @set 'filteredDoctorList', doctorList
        console.log 'filtered doctor list ', @filteredDoctorList;  

  doctorSelected: (e)->
    return unless e.detail.value
    doctor = e.detail.value
    console.log 'selected doctor', doctor
    @set 'filterByDoctorId', doctor.idOnServer
    @set 'filterByDoctorName', doctor.name.trim()
    @set 'doctorPhone', doctor.phone
    @set 'doctorSpecializations', doctor.specializationList
    @set 'doctorEmployment', doctor.employment
    @set 'doctorExperience', doctor.experience
        
    if doctor.fileNameOnServer
      @_loadDoctorPicture(doctor.idOnServer)
    else
      @set 'doctorPicture', 'images/avatar.png' 

  _loadDoctorPicture: (doctorId)->
    data = { 
      userIdOnServer: doctorId
    }
    @callApi '/bdemr--patient-booking-get-doctor-picture', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'doctorPicture', response.data.profileImage

  searchBookingTapped: (e = null)->
    d = new Date();
    d.setFullYear(d.getFullYear());

    {
      filterByExperience
      filterByDegree
      filterBySpecialization
      filterByDoctorName
      filterByShortCode
      filterByChamberAddress
      filterByOrganizationId
      dateString
    } = this

    data = {
      filterByExperience: filterByExperience or null
      filterByDegree: filterByDegree or null
      filterBySpecialization: filterBySpecialization or null
      filterByDoctorName: filterByDoctorName or null
      filterByShortCode: filterByShortCode or null
      filterByChamberAddress: filterByChamberAddress or null
      filterByOrganizationId: filterByOrganizationId or null
      dateString: dateString or lib.datetime.mkDate(d)
    }

    console.log 'org name', @filterByOrganizationName
    console.log 'all filters', data
    # if !data.dateString
    #   @domHost.showModalDialog @$TRANSLATE('Select the Date of the Booking', @LANG)
    # else
    this._searchDoctorToBook data, =>
      console.log(this.chamberList)
      @$$("#notificationDrawer").close()
      null

  # ====================================== NEW BOOK END

  # ====================================== MY START

  cancelMyBookingTapped: (e)->
    { myBooking } = e.model
    console.log 'booking ', myBooking




  _loadMyBookings: (cbfn)->
    data = { 
      apiKey: this.user.apiKey
    }
    this.domHost.callApi '/bdemr-booking--patient--get-my-appointments', data, (err, response)=>
      if response.hasError
        this.domHost.showModalDialog response.error.message
      else if response.data
        this.myBookingList = []
        myBookingList = response.data
        this.myBookingList = myBookingList

        #sort booking list
        @myBookingList.sort (prev, after)->
          return (new Date after.dateString).getTime() - (new Date prev.dateString).getTime()

        cbfn()
      else
        this.myBookingList = []
        cbfn()
      console.log 'my booking list ', this.myBookingList

  # ====================================== MY END

  _showBookingWarningToUser: ()->
    this.domHost.showYesNoModalPrompt "-- !!লক্ষ্য করুন!! -- আপনি কোন বিভাগের ডাক্তারের সাক্ষাৎ চান তা জানা থাকলে পরবর্তী ধাপে (Ok) কিল্ক করুন!"
    warningData = sessionStorage.setItem('warningShown', 'true')
    #Here used session storage so that user can refresh the page without gettng the warning everytime.
    #Only After leaving the site will clear the warning, true


  _loadCountryCityFromSystem: (cbfn)->
    @set 'countryWithCitiesList', []
    @domHost.getStaticData 'countryCityList', (countryCityList)=>
      unless countryCityList.length is 0
        for item in countryCityList
          unless item.name is ''
            object = {}
            object.label = item.name
            object.value = item   
            @push "countryWithCitiesList", object

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
      console.log 'static country cities', @countryWithCitiesList
      cbfn() if cbfn
  

  _countrySelected: (e)->
    return unless e.detail.value
    @selectedOrganizationCountry = e.detail.value.value
    console.log 'selected country', @selectedOrganizationCountry
    @set 'selectedCountryCitiesList', []
    @set 'selectedOrganizationCity', null
    @set 'selectedCountryCitiesList', @selectedOrganizationCountry.cities
    
    @_callGetAllOrganizationList {
      country: @selectedOrganizationCountry.name
    }
  

  _cityselected: (e)->
    return unless e.detail.value
    @selectedOrganizationCity = e.detail.value
    console.log 'selected city', @selectedOrganizationCity
    console.log 'fetching orgs in selected cities'
    @_callGetAllOrganizationList {
      country: @selectedOrganizationCountry.name
      city: @selectedOrganizationCity
    }
  
  _callGetAllOrganizationList: (query)->
    @domHost.toggleModalLoader 'Loading all organization...'
    
    @domHost.callApi '/bdemr-get-all-organization-names', query or {}, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        console.log response.error.message
        @set 'organizationList', []
      else
        data = response.data.organizationList
        @set 'organizationList', data
        console.log 'organization list', @organizationList
  
  # agentSelected: (e)->
  #   return unless e.detail.value
  #   agent = e.detail.value
  #   console.log "Agent", agent
  #   @set 'selectedAgentDetails.name', agent.name
  #   @set 'selectedAgentDetails.phone', agent.phone
  #   @set 'selectedAgentDetails.idOnServer', agent.id


  _getFormattedChamberTime: (timeslotString)->
    startEnd = timeslotString.split('to')
    processedTimeSlot = "#{@$formatTimeString startEnd[0].trim()} to #{@$formatTimeString startEnd[1].trim()}"
    return processedTimeSlot

  _scheduleSelected: (e)->
    selectedDateStringIndex = @selectedDoctor.selectedSchedulePage
    if selectedDateStringIndex is 0
      schedule = @selectedDoctor.scheduleList[selectedDateStringIndex]
      @selectedDateString = schedule.dateString
      @selectedScheduleIdFromDateDropdown = schedule.scheduleId
      @selectedTimeSlotFromSchduleDateDrpdwn = schedule.timeSlotList


  prevSchedule: (e)->
    # el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    # el.opened = false
    # repeater = @$$ '#search-result-card-repeater'
    # index = repeater.indexForElement el
    # chamber = @chamberList[index]

    path = 'selectedDoctor.selectedSchedulePage'
    timeSlotPath = 'selectedDoctor._selectedTimeSlotIndex'

    @set timeSlotPath, -1

    if @selectedDoctor.selectedSchedulePage > 0
      @set path, @selectedDoctor.selectedSchedulePage - 1
      schedule = @selectedDoctor.scheduleList[@selectedDoctor.selectedSchedulePage]
      @selectedDateString = schedule.dateString
      @selectedTimeSlotFromSchduleDateDrpdwn = schedule.timeSlotList           
    else
      @set path, @selectedDoctor.scheduleList.length - 1
      schedule = @selectedDoctor.scheduleList[@selectedDoctor.scheduleList.length - 1]
      @selectedDateString = schedule.dateString
      @selectedTimeSlotFromSchduleDateDrpdwn = schedule.timeSlotList          


  nextSchedule: (e)->
    # el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    # el.opened = false
    # repeater = @$$ '#search-result-card-repeater'
    # index = repeater.indexForElement el
    # chamber = @chamberList[index]

    # path = 'chamberList.' + index + '.selectedSchedulePage'
    # timeSlotPath = 'chamberList.' + index + '._selectedTimeSlotIndex'

    path = 'selectedDoctor.selectedSchedulePage'
    timeSlotPath = 'selectedDoctor._selectedTimeSlotIndex'

    @set timeSlotPath, -1    

    if @selectedDoctor.selectedSchedulePage < @selectedDoctor.scheduleList.length - 1
      @set path, @selectedDoctor.selectedSchedulePage + 1
      schedule = @selectedDoctor.scheduleList[@selectedDoctor.selectedSchedulePage]
      console.log schedule
      @selectedDateString = schedule.dateString
      @selectedTimeSlotFromSchduleDateDrpdwn = schedule.timeSlotList
    else
      @set path, 0
      schedule = @selectedDoctor.scheduleList[0]
      @selectedDateString = schedule.dateString
      @selectedTimeSlotFromSchduleDateDrpdwn = schedule.timeSlotList  

  patchOverlay: (e)->
    if e.target.withBackdrop
      e.target.parentNode.insertBefore e.target.backdropElement, e.target

  doctorClicked: (e)->
    item = e.model.__data__.chamber
    console.log item
    dateString = item.scheduleList[0].dateString
    console.log dateString
    for myBooking in this.myBookingList
      if item.name is myBooking.chamberName and item.doctorId is myBooking.doctorId and myBooking.dateString is dateString and not myBooking.isCanceled
        item.alreadyHaveAnAppointment = true    
    @set 'selectedDoctor', item
    @set "selectedDoctorVisitFee", item.newPatientVisitFee
    @makeNewSignupPatientObject()
    @$$('#doctorBookingDetailsDialog').toggle()

  # ------------ signup new patient start ------------

  getSearchPatientBack: ()->
    @signupPatientDivHidden = true

  makeNewSignupPatientObject:()->
    newPatient =
      name: null
      phone: null
      repeatPhone: null
      email: null
      repeatEmail: null
      dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      gender: ''
      profileImage: null
      nationalIdCardNumber: null
      organizationId: @organization.idOnServer
      password: '123456'
      doctorAccessPin: '0000'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      isUserCreatedByAgent: true
      additionalPhoneNumber: null
      effectiveRegion: null
      bloodGroup: null
      allergy: null
      drugAllergy:
        value: null
        list: []
        
      emmergencyContact: 
        name: null
        relation: null
        phoneNumber: null

      addressList: [
        {
          addressTitle: 'Personal'
          addressType: 'personal'
          flat: null
          floor: null
          plot: null
          block: null
          road: null
          village: null
          addressUnion: null
          subdistrictName: null
          addressDistrict: null
          addressPostalOrZipCode: null
          addressCityOrTown: null
          addressLine1: null
          addressLine2: null
          stateOrProvince: null
          addressCountry: null
        }
      ]

      employmentDetailsList: []
      belongOrganizationList: []

      expenditure: null
      profession: null
      education: null

      patientSpouseName: null
      patientFatherName: null
      patientMotherName: null
      maritalAge: null
      maritalStatus: null
      numberOfFamilyMember: 0
      numberOfChildren: 0
      recordSpecificPatientIdList: []  
    @set 'newPatient', newPatient


  signUpNewPatient:()->
    
    unless @newPatient.name and @newPatient.dateOfBirth and @newPatient.gender and @newPatient.password
      @domHost.showToast 'Please fill up required fields'

    unless @newPatient.isUserCreatedByAgent
      @domhost.showToast 'Something went wrong, please reload and signup again'

    @newPatient.name = @$makeNameObject @newPatient.name
    @newPatient.apiKey = @user.apiKey
    
    @callApi '/bdemr--organizaiton-add-new-member', @newPatient, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        member = response.data
        if member.idOnServer
          @set 'selectedPatients', member
          @signupPatientDivHidden = true
        
  #------- signup new patient end ----------

  printBookingDetails: (e)->
    item = e.model.__data__.myBooking
    console.log 'Selected CHAMBER', item
    localStorage.setItem 'bookingDetails', JSON.stringify(item)
    window.location = '#/print-booking-details'

  searchDoctorToggleBtnPrsed: (e)->
    @$$("#notificationDrawer").toggle()

  clearSearchFilters: (e)->
    @$$("#notificationDrawer").close()

}
