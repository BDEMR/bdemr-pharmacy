
app.behaviors.recordPage = {

  desiredRecordType: 'NOT DEFINED'
 
  properties:

    record:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    hasLocalChanges: 
      type: Boolean
      value: true

  genericNavigatedIn: (desiredRecordType)->

    @desiredRecordType = desiredRecordType

    params = @domHost.getPageParams()

    if params['record']
      if params['record'] is 'new'
        @_makeNewRecord()
      else 
        @_loadRecord params['record']
    else
      @_notifyInvalidRecord()

    if @record
      if params['patient']
        @_loadPatient params['patient']
      else if @record.patientSerial
        @_loadPatient @record.patientSerial
      else
        @_notifyInvalidPatient()

  navigatedOut: ->
    @record = null
    @patient = null

  _saveRecord: ->
    app.db.upsert @desiredRecordType, @record, ({serial})=> @record.serial is serial
    @domHost.showToast 'Record Saved'

  _goBack: ->
    @domHost.navigateToPreviousPage()

  arrowBackButtonPressed: (e)->
    if @hasLocalChanges
      @domHost.showModalPrompt 'Are you sure? All unsaved changes will be lost.', (answer)=>
        if answer
          @_goBack()
    else
      @_goBack()

  saveButtonPressed: (e)->
    @_saveRecord()
    @hasLocalChanges = false

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  _notifyInvalidPatient: ->
    @domHost.showModalDialog 'Invalid Patient Provided'

  _loadRecord: (recordIdentifier)->
    list = app.db.find @desiredRecordType, ({serial})-> serial is recordIdentifier
    if list.length is 1
      @record = list[0]
    else
      @_notifyInvalidRecord()

  _notifyInvalidRecord: ->
    @domHost.showModalDialog 'Invalid Record Provided'

}