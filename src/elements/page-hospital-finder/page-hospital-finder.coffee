Polymer {
  is: 'page-hospital-finder'
  
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


  _callBdemrOrganizationFindPublicSummary:(filterBy, cbfn)->
    data =
      filterBy: filterBy

    @set 'loading', true
    @set 'matchingResults', []
    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/bdemr-organization-find-public-summary-rev-2', data, (err, response)=>
      @set 'loading', false
      @domHost.toggleModalLoader()
      if response.hasError
        @set 'matchingResults', data.organizationList
        @domHost.showToast "No Result Found!"
        cbfn()
      else
        data = response.data
        @set 'matchingResults', data.organizationList
        cbfn()
  
  _onTapSearch: ()->
    @_callBdemrOrganizationFindPublicSummary @filterBy, => null
  
  editorHasOpened: (hasOpened)->
    # console.log hasOpened
    if hasOpened
      return ''
    return 'open'

  
  _resetFilter: ()->
    filterBy = {
      name: ''
      effectiveRegion: ''
      address: ''
      otherFacilities: [
        {
          label:"Emergency Facilities",
          key: "emergencyFacilities",
          isChecked: false
        }
        {
          label: "AC Available",
          key: "acAvailable",
          isChecked: false
        }
        {
          label: "Online Appointment"
          key: "onlineAppointment",
          isChecked: false
        }
        {
          label:"Cabin Available",
          key: "cabinAvailable",
          isChecked: false
        }
        {
          label:"Advanced Patient Monitoring Cardiac",
          key: "advancedPatientMonitoringCardiac",
          isChecked: false
        }
        {
          label: "Anaesthesia Machine",
          key: "anaesthesiaMachine",
          isChecked: false
        }
        {
          label: "Histo Pathology Facility",
          key: "histoPathologyFacility",
          isChecked: false
        }
        {
          label: "MRI Facility",
          key: "mriFacility",
          isChecked: false
        }
        {
          label: "CT Scan Facility",
          key: "ctScanFacility",
          isChecked: false
        }
        {
          label: "Ultrasound Facility", 
          key: "ultrasoundFacility",
          isChecked: false
        }
        {
          label: "Pathology Facility",
          key: "pathologyFacility",
          isChecked: false
        }
        {
          label: "Blood Transfusion Facility",
          key: "bloodTransfusionFacility",
          isChecked: false
        }
        {
          label: "Ambulance Facility",
          key: "ambulanceFacility",
          isChecked: false
        }
        {
          label: "Labour Delivery",
          key: "labourDelivery",
          isChecked: false
        }
        {
          label: "Operation Facility",
          key: "operationFacility",
          isChecked: false
        }
      ]
    }

    @set 'filterBy', filterBy

    @set 'matchingResults', []
  

  navigatedIn: ->
    @set 'districtlist', @_getDistrictList()
    @_resetFilter()
    

} 