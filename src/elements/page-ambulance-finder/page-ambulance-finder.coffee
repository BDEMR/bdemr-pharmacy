Polymer {
  is: 'page-ambulance-finder'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    districtlist:
      type: Array
      value: null

    matchingResults:
      type: Array
      value: -> []
    
    loading:
      type: Boolean
      value: false

    filterBy:
      type: Object
      value: {}
    
    activeItem:
      observer: '_activeItemChanged'
    
    organization:
      type: Object
      value: {}
    
    hideEditForm:
      type: Boolean
      value: true

  _closeModalView: ()->
    hideEditForm = @hideEditForm
    @set 'hideEditForm', !hideEditForm

  _callGetAllOrganizationList:()->
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-get-all-organization-names', {}, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        console.log response.error.message
      else
        data = response.data.organizationList
        @set 'organizationList', data

  _getDistrictList: ()->
    list = [
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
    return list.sort()

  _activeItemChanged: (item)->
    console.log item
    copyItem = lib.util.deepCopy item

    if copyItem
      # @set 'ARBITARY_INDEX', index
      @set 'hideEditForm', false
      @set 'organization', copyItem
    else
      @set 'hideEditForm', true


  _callBdemrOrganizationFindPublicAmbulanceService:(cbfn)->
    data =
      filterBy: @filterBy

    # @set 'loading', true
    @set 'matchingResults', []
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-organization-find-public-ambulance-service', data, (err, response)=>
      # @set 'loading', false
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'matchingResults', []
        @domHost.showToast "No Result Found!"
      else
        data = response.data
        @set 'matchingResults', data
      cbfn()
  
  _onTapSearch: ()->
    unless @filterBy.address or @filterBy.organizationId
      @domHost.showToast 'Please search by location or hospital atleast!'
      return
    @_callBdemrOrganizationFindPublicAmbulanceService => null
  
  editorHasOpened: (hasOpened)->
    # console.log hasOpened
    if hasOpened
      return ''
    return 'open'

  
  _resetFilter: ()->
    filterBy = {
      organizationId: ''
      effectiveRegion: ''
      address: ''
      isOxizenAvailable: false
    }

    @set 'filterBy', filterBy

    @set 'matchingResults', []
  

  navigatedIn: ->
    @_resetFilter()
    # @_callBdemrOrganizationFindPublicAmbulanceService =>
    @set 'districtlist', @_getDistrictList()
    @_callGetAllOrganizationList()
      
    

} 