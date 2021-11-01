

Polymer {

  is: 'page-print-record'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
  ]
  properties:
    isPrescriptionValid: 
      type: Boolean
      notify: false
      value: true

    isPatientValid:
      type: Boolean
      notify: false
      value: true      

    prescription:
      type: Object
      notify: true
      value: null


    medications:
      type: Array
      notify: true
      value: []

    matchingCurrentMedicineList:
      type: Array
      notify: true
      value: []

    matchingFavMedicineList:
      type: Array
      notify: true
      value: []

    patient:
      type: Object
      notify: true
      value: null

    medicine:
      type: Object
      notify: true
      value: null

    settings:
      type: Object
      notify: true

    computedEndDate:
      type: String
      computed: '_showComputedEndDate(duplicateMedicineEditablePart.endDateTimeStamp)'      

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

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _getRecord: (recordIdentifier, desiredRecordType)->
    list = app.db.find desiredRecordType, ({serial})-> serial is recordIdentifier
    if list.length is 1
      return list[0]
    else
      return null

  _getPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      return list[0]
    else
      return null



  navigatedIn: ->
    @organization = @getCurrentOrganization()
    # console.log 'here'
    params = @domHost.getPageParams()

    unless params['prescription']
      @domHost.showModalDialog 'Missing prescription!'
      return

    @record = @_getRecord params['prescription'], 'visit-prescription'

    unless @record
      @domHost.showModalDialog 'Invalid prescription Identifier'
      return

    @medications = app.db.find 'patient-medications', ({prescriptionSerial})=> prescriptionSerial is @record.serial

    # unless 'patientSerial' of @record
    #   @domHost.showModalDialog 'Missing Patient from Record'
    #   return

    # console.log @_getPatient params['patient']
    @patient = @_getPatient params['patient']

    unless @patient
      @domHost.showModalDialog 'Invalid Patient Identifier'
      return

    @_getSettings()

    #  console.log @record + 'here 2'
    #  console.log @patient
    #  console.log @medications
    @shouldRender = true

  navigatedOut: ->

    @shouldRender = false

    
  _indexIncrement: (indexNumber)->
    return indexNumber + 1


  _computeTotalDaysCount: (endDate, startDate)->
    return 'As Needed' unless endDate
    oneDay = 1000*60*60*24;
    startDate = new Date startDate
    endDate = new Date endDate
    diffMs = endDate - startDate
    return Math.round(diffMs / oneDay)

}