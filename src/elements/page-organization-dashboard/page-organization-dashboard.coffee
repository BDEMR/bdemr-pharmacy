
Polymer {
  
  is: 'page-organization-dashboard'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:
    organizationsIBelongToList:
      type: Array
      value: -> []
    user:
      type: Object
      value: -> (app.db.find 'user')[0]

    organizationSearchResultList:
      type: Array
      value: -> []
    
    featureStatsList:
      type: Array
      value: -> []
    
    recordStatsList:
      type: Array
      value: -> []
    
    isOrganizationValid:
      type: Boolean
      value: false
    
    organization:
      type: Object
      value: null
    
    childOrganizationList:
      type: Array
      value: -> []

    memberListByRole:
      type: Array
      value: -> []

    loadingCounter:
      type: Number
      value: -> 0      
  
  _isEmptyArray: (data)->
    if data is 0
      return true
    else
      return false

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization/Create new one!'
  
  _loadUser:(cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
    cbfn()
  
  
  
  _loadOrganization: (idOnServer, cbfn)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @loadingCounter++    
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        organization = response.data.matchingOrganizationList[0]

        if typeof organization.serial is 'undefined'
          organization.serial = ''
        
        @set 'organization', organization
        console.log @organization
        @set 'isOrganizationValid', true
      
      cbfn()
  

  # ================================================
  # @author Mahmudul Hasan
  # ================================================

  # Remove organization - start
  _removeOrganization: (organizationId, cbfn)->
    data = { 
      apiKey: @user.apiKey
      organizationId: organizationId
    }
    @callApi '/bdemr-organization-remove', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn response.data.wasRemoved

  removeOrganizationPressed: (e)->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        @_removeOrganization @organization.idOnServer, (wasRemoved)=>
          if wasRemoved
            @domHost.showModalDialog "Removed Successfully"
          else
            @domHost.showModalDialog "Failed to Remove"
            
          @arrowBackButtonPressed()
          @domHost.navigateToPage '#/organization-manager'
  # Remove organization - end

 # Three dot navigation functions (except delete and leave organization)

  accountsManagerPressed: (e)->
    @domHost.navigateToPage '#/accounts-manager-dashboard/organization:' + @organization.idOnServer  

  salaryReportPressed: (e)->
    @domHost.navigateToPage '#/organization-salary-report/organization:' + @organization.idOnServer 

  manageUnitPricePressed: (e)->
    @domHost.navigateToPage '#/manage-unit-price'
  
  sendBulkSmsPressed: (e)->
    @domHost.navigateToPage '#/send-bulk-sms'
  
  dutyRosterPressed: (e)->
    @domHost.navigateToPage '#/manage-duty-roster'

  managePharmacyPressed: (e)->
    @domHost.navigateToPage '#/pharmacy-manager/organization:' + @organization.idOnServer

  editOrganizationPressed: (e)->
    @domHost.navigateToPage '#/organization-editor/organization:' + @organization.idOnServer

  organizationEmployeeManagerPressed: (e)->
    @domHost.navigateToPage '#/organization-employee-manager/organization:' + @organization.idOnServer

  editOrganizationSettingsPressed: (e)->
    @domHost.navigateToPage '#/organization-settings/organization:' + @organization.idOnServer

  # Organization Feature stats - start
  _makeObjectForStats:(stats)->
    recordStatsList = [
      {
        name: 'PCC Records'
        value: 'pcc-records'
        herf: 'pcc-reports'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        isHidden: true
        statsList: [
          {
            title: 'Today'
            type: 'pcc-today'
            recordCount: stats.pccNdrStats.pccTodaysPatientsCount
            patientCount: stats.pccNdrStats.pccTodaysRecordCount
            subTitle: 'Today'
          }
          {
            title: 'This week'
            type: 'pcc-last-7days'
            recordCount: stats.pccNdrStats.pccWeeklyRecordCount
            patientCount: stats.pccNdrStats.pccWeeklyPatientsCount
            subTitle: 'Last 7days'
          }
          {
            title: 'This month'
            type: 'pcc-last-30days'
            recordCount: stats.pccNdrStats.pccMonthlyRecordCount
            patientCount: stats.pccNdrStats.pccMonthlyPatientsCount
            subTitle: 'Last 7days'
          }

          {
            title: 'All Time'
            type: 'pcc-time'
            recordCount: stats.pccNdrStats.pccAllTimeRecordCount
            patientCount: stats.pccNdrStats.pccAllTimePatientsCount
            subTitle: 'Last 7days'
          }
        ]
        actionType: 'outPage'
        classType: 'normal'
      }

      {
        name: 'NWDR Records'
        value: 'ndr-records'
        herf: 'nwdr-reports'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        isHidden: true
        statsList: [
          {
            title: 'Today'
            type: 'ndr-today'
            recordCount: stats.pccNdrStats.ndrTodaysPatientsCount
            patientCount: stats.pccNdrStats.ndrTodaysRecordCount
            subTitle: 'Today'
          }
          {
            title: 'This week'
            type: 'ndr-last-7days'
            recordCount: stats.pccNdrStats.ndrWeeklyRecordCount
            patientCount: stats.pccNdrStats.ndrWeeklyPatientsCount
            subTitle: 'Last 7days'
          }
          {
            title: 'This month'
            type: 'ndr-last-30days'
            recordCount: stats.pccNdrStats.ndrMonthlyRecordCount
            patientCount: stats.pccNdrStats.ndrMonthlyPatientsCount
            subTitle: 'Last 7days'
          }

          {
            title: 'All Time'
            type: 'ndr-all-time'
            recordCount: stats.pccNdrStats.ndrAllTimeRecordCount
            patientCount: stats.pccNdrStats.ndrAllTimePatientsCount
            subTitle: 'Last 7days'
          }
        ]
        actionType: 'outPage'
        classType: 'normal'
      }
    ]

    if @organization
      for item, index in recordStatsList
        if (item.value is 'pcc-records') and (@organization.markAsPccOrganization)
          recordStatsList[index].isHidden = false
        if (item.value is 'ndr-records') and (@organization.markAsNwdrOrganization)
          recordStatsList[index].isHidden = false    
      @set 'recordStatsList', recordStatsList
      console.log recordStatsList

    featureStatsList = [
      {
        name: 'Manage Users'
        type: 'manage-users'
        herf: 'organization-manage-users'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        stats: @memberListByRole
        actionType: 'outPage'
        classType: 'normal'
      }
      {
        name: 'Manage Patient Stay'
        type: 'manage-patient-stay'
        herf: 'organization-manage-patient-stay'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        stats: [
          {
            name: 'Total Seats';
            count: stats.patientStay.totalSeatCount
          }
          {
            name: 'Vacant'
            count: stats.patientStay.totalVacantCount
          }
          {
            name: 'Occupied'
            count: stats.patientStay.totalOccupiedCount
          }
          {
            name: 'Overfolow'
            count: stats.patientStay.totalOverflowCount
          }
        ]
      }
      # {
      #   name: 'Rolewise Member Statistics'
      #   type: 'rolewise-member-statistics'
      #   herf: 'organization-rolewise-member-statistics'
      #   description: ''
      #   iconUrl: 'icons:label-outline'
      #   imageUrl: ''
      #   stats: []
      #   actionType: 'outPage'
      #   classType: 'normal'
      # }
      {
        name: 'Manage Waitlist'
        type: 'organization-manage-waitlist'
        herf: 'organization-manage-waitlist'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        stats: []
        actionType: 'outPage'
        classType: 'normal'
      }
      {
        name: 'Medicine Sales'
        type: 'medicine-sales-statistics'
        herf: 'organization-medicine-sales-statistics'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        stats: []
        actionType: 'outPage'
        classType: 'normal'
      }
      {
        name: 'Organization Wallet for Patient'
        type: 'manage-patient'
        herf: 'organization-manage-patient'
        description: ''
        iconUrl: 'icons:label-outline'
        imageUrl: ''
        stats: []
        classType: 'normal'
      }
      # {
      #   name: 'Organization Records'
      #   type: 'organization-records'
      #   herf: 'organization-records'
      #   description: ''
      #   iconUrl: 'icons:label-outline'
      #   imageUrl: ''
      #   stats: [
      #     {
      #       name: "Total Records"
      #       count: @organizationRecordCount
      #     }
      #   ]
      #   actionType: 'outPage'
      #   classType: 'normal'
      # }
    ]

    console.log featureStatsList
    @set 'featureStatsList', featureStatsList
  
  goToSelectedOrganizationSpecificRecordsPage: (e)->
    { feature } = e.model
    @domHost.navigateToPage '#/' + feature.herf
  
  goToSelectedFeaturePage: (e)->
    { feature } = e.model
    @domHost.navigateToPage '#/' + feature.herf + '/organization:' + @organization.idOnServer
  
  _goToOrganizationDashboard: (e)->
    { childOrg } = e.model
    @domHost.organizationSelectedPageIndex = 0;
    @domHost.navigateToPage '#/organization-dashboard/organization:' + childOrg._id
    # location.reload()

  joinOrganizationTapped: (e)->
    { organization } = e.model
    
    data = { 
      apiKey: @user.apiKey
      organizationId: organization.idOnServer
    }
    @callApi '/bdemr-organization-join-as-a-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        # @_updateOrganizationsIBelongToList()
        @searchOrganizationTapped null

  claimOrganizationTapped: (e)->
    { organization } = e.model
    
    data = { 
      apiKey: @user.apiKey
      organizationId: organization.idOnServer
    }
    @callApi '/bdemr-organization-claim', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog response.data

  leaveOrganizationPressed: (e)->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      if answer
        data = { 
          apiKey: @user.apiKey
          organizationId: @organization.idOnServer
          targetUserId: @user.idOnServer
        }
        @callApi '/bdemr-organization-remove-user', data, (err, response)=>
          if response.hasError
            @domHost.showModalDialog response.error.message
          else
            # @_updateOrganizationsIBelongToList()
            @domHost.logoutPressed()
  
  _loadChildOrganizationList: (organizationIdentifier, cbfn)->
    # @organizationLoading = true
    query =
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier

    @callApi '/bdemr--get-child-organization-list', query, (err, response) =>

      # console.log response
      @organizationLoading = false
      organizationList = response.data
      @set 'childOrganizationCounter', organizationList.length
      if organizationList.length
        @set 'childOrganizationList', organizationList
      else
        @domHost.showToast 'No Child Organization Found'
      
      console.log @childOrganizationList
      cbfn null
  
  _createDateRange: ()->
    daysRange = {}
   
    #today
    today = new Date()
    daysRange.todayStart = today.setHours(0, 0, 0, 0)
    daysRange.todayEnd = today.setHours(23, 59, 59, 999)

    #yesterday
    yesterday = new Date(new Date().setDate(new Date().getDate()-1))
    daysRange.yesterdayStart = yesterday.setHours(0, 0, 0, 0)
    daysRange.yesterdayEnd = yesterday.setHours(23, 59, 59, 999)

    #thisWeek
    thisWeekStart = new Date(new Date().setDate(new Date().getDate()-7))
    thisWeekEnd = new Date()
    daysRange.thisWeekStart = thisWeekStart.setHours(0, 0, 0, 0)
    daysRange.thisWeekEnd = thisWeekEnd.setHours(23, 59, 59, 999)

    #last30days
    last30Days = new Date(new Date().setDate(new Date().getDate()-30))
    today = new Date()
    daysRange.last30DaysStart = last30Days.setHours(0, 0, 0, 0)
    daysRange.last30DaysEnd = today.setHours(23, 59, 59, 999)

    return daysRange

  
  _getOrganizationDashboardStatistics: ()->
    query =
      apiKey: @user.apiKey,
      organizationId: @organization.idOnServer
      organizationIdList: []
      daysRange: @_createDateRange()
    
    if @childOrganizationList.length > 0
      query.organizationIdList = @childOrganizationList.map (item) => (item._id)
    
    query.organizationIdList.push @organization.idOnServer

    @callApi '/bdemr--get-organization-dashboard-stats', query, (err, response) =>
      @loadingCounter--
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_makeObjectForStats response.data
  

  _getAuthorizedRecordsCount:(cbfn) ->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      filters: null
    }
    @callApi '/bdemr-organization-list-authorized-records', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'organizationRecordCount', response.data.recordAuthorizationList.length
        console.log @organizationRecordCount
        cbfn()
  

  _loadMemberList: (cbfn)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'memberList', response.data.matchingUserList
        console.log 'Member List', @memberList
        @_getMemberListByRole(@memberList, @organization)
      
        cbfn()
    

  _getMemberListByRole: (userList, organization)->
    organizationCopy = Object.assign {}, organization

    if organizationCopy.roleList?.length
      memberListByRole = organizationCopy.roleList

      for organizationRole in memberListByRole
        for user in organizationRole.userList
          for member in userList
            if user.id is member.idOnServer
              Object.assign(user, member)

      @set 'memberListByRole', memberListByRole   

  orgWalledPressed: (e)->
    @domHost.navigateToPage '#/organization-wallet/organization:' + @organization.idOnServer  
  
  navigatedIn: ->
    params = @domHost.getPageParams()
    if params['organization']
      @_loadOrganization params['organization'], =>
        @_loadMemberList =>
          # @_getAuthorizedRecordsCount =>
          @_loadChildOrganizationList @organization.idOnServer, =>
            @_getOrganizationDashboardStatistics()

    else
      @_notifyInvalidOrganization()


}
