Polymer {
  is: 'page-organization-reports'
  
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
    
    organizationType:
      type: Array
      value: ['Hospital', 'Shop', 'Pharmacy', 'Chamber', 'Other']
    
    filterBy:
      type: Object
      value: {
        type: null
        name: null
        address: null
        fromDate: null
        toDate: null
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
    @domHost.callApi '/bdemr-filter-organization-list', data, (err, response)=>
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
      type: 'Hospital'
      name: null
      address: null
      fromDate: null
      toDate: null
    }

    @_callGetInventory @filterBy, => null
  

  navigatedIn: ->
    # @_callGetInventory @filterBy, => null 

    

} 