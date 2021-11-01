

Polymer {

  is: 'page-preview-preconception-record'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
  ]
  properties:
    isPatientValid: 
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

    pcc:
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
      value: -> {
        type: ''
        comment: ''
        class: ''
      }

    bmi:
      type: Object
      value: -> {
        results: 0
        classification: ''
      }

    waistHipRatio:
      type: Object
      notify: true
      value: -> {
        value: 0
        comment: ''
        class: 'normal'
      }

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
      value: ->
        {
          value: ''
          class: ''
        }

    settings:
      type: Object
      notify: true

  ## SETTINGS ======================================================================================

 
  _getSettings: ->
    list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
    if list.length
      @settings = list[0]
      if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
        if @organization.printSettings
          @settings.printDecoration = @organization.printSettings      
    else
      @domHost.showModalDialog 'No Settings Found'

 

  # Helper
  # ================================

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  $findCreator: (creatorSerial)-> 'me'

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

  _computeTotalDaysCount: (endDate, startDate)->
      return 'As Needed' unless endDate
      oneDay = 1000*60*60*24;
      startDate = new Date startDate
      diffMs = endDate - startDate
      return Math.round(diffMs / oneDay)

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age

  printButtonPressed: (e)->
    window.print()

  editButtonPressed: (e)->
    @domHost.navigateToPage '#/preconception-record/record:' + @pcc.serial + '/patients:' + @patient.serial
    
  getFullName:(data)->

    if typeof data is "object"
      honorifics = ''
      first = ''
      last = ''
      middle = ''

      if data.honorifics  
        honorifics = data.honorifics + ". "
      if data.first
        first = data.first
      if data.middle
        middle = " " + data.middle
      if data.last
        last = " " + data.last
        
      return honorifics + first + middle + last

    else return data

  _sortByDate: (a, b)->
    if a.date < b.date
      return 1
    if a.date > b.date
      return -1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')

  _returnSerial: (index)->
    index+1

  getDoctorSpeciality: () ->
    unless @user.specializationList.length is 0
      return @user.specializationList[0].specializationTitle

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      patient = list[0]
      patient.name = @getFullName patient.name
      @patient = patient
      console.log 'patient', @patient
    else
      @_notifyInvalidPatient()

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'

  goToPatientManger: ()->
    @domHost.navigateToPage '#/patient-manager/query:' + @patient.phoneNumber

  _loadPccRecord: (recordIdentifier, cbfn)->
    list = app.db.find 'pcc-records', ({serial})-> serial is recordIdentifier
    if list.length is 1
      @pcc = list[0]
      console.log 'PCC', @pcc
      @_loadPatient @pcc.patientSerial
    cbfn()

  createAnotherPatient: ()->
    @domHost.navigateToPage '#/preconception-record/record:new/patients:new'

  goDashboard: ()->
    @domHost.navigateToPage '#/dashboard'


  navigatedIn: ->

    params = @domHost.getPageParams()

    @_loadUser()
    @organization = @getCurrentOrganization()
    @_getSettings() 

    if params['record']
      @_loadPccRecord params['record'], =>
        @getResultsForLabData()
        @getResultsForClinicalData()
    else
      @_notifyInvalidPatient()

  navigatedOut: ->
    @patient = null
    @isPatientValid = false
   
    @patient = null

  calcAlbuminType: (value)->
    console.log value
    if value is 'Present'
      @set 'albuminType', 'ALBUMINURIA'
    else
      @set 'albuminType', ''
  
  calcUrinePusCellStatus: (value)->
    console.log value
    if value is 'Present (More than 4/HPF)'
      @set 'urinePusCellStatus', 'UTI'
    else
      @set 'urinePusCellStatus', ''

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

  calcHBsAgStatus: (value)->
    console.log value
    if value is 'Present'
      @set 'hBsAgStatus', 'HEPATITIS B POSITIVE'
    else
      @set 'hBsAgStatus', ''

  calcVdrlStatus: (value)->
    console.log value
    if value is 'Present'
      @set 'vdrlStatus', 'VDRL POSITIVE'
    else
      @set 'vdrlStatus', ''


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

    if !((@pcc.visitReason.type is 'Preconception') or (@pcc.visitReason.type is 'At Delivery'))
      if fpg <= 5.1
        @set "glycemiaTypeAdditionalMsg.value", 'Good Control'
        @set "glycemiaTypeAdditionalMsg.class", 'normal'

        if twoHpg <= 6.7
          @set "glycemiaTypeAdditionalMsg.value", 'Good Control'
          @set "glycemiaTypeAdditionalMsg.class", 'normal'
        else
          @set "glycemiaTypeAdditionalMsg.value", 'Uncontrolled'
          @set "glycemiaTypeAdditionalMsg.class", 'warning'
      else
        @set "glycemiaTypeAdditionalMsg.value", 'Uncontrolled'
        @set "glycemiaTypeAdditionalMsg.class", 'warning'

  calcIdealWeight: (heightInCM)->
    idealWeight = heightInCM - 100
    @set 'idealWeight', idealWeight

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

  getResultsForLabData: ()->
    console.log @pcc.clinical.labReportsList
    for item in @pcc.clinical.labReportsList
      if item.type is 'FPG'
        @fpg = parseFloat item.value
      else if item.type is '2hPG/Post meal'
        @twoHpg = parseFloat item.value
      else if item.type is 'Urine Albumin'
        @calcAlbuminType item.value
      else if item.type is 'Urine Pus cell'
        @calcUrinePusCellStatus item.value
      else if item.type is 'Hb'
        @calcHbStatus item.value
      else if item.type is 'HBsAg'
        @calcHBsAgStatus item.value
      else if item.type is 'VDRL'
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
      
}
