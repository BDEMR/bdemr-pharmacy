
Polymer {

  is: 'page-visit-patient-stay-editor'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.pageLike
  ]

  properties:

    selectedView:
      type: Number
      value: -> 0
    
    isVisitValid: 
      type: Boolean
      notify: false
      value: true

    isPatientValid:
      type: Boolean
      notify: false
      value: true

    isPatientStayValid: 
      type: Boolean
      notify: false
      value: true 

    isThatNewPatientStay: 
      type: Boolean
      notify: false
      value: true    

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    visit:
      type: Object
      notify: true
      value: null

    patientStay:
      type: Object
      notify: true
      value: null

    patientStayObject:
      type: Object
      notify: true
      value: null

    organizationsIBelongToList:
      type: Array
      value: -> []

    proceduralAdviceList:
      type: Array
      value: -> []

    admissionTypeList:
      type: Array
      value: -> [
        'Out patient/ Discharged with advice'
        'Out patient/ Advised admission'
        'Seen in emergency/ Discharged with advice'
        'Seen in emergency/ Advised admission'
      ]
    
    locationList:
      type: Array
      value: -> [
        'Absconded'
        'Bed'
        'CT'
        'Discharged but waiting in bed'
        'Doctors chamber outside hospital'
        'Laboratory'
        'Out of bed on permission'
        'Pathology'
        'Smoking'
        'Ultrasound'
        'X-ray'
      ]

    defaultStatusList:
      type: Array
      value: -> [
        'Providing Information for Admission'
        'Currently at his/her Assigned Seat'
        'Getting Discharged'
      ]

    dischargeReasonList:
      type: Array
      value: -> [
        'Patient Got better'
        'Patient require care at bigger facility'
        'Patient care not possible at current facility'
        'Patient do not require further stay at hospital'
        'Death'
      ]
    
    dischargedToList:
      type: Array
      value: -> [
        'Home'
        'Rehabilitation'
        'Mortuary'
      ]

    selectedOrganizationIndex:
      type: Number
      value: -> null

    selectedStatusIndex:
      type: Number
      value: -1
      observer: 'selectedStatusIndexChanged'

    selectedDepartmentIndex:
      type: Number
      value: -> null
      observer: 'departmentSelected'

    selectedUnitIndex:
      type: Number
      value: -> null
      observer: 'unitSelected'
      
    selectedWardIndex:
      type: Number
      value: -> null
      observer: 'wardSelected'
      
    seatList:
      type: Array
      value: -> []
    
    fetchedStatusList:
      type: Array
      value: -> []

    patientDischarged:
      type: Boolean
      value: -> false

    patientInvoiceList:
      type: Array
      value: []
      observer: '_patientInvoiceListChanged'

    patientInvoiceListWithoutCompleted:
      type: Array
      value: []
    
    patientClearForDischarge:
      type: Boolean
      value: null

    patientStayButtonLabel:
      type: String
      value: 'Save Patient Stay'

    

  _hasDue: (billed, received)->
    return billed > received

  _areAllPaymentsCleared: (invoiceList)->
    for invoice in invoiceList
      return false if @_hasDue invoice.totalBilled, invoice.totalAmountReceieved
    return true


  navigatedIn: ->
    refreshPageFlag = JSON.parse localStorage.getItem 'refreshPatientStayPage'
    if refreshPageFlag and !refreshPageFlag.value
      localStorage.removeItem 'refreshPatientStayPage'
      @_loadUser()
    else
      @set 'patientStayButtonLabel', 'Save Patient Stay'
      @_loadUser()
      params = @domHost.getPageParams()

      unless params['patient']
        @_notifyInvalidPatient()
        return
      else
        @_loadPatient(params['patient'])

      if params['patient-stay'] is 'new'
        @_loadOperationNameList()  
        @_makeNewPatientStay()
        @isThatNewPatientStay = true
        @_makeNewVisit()
      else
        @_loadOperationNameList()        
        @isThatNewPatientStay = false
        @_loadVisitPatientStay params['patient-stay']

      @_loadOrganizationsIBelongTo ()=>
        # if visit is in edit mode
        unless params['patient-stay'] is 'new'
          organizationQueryParameters = @patientStay.organizationQueryParameters
          @set 'selectedOrganizationIndex', organizationQueryParameters.selectedOrganizationIndex
          @_loadPatientStayObject @organizationsIBelongToList[@selectedOrganizationIndex].idOnServer, ()=>
            @_loadDropdowns()
  

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      @set 'patient', list[0]
      @patient.emergencyContact = @patient.emmergencyContact or {}
      console.log @patient
    else
      @_notifyInvalidPatient()


  _loadPatientInvoice: (patientSerialIdentifier, organizationIdentifier)->
    invoiceList = app.db.find 'patient-invoice', ({patientSerial, organizationId})-> patientSerial is patientSerialIdentifier and organizationId is organizationIdentifier
    notCompletedInvoiceList = (item for item in invoiceList when item.flags.markAsCompleted isnt true)
    @set 'patientInvoiceList', invoiceList
    @set 'patientInvoiceListWithoutCompleted', notCompletedInvoiceList
    console.log 'patient invoice list', @patientInvoiceList


  _patientInvoiceListChanged: ()->
    @set 'patientClearForDischarge', @_areAllPaymentsCleared @patientInvoiceList
  

  _loadVisit: (visitIdentifier)->
    list = app.db.find 'doctor-visit', ({serial})-> serial is visitIdentifier
    if list.length is 1
      @isVisitValid = true
      @visit = list[0]
      # @_listPrescribedMedications()
      return true
    else
      @_notifyInvalidVisit()
      return false

  _loadVisitPatientStay: (patientStayIdentifier)->
    list = app.db.find 'visit-patient-stay', ({serial})-> serial is patientStayIdentifier
    if list.length is 1
      @isPatientStayValid = true
      @set 'patientStay', list[0]
      return if @patientStay.adviseOnly is true
      @async ()=> @patientStayAdmissionDate = @$mkDate @patientStay.data.admissionDateTimeStamp
      console.log 'patient stay obj', @patientStay
    else
      @_notifyInvalidPatientStay()
  
  _loadOrganizationsIBelongTo: (cbfn)->
    data = { 
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-organization-list-those-user-belongs-to', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'organizationsIBelongToList', response.data.organizationObjectList
        cbfn() if cbfn

  _loadDropdowns: ->
    # if record is in edit mode
    if 'organizationQueryParameters' of @patientStay
      organizationQueryParameters = @patientStay.organizationQueryParameters
      @set 'selectedOrganizationIndex', organizationQueryParameters.selectedOrganizationIndex
      @set 'selectedDepartmentIndex', organizationQueryParameters.selectedDepartmentIndex
      @set 'selectedUnitIndex', organizationQueryParameters.selectedUnitIndex
      @set 'selectedWardIndex', organizationQueryParameters.selectedWardIndex
      @set 'selectedStatusIndex', organizationQueryParameters.selectedStatusIndex

  $notUndefined: (value)-> if value? then true else false

  _loadPatientStayObject: (organizationId, cbfn)->
    data = { 
      apiKey: @user.apiKey
      organizationId: organizationId
    }
    @callApi '/bdemr-organization-patient-stay-get-object', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'patientStayObject', response.data.patientStayObject
        console.log @patientStayObject
        unless @patientStayObject.locations
          @patientStayObject.locations = @locationList
        unless @patientStayObject.statusList
          @patientStayObject.statusList = @defaultStatusList
        cbfn() if cbfn


  organizationSelected: (e)->
    if @selectedOrganizationIndex?
      @set 'organization', @organizationsIBelongToList[@selectedOrganizationIndex]
      @_loadPatientInvoice @patient.serial, @organization.idOnServer
      @_loadPatientStayObject @organization.idOnServer, ()=>
        @async ()-> @_populateSeatList()
  
  departmentSelected: (e)->
    if @selectedDepartmentIndex?
      department = @patientStayObject.departmentList[@selectedDepartmentIndex]
      @department = department
      @set 'unitList', department.unitList
      @debounce 'iron-select', (()-> @_populateSeatList @department), 50
      @selectedUnitIndex = null
      @selectedWardIndex = null

  unitSelected: (e)->
    if @selectedUnitIndex?
      unit = @department.unitList[@selectedUnitIndex]
      @unit = unit
      @set 'wardList', unit.wardList
      # @selectedWardIndex = null
      @debounce 'iron-select', (()-> @_populateSeatList @department, @unit), 50

  wardSelected: (e)->
    if @selectedWardIndex?
      ward = @unit.wardList[@selectedWardIndex]
      @ward = ward
      @debounce 'iron-select', (()-> @_populateSeatList @department, @unit, @ward), 50
      

  _populateSeatList: (department=null, unit=null, ward=null)->
    if ward
      seatList = (seat for seat in @patientStayObject.seatList when (department.name is seat.department and unit.name is seat.unit and ward.name is seat.ward))
      @set 'seatList', seatList
      @$$("#seatList").fire('iron-resize')
      return
    if unit
      seatList = (seat for seat in @patientStayObject.seatList when (department.name is seat.department and unit.name is seat.unit))
      @set 'seatList', seatList
      @$$("#seatList").fire('iron-resize')
      return
    if department
      seatList = (seat for seat in @patientStayObject.seatList when department.name is seat.department)
      @set 'seatList', seatList
      @$$("#seatList").fire('iron-resize')
      return

    @set 'seatList', @patientStayObject.seatList
    # if @seatList.length
    #   @$$("#seatList").fire('iron-resize')


  fillTapped: (e)->
    for seat, index in @seatList
      if seat.patientSerial is @patient.serial
        @set "seatList.#{index}.patientSerial", null
        @set "seatList.#{index}.location", ''
    @set "seatList.#{e.model.index}.patientSerial", @patient.serial
    @set "seatList.#{e.model.index}.patientAdmittedDatetimeStamp", lib.datetime.now()
    @set "seatList.#{e.model.index}.patientName", @$getFullName @patient.name
    @set "seatList.#{e.model.index}.patientEmailOrPhone", if @patient.phone then @patient.phone else @patient.email

  dischargeTapped: (e)->
    index = e.model.index
    @set "seatList.#{index}.patientSerial", null
    @set "seatList.#{index}.patientAdmittedDatetimeStamp", null
    @set "seatList.#{index}.patientName", ''
    @set "seatList.#{index}.patientEmailOrPhone", ''
    @set "seatList.#{index}.location", ''
    @unshift 'patientStay.data.currentLocation', {datetimeStamp: lib.datetime.now(), location: 'Discharged'}
    @unshift 'patientStay.data.currentPatientStatus', {datetimeStamp: lib.datetime.now(), status: 'Patient Discharged'}
    
    @patientDischarged = true
    @set 'selectedView', 1

    @set 'patientStayButtonLabel', 'Discharge'


  addOverflow: ->
    seat = {
      department: @department.name
      unit: @unit.name
      ward: @ward.name
    }
    seat.patientSerial = @patient.serial
    seat.patientName = @$getFullName @patient.name
    seat.patientEmailOrPhone = if @patient.phone then @patient.phone else 
    seat.patientAdmittedDatetimeStamp = lib.datetime.now()
    seat.name = 'Overflow Seat'
    seat.uid = (@patientStayObject.seatSeed++)
    seat.isOverflow = true
    @push 'seatList', seat

  
  admissionTypeChanged: (e)->
    switch @patientStay.data.admissionType
      when 'Out patient/ Discharged with advice', 'Seen in emergency/ Discharged with advice' then @advisedAdmission = false
      when 'Out patient/ Advised admission', 'Seen in emergency/ Advised admission' then @advisedAdmission = true
      else @showAdmission = true
    
  customLocationAdded: (e)->
    if e.keyCode is 13
      value = e.target.value
      e.target.value = ""
      @push 'patientStayObject.locations', value
      el = @$$("#locationRadioGroup")
      el.selected = value
      for seat, index in @seatList
        if seat.patientSerial is @patient.serial
          @set "seatList.#{index}.location", value

  
  locationChanged: (e)->
    for seat, index in @seatList
      if seat.patientSerial is @patient.serial
        @set "seatList.#{index}.location", @selectedLocation
        @unshift 'patientStay.data.currentLocation', {datetimeStamp: lib.datetime.now(), location: @selectedLocation}
        return
    @domHost.showToast 'Fill a seat first.'

  deleteLocationEntry: (e)->
    index = e.model.index
    @splice 'patientStay.data.currentLocation', index, 1    

  selectedStatusIndexChanged: (newIndex)->
    if @patientStayObject
      item = @patientStayObject.statusList[newIndex]
      for seat, index in @seatList
        if seat.patientSerial is @patient.serial
          @set "seatList.#{index}.status", item
          @unshift 'patientStay.data.currentPatientStatus', {datetimeStamp: lib.datetime.now(), status: item}
          return
      @domHost.showToast 'Fill a seat first.'

  deleteStatusHistory: (e)->
    index = e.model.index
    @splice 'patientStay.data.currentPatientStatus', index, 1
    

  dischargeReasonChanged: (e)->
    checked = e.target.checked
    value = e.target.name
    if checked
      @push 'patientStay.data.dischargeReason', value
    else
      if (index = @patientStay.data.dischargeReason.indexOf value) > -1
        @splice 'patientStay.data.dischargeReason', index, 1
  
  customDischargeReasonAdded: (e)->
    if e.keyCode is 13
      value = e.target.value
      e.target.value = ""
      @push 'patientStay.data.dischargeReason', value

  dischargedToChanged: (e)->
    checked = e.target.checked
    value = e.target.name
    if checked
      @push 'patientStay.data.dischargeTo', value
    else
      if (index = @patientStay.data.dischargeTo.indexOf value) > -1
        @splice 'patientStay.data.dischargeTo', index, 1
  
  customDischargeToAdded: (e)->
    if e.keyCode is 13
      value = e.target.value
      e.target.value = ""
      @push 'patientStay.data.dischargeTo', value


  $findCreator: (creatorSerial)-> 'me'

  _makeNewVisit: ()->
    @visit =
      serial: null
      idOnServer: null
      source: 'local'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      doctorsPrivateNote: ''
      patientSerial: @patient.serial
      recordType: 'doctor-visit'
      doctorName: @user.name
      hospitalName: null
      doctorSpeciality: null
      prescriptionSerial: null
      doctorNotesSerial: null
      nextVisitSerial: null
      advisedTestSerial: null
      patientStaySerial: null
      invoiceSerial: null
      historyAndPhysicalRecordSerial: null
      diagnosisSerial: null
      vitalsSerial: null
      testResults: {
        serial: null
        name: null
        attachmentSerialList: []
      }

    @isVisitValid = true


  _makeNewPatientStay: ()->
    patientStay = 
      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      visitSerial: null
      patientSerial: @patient.serial
      adviseOnly: false
      data:
        referredByDoctorName: ''
        admittedByDoctorName: @user.name
        admissionDateTimeStamp: null
        admissionType: ''
        operationName: ''
        advise: ''
        locationHospitalName: ''
        locationDepartment: ''
        locationUnit: ''
        locationWard: ''
        locationBed: ''
        currentLocation: []
        currentPatientStatus: []
        dischargedByDoctorName: ''
        dischargeDatetimeStamp: null
        dischargeReason: []
        dischargeTo: []
        consentData: null
    
    @set 'patientStay', patientStay
    @isPatientStayValid = true
    @patientStayAdmissionDate = @$mkDate new Date
    

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  $of: (a, b)->
    unless b of a
      a[b] = null
    return a[b]

  _sortByDate: (a, b)->
    return (b.datetimeStamp - a.datetimeStamp)

  addCustomDischargedPressed:(e)->
    if e.which is 13
      value = e.target.value
      e.target.value = ''
      
      @patientStay.data.dischargeCustomCheckedMap[value] = false
      @push 'patientStay.data.dischargeCustomList', value
  
  patientStayDischargeChanged: (e)->
    { item } = e.model
    value = not @get ('patientStay.data.dischargeCustomCheckedMap.' + item)
    # console.log value
    @set ('patientStay.data.dischargeCustomCheckedMap.' + item), value


  _dateTimeToMS: (datetime)-> return (new Date datetime).getTime()

  _makeNameObject: (fullName)->
    if typeof fullName is 'string'
      fullName = fullName.trim()
      partArray = fullName.split('.')
      namePart = partArray.pop()
      if partArray.length is 0 
        honorifics = ''
      else
        honorifics = partArray.join('.').trim()
      partArray = (namePart.trim()).split(' ')
      nameObject = {}
      if (partArray.length <= 1)
        first = partArray[0]
      else
        first = partArray.shift()
        last = partArray.pop()
        middle = partArray.join(' ')
        if middle is ''
          middle = null
        
        if last is ''
          last = null
      if honorifics is ''
        honorifics = null
      nameObject.honorifics = honorifics
      nameObject.first = first
      nameObject.middle = middle
      nameObject.last = last
      return nameObject
    else
      return fullName
  
  
  updatePatientDetails: ()->
    console.log 'PATIENT', @patient
    unless @patient.name and @patient.dateOfBirth
      @domHost.showToast 'Please Fill Up Required Information'
      return
    @patient.name = @_makeNameObject @patient.name
    app.db.upsert 'patient-list', @patient, ({serial})=> @patient.serial is serial
    
    data = {
      patient: @patient
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-patient-details-update', data, (err, response)=>
      if response.hasError
        @domHost.showToast response.error.message
      
  
  _saveBedInfo: ->
    for item in @seatList
      if item.patientSerial is @patient.serial
        @patientStay.data.locationHospitalName = @organizationsIBelongToList[@selectedOrganizationIndex].name
        @patientStay.data.locationHospitalId = @organizationsIBelongToList[@selectedOrganizationIndex].idOnServer
        @patientStay.data.locationDepartment = item.department
        @patientStay.data.locationUnit = item.unit
        @patientStay.data.locationWard = item.ward
        @patientStay.data.locationBed = item.name
        break
  
  _validatePatientStayData: (patientStay)->
    if @patientDischarged 
      unless @patientStayDischargeDate
        @domHost.showModalDialog 'Discharge Date is required'
        return false
      unless patientStay.data.dischargeReason.length
        @domHost.showModalDialog 'Please specify a discharge reason'
        return false
    else 
      if @advisedAdmission
        unless @patientStayAdmissionDate
          @domHost.showModalDialog 'Admission Date is required'
          return false
        unless patientStay.data.currentLocation.length
          @domHost.showModalDialog 'Please spcify patient current location'
          return false
        unless patientStay.data.currentPatientStatus.length
          @domHost.showModalDialog 'Please spcify patients current status'
          return false
      else
        unless patientStay.data.advise
          @domHost.showModalDialog 'Specify Advise to patient'
          return false
    return true
  
  savePatientStayButtonPressed: (e)->
    return unless @_validatePatientStayData(@patientStay)
    unless @patientStay.serial
      @patientStay.serial = @generateSerialForPatientStay()
    @updatePatientDetails()    
    if @organization?.idOnServer
      @savePatientStayObject =>
        @_savePatientStay()
        @domHost.showToast 'Patient Stay Saved!'
        @arrowBackButtonPressed()
    else
      # Save Patient Stay data without organization values
      @_savePatientStay()
      @domHost.showToast 'Patient Stay Saved!'
      @arrowBackButtonPressed()

  
  savePatientStayObject: (cbfn)->

    if @patientStayButtonLabel is 'Discharge'
      seatList = []
      seatList = @patientStayObject.seatList
      for item, index in seatList
        if @patient.serial is item.patientSerial
          @patientStayObject.seatList[index].patientSerial = null
          @patientStayObject.seatList[index].patientAdmittedDatetimeStamp = null
          @patientStayObject.seatList[index].patientName = ''
          @patientStayObject.seatList[index].patientEmailOrPhone = ''
          @patientStayObject.seatList[index].location = ''
          @patientStayObject.seatList[index].status = ''

    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      patientStayObject: @patientStayObject
    }

    console.log @patientStayObject
    @callApi '/bdemr-organization-patient-stay-set-object', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn() if cbfn

  _savePatientStay: ()->
    @_saveBedInfo()
    @patientStay.organizationQueryParameters = {
      selectedOrganizationIndex: @selectedOrganizationIndex
      selectedDepartmentIndex: @selectedDepartmentIndex
      selectedUnitIndex: @selectedUnitIndex
      selectedWardIndex: @selectedWardIndex
      selectedStatusIndex: @selectedStatusIndex
    }
    console.log @patientStay.organizationQueryParameters
    @set 'patientStay.data.admissionDateTimeStamp', @_dateTimeToMS @patientStayAdmissionDate
    if @patientDischarged
      @set 'patientStay.data.dischargeDatetimeStamp', @_dateTimeToMS @patientStayDischargeDate
    @patientStay.lastModifiedDatetimeStamp = lib.datetime.now()
    console.log @patientStay
    app.db.upsert 'visit-patient-stay', @patientStay, ({serial})=> @patientStay.serial is serial
  
  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  _notifyInvalidVisit: ->
    @isVisitValid = false
    @domHost.showModalDialog 'Invalid Visit Provided'

  _notifyInvalidPatientStay: ->
    @isVisitValid = false
    @domHost.showModalDialog 'Invalid Patient Stay Provided'

  
  # psedo lifecycle callback
  
  _checkUserAccess: (accessId)->
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return false

          return false
        else
          return false

      else
        return true

  navigatedOut: ->
    refreshPageFlag = JSON.parse localStorage.getItem 'refreshPatientStayPage'
    unless refreshPageFlag
      @visit = {}
      @patient = {}
      @patientStay = {}
      @isVisitValid = false
      @isPatientValid = false
      @isPatientStayValid = true
      @selectedView = 0
      @patientStay = null
      @patientStayObject = null
      @organizationsIBelongToList = []
      @selectedOrganizationIndex = null
      @selectedDepartmentIndex = null
      @selectedUnitIndex = null
      @seatList = []
      @patientDischarged = false


  _preparePatientStayPrintPreview: (patientStay)->
    patientStayPreview = {
      adviseOnly : patientStay.adviseOnly
      data : {
        admissionDateTimeStamp : @_dateTimeToMS @patientStayAdmissionDate
        admissionType : patientStay.data.admissionType
        operationName: patientStay.data.operationName
        advise : patientStay.data.advise
        referredByDoctorName : patientStay.data.referredByDoctorName
        admittedByDoctorName : patientStay.data.admittedByDoctorName
        dischargeDatetimeStamp : if @patientDischarged then @_dateTimeToMS @patientStayDischargeDate else null
        locationHospitalName : null
        locationDepartment : null
        locationUnit : null
        locationWard : null
        locationBed : null
        currentLocation : patientStay.data.currentLocation
        dischargedByDoctorName : patientStay.data.dischargedByDoctorName
        dischargeReason : patientStay.data.dischargeReason
        dischargeTo : patientStay.data.dischargeTo
      }
    }

    for item in @seatList
      if item.patientSerial is @patient.serial
        patientStayPreview.data.locationHospitalName = @organizationsIBelongToList[@selectedOrganizationIndex].name
        patientStayPreview.data.locationDepartment = item.department
        patientStayPreview.data.locationUnit = item.unit
        patientStayPreview.data.locationWard = item.ward
        patientStayPreview.data.locationBed = item.name
        break
    return patientStayPreview


  showPrintPreviewButtonPressed: ()->
    # remove first if exists
    patientStayPreview = @_preparePatientStayPrintPreview @patientStay
    localStorage.removeItem 'previewPatientStayObject'
    localStorage.removeItem 'previewPatientStayPatientObject'
    localStorage.removeItem 'refreshPatientStayPage'

    localStorage.setItem 'previewPatientStayObject', JSON.stringify patientStayPreview
    localStorage.setItem 'previewPatientStayPatientObject', JSON.stringify @patient
    localStorage.setItem 'refreshPatientStayPage', JSON.stringify {value: false}

    @domHost.navigateToPage '#/patient-stay-print-preview'

  _loadOperationNameList: ()->
    @domHost.getStaticData 'proceduralAdviceList', (list)=>
      for item in list
        @proceduralAdviceList.push(item.advice)
    
  operationNameSelected: (e)->
    return unless e.detail.value
    @operation = e.detail.value
    # set operation name in seat-wise info
    for seat, index in @seatList
      if seat.patientSerial is @patient.serial
        @set "seatList.#{index}.operationName", @operation
    # set operation name for normal usages like print, overview
    @set 'patientStay.data.operationName', @operation
    return
}