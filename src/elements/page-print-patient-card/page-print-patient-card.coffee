
Polymer {

  is: 'page-print-patient-card'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    invoice:
      type: Object
      notify: true
      value: null

    settings:
      type: Object
      notify: true

    loadingCounter:
      type: Number
      notify: true
      value: -> 0


  navigatedIn: ->
    @_loadUser()
    @organization = @getCurrentOrganization()
    params = @domHost.getPageParams()
    unless params['patient']
      @_notifyInvalidVisit()
      return
    @_loadPatient(params['patient'])
    console.log 'patient', @patient
    # idForBarcode = "#{@patient.organizationPatientId}".replace /-/g, ''
    # JsBarcode "#barcode", @patient.organizationPatientId

  navigatedOut: ->
    @settings = {}
    @patient = {}
    @invoice = {}


  _loadUser:()->
    userList = app.db.find 'user'
    # console.log userList
    if userList.length is 1
      @user = userList[0]

  _loadPatient: (patientIdentifier)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length
      @set 'patient', list[0]
    else
      @domHost.showModalDialog 'No Patient details available'



  printButtonPressed: (e)->
    window.print()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _returnSerial: (index)->
    index+1

  $getTodayDate: ()->
    today = new Date()
    year = today.getFullYear()
    month = (today.getMonth()+1).toString()
    date = today.getDate().toString()

    if month.length is 1 then month = "0#{month}"
    if date.length is 1 then date = "0#{date}"

    return "#{year}-#{month}-#{date}"


  _getpatientAddress: (addressList)->
    if not addressList? or addressList.length is 0
      return 'N/A'
    else
      line1 = if addressList[0].addressLine1 then addressList[0].addressLine1 else ''
      line2 = if addressList[0].addressLine2 then addressList[0].addressLine2 else ''

      if line1 is '' and line2 is '' 
        return 'N/A'
      else
        return "#{line1} #{line2}"


  _getPatientBloodGroup: (bloodgroup)->
    if bloodgroup is null or bloodgroup is ''
      return 'N/A'
    else
      return bloodgroup
  
}
