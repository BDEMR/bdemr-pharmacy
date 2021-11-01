
Polymer {
  
  is: 'page-referral-doctor-manager'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:

    user:
      type: Object
      value: {}
    
    organization:
      type: Object
      value: {}

    referralDoctorObj:
      type: Object
      value: {}
   
    filterDate:
      type: Object
      value: {}

    isLoading:
      type: Boolean
      value: false

    doctorList:
      type: Array
      value: -> []

  

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  
  
  $isAdmin: (userId, userList)->
    for user in userList
      if userId is user.id
        return user.isAdmin
        break
    return false

  _getTotalPaid: (paid = 0, lastPaid = 0)->
    return (parseInt paid) + (parseInt lastPaid)

  
  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  navigatedIn: ->
    @isLoading = true
    @_loadUser()
    @_loadOrganization (organizationIdentifier)=>    
      @isLoading = false
      @_makeNewDoctorObject()
      @searchButtonClicked()
      

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
  
  _loadOrganization: (cbfn)->
    organizationId = @getCurrentOrganization().idOnServer
    unless organizationId
      @_notifyInvalidOrganization()
      return
    data = { 
      apiKey: @user.apiKey
      idList: [ organizationId ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        
        cbfn()
    
  _notifyInvalidOrganization: ->
    @domHost.showModalDialog 'No Organization is Present. Please Select an Organization first.'


  filterByDateClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', (startDate.getTime())
    @set 'dateCreatedTo', (endDate.getTime())

  filterByDateClearButtonClicked: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0
    
  
  searchButtonClicked: ()->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        mobileSearchString: @searchString
      }    
    }
    @callApi '/bdemr--clinic-referral-doctors-report', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        doctorList = response.data
        console.log doctorList
        @set 'doctorList', doctorList


  _addNewDoctorButtonClicked: (e)-> 
    return this.$$('#addNewDoctorDialog').toggle();
  
  _makeNewDoctorObject: ()-> 
    referralDoctorObj = {
      createdDatetimeStamp: null,
      lastModifiedDatetimeStamp: null,
      organizationId: @organization.idOnServer,
      serial: null,
      name: '',
      phone: '',
      email: '',
      address: '',
    }
    @set 'referralDoctorObj', referralDoctorObj



  _addDoctor: ()->
    if @referralDoctorObj.name is '' or @referralDoctorObj.phone is ''
      return @domHost.showModalDialog 'Need Name and Mobile Atleast!'

    @referralDoctorObj.lastModifiedDatetimeStamp = lib.datetime.now()
    @referralDoctorObj.createdDatetimeStamp = lib.datetime.now()
    if !@referralDoctorObj.serial
      @referralDoctorObj.serial = @generateSerialForReferralDoctor()

    console.log {@referralDoctorObj}
    if @referralDoctorObj.serial
      data = { 
        apiKey: @user.apiKey
        referralDoctorDetails: @referralDoctorObj
      }
      @callApi '/bdemr--clinic-add-update-referral-doctor', data, (err, response)=>
        if response.hasError
          @domHost.showModalDialog response.error.message
        else
          @domHost.showToast "User added"
          @_makeNewDoctorObject()
          @searchButtonClicked()
          return this.$$('#addNewDoctorDialog').close();

 
  _editDoctor: (e)->
    { item } = e.model
    console.log item
    this.$$('#addNewDoctorDialog').toggle()
    @referralDoctorObj = item
    

  _deleteDoctor:(e)->
    { item } = e.model
    console.log item
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        data = { 
          apiKey: @user.apiKey
          id: item._id
        }
        @callApi '/bdemr--clinic-delete-referral-doctor', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            @domHost.showToast "User Deleted"
            @searchButtonClicked()
            return


  resetButtonClicked: (e)->
    window.location.reload()    


  # export - start
  _prepareReferralDoctorData: (doctorList) ->
    console.log doctorList
    exportableList = []
    exportableList = doctorList.map (item) =>
      return {
        'name': item.name or ''
        'phone': item.phone or ''
        'email': item.email or ''
        'address': item.address or ''
      }
        
    return exportableList
  
  downloadCsv: (csv, exportedFilenmae) ->
    blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    link = document.createElement("a")
    url = URL.createObjectURL(blob)
    link.setAttribute("href", url)
    link.setAttribute("download", exportedFilenmae)
    link.style.visibility = 'hidden'
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

  _exportBtnPressed: (e)->
    data = @_prepareReferralDoctorData @doctorList

    csvString = Papa.unparse(data);
    fileName = @organization.name.replace(' ', '_') + '_doctor_list.csv'

    @downloadCsv(csvString, fileName);

  # export - end

  # bulk import - start
  _resetBulkImport:()->
    @set 'IMPORT_DONE', false
    @set 'bulkImportLog', null
    @set 'isLoading', false
    @$$('#inputCsvFile').value = ''
    @bulkImport =
      organizationId: @organization.idOnServer
      data: []
    
  
  openFile: (e)->
    @set 'bulkImportLog', null
    reader = new FileReader
    file = e.target.files[0]

    fileType = file.name.split('.').pop()
    console.log fileType

    unless fileType is "csv"
      @domHost.showWarningToast 'Supports CSV Format only!'
      @$$('#inputCsvFile').value = ''
      return

    if file.size > @maximumFileSizeAllowedInBytes
      @domHost.showWarningToast 'Please provide a file less than 1mb in size.'
      return
    reader.readAsText file
    reader.onload = =>
      data = reader.result
      @_convertToCsvFormat(data)
  
  _convertToCsvFormat: (data)->
    Papa.parse data, {
      quotes: false
      quoteChar: '"'
      escapeChar: '"'
      delimiter: ","
      header: true
      newline: "\r\n"
      skipEmptyLines: false,
      columns: null
      complete: (result) =>
        @bulkImport.data = result.data
    }

  _callReferralDoctorBulkApi: (data, cbfn)->
    data.apiKey = @user.apiKey
    @set 'isLoading', true
    @domHost.callApi '/bdemr-clinic-referral-doctors-bulk-import', data, (err, response)=>
      @set 'isLoading', false
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        @set 'IMPORT_DONE', true
        @set 'bulkImportLog', response.data
        cbfn()
  
  onBulkImportBtnPressed: ()->
    console.log @bulkImport
    unless @bulkImport.data.length > 0
      @domHost.showToast 'No Data Availale!'
      return

    @_callReferralDoctorBulkApi @bulkImport, =>
      @searchButtonClicked()
  
  onClearImportBulkBtnPressed: ()->
    @_resetBulkImport()

  showBulkImportForm: ()->
    this.$$('#dialogBulkImport').toggle()
    @_resetBulkImport()

  # bulk import end
}
