
Polymer {

  is: 'page-preconception-record'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    disableAddVaccineBtn:
      type: Boolean
      notify: true
      value: true
    
    disableAddOtherFamilyHistoryBtn:
      type: Boolean
      notify: true
      value: true

    disableAddDietaryHistoryBtn:
      type: Boolean
      notify: true
      value: true

    disableAddCookingOilBtn:
      type: Boolean
      notify: true
      value: true

    disableAddHistoryOfDiseaseBtn:
      type: Boolean
      notify: true
      value: true

    addedMedication:
      type: Object
      notify: true
      value: ->
        type: ''
        list: []

    orgSmsBalance:
      type: Number
      notify: true
      value: 0

    pregnancyTitle:
      type: String
      notify: true
      value: null

    hideChildExamination:
      type: Boolean
      notify: true
      value: true

    IS_NEW_PATIENT:
      type: Boolean
      notify: true
      value: false

    visitReasonIndex:
      type: Number
      notify: true
      value: 0

    selectedPatientInfoPage:
      type: Number
      notify: true
      value: 0

    hideMoreAddressInput:
      type: Boolean
      notify: true
      value: false

    showPhysicalActivity:
      type: Boolean
      notify: true
      value: false


    EDIT_MODE_ON:
      type: Boolean
      notify: true
      value: false

    EDIT_RECORD:
      type: Boolean
      notify: true
      value: false

    showMedicalMngForm:
      type: String
      notify: true
      value: null


    user:
      type: Object
      notify: true
      value: null

    isPatientValid: 
      type: Boolean
      notify: true
      value: false

    patient:
      type: Object
      notify: true
      value: null
    pcc:
      type: Object
      notify: true
      value: null

    pccOthers:
      type: Object
      notify: true
      value: null


    waistHipRatio:
      type: Object
      notify: true
      value: {}

    hideClinicalPart:
      type: Boolean
      notify: true
      value: false


    visitReasonList:
      type: Array
      value: -> [
        {
          label: 'Preconception'
          value: 'Preconception'
          id: '001'
        }
        {
          label: '1st ANC (6 - 14 weeks)'
          value:'1st ANC (6 - 14 weeks)'
          id: '002'
        }
        {
          label: '2nd ANC (24 - 28 weeks)'
          value: '2nd ANC (24 - 28 weeks)'
          id: '003'
        }
        {
          label: 'At Delivery'
          value: 'At Delivery'
          id: '004'
        }
        {
          label: '6 weeks after delivery'
          value: '6 weeks after delivery'
          id: '005'
        }
        {
          label: '1 year after delivery'
          value: '1 year after delivery'
          id: '006'
        }
        {
          label: '5 years after delivery'
          value: '5 years after delivery'
          id: '007'
        }

      ]

    survey1ChoiceList:
      type: Array
      value: -> ['Kazi', 'Social Media', 'Mobile Message', 'Website', 'Social Gathering', 'Newspaper Article', 'TV Program', 'BADAS / Birdem Center', 'bKash', 'UCash', 'mCash', 'DBBL Mobile-Banking', 'EasyCash', 'SureCash', 'GP SMS', 'Robi/Airtel SMS', 'Banglalink SMS', 'Teletalk SMS']

    genderList:
      type: Array
      value: -> ['Male', 'Female', 'Other']

    divisionIndex:
      type: Number
      value: -1
      notify: true

    districtIndex:
      type: Number
      value: -1
      notify: true

    districtList:
      type: Array
      value: -> []
      notify: true

    divisionList:
      type: Array
      value: -> [
        {
            divisionName: "Barisal"
            districtList: [
                "Barguna",
                "Barisal",
                "Bhola",
                "Jhalokati",
                "Patuakhal",
                "Pirojpur"
            ]
        }
        {
            divisionName: "Chittagong"
            districtList: [
                "Bandarban",
                "Brahmanbaria",
                "Chandpur",
                "Chittagong",
                "Comilla",
                "Cox's Bazar",
                "Feni",
                "Khagrachhari",
                "Lakshmipur",
                "Noakhali",
                "Rangamati"
            ]
        }
        {
            divisionName: "Dhaka"
            districtList: [
                "Dhaka",
                "Faridpur",
                "Gazipur",
                "Gopalganj",
                "Kishoreganj",
                "Madaripur",
                "Manikganj",
                "Munshiganj",
                "Narayanganj",
                "Narsingdi",
                "Rajbari",
                "Shariatpur",
                "Tangail "
            ]
        }
        {
            divisionName: "Khulna"
            districtList: [
                "Bagerhat",
                "Chuadanga",
                "Jessore",
                "Jhenaidah",
                "Khulna",
                "Kushtia",
                "Magura",
                "Meherpur",
                "Narail",
                "Satkhira"
            ]
        }
        {
            divisionName: "Mymensingh"
            districtList: [
                "Jamalpur",
                "Mymensingh",
                "Netrakona",
                "Sherpur"
            ]
        }
        {
            divisionName: "Rajshahi"
            districtList: [
                "Bogra",
                "Joypurhat",
                "Naogaon",
                "Natore",
                "Nawabganj",
                "Pabna",
                "Rajshahi",
                "Sirajganj"
            ]
        }
        {
            divisionName: "Rangpur"
            districtList: [
                "Dinajpur",
                "Gaibandha",
                "Kurigram",
                "Lalmonirhat",
                "Nilphamari",
                "Panchagarh",
                "Rangpur",
                "Thakurgaon"
            ]
        }
        {
            divisionName: "Sylhet"
            districtList: [
                "Habiganj",
                "Moulvibazar",
                "Sunamganj",
                "Sylhet"
            ]
        }
      ]
    bloodGroupList:
      type: Array
      value: -> ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']

    bloodGroupIndex1:
      type: Number
      value: -1

    bloodGroupIndex2:
      type: Number
      value: -1

    professionList:
      type: Array
      value: -> ['Govt. employee', 'Non Govt. employee', 'Self employed', 'Retired', 'Unemployed', 'Others', 'House wife', 'Student', 'Manual labor', 'Skilled labor', 'Administrative']

    expenditureList:
      type: Array
      value: -> ['<20 Thousands', '21-30 Thousands', '31-40 Thousand', '41-50 Thousand', '51 Thousand and above', 'Dependant']

    maritalAgeList:
      type: Array
      value: -> ['Newly Married', 'Less than 1 year', '1 to 5 Years', 'More than 5 Years']

    OADList:
      type: Array
      value: -> ['Metformin', 'Sulphonylureas', 'Meglinitide', 'Glucosidase inhibitor', 'DPP-4 inhibitors', 'SGLT-2 inhibitors', 'Others']

    antiHTNList:
      type: Array
      value: -> ['BB (Beta Blocker)', 'CCB (Calcium Channel Blocker)', 'ACE-1 (Angiotensin-converting Enzyme Inhibitors)', 'ARB (Angiotensis Receptor Blocker', 'α - Blocker', 'Diuretics', '2 Drugs', '3 Drugs', 'Other']

    antiLipidsList:
      type: Array
      value: -> ['Statin', 'Fibrate', 'Ezetimibe', 'Others']

    urineAlbuminList:
      type: Array
      value: -> ['Present', 'Absent']

    urineAlbuminList:
      type: Array
      value: -> ['Present (More than 4/HPF', 'Absent']

    pageCounter:
      type: Number
      value: 0

    familyPlanningMethodList:
      type: Array
      value: -> ['Pills', 'Condom', 'IUCD']

    physicalActivityPreList:
      type: Array
      value: -> ['Aerobic dance', 'Walking', 'Running', 'Cycling', 'Treadmill', 'Stair climbing', 'Swimming', 'Jogging', 'Other']

    physicalActivityObj:
      type: Object
      value: -> {
        name: null
        duration: null
        unit: 'min/day'
      }

    onInsulinList:
      type: Array
      value: -> []

    insulinDeviceList:
      type: Array
      value: -> ['Syringe', 'Pen', 'Pump']

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

    idealWeight:
      type: Number
      value: 0

    estimateCaloriesIntake:
      type: Number
      value: 0
      notify: true

    albuminType:
      type: String
      value: ''

    urinePusCellStatus:
      type: String
      value: ''

    ageInYears:
      type: Number
      value: -1


    vdrlStatus:
      type: String
      value: ''

    hBsAgStatus:
      type: String
      value: ''
    
    hbStatus:
      type: String
      value: ''

    usgReport:
      type: String
      value: ''

    showSponsorDetails:
      type: Boolean
      value:-> false
      notify: true


    foodChartName:
      type: String
      value: ''

    fpg:
      type: Number
      value: 0

    twoHpg:
      type: Number
      value: 0

    glycemiaType:
      type: Object
      value: {}

    glycemiaTypeAdditionalMsg:
      type: Object
      value: {}

    glycemicStatusList:
      type: Array
      value: ->['Unknown', 'Normal at Visit', 'IFG', 'IGT', 'Known Diabetes', 'GDM']

    confirmPregnancyList:
      type: Array
      value: ->['Pregnancy Strip', 'USG']

    hyperglycemiaOfPregnancyValueList:
      type: Array
      value: ->['Rapid Acting', 'Short Acting', 'Intermideate Action', 'Premix', 'Split mix', 'Long acting']

    otherFamilyHistoryDisease:
      type: Object
      value: null

    historyDisease:
      type: Object
      value: null

    otherTypeOfCookingOil:
      type: Object
      value: null

    otherVaccine:
      type: Object
      value: null

    otherDietItem:
      type: Object
      value: null
        

  _returnSerial: (index)->
    index+1
    
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


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

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

  nextButton: ()->
    @selectedPatientInfoPage++
  backButton: ()->
    @selectedPatientInfoPage--

  getDefaultPasswordForPatientSignup: ()->
    if typeof @settings.otherSettings.patientSignUpDefaultPassword
      return '123456'
    else
      return @settings.otherSettings.patientSignUpDefaultPassword

  _makePatientSignUp : (cbfn)->
    @patient =
      name:
        first: ''
        last: ''
        middle: ''
        honorifics: ''
      password: '123456'
      email: ''
      phone: ''
      additionalPhoneNumber: null
      dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      effectiveRegion: 'Bangladesh'
      doctorAccessPin: '0000'
      nationalIdCardNumber: null

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
          addressDivision: null
          addressAreaName: null
          addressLine1: null
          addressLine2: null
          stateOrProvince: null
          addressCountry: "Bangladesh"
        }
      ]
      
      gender: 'Female'
      bloodGroup: ''
      allergy: ''

      expenditure: null
      profession: null
      
      patientSpouseName: ''
      patientFatherName: ''
      patientMotherName: ''
      maritalAge: ''
      maritalStatus: ''
      numberOfFamilyMember: ''
      numberOfChildren: ''

      belongOrganizationList: [
        {
          organizationId: null
          patientIdbyOrganization: null
        }
      ]

      
    @set "IS_NEW_PATIENT", true
    @isPatientValid = true
    cbfn()

  createOtherPccRecordData: ()->
    @pccOthers =
      survey: [
        {
          question: 'How did you find out about this project?'
          answer: ''
        }
      ]

      sponsor:
        name: null
        contactNumber: null
        
      questionList: [
        {
          question:
            en: 'Appropriate medical advice before pregnancy may reduce the risk of diabetes,gestational diabetes (diabetes during pregnancy) and heart problems'
            bd: 'গর্ভধারণের আগে সঠিক সেবা ভবিষ্যতে ডায়াবেটিস ,গর্ভকালীন ডায়াবেটিস ও হৃদরোগের ঝুঁকি কমায়'
          value: ''
        }
        {
          question:
            en: 'Every married woman should take the following vaccinations before pregnancy: Tetanus, Measles, Mumps, Rubella, Chicken Pox, Hepatitis-B, if not taken previously'
            bd: 'আগে থেকে দেয়া না থাকলে প্রত্যেক বিবাহিত নারীর গর্ভধারণের পূর্বে টিটেনাস, হাম, মাম্পস, রুবালা, জলবসন্ত ও বি-ভাইরাসের টিকাগুলি নেয়া উচিত'
          value: ''
        }
        {
          question:
            en: 'Before pregnancy every women should know their blood group'
            bd: 'গর্ভধারণের পূর্বেই প্রত্যেক মহিলার রক্তের গ্রুপ জেনে নেয়া প্রয়োজন'
          value: ''
        }
        {
          question:
            en: 'People who are overweight and have family members with diabetes are most likely to get diabetes (by family members only parents, siblings and grandparents are implied)'
            bd: 'যাদের ওজনাধিক্য ও বংশে ডায়াবেটিস আছে, তাদের ডায়াবেটিস হবার ঝুঁকি বেশি'
          value: ''
        }
        {
          question:
            en: 'Uncontrolled gestational diabetes (diabetes during pregnancy) may create complications for the mother and child'
            bd: 'অনিয়ন্ত্রিত গর্ভকালীন ডায়াবেটিস মা ও শিশুর নানান জটিলতা সৃষ্টি করতে পারে'
          value: ''
        }
        {
          question:
            en: 'Overeating and less physical activity are among the many causes for overweight and obesity'
            bd: 'অতিরিক্ত খাদ্যাভ্যাস ও কম শারীরিক পরিশ্রম ওজনাধিক্য ও স্থুলতার অন্যতম কারণ'
          value: ''
        }
        {
          question:
            en: 'Low Hemoglobin Level (Anemia) increases the risk of complications before and after pregnancy'
            bd: 'রক্তস্বল্পতার কারণে গর্ভকালীন, প্রসবকালীন ও প্রসব পরবর্তী জটিলতা বৃদ্ধি পায়'
          value: ''
        }
        {
          question:
            en: 'Stroke, heart problems, kidney and respiratory disorders may be caused by high blood pressure'
            bd: 'উচ্চ রক্তচাপের কারণে স্ট্রোক, হৃদরোগ, স্নায়ুরোগ ও কিডনির সমস্যা দেখা দিতে পারে'
          value: ''
        }
        {
          question:
            en: 'The condition where pregnant women with blood pressure, experience convulsions/fit is called Eclampsia'
            bd: 'গর্ভকালীন উচ্চ রক্তচাপসহ খিঁচুনি হওয়াকে এক্লাম্পশিয়া বলে '
          value: ''
        }
        {
          question:
            en: 'If Urinary Tract Infection (infection related with urine & bladder) is not treated properly before/during pregnancy, the risk of underweight childbirth and premature baby increases'
            bd: 'গর্ভকালীন মূত্রনালির সংক্রমণের সঠিক চিকিৎসা না করালে কম ওজনের শিশুর জন্ম ও অকালে সন্তান প্রসবের ঝুঁকি বাড়ে'
          value: ''
        }

      ]

      referredList: [
        {
          isSelected: false
          type: 'general'
          value: 'Counselled'
        }
        {
          isSelected: false
          type: 'general'
          value: 'Referred to Gynaecologist'
        }
        {
          isSelected: false
          type: 'general'
          value: 'Referred to Diabatologist/Endocrinologist'
        }
        {
          isSelected: false
          type: 'general'
          value: 'Referred to BADAS Center for Registration'
        }
        {
          isSelected: false
          type: 'general'
          value: 'Referred to Medicine Specialist'
        }
        {
          isSelected: false
          type: 'general'
          value: 'Referred to Nutritionist'
        }
        {
          isSelected: true
          type: 'terms-and-condition'
          value: 'I Agree to the Terms and Conditions'
        }
      ]


    console.log 'PCC OTHER-->', @pccOthers

  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle
    return 'not provided yet'

  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false

  createPccRecord: ()->
    console.log 'createPccRecord Called!'
    
    @pcc =

      serial: null
      lastModifiedDatetimeStamp: 0
      createdDatetimeStamp: 0
      lastSyncedDatetimeStamp: 0
      createdByUserSerial: @user.serial
      createdByUserId: @user.idOnServer
      createdByUserName: @user.name
      patientSerial: null
      patientRegisteredPhoneNumber: @patient.phone
      doctorName: @$getFullName @user.name
      doctorSpeciality: @getDoctorSpeciality()
      isAuthorized: false
      organizationId: @organization.idOnServer
      clientCollectionName: 'pcc-records'
      visitReason:
        type: 'Preconception'
        id: '001'
      centerInfo:
        centerIdOnServer: @organization.idOnServer
        centerSerial: @organization.serial
        centerName: @organization.name
        patientId: null ## this id will come from "patientIdbyOrganization"

      doPhysicalActivity: 'no'
      physicalActivityList: []

      medicalInfo:
        vaccinationList: [
          {
            name: 'Tetanus'
            value: ''
          }
          {
            name: 'MMR'
            value: ''
          }
          {
            name: 'Varicella'
            value: ''
          }
          {
            name: 'Hepatitis'
            value: ''
          }
        ]
        didPreviousPreconceptionCare: ''
        familyPlanning:
          haveFamilyPlanning: ''
          methodsOfFamilyPlanning: ''
        drugAddictionList: [
          {
            type: 'Cigarette Smoking'
            isYes: ''
            amount: ''
          }
          {
            type: 'Tobacco leaf'
            isYes: ''
            amount: ''
          }
          {
            type: 'Betel leaf'
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
        

        otherActivityList: [
          {
            name: "Watching TV",
            duration: null
            unit: 'h/day'
          }

          {
            name: "Sleeping",
            duration: null
            unit: 'h/day'
          }

        ]

        dietaryHistoryList: [
          {
            isCustom: false
            type: 'Rice'
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
          {
            isCustom: false
            type: 'Ruti/Chapati'
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
          {
            isCustom: false
            type: 'Fish'
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
          {
            isCustom: false
            type: 'Meat'
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
          {
            isCustom: false
            type: 'Green Vegetable'
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
          {
            isCustom: false
            type: 'Fruits'
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
          {
            isCustom: false
            type: 'Soft drinks'
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
          {
            isCustom: false
            type: 'Table Salt'
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
          {
            isCustom: false
            type: 'Sweets'
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
          {
            isCustom: false
            type: 'Fast Foods'
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
          {
            isCustom: false
            type: 'Ghee/butter'
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
          {
            isCustom: false
            type: 'Hotel Food'
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
        ]

        

        typeOfCookingOilList: [
          {
            type: 'Soyebean oil'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
          }
          {
            type: 'Mustard oil'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
          }
          {
            type: 'Palm oil'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
          }
          {
            type: 'Olive oil'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
          }
          {
            type: 'Rice bran oil'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
          }
          {
            type: 'Other'
            isYes: ''
            amount: ''
            unit: 'Litres'
            duration: 'Month'
            isCustom: false
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
            disease: 'Heart disease'
            value: ''
          }
          {
            disease: 'Stroke'
            value: ''
          }
        ]
      clinical:
        diabeticStatus: 'Non-Diabetic'
        pregnancyInfo:
          glycemicStatus: localStorage.getItem("currentPatientGlycemicStatus") or ''
          gestationalWeek: ''
          weeksAfterDelivery: ''
          monthsAfterDelivery: ''
          yearsAfterDelivery: ''
          confirmPregnancyBy: ''
          lmp: ''
          edd: ''
          nextVisitDate: ''
          gravida: ''
          para: ''
          haveAbortion: 'no'
          odema: ''


        birthInfo:
          list: [
            {
              type: 'Site of Deliver'
              value: ''
              unit: ''
              preList: ['Home', 'Hospital']
              inputType: 'radio-button-group'
            }
            {
              type: 'Sex of Baby'
              value: ''
              unit: ''
              preList: ['Male', 'Female']
              inputType: 'radio-button-group'
            }
            {
              type: 'Mode of Delivery'
              value: ''
              unit: ''
              preList: ['Normal', 'C/S','Forcep']
              inputType: 'radio-button-group'
            }
            {
              type: 'Apgar score'
              value: ''
              unit: ''
              preList: []
              inputType: 'text'
            }
            {
              type: 'Resuscitation'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'radio-button-group'
            }
            {
              type: 'Delivered at (Weeks)'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'number'
            }
            {
              type: 'Admission to neonatal nursery'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'radio-button-group'
            }
            {
              type: 'Congenital anomaly'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'radio-button-group'
            }
            {
              type: 'jaundice'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'radio-button-group'
            }
            {
              type: 'Death'
              value: ''
              unit: ''
              preList: ['Yes', 'No']
              inputType: 'radio-button-group'
            }
          ]

        childHistory: [
          {
            type: 'Weight(kg)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'length(cm)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'OFC(cm)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Mid Upper Arm(cm)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Weight for height(kg/m²)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Height for age(cm)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Ponderial Index([(gm/cm­³)*100])'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Placental weight(gm)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
          {
            type: 'Blood sugar(mmol/L)'
            atBirthAndComments: [
              {
                name:'At Birth'
                value: ''
              }
              {
                name: 'Comments'
                value: ''
              }
            ]
          }
        ]

        motherHistory: [
          {
            type: 'Preclampsia'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'Eclampsia'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'Breast Feeding'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'PIH'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
        ]

        clinicalExaminationList: [
          {
            type: 'Birth Weight'
            value: ''
            unit: 'Kg'
            inputType: 'number'
            haveInfoPanel: false
          }
          {
            type: 'Height'
            value: ''
            unit: 'cm'
            inputType: 'number'
          }
          {
            type: 'Weight'
            value: ''
            unit: 'Kg'
            inputType: 'number'
          }
          {
            type: 'Waist'
            value: ''
            unit: 'cm'
            inputType: 'number'
          }
          {
            type: 'Hip'
            value: ''
            unit: 'cm'
            inputType: 'number'
          }
          {
            type: 'SBP'
            value: ''
            unit: 'mmHg'
            inputType: 'number'
          }
          {
            type: 'DBP'
            value: ''
            unit: 'mmHg'
            inputType: 'number'
          }
          
        ]

        muacValue: ''

        labReportsList: [
          {
            type: 'FPG'
            value: ''
            unit: 'mmol/L'
            inputType: 'number'
          }
          {
            type: '2hPG/Post meal'
            value: ''
            unit: 'mmol/L'
            inputType: 'number'
          }
          {
            type: 'Hb'
            value: ''
            unit: 'g/dl'
            inputType: 'number'
          }
          {
            type: 'Blood Group'
            value: ''
            unit: ''
            inputType: 'drop-down-menu'
            haveInfoPanel: false
          }
          {
            type: 'Urine Albumin'
            value: ''
            unit: ''
            preList: ['Absent', 'Present']
            inputType: 'radio-button-group'
          }
          {
            type: 'Urine Pus cell'
            value: ''
            unit: ''
            preList: ['Absent', 'Present (More than 4/HPF)']
            inputType: 'radio-button-group'
          }
        ]

        labReportsOtherList: [
          {
            type: 'HBsAg'
            value: ''
            unit: ''
            preList: ['Absent', 'Present']
            inputType: 'radio-button-group'
          }
          {
            type: 'VDRL'
            value: ''
            unit: ''
            preList: ['Absent', 'Present']
            inputType: 'radio-button-group'
          }
          {
            type: 'USG report'
            value: ''
            unit: 'Weeks'
            inputType: 'number'
          }
          {
            type: 'HbA1c %:'
            value: ''
            unit: ''
            inputType: 'number'
          }
        ]
      medicalManagement:
   
        lifeStyleType: ''
          
        medicationList: [
          {
            type: 'Oral anti-diabetics'
            list: [
              {
                name: 'OADs'
                isYes: ''
                value: ''
                hideAddButton: true

              }
            ]
          }
          {
            type: 'Insulin'
            list: [
              {
                name: 'On insulin'
                isYes: ''
                value: ''
                typeOfDevice: ''
                hideAddButton: true
              }
            ]
          }
          {
            type: 'Other medications'
            list: [
              {
                name: 'Anti HTN'
                isYes: ''
                hideAddButton: false
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
                isYes: ''
                hideAddButton: false
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
                isYes: ''
                hideAddButton: false
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
                isYes: ''
                hideAddButton: false
                medicineList: [
                  {
                    name: ''
                    dose: ''
                    unit: ''
                  }
                ]
              }
            ]
          }
          
        ]

        medicationRelatedToPregnancy: [
          {
            type: 'Multivitamin'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'Calcium'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'Iron'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
        ]

        medicationRelatedToPregnancyFro1stANC: [
          {
            type: 'Folic Acid'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
          {
            type: 'Zn'
            value: ''
            unit: ''
            preList: ['Yes', 'No']
            inputType: 'radio-button-group'
          }
        ]

        hyperglycemiaOfPregnancy:
          instruction: ''
          drugList: [
            {
              name: ''
            }
          ]

      pccOthers: null

      childExamination:
        forVisitReasonIdList: ['005', '006', '007']
        examinationList: [
          {
            type: 'Height'
            value: ''
            unit: 'cm'
            inputType: 'number'
          }
          {
            type: 'Weight'
            value: ''
            unit: 'kg'
            inputType: 'number'
          }
          {
            type: 'Length'
            value: ''
            unit: 'cm'
            inputType: 'number'
          }
          {
            type: 'MUAC'
            value: ''
            unit: ''
            inputType: 'number'
          }
        ]
    

  _loadPatient: (patientIdentifier, cbfn)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @patient = list[0]
      console.log 'PATIENT ------>', @patient
      @set 'IS_NEW_PATIENT', false
      @isPatientValid = true
    else
      @_notifyInvalidPatient()

    cbfn()

  _loadPccRecord: (recordIdentifier)->
    list = app.db.find 'pcc-records', ({serial})-> serial is recordIdentifier
    if list.length is 1
      pcc = list[0]
      @set 'pcc', pcc
      if pcc.pccOthers
        @set 'pccOthers', pcc.pccOthers
      else
        @createOtherPccRecordData()

      console.log 'Load PCC Record ------>', @pcc
      console.log 'Load PCC Record ------>', @pcc
    else
      @domHost.showModalDialog 'Duplicate PCC Record!'


  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient!'

  calculateAge: (e)->
    selectedDate = e.detail.value
    selectedDateYear = (new Date selectedDate).getFullYear()
    currentYear = (new Date).getFullYear()
    age = currentYear - selectedDateYear
    # console.log age
    if age is 0
      age = null
    @ageInYears = age

  makeDOBFromYears: (e)->
    age = e.target.value
    dateInYear = (new Date).getFullYear()
    dateInYear -= parseInt age
    @set 'patient.dateOfBirth', "#{dateInYear}-01-01"

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

  printButtonPressed: (e)->
    window.print()

  addPhysicalActivity: ()->
    unless @physicalActivityObj.name and @physicalActivityObj.duration
      @domHost.showToast 'Please Fill Up Name and Duration'
      return

    @push "pcc.physicalActivityList", @physicalActivityObj
    @makeNewPhysicalActivityObj()

  deletePhysicalActivity: (e)->
    index = e.model.index
    @splice "pcc.physicalActivityList", index, 1

  deleteVaccination: (e)->
    index = e.model.index
    @splice "pcc.medicalInfo.vaccinationList", index, 1

  deleteDietItem: (e)->
    index = e.model.index
    @splice "pcc.medicalInfo.dietaryHistoryList", index, 1

  deleteCookingOil: (e)->
    index = e.model.index
    @splice "pcc.medicalInfo.typeOfCookingOilList", index, 1
  
  deleteHistoryOfDisease: (e)->
    index = e.model.index
    @splice "pcc.medicalInfo.historyOfDeseaseList", index, 1
  
  deleteFamilyHistory: (e)->
    index = e.model.index
    @splice "pcc.medicalInfo.familyHistoryList", index, 1

  makeNewPhysicalActivityObj: ()->
    @physicalActivityObj =
      name: null
      duration: null
      unit: 'min/day'

  medicalManagementValueChange: (e)->
    value = @pcc.medicalManagement.mangementTypeList[1].value
    console.log value
    @set 'showMedicalMngForm', @pcc.medicalManagement.mangementTypeList[1].value


  calcCalories: (calorie)->
    @set 'estimateCaloriesIntake', 0

    actualCal = calorie

    visitReason = @pcc.visitReason.type

    if visitReason is '2nd ANC (24 - 28 weeks)'
      actualCal = calorie + 340
    else if visitReason is 'At Delivery' or visitReason is '6 weeks after delivery'
      actualCal = calorie + 700


    # lib.util.delay 100, ()=>
    @set 'estimateCaloriesIntake', actualCal

    @getFoodChart @estimateCaloriesIntake


  getFoodChart: (calorie)->
    console.log 'calorie', calorie
    foodChartName = ''
    @set "foodChartName", ''
    
    if 1100 > calorie
      foodChartName = 'Food Chart 1'
    else if (1300 > calorie >= 1100)
      foodChartName = 'Food Chart 2'
    else if (1500 > calorie >= 1300)
      foodChartName = 'Food Chart 3'
    else if (1700 > calorie >= 1500)
      foodChartName = 'Food Chart 4'
    else if (1900 > calorie >= 1700)
      foodChartName = 'Food Chart 5'
    else if (2100 > calorie >= 1900)
      foodChartName = 'Food Chart 6'
    else if (2300 > calorie >= 2100)
      foodChartName = 'Food Chart 7'
    else if (2500 > calorie >= 2300)
      foodChartName = 'Food Chart 8'
    else if (2500 <= calorie)
      foodChartName = 'Food Chart 9'

    console.log 'foodChartName', foodChartName

    # lib.util.delay 100, ()=>
    @set "foodChartName", foodChartName


  calcBMI: (height, weight)->
    results = weight / (height * height)
    @set 'bmi.results', Math.round(results * 100) / 100
    console.log 'bmi', @bmi
    if @bmi.results < 18.50
      @set 'bmi.classification', 'Underweight'
      @set 'bmi.class', 'warning'
      @calcCalories parseFloat @idealWeight * 35
    else if (18.5 <= @bmi.results < 23)
      @set 'bmi.classification', 'Normal weight'
      @set 'bmi.class', 'normal'
      @calcCalories parseFloat @idealWeight * 30
    else if (23 <= @bmi.results <= 25)
      @set 'bmi.classification', 'Overweight'
      @set 'bmi.class', 'warning'
      @calcCalories parseFloat @idealWeight * 25
    else if (25 <= @bmi.results < 30)
      @set 'bmi.classification', 'Class I obesity'
      @set 'bmi.class', 'danger'
      @calcCalories parseFloat @idealWeight * 20
    else if (30 <= @bmi.results < 35)
      @set 'bmi.classification', 'Class II obesity'
      @set 'bmi.class', 'danger'
      @calcCalories parseFloat @idealWeight * 20
    else if @bmi.results >= 35
      @set 'bmi.classification', 'Class III obesity'
      @set 'bmi.class', 'danger'
      @calcCalories parseFloat @idealWeight * 20

    # console.log 'estimateCaloriesIntake', @estimateCaloriesIntake

  calcIdealWeight: (heightInCM)->
    idealWeight = heightInCM - 100
    @set 'idealWeight', idealWeight


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


   calcUrinePusCellStatus: (value)->
    console.log value
    if value is 'Present (More than 4/HPF)'
      @set 'urinePusCellStatus', 'UTI'
    else
      @set 'urinePusCellStatus', ''

  calcAlbuminType: (value)->
    console.log value
    if value is 'Present'
      @set 'albuminType', 'ALBUMINURIA'
    else
      @set 'albuminType', ''

  calcVdrlStatus: (value)->
    console.log value
    if value is 'Present'
      @set 'vdrlStatus', 'VDRL POSITIVE'
    else
      @set 'vdrlStatus', ''

  calcHBsAgStatus: (value)->
    console.log value
    if value is 'Present'
      @set 'hBsAgStatus', 'HEPATITIS B POSITIVE'
    else
      @set 'hBsAgStatus', ''

  calcHbStatus: (value)->
    value = parseFloat value

    if @pcc.visitReason.type is '1st ANC (6 - 14 weeks)' or @pcc.visitReason.type is '2nd ANC (24 - 28 weeks)'
      if value < 11
        @set 'hbStatus', 'ANEMIA'
      else
        @set 'hbStatus', ''

    else
      if value < 12
        @set 'hbStatus', 'ANEMIA'
      else
        @set 'hbStatus', ''

  checkUSGReport: (value, index)->
    console.log value
    if value > 14
      @set "pcc.clinical.labReportsList.{index}.value", 14
      @set "usgReport", "USG duration can't be more than 14 weeks"
    else
      @set "usgReport", "USG duration can't be more than 14 weeks"

  hideBmiData: ()->
    @set 'bmi.results', 0

  hideIdealWeight: ()->
    @set 'idealWeight', 0

  # hideWaistHipRatio: ()->
  #   @set 'waistHipRatio', 0

  hideHypertention: ()->
    @set 'hypertension.type', ''

  hideAlbuminType: ()->
    @set 'albuminType', ''



  computeClinicalData: (e)->

    index = e.model.index
    item = @pcc.clinical.clinicalExaminationList[index]
    if item.type is 'Height'
      @getPatientHeight = item.value / 100
      @calcIdealWeight item.value
    else if item.type is 'Weight'
      @getPatientWeight = item.value
    else if item.type is 'Waist'
      @patientWaistValue = item.value
    else if item.type is 'Hip'
      @patientHipValue = item.value
    else if item.type is 'SBP'
      @sbpValue = item.value
      @calcHypertension @sbpValue, @dbpValue
    else if item.type is 'DBP'
      @dbpValue = item.value
      @calcHypertension @sbpValue, @dbpValue
    
    @calcWaistHipRatio @patientWaistValue, @patientHipValue
    @calcBMI @getPatientHeight, @getPatientWeight
    

  
  calc2HpgValue: (fpg, twoHpg)->
    if fpg is 0
      return

    if @pcc.visitReason.type is '1st ANC (6 - 14 weeks)' or @pcc.visitReason.type is '2nd ANC (24 - 28 weeks)'

      if fpg < 5.1

        @set "glycemiaType.value", 'NORMAL GLYCEMIA'
        @set "glycemiaType.class", 'normal'

        if twoHpg < 8.5
          @set "glycemiaType.value", 'Normal GLYCEMIA'
          @set "glycemiaType.class", 'normal'
        else if twoHpg >= 8.5
          @set "glycemiaType.value", 'GDM'
          @set "glycemiaType.class", 'warning'

      else if fpg >= 5.1
        @set "glycemiaType.value", 'GDM'
        @set "glycemiaType.class", 'warning'

    
    else

      if fpg < 6.1
        @set "glycemiaType.value", 'NORMAL GLYCEMIA'
        @set "glycemiaType.class", 'normal'
        if twoHpg >= 11.1
          @set "glycemiaType.value", 'DM'
          @set "glycemiaType.class", 'warning'

        else if ( 7.8 <= twoHpg <  11.1)
          @set "glycemiaType.value", 'IGT'
          @set "glycemiaType.class", 'warning'

        else if twoHpg < 7.8 
          @set "glycemiaType.value", 'Normal GLYCEMIA'
          @set "glycemiaType.class", 'normal'

      else if (6.1 <= fpg < 7)

        @set "glycemiaType.value", 'IFG'
        @set "glycemiaType.class", 'warning'

        if (11.1 > twoHpg >= 7.8)
          @set "glycemiaType.value", 'IGT'
          @set "glycemiaType.class", 'warning'

        else if twoHpg >= 11.1
          @set "glycemiaType.value", 'DM'
          @set "glycemiaType.class", 'warning'

      else if fpg >= 7
        @set "glycemiaType.value", 'DM'
        @set "glycemiaType.class", 'warning'

    # if !((@pcc.visitReason.type is 'Preconception') or (@pcc.visitReason.type is 'At Delivery'))
    if fpg < 7
      # @set "glycemiaTypeAdditionalMsg.value", 'Controlled DM'
      # @set "glycemiaTypeAdditionalMsg.class", 'normal'

      if twoHpg < 8
        @set "glycemiaTypeAdditionalMsg.value", 'Controlled DM'
        @set "glycemiaTypeAdditionalMsg.class", 'normal'
      else
        @set "glycemiaTypeAdditionalMsg.value", 'Uncontrolled DM'
        @set "glycemiaTypeAdditionalMsg.class", 'warning'

    else
      @set "glycemiaTypeAdditionalMsg.value", 'Uncontrolled DM'
      @set "glycemiaTypeAdditionalMsg.class", 'warning'

    
  onDiabeticStatusChange: (e)->
    value = e.target.name
    if value is 'Diabetic'
      lib.util.delay 5, ()=>
        @set "pcc.clinical.labReportsList.1.type", 'Post meal'
    else
      lib.util.delay 5, ()=>
        @set "pcc.clinical.labReportsList.1.type", '2hPG/Post meal'

  computeLabData: (e)->
    index = e.model.index
    item = @pcc.clinical.labReportsList[index]

    if item.type is 'FPG'
      @fpg = parseFloat item.value

    else if item.type is '2hPG/Post meal'
      @twoHpg = parseFloat item.value

    else if item.type is 'Urine Albumin'
      lib.util.delay 100, ()=>
        @calcAlbuminType item.value
    else if item.type is 'Urine Pus cell'
      lib.util.delay 100, ()=>
        @calcUrinePusCellStatus item.value
    else if item.type is 'Hb'
      lib.util.delay 100, ()=>
        @calcHbStatus item.value
    else if item.type is 'HBsAg'
      lib.util.delay 100, ()=>
        @calcHBsAgStatus item.value
    else if item.type is 'VDRL'
      lib.util.delay 100, ()=>
        @calcVdrlStatus item.value

    # else if item.type is 'USG report'
    #   lib.util.delay 100, ()=>
    #     @checkUSGReport item.value, index

    @calc2HpgValue @fpg, @twoHpg


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
      dailyValue = @pcc.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{weeklyIndex}.value", parseInt((dailyValue * 7).toString())
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 1
      weeklyValue = @pcc.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      dailyValue = weeklyValue / 7
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{dailyIndex}.value", parseInt(dailyValue.toString())
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{monthlyIndex}.value", parseInt((dailyValue * 30).toString())


    if memberIndex is 2
      monthlyValue = @pcc.medicalInfo.dietaryHistoryList[index].consumeAmount[memberIndex].value
      dailyValue = monthlyValue / 30
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{dailyIndex}.value", 0
      @set "pcc.medicalInfo.dietaryHistoryList.#{index}.consumeAmount.#{weeklyIndex}.value", 0


    # @pcc.medicalInfo.dietaryHistoryList[index].consumeAmount[weeklyIndex].value = (value * 7).toString()

    
    console.log 'list', @pcc.medicalInfo.dietaryHistoryList


  _getWeeklyValue: (e)->
    el = @locateParentNode e.target, 'PAPER-INPUT'
    el.opened = false
    repeater = @$$ '#dietary-list-repeater'
    index = repeater.indexForElement el
    dailyIndex = e.model.index

    console.log 'index', index
    console.log 'dailyIndex', dailyIndex

  sendFollowUpResultToPatientViaSms: (cbfn) ->
    data =
      patient:
        name: @$getFullName @patient.name
        phone: @patient.phone
      apiKey: @user.apiKey
      organization:
        id: @organization.idOnServer
        name: @organization.name
      computedData: @getComputedData()

    @callApi '/bdemr-pcc-send-sms-with-results', data, (err, response)=>
      if err or response.hasError
        @domHost.showWarningToast 'Couldnt send SMS'
        # cbfn false
        # return
      # else
      #   console.log 'Sucessfully Sent SMS to Patient!'
      #   cbfn()
      #   return

      # cbfn true
      # return

      cbfn()


  upsertPccRecord: ()->

    unless @patient.name and @patient.dateOfBirth
      @domHost.showToast 'Please Fill Up Required Information'
      return

    @_callBDEMRPatientDetailsUpdateApi @patient, =>
      app.db.upsert 'patient-list', @patient, ({serial})=> @patient.serial is serial

    if @pcc.serial is null
      @pcc.serial = @generateSerialForPccRecord()
      @pcc.createdDatetimeStamp = lib.datetime.now()
      @pcc.patientSerial = @patient.serial

    if @pcc.visitReason.type is 'Preconception'
      @pcc.pccOthers = @pccOthers

    @pcc.computedData = @prepartedComputedObject()
    @pcc.clientCollectionName = 'pcc-records'
    
    @_savePccRecord @pcc, =>
      # @authorizePccRecord @pcc.serial, @pcc.visitReason.type, =>
      # @sendFollowUpResultToPatientViaSms ()=>
      @domHost.loadOrganizationSmsBalance @organization.idOnServer
      @createPccRecord()
      @domHost.showToast "Record Saved!"
      @arrowBackButtonPressed()


  _importPatient: (serial, pin, cbfn)->
    @callApi '/bdemr-patient-import-new', {serial: serial, pin: pin, doctorName: @user.name, organizationId: @organization.idOnServer}, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patientList = response.data

        if patientList.length isnt 1
          return @domHost.showModalDialog 'Unknown error occurred.'


        patient = patientList[0]

        id = (app.db.find 'patient-list', ({serial})-> serial is patient.serial)[0]._id
        if id
          app.db.remove 'patient-list', id

        patient.flags = {
          isImported: false
          isLocalOnly: false
          isOnlineOnly: false
        }
        patient.flags.isImported = true

        # @domHost.setCurrentPatientsDetails patient

        _id = app.db.insert 'patient-list', patient
        cbfn _id


  _callBDEMRPatientDetailsUpdateApi: (patient, cbfn) ->
    data =
      patient: patient
      apiKey: @user.apiKey
    @callApi '/bdemr-patient-details-update', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()

  onVisitReasonChange: (e)->
    id = @visitReasonList[@visitReasonIndex].id
    type = @visitReasonList[@visitReasonIndex].value
    @pcc.visitReason.id = id
    @pcc.visitReason.type = type

    console.log @pcc.visitReason

    @changePregnencyCardTitle @pcc.visitReason.type

    @updateInsulinTypePreList()

    @toggleChildExaminationCard()

  toggleChildExaminationCard: ()->
    list = @pcc.childExamination.forVisitReasonIdList
    
    for id in list
      if @pcc.visitReason.id is id
        lib.util.delay 10, ()=>
          @set 'hideChildExamination', false
          return

    @set 'hideChildExamination', true

  changePregnencyCardTitle: (visitReason)->
    if visitReason is "6 weeks after delivery"
      lib.util.delay 10, ()=>
        @set 'pregnancyTitle', 'Post Pregnancy (4 to 12 weeks)'

    else if visitReason is "1 year after delivery"
      lib.util.delay 10, ()=>
        @set 'pregnancyTitle', "1 year after delivery"

    else if visitReason is "5 years after delivery"
      lib.util.delay 10, ()=>
        @set 'pregnancyTitle', "5 years after delivery"

  updateInsulinTypePreList: ()->
    preList1 = ['Short Acting Conventional', 'Intermediate Acting Conventional', 'Rapid Activing Analogue', 'Premixed Conventional', 'Premixed Analogue', 'Spiltmixed Conventional', 'Glargine Analogue', 'Determir Analogue', 'Others']
    preList2 = ['Short Acting Conventional', 'Intermediate Acting Conventional', 'Rapid Activing Analogue', 'Premixed Conventional', 'Premixed Analogue', 'Spiltmixed Conventional', 'Glargine Analogue', 'Determir Analogue', 'Insulin Degludec', 'Insulin Degludec/Insulin Aspart', 'Others']
    
    visitReasonList = ["Preconception", "6 weeks after delivery", "1 year after delivery", "5 years after delivery"]
    
    for item in visitReasonList
      if @pcc.visitReason.type is item
        @set "onInsulinList", preList2
        return

    @set 'onInsulinList', preList1

  abortionValueChange: (e)->
    lib.util.delay 10, ()=>
      if @pcc.clinical.pregnancyInfo.haveAbortion is "yes"
        lib.util.delay 100, ()=>
          @set 'hideClinicalPart', true
          console.log @hideClinicalPart
          return
      else
        lib.util.delay 100, ()=>
          @set 'hideClinicalPart', false
          console.log @hideClinicalPart
          return

  addAnotherHyperglycemiaDrug: ()->
    @push 'pcc.medicalManagement.hyperglycemiaOfPregnancy.drugList', {
      name: ''
    }

  deleteHyperglycemiaDrug: (e)->
    index = e.model.index
    @splice 'pcc.medicalManagement.hyperglycemiaOfPregnancy.drugList', index, 1

  onDivisionChange: (e)->
    @set 'districtIndex', -1
    districtList = @divisionList[@divisionIndex].districtList
    lib.util.delay 5, ()=>
      @set 'districtList', districtList

  checkForVisitId: (list)->
    console.log 'pcc.visitReason.id', @pcc.visitReason.id
    if list.length > 0
      for id in list
        if @pcc.visitReason.id is id
          return true
    return true

  onPageSelect: (e)->
    console.log 'selectedPatientInfoPage', @selectedPatientInfoPage
    if @patient is null
      return

    else
      weight = @pcc.clinical.clinicalExaminationList[2].value
      height = @pcc.clinical.clinicalExaminationList[1].value

      if @IS_NEW_PATIENT
        unless @patient.name.first and @patient.password and @patient.phone and @patient.dateOfBirth
          @domHost.showToast 'Please Fill Up Required Information'
          @set 'selectedPatientInfoPage', 0
          return

        if @selectedPatientInfoPage > 3
          if @pcc.visitReason.type isnt 'At Delivery'
            unless height and weight
              @domHost.showToast 'Please Add Height & Weight'
              @set 'selectedPatientInfoPage', 3
              return

        if @selectedPatientInfoPage is 6
          @getAddedMedicatonList()

      else
        unless @patient.name.first and @patient.dateOfBirth
          @domHost.showToast 'Please Fill Up Required Information'
          @set 'selectedPatientInfoPage', 0
          return
        # if @pcc.visitReason.type is 'Preconception'
        if @selectedPatientInfoPage > 3
          if @pcc.visitReason.type isnt 'At Delivery'
            unless height and weight
              @domHost.showToast 'Please Add Height & Weight'
              @set 'selectedPatientInfoPage', 3
              return
        # else
        #   if @selectedPatientInfoPage > 2
        #     if @pcc.visitReason.type isnt 'At Delivery'
        #       unless height and weight
        #         @domHost.showToast 'Please Add Height & Weight'
        #         @set 'selectedPatientInfoPage', 2
        #         return


        # if @selectedPatientInfoPage is 4
        @getAddedMedicatonList()

    if @EDIT_RECORD
      if (@selectedPatientInfoPage is 2) or (@selectedPatientInfoPage is 4)
        @getResultsForClinicalData()
        @getResultsForLabData()



  getResultsForLabData: ()->
    for item in @pcc.clinical.labReportsList

      if item.type is 'FPG'
        @fpg = parseFloat item.value

      else if item.type is '2hPG/Post meal'
        @twoHpg = parseFloat item.value

      else if item.type is 'Urine Albumin'
        lib.util.delay 100, ()=>
          @calcAlbuminType item.value
      else if item.type is 'Urine Pus cell'
        lib.util.delay 100, ()=>
          @calcUrinePusCellStatus item.value
      else if item.type is 'Hb'
        lib.util.delay 100, ()=>
          @calcHbStatus item.value
      else if item.type is 'HBsAg'
        lib.util.delay 100, ()=>
          @calcHBsAgStatus item.value
      else if item.type is 'VDRL'
        lib.util.delay 100, ()=>
          @calcVdrlStatus item.value

      # else if item.type is 'USG report'
      #   lib.util.delay 100, ()=>
      #     @checkUSGReport item.value, index

      @calc2HpgValue @fpg, @twoHpg
      

  getResultsForClinicalData: () ->
    for item in @pcc.clinical.clinicalExaminationList
      if item.type is 'Height'
        @getPatientHeight = item.value / 100
        @calcIdealWeight item.value
      else if item.type is 'Weight'
        @getPatientWeight = item.value
      else if item.type is 'Waist'
        @patientWaistValue = item.value
      else if item.type is 'Hip'
        @patientHipValue = item.value
      else if item.type is 'SBP'
        @sbpValue = item.value
        @calcHypertension @sbpValue, @dbpValue
      else if item.type is 'DBP'
        @dbpValue = item.value
        @calcHypertension @sbpValue, @dbpValue
      
      @calcWaistHipRatio @patientWaistValue, @patientHipValue
      @calcBMI @getPatientHeight, @getPatientWeight


  getAddedMedicatonList: ()->

    # @set "addedMedication.type", ''
    # @set "addedMedication.list", []

    addedMedication =
      type: @pcc.medicalManagement.lifeStyleType
      list: []

    if addedMedication.type is 'Medication'
      medList = @pcc.medicalManagement.medicationList

      filteredMedList = []

      for obj in medList
        for item in obj.list
          if item.isYes is 'yes'
            filteredMedList.push item

      addedMedication.list = filteredMedList
    else
      @addedMedication.list = []

    lib.util.delay 100, ()=>
      @set "addedMedication", addedMedication

      console.log 'addedMedication', @addedMedication

  calcEstimateEddDate: ()->
    if @pcc.clinical.pregnancyInfo.lmp isnt null or @pcc.clinical.pregnancyInfo.lmp isnt ''
      lmpDate = @pcc.clinical.pregnancyInfo.lmp
      ms = Date.parse lmpDate
      days = (1000*60*60*24) * 262 ## (28days * 9months + 10days)
      totalMs = ms + days
      eddDate = lib.datetime.mkDate totalMs, 'dd-mmm-yyyy'
      @set 'pcc.clinical.pregnancyInfo.edd', eddDate
    else
      @set 'pcc.clinical.pregnancyInfo.edd', ''

  ## -- pcc update -- start

  ## -- pcc update -- end

  ## -- pcc signup -- start

  _gotoPreconceptionPreviewPage: (recordIdentifier)->
    localStorage.setItem("pcc", JSON.stringify @patient)
    @domHost.navigateToPage "#/preview-preconception-record/record:" + recordIdentifier

  _mimicPatientImport: (patient)->
    patient.flags = {
      isImported: false
      isLocalOnly: false
      isOnlineOnly: false
    }
    patient.flags.isImported = true
    app.db.insert 'patient-list', patient

  _savePccRecord: (record, cbfn)->

    record.lastModifiedDatetimeStamp = lib.datetime.now()

    data =
      apiKey: @user.apiKey
      record: record
    
    @domHost.toggleModalLoader 'Uploading Record, please wait...'

    @callApi '/set-pcc-record', data, (err, response)=>
      @domHost.toggleModalLoader()
      if err
        return @domHost.showModalDialog err.message
      if response.hasError
        return @domHost.showModalDialog response.error.message
      
      cbfn()



    # if window.navigator.onLine
    #   data =
    #     apiKey: @user.apiKey
    #     organizationId: @organization.idOnServer
    #     clientToServerDocList: [ record ]
    #     client: 'clinic'

    #   @domHost.toggleModalLoader 'Uploading Record, please wait...'

    #   # @domHost._newSync =>    

    #   @callApi '/set-pcc-record', data, (err, response)=>

    #     @domHost.toggleModalLoader()

    #     if err
    #       return @domHost.showModalDialog err.message
    #     if response.hasError
    #       return @domHost.showModalDialog response.error.message
        
    #     app.db.upsert 'pcc-records', record, ({serial})=> record.serial is serial
    #     cbfn()
    
    # else
    #   app.db.upsert 'pcc-records', record, ({serial})=> record.serial is serial
    #   cbfn()


  _assignNewPatientToCurrentPccRecord: (patient)->
    @pcc.pccOthers = @pccOthers
    @pcc.serial = @generateSerialForPccRecord()
    @pcc.createdDatetimeStamp = lib.datetime.now()
    @pcc.patientSerial = patient.serial
    console.log 'PCC', @pcc

  prepartedComputedObject: ()->
    object = 
      bmi: ''
      idealWeight: ''
      estimateCaloriesIntake: ''
      foodChartName: ''
      waistHipRatio:
        value: ''
        comment: ''
      hypertension:
        type: ''
        comment: ''
      glycemiaType: ''
      glycemiaTypeAdditionalMsg: ''
      albuminType: ''
      urinePusCellStatus: ''
      hbStatus: ''
      vdrlStatus: ''

    if @bmi.results > 0
     object.bmi = @bmi.results

    if @idealWeight > 0
      object.idealWeight =  @idealWeight

    if @bmi.results > 0
      if @estimateCaloriesIntake > 0
        object.estimateCaloriesIntake = @estimateCaloriesIntake

    if @bmi.results > 0
      if @foodChartName isnt ''
        object.foodChartName = @foodChartName

    if @patientWaistValue > 0
      object.waistHipRatio = @waistHipRatio.value
      object.waistHipRatioComment = @waistHipRatio.comment

    if @hypertension.type isnt ''
      object.hypertension = @hypertension.type
      object.hypertension = @hypertension.comment

    if @glycemiaType.value isnt ''
      object.glycemiaType = @glycemiaType.value

    if @glycemiaTypeAdditionalMsg.value isnt ''
      object.glycemiaTypeAdditionalMsg = @glycemiaTypeAdditionalMsg.value

    if @albuminType isnt ''
      object.albuminType = @albuminType

    if @urinePusCellStatus isnt ''
      object.urinePusCellStatus = @urinePusCellStatus

    if @hbStatus isnt ''
      object.hbStatus = @hbStatus

    if @vdrlStatus isnt ''
      object.vdrlStatus = @vdrlStatus


    return object


  getComputedData: ()->
    string = ''

    if @bmi.results > 0
      string += "BMI: " + @bmi.results

    if @idealWeight > 0
      string += ", Ideal Weight: " + @idealWeight

    if @bmi.results > 0
      if @estimateCaloriesIntake > 0
        string += ", Calorie: " + @estimateCaloriesIntake

    if @bmi.results > 0
      if @foodChartName isnt ''
        string += ", See: " + @foodChartName

    if @patientWaistValue > 0
      string += ', Waist-Hip Ratio: ' + @waistHipRatio.value + '(' + @waistHipRatio.comment + ')'

    if @hypertension.type isnt ''
      string += ', ' + @hypertension.type

    if @glycemiaType.value isnt ''
      string += ', ' + @glycemiaType.value

    if @glycemiaTypeAdditionalMsg.value isnt ''
      string += ', ' + @glycemiaTypeAdditionalMsg.value

    if @albuminType isnt ''
      string += ', You have ' + @albuminType

    if @urinePusCellStatus isnt ''
      string += ', You have ' + @urinePusCellStatus

    if @hbStatus isnt ''
      string += ', You have ' + @hbStatus

    if @vdrlStatus isnt ''
      string += ', You have ' + @vdrlStatus

    string += '.'

    return string


  _memorizePinForNewPatient: (patient)->
    patientPinObject = { patientSerial: patient.serial, pin: patient.doctorAccessPin }
    app.db.upsert 'local-patient-pin-code-list', patientPinObject, ({patientSerial})=> patientPinObject.patientSerial is patientSerial

  _createOnlinePccPatient: (patient, cbfn) ->
    data =
      patient: patient
      apiKey: @user.apiKey
      computedData: @getComputedData()

    @callApi '/bdemr-preconception-records-patient-registration', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        patient = response.data.patient
        @domHost.loadOrganizationSmsBalance @organization.idOnServer
        return cbfn patient
  
  _createTemporaryOfflinePatient: (patient, cbfn)->
    serial = '' + (new Date).getTime() + '-' + (Math.floor(Math.random() * 10000) + 10000)
    patient.serial = serial
    patient.isTemporaryOfflinePatient = true
    lib.util.delay 0, => cbfn patient

  _createPatientAndPccRecord: (isOffline, cbfn)->
    console.log 'PATIENT', @patient
    unless @patient.name.first and @patient.password and @patient.phone and @patient.dateOfBirth
      @domHost.showToast 'Please Fill Up Required Information'
      return

    @patient.belongOrganizationList[0].organizationId = @organization.idOnServer

    p1 = new Promise (accept, reject)=>
      if isOffline
        @_createTemporaryOfflinePatient @patient, (patient)=> accept(patient)
      else
        @_createOnlinePccPatient @patient, (patient)=> accept(patient)
    p1.then (patient)=>
      @_memorizePinForNewPatient patient
      @_assignNewPatientToCurrentPccRecord patient
      @_savePccRecord @pcc, =>
        @_mimicPatientImport patient
        # @authorizePccRecord @pcc.serial
        @domHost.showModalDialog "Patient Created Successfully!"
        @_gotoPreconceptionPreviewPage @pcc.serial, @pcc.visitReason.type

  authorizePccRecord: (pccSerial, pccType, cbfn)->
    if @pcc.isAuthorized
      cbfn true
      return

    else
      data = { 
        apiKey: @user.apiKey
        visitSerial: 'none'
        recordSerial: pccSerial
        recordType: 'PCC'
        serverDb: 'bdemr--pcc-records'
        organizationId: @organization.idOnServer
        authorizedOrganizationList: @$getAuthorizedOrganizationList()
        masterType: 'pcc-records'
        recordSubType: pccType
        patientSerial: @patient.serial
      }


      @callApi '/bdemr-organization-authorize-particular-type-of-record', data, (err, response)=>
        console.log response
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          @pcc.isAuthorized = true
          cbfn true
          return


  pccPatientOfflineSignupPressed: (e = null)->        
    # @domHost.showModalPrompt "This is an offline patient. Once created you can not modify it after you connect
    #   to the internet. Are you sure all the information is correct?", (answer)=>
    #   return unless answer
    @_createPatientAndPccRecord true, => null

  pccPatientSignupPressed: (e = null)->
    @_createPatientAndPccRecord false, => null

  ## -- pcc signup -- end

  onKeyUpFamilyHistory:(e)->
    value = e.target.value
    if value
      @set 'disableAddOtherFamilyHistoryBtn', false
    else
      @set 'disableAddOtherFamilyHistoryBtn', true

  _makeOtherFamilyHistoryObject:()->
    @otherFamilyHistoryDisease =
      {
        disease: ''
        value: 'yes'
        isCustom: true
      }

  addFamilyHistoryDisease: ()->
    @push "pcc.medicalInfo.familyHistoryList", @otherFamilyHistoryDisease
    @_makeOtherFamilyHistoryObject()
  
  onKeyUpHistoryOfDisease:(e)->
    value = e.target.value
    if value
      @set 'disableAddHistoryOfDiseaseBtn', false
    else
      @set 'disableAddHistoryOfDiseaseBtn', true

  _makeHistoryOfDiseaseObject:()->
    @historyDisease =
      {
        disease: ''
        value: 'yes'
        isCustom: true
      }

  addHistoryDisease: ()->
    @push "pcc.medicalInfo.historyOfDeseaseList", @historyDisease
    @_makeHistoryOfDiseaseObject()

  onKeyUpCookingOil:(e)->
    value = e.target.value
    if value
      @set 'disableAddCookingOilBtn', false
    else
      @set 'disableAddCookingOilBtn', true

  _makeCookingOilObject:()->
    @otherTypeOfCookingOil =
      {
        type: ''
        isYes: 'yes'
        amount: ''
        unit: 'Litres'
        duration: 'Month'
        isCustom: true
      }


  addCookingOil: ()->
    @push "pcc.medicalInfo.typeOfCookingOilList", @otherTypeOfCookingOil
    @_makeCookingOilObject()


  onKeyUpVaccine:(e)->
    value = e.target.value
    if value
      @set 'disableAddVaccineBtn', false
    else
      @set 'disableAddVaccineBtn', true

  _makeOtherVaccineObject:()->
    @otherVaccine =
      name: ''
      value: ''
      isCustom: true

  addVaccine: ()->
    @push "pcc.medicalInfo.vaccinationList", @otherVaccine
    @_makeOtherVaccineObject()

  _makeDietItemObject:()->
    @otherDietItem =
      {
        type: ''
        isCustom: true
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

  addDietItem: ()->
    @push "pcc.medicalInfo.dietaryHistoryList", @otherDietItem
    @_makeDietItemObject()

  onKeyUpDiet:(e)->
    value = e.target.value
    if value
      @set 'disableAddDietaryHistoryBtn', false
    else
      @set 'disableAddDietaryHistoryBtn', true


  addMedicine: (e)->
    index = e.model.index
    console.log index
    path = "pcc.medicalManagement.medicationList.2.list.#{index}.medicineList"
    @push path , {
      name: ''
      dose: ''
      unit: ''
    }

  intializeComputedData: ()->

    @set 'bmi', {
      results: 0
      classification: ''
    }

    @set 'idealWeight', 0
    @set 'estimateCaloriesIntake', 0
    @set 'foodChartName', ''

    @set 'waistHipRatio', {
      value: 0
      comment: ''
      class: 'normal'
    }
    @set 'hypertension', {
      type: ''
      comment: ''
      class: ''
    }

    @set 'glycemiaType', {
      value: ''
      class: ''
    }

    @set 'glycemiaTypeAdditionalMsg', {
      value: ''
      class: ''
    }
    @set 'albuminType', ''

    @set 'urinePusCellStatus', ''

    @set 'hBsAgStatus', ''

    @set 'vdrlStatus', ''
    @set 'patientWaistValue', 0

  loadOrganization: (cbfn)->
    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"

    cbfn()

  onSurvery1SelectedValue: (e)->
    if @pccOthers.survey[0].answer is 'Kazi'
      @set 'showSponsorDetails', true
    else
      @pccOthers.sponsor.name = null
      @pccOthers.sponsor.contactNumber = null

      @set 'showSponsorDetails', false
    

  navigatedIn: ->

    @intializeComputedData()
    @_makeCookingOilObject()
    @_makeDietItemObject()
    @_makeOtherVaccineObject()
    @_makeHistoryOfDiseaseObject()
    @_makeOtherFamilyHistoryObject()
    
    params = @domHost.getPageParams()

    @loadOrganization =>
      @set 'orgSmsBalance', @domHost.orgSmsBalance

      console.log 'orgSmsBalance', @orgSmsBalance
      
      @_loadUser()
    
      if params['patients'] is 'new'
        @_makePatientSignUp =>
          if params['record'] is 'new'
            @createPccRecord()
            @createOtherPccRecordData()
            @set 'visitReasonIndex', 0
      else
        @_loadPatient params['patients'], =>
          @set "EDIT_MODE_ON", true
          if params['record'] is 'new'
            @createPccRecord()
            @createOtherPccRecordData()
            @set 'visitReasonIndex', 0
          else
            @_loadPccRecord params['record']
            @set 'EDIT_RECORD', true
      
      
  
  navigatedOut: ->
    # console.trace 'navigatedOut'
    @patient = null
    @isPatientValid = false

    @set 'visitReasonIndex', 0
    @set 'selectedPatientInfoPage', 0

    @set 'divisionIndex', -1
    @set 'districtIndex', -1
    @set 'bloodGroupIndex1', -1
    @set 'bloodGroupIndex2', -1
    @set 'EDIT_MODE_ON', false
    @set 'EDIT_RECORD', false



}
