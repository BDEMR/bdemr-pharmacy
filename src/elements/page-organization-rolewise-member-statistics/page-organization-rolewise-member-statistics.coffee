
Polymer {

  is: 'page-organization-rolewise-member-statistics'

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

    isOrganizationValid: 
      type: Boolean
      notify: true
      value: false

    organization:
      type: Object
      notify: true
      value: null

    memberList:
      type: Array
      value: -> []

    matchingPatientList:
      type: Array
      value: -> []

    memberWiseRoleCounter:
      type: Array
      value: ->[]


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _notifyInvalidOrganization: ->
    @isOrganizationValid = false
    @domHost.showModalDialog 'Invalid Organization Provided'

  generateRandomString : ( randomStringLength ) ->
    randomString = ''
    characterList = []
    for item in [0..25]
      characterList.push String.fromCharCode( 'a'.charCodeAt() + item )
    for item in [0..25]
      characterList.push String.fromCharCode( 'A'.charCodeAt() + item )
    for item in [0..9]
      characterList.push String.fromCharCode( '0'.charCodeAt() + item )

    len = characterList.length
    for item in [ 1..randomStringLength ]
      idx = ( Math.floor ( Math.random() * 10000363 ) ) % 10000019
      idx %= len
      randomString += characterList[ idx ]

    return randomString


  _checkOrAndCreateSerialForWard: (object, cbfn)->
    deptList = object.departmentList
    unless deptList.length is 0
      for dept in deptList
        if dept.unitList?.length > 0
          unitList = dept.unitList
          for unit in unitList
            if unit.wardList?.length > 0
              wardList = unit.wardList
              for ward in wardList
                if typeof ward.wardId is 'undefined'
                  ward.wardId = @generateRandomString 4
                if typeof ward.assignedUserList is 'undefined'
                  ward.assignedUserList = []

    object.departmentList = deptList

    cbfn object
    return

  navigatedIn: ->
    
    @_loadUser()
    
    params = @domHost.getPageParams()
 
    @_loadOrganization params['organization'], =>
      console.log 'organization', @organization

    
  navigatedOut: ->
    @organization = null
    @isOrganizationValid = false
    @memberList = []

  _loadOrganization: (idOnServer, cbfn)->
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
        @_loadMemberList()
        # @_loadPatientList()
        cbfn()


  _loadMemberList: ->
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
        @_computeCountOfMemberRoles()

  _computeCountOfMemberRoles: ()->
    doctorCounter = 0
    physicianNonBmdcCounter = 0
    studentCounter = 0
    agentCounter = 0
    doctorAssistantCounter = 0
    clinicOwnerCounter = 0
    clinicStaffCounter = 0
    nurseCounter = 0
    for member in @memberList
      for role in member.roleList
        if role.roleName is 'doctor' and role.isActivated is true
          doctorCounter++
        if role.roleName is 'physician-non-bmdc' and role.isActivated is true
          physicianNonBmdcCounter++
        if role.roleName is 'student' and role.isActivated is true
          studentCounter++
        if role.roleName is 'agent' and role.isActivated is true
          agentCounter++
        if role.roleName is 'doctor-assistant' and role.isActivated is true
          doctorAssistantCounter++
        if role.roleName is 'clinic-owner' and role.isActivated is true
          clinicOwnerCounter++
        if role.roleName is 'clinic-staff' and role.isActivated is true
          clinicStaffCounter++
        if role.roleName is 'nurse' and role.isActivated is true
          nurseCounter++


    roleWiseCounter = {
      doctor: doctorCounter
      physicianNonBmdc: physicianNonBmdcCounter
      student: studentCounter
      agent: agentCounter
      doctorAssistant: doctorAssistantCounter
      clinicOwner: clinicOwnerCounter
      clinicStaff: clinicStaffCounter
      nurse: nurseCounter
      
    }
    @set 'roleWiseCounter', roleWiseCounter

  _roleCheckOfTheMembers: (member, roleName)->
    for role in member.roleList
      if role.roleName is roleName and role.isActivated is true
        return true
    return false
   
  toggleDoctorList: (e)-> @$$("#doctorList").toggle()
  toggleNurseList: (e)-> @$$("#nurseList").toggle()
  togglPhysicianNonBmdcList: (e)-> @$$("#physicianList").toggle()
  toggleClincStaffListt: (e)-> @$$("#clinicStaffList").toggle()
  toggleClinicOwnerList: (e)-> @$$("#clinicOwnerList").toggle()
  toggleStudentList: (e)-> @$$("#studentList").toggle()
  toggleAgentList: (e)-> @$$("#agentList").toggle()
  toggleDoctorAssistantList: (e)-> @$$("#doctorAssistantList").toggle()

  $isAdmin: (userId, userList)->
    for user in userList
      if userId is user.id
        return user.isAdmin

  _loadWardForThisOrganization: ()->
    console.log '_loadWardForThisOrganization'

  showDialogForAssignWard: (e)->
    { member } = e.model
    
    @set 'selectecMemberId', member.idOnServer

    @$$('#dialogAssigningWard').toggle()

  ## Assigning Ward - end

}
