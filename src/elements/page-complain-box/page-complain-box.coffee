Polymer {
  is: 'page-complain-box'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    complain:
      type: Object
      value: {}
    
    user:
      type: Object
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      value: -> (app.db.find 'organization')[0]
    
    complaintList:
      type: Array
      value: ['Salary', 'Personal attack', 'Verbal assault', 'Physical assault', 'Group assault', 'Lack of Security', 'Misbehaviour by Colleague', 'Misbehaviour by Staff', 'Others' ]

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
    
    attachmentData:
      type: Object
      value: {
        name: null
        dataURI: null
      }


  _getTodaysDateString:()->
    d = new Date()
    month = '' + (d.getMonth() + 1)
    day = '' + d.getDate()
    year = d.getFullYear()

    if month.length < 2
      month = '0' + month
    if day.length < 2
      day = '0' + day

    return [year, month, day].join('-')
  
  _resetComplainObject: (cbfn)->
    @set 'complain', {
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      lastSyncedDatetimeStamp: lib.datetime.now()
      createdByUserSerial: @user.serial
      name: @user.name
      serial: @generateSerialForComplainBox()
      position: ''
      organization:
        name: @organization.name
        id: @organization.idOnServer
      location: @organization.address
      dateOfOccurrence: @_getTodaysDateString()
      typeOfComplaint: ''
      complaintAgainstPerson: ''
      complainAgainstOrganization:
        name: ''
        id: ''
      complainDetails: ''
      attachments: []
      status: 'pending'
    }
    cbfn()
  
  _onTapClear: ()->
    @_resetComplainObject => null
  
  _onSubmitComplain: ()->
    unless @complain.name and @complain.typeOfComplaint and @complain.complainDetails
      return @domHost.showToast 'Please fillup required inputs!'

    @_uploadComplainAttachments @complain.attachments, =>
      @_callSubmitComplain (complainId)=>
        @domHost.showToast 'Your Complain has been Submitted Successfully!'
        @_navigateToComplainPreview complainId
  

  _navigateToComplainPreview: (complainId)->
    @domHost.navigateToPage '#/complain-preview/complainId:' + complainId
    

  _callSubmitComplain: (cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      complain: @complain

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/organization-submit-complain', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        complainId = response.data.complainId
        cbfn complainId
  
  _resetAttachemntData: ()->
    @set 'attachmentData', {
      name: null
      fileNameOnServer: null
    }
  

  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    # if file.size > @maximumImageSizeAllowedInBytes
    #   @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
    #   return

    reader.readAsDataURL file
    reader.onload = =>
      @push 'complain.attachments', {
        name: file.name
        dataURI: reader.result
        fileNameOnServer: null
      }

      @$$("#attachmentFile").value = ''
      # @attachmentData.name = file.name
      # @attachmentData.dataURI = reader.result
    
      console.log @complain
  

  _removeAttachment: (e)->
    index = e.model.index;
    @splice 'complain.attachments', index, 1
  
  _uploadComplainAttachments: (list, cbfn)->
    if list.length is 0
      cbfn()

    @domHost.toggleModalLoader 'Uploading attachment...'
    filteredList = []

    lib.util.iterate list, (next, index, item)=>
      @_callUploadComplainAttachmentApi item, (fileNameOnServer)=>
        filteredList.push {
          name: item.name
          fileNameOnServer: fileNameOnServer
        }
        next()
    .finally =>
      @complain.attachments = filteredList
      @domHost.toggleModalLoader()
      @_resetAttachemntData()
      cbfn()


  _callUploadComplainAttachmentApi: (data, cbfn)->
    attachment =
      mainStorage: 'server'
      apiKey: (app.db.find 'user')[0].apiKey
      dataURI: data.dataURI
      recordSerial: @complain.serial
      originalName: data.name

    @callApi '/bdemr-upload-complain-attachment', attachment, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        fileNameOnServer = response.data.fileNameOnServer
        # @complain.attachments.push {
        #   fileNameOnServer: fileNameOnServer
        #   name: @attachmentData.name
        # }

        cbfn fileNameOnServer

  navigatedIn: ->
    @_resetComplainObject => null
    
} 