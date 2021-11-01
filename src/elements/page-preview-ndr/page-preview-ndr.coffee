
Polymer {

  is: 'page-preview-ndr'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    abnormalityValue:
      type: String
      notify: true
      value: null

    visitTypeIndex:
      type: Number
      notify: true
      value:-> -1


    showPhysicalActivity:
      type: String
      notify: true
      value: 'no'

    showDietaryHistory:
      type: String
      notify: true
      value: 'no'

    showCookingOil:
      type: String
      notify: true
      value: 'no'

    showPhysicalActivity2:
      type: String
      notify: true
      value: 'no'

    showDietaryHistory2:
      type: String
      notify: true
      value: 'no'

    showCookingOil2:
      type: String
      notify: true
      value: 'no'


    showInsulin:
      type: String
      notify: true
      value: 'no'

    user:
      type: Object
      notify: true
      value: null

    isPatientValid: 
      type: Boolean
      notify: true
      value: false

    isRecordValid: 
      type: Boolean
      notify: true
      value: false


    patient:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: null

    ndr:
      type: Object
      notify: true
      value: null

    getPatientHeight:
      type: Number
      value: 0

    getPatientWeight:
      type: Number
      value: 0

    patientWaistValue:
      type: Number
      value: 0

    patientHipValue:
      type: Number
      value: 0

    sbpValue:
      type: String
      value: ''
    dbpValue:
      type: String
      value: ''

    hypertension:
      type: Object
      value: {}

    bmi:
      type: Object
      value: {}

    dmStatusList:
      type: Array
      value: -> ['<1 year/diabetes', '<1-5 year', '6-10 years', '11-15 years', '16-20 years', '>20 years']

    typeOfTreatmentList:
      type: Array
      value: ->
        [
          {
            label: 'Diet'
            value: 'Diet'
          }
          {
            label: 'Diet & OGLD'
            value: 'Diet & OGLD'
          }
          {
            label: 'Diet, OGLD & insulin'
            value: 'Diet, OGLD & insulin'
          }
          {
            label: 'Insulin only'
            value: 'Insulin only'
          }
          {
            label: 'Other'
            value: 'Other'
          }
        ]

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

    basalDrugList:
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
        ]

    bolusDrugList:
      type: Array
      value: ->
        [
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

        ]

    premixDrugList:
      type: Array
      value:
        [
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

    otherInsulinDrugList:
      type: Array
      value: -> ['Maxsuline N', 'Maxsuline 50/50', 'Maxsuline R', 'Maxsuline 30/70', 'Vibrenta', 'Glycet Mix', 'Ansulin N', 'Ansulin 50/50', 'Ansulin R', 'Ansulin 30/70', 'DIASULIN N', 'DIASULIN-50/50', 'DIASULIN-R', 'DIASULIN-30/70', 'GLARINE', 'ACILOG', 'ACILOG MIX', 'INSULET N', 'ISULET 50/50', 'INSULET-R', 'INSULET 30/70', 'INSULET GN', 'INSULET ASP', 'INSULET ASP MIX', 'INSUL N', 'INSUL-50/50', 'INSUL R', 'INSUL 30/70', 'INSUL GLARGINE', 'INSUL LISPRO', 'HUMULIN N', 'HUMULIN-R', 'HUMULIN 70/30', 'HUMALOG-MIX 25', 'HUMALOG-MIX-50', 'HUMALOG-KWIKPEN', 'INSUMAN-COMB', 'INSUMAN-BASAL', 'INSUMAN-RAPID', 'LANTUS', 'APIDRA', 'Actrapid FlexPen']

    waistHipRatio:
      type: Object
      value: {}
      notify: true

    ecgTypeList:
      type: Array
      value: -> ['RBBB', 'LBBB', 'LVH', 'MI']

    physicalActivityPreList:
      type: Array
      value: -> ['Aerobic dance', 'Walking', 'Running', 'Cycling', 'Treadmill', 'Stair climbing', 'Swimming', 'Jogging', 'Other', 'none']

    physicalActivityObj:
      type: Object
      value: -> {
        name: null
        duration: null
        unit: 'min/day'
      }

    physicalActivityObj2:
      type: Object
      value: -> {
        name: null
        duration: null
        unit: 'min/day'
      }

    foodItemPreList:
      type: Array
      value: -> ['Rice', 'Ruti', 'Chapati', 'Fish', 'Meat', 'Green Vegetable', 'Fruits', 'Soft drinks', 'Table Salt', 'Sweets', 'Fast Foods', 'Ghee/butter', 'Hotel Food']

    customTest:
      type: Object
      value: {}

    customExamination:
      type: Object
      value: {}

    customComplication:
      type: String
      value: null

    otherFamilyHistoryDisease:
      type: Object
      value: ->
        {
          disease: ''
          value: 'yes'
        }

    otherAddiction:
      type: Object
      value: ->
        {
          type: ''
          isYes: 'yes'
          amount: ''
        }

    historyDisease:
      type: Object
      value: ->
        {
          disease: ''
          value: 'yes'
        }

    otherTypeOfCookingOil:
      type: Object
      value: ->
        {
          type: ''
          isYes: 'yes'
          amount: ''
          unit: 'Litres'
          duration: 'Month'
        }

    otherTypeOfCookingOil2:
      type: Object
      value: ->
        {
          type: ''
          isYes: 'yes'
          amount: ''
          unit: 'Litres'
          duration: 'Month'
        }

    otherDietItem:
      type: Object
      value: ->
        {
          type: ''
          consumeAmount: [
            {
              time: 'daily'
              value: null
              unit: ''
            }
            {
              time: 'weekly'
              value: null
              unit: ''
            }
            {
              time: 'monthly'
              value: null
              unit: ''
            }
          ]
        }

    otherDietItem2:
      type: Object
      value: ->
        {
          type: ''
          consumeAmount: [
            {
              time: 'daily'
              value: null
              unit: ''
            }
            {
              time: 'weekly'
              value: null
              unit: ''
            }
            {
              time: 'monthly'
              value: null
              unit: ''
            }
          ]
        }

    antiHTNList:
      type: Array
      value: -> ['BB (Beta Blocker)', 'CCB (Calcium Channel Blocker)', 'ACE-1 (Angiotensin-converting Enzyme Inhibitors)', 'ARB (Angiotensis Receptor Blocker', 'α - Blocker', 'Diuretics', '2 Drugs', '3 Drugs', 'Other']

    antiLipidsList:
      type: Array
      value: -> ['Statin', 'Fibrate', 'Ezetimibe', 'Others']

    visitTypeList:
      type: Array
      value: -> ['Newly Diagnosed', '≤1 year of Diagnosis', '1 to 5 years of Diagnosis', '5 to 10 years of Diagnosis', '10 to 15 years of Diagnosis', '15 to 20 years of Diagnosis', '20 and above', 'Visit 1', 'Visit 2', 'Visit 3']

    laboratoryTestList:
      type: Array
      value: []

    complicationList:
      type: Array
      value: []

  _makeComplicationList: (cbfn)->
    @complicationList = [
      {
        name: 'Hypogycemia'
        isSelected: false
        serial: null
      }
      {
        name: 'DKA'
        isSelected: false
        serial: null
      }
      {
        name: 'HHNS'
        isSelected: false
        serial: null
      }
      {
        name: 'Neuropathy'
        isSelected: false
        serial: null
      }
      {
        name: 'Nephropathy'
        isSelected: false
        serial: null
      }
      {
        name: 'Retinopathy'
        isSelected: false
        serial: null
      }
      {
        name: 'Cerebrovascular'
        isSelected: false
        serial: null
      }
      
      {
        name: 'PVD'
        isSelected: false
        serial: null
      }
      {
        name: 'CVD'
        isSelected: false
        serial: null
      }
      {
        name: 'HTN'
        isSelected: false
        serial: null
      }
      {
        name: 'Dyslipidaemia'
        isSelected: false
        serial: null
      }
      {
        name: 'Gastro Complications'
        isSelected: false
        serial: null
      }
      {
        name: 'Others'
        isSelected: false
        serial: null
      }
    ]
    cbfn()

  _makeLaboratoryTestList: (cbfn)->
    @laboratoryTestList = [
      {
        name: 'HbA1c'
        value: null
        unit: '%'
        isSelected: ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "001"
      }
      {
        name: 'FPG'
        value: null
        unit: 'mmol'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "002"
      }
      {
        name: '2hPG'
        value: null
        unit: 'mmol'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "003"
      }
      {
        name: 'Post Meal'
        value: null
        unit: 'mmol'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "004"
      }
      {
        name: 'Urine Acetone'
        value: null
        unit: '+'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "005"
      }
      {
        name: 'Urine Albumin'
        value: null
        unit: ''
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "006"
      }
      {
        name: 'S. Creatinine'
        value: null
        unit: 'mg/dl'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "006"
      }
      {
        name: 'SGPT'
        value: null
        unit: 'Units per liter'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "007"
      }
      {
        name: 'HB'
        value: null
        unit: '%'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "008"
      }
      {
        name: 'ECG'
        value: null
        unit: ''
        type: ''
        isSelected:  ''
        costType: 'free'
        inputType: 'mixed'
        isCustomTest: false
        serial: null
        ecgAbnormalityList: []
        testId: "009"
      }
      {
        name: 'T.Chol'
        value: null
        unit: 'mg/dl'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "010"
      }
      {
        name: 'LDL-C'
        value: null
        unit: 'mg/dl'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "011"
      }
      {
        name: 'HDL-C'
        value: null
        unit: 'mg/dl'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "012"
      }
      {
        name: 'Triglycerides'
        value: null
        unit: 'mg/dl'
        isSelected:  ''
        costType: 'free'
        inputType: 'number'
        isCustomTest: false
        serial: null
        testId: "013"
      }
    ]
    cbfn()

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

  _showComputedWestHipRatio: (waist, hip)->
    console.log waist, hip
    return waist / hip

  _returnSerial: (index)->
    index+1

  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false


  _loadUser:(cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
    cbfn()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()


  $findCreator: (creatorSerial)-> 'me'

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--

    return age

  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle

  
  loadNDRFromServer: (identifier, cbfn)->
    record = JSON.parse window.localStorage.getItem 'previewTempNDRRecord'
    if record
      @isRecordValid = true
      @ndr = record
    else
      @_notifyInvalidRecord()
  
  loadNdr: (identifier, cbfn)->
    list = app.db.find 'ndr-records', ({serial})-> serial is identifier
    if list.length is 1
      @isRecordValid = true
      @ndr = list[0]
    else
      @_notifyInvalidRecord()

    cbfn()



  _loadPatient: (patientIdentifier, cbfn)->
    params = @domHost.getPageParams()
    # if params['recordOnline']
    #   record = JSON.parse window.localStorage.getItem 'previewTempNDRRecord'
    #   if record
    #     patient = record.patientInfo
    #     patient.name = @$getFullName patient.name
    #     @patient = patient
    # else
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      patient = list[0]
      patient.name = @$getFullName patient.name
      @patient = patient
    else
      @_notifyInvalidPatient()
    

    cbfn()

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid/missing Patient!'

  _notifyInvalidRecord: ->
    @isRecordValid = false
    @domHost.showModalDialog 'Invalid/missing NDR Record!'


  onDietaryItemValue: (e)->
    el = @locateParentNode e.target, 'PAPER-INPUT'
    el.opened = false
    repeater = @$$ '#dietary-list-repeater'
    index = repeater.indexForElement el
    memberIndex = e.model.index

    dailyIndex = 0
    weeklyIndex = 1
    monthlyIndex = 2

    if memberIndex is 0
      dailyValue = @ndr.data.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{weeklyIndex}.value", parseInt((dailyValue * 7).toString())
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 1
      weeklyValue = @ndr.data.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      dailyValue = weeklyValue / 7
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{dailyIndex}.value", parseInt(dailyValue.toString())
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 2
      monthlyValue = @ndr.data.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      dailyValue = monthlyValue / 30
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{dailyIndex}.value", 0
      @set "ndr.data.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{weeklyIndex}.value", 0


    # @ndr.data.medicalInfo.dietaryHistoryList[index].consumeAmount[weeklyIndex].value = (value * 7).toString()

    
    console.log 'list', @ndr.data.medicalInfo.dietaryHistoryList

  ## Dietary ------------------------------> end

  onDietaryItemValue2: (e)->
    el = @locateParentNode e.target, 'PAPER-INPUT'
    el.opened = false
    repeater = @$$ '#dietary-list-repeater-2'
    index = repeater.indexForElement el
    memberIndex = e.model.index

    dailyIndex = 0
    weeklyIndex = 1
    monthlyIndex = 2

    if memberIndex is 0
      dailyValue = @ndr.data.medicalInfo.dietaryHistoryList2[index].consumeAmount[memberIndex].value
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{weeklyIndex}.value", parseInt((dailyValue * 7).toString())
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 1
      weeklyValue = @ndr.data.medicalInfo.dietaryHistoryList2[index].consumeAmount[memberIndex].value
      dailyValue = weeklyValue / 7
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{dailyIndex}.value", parseInt(dailyValue.toString())
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 2
      monthlyValue = @ndr.data.medicalInfo.dietaryHistoryList2[index].consumeAmount[memberIndex].value
      dailyValue = monthlyValue / 30
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{dailyIndex}.value", 0
      @set "ndr.data.medicalInfo.dietaryHistoryList2.#{index}.consumeAmount.#{weeklyIndex}.value", 0


    # @ndr.data.medicalInfo.dietaryHistoryList[index].consumeAmount[weeklyIndex].value = (value * 7).toString()

    
    console.log 'list', @ndr.data.medicalInfo.dietaryHistoryList2

  

  ## Dietary ------------------------------> end

  ## Clinical ------------------------------> start
  calcWaistHipRatio: (waist, hip)->
    waist = parseFloat waist
    hip = parseFloat hip
    console.log 'waist', waist
    console.log 'hip', hip

    if hip > 0
      console.log 'here 1'
      ratio = waist / hip
      ratio = Math.round(ratio * 100) / 100

      if ratio < 0.8
        lib.util.delay 100, ()=>
          @set 'waistHipRatio.value', ratio
          @set 'waistHipRatio.comment', 'YOU ARE HEALTHY'
          @set 'waistHipRatio.class', 'normal'

      else
        lib.util.delay 100, ()=>
          @set 'waistHipRatio.value', ratio
          @set 'waistHipRatio.comment', 'YOU ARE OBESE'
          @set 'waistHipRatio.class', 'warning'

    else if waist >= 80
      console.log 'here 2'
      lib.util.delay 100, ()=>
        @set 'waistHipRatio.value', ''
        @set 'waistHipRatio.comment', 'YOU ARE C.OBESE'
        @set 'waistHipRatio.class', 'warning'

    else if waist < 80
      console.log 'here 3'
      lib.util.delay 100, ()=>
        @set 'waistHipRatio.value', ''
        @set 'waistHipRatio.comment', 'YOU ARE HEALTHY'
        @set 'waistHipRatio.class', 'normal'

  calcBMI: (height, weight)->
    @bmi.height = height
    @bmi.weight = weight
    results = weight / (height * height)
    @set 'bmi.calculatedBMI', Math.round(results * 100) / 100
    console.log 'bmi', @bmi
    if @bmi.calculatedBMI < 18.50
      @set 'bmi.classification', 'Underweight'
      @set 'bmi.class', 'warning'
    else if (18.5 <= @bmi.calculatedBMI < 23)
      @set 'bmi.classification', 'Normal weight'
      @set 'bmi.class', 'normal'
    else if (23 <= @bmi.calculatedBMI <= 25)
      @set 'bmi.classification', 'Overweight'
      @set 'bmi.class', 'warning'
    else if (25 <= @bmi.calculatedBMI < 30)
      @set 'bmi.classification', 'Class I obesity'
      @set 'bmi.class', 'danger'
    else if (30 <= @bmi.calculatedBMI < 35)
      @set 'bmi.classification', 'Class II obesity'
      @set 'bmi.class', 'danger'
    else if @bmi.calculatedBMI >= 35
      @set 'bmi.classification', 'Class III obesity'
      @set 'bmi.class', 'danger'

  calcHypertension: (sbp, dbp)->

    console.log 'before', sbp, dbp
    sbp = parseInt sbp
    dbp = parseInt dbp

    console.log 'after', sbp, dbp

    if (sbp <= dbp)
      @set 'hypertension.type', 'Invalid'
      @set 'hypertension.comment', 'SBP Value cannot be equal or lower than DBP value'
      @set 'hypertension.class', 'danger'
      return

    else if (sbp <= 120) and (dbp <= 80)
      console.log 'case 1'
      @set 'hypertension.type', 'BP normal'
      @set 'hypertension.comment', 'Normal'
      @set 'hypertension.class', 'normal'
      return

    else if ((120 < sbp <= 139) or (80 < dbp <= 89))
      console.log 'case 2'
      @set 'hypertension.type', 'Prehypertension'
      @set 'hypertension.comment', 'Need lifestyle change'
      @set 'hypertension.class', 'warning'
      return

    else if ((140 <= sbp <= 159) or (90 <= dbp <= 99))
      console.log 'case 3'
      @set 'hypertension.type', 'Stage 1 hypertension'
      @set 'hypertension.comment', 'Need lifestyle change and Need physician consultation'
      @set 'hypertension.class', 'danger'
      return

    else if ((sbp >= 160) or (dbp >= 100))
      console.log 'case 4'
      @set 'hypertension.type', 'Stage 2 hypertension'
      @set 'hypertension.comment', 'Need lifestyle change and Need immediate physician consultation'
      @set 'hypertension.class', 'danger'
      return

  computeClinicalData2: ()->
    list = @ndr.data.clinicalInfoList
    for item in list
      if item.type is 'height'
        @getPatientHeight = item.value / 100
      else if item.type is 'weight'
        @getPatientWeight = item.value
      else if item.type is 'waist'
        @patientWaistValue = item.value
      else if item.type is 'hip'
        @patientHipValue = item.value
      else if item.type is 'sbp'
        @sbpValue = item.value
      else if item.type is 'dbp'
        @dbpValue = item.value

      @calcHypertension @sbpValue, @dbpValue
      @calcWaistHipRatio @patientWaistValue, @patientHipValue
      @calcBMI @getPatientHeight, @getPatientWeight

  computeClinicalData: (e)->
    
    index = e.model.index
    item = @ndr.data.clinicalInfoList[index]
    if item.type is 'height'
      @getPatientHeight = item.value / 100
    else if item.type is 'weight'
      @getPatientWeight = item.value
    else if item.type is 'waist'
      @patientWaistValue = item.value
    else if item.type is 'hip'
      @patientHipValue = item.value
    else if item.type is 'sbp'
      @sbpValue = item.value
    else if item.type is 'dbp'
      @dbpValue = item.value

    @calcHypertension @sbpValue, @dbpValue
    @calcWaistHipRatio @patientWaistValue, @patientHipValue
    @calcBMI @getPatientHeight, @getPatientWeight


  ## Clinical ------------------------------> end


  saveButtonPressed: ()->
    unless @ndr.data.visitType
      @domHost.showToast 'Please Fill Up Visit type First!'
      return

    if @ndr.serial is null
      @ndr.serial = @generateSerialForNdrRecord()

    console.log @ndr

    @saveNdrData @ndr, =>
      @saveNdrLaboratoryTestList =>
        @saveNdrComplicationList =>
          @saveClinialData =>
            @domHost.showToast 'Record Saved!'
            @arrowBackButtonPressed()

  saveNdrData: (data, cbfn)->
    data.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'ndr-records', data, ({serial})=> data.serial is serial
    cbfn()

  # Laboratory Data a.k.a "other test" -------> start

  loadBmi: (ndrIdentifier)->
    list = app.db.find 'patient-vitals-bmi', ({visitSerial})=> visitSerial is ndrIdentifier
    if list.length is 1
      bmi = list[0]
      height = bmi.data.height
      weight = bmi.data.weight
      @calcBMI height, weight
      @set 'ndr.data.clinicalInfoList.0', height
      @set 'ndr.data.clinicalInfoList.1', weight
    else
      console.log "Duplicate record detected!"

  loadBp: (ndrIdentifier)->
    list = app.db.find 'patient-vitals-blood-pressure', ({visitSerial})=> visitSerial is ndrIdentifier
    if list.length is 1
      bp = list[0]
      sbp = bp.data.systolic
      dbp = bp.data.diastolic
      @calcHypertension sbp, dbp
      @set 'ndr.data.clinicalInfoList.4', sbp
      @set 'ndr.data.clinicalInfoList.5', dbp
    else
      console.log "Duplicate record detected!"


  loadAndFilterNdrLaboratoryTestList: (ndrIdentifier) ->
    @_makeLaboratoryTestList =>
    
      otherTestList = app.db.find 'patient-test-other', ({visitSerial})=> visitSerial is ndrIdentifier
      bloodSugarList = app.db.find 'patient-test-blood-sugar', ({visitSerial})=> visitSerial is ndrIdentifier
      # list = otherTestList.concat bloodSugarList
      console.log 'NDR Laboratory Investigation Data (Loaded from Other Test) -->', otherTestList
      console.log 'NDR Laboratory Investigation Data (Loaded from Blood Sugar) -->', bloodSugarList

      if otherTestList.length > 0
        for item, index in otherTestList
          foundChildIndex = -1

          for child, childIndex in @laboratoryTestList
            console.log 'child', childIndex, child
            if child.testId is item.data.testId
              foundChildIndex = childIndex
              break

          if foundChildIndex > -1
            @set "laboratoryTestList.#{foundChildIndex}.value", item.data.result
            @set "laboratoryTestList.#{foundChildIndex}.serial", item.serial

          else
            @push "laboratoryTestList", {
              name: item.data.name
              value: item.data.result
              unit: item.data.unit
              isSelected: 'yes'
              costType: 'free'
              inputType: 'number'
              isCustomTest: true
              serial: item.serial
              testId: item.data.testId
            }


      if bloodSugarList.length > 0
        for item in bloodSugarList
          @checkAndPushBloodSugarAsLaboratoryData item

  checkAndPushBloodSugarAsLaboratoryData: (test)->
    list = @laboratoryTestList
    for item, index in list
      if test.serial
        if test.data.type is item.name
          @set "laboratoryTestList.#{index}.value", test.data.value
          @set "laboratoryTestList.#{index}.serial", test.serial
          return

  # Laboratory Data a.k.a "other test" -------> end

  # Complication & Assosiate Complication Data a.k.a "Confirm Diagnosis" -------> start
 
  loadAndFilterNdrComplicationList: (ndrIdentifier) ->
    @_makeComplicationList =>
      list = app.db.find 'visit-diagnosis', ({visitSerial})=> visitSerial is ndrIdentifier

      if list.length > 0
        for item in list
          @formatDiagnosisDataToComplicationData item

  formatDiagnosisDataToComplicationData: (data)->
    list = @complicationList
    # console.log 'complicationList', @complicationList
    for item, index in list
      if data.serial
        if data.diagnosis is item.name
          @set "complicationList.#{index}.isSelected", true
          @set "complicationList.#{index}.serial", data.serial
          return
        else
          @push "complicationList", {
            name: data.diagnosis
            isSelected: true
            serial: data.serial
            isCustom: true
          }
          return

    console.log 'complicationList', @complicationList


  saveNdrComplicationList: (cbfn)->
    list = @complicationList
    for item in list
      if item.isSelected
        # for other test
        @_makeConfirmDiagnosis item, (test)=>
          @upsertConfirmDiagnosis test
      else
        @deleteConfirmDiagnosisDataIfAvaialble item.serial

    cbfn()

  filterAndSaveNdrAssosiateComplicationList: (cbfn)->
    list = @associateComplicationList
    for item in list
      if item.isSelected
        # for other test
        @_makeConfirmDiagnosis item, (test)=>
          @upsertConfirmDiagnosis test
      else
        @deleteConfirmDiagnosisDataIfAvaialble item.serial

    cbfn()

  deleteConfirmDiagnosisDataIfAvaialble: (diagnosisIdentifier)->
    if diagnosisIdentifier
      id = (app.db.find 'visit-diagnosis', ({serial})-> serial is diagnosisIdentifier)[0]._id
      app.db.remove 'visit-diagnosis', id
      return
    else
      return


  # Complication & Assosiate Complication Data a.k.a "Confirm Diagnosis" -------> end


  printButtonPressed: ()->
    window.print()

  editPatientBtnPressed: ()->
    @domHost.navigateToPage "#/patient-editor/patient:" + @patient.serial


  navigatedIn: ->

    params = @domHost.getPageParams()

    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"
      
    @_loadUser =>

      if params['patient']
        @_loadPatient params['patient'], =>
          if params['record'] is 'new'
            @_makeLaboratoryTestList =>
              @_makeComplicationList =>
                @isRecordValid = true

          else
            if params['recordOnline']
              @loadNDRFromServer params['record'], =>
                @loadAndFilterNdrLaboratoryTestList @ndr.serial
                @loadAndFilterNdrComplicationList @ndr.serial
                @computeClinicalData2()
            else
              @loadNdr params['record'], =>
                @loadAndFilterNdrLaboratoryTestList @ndr.serial
                @loadAndFilterNdrComplicationList @ndr.serial
                @computeClinicalData2()


  navigatedOut: ->
    @set 'ndr', {}
    @getPatientHeight = 0
    @calculatedBMI = 0
    @getPatientWeight = 0
    @patientWaistValue = 0
    @patientHipValue = 0
    @sbpValue = ''
    @dbpValue = ''
    @set 'hypertension', null
    @set 'bmi', {}
    
    
  goDashboard: ()->
    @domHost.navigateToPage '#/dashboard'

}
