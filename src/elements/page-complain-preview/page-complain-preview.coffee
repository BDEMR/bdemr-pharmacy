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
  is: 'page-complain-preview'
  
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
    
    statusList:
      type: Array
      value: ['pending', 'resolved', 'seen']
    
    complaintList:
      type: Array
      value: ['Salary', 'Personal attack', 'Verbal assault', 'Physical assault', 'Group assault', 'Lack of Security', 'Misbehaviour by Colleague', 'Misbehaviour by Staff', 'Others' ]
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  printButtonPressed: (e)->
    window.print()

  _callGetComplain: (organizationId, complainId)->
    data =
      apiKey: @user.apiKey
      organizationId: organizationId
      complainId: complainId

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/organization-get-complain', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log {response}
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'complain', response.data

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
  
  _updateComplainStatus: ()->
    @_callSubmitComplain =>
      @domHost.showToast 'Status updated!'
      @arrowBackButtonPressed()
  

  onTapDownloadSelectedAttachment: (e)->
    index = e.model.fileIndex

    el = @locateParentNode e.target, 'PAPER-BUTTON'
    el.opened = false
    repeater = @$$ '#complain-attachment-list-repeater'

    index = repeater.indexForElement el

    # console.log index
    file = @complain.attachments[index]

    data = { 
      apiKey: @user.apiKey
      fileIdentifier: file.fileNameOnServer
    }

    @domHost.toggleModalLoader 'Downloading File'

    @callApi '/bdemr-complain-attachment-file-download', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        src = response.data.file.data

        if (src.indexOf 'data:') is 0
          blob = dataURItoBlob src
          objectURL = window.URL.createObjectURL blob
        else
          objectURL = src

        identifier = response.data.file.originalName
        a = window.document.createElement 'a'
        a.href = objectURL
        a.target = '_blank'
        a.download = identifier
        document.body.appendChild a
        a.click()
        window.URL.revokeObjectURL(objectURL)
        document.body.removeChild a
  
  navigatedIn: ->
    params = @domHost.getPageParams()
    complainId = params['complainId']
    if @organization and complainId
      @_callGetComplain @organization.idOnServer, complainId
    
} 