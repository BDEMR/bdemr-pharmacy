dataURItoBlob = (dataURI) ->
  byteString = atob(dataURI.split(',')[1])
  mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
  ab = new ArrayBuffer(byteString.length)
  ia = new Uint8Array(ab)
  i = 0
  while i < byteString.length
    ia[i] = byteString.charCodeAt(i)
    i++
  blob = new Blob([ ab ], type: mimeString)
  blob

Polymer {

  is: 'page-single-test-result-print'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
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

    isTestValid:
      type: Boolean
      value: false

    testResult:
      type: Object
      notify: true
      value: null

    settings:
      type: Object
      notify: true
      value: {}

    showPrintDetails:
      type: Boolean

    haveAttachment:
      type: Boolean
      value: false
      notify: true

    hideAttachment:
      type: Boolean
      value: false
      notify: true

    testResultsAttachmentSerialList:
      type: Array
      notify: true
      value: []

    attachmentList:
      type: Array
      notify: false
      value: -> []

    newAttachment:
      type: Object
      notify: false
      value: null

    localDataUriDb:
      type: Object
      value: null

    maximumImageSizeAllowedInBytes: 
      type: Number
      value: 10 * 1000 * 1000

    maximumLocalDataUriDbSizeInChars: 
      type: Number
      value: 2 * 1000 * 1000

    localDataUsedPercentage:
      type: Number
      value: 0

    currentDateFilterStartDate:
      type: Number

    currentDateFilterEndDate:
      type: Number



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
      @patient = list[0]
    else
      @_notifyInvalidPatient()

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _notifyInvalidPatient: ->
    @isPatientValid = false
    @showModal 'Invalid Patient Provided'

  _notifyInvalidTest:() ->
    @isTestValid = false
    @domHost.showModalDialog 'Invalid Test Provided!'

  _getAttachements: (serialList)->

  _loadTestResultData: (collectionName, testIdentifier,cbfn)->
      data = {
        apiKey: @user.apiKey
        serial : testIdentifier
        collectionName : collectionName
      }
      this.domHost.toggleModalLoader 'Please Wait'
      @callApi '/bdemr--get-patient-details', data, (err, response)=>
        this.domHost.toggleModalLoader()
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          collectedData = response.data
          cbfn collectedData

  _loadTestResults: (testIdentifier)->
    collectionName = "bdemr--patient-test-results"
    @_loadTestResultData collectionName ,testIdentifier ,(loadedData)=>

    # list = app.db.find 'patient-test-results', ({serial})-> serial is testIdentifier
 
      if loadedData.length is 1
        @testResult = loadedData[0]
        console.log @testResult
        @isTestValid = true

        if @testResult.attachmentSerialList.length > 0
          @_loadAttachmentList testIdentifier
          @set 'haveAttachment', true

        else
          @set 'haveAttachment', false
        
        console.log 'test results', @testResult
      else
        @_notifyInvalidTest()


  navigatedIn: ->

    @organization = @getCurrentOrganization()
    unless @organization
      return @domHost.navigateToPage "#/select-organization"

    params = @domHost.getPageParams()

    showPrintDetails = window.localStorage.getItem('showPrintSectionOnTestResult')
    @set 'showPrintDetails', showPrintDetails

    @_loadUser()
    @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
      @set 'settings', settings       
    
    if params['patient']
      @_loadPatient params['patient']
    else
      @_notifyInvalidPatient()

    if params['record']
      @_loadTestResults params['record']
    else
      @_notifyInvalidTest()

  # Gallary [START]
  # ================================

  _updateSpaceCalculation: ->
    if @localDataUriDb
      taken = @localDataUriDb.computeTotalSpaceTaken()
      used = 1 - ((@maximumLocalDataUriDbSizeInChars - taken) / @maximumLocalDataUriDbSizeInChars)
      @localDataUsedPercentage = Math.floor ((used) * 100)

  _openLocalDataUriDb: ->

    localDataUriDb = new lib.DatabaseEngine {
      name: 'local-data-uri-db'
      storageEngine: lib.localStorage
      serializationEngine: lib.json
      config:
        commitDelay: 0
    }

    localDataUriDb.initializeDatabase { removeExisting: false }

    localDataUriDb.defineCollection {
      name: 'local-attachment'
    }

    @localDataUriDb = localDataUriDb

    sessionDataUriDb = new lib.DatabaseEngine {
      name: 'session-data-uri-db'
      storageEngine: lib.tabStorage
      serializationEngine: lib.json
      config:
        commitDelay: 0
    }

    sessionDataUriDb.initializeDatabase { removeExisting: false }

    sessionDataUriDb.defineCollection {
      name: 'local-attachment'
    }

    @sessionDataUriDb = sessionDataUriDb

  
  
  _makeBlankAttachment: ->
    @set 'newAttachment', {
      title: ''
      description: ''
      dataUri: ''
      originalName: null 
      originalType: null
      sizeInBytes: 0
      sizeInChars: 0
      isImage: false
      isLoaded: false
      progress: 0
    }

  _loadAttachmentList: (testResultIdentifier)->
    # console.log patientIdentifier

    # unless 'attachmentList' of @record.content.attachment
    #   @record.content.attachment.attachmentList = []
    
    localAttachmentList = app.db.find 'patient-gallery--local-attachment', ({testResultsSerial})-> testResultsSerial is testResultIdentifier
    onlineAttachmentList = app.db.find 'patient-gallery--online-attachment', ({testResultsSerial})-> testResultsSerial is testResultIdentifier
    # console.log onlineAttachmentList

    uploadedFileList = []

    lib.util.iterate onlineAttachmentList, (next, index, item)=>
      @callApi 'bdemr/get-uploaded-file', {attachmentId: item.data.attachmentId}, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          uploadedFileList.push response.data
          next()
    .finally =>
      attachmentList = [].concat localAttachmentList, uploadedFileList
      @set 'attachmentList', attachmentList


    console.log @attachmentList
    

  _saveAttachment: (attachment)->
    app.db.upsert 'patient-gallery--local-attachment', attachment, ({serial})=> attachment.serial is serial
  

    

  $toMega: (value)-> (Math.ceil ((value / 1000 / 1000) * 100)) / 100

  $getImageSrc: (attachment)->
    if attachment.mainStorage is 'local'
      list = @localDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial
      if list.length > 0
        return list[0].dataUri
      else
        return 'assets/not-found.png'
    else if attachment.mainStorage is 'server'
      return attachment.dataURI
    else if attachment.mainStorage is 'session'
      list = @sessionDataUriDb.find 'local-attachment', ({attachmentSerial})-> attachmentSerial is attachment.serial
      if list.length > 0
        return list[0].dataUri
      else
        return 'assets/not-found.png'


  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog "Please provide a file less than #{Math.floor(@maximumImageSizeAllowedInBytes / 1000 / 1000)}mb in size."
      return

    reader.readAsDataURL file

    reader.onprogress = (e)=>
      @set 'newAttachment.progress', ((e.loaded / e.total) * 100)

    reader.onload = =>
      dataUri = reader.result
      @set 'newAttachment.isImage', file.type.indexOf('image/') > -1

      @set 'newAttachment.sizeInBytes', file.size
      @set 'newAttachment.title', file.name
      @set 'newAttachment.dataUri', dataUri
      @set 'newAttachment.originalType',  file.type
      @set 'newAttachment.originalName', file.name
      @set 'newAttachment.sizeInChars', dataUri.length
      
      @set 'newAttachment.isLoaded', true

  _prepareAtachment: ->
    { 
      title
      description
      dataUri
      isImage
      originalName
      originalType
      sizeInBytes
      sizeInChars
    } = @newAttachment

    attachment = {
      serial: @generateSerialForAttachment()
      lastModifiedDatetimeStamp: lib.datetime.now()
      mainStorage: null # could be 'server' or 'local' or 'session'
      title
      description
      # dataUri
      isImage
      originalName
      originalType
      sizeInBytes
      sizeInChars
    }

    return attachment


  downloadPressed: (e)->
    attachment = e.model.attachment
    src = @$getImageSrc attachment

    if (src.indexOf 'data:') is 0
      blob = dataURItoBlob src
      objectURL = window.URL.createObjectURL blob, { type: attachment.originalType }
    else
      objectURL = src

    identifier = attachment.originalName
    a = window.document.createElement 'a'
    a.href = objectURL
    a.target = '_blank'
    a.download = identifier
    document.body.appendChild a
    a.click()
    document.body.removeChild a

  # === Gallary [END] ===



  navigatedOut: ->
    @patient = null
    @isPatientValid = false
    @testResults = null

}
