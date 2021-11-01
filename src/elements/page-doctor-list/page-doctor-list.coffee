Polymer {
  is: 'page-doctor-list'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    selectedPageIndex:
      type: Number
      value: 0
      observer: 'observeSelectedPageIndex'
    
    isPrivileged:
      type: Boolean
      value: false

    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
      
  
  observeSelectedPageIndex: (index)->
    console.log {index}
    return if !@user or !@organization
    @_callGetUnverifiedDoctorList() if index is 1
    @_callGetVerifiedDoctorList() if index is 0
    @_callGetFlaggedDoctorList() if index is 2

  _formatAddress: (list)->
    return '' if !list
    return '' if list.length is 0
    address = list[0]
    return (address.addressLine1 or '') + ' ' + (address.addressLine1 or '')

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _callGetUnverifiedDoctorList: ()->
    data =
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/get-unverified-doctor-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'unverifiedDoctors', []
        # if response.error.message is 'ACCESS_DENIED'
        #   @domHost.showModalDialog "Only verified doctor can access this page."
        #   return
      else
        @set 'unverifiedDoctors', response.data.unverifiedDoctorList
        @set 'isPrivileged', response.data.isPrivileged
  
  _callGetVerifiedDoctorList: ()->
    data =
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/get-verified-doctor-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'verifiedDoctors', []
      else
        @set 'verifiedDoctors', response.data
  
  _callGetFlaggedDoctorList: ()->
    data =
      apiKey: @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/get-flagged-doctor-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'flaggedDoctors', []
      else
        @set 'flaggedDoctors', response.data
  
  _callVerifyDoctorRoleByBmdcNumber: (doctorId, bmdcFlaggedAsError, cbfn)->
    data =
      apiKey: @user.apiKey
      doctorId: doctorId
      bmdcFlaggedAsError: bmdcFlaggedAsError

    @domHost.toggleModalLoader 'Verifying...'
    @domHost.callApi '/verify-doctor-role-by-bmdc-number', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog "Only verified doctor can access this page."
        return
      else
        @domHost.showToast 'Success!'
        cbfn()

  _verifyDoctor: (e)->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      index = e.model.index
      doctorId = @unverifiedDoctors[index].idOnServer

      @_callVerifyDoctorRoleByBmdcNumber doctorId, false, =>
        @_callGetUnverifiedDoctorList()
  
  _flagAsError: (e)->
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      index = e.model.index
      doctorId = @unverifiedDoctors[index].idOnServer

      @_callVerifyDoctorRoleByBmdcNumber doctorId, true, =>
        @_callGetUnverifiedDoctorList()


  navigatedIn: ->
    console.log @selectedPageIndex
    @_callGetVerifiedDoctorList() if @selectedPageIndex is 0
    @_callGetUnverifiedDoctorList() if @selectedPageIndex is 1

} 