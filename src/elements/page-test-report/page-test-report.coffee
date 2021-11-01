
Polymer {

  is: 'page-test-report'

  behaviors: [ 
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:

    user:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    settings:
      type: Object
      notify: true
      value: (app.db.find 'settings')[0] 

    childOrganizationList:
      type: Array
      notify: true
      value: -> []

    loading:
     type: Boolean
     value: -> false

    reportResults:
      type: Array
      value: -> []
    
    totalServiceAmount:
      type: Number
      computed: 'getTotalServiceAmount(reportResults)'

    dateCreatedFrom: String
    dateCreatedTo: String
    currentDateTime:
      type: Number
      value: lib.datetime.now()
    

  
  _isEmptyArray: (array)->
    return array? and array.length > 0

  navigatedIn: ->
    @_loadUser()
    @_loadOrganization()


  _loadUser: ()->
    userList = app.db.find 'user'
    if userList.length is 1
      @set 'user', userList[0]

    
  _loadOrganization: ->
    organizationList = app.db.find 'organization'
    if organizationList.length is 1
      @set 'organization', organizationList[0]
      @_loadChildOrganizationList @organization.idOnServer

  resetButtonClicked: -> @domHost.reloadPage()

  organizationSelected: (e)->
    organizationId = e.detail.value;
    this.set('selectedOrganizationId', organizationId)
  
  _loadChildOrganizationList: (organizationIdentifier)-> 
    this.loading = true
    query = {
      apiKey: this.user.apiKey
      organizationId: organizationIdentifier
    }
    this.callApi '/bdemr--get-child-organization-list', query, (err, response) => 
      this.loading = false;
      organizationList = response.data
      if organizationList.length
        mappedValue = organizationList.map (item) => 
          return { label: item.name, value: item._id }
        mappedValue.unshift({ label: 'All', value: '' }, {label: @organization.name, value: @organization.idOnServer})
        this.set('childOrganizationList', mappedValue)
      else
        organizationSelectorComboBox = this.$.summaryOrganizationSelector
        organizationSelectorComboBox.items = [{ label: this.organization.name, value: this.organization.idOnServer }]
        organizationSelectorComboBox.value = this.organization.idOnServer
        # this.domHost.showToast('No Child Organization Found')


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

  getTotalServiceAmount: (reports)->
    totalCost = reports.reduce (total, item)=> 
      return total += (parseFloat item.serviceAmount)
    , 0
    return totalCost.toFixed(2)

  _getTotalPatientCountByReport: (reports)->
    return reports.reduce((list, item) => 
      if (list.indexOf(item.visit.patientSerial) == -1) 
        list.push(item.visit.patientSerial);
      return list
    , []).length
  

  # ====================================================

  searchButtonClicked: ->
    @reportResults = []
    
    query = {
      apiKey: @user.apiKey
      organizationIdList: []
      reportType: 'investigation'
      searchParameters: {
        dateCreatedFrom: @dateCreatedFrom?=""
        dateCreatedTo: @dateCreatedTo?=""
        searchString: @searchString
      }
    }
    # search parent+child when selecting all
    if !this.selectedOrganizationId
      organizationIdList = this.childOrganizationList.map (item)-> item.value
      organizationIdList.splice(0, 1, this.organization.idOnServer)
      query.organizationIdList = organizationIdList
    else
      query.organizationIdList = [this.selectedOrganizationId]
    
    @loading = true
    @callApi '/bdemr--clinic-test-report', query, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
        @loading = false
      else
        @set 'reportResults', response.data
        @loading = false
  
  # Print Preview
  _getFormattedCurrentDateTime: (currentTime)->
    return lib.datetime.format (new Date(currentTime)), 'mmm d, yyyy h:MMTT'


  _printButtonPressed: ()->
    @currentDateTime = lib.datetime.now()
    window.print()
    # use it if some delay during loading
    # lib.util.delay 200, ()=>
    #   console.log 'wait is over'
    #   window.print()


}
