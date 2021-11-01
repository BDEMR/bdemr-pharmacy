Polymer {
  is: 'page-organization-unit-price-public'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    inventory:
      type: Array
      value: []

    categories:
      type: Array
      value: []
    
    
    selectedCategory:
      type: String
      value: ''
    
    filterBy:
      type: Object
      value: {
        category: null
        fromDate: null
        toDate: null
      }
    
    
    activeItem:
      observer: '_activeItemChanged'
  

  categorySelected: (e) ->
    if (this.categories && this.categories.length > 0)
      category = e.detail.value
      if category is 'investigation'
        @set 'product.investigationList', category.investigationList
  
    

  _activeItemChanged: (item)->
    if (this.inventory && this.inventory.length > 0)
      this.$.list.selectedItems = [item] or [];

  
  _callGetInventory:(filterBy, cbfn)->
    # data =
    #   organizationId: "5d26fec24aa750c026721989" ## @organization.idOnServer
    #   filterBy: filterBy

    # @domHost.toggleModalLoader 'Please wait...'
    # @domHost.callApi '/bdemr-get-organization-inventory--public', data, (err, response)=>
    #   @domHost.toggleModalLoader()
    #   if response.hasError
    #     @domHost.showWarningToast response.error.message
    #   else
    #     data = response.data
    #     @set 'inventory', data
    #     cbfn()

  onFilterTapped: ()->
    @_callGetInventory @filterBy, =>
      @_resetProductObject()
  
  onClearFilterTapped: ()->
    @set 'filterBy', {}
    @_callGetInventory @filterBy, => null
  


  navigatedIn: ->
    @_callGetInventory @filterBy, =>
      @_getCategories()
      @_resetProductObject()

    

} 