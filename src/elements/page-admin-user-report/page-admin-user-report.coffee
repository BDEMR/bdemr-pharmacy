Polymer {
  is: 'page-admin-user-report'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    reports:
      type: Array
      value: []
    
    roles:
      type: Array
      value: ['Patient', 'Agent', 'Doctor', 'Student', 'Physician(Non BMDC)', 'Institution Admin', 'Doctor Assistant', 'Hospital/Clinic Staff', 'Nurse']
    
    
    filterBy:
      type: Object
      value: {
        role: null
        address: null
        fromDate: 0
        toDate: 0
      }
    
      
    activeItem:
      observer: '_activeItemChanged'
    
  

  _activeItemChanged: (e, item)->
    console.log {item}
 

  _callGetInventory:(filterBy, cbfn)->
    data =
      apiKey: @user.apiKey
      filterBy: filterBy

    @domHost.toggleModalLoader 'Loading Reports...'
    @domHost.callApi '/bdemr-filter-user-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        data = response.data
        @set 'reports', data
        cbfn()     
  

  onFilterTapped: ()->
    @_callGetInventory @filterBy, => null 
  
  onClearFilterTapped: ()->
    @set 'filterBy', {
      role: null
      address: null
      fromDate: 0
      toDate: 0
    }

    @_callGetInventory @filterBy, => null
  

  navigatedIn: ->
    # @_callGetInventory @filterBy, => null 

    

} 