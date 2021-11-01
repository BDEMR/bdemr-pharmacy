
Polymer {

  is: 'page-visit-preview'

  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:
    collectiveRecords:
      type: Array
      value: []

    comboBoxSymptomsInputValue:
      type: String
      notify: true
      value: null

    walletBalance:
      type: Number
      value: -1
    
    currentOrganization:
      type: Object
      notify: true
      value: null

    selectedMedicinePage:
      type: Number
      notify: false
      value: 0

    printPrescriptionOnly:
      type: Boolean
      notify: true
      value: true


    isBPAdded:
      type: Boolean
      notify: true
      value: false

    isHRAdded:
      type: Boolean
      notify: true
      value: false

    isBMIAdded:
      type: Boolean
      notify: true
      value: false

    isSpO2Added:
      type: Boolean
      notify: true
      value: false

    isRRAdded:
      type: Boolean
      notify: true
      value: false
    prescriptionList:
      type: Array
      notify: true
      value :[]
    isTempAdded:
      type: Boolean
      notify: true
      value: false

    isThatNewVisit:
      type: Boolean
      notify: true
      value: true


    visitHeaderTitleList:
      type: Array
      notify: false
      value: [
        'Complete Visit',
        'Discharge Note',
      ]

    insulineMedicineList:
      type: Array
      notify: true
      value: -> []


    visitHeaderTitleSelectedIndex:
      type: Number
      notify: false
      value: 0



    isVisitValid:
      type: Boolean
      notify: false
      value: false

    selectedVisitPageIndex:
      type: Number
      notify: false
      value: false

    isPrescriptionValid:
      type: Boolean
      notify: false
      value: false

    isNoteValid:
      type: Boolean
      notify: false
      value: false

    isNextVisitValid:
      type: Boolean
      notify: true
      value: false

    isInvoiceValid:
      type: Boolean
      notify: false
      value: false

    isTestAdvisedValid:
      type: Boolean
      notify: false
      value: false


    isPatientValid:
      type: Boolean
      notify: false
      value: false

    isFullVisitValid:
      type: Boolean
      notify: false
      value: false

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null
    doctorOrganizationDetails:
      type: Array
      notify: true
      value: ->[]

    visit:
      type: Object
      notify: true
      value: null

    doctorNotes:
      type: Object
      notify: true
      value: null

    doctorNotesMessage:
      type: String
      notify: true
      value: ''

    nextVisit:
      type: Object
      notify: true
      value: null

    testAdvised:
      type: Object
      notify: true
      value: null

    invoice:
      type: Object
      notify: true
      value: null

    matchingPrescribedMedicineList:
      type: Array
      notify: true
      value: []

    doctorInstitutionList:
      type: Array
      notify: true
      value: []

    doctorSpecialityList:
      type: Array
      notify: true
      value: []

    doctorInstitutionSelectedIndex:
      type: Number
      notify: true
      value: 0

    doctorSpecialitySelectedIndex:
      type: Number
      notify: true
      value: 0

    hasTestResults:
      type: Boolean
      notify: true
      value: false

    ## historyAndPhysicalRecord - start
    historyAndPhysicalRecord:
      type: Object
      notify: true
      value: null

    matchingRecordList:
      type: Object
      notify: true
      value: null

    ## historyAndPhysicalRecord - end

    ## diagnosis - start
    diagnosis:
      type: Object
      notify: true
      value: null

    isDiagnosisValid:
      type: Boolean
      value: false

    diagnosisListArray:
      type: Array
      notify: true
      value: []

    selectedDiagnosisListArray:
      type: Array
      notify: true
      value: []

    ## diagnosis - end

    #####################################################################
    ### Prescription - start
    #####################################################################
    prescription:
      type: Object
      notify: true
      value: null

    matchingPrescribedMedicineList:
      type: Array
      notify: true
      value: []

    matchingCurrentMedicineList:
      type: Array
      notify: true
      value: []

    matchingFavoriteMedicineList:
      type: Array
      notify: true
      value: []

    duplicateMedicineEditablePart:
      type: Object
      notify: true
      value: null

    favoriteMedicineShownIndex:
      type: Number
      value: 0

    isMedicineValid:
      type: Boolean
      notify: false
      value: true  

    isThatNewMedicine:
      type: Boolean
      notify: false
      value: true

    medicine:
      type: Object
      notify: true
      value: {}

    strengthList:
      type: Array
      value: []

    continueMedicineEndsOnDate:
      type: String
      value: null

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
    doseUnitList:
      type: Array
      value: ['Custom']
    endDateTimeTypeList:
      type: Array
      value: [
        'As Needed'
        '0 Weeks'
        '1 Week'
        '2 Weeks'
        '3 Weeks'
        'Custom'
      ]
    endDateTimeTypeArgument2List:
      type: Array
      value: [
        '0 Day'
        '1 Day'
        '2 Days'
        '3 Days'
        '4 Days'
        '5 Days'
        '6 Days'
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

    intervalInDays:
      type: Number
      value: 1
    medicineFormSelectedIndex:
      type: Number
      value: 0
    doseUnitSelectedIndex:
      type: Number
      value: 0
    directionSelectedIndex:
      type: Number
      value: 0
    routeSelectedIndex:
      type: Number
      value: 0
    endDateTimeTypeSelectedIndex:
      type: Number
      value: 0
    endDateTimeTypeArgument2SelectedIndex:
      type: Number
      value: 0
    strengthSelectedIndex:
      type: Number
      value: 0
      notify: true
    
    matchingMedicineList:
      type: Array
      value: []
    
    doseGuidelineList:
      type: Array
    activeDoseGuideline:
      type: Object
      value: null
    guidelineIndicationSelectedIndex:
      type: Number
      value: null
    guidelineAgeSelectedIndex:
      type: Number
      value: null
    guidelineIndicationList:
      type: Array
      value: -> []
    guidelineAgeList:
      type: Array
      value: -> []
    
    insulinMedicine:
      type: Object
      value: -> null
    
    medicineCompositionList:
      type: Array
      value: []

    brandNameSourceDataList:
      type: Array
      value: []
    brandNameSelectedObjectList:
      type: Array
      value: []
    genericNameSourceDataList:
      type: Array
      value: []
    
    showDetailedForm:
      type: Boolean
      value: false
    
    showGuidelineDisclaimer:
      type: Boolean
      value: true
      notify: true
    

    selectedCurrentMedicineData:
      type: Object
      value: null

    #####################################################################
    ### Prescription - end
    #####################################################################

    #####################################################################
    ### Symptoms - start
    #####################################################################
    symptomsDataList:
      type: Array
      notify: true
      value: []

    addedIdentifiedSymptomsList:
      type: Array
      notify: true
      value: []

    customSymptomsObject:
      type: Object
      notify: true
      value: {}
    #####################################################################
    ### Symptoms - end
    #####################################################################

    #####################################################################
    ### Examination - start
    #####################################################################
    examinationDataList:
      type: Array
      notify: true
      value: []

    addedExaminationList:
      type: Array
      notify: true
      value: []

    addedExaminationList2:
      type: Array
      notify: true
      value: ()-> []

    examinationObject:
      type: Object
      notify: true
      value: {}


    addedChildHistoryList:
      type: Array
      notify: true
      value: ()-> []

    addedBirthHistoryList:
      type: Array
      notify: true
      value: ()-> []

    familyHistoryNotes:
      type: Array
      notify: true
      value: ()-> []


    


    #####################################################################
    ### Examination - end
    #####################################################################



    #####################################################################
    ### Test Advised - start
    #####################################################################

    favoriteInvestigaitonList:
      type: Array
      notify: true
      value: []

    investigationMemberValue:
      type: String
      notify: true
      value: ''

    investigationDataList:
      type: Array
      notify: true
      value: []

    addedInvestigationList:
      type: Array
      notify: true
      value: []

    testAdvisedObject:
      type: Object
      notify: true
      value: {}

    suggestedInstitutionValue:
      type: String
      value: ''
      notify: true

    machingUserAddedInstitutionList:
      type: Array
      value: []
      notify: true

    addedInvestigationNameIndex:
      type: Number
      value: 0

    customInvestigationObject:
      type: Object
      notify: true
      value: {}

    customInvestigationUnitValue:
      type: String
      value: ''
      notify: true

    customInvestigationUnitList:
      type: Array
      value: []
      notify: true



    #####################################################################
    ### Test Advised - end
    #####################################################################

    #####################################################################
    ### Vitals - start
    #####################################################################

    selectedVitalIndex:
      type: Number
      value: -1
      notify: true

    heightUnitSelectedIndex:
      type: Number
      value: 0
      notify: true
    weightUnitSelectedIndex:
      type: Number
      value: 0
      notify: true
    tempUnitSelectedIndex:
      type: Number
      value: 0
      notify: true

    bloodPressure:
      type: Object
      notify: true
      value: {}
    pulseRate:
      type: Object
      notify: true
      value: {}
    bmi:
      type: Object
      notify: true
      value: {}
    respiratoryRate:
      type: Object
      notify: true
      rpm: {}
    oxygenSaturation:
      type: Object
      notify: true
      value: {}
    temperature:
      type: Object
      notify: true
      value: {}

    addedVitalList:
      type: Array
      value: []

    #####################################################################
    # Vitals - end
    #####################################################################

    #####################################################################
    # Next Visit - start
    #####################################################################


    priorityTypeList:
      type: Array
      value: [
        'As Necessary'
        'Others'
      ]

    nextVisitDurationTypeList:
      type: Array
      value: [
        '0 Day'
        '1 Day'
        '2 Days'
        '3 Days'
        '4 Days'
        '5 Days'
        '6 Days'
        '7 Days'
        '8 Days'
        '9 Days'
        '10 Days'
        '11 Days'
        '12 Days'
        '13 Days'
        '14 Days'
        '15 Days'
        '1 Week'
        '2 Weeks'
        '3 Weeks'
        '4 Weeks'
        '1 month'
        '2 months'
        '3 months'
        '4 months'
        '5 months'
        '6 months'
        '7 months'
        '8 months'
        '9 months'
        '11 month'
        '1 year'
        '2 years'
        '3 years'
        'Custom'
      ]

    nextVisitDurationTypeSelectedIndex:
      type: Number
      notify: true
      value: 0

    nextVisitPriorityTypeSelectedIndex:
      type: Number
      notify: true
      value: 0

    isCustomDateTypeSelected:
      type: Boolean
      notify: true
      value: false

    insulinTypeList:
      type: Array
      value: ->
        [
          {
            label: 'Bolus (Mealtime Insulin)'
            value: 'Bolus (Mealtime Insulin)'
          }
          {
            label: 'Premix'
            value: 'Premix'
          }
          {
            label: 'Split Mix'
            value: 'Split Mix'
          }
          {
            label: 'Basal & Bolus'
            value: 'Basal & Bolus'
          }
          {
            label: 'Basal Plus'
            value: 'Basal Plus'
          }
          {
            label: 'Basal Only'
            value: 'Basal Only'
          }
        ]

    insulinDrugList:
      type: Array
      value: ->
        [
          {
            label: 'Insulatard 100 IU Vial'
            value: 'Insulatard 100 IU Vial'
          }
          {
            label: 'Insulatard Penfill'
            value: 'Insulatard Penfill'
          }
          {
            label: 'Levemir'
            value: 'Levemir'
          }
          {
            label: 'Tresiba'
            value: 'Tresiba'
          }
          {
            label: 'Victoza'
            value: 'Victoza'
          }
          {
            label: 'Insulatard Flexpen'
            value: 'Insulatard Flexpen'
          }

          {
            label: 'Actrapid Penfill'
            value: 'Actrapid Penfill'
          }
          {
            label: 'NovoRapid FlexPen'
            value: 'NovoRapid FlexPen'
          }
          {
            label: 'NovoRapid Penfill'
            value: 'NovoRapid Penfill'
          }
          {
            label: 'Actrapid 100 IU Vial'
            value: 'Actrapid 100 IU Vial'
          }
          {
            label: 'Actrapid FlexPen-Humean Insulin'
            value: 'Actrapid FlexPen-Humean Insulin'
          }

          {
            label: 'Mixtard 30 100 IU Vial'
            value: 'Mixtard 30 100 IU Vial'
          }
          {
            label: 'Mixtard 30 Penfill'
            value: 'Mixtard 30 Penfill'
          }
          {
            label: 'Mixtard 50 Penfill'
            value: 'Mixtard 50 Penfill'
          }
          {
            label: 'NovoMix 30 FlexPen'
            value: 'NovoMix 30 FlexPen'
          }
          {
            label: 'Ryzodeg'
            value: 'Ryzodeg'
          }
          {
            label: 'NovoMix 30 Penfill'
            value: 'NovoMix 30 Penfill'
          }
          {
            label: 'Mixtard 30 FlexPen'
            value: 'Mixtard 30 FlexPen'
          }
        ]


    #####################################################################
    # Full Visit Preview - start
    #####################################################################
    settings:
      type: Object
      notify: true

    ## VIEW - HistoryAndPhysicalRecord - start
    record:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    recordDatabaseCollectionName:
      type: String
      value: null

    recordPartName:
      type: String
      value: null

    recordPartData:
      type: Object
      value: null

    recordPartDef:
      type: Object
      value: null

    recordPartTitle:
      type: String
      value: null

    recordPartHtmlContent:
      type: String
      value: null

    shouldRender:
      type: Boolean
      value: false

    delayRendering:
      type: Boolean
      value: false

    childHistoryObject:
      type: Object
      notify: true
      value: {}
    
    birthHistoryObject:
      type: Object
      notify: true
      value: {}

    familyHistoryNotes:
      type: Object
      notify: true
      value: null

    ## provisional diagnosis - start
    provisionalDiagnosis:
      type: Object
      notify: true
      value: null

    isProvisionalDiagnosisValid:
      type: Boolean
      value: false
    ## provisional diagnosis - end

    ## differential diagnosis - start
    differentialDiagnosis:
      type: Object
      notify: true
      value: null

    isDifferentialDiagnosisValid:
      type: Boolean
      value: false
    ## differential diagnosis - end

    addedIdentifiedPhysiotherapyList:
      type: Array
      notify: true
      value: []
    
    referralDoctor:
      type: Object
      notify: true
      value: {}

    referralOrganization:
      type: Object
      notify: true
      value: {}

  # Util Functions - start
  $of: (a, b)->
    unless b of a
      a[b] = null
    return a[b]

  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

  _isEmptyString: (data)->
    if data is null or data is '' or data is 'undefined'
      return true
    else
      return false

  _compareFn: (left, op, right) ->
    # lib.util.delay 5, ()=>
    if op is '<'
      return left < right
    if op is '>'
      return left > right
    if op is '=='
      return left == right
    if op is '>='
      return left >= right
    if op is '<='
      return left <= right
    if op is '!='
      return left != right

  _sortByDate: (a, b)->
    if a.lastModifiedDatetimeStamp < b.lastModifiedDatetimeStamp
      return 1
    if a.lastModifiedDatetimeStamp > b.lastModifiedDatetimeStamp
      return -1

  _computeTotalDaysCount: (endDate, startDate)->
    return (@$TRANSLATE 'As Needed', @LANG) unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    endDate = new Date endDate
    diffMs = endDate - startDate
    return @$TRANSLATE (Math.round(diffMs / oneDay)), @LANG

  _returnSerial: (index)->
    index+1

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--

    return age
  # Util Functions - end
    

  _loadUser:(cbfn)->
    list = app.db.find 'user'
    console.log 'USER: ', list[0]
    if list.length is 1
      @user = list[0]
      @_getEmploymentList @user
      @_getSpecializationList @user

    else
      @domHost.showModalDialog 'Invalid User!'

    cbfn()

  _getEmploymentList: (user)->
    if user.employmentDetailsList.length > 0
      for employmentDetails in user.employmentDetailsList
        @push 'doctorInstitutionList', employmentDetails?.institutionName
    else
      @doctorInstitutionList = []

  _getSpecializationList: (user)->
    if user.specializationList.length > 0
      for specializationDetails in user.specializationList
        @push 'doctorSpecialityList', specializationDetails.specializationTitle
    else
      @doctorSpecialityList = []


  _loadPatient: (patientIdentifier, cbfn)->
    console.log 'PATIENT:', patientIdentifier

    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    console.log 'PATIENT:', list

    if list.length is 1
      @isPatientValid = true
      @patient = list[0]
      console.log 'PATIENT:', @patient
      @push 'collectiveRecords', { collection: 'patient-list', data: list}
    else
      @_notifyInvalidPatient()

    cbfn()

  _listPrescribedMedications: (prescriptionIdentifier) ->
    # console.log prescriptionIdentifier
    prescribedMedicineList = app.db.find 'patient-medications', ({prescriptionSerial})=> prescriptionIdentifier is prescriptionSerial

    medicineList = [].concat prescribedMedicineList
    medicineList.sort (left, right)->
      return -1 if left.createdDatetimeStamp < right.createdDatetimeStamp
      return 1 if left.createdDatetimeStamp > right.createdDatetimeStamp
      return 0

    @matchingPrescribedMedicineList = medicineList
    @push 'collectiveRecords', { collection: 'patient-medications', data: @matchingPrescribedMedicineList}
    console.log "MEDICINE LIST:", @matchingPrescribedMedicineList


  ## Load Prescription
  _loadPrescription: (prescriptionIdentifier)->
    list = app.db.find 'visit-prescription', ({serial})-> serial is prescriptionIdentifier
    if list.length is 1
      @isPrescriptionValid = true
      @prescription = list[0]
      console.log "PRESCRIPTION: ", @prescription
      @_listPrescribedMedications @prescription.serial
      @push 'collectiveRecords', { collection: 'visit-prescription', data: list}
      return true
    else
      @_notifyInvalidPrescription()
      return false
  
  ## Load Symptoms Data

      
  ## Load Examination Data
  _loadExamination: (examinationIdentifier)->

    list = app.db.find 'visit-examination', ({serial})-> serial is examinationIdentifier
    if list.length is 1
      @isExaminationValid = true
      @examinationObject = list[0]
      console.log 'EXAMINATION: ', @examinationObject
      @addedExaminationList = list[0].data.examinationValueList
      @push 'collectiveRecords', { collection: 'visit-examination', data: list}
      return true
    else
      @_notifyInvalidExamination()
      return false


  _loadChildHistory: (childHistoryIdentifier)->
    list = app.db.find 'visit-child-history', ({serial})-> serial is childHistoryIdentifier
    if list.length is 1
      @isChildHistoryValid = true
      @childHistoryObject = list[0]
      @addedChildHistoryList = list[0].data.examinationValueList
      @push 'collectiveRecords', { collection: 'visit-child-history', data: list}
      return true
    else
      @_notifyInvalidChildHistory()
      return false

  _notifyInvalidChildHistory: ->
    @isChildHistoryValid = false
    @domHost.showModalDialog 'Invalid Child History Provided'
  

  _loadBirthHistory: (birthHistoryIdentifier)->
    list = app.db.find 'visit-birth-history', ({serial})-> serial is birthHistoryIdentifier
    if list.length is 1
      @isBirthHistoryValid = true
      @birthHistoryObject = list[0]
      @addedBirthHistoryList = list[0].data.examinationValueList
      @push 'collectiveRecords', { collection: 'visit-birth-history', data: list}
      return true
    else
      @_notifyInvalidBirthHistory()
      return false

  _notifyInvalidBirthHistory: ->
    @isBirthHistoryValid = false
    @domHost.showModalDialog 'Invalid Birth History Provided'
  

  


  ## Load Test Advised Data



  _pritifyVitalData: (masterVitalObject)->

    if masterVitalObject.vitalType is 'Blood Pressure'
      return masterVitalObject.vitalObject.systolic + "/" + masterVitalObject.vitalObject.diastolic

    if masterVitalObject.vitalType is 'Heart Rate'
      return masterVitalObject.vitalObject.bpm + " " + masterVitalObject.vitalObject.unit

    if masterVitalObject.vitalType is 'BMI'

      if masterVitalObject.vitalObject.heightUnit is "ft/inch"
        heightValue = masterVitalObject.vitalObject.heightInFt + "'" + masterVitalObject.vitalObject.heightInInch + "'' " + masterVitalObject.vitalObject.heightUnit
      else
        heightValue = masterVitalObject.vitalObject.height + " " + masterVitalObject.vitalObject.heightUnit

      weightValue = masterVitalObject.vitalObject.weight + masterVitalObject.vitalObject.weightUnit


      return masterVitalObject.vitalObject.calculatedBMI + ", " + "Height: " + heightValue + ", " + "Weight: " + weightValue

    if masterVitalObject.vitalType is 'Respirtory Rate'
      return masterVitalObject.vitalObject.respiratoryRate + masterVitalObject.vitalObject.unit

    if masterVitalObject.vitalType is 'SpO2'
      return masterVitalObject.vitalObject.spO2Percentage + masterVitalObject.vitalObject.unit

    if masterVitalObject.vitalType is 'Temperature'
      return masterVitalObject.vitalObject.temperature + masterVitalObject.vitalObject.unit



  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  _notifyInvalidVisit: ->
    @isVisitValid = false
    @domHost.showModalDialog 'Invalid Visit Provided'

  _loadVisit: (visitIdentifier)->
    console.log 'visitIdentifier', visitIdentifier
    
    @visitSerialIdentifier = visitIdentifier
    data = {
      apiKey: @user.apiKey
      visitSerial : visitIdentifier
    }
    @callApi '/bdemr-agent-view-user-details', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
      
        @details=response.data
        @patient=@details[0]
        console.log 'details',@details[0].serial
        @_loadPrescriptionInfo @patient.prescriptionSerial
        @_loadSuggestedData()
        
       

  _loadPrescriptionInfo:(prescriptionSerial)-> 
    data = {
      apiKey: @user.apiKey
      prescriptionSerial : prescriptionSerial
      visitSerial : @visitSerialIdentifier
    }
    @callApi '/bdemr-prescription-details-on-agent', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
      
        @prescriptionList = response.data
        console.log 'prescriptiondetails',@prescriptionList

  _loadSuggestedData:()-> 
    data = {
      apiKey: @user.apiKey
      visitSerial : @visitSerialIdentifier
    }
    this.domHost.toggleModalLoader 'Please Wait'
    @callApi '/bdemr-get-doctor-visit-suggestion', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
      
        @suggestedData = response.data
        console.log 'suggestedData',@suggestedData
        this.domHost.toggleModalLoader()
 

  
  _loadVitalsForVisit: (vitalIdentifier, vitalType)->

    if vitalType is 'Blood Pressure'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-blood-pressure'
      @isBPAdded = true

    else if vitalType is 'Heart Rate'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-pulse-rate'
      @isHRAdded = true

    else if vitalType is 'BMI'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-bmi'
      @isBMIAdded = true

    else if vitalType is 'Respirtory Rate'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-respiratory-rate'
      @isRRAdded = true

    else if vitalType is 'Spo2'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-spo2'
      @isSpO2Added = true

    else if vitalType is 'Temperature'
      @loadIdentifiedVitalData vitalIdentifier, vitalType, 'patient-vitals-temperature'
      @isTempAdded = true
  
  loadIdentifiedVitalData: (vitalIdentifier, vitalType, collectionName) ->
    list = app.db.find collectionName, ({serial})=> serial is vitalIdentifier

    if list.length is 1
      vitalData = list[0]
      @push 'collectiveRecords', { collection: collectionName, data: list}
      console.log vitalType, ': ', vitalData
      @_addToVitalList vitalData, vitalType
      return true
    else
      return false

  _addToVitalList: (object, type)->
    lib.util.delay 5, ()=>

      @push 'addedVitalList', {
        vitalType: type
        vitalObject: object
      }

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')



  _loadVisitPrescription: (prescriptionSerial)->
    list = app.db.find 'visit-prescription', ({serial})-> serial is prescriptionSerial
    if list.length is 1
      @isPrescriptionValid = true
      @isFullVisitValid = true
      @prescription = list[0]
      @push 'collectiveRecords', { collection: 'visit-prescription', data: list}
      @_listPrescribedMedications @prescription.serial
      # console.log "PrescriptionObj:",  @prescription
      return true
    else
      @isPrescriptionValid = false
      return false



  _loadVisitNote: (doctorNotesSerialIdentifier)->

    list = app.db.find 'visit-note', ({serial})-> serial is doctorNotesSerialIdentifier
    if list.length is 1
      @isNoteValid = true
      @isFullVisitValid = true
      @doctorNotes = list[0]
      @push 'collectiveRecords', { collection: 'visit-note', data: list}
      console.log 'NOTES: ', @doctorNotes
      return true
    else
      @isNoteValid = false
      return false

  _loadVisitReferralDoctorInfo: (referralDoctorSerialIdentifier)->
    list = app.db.find 'visit-referral-doctor-info', ({serial})-> serial is referralDoctorSerialIdentifier
    if list.length is 1
      @isFullVisitValid = true
      @referralDoctor = list[0]
      console.log 'Referral Doctors: ', @referralDoctor
      @push 'collectiveRecords', { collection: 'visit-referral-doctor-info', data: list}
      
      return true
    else
      return false

  _loadVisitReferralOrganizationInfo: (referralOrganizationSerialIdentifier)->
    list = app.db.find 'visit-referral-organization-info', ({serial})-> serial is referralOrganizationSerialIdentifier
    if list.length is 1
      @isFullVisitValid = true
      @referralOrganization = list[0]
      console.log 'Referral Organization: ', @referralOrganization
      @push 'collectiveRecords', { collection: 'visit-referral-organization-info', data: list}
      return true
    else
      return false

  _loadNextVisit: (nextVisitSerial)->
    list = app.db.find 'visit-next-visit', ({serial})-> serial is nextVisitSerial

    if list.length is 1
      @isNextVisitValid = true
      @isFullVisitValid = true
      @nextVisit = list[0]
      console.log "NEXT VISIT: ", @nextVisit
      @push 'collectiveRecords', { collection: 'visit-next-visit', data: list}
      return true
    else
      @isNextVisitValid = false
      return false


  ## VIEW :: HistoryAndPhysical - start
  _getRecord: (recordIdentifier, desiredRecordType)->
    list = app.db.find desiredRecordType, ({serial})-> serial is recordIdentifier
    if list.length is 1
      return list[0]
    else
      return null

  ## NOTE - PRINT ======================================================================================
  # The code below is unavoidably messy looking due to the various requirements in the data 
  # definition. If the namespace is not polluted then we will not have any serious consequences
  # when it comes to performance.

  generateHtmlContent: (def, data)->
    html = @handle_type def, data.data
    html = @filterHtmlContent html
    return html

  filterHtmlContent: (html)->
    html = html.replace /@VALUE@/g, ''
    return html

  printOutStyleSheet: ->
    """
    <style>
      
      .default-category {
        /* font-size: 20px; 
        font-weight: bold; */
        text-align: center; 
      }
      .default-collection {
        /* font-size: 16px; 
        font-weight: bold; */
      }
      .default-group {
        /* text-decoration: overline; */
      }
      .default-card {
        /* text-decoration: underline; */
      }
      span {
        font-size: 14px;
      }
      .unprocessed {
        color: red;
      }
    </style>
    """

  handle_children: (def, data)->
    html = ''
    # console.log data
    if 'childMap' of data and 'childList' of def and def.childList isnt null
      for child, childIndex in def.childList
        if child.key of data.childMap
          childHtml = @handle_type child, data.childMap[child.key]
          if childHtml and not (childHtml in [ ';', ':;', ': ;' ])
            childHtml = @sanitizeOutput childHtml
            html += childHtml
    else
      console.log 'end-case'
    return html

  handle_type: (def, data)->
    # console.log def.key, @listPrintDirectives def
    def.print = {} unless 'print' of def
    if def.type is 'systemRoot'
      @flattenStyle def
      return @type_systemRoot def, data
    else if def.type is 'category'
      def.print.boldLabel = true unless 'boldLabel' of def.print
      def.print.fontSize = 18 unless 'fontSize' of def.print
      @flattenStyle def
      return @type_category def, data
    else if def.type is 'collection'
      def.print.boldLabel = true unless 'boldLabel' of def.print
      def.print.fontSize = 16 unless 'fontSize' of def.print
      @flattenStyle def
      return @type_collection def, data
    else if def.type is 'group'
      def.print.passThrough = true unless 'passThrough' of def.print
      def.print.fontSize = 14 unless 'fontSize' of def.print
      @flattenStyle def
      return @type_group def, data
    else if def.type is 'card'
      def.print.boldLabel = true unless 'boldLabel' of def.print
      def.print.fontSize = 14 unless 'fontSize' of def.print
      @flattenStyle def
      return @type_card def, data
    else if def.type is 'checkbox'
      @flattenStyle def
      return @type_checkbox def, data
    else if def.type is 'toggleableContainer'
      @flattenStyle def
      return @type_toggleableContainer def, data
    else if def.type is 'label'
      @flattenStyle def
      return @type_label def, data
    else if def.type is 'autocomplete'
      if 'selectionType' of def and def.selectionType is 'label'
        def.print.separatorString = ", " unless 'separatorString' of def.print
      @flattenStyle def
      return @type_autocomplete def, data
    else if def.type is 'container'
      @flattenStyle def
      return @type_container def, data
    else if def.type is 'checkList'
      def.print.separatorString = ", " unless 'separatorString' of def.print
      @flattenStyle def
      return @type_checkList def, data
    else if def.type is 'radioList'
      def.print.separatorString = ", " unless 'separatorString' of def.print
      @flattenStyle def
      return @type_radioList def, data
    else if def.type is 'input'
      @flattenStyle def
      return @type_input def, data
    else if def.type is 'singleSelectDropdown'
      @flattenStyle def
      return @type_singleSelectDropdown def, data
    else if def.type is 'incrementalCounter'
      @flattenStyle def
      return @type_incrementalCounter def, data
    else
      return '<span class="unprocessed">UNPROCESSED ' + def.type + ' - ' + def.key + '</span>'


  flattenStyle: (def)->
    if 'passThrough' of def.print
      unless 'hideLabel' of def.print
        def.print.hideLabel = true
      unless 'noColonAfterThis' of def.print
        def.print.noColonAfterThis = true
      unless 'noSemicolonAfterThis' of def.print
        def.print.noSemicolonAfterThis = false
      # delete def.print['passThrough']
    if 'newLineBeforeThis' of def.print
      if typeof def.print.newLineBeforeThis is 'boolean'
        def.print.newLineBeforeThis = (if def.print.newLineBeforeThis is true then 1 else 0)
      else
        def.print.newLineBeforeThis = parseInt def.print.newLineBeforeThis
    if 'newLineAfterThis' of def.print
      if typeof def.print.newLineAfterThis is 'boolean'
        def.print.newLineAfterThis = (if def.print.newLineAfterThis is true then 1 else 0)
      else
        def.print.newLineAfterThis = parseInt def.print.newLineAfterThis
    if 'newLineAfterThisAndChildren' of def.print
      if typeof def.print.newLineAfterThisAndChildren is 'boolean'
        def.print.newLineAfterThisAndChildren = (if def.print.newLineAfterThisAndChildren is true then 1 else 0)
      else
        def.print.newLineAfterThisAndChildren = parseInt def.print.newLineAfterThisAndChildren
    if 'newLineAfterEachValue' of def.print
      if typeof def.print.newLineAfterEachValue is 'boolean'
        def.print.newLineAfterEachValue = (if def.print.newLineAfterEachValue is true then 1 else 0)
      else
        def.print.newLineAfterEachValue = parseInt def.print.newLineAfterEachValue

  sanitizeOutput: (content)->
    for i in [0..2]
      content = content.replace /\;;/g, ';'
      content = content.replace /\;;/g, ';'
      content = content.replace /\; ;/g, ';'
      content = content.replace /\: ;/g, ';'
      content = content.replace /\: :/g, ':'
      content = content.replace /\, ;/g, ';'
      content = content.replace /\; ,/g, ';'
      content = content.replace /\,;/g, ';'

      content = content.replace /<\/span style=""><\/span>/g, ''
      content = content.replace /<\/span>;<\/span>/g, '<\/span><\/span>'
      content = content.replace /<\/span>; <\/span>/g, '<\/span><\/span>'
      content = content.replace /<\/span> ,<\/span>/g, '<\/span><\/span>'

    return content


  ###
    REGION - VARIOUS TYPES
  ###

  _computeElementStyle: (def)->
    style = ''
    if def.print.fontSize
      style += "font-size: #{def.print.fontSize}px;"
    if def.print.hide
      style += "display: none;"
    return style

  _computeTitleOrLabelStyle: (def)->
    style = ''
    if def.print.boldLabel
      style += "font-weight: bold;"
    return style

  type_systemRoot: (def, data)->
    content = (@handle_children def, data)
    return @printOutStyleSheet() + content

  type_category: (def, data)->
    content = @handle_children def, data
    return '' if content.length is 0
    style = @_computeTitleOrLabelStyle def
    title = """<span style="#{style}">#{def.label}</span>"""
    style = @_computeElementStyle def
    html = """<div class="default-category" style="#{style}">#{title}</div>#{content}"""
    return html

  type_collection: (def, data)->
    return '' if (Object.keys data.childMap).length is 0
    if def.defaultGroup and not data.isDefaultGroupDismissed
      content = @handle_type def.defaultGroup, data.childMap[def.defaultGroup.key]
    else
      content = @handle_children def, data
    style = @_computeTitleOrLabelStyle def
    title = """<br><span style="#{style}">#{def.label}</span><br>"""
    style = @_computeElementStyle def
    html = """<span class="default-collection" style="#{style}">#{title}</span>: #{content}<br>"""
    return html

  type_group: (def, data)->
    content = @handle_children def, data
    style = @_computeTitleOrLabelStyle def
    title = """<span style="#{style}">#{def.label}</span>"""
    if def.print.passThrough
      html = """#{content};"""
    else
      style = @_computeElementStyle def
      html = """<span class="default-group" style="#{style}">#{title}</span>: #{content}; """
    return html

  _makePrintableContent: (label, content, value, def, data)->
    return '' if content.length is 0 and value.length is 0 and def.type isnt 'label'
    print = def.print

    # console.log label, print

    labelHtml = ''
    contentHtml = ''
    valueHtml = ''

    return '' if print.hide

    if label.length > 0
      unless print.hideLabel
        style = ''
        if print.boldLabel
          style += 'font-weight: bold;'
        if print.fontSize
          style += "font-size:#{print.fontSize}px;"
        labelHtml = """<span style="#{style}">#{label}</span>"""

    if value.length > 0
      unless print.hideValue
        style = ''
        if print.boldValue
          style += 'font-weight: bold;'
        if print.fontSize
          style += "font-size:#{print.fontSize}px;"
        valueHtml = """<span style="#{style}">#{value}</span>"""    

    if content.length > 0
      unless print.hideChildren
        style = ''
        if print.boldChildren
          style += 'font-weight: bold;'
        contentHtml = """<span style="#{style}">#{content}</span>"""

    if (labelHtml + contentHtml + valueHtml).length is 0
      return ''

    if 'newLineBeforeThis' of print
      for i in [0...print.newLineBeforeThis]
        labelHtml = '<br>' + labelHtml

    if 'newLineAfterThis' of print
      for i in [0...print.newLineAfterThis]
        labelHtml = labelHtml + '<br>'

    colon = (if ('noColonAfterThis' of print and print.noColonAfterThis) or labelHtml.length is 0 then '' else ': ')
    semicolon = (if 'noSemicolonAfterThis' of print and print.noSemicolonAfterThis then '' else '; ')
    html = labelHtml + colon + contentHtml + valueHtml + semicolon

    if 'newLineAfterThisAndChildren' of print
      for i in [0...print.newLineAfterThisAndChildren]
        html = html + '<br>'

    return html


  type_card: (def, data)->
    content = (@handle_children def, data)
    label = def.label
    value = null
    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data
    
  type_checkbox: (def, data)->
    content = null
    label = null

    if data.isChecked
      value = def.label
    else
      value = ''

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_label: (def, data)->
    content = null
    label = data.label or def.label or def.defaultLabel
    value = null
    
    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_toggleableContainer: (def, data)->
    return '' unless data.isChecked

    content = @handle_children def, data
    label = def.label
    value = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_container: (def, data)->
    content = @handle_children def, data
    label = data.label or def.defaultLabel
    value = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_checkList: (def, data)->
    print = def.print

    stringList = []
    for item in data.checkedValueList
      stringList.push item

    separatorString = print.separatorString
    if 'newLineAfterEachValue' of print
      for i in [0...print.newLineAfterEachValue]
        separatorString += '<br>'

    value = stringList.join separatorString 

    label = null
    content = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_radioList: (def, data)->
    value = data.selectedValue
    label = null
    content = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_singleSelectDropdown: (def, data)->
    value = def.possibleValueList[data.selectedIndex]
    label = null
    content = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_input: (def, data)->
    content = data.value

    if def.unitDetails
      unit = def.unitDetails.unitList[data.selectedUnitIndex]
      # content += ' ' + unit.name

    value = content
    label = def.label
    content = null

    return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_autocomplete: (def, data)->
    print = def.print

    if def.selectionType is 'label'

      stringList = []
      for key, value of data.virtualChildMap
        title = key.split '_'
        title.pop()
        title.shift()
        title = title.join '_'
        stringList.push title

      separatorString = print.separatorString
      if 'newLineAfterEachValue' of print
        for i in [0...print.newLineAfterEachValue]
          separatorString += '<br>'

      value = stringList.join separatorString 

      label = def.label
      content = null

      return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

    else
      content = ''
      for key, value of data.virtualChildMap
        title = key.split '_'
        title.pop()
        title.shift()
        title = title.join '_'

        virtualContainer = 
          type: 'container'
          defaultLabel: title
          key: key
          childList: def.childListForEachContainer

        childContent = (@handle_type virtualContainer, value) + ', '
        content += childContent

      value = null
      label = def.label

      return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  type_incrementalCounter: (def, data)->
    content = ''
    for key, value of data.virtualChildMap
      title = key.replace 'item', ''
      serial = parseInt title

      virtualContainer = 
        type: 'container'
        defaultLabel: (try def.unit.singular catch ex then 'unit') + ' #' + (serial + 1)
        key: key
        childList: def.childListForEachContainer

      content += (@handle_type virtualContainer, value) + ';'

      value = null
      label = def.label
      return @_makePrintableContent (label or ''), (content or ''), (value or ''), def, data

  ###
    REGION - PRINT RELATED CHECKS
  ###

  should_boldLabel: (def)->
    'print' of def and 'boldLabel' of def.print and def.print.boldLabel

  should_passThrough: (def)->
    'print' of def and 'passThrough' of def.print and def.print.passThrough

  should_newLineBeforeThis: (def)->
    'print' of def and 'newLineBeforeThis' of def.print and def.print.newLineBeforeThis

  inject_passThrough_special_card: (def, data)->
    if def.key is def.label and def.key in [ "Details", 'Default' ]
      def.print = {} unless def.print
      def.print.passThrough = true

  inject_passThrough_special_group: (def, data)->
    if def.key is def.label and def.key in [ "List", 'Default' ]
      def.print = {} unless def.print
      def.print.passThrough = true

  __debug_print: (def, handledDirectiveList)->
    all = if 'print' of def then Object.keys(def.print) else []
    left = lib.array.minus all, handledDirectiveList
    if left.length > 0
      console.log 'UNHANDLED print directives', def, left

  printButtonPressed: (e)->
    @printPrescriptionOnly = false
    window.print()
        

  _getSettings: (cbfn) ->
    list = app.db.find 'settings', ({serial})=> serial is @generateSerialForSettings()
    @settings = list[0]

    console.log @settings
    cbfn()
  
    
  _getBrandNameOrGenericName: (medicine)->
    return medicine.brandName or medicine.genericName

  _extractMedicineDoseList: (doseValue)->
    return doseValue.split ';;'
  navigatedIn: ->


    @currentOrganization = @getCurrentOrganization()
    
          
    unless @currentOrganization
      @domHost.navigateToPage "#/select-organization"


    # Load User
    @_loadUser =>
      params = @domHost.getPageParams()
      @_loadVisit params['visit']
    if window.localStorage.getItem('doctorId')
      data = {
        apiKey: @user.apiKey
        userId: window.localStorage.getItem('doctorId')
        organizationId : window.localStorage.getItem('organizationId')
      }
      @callApi '/bdemr-get-organization-specific-user-settings', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
        
          @doctorOrganizationDetails=response.data
          
          console.log 'settings',@doctorOrganizationDetails


  navigatedOut: ->
  
    @prescriptionList=[]
    @patient=[]
    ## ------------------------------- History and physical - start

  checkForPrintPreviewType: ()->
    
    if @visit?.historyAndPhysicalRecordSerial
      return false
    if @visit?.identifiedSymptomsSerial
      return false
    if @visit?.identifiedPhysiotherapySerial
      return false
    else if @visit?.examinationSerial
      return false
    else if @visit?.childHistorySerial
      return false
    else if @visit?.birthHistorySerial
      return false
    else if @visit?.familyHistoryNotesSerial
      return false
    else if @visit?.vitalSerial.bp
      return false
    else if @visit?.vitalSerial.hr
      return false
    else if @visit?.vitalSerial.bmi
      return false
    else if @visit?.vitalSerial.rr
      return false
    else if @visit?.vitalSerial.spo2
      return false
    else if @visit?.vitalSerial.temp
      return false
    else if @visit?.advisedTestSerial
      return false
    else if @visit?.diagnosisSerial
      return false
    else if @visit?.provisionalDiagnosisSerial
      return false
    else if @visit?.differentialDiagnosisSerial
      return false
    else if @visit?.doctorNotesSerial
      return false
    else if @visit?.nextVisitSerial
      return false
    else
      return true


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()



  openVisitSettingsDialog: (e)->
    @$$('#dialogVisitSettings').toggle()


}
