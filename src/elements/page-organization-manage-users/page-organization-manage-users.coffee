
Polymer {

  is: 'page-organization-manage-users'

  behaviors: [ 
    app.behaviors.commonComputes
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
    
    newMember:
      type: Object
      notify: true
      value: null

    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false

    organization:
      type: Object
      notify: true
      value: null

    memberSearchResultList:
      type: Array
      value: -> []

    memberList:
      type: Array
      value: -> []


    ## Role Manager - start

    role:
      type: Object
      notify: true
      value: null

    roleList:
      type: Array
      value: -> []

    selectedRoleTypeForUser:
      type: String
      notify: true
      value: null

    selectecMemberId:
      type: String
      notify: true
      value: null

    selectedRoleIndex:
      type: Number
      notify: true
      value: null

    departmentList:
      type: Array
      notify: true
      value: -> []

    memberListByRole:
      type: Array
      value: -> []
    
    privilegeList:
      type: Array
      value: -> []


    ## Role Manager - end

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  _loadPatientStayObject: (organizationIdentifier)->
    data = { 
      apiKey: @user.apiKey
      organizationId: organizationIdentifier
    }
    @callApi '/bdemr-organization-patient-stay-get-object', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        departmentList = response.data.patientStayObject.departmentList
        seatList = response.data.patientStayObject.seatList
        @set 'departmentList', @_modifyList departmentList, seatList

        console.log 'departmentList', @departmentList
        

  _modifyList: (deptList, seatList)->
    modDeptList = []
    if deptList
      for dept in deptList
        modDept =
          name: dept.name
          checked: false

        unitList = dept.unitList
        modUnitList = []
        if unitList
          for unit in unitList
            modUnit =
              name: unit.name
              checked: false

            wardList = unit.wardList
            modWardList = []
            if wardList
              for ward in wardList
                modWard =
                  name: ward.name
                  checked: false
                  seatList: @_getSeatListForWard ward.name, seatList
                modWardList.push modWard
              modUnit.wardList =  modWardList
            else
              modUnit.wardList =  modWardList

            modUnitList.push modUnit
          modDept.unitList = modUnitList

        else
          modDept.unitList = modUnitList

        modDeptList.push modDept

      return modDeptList
    else
      return modDeptList

  _getSeatListForWard: (wardName, seatList)->
    modSeatList = []
    if seatList
      for seat in seatList
        if seat.ward
          seat.checked = false
          modSeatList.push seat
      return modSeatList
    else
      return modSeatList

  onDeptSelect: (e)->
    checked = e.target.checked
    selectedDept = e.model.dept
    departmentList = @departmentList

    unitList = selectedDept.unitList
    modUnitList = []

    if checked
      if unitList
        for unit in unitList
          unit.checked = true
          modUnitList.push unit
        selectedDept.unitList = modUnitList
      else
        selectedDept.unitList = modUnitList

      console.log 'selectedDept', selectedDept

      for dept, index in departmentList
        if dept.name is selectedDept.name
          departmentList[index] = selectedDept

      @set 'departmentList', []
      @set 'departmentList', departmentList

    else
      if unitList
        for unit in unitList
          unit.checked = false
          modUnitList.push unit
        selectedDept.unitList = modUnitList
      else
        selectedDept.unitList = modUnitList

      for dept, index in departmentList
        if dept.name is selectedDept.name
          departmentList[index] = selectedDept

      @set 'departmentList', departmentList




          



  navigatedIn: ->
    # currentOrganization = @getCurrentOrganization()
    # unless currentOrganization
    #   return @domHost.navigateToPage "#/select-organization"
      
    @_loadUser()
    # @_getPrivilegedFeatureList()
    
    params = @domHost.getPageParams()
    if params['organization']
      @_loadOrganization params['organization']
      @_loadPatientStayObject params['organization']
      
    else
      @_notifyInvalidOrganization()
    
    

  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false
    @memberSearchResultList = []
    @memberList = []

  searchMemberOrganizationTapped: (e)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      searchString: @memberOrganizationSearchString
      overrideWithIdList: []
    }
    @callApi '/bdemr-organization-find-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'memberSearchResultList', response.data.matchingUserList

  _loadOrganization: (idOnServer)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        @set 'organization', response.data.matchingOrganizationList[0]

        console.log @organization
        @set 'isOrganizationValid', true
        @_loadRoleList response.data.matchingOrganizationList[0]
        @_loadMemberList()
        


  _loadMemberList: ->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      overrideWithIdList: (user.id for user in @organization.userList)
      searchString: 'N/A'
    }
    @callApi '/bdemr-organization-get-users', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'memberList', response.data
        console.log 'member list', @memberList
        @_getMemberListByRole(@memberList, @organization)

  addMemberTapped: (e)->
    { member } = e.model
    @_callAddMemberApi member, =>
      null
  
  _callAddMemberApi:(member, cbfn)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: member.idOnServer
    }
    @callApi '/bdemr-organization-add-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'User Added'
        @splice 'memberSearchResultList', (@memberSearchResultList.indexOf member), 1
        params = @domHost.getPageParams()
        @_loadOrganization params['organization']
        cbfn()


  removeMemberTapped: (e)->
    { member } = e.model
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: member.idOnServer
    }
    @callApi '/bdemr-organization-remove-user', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'User Removed'
        params = @domHost.getPageParams()
        @_loadOrganization params['organization']

  $isAdmin: (userId, userList)->
    for user in userList
      if userId is user.id
        return user.isAdmin

  _setUserPrivilege: (member, shouldBeAdmin)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: member.idOnServer
      shouldBeAdmin: shouldBeAdmin
    }
    @callApi '/bdemr-organization-set-user-privilege', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'User Access Updated'
        params = @domHost.getPageParams()
        @_loadOrganization params['organization']

  makeAdminTapped: (e)->
    { member } = e.model
    @_setUserPrivilege member, true

  makeRegularUserTapped: (e)->
    { member } = e.model
    @_setUserPrivilege member, false


  ## Role Manager - start

  _makePreListedRoles:()->
    preListedRoles = [
      {
        title: 'Front desk officer'
        serialList: ['D001','D002','D003','D009','D011','D012','D015','D020','D022','D023']
      }
      {
        title: 'Doctor'
        serialList: ['D001','D002','D003','D009','D011','D012','D015','D020','D022','D023','D014','D017']
      }
      {
        title: 'Doctor Assistant'
        serialList: ['D001','D002','D003','D009','D011','D012','D015','D020','D022','D023','D014','D017']
      }
      {
        title: 'Nurse'
        serialList: ['D001','D002','D003','D009','D011','D012','D015','D020','D022','D023','D014', 'D004']
      }
      {
        title: 'Accounts'
        serialList: [ 'D018','D019','D020','D021','D022','D024','D026','D027']
      }
      {
        title: 'General User with Chamber Manager'
        serialList: ['D003']
      }
    ]

    @set 'preListedRoles', preListedRoles
  
  _getPrivilegedFeatureList: (cbfn)->
    data =
      apiKey: @user.apiKey

    @callApi '/get-privileged-feature-list', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'privilegeList', response.data
        cbfn()
   

  _loadRoleList: (org)->
    if typeof org.roleList is 'undefined'
      @set 'roleList', []
    else
      @set 'roleList', @organization.roleList

    console.log @roleList
  
  _makeNewRole: ()->

    @role = 
      type: ''
      title: ''
      serial: null
      privilegeList: []
      userList: []

  _makeRoleType: (str)->
    converToStr = str.toString()
    lowerCaseStr = converToStr.toLowerCase()
    replaced = str.split(' ').join('-');
    return replaced

  saveRole: (object)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      roleObject: object
    }
    @callApi '/bdemr-organization-add-role', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'Role Added!'
        params = @domHost.getPageParams()
        @_makeNewRole()
        @_loadOrganization params['organization']
        @$$('#dialogAddRole').close()

  _onPreListedRoleTap:(e)->

    selectedIndex = e.model.index
    role = @preListedRoles[selectedIndex]

    modifiedPrivilegeList = []
    # console.log privilegeList
    for item, index in @privilegeList
      if item.serial in role.serialList
        item.isSelected = true
        @$$('#'+ item.serial ).checked = true
      else
        item.isSelected = false
        @$$('#'+ item.serial ).checked = false

      modifiedPrivilegeList.push item
    
    @privilegeList = modifiedPrivilegeList

    @set 'role.title', role.title

  showAddRoleDialog: ()->
    @set 'ROLE_EDIT_MODE', false
    @_getPrivilegedFeatureList =>
      @_makePreListedRoles()
      @_makeNewRole()
      @$$('#dialogAddRole').toggle()
      

  filterPrivilegeList: ()->
    selectedItemSerialList = []
    for item in @privilegeList
      if item.isSelected
        selectedItemSerialList.push item

    return selectedItemSerialList

  addRole: ()->
    if (@role.title is null) or (@role.title is '')
      @domHost.showToast 'Type Role Title!'
      return
    else
      @role.type =  @role.title
      @role.privilegeList = @filterPrivilegeList()
      @role.serial = @generateSerialForOrgRole()
      console.log 'ROLE', @role
      @saveRole @role
  
  getSelectedRolePrevilizedList: (cbfn)->
    serialMap = @role.privilegeList.map (item) => (item.serial)

    modifiedPrivilegeList = []
    for item, index in @privilegeList
      if item.serial in serialMap
        item.isSelected = true
      modifiedPrivilegeList.push item
    
    @privilegeList = modifiedPrivilegeList
    
    cbfn()

  showEditRoleDialog: (e)->
    index = e.model.index
    @role = @roleList[index]
    console.log @role
    @_getPrivilegedFeatureList =>
      @_makePreListedRoles()
      @getSelectedRolePrevilizedList =>
        @$$('#dialogAddRole').toggle()
        @set 'ROLE_EDIT_MODE', true

  editRole: (e)->
    if (@role.title is null) or (@role.title is '')
      @domHost.showToast 'Type Role Title!'
      return
    
    @role.privilegeList = @filterPrivilegeList()
    @updateRole @role
    


  updateRole: (role)->
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      roleObject: role
    }
    @callApi '/bdemr-organization-update-role', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'Role Updated!'
        params = @domHost.getPageParams()
        @_makeNewRole()
        @_loadOrganization params['organization']
        @set 'ROLE_EDIT_MODE', false
        @$$('#dialogAddRole').close()


  showDialogForSetRole: (e)->
    { member } = e.model
    
    @set 'selectecMemberId', member.idOnServer

    roleTitle = @_getRoleTitleForUser member.idOnServer

    @set 'selectedRoleTypeForUser', roleTitle

    @$$('#dialogSetRoleForUser').toggle()

  # setRoleForUserValueChanged: (e)->
  #   console.log 'selectedRoleIndex', @selectedRoleIndex
  #   @selectedRoleTypeForUser = @roleList[@selectedRoleIndex].type
    

  setRoleForUser: (e)->
    { member } = e.model
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      targetUserId: @selectecMemberId
      roleType: @selectedRoleTypeForUser
    }
    @callApi '/bdemr-organization-set-user-on-specific-role', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'User Role Added.'
        params = @domHost.getPageParams()
        @_loadOrganization params['organization']
        @$$('#dialogSetRoleForUser').close()

  removeRole:(e)->
    role = @roleList[e.model.index]
    data = { 
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      roleObject: role
    }
    @callApi '/bdemr-organization-remove-role', data, (err, response)=>
      console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showToast 'Role Removed!'
        params = @domHost.getPageParams()
        @_makeNewRole()
        @_loadOrganization params['organization']


  _getRoleTitleForUser: (userIdentifier)->
    roleTitle = ''

    if @roleList.length > 0
      for role in @roleList
        for user in role.userList
          if user.id is userIdentifier
            roleTitle = role.title
            return roleTitle
    else
      return roleTitle


  ## Role Manager - end

  ## Rolewise statistics for members - start

  _getMemberListByRole: (userList, organization)->
    console.log 'user list', userList
    console.log 'organization', organization

    organizationCopy = Object.assign {}, organization

    if organizationCopy.roleList?.length
      memberListByRole = organizationCopy.roleList

      for organizationRole in memberListByRole
        for user in organizationRole.userList
          for member in userList
            if user.id is member.idOnServer
              Object.assign(user, member)
  

      @set 'memberListByRole', memberListByRole
      console.log {memberListByRole}


  

  convertRoleNameToId: (roleType)-> roleType.toLowerCase().split(" ").join("")

  toggleCollapseClicked: (e)->
    roleType = @convertRoleNameToId e.model.role.type
    console.log roleType
    @$$("##{roleType}").toggle()
  
  _returnSerial: (index)->
    index+1
  ## Rolewise statistics for members - end

  makeAddNewMemberObject:(cbfn)->
    newMember =
      name: null
      phone: null
      repeatPhone: null
      email: null
      repeatEmail: null
      dateOfBirth: lib.datetime.mkDate lib.datetime.now()
      gender: ''
      profileImage: null
      nationalIdCardNumber: null
      organizationId: @organization.idOnServer
      password: '123456'
      doctorAccessPin: '0000'
      createdDatetimeStamp: lib.datetime.now()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer

      additionalPhoneNumber: null
      effectiveRegion: null
      bloodGroup: null
      allergy: null
      drugAllergy:
        value: null
        list: []
        
      emmergencyContact: 
        name: null
        relation: null
        phoneNumber: null

      addressList: [
        {
          addressTitle: 'Personal'
          addressType: 'personal'
          flat: null
          floor: null
          plot: null
          block: null
          road: null
          village: null
          addressUnion: null
          subdistrictName: null
          addressDistrict: null
          addressPostalOrZipCode: null
          addressCityOrTown: null
          addressLine1: null
          addressLine2: null
          stateOrProvince: null
          addressCountry: null
        }
      ]

      employmentDetailsList: []
      belongOrganizationList: []

      expenditure: null
      profession: null
      education: null

      patientSpouseName: null
      patientFatherName: null
      patientMotherName: null
      maritalAge: null
      maritalStatus: null
      numberOfFamilyMember: 0
      numberOfChildren: 0
      recordSpecificPatientIdList: []  
    @set 'newMember', newMember
    cbfn()

  showAddNewMemberDialog: ()->
    @makeAddNewMemberObject =>
      @$$('#dialogAddMember').toggle()

  
  addNewMember:()->
    unless @newMember.name and @newMember.dateOfBirth and @newMember.gender and @newMember.password
      @domHost.showToast 'Please fill up required fields'

    
    @newMember.name = @$makeNameObject @newMember.name
    @newMember.apiKey = @user.apiKey
    
    @callApi '/bdemr--organizaiton-add-new-member', @newMember, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        member = response.data
        @_callAddMemberApi member, =>
          @$$('#dialogAddMember').close()

  verifyUserProfilePressed: (e)->
    { member } = e.model
    @domHost.navigateToPage "#/view-user-profile/userId:" + member.idOnServer

}         
