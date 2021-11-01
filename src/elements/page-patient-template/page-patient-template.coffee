
Polymer {

  is: 'page-patient-template'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    isUploading:
      type: Boolean
      value: false

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
    
    organization:
      type: Object
      notify: true
      value: null

    profileImage:
      type: String
      value: null
      notify: true

    otTemplateObject:
      type: Object
      value: ()-> {}


  _returnSerial: (index)->
    index+1

  _isEmpty: (data)-> 
    if data is 0
      return true
    else
      return false


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()


  _loadPatient: (patientIdentifier, cbfn)->
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1
      @isPatientValid = true
      patient = list[0]
      patient.name = @$getFullName patient.name

      if patient.profileImage
        @set 'profileImage', patient.profileImage
      else
        @set 'profileImage', 'images/avatar.png'

      if ((typeof patient.drugAllergy is 'undefined') or (patient.drugAllergy.list.length is 0))
        patient.drugAllergy =  {value: null, list: []}
        patient.drugAllergy.list.push { type: null }

      @patient = patient
      console.log 'PAT', @patient
    else
      @_notifyInvalidPatient()

    cbfn() if cbfn

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @domHost.showModalDialog 'Invalid Patient Provided'


  _makeOtTemplateObject: ()->
    @otTemplateObject = {
      serial: @generateSerialForOtTemplate()
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: null
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      patientSerial: @patient.serial
      organizationId: @organization.idOnServer
      organizationName: @organization.name
      templateCreatedFrom: 'clinic-app-patient-template'
      data: {
        templateName: ''
        templateContent: ''
      }
      sendToPatient: false
    }


  navigatedIn: ->
    params = @domHost.getPageParams()
    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"
      
    @_loadUser()
    @_loadPatient params['patient'], null

    # ==========
    returningFromOTEditor = JSON.parse localStorage.getItem 'returning_from_generic_editor'
    localStorage.removeItem 'returning_from_generic_editor'

    updatedTemplateContent = JSON.parse localStorage.getItem 'updated_template_content'
    localStorage.removeItem 'updated_template_content'

    unless returningFromOTEditor
      @_makeOtTemplateObject()
    @_setUpdatedTemplateContent returningFromOTEditor, updatedTemplateContent
    # ==========


  _setUpdatedTemplateContent: (returningFromOTEditor, updatedTemplateContent)->
    if returningFromOTEditor
      @set 'otTemplateObject.data.templateContent', updatedTemplateContent

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

        @domHost.setCurrentPatientsDetails patient
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


  navigatedOut: ->
    # console.trace 'navigatedOut'
    @patient = null
    @isPatientValid = false

  
  saveOtButtonPressed: ()->
    console.log 'ot template obj', @otTemplateObject
    @otTemplateObject.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'patient-template-record', @otTemplateObject, ({serial})=> @otTemplateObject.serial is serial
    @domHost.showToast "Patient template saved!"
    @domHost.reloadPage()


}
