Polymer {
  is: 'page-compare-unit-price'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    matchingItemKeys:
      type: Array
      value: []
    
    districtlist:
      type: Array
      value: -> [
        "Barguna",
        "Barisal",
        "Bhola",
        "Jhalokati",
        "Patuakhal",
        "Pirojpur",
        "Bandarban",
        "Brahmanbaria",
        "Chandpur",
        "Chittagong",
        "Comilla",
        "Cox's Bazar",
        "Feni",
        "Khagrachhari",
        "Lakshmipur",
        "Noakhali",
        "Rangamati",
        "Dhaka",
        "Faridpur",
        "Gazipur",
        "Gopalganj",
        "Kishoreganj",
        "Madaripur",
        "Manikganj",
        "Munshiganj",
        "Narayanganj",
        "Narsingdi",
        "Rajbari",
        "Shariatpur",
        "Tangail ",
        "Bagerhat",
        "Chuadanga",
        "Jessore",
        "Jhenaidah",
        "Khulna",
        "Kushtia",
        "Magura",
        "Meherpur",
        "Narail",
        "Satkhira",
        "Jamalpur",
        "Mymensingh",
        "Netrakona",
        "Sherpur",
        "Bogra",
        "Joypurhat",
        "Naogaon",
        "Natore",
        "Nawabganj",
        "Pabna",
        "Rajshahi",
        "Sirajganj",
        "Dinajpur",
        "Gaibandha",
        "Kurigram",
        "Lalmonirhat",
        "Nilphamari",
        "Panchagarh",
        "Rangpur",
        "Thakurgaon",
        "Habiganj",
        "Moulvibazar",
        "Sunamganj",
        "Sylhet"
      ]

    hideAuthorColumn:
      type: Boolean
      value: true
      
    categoryList:
      type: Array
      value: []
    
    organizationList:
      type: Array
      value: []
    
    matchingResults:
      type: Array
      value: -> []
    
    loading:
      type: Boolean
      value: false

    filterBy:
      type: Object
      value: {
        name: ''
        effectiveRegion: ''
        address: ''
        category: ''
        organizationId: ''
      }
    
    searchQuery:
      type: String
      value: -> ''
      observer: 'itemSearchInputChanged'
    
    activeItem:
      observer: '_activeItemChanged'
    
    product:
      type: Object
      value: {}
    
    hideEditForm:
      type: Boolean
      value: true

  categorySelected: (e) ->
    return if !e.detail.value
    category = e.detail.value
    if @isThatBookCategory category
      return @set 'hideAuthorColumn', false
    @set 'hideAuthorColumn', true
  
  isThatBookCategory: (categoryName)->
    list = ['গল্প','প্রবন্ধ','উপন্যাস','ভ্রমণ কাহিনী','রম্য রচনা','বই','ইসলামি বই', 'আত্ম উন্নয়ন', 'একুশে বইমেলা', "একশে বই মেলা","একুশ বই মেলা","একুশে ব মেলা","একুশে বই  মেলা","একুশে বই বেলা","একুশে বই মেলা","একুশে বই মেলা (কবিতা)","একুশে বয়োই মেলা","এখুশে বই মেলা","ছোটদের মুক্তিযুদের অজানা গল্প","তেল সারা পরোটা","তেল সারা পড়াটা","পরোটা","পৃথিবীর বিস্ময়কর সপ্তাশ্চর্য","বই","বিরিয়ানি","বয়োই","ভাত","রুটি","সিসিমপুর","ীকুশে বই মেলা"]
    return list.some (name) => name is categoryName

  _closeModalView: ()->
    hideEditForm = @hideEditForm
    @set 'hideEditForm', !hideEditForm
  
  _activeItemChanged: (item)->
    console.log item
    copyItem = lib.util.deepCopy item

    if copyItem
      # @set 'ARBITARY_INDEX', index
      @set 'hideEditForm', false
      @set 'product', copyItem
    else
      @set 'hideEditForm', true

  _getCategoryIcon: (category)->
    src = "../../images/icons/"
    defaultIcon = "ico_default_item.png"
    return src + defaultIcon if !category
       
    switch category
      when 'medicine' then src += 'ico_medicine.png'
      else src += defaultIcon
    
    return src

        
  _onSelectedItemChanged: (e)->
    return if !e.detail.value
    console.log e
    @filterBy.name = e.detail.value

    @_callGetCompareItemBetweenOrganizations @filterBy, =>
      null
  
  
  itemSearchInputChanged: (searchQuery)->
    @set 'matchingItemKeys', []
    unless searchQuery.length > 1
      return
    
    @_callGetMatchingKeywords searchQuery

  _callGetMatchingKeywords:(searchQuery)->
    console.log @$$('#ItemSearch').items
    data =
      organizationId: @filterBy.organizationId
      searchQuery: searchQuery

    @fetchingInventorySearchResult = true
    @domHost.callApi '/bdemr-get-matching-item-keywords', data, (err, response)=>
      @fetchingInventorySearchResult = false
      if response.hasError
        @domHost.showWarningToast response.error.message
      else
        data = response.data
        @set 'matchingItemKeys', data


  _callGetCompareItemBetweenOrganizations:(filterBy, cbfn)->
    data =
      filterBy: filterBy

    @set 'loading', true
    @set 'matchingResults', []
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-compare-items-between-organizations', data, (err, response)=>
      @set 'loading', false
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showToast "No Product Found!"
        cbfn()
      else
        data = response.data
        @set 'matchingResults', data
        cbfn()
  
  _callGetAllProductCategories:(cbfn)->
    @domHost.toggleModalLoader 'Loading all categories...'
    @domHost.callApi '/bdemr-get-all-product-categories', {}, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        console.log response.error.message
        # @set 'categoryList', []
      else
        data = response.data
        @set 'categoryList', data.uniqCategoryList
        cbfn()
  
  _callGetAllOrganizationList:()->
    @domHost.toggleModalLoader 'Loading all organization...'
    @domHost.callApi '/bdemr-get-all-organization-names', {}, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        console.log response.error.message
      else
        data = response.data.organizationList
        @set 'organizationList', data
  
  _searchForMatchingItems: ()->
    console.log {@filterBy}
    unless @filterBy.category.length > 1 or @filterBy.name.length > 1 or @filterBy.organizationId.length > 0
      @domHost.showToast 'Please select Organization/Category/Type Product name!'
      return

    @_callGetCompareItemBetweenOrganizations @filterBy, =>
      null

  _onTapClearCategoryFilter: ()->
    @set 'filterBy.category', ''
    @_searchForMatchingItems()
  
  _onTapClearEffectiveRegionFilter: ()->
    @set 'filterBy.effectiveRegion', ''
    @_searchForMatchingItems()
  
  _onTapClearLocationFilter: ()->
    @set 'filterBy.address', ''
    @_searchForMatchingItems()
  
  _onTapSearch: ()->
    @_searchForMatchingItems()
  
  _onfilterModalConfirm: ()->
    if @filterBy.name.length < 2
      @$$("#filterModal").toggle()
      return

    @_callGetCompareItemBetweenOrganizations @filterBy, =>
      @$$("#filterModal").toggle()
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _goLoginPage: (e)->
    @domHost.navigateToPage '#/login'
  
  editorHasOpened: (hasOpened)->
    # console.log hasOpened
    if hasOpened
      return ''
    return 'open'

  
  _onfilterModalClearAll: ()->
    filterBy = 
      name: @filterBy.name
      effectiveRegion: ''
      address: ''
      category: ''
      organizationId: ''

    @set 'filterBy', filterBy

    @set 'matchingResults', []

    @$$("#filterModal").toggle()
  
  _showFilterOptions: ()->
    @$$("#filterModal").toggle()


  navigatedIn: ->
    @_callGetAllProductCategories =>
      @_callGetAllOrganizationList()
    

} 