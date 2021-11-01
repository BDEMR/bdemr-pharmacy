
app.behaviors.visitPage = {
 
  properties:

    visit:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

  genericNavigatedIn: ->
    params = @domHost.getPageParams()

    if params['visit']
      if params['visit'] is 'new'
        @_makeNewVisit()
      else  
        @_loadVisit params['visit']
    else
      @_notifyInvalidVisit()

    if @visit
      if params['patient']
        @_loadPatient params['patient']
      else if @visit.patientSerial
        @_loadPatient @visit.patientSerial
      else
        @_notifyInvalidPatient()

  navigatedOut: ->
    @visit = null
    @patient = null

  _saveVisit: ->
    app.db.upsert 'doctor-visit', @visit, ({serial})=> @visit.serial is serial
    @domHost.showToast 'Visit Saved'

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    @_saveVisit()
    @arrowBackButtonPressed()

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  _notifyInvalidPatient: ->
    @domHost.showModalDialog 'Invalid Patient Provided'

  _loadVisit: (visitIdentifier)->
    list = app.db.find 'doctor-visit', ({serial})-> serial is visitIdentifier
    if list.length is 1
      @visit = list[0]
    else
      @_notifyInvalidVisit()

  _notifyInvalidVisit: ->
    @domHost.showModalDialog 'Invalid Visit Provided'

}