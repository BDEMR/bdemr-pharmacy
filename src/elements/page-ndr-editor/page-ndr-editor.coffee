
Polymer {

  is: 'page-ndr-editor'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    symptomaticTypeList:
      type: Array
      notify: true
      value:-> [
        'Typical',
        'Atypical'
      ]
    
    selectedPage:
      type: Number
      notify: true
      value: 0

    abnormalityValue:
      type: String
      notify: true
      value: null

    EDIT_MODE_ON:
      type: Boolean
      notify: true
      value: false

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

    showInsulin2:
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
      value: -> ['less than 1 year', '1 to 5 year', '6 to 10 years', '11 to 15 years', '16 to 20 years', 'more than 20 years']

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
      value: -> ['Rice', 'Ruti/Chapati', 'Fish', 'Meat', 'Green Vegetable', 'Fruits', 'Soft drinks', 'Table Salt', 'Sweets', 'Fast Foods', 'Ghee/butter', 'Hotel Food']

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
      value: null

    otherAddiction:
      type: Object
      value: null

    historyDisease:
      type: Object
      value: ->
        {
          disease: ''
          value: 'yes'
        }

    otherTypeOfCookingOil:
      type: Object
      value: null

    otherTypeOfCookingOil2:
      type: Object
      value: null

    otherDietItem:
      type: Object
      value: null

    otherDietItem2:
      type: Object
      value: null

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
    # console.log waist, hip
    return waist / hip

  _returnSerial: (index)->
    index+1

  _isEmpty: (data)-> 
    if data is 0
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

  _makeNdr: ->
    @ndr =

      serial: null
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      createdByUserId: @user.idOnServer
      patientSerial: @patient.serial
      doctorName: @$getFullName @user.name
      doctorSpeciality: @getDoctorSpeciality()
      isAuthorized: false
      organizationId: @organization.idOnServer
      clientCollectionName: 'ndr-records'
      data:

        visitType: null
        visitDate: lib.datetime.mkDate lib.datetime.now()
        registeredCenter:
          name: null
          id: null

        symptomatic:
          isYes: null
          value: null

        diabeticsInfo:
          patientBookSerial: null
          duration: null
          typeOfDiabetics: null
          diabeticsDuration: null

        laboratoryTestList: []

        clinicalInfoList: [

          {
            serial: null
            type: 'height'
            name: 'Height'
            value: null
            unit: 'cm'
            inputType: 'number'
            isCustom: false
          }
          {
            serial: null
            type: 'weight'
            name: 'Weight'
            value: null
            unit: 'kg'
            inputType: 'number'
            isCustom: false
          }
          {
            serial: null
            type: 'waist'
            name: 'Waist'
            value: null
            unit: 'cm'
            inputType: 'number'
            isCustom: false
          }
          {
            serial: null
            type: 'hip'
            name: 'Hip'
            value: null
            unit: 'cm'
            inputType: 'number'
            isCustom: false
          }

          {
            serial: null
            type: 'sbp'
            name: 'SBP'
            value: null
            unit: 'mmHg'
            inputType: 'number'
            isCustom: false
          }
          {
            serial: null
            type: 'dbp'
            name: 'DBP'
            value: null
            unit: 'mmHg'
            inputType: 'number'
            isCustom: false
          }
        ]

        complicationList: [
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
        # associateComplicationList: [
        #   {
        #     name: 'HTN (Hypertension)'
        #     isSelected: false
        #     serial: null
        #   }
          
        #   {
        #     name: 'Gastro Complication'
        #     isSelected: false
        #     serial: null
        #   }
          
        #   {
        #     name: 'Lipid Disorder'
        #     isSelected: false
        #     serial: null
        #   }
        # ]

        physicalActivityList: []

        physicalActivityList2: []

        medicalInfo:
          havePrevDietaryHistory: 'no'
          haveDietaryHistory: 'no'

          havePrevCookingOil: 'no'
          haveCookingOil: 'no'

          havePrevPhysicalActivity: 'no'
          havePhysicalActivity: 'no'

          drugAddictionList: [
            {
              type: 'Cigarette/Bidi'
              isYes: ''
              amount: ''
            }
            {
              type: 'Tobacco'
              isYes: ''
              amount: ''
            }
            {
              type: 'Betal Leaf/Betal Nut (Shupari)'
              isYes: ''
              amount: ''
            }
            {
              type: 'Alcohol'
              isYes: ''
              amount: ''
            }
            {
              type: 'Others'
              isYes: ''
              amount: ''
            }
          ]

          dietaryHistoryList: []

          dietaryHistoryList2: []

          typeOfCookingOilList: [
            {
              type: 'Soyebean oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Mustard oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Palm oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Olive oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Rice bran oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Other'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
          ]

          typeOfCookingOilList2: [
            {
              type: 'Soyebean oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Mustard oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Palm oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Olive oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Rice bran oil'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
            {
              type: 'Other'
              isYes: ''
              amount: ''
              unit: 'Litres'
              duration: 'Month'
            }
          ]

          historyOfDeseaseList: [
            {
              diseaseName: 'Diabetes'
              value: ''
            }
            {
              diseaseName: 'Pregnancy diabetes'
              value: ''
            }
            {
              diseaseName: 'Hypertension'
              value: ''
            }
            {
              diseaseName: 'Heart disease'
              value: ''
            }
            {
              diseaseName: 'Asthma'
              value: ''
            }
            {
              diseaseName: 'Tuberculosis'
              value: ''
            }
            {
              diseaseName: 'Mental disorder'
              value: ''
            }
            {
              diseaseName: 'Abortion'
              value: ''
            }
            {
              diseaseName: 'Preeclampsia'
              value: ''
            }
            {
              diseaseName: 'Eclampsia'
              value: ''
            }
            {
              diseaseName: 'Still-Birth'
              value: ''
            }
            {
              diseaseName: 'Macrosomia (Large Baby >4kg)'
              value: ''
            }
            {
              diseaseName: 'LBW (Small Baby <2.5kg)'
              value: ''
            }
            {
              diseaseName: 'Pre-term ( less than 37 weeks )'
              value: ''
            }
            {
              diseaseName: 'IUD'
              value: ''
            }
          ]

          historyOfMedicationList: [
            {
              name: 'On Insulin'
              value: ''
              type: ''
              typeOfDevice: ''
              forVisitReasonIdList: []
            }
            {
              name: 'OADs'
              value: ''
              type: ''
              forVisitReasonIdList: ['002', '003', '005']
              
            }
            {
              name: 'Anti HTN'
              value: ''
              type: ''
              forVisitReasonIdList: []
            }
            {
              name: 'Anti lipids'
              value: ''
              type: ''
              forVisitReasonIdList: []
            }
            {
              name: 'Cardiac Medication'
              value: ''
              type: ''
              forVisitReasonIdList: []
            }
          ]

          familyHistoryList: [
            {
              disease: 'Diabetes'
              value: ''
            }
            {
              disease: 'Hypertension'
              value: ''
            }
            {
              disease: 'Coronary Artery Disease'
              value: ''
            }
            {
              disease: 'Cerebro-Vascular Disease'
              value: ''
            }
          ]

        
        ogld:
          ogldUsage: 'no'
          ogldDrugList: [
            {
              ogldDrugName: ''
              drugDosage: ''
            }
          ]

        ogld2:
          ogldUsage: 'no'
          ogldDrugList: [
            {
              ogldDrugName: ''
              drugDosage: ''
            }
          ]
        insulin:
          insulinUsage: 'no'
          insulinType: ''
          insulinTherapyList: [
            {
              therapyType: 'Basal'
              drugName: ''
              preListedDrugPath: 'basalDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Bolus'
              drugName: ''
              preListedDrugPath: 'bolusDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Premix'
              drugName: ''
              preListedDrugPath: 'premixDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Other'
              drugName: ''
              preListedDrugPath: 'otherInsulinDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
          ]

        otherMedicationList:  [
          {
            name: 'Anti HTN'
            id: 'antiHTN'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Anti lipids'
            id: 'antilipids'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Aspirin'
            id: 'aspirin'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Anti-obesity'
            id: 'antiobesity'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Others'
            id: 'others'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
        ]

        insulin2:
          insulinUsage: 'no'
          insulinType: ''
          insulinTherapyList: [
            {
              therapyType: 'Basal'
              drugName: ''
              preListedDrugPath: 'basalDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Bolus'
              drugName: ''
              preListedDrugPath: 'bolusDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Premix'
              drugName: ''
              preListedDrugPath: 'premixDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
            {
              therapyType: 'Other'
              drugName: ''
              preListedDrugPath: 'otherInsulinDrugList'
              dosageList: [
                {
                  time: 'Morning'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Noon'
                  value: ''
                  unit: 'unit'
                }
                {
                  time: 'Night'
                  value: ''
                  unit: 'unit'
                }
              ]
            }
          ]

        otherMedicationList2:  [
          {
            name: 'Anti HTN'
            id: 'antiHTN'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Anti lipids'
            id: 'antilipids'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Aspirin'
            id: 'aspirin'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Anti-obesity'
            id: 'antiobesity'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
          {
            name: 'Others'
            id: 'others'
            isYes: ''
            medicineList: [
              {
                name: ''
                dose: ''
                unit: ''
              }
            ]
          }
        ]

    pccMedicineBrandNameSourceDataList:
      type: Array
      value: -> []
        

  loadNdr: (identifier, cbfn)->
    list = app.db.find 'ndr-records', ({serial})-> serial is identifier
    if list.length is 1
      @isRecordValid = true
      @ndr = list[0]
      @set 'EDIT_MODE_ON', true
      console.log "NDR LOADED DATA ------>", @ndr
    else
      @_notifyInvalidRecord()
      @set 'EDIT_MODE_ON', false

    cbfn()



  _loadPatient: (patientIdentifier, cbfn)->
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


  # saveBPData: (clinicalInfoList)->
  #   bloodPressure =
  #     serial: null
  #     visitSerial: null
  #     createdByUserSerial: null
  #     createdByUserName: @user.name
  #     patientSerial: null
  #     createdDatetimeStamp: null
  #     lastModifiedDatetimeStamp: null
  #     lastSyncedDatetimeStamp: null
  #     data:
  #       systolic: ''
  #       diastolic: ''
  #       random: ''
  #       unit: 'mm Hg'
  #       flags:
  #         flagAsError: false

  #   for item in clinicalInfoList
  #     if item.type is 'sbp'
  #       bloodPressure.data.systolic = parseInt item.value
  #     else if item.type is 'dbp'
  #       bloodPressure.data.diastolic = parseInt item.value


  #   bloodPressure.serial = @generateSerialForVitals 'BP-REG'
  #   bloodPressure.lastModifiedDatetimeStamp = lib.datetime.now()
  #   bloodPressure.createdByUserSerial = @user.serial
  #   bloodPressure.patientSerial = @patient.serial
  #   bloodPressure.createdDatetimeStamp = lib.datetime.now()

  #   app.db.upsert 'patient-vitals-blood-pressure', bloodPressure, ({serial})=> bloodPressure.serial is serial

  # saveToOtherTest: (data)->
  #   otherTest =
  #     serial: @generateSerialForVitals 'OT'
  #     createdByUserSerial: @user.serial
  #     patientSerial: @patient.serial
  #     createdDatetimeStamp: lib.datetime.now()
  #     lastModifiedDatetimeStamp: lib.datetime.now()
  #     lastSyncedDatetimeStamp: 0
  #     data:
  #       date: lib.datetime.now()
  #       name: data.name
  #       institution: null
  #       result: data.value
  #       unit: data.unit
  #       attachmentSerialList: []

  #   app.db.upsert 'patient-test-other', otherTest, ({serial})=> otherTest.serial is serial

  # saveLabDataToOtherTest: (list)->
  #   for item in list
  #     if item.value
  #       @saveToOtherTest item  

  # savePatientClinicalData: (patient, cbfn)->
  #   @saveBPData patient.clinicalInfoList
  #   @saveLabDataToOtherTest patient.laboratoryTestList
  #   # @saveComplicationDataToDiagnosis patient.complicationList
  #   cbfn()

  ## Physical Activity -----------------------> start

  addPhysicalActivity: ()->
    unless @physicalActivityObj.name and @physicalActivityObj.duration
      @domHost.showToast 'Please Fill Up Name and Duration'
      return

    @push "ndr.data.physicalActivityList", @physicalActivityObj
    @makeNewPhysicalActivityObj()

  deletePhysicalActivity: (e)->
    index = e.model.index
    @splice "ndr.data.physicalActivityList", index, 1

  makeNewPhysicalActivityObj: ()->
    @physicalActivityObj =
      name: null
      duration: null
      unit: 'min/day'

  ## Physical Activity -----------------------> end


  ## Physical Activity2 -----------------------> start

  addPhysicalActivity2: ()->
    unless @physicalActivityObj2.name and @physicalActivityObj2.duration
      @domHost.showToast 'Please Fill Up Name and Duration'
      return

    @push "ndr.data.physicalActivityList2", @physicalActivityObj2
    @makeNewPhysicalActivityObj2()

  deletePhysicalActivity2: (e)->
    index = e.model.index
    @splice "ndr.data.physicalActivityList2", index, 1

  makeNewPhysicalActivityObj2: ()->
    @physicalActivityObj2 =
      name: null
      duration: null
      unit: 'min/day'

  ## Physical Activity2 -----------------------> end

  addCustomTest: ()->
    unless @customTest.name and @customTest.unit
      @domHost.showToast 'Test Name and Unit is Required!'
      return

    @push "laboratoryTestList", @customTest
    @_makeNewCustomTest()

  deleteCustomComplication: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#complication-list-repeater'
    index = repeater.indexForElement el
    @splice "ndr.data.complicationList", index, 1
  
  deleteCustomTest: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#lab-test-list-repeater'

    index = repeater.indexForElement el

    @splice "laboratoryTestList", index, 1

  _makeNewCustomTest: ()->
    @customTest =
      name: null
      value: null
      unit: null
      isSelected:  ''
      costType: 'free'
      inputType: 'number'
      isCustomTest: true
      serial: null





  addCustomExamination: ()->
    unless @customExamination.name and @customExamination.unit
      @domHost.showToast 'Examination Name and Unit is Required!'
      return

    @customExamination.type = @customExamination.name

    @push "ndr.data.clinicalInfoList", @customExamination
    @_makeNewExamination()

  deleteExamination: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#examination-test-list-repeater'

    index = repeater.indexForElement el

    @splice "ndr.data.clinicalInfoList", index, 1

  _makeNewExamination: ()->
    @customExamination =
      serial: null
      type: null
      name: null
      value: null
      unit: null
      inputType: 'number'
      isCustom: true
  

  deleteFamilyHistoryItem: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#family-history-list-repeater'

    index = repeater.indexForElement el
    @splice "ndr.data.medicalInfo.familyHistoryList", index, 1
  
  _makeFamilyHistoryObject:()->
    @otherFamilyHistoryDisease =
      disease: ''
      value: 'yes'
      isCustom: true


  addFamilyHistoryDisease: ()->
    @push "ndr.data.medicalInfo.familyHistoryList", @otherFamilyHistoryDisease
    @_makeFamilyHistoryObject()
  
  _makeOtherAddictionObject:()->
    @otherAddiction =
      type: ''
      isYes: 'yes'
      amount: ''
      isCustom: true
        
  addAddiction: ()->
    @push "ndr.data.medicalInfo.drugAddictionList", @otherAddiction
    @_makeOtherAddictionObject()
  
  deleteAddictionItem: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#addiction-list-repeater'

    index = repeater.indexForElement el
    @splice "ndr.data.medicalInfo.drugAddictionList", index, 1

  addCustomComplication:()->
    if @customComplication
      @push "ndr.data.complicationList", {
        name: @customComplication
        isSelected: true
        serial: null
        isCustom: true
      }
      @set 'customComplication', null
    else
      @domHost.showToast "Please type first!"

  addHistoryDisease: ()->
    @push "ndr.data.medicalInfo.historyOfDeseaseList", @historyDisease
    # @set 'historyDisease.diseaseName', ''
  

  _makeCookingOilObject: () ->
    @otherTypeOfCookingOil =
      type: ''
      isYes: 'yes'
      amount: ''
      unit: 'Litres'
      duration: 'Month'
      isCustom: true
    
    @otherTypeOfCookingOil2 =
      type: ''
      isYes: 'yes'
      amount: ''
      unit: 'Litres'
      duration: 'Month'
      isCustom: true

  addCookingOil: ()->
    @push "ndr.data.medicalInfo.typeOfCookingOilList", @otherTypeOfCookingOil
    @_makeCookingOilObject()

  addCookingOil2: ()->
    @push "ndr.data.medicalInfo.typeOfCookingOilList2", @otherTypeOfCookingOil2
    @_makeCookingOilObject()
  
  deletePrevCookingOilItem: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#prev-cooking-oil-list-repeater'

    index = repeater.indexForElement el
    @splice "ndr.data.medicalInfo.typeOfCookingOilList2", index, 1
  
  deleteCookingOilItem: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#cooking-oil-list-repeater'

    index = repeater.indexForElement el
    @splice "ndr.data.medicalInfo.typeOfCookingOilList", index, 1


  ## Dietary ------------------------------> start

  addDietItem: ()->
    if @otherDietItem.type
      @push "ndr.data.medicalInfo.dietaryHistoryList", @otherDietItem
      @_makeOtherDietItemObject()
    else
      @domHost.showToast 'Please Type An item first!'

  deleteDietItem: (e)->
    index = e.model.index
    @splice "ndr.data.medicalInfo.dietaryHistoryList", index, 1


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

    
    # console.log 'list', @ndr.data.medicalInfo.dietaryHistoryList

  ## Dietary ------------------------------> end

  ## Dietary ------------------------------> start
  addDietItem2: ()->
    if @otherDietItem2.type
      @push "ndr.data.medicalInfo.dietaryHistoryList2", @otherDietItem2
      @_makeOtherDietItemObject()
    else
      @domHost.showToast 'Please Type An item first!'

  deleteDietItem2: (e)->
    index = e.model.index
    @splice "ndr.data.medicalInfo.dietaryHistoryList2", index, 1


  onDietaryItemValue2: (e)->
    el = @locateParentNode e.target, 'PAPER-INPUT'
    el.opened = false
    repeater = @$$ '#dietary-list-repeater-2'
    index = repeater.indexForElement el
    memberIndex = e.model.index

    console.log index, memberIndex

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

    
    # console.log 'list', @ndr.data.medicalInfo.dietaryHistoryList2

  

  ## Dietary ------------------------------> end

  ## Clinical ------------------------------> start
  calcWaistHipRatio: (waist, hip)->
    waist = parseFloat waist
    hip = parseFloat hip
    # console.log 'waist', waist
    # console.log 'hip', hip

    if hip > 0
      # console.log 'here 1'
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
      # console.log 'here 2'
      lib.util.delay 100, ()=>
        @set 'waistHipRatio.value', ''
        @set 'waistHipRatio.comment', 'YOU ARE C.OBESE'
        @set 'waistHipRatio.class', 'warning'

    else if waist < 80
      # console.log 'here 3'
      lib.util.delay 100, ()=>
        @set 'waistHipRatio.value', ''
        @set 'waistHipRatio.comment', 'YOU ARE HEALTHY'
        @set 'waistHipRatio.class', 'normal'

  calcBMI: (height, weight)->
    @bmi.height = height
    @bmi.weight = weight
    results = weight / (height * height)
    @set 'bmi.calculatedBMI', Math.round(results * 100) / 100
    # console.log 'bmi', @bmi
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

    # console.log 'before', sbp, dbp
    sbp = parseInt sbp
    dbp = parseInt dbp

    # console.log 'after', sbp, dbp

    if (sbp <= dbp)
      @set 'hypertension.type', 'Invalid'
      @set 'hypertension.comment', 'SBP Value cannot be equal or lower than DBP value'
      @set 'hypertension.class', 'danger'
      return

    else if (sbp <= 120) and (dbp <= 80)
      # console.log 'case 1'
      @set 'hypertension.type', 'BP normal'
      @set 'hypertension.comment', 'Normal'
      @set 'hypertension.class', 'normal'
      return

    else if ((120 < sbp <= 139) or (80 < dbp <= 89))
      # console.log 'case 2'
      @set 'hypertension.type', 'Prehypertension'
      @set 'hypertension.comment', 'Need lifestyle change'
      @set 'hypertension.class', 'warning'
      return

    else if ((140 <= sbp <= 159) or (90 <= dbp <= 99))
      # console.log 'case 3'
      @set 'hypertension.type', 'Stage 1 hypertension'
      @set 'hypertension.comment', 'Need lifestyle change and Need physician consultation'
      @set 'hypertension.class', 'danger'
      return

    else if ((sbp >= 160) or (dbp >= 100))
      # console.log 'case 4'
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

  _makeBmi: (data, cbfn) ->
    bmi =
      serial: null
      visitSerial: @ndr.serial
      visitType: 'ndr-records'
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      data:
        height: data.height
        heightInFt: ''
        heightInInch: ''
        heightUnit: 'cm'
        weight: data.weight
        weightUnit: 'kg'
        calculatedBMI: data.calculatedBMI
        flags:
          flagAsError: false

    if data.serial is null
      bmi.serial = @generateSerialForVitals 'BMI'

    cbfn bmi
    return

  _makeBp: (data, cbfn)->
    bloodPressure =
      serial: data.serial
      visitSerial: @ndr.serial
      visitType: 'ndr-records'
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: null
      data:
        systolic: data.sbp
        diastolic: data.dbp
        random: ''
        unit: 'mm Hg'
        flags:
          flagAsError: false

    if data.serial is null
      bloodPressure.serial = @generateSerialForVitals 'bp'

    cbfn bloodPressure
    return

  upsertBmi: (data)->
    data.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-vitals-bmi', data, ({serial})=> data.serial is serial

  upsertBp: (data)->
    data.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-vitals-blood-pressure', data, ({serial})=> data.serial is serial

  saveBmiData: ()->
    @_makeBmi @bmi, (data)=>
      @upsertBmi data

  saveBpData: (sbp, dbp)->
    bp =
      sbp: sbp.value
      dbp: dbp.value
      serial: sbp.serial

    @_makeBp bp, (data)=>
      @upsertBp data


  saveClinialData: (cbfn)->
    sbp = @ndr.data.clinicalInfoList[4]
    dbp = @ndr.data.clinicalInfoList[5]

    if @bmi.calculatedBMI
     @saveBmiData()

    if sbp.value and dbp.value
      @saveBpData sbp, dbp

    cbfn()
      

  ## Clinical ------------------------------> end

  addMedicine: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#repeat-other-medication-list'
    index = repeater.indexForElement el

    console.log index
    path = "ndr.data.otherMedicationList.#{index}.medicineList"
    @push path , {
      name: ''
      dose: ''
      unit: ''
    }

  addMedicine2: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#repeat-other-medication-list-2'
    index = repeater.indexForElement el

    console.log index
    path = "ndr.data.otherMedicationList2.#{index}.medicineList"
    @push path , {
      name: ''
      dose: ''
      unit: ''
    }

  authorizeNdrRecord: (ndrSerial, ndrType, cbfn)->
    if @ndr.isAuthorized
      cbfn true
      return

    else
      data = { 
        apiKey: @user.apiKey
        visitSerial: 'none'
        recordSerial: ndrSerial
        recordType: 'NDR'
        serverDb: 'bdemr--ndr-records'
        organizationId: @organization.idOnServer
        authorizedOrganizationList: @$getAuthorizedOrganizationList()
        masterType: 'ndr-records'
        recordSubType: ndrType
        patientSerial: @patient.serial
      }


      @callApi '/bdemr-organization-authorize-particular-type-of-record', data, (err, response)=>
        console.log response
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          @ndr.isAuthorized = true
          cbfn true
          return


  saveButtonPressed: ()->
    unless @ndr.data.visitType
      @domHost.showToast 'Please Fill Up Visit type First!'
      return

    if @ndr.serial is null
      @ndr.serial = @generateSerialForNdrRecord()

    
    @ndr.data.laboratoryTestList = @laboratoryTestList
    
    console.log 'NDR SAVING DATA ------>', @ndr
    @saveNdrData @ndr, =>
      @saveNdrLaboratoryTestList =>
        @saveNdrComplicationList @ndr.data.complicationList, =>
          @saveClinialData =>
            @authorizeNdrRecord @ndr.serial, @ndr.data.visitType, =>
              @_makeNdr()
              @domHost.showToast 'Record Saved!'
              @arrowBackButtonPressed()


  saveNdrData: (record, cbfn)->

    record.lastModifiedDatetimeStamp = lib.datetime.now()

    if window.navigator.onLine
      data =
        apiKey: @user.apiKey
        organizationId: @organization.idOnServer
        clientToServerDocList: [ record ]
        client: 'clinic'

      @domHost.toggleModalLoader 'Uploading Record, please wait...'

      @domHost._newSync =>

      # @callApi '/bdemr--generic-upload-data', data, (err, response)=>

        @domHost.toggleModalLoader()

        # if err
        #   return @domHost.showModalDialog err.message
        # if response.hasError
        #   return @domHost.showModalDialog response.error.message
        
        app.db.upsert 'ndr-records', record, ({serial})=> record.serial is serial
        cbfn()
    
    else

      app.db.upsert 'ndr-records', record, ({serial})=> record.serial is serial
      cbfn()

  # Laboratory Data a.k.a "other test" -------> start
  _makeOtherTest: (data, cbfn) ->
    otherTest =
      serial: data.serial
      visitSerial: @ndr.serial
      visitType: 'bdemr-ndr'
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      data:
        date: lib.datetime.now()
        name: data.name
        institution: @organization.name
        institutionSerial: @organization.idOnServer
        result: data.value
        unit: data.unit
        attachmentSerialList: []
        testId: data.testId
        ecgAbnormalityList: []


    if data.serial is null
      otherTest.serial = @generateSerialForVitals 'OT'

    if data.name is 'ECG'
      otherTest.data.ecgAbnormalityList = data.ecgAbnormalityList

    cbfn otherTest
    return

  _makeBloodSugar: (data, cbfn) ->
    bloodSugar =
      serial: data.serial
      visitSerial: @ndr.serial
      visitType: 'bdemr-ndr'
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      data:
        type: data.name
        value: data.value
        unit: data.unit
        testId: data.testId

    if data.serial is null
      bloodSugar.serial = @generateSerialForVitals 'BS'

    cbfn bloodSugar
    return

  upsertOtherTest: (item)->
    # console.log 'OTHER TEST', item
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-test-other', item, ({serial})=> item.serial is serial

  upsertBloodSugar: (item)->
    # console.log 'BLOOD SUGAR'
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-test-blood-sugar', item, ({serial})=> item.serial is serial

  saveNdrLaboratoryTestList: (cbfn)->
    list = @laboratoryTestList
    for item in list
      if item.value
        # for fpg, 2hpg and Post Meal only
        if ((item.name is 'FPG') or (item.name is '2hPG') or (item.name is 'Post Meal'))
          @_makeBloodSugar item, (test)=>
            @upsertBloodSugar test
        else
          # for other test
          @_makeOtherTest item, (test)=>
            @upsertOtherTest test

    cbfn()

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
            # console.log 'child', childIndex, child
            if child.testId is item.data.testId
              foundChildIndex = childIndex
              break

          if foundChildIndex > -1
            @set "laboratoryTestList.#{foundChildIndex}.value", item.data.result
            @set "laboratoryTestList.#{foundChildIndex}.serial", item.serial

            if item.data.name is 'ECG'
              @set "laboratoryTestList.#{foundChildIndex}.ecgAbnormalityList", item.data.ecgAbnormalityList
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

      # console.log 'laboratoryTestList', @laboratoryTestList


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
  _makeConfirmDiagnosis: (data, cbfn) ->
    diagnosis =
      serial: data.serial
      visitSerial: @ndr.serial
      visitType: 'bdemr-ndr'
      createdByUserSerial: @user.serial
      patientSerial: @patient.serial
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: 0
      diagnosis: data.name

    if data.serial is null
      diagnosis.serial = @generateSerialForDiagnosis()

    cbfn diagnosis
    return

  upsertConfirmDiagnosis: (item)->
    # console.log 'CONFIRM  DIAGNOSIS'
    item.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'visit-diagnosis', item, ({serial})=> item.serial is serial

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

    # console.log 'complicationList', @complicationList


  saveNdrComplicationList: (list, cbfn)->
    # list = @complicationList
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
    @domHost.navigateToPage "#/preview-ndr/record:" + @ndr.serial + "/patient:" + @patient.serial

  editPatientBtnPressed: ()->
    @domHost.navigateToPage "#/patient-editor/patient:" + @patient.serial



  addEcgAbonormalValue: (e)->
    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#lab-test-list-repeater'
    index = repeater.indexForElement el

    # console.log 'index', index

    if @abnormalityValue
      @push "laboratoryTestList.#{index}.ecgAbnormalityList", @abnormalityValue

  removeEcgAbnormalValue: (e)->
    el = @locateParentNode e.target, 'PAPER-ICON-BUTTON'
    el.opened = false
    repeater = @$$ '#lab-test-list-repeater'
    index = repeater.indexForElement el

    index2 = e.model.index

    @splice "laboratoryTestList.#{index}.ecgAbnormalityList", index2, 1

  _makeOtherDietItemObject: ()->

    @otherDietItem =

      type: null
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
      calorie: null
      dietChart: null

    @otherDietItem2 =

      type: null
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
      calorie: null
      dietChart: null
  

  _deleteDrug:(e)->
    index = e.model.index
    console.log index
    


  navigatedIn: ->

    @_makeOtherDietItemObject()
    @_makeNewExamination()
    @_makeNewCustomTest()
    @_makeOtherAddictionObject()
    @_makeFamilyHistoryObject()
    @_makeCookingOilObject()

    params = @domHost.getPageParams()

    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"
      
    @_loadUser =>

      if params['patient']
        @_loadPatient params['patient'], =>
          if params['record'] is 'new'
            @_makeNdr()
            @_makeLaboratoryTestList =>
              # @_makeComplicationList =>
              @isRecordValid = true

          else
            @loadNdr params['record'], =>
              @loadAndFilterNdrLaboratoryTestList @ndr.serial
              # @loadAndFilterNdrComplicationList @ndr.serial
              @computeClinicalData2()
      else
        @_notifyInvalidPatient()

    @_loadPccMedicineList()


  addOgldDrug: (e)->

    @push 'ndr.data.ogld.ogldDrugList', {
      ogldDrugName: ''
      drugDosage: ''
    }
  deleteSelectedOgldDrug: (e)->
    len = @ndr.data.ogld.ogldDrugList.length
    # console.log 'length', length
    if len is 1
      @domHost.showToast "Add Another field and TRY AGAIN."
    else
      index = e.model.index
      @splice 'ndr.data.ogld.ogldDrugList', index, 1  


  addOgldDrug2: (e)->
    @push 'ndr.data.ogld2.ogldDrugList', {
      ogldDrugName: ''
      drugDosage: ''
    }
  deleteSelectedOgldDrug2: (e)->
    len = @ndr.data.ogld2.ogldDrugList.length
    # console.log 'length', length
    if len is 1
      @domHost.showToast "Sorry! Add Another field & TRY AGAIN."
    else
      index = e.model.index
      @splice 'ndr.data.ogld2.ogldDrugList', index, 1

  addOgldDrug: (e)->

    @push 'ndr.data.ogld.ogldDrugList', {
      ogldDrugName: ''
      drugDosage: ''
    }
  deleteSelectedOgldDrug: (e)->
    len = @ndr.data.ogld.ogldDrugList.length
    # console.log 'length', length
    if len is 1
      @domHost.showToast "Add Another field and TRY AGAIN."
    else
      index = e.model.index
      @splice 'ndr.data.ogld.ogldDrugList', index, 1   

  # =========================================
  # Loading PCC Medicine List
  # by @taufiq
  # =========================================

  _loadPccMedicineList: ->
    @domHost.getStaticData 'pccMedicineList', (pccMedicineCompositionList)=>
      @pccMedicineCompositionList = pccMedicineCompositionList

      @pccMedicineBrandNameSourceDataList = ({text: "#{item.brandName} #{item.composition[0].strength}", value: item} for item in pccMedicineCompositionList)

  oadAutocompleteSelected: (e)->
    medicine = e.detail.value
    data = {
      ogldDrugName: medicine.brandName
      drugDosage: medicine.composition[0].strength
    }
    @splice "ndr.data.ogld.ogldDrugList", e.model.index, 1, data

  oadAutocompleteSelected2: (e)->
    medicine = e.detail.value
    data = {
      ogldDrugName: medicine.brandName
      drugDosage: medicine.composition[0].strength
    }
    @splice "ndr.data.ogld2.ogldDrugList", e.model.index, 1, data

  otherMedicineAutocompleteSelected: (e)->
    medicine = e.detail.value
    data = {
      name: medicine.brandName
      dose: medicine.composition[0].strength
      unit: medicine.type
    }
    {item, medicineIndex} = e.model
    index = (index for _, index in @ndr.data.otherMedicationList when item.id is _.id)[0]
    path = "ndr.data.otherMedicationList.#{index}.medicineList"
    @splice path, medicineIndex, 1, data
    console.log @ndr.data.otherMedicationList

  otherMedicineAutocompleteSelected2: (e)->
    medicine = e.detail.value
    data = {
      name: medicine.brandName
      dose: medicine.composition[0].strength
      unit: medicine.type
    }
    {item, medicineIndex} = e.model
    index = (index for _, index in @ndr.data.otherMedicationList when item.id is _.id)[0]
    path = "ndr.data.otherMedicationList2.#{index}.medicineList"
    @splice path, medicineIndex, 1, data
    console.log @ndr.data.otherMedicationList

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
    @set 'EDIT_MODE_ON', false
    

}
