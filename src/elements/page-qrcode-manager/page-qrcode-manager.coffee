Polymer {
  is: 'page-qrcode-manager'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    selectedIndex:
      type: Number
      value: 0

    list:
      type: Array
      value: [
        { name: 'Mahmudul Hasan', expireDatetimeStamp: '', purpose: '' },
      ]

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    patientSearchQuery:
      type: String
      value: -> ""
      observer: 'patientSearchInputChanged'
    
    reports:
      type: Array
      value: []
  

  _callGetOrganizatonPassScanReport: ()->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-pass-scan-logs', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'reports', []
      else
        @set 'reports', response.data
  
  patientSearchInputChanged: (searchQuery)->
    unless searchQuery.length > 2
      return
    @debounce 'search-patient', ()=>
      @_patientSearch(searchQuery)
    , 1000
  
  _patientSearch: (searchQuery)->
    return unless searchQuery
    @$$("#patientSearch").items = []
    @fetchingPatientSearchResult = true;
    @callApi '/bdemr-patient-search-new', { apiKey: @user.apiKey, searchQuery: searchQuery}, (err, response)=>
      @fetchingPatientSearchResult = false
      if response.hasError
        # @domHost.showModalDialog response.error.message
        @domHost.showToast 'No Match Found!'
        @_clearSelectedPatientData()
      else
        @matchingPatientdata = response.data
        console.log @matchingPatientdata
        if @matchingPatientdata.length > 0
          @$$("#patientSearch").items = @matchingPatientdata
          
  
  patientSelected: (e)->
    return unless e.detail.value
    user = e.detail.value
    @doc.generatedForUserId = user.idOnServer
  
  _clearSelectedPatientData: ()->
    @set "patientSearchQuery", ''
    @$$("#patientSearch").value = ""

  
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _callGetOrganizationGeneratedQrCodes: ()->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-organization-get-generated-qr-code-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'list', []
      else
        @set 'list', response.data
  
  _callGetOrganizationPurposeList: ()->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-organization-get-purpose-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'list', []
      else
        @set 'purposeList', response.data
  
  _callSetOrganizationGeneratedQrCode: (data, cbfn)->
    data.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-set-organization-qr-code', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
        return
      else
        @domHost.showToast "Generated New QR Code!"
        cbfn()
  
  _callDeleteOrganizationQrCode: (code, cbfn)->
    data = 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      docCode: code

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-delete-organization-qr-code', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
        return
      else
        @domHost.showToast "Deleted!"
        cbfn()
  
  _getDateTime: ( daysCount, type = null )->
    date = new Date(new Date().setDate(new Date().getDate() + daysCount))
    if type is 'end'
      return "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()-1}T#{date.getHours()}:#{date.getMinutes()}"
    else
      return "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()-1}T#{date.getHours()}:#{date.getMinutes()}"
  
  _resetDoc: ()->
    @set 'doc', {
      startDatetimeStamp: 0
      endDatetimeStamp: 0
      generatedForUserId: ''
      purpose: ''
      organizationId: @organization.idOnServer
    }

    console.log @doc
  
  _generateQrCode: ()->

    unless @doc.generatedForUserId
      return @domHost.showToast 'Please select User first!'

    @doc.startDatetimeStamp = Date.parse @doc.startDatetimeStamp
    @doc.endDatetimeStamp = Date.parse @doc.endDatetimeStamp
    
    @_callSetOrganizationGeneratedQrCode @doc, =>
      @_resetDoc()
      @_callGetOrganizationGeneratedQrCodes()
  
  _deleteItem: (e)->
    { item } = e.model
    console.log {item}
    return if !item
    @_callDeleteOrganizationQrCode item.code, =>
      @_callGetOrganizationGeneratedQrCodes()

  
  navigatedIn: ->
    @_callGetOrganizationPurposeList()
    @_callGetOrganizationGeneratedQrCodes()
    @_callGetOrganizatonPassScanReport()
    @_resetDoc()

    
} 