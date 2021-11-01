Polymer {
  is: 'page-ambulance-manager'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    EDIT_MODE:
      type: Boolean
      value: false
    
    selectedPageIndex:
      type: Number
      value: 0
      observer: '_selectedPageIndexChanged'

    hideEditForm:
      type: Boolean
      value: true

    EDIT_MODE:
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
    
    ambulance:
      type: Object
      value: null
    
    matchingAmbulance:
      type: Array
      value: []
    
    activeItem:
      observer: '_activeItemChanged'
  

  _selectedPageIndexChanged: (index)->
    @user = (app.db.find 'user')[0]
    @organization = (app.db.find 'organization')[0]
    isAvailable = true
    if index is 1
      isAvailable = false
      @_callGetAmbulanceList isAvailable
    else
      @_callGetAmbulanceList isAvailable
    

  editorHasOpened: (hasOpened)->
    # console.log hasOpened
    if hasOpened
      return ''
    return 'open'
  
  _closeEditForm: ()->
    hideEditForm = @hideEditForm
    @set 'hideEditForm', !hideEditForm

  addAmbulanceBtnPressed: ()->
    @_resetAmbulanceObject()
    @set 'hideEditForm', false

  _resetAmbulanceObject: ()->
    ambulance =
      organizationId: @organization.idOnServer
      lastModifiedByUserId: @user.idOnServer
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      label: ''
      regNumber: ''
      modelName: ''
      isOxizenAvailable: false
      isAvailable: true
      driverPhoneNumber: ''
      driverName: ''
      driverNID: ''
      driverPhoto: ''
      bookingHistory: []

    @set 'ambulance', ambulance
    @set 'EDIT_MODE', false
  

  _insertBooking: ()->
    path = "ambulance.bookingHistory"
    @push path, {
      bookedPersonName: ''
      bookedPersonPhoneNumber: ''
      pickupPointAddress: ''
      dropoffPointAddress: ''
      assignedDriverName: @ambulance.driverName
      assignedDriverPhoneNumber: @ambulance.driverPhoneNumber
      createdByUserId: @user.idOnServer
      createdDatetimeStamp: lib.datetime.now()
      isActive: false
    }
  
  _deleteBookingHistory: (e)->
    
    index = e.model.index
    console.log e, index
    @splice "ambulance.bookingHistory", index, 1

 
  _activeItemChanged: (item)->
    copyItem = lib.util.deepCopy item

    if copyItem
      # @set 'ARBITARY_INDEX', index
      @set 'hideEditForm', false
      @set 'EDIT_MODE', true
      @set 'ambulance', copyItem
    else
      @set 'hideEditForm', true
  
  _callGetAmbulanceList:(isAvailable)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      isAvailable: isAvailable
      
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-organization-ambulance', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'matchingAmbulance', []
      else
        @set 'matchingAmbulance', response.data
  

  _deleteAmbulance: (e)->
    if @ambulance._id
      @_callDeleteAmbulanceApi @ambulance._id, =>
        @splice 'matchingAmbulance', @ARBITARY_INDEX, 1
        @_closeEditForm()
    else
      @splice 'matchingAmbulance', @ARBITARY_INDEX, 1
  
  _callDeleteAmbulanceApi: (ambulanceId, cbfn)->
    data = 
      apiKey: @user.apiKey
      ambulanceId: ambulanceId
      organizationId: @organization.idOnServer

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-delete-ambulance', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log response
      if response.hasError
        console.log response.error.message
      else
        message = response.data.message
        if message is "DELETE_SUCCESS"
          @domHost.showToast 'Ambulance Data has been Deleted!'

        cbfn()
  
  _toggleAvailability: ()->
    @set 'ambulance.isAvailable', !@ambulance.isAvailable
    
  _addOrUpdateBtnPressed: (e)->
    console.log @ambulance
    unless @ambulance.regNumber
      @domHost.showToast 'Ambulance Registation Number is requried!'
      return 

    @_callSetAmbulance @ambulance,  =>
      @_closeEditForm()

      if @selectedPageIndex is 0
        @_callGetAmbulanceList true
      if @selectedPageIndex is 1
        @_callGetAmbulanceList false

  _callSetAmbulance: (ambulance, cbfn)->
    data = {}
    data = ambulance
    data.apiKey = @user.apiKey

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-set-ambulance', data, (err, response)=>
      @domHost.toggleModalLoader()
      cbfn()
  
  
  
    
  navigatedIn: ->

    

} 