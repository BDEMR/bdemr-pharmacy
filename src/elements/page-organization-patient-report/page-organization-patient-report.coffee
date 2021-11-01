
Polymer {
  
  is: 'page-organization-patient-report'

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
    
    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    patientTypeList:
      type: Array
      value: -> ['Regular', 'VIP', 'Employee', 'Political', 'Police Case', 'Free Patient', 'COVID-19 Suspected', 'COVID-19 Confirmed', 'Non COVID-19 Patient']

    loadingCounter:
      type: Number
      value: -> 0

    currentDateTime:
      type: Number
      value: lib.datetime.now()

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0]      

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
   
    patientNameSearchString:
      type: String
      value: ''
    
    patientTypeRecords:
      type: Array
      value: []


  # filteringParametersChanged: (patientNameSearchString, patientPhoneSearchString)->
  #   lib.util.delay 300, ()=>
  #     tempPatientName = if patientNameSearchString then patientNameSearchString.trim().toLowerCase() else ''
  #     tempPatientPhone = if patientPhoneSearchString then patientPhoneSearchString.trim() else ''

  #     tempList = @invoiceList.filter (item)=>
  #       nameFlag = phoneFlag = false
  #       if (item.patientName) and ((tempPatientName is '') or (tempPatientName isnt '' and @$getFullName(item.patientName).toLowerCase().includes tempPatientName))
  #         nameFlag = true
  #       if (item.patientPhone) and ((tempPatientPhone is '') or (tempPatientPhone isnt '' and item.patientPhone.includes tempPatientPhone)) 
  #         phoneFlag = true
  #       return nameFlag and phoneFlag
      
  #     @set 'filteredInvoiceList', tempList
  #     console.log 'filtered list', @filteredInvoiceList


  
  _isEmptyArray: (array)->
    return array? and array.length > 0

  _sortByDate: (a, b)->
    if a.createdDatetimeStamp < b.createdDatetimeStamp
      return 1
    if a.createdDatetimeStamp > b.createdDatetimeStamp
      return -1
  

  navigatedIn: ->
    @loadingCounter++
    @_loadUser()
    @_loadOrganization ()=>
      @_loadChildOrganizationList @organization.idOnServer
      @_loadMemberList ()=> null    
      @loadingCounter--


  navigatedOut: ->
    @showDuesOnly = false
    @dateCreatedFrom = ''
    @dateCreatedTo = ''
    @selectedOrganizationId = ''

  
  getBoolean: (data)-> if data then true else false

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  # _loadSettings: ()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   @settings = {}
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization and @organization.printSettings
  #         @settings.printDecoration =  @organization.printSettings


  _loadOrganization: (cbfn)->
    @loadingCounter++
    data = { 
      apiKey: @user.apiKey
      idList: [ @organization.idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      @loadingCounter--
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]
        cbfn()


  resetButtonClicked: -> @domHost.reloadPage()

  organizationSelected: (e)->
    organizationId = e.detail.value
    @set('selectedOrganizationId', organizationId)

  memberSelected: (e)->
    unless e.detail.value
      @selectedUserSerial = null
      return
    user = e.detail.value
    @selectedUserSerial = user.serial
  
  _loadChildOrganizationList: (organizationIdentifier)-> 
    @loadingCounter++
    query = {
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    }
    @callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      @loadingCounter--
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        @set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = @$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: @organization.name, value: @organization.idOnServer }]
        organizationSelectorComboBox.value = @organization.idOnServer

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
    
  
  # viewInvoiceButtonPressed: (e)->
  #   item = e.model.item
  #   @domHost.navigateToPage '#/print-invoice/invoice:' + item.serial + '/patient:' + item.patientSerial

  # editInvoiceButtonPressed: (e)->
  #   item = e.model.item
  #   console.log item
  #   @domHost.showModalInput "Patient already exists. Please enter patient PIN to import", "0000", (answer)=>
  #     if answer    
  #       @_importPatient item.patientSerial, answer, (patient)=>
  #         @domHost.navigateToPage '#/create-invoice/invoice:' + item.serial + '/patient:' + item.patientSerial


  _checkUserAccess: (accessId)->
    # console.log 'accessId', accessId
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return false

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true


  resetButtonClicked: -> return @domHost.reloadPage()
  
  _loadMemberList: (cbfn)->
    @loadingCounter++
    @memberListLoading = true
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      @loadingCounter--
      @memberListLoading = false
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @set 'memberList', response.data.matchingUserList
        cbfn()
  
  searchButtonClicked: ()->
    query = {
      apiKey: @user.apiKey
      organizationIdList: []
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        patientType: @patientType
        createdByUserSerial: @selectedUserSerial?=""
      }
    }

    # search parent+child when selecting all
    if !@selectedOrganizationId
      organizationIdList = @childOrganizationList.map (item)-> item.value
      organizationIdList.splice(0, 1, @organization.idOnServer)
      query.organizationIdList = organizationIdList
    else
      query.organizationIdList = [@selectedOrganizationId]

    console.log 'query', query
    @loadingCounter += 1
    @callApi '/bdemr--clinic-organization-patient-report', query, (err, response)=>
      @loadingCounter -= 1
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @patientTypeRecords = response.data
        console.log 'patient type list', @patientTypeRecords


  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'

  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    @domHost.navigateToPage "#/invoice-report-print-preview"
  
  _prepareInvoiceReportJsonData: (rawReport) ->
    return rawReport.map (item) => {
      'Serial': item.referenceNumber or ''
      'Date': @$formatDate item.createdDatetimeStamp
      'Category': item.category or ''
      'Patient Name': @$getFullName item.patientName or ''
      'Patient Mobile': item.patientPhone or ''
      'Referred Doctor': item?.referralDoctor?.name or ''
      'Discount': item.discount or ''
      'Vat/Tax': item.vatOrTax or ''
      'Billed': item.totalBilled or ''
      'Received': item.totalAmountReceieved or ''
      'Due': @calculateDue(item.totalBilled, item.totalAmountReceieved)
      'Next Payment Date': @$formatDate(item.nextPaymentDate)
    }
  
  downloadCsv: (csv, exportedFilenmae)->
    blob = new Blob [csv], { type: 'text/csvcharset=utf-8' }
    link = document.createElement "a"
    url = URL.createObjectURL blob
    link.setAttribute "href", url
    link.setAttribute "download", exportedFilenmae
    link.style.visibility = 'hidden'
    link.target = '_blank'
    document.body.appendChild link
    link.click()
    document.body.removeChild link

  _exportButtonClicked: ()->
    data = null
    data = @_prepareInvoiceReportJsonData @filteredInvoiceList
    preppedData = data
    csvString = Papa.unparse(preppedData)
    @downloadCsv csvString, 'invoice-report-export.csv'


}
