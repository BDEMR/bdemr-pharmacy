
###
  app.pages
###

app.pages = {}

app.pages.pageList = [
 {
    name: 'dashboard'
    element: 'page-dashboard'
    windowTitlePostfix: 'Dashboard'
    headerTitle: 'Dashboard'
    preload: true
    hrefList: [ 'dashboard' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'none'
    showOnSideNav: false
    index: 1
    icon: 'dashboard'
  }
  #  {
  #   name: 'patients-list'
  #   element: 'page-patients-list'
  #   windowTitlePostfix: 'Patients List'
  #   headerTitle: 'Patients List'
  #   preload: true
  #   hrefList: [ 'patients-list' ]
  #   requireAuthentication : true
  #   headerType: 'normal'
  #   leftMenuEnabled: true
  #   showPatientsDetails: false
  #   showToolbar: true
  #   accessId: 'none'
  #   showOnSideNav: false
  #   index: 1
  #   icon: 'view-list'
  # }
   {
    name: 'agent-bookings'
    element: 'page-agent-bookings'
    windowTitlePostfix: 'Agent Booking'
    headerTitle: 'Agent Booking'
    preload: true
    hrefList: [ 'agent-bookings' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'none'
    showOnSideNav: false
    index: 1
    icon: 'view-list'
  } 
  {
    name: 'visit-preview'
    element: 'page-visit-preview'
    windowTitlePostfix: 'Visit Preview'
    headerTitle: 'Visit Preview'
    preload: true
    hrefList: [ 'visit-preview' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    hideAd: false
    showPrintButton: true
    showToolbar: true
    index:1
    hideHeaderTitle: false
    accessId:'none'
  }
  {
    name: 'activate'
    element: 'page-activate'
    windowTitlePostfix: 'Activate'
    headerTitle: 'Activate Code'
    preload: true
    hrefList: [ 'activate' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    hideHeaderTitle: false
    removeToolbar: true
  }
  {
    name: 'login'
    element: 'page-login'
    windowTitlePostfix: 'Login'
    headerTitle: 'Clinic App'
    preload: true
    hrefList: [ 'login' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    accessId: 'none'
  }
  {
    name: 'patient-signup'
    element: 'page-patient-signup'
    windowTitlePostfix: 'patient-signup'
    headerTitle: 'Patient Signup'
    preload: true
    hrefList: [ 'patient-signup' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
  }
  {
    name: 'patient-manager'
    element: 'page-patient-manager'
    windowTitlePostfix: 'Patient Manager'
    headerTitle: 'Patient Manager'
    preload: true
    hrefList: [ 'patient-manager' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D001'
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'account-box'
    index: 2
  }
  {
    name: 'chamber-manager'
    element: 'page-chamber-manager'
    windowTitlePostfix: 'Chamber Manager'
    headerTitle: 'Chamber Manager'
    preload: true
    hrefList: [ 'chamber-manager' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D003'
    showOnSideNav: false
    icon: 'date-range'
    index: 89
  }

  {
    name: 'create-operation-list'
    element: 'page-create-operation-list'
    windowTitlePostfix: 'OT List'
    headerTitle: 'OT List'
    preload: true
    hrefList: [ 'create-operation-list' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
  }

  {
    name: 'operation-theater-management'
    element: 'page-operation-theater-management'
    windowTitlePostfix: 'Operation Theater Management'
    headerTitle: 'Operation Theater Management'
    preload: true
    hrefList: [ 'operation-theater-management' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    showOnSideNav: false
    icon: 'track-changes'
    index: 77   
    accessId: 'C021'
  }

  {
    name: 'qrcode-manager'
    element: 'page-qrcode-manager'
    windowTitlePostfix: 'Business QR Code Manager'
    headerTitle: 'Business QR Code Manager'
    preload: true
    hrefList: [ 'qrcode-manager' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    showOnSideNav: false
    icon: 'home'
    index: 201   
    accessId: 'C040'
  }

  {
    name: 'my-pass-id-list'
    element: 'my-pass-id-list'
    windowTitlePostfix: 'My Pass Cards'
    headerTitle: 'My Pass Id list'
    preload: true
    hrefList: [ 'my-pass-id-list' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    showOnSideNav: false
    icon: 'home'
    index: 201   
    accessId: 'C041'
  }
  
  {
    name: 'booking'
    element: 'page-booking'
    windowTitlePostfix: 'Booking and Services'
    headerTitle: 'Booking and Services'
    preload: true
    hrefList: [ 'booking' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D003'
  }
  {
    name: 'chamber'
    element: 'page-chamber'
    windowTitlePostfix: 'Chamber'
    headerTitle: 'Chamber'
    preload: true
    hrefList: [ 'chamber' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D003'
  }
  {
    name: 'chamber-patients'
    element: 'page-chamber-patients'
    windowTitlePostfix: 'Chamber: Patients'
    headerTitle: 'Chamber: Patients'
    preload: true
    hrefList: [ 'chamber-patients' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D003'
  }
  {
    name: 'print-chamber-patients'
    element: 'page-print-chamber-patients'
    windowTitlePostfix: 'Chamber Patients Print'
    headerTitle: 'Chamber Patients Print'
    preload: true
    hrefList: [ 'print-chamber-patients' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showPrintButton: true
    showToolbar: true
  }
  {
    name: 'chamber-statistics'
    element: 'page-chamber-statistics'
    windowTitlePostfix: 'Chamber Statistics'
    headerTitle: 'Chamber Statistics'
    preload: true
    hrefList: [ 'chamber-statistics' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D003'
  }
  {
    name: 'patient-editor'
    element: 'page-patient-editor'
    windowTitlePostfix: 'Patient Editor'
    headerTitle: 'Patient Editor'
    preload: true
    hrefList: [ 'patient-editor' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D001'
  }
  {
    name: 'patient-template'
    element: 'page-patient-template'
    windowTitlePostfix: 'Patient Template'
    headerTitle: 'Patient Template'
    preload: true
    hrefList: [ 'patient-template' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'D001'
  }
  # {
  #   name: 'ndr-editor'
  #   element: 'page-ndr-editor'
  #   windowTitlePostfix: 'NDR'
  #   headerTitle: 'NDR Form'
  #   preload: true
  #   hrefList: [ 'ndr' ]
  #   requireAuthentication : true
  #   headerType: 'modal'
  #   leftMenuEnabled: true
  #   showSaveButton: true
  #   showPatientsDetails: false
  #   showToolbar: true
  #   hideHeaderTitle: false
  #   accessId: 'D001'
  #   showPrintButton: false
  # }
  # {
  #   name: 'preview-ndr'
  #   element: 'page-preview-ndr'
  #   windowTitlePostfix: 'Preview NDR Record'
  #   headerTitle: 'Preview NDR Record'
  #   preload: true
  #   hrefList: [ 'preview-ndr' ]
  #   requireAuthentication : true
  #   headerType: 'modal'
  #   leftMenuEnabled: false
  #   showSaveButton: false
  #   showPatientsDetails: false
  #   showToolbar: true
  #   hideAd: false
  #   hideHeaderTitle: false
  #   accessId: 'none'

  # }
  {
    name: 'patient-viewer'
    element: 'page-patient-viewer'
    windowTitlePostfix: 'Patient'
    headerTitle: ''
    preload: true
    hrefList: [ 'patient-viewer' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: true
    showMediumTallToolbar: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D001'
  }

  {
    name: 'advised-test-editor'
    element: 'page-advised-test-editor'
    windowTitlePostfix: 'Advised Test'
    headerTitle: 'Advised new test'
    preload: true
    hrefList: [ 'advised-test-editor' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D001'
  }

  {
    name: 'single-test-result-print'
    element: 'page-single-test-result-print'
    windowTitlePostfix: 'Test Result Print'
    headerTitle: 'Test Result Print'
    preload: true
    hrefList: [ 'single-test-result-print' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showToolbar: true
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'internal-inventory-transaction-print'
    element: 'page-internal-inventory-transaction-print'
    windowTitlePostfix: 'Internal inventory transaction'
    headerTitle: 'Preview'
    preload: true
    hrefList: [ 'internal-inventory-transaction-preview' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showToolbar: true
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'store-inventory-transaction-print'
    element: 'page-store-inventory-transaction-print'
    windowTitlePostfix: 'Store inventory transaction'
    headerTitle: 'Preview'
    preload: true
    hrefList: [ 'store-inventory-transaction-preview' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showToolbar: true
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }
  {
    name: 'all-test-result-print'
    element: 'page-all-test-result-print'
    windowTitlePostfix: 'Test Results Print'
    headerTitle: 'Test Results Print'
    preload: true
    hrefList: [ 'all-test-result-print' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showToolbar: true
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }
  

  {
    name: 'advised-test'
    element: 'page-advised-test-editor'
    windowTitlePostfix: 'Test Advised'
    headerTitle: 'Test Advised'
    preload: true
    hrefList: [ 'advised-test' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: true
    showToolbar: true
    showPatientsDetails: false
    accessId: 'none'
  }

  {
    name: 'test-results'
    element: 'page-test-results-editor'
    windowTitlePostfix: 'Test Results'
    headerTitle: 'Test Results'
    preload: true
    hrefList: [ 'test-results' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showToolbar: true
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'D017'
  }

  {
    name: 'notification-panel'
    element: 'page-notification-panel'
    windowTitlePostfix: 'Notfication Panel'
    headerTitle: 'Notfication Panel'
    preload: true
    hrefList: [ 'notification-panel' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    accessId: 'none'
    showOnSideNav: false
    icon: 'announcement'
    index: 99
  }

  {
    name: 'PCC Help'
    element: 'page-pcc-help'
    windowTitlePostfix: 'PCC Help'
    headerTitle: 'PCC Help'
    preload: true
    hrefList: [ 'pcc-help' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none'
    showOnSideNav: false
    forPccOnly: true
    icon: 'book'
    index: 202
  }

  {
    name: 'settings'
    element: 'page-settings'
    windowTitlePostfix: 'Settings'
    headerTitle: 'Settings'
    preload: true
    hrefList: [ 'settings' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none'
    showOnSideNav: true
    icon: 'settings'
    index: 100
  }

  {
    name: 'organization-settings'
    element: 'page-organization-settings'
    windowTitlePostfix: 'Organization Settings'
    headerTitle: 'Organization Settings'
    preload: true
    hrefList: [ 'organization-settings' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
  }

  {
    name: 'set-unit-price'
    element: 'page-set-unit-price'
    windowTitlePostfix: 'set-unit-price'
    headerTitle: 'Set Price for Unit'
    preload: true
    hrefList: [ 'set-unit-price' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none'
  }

  {
    name: 'manage-unit-price'
    element: 'page-manage-unit-price'
    windowTitlePostfix: 'manage-unit-price'
    headerTitle: 'Manage Price for Unit'
    preload: true
    hrefList: [ 'manage-unit-price' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
  }

  {
    name: 'organization-reports'
    element: 'page-organization-reports'
    windowTitlePostfix: 'organization-reports'
    headerTitle: 'Organization Reports'
    preload: true
    hrefList: [ 'organization-reports' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    showOnSideNav: false
    icon:'report'
  }

  {
    name: 'organization-send-bulk-sms'
    element: 'page-organization-send-bulk-sms'
    windowTitlePostfix: 'Organization-send-bulk-sms'
    headerTitle: 'Send SMS to Audience'
    preload: true
    hrefList: [ 'send-bulk-sms' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    
  }

  {
    name: 'compare-unit-price'
    element: 'page-compare-unit-price'
    windowTitlePostfix: 'compare-unit-price'
    headerTitle: 'Compare Price for Unit'
    preload: true
    hrefList: [ 'compare-unit-price' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    accessId: 'none'
  }

  {
    name: 'ambulance-finder'
    element: 'page-ambulance-finder'
    windowTitlePostfix: 'ambulance-finder'
    headerTitle: 'Find Ambulance'
    preload: true
    hrefList: [ 'find-ambulance' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    accessId: 'none'
  }

  {
    name: 'hospital-finder'
    element: 'page-hospital-finder'
    windowTitlePostfix: 'hospital-finder'
    headerTitle: 'Find Hospital'
    preload: true
    hrefList: [ 'find-hospital' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    accessId: 'none'
  }

  {
    name: 'my-duty-roster'
    element: 'page-my-duty-roster'
    windowTitlePostfix: 'my-duty-roster'
    headerTitle: 'My Duty Roster'
    preload: true
    hrefList: [ 'my-duty-roster' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'assignment-ind'
    showOnSideNav: false
    accessId: 'C043'
  }

  {
    name: 'access-management'
    element: 'page-access-management'
    windowTitlePostfix: 'my-access-management'
    headerTitle: 'Special Access Management'
    preload: true
    hrefList: [ 'access-management' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'assignment-ind'
    showOnSideNav: false
    accessId: 'none'
  }

  {
    name: 'doctor-list'
    element: 'page-doctor-list'
    windowTitlePostfix: 'doctor-list'
    headerTitle: 'All Doctors'
    preload: true
    hrefList: [ 'doctor-list' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'supervisor-account'
    showOnSideNav: false
    accessId: 'C044'
  }

  {
    name: 'organization-qrcode'
    element: 'page-organization-qrcode'
    windowTitlePostfix: 'organization-qrcode'
    headerTitle: 'Organization QR Code'
    preload: true
    hrefList: [ 'organization-qrcode' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'select-all'
    showOnSideNav: false
    accessId: 'C045'    
  }

  {
    name: 'complain-box'
    element: 'page-complain-box'
    windowTitlePostfix: 'complain-box'
    headerTitle: 'Complain Box'
    preload: true
    hrefList: [ 'complain-box' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'assignment-late'
    showOnSideNav: false
    accessId: 'C046'
  }

  {
    name: 'complain-preview'
    element: 'page-complain-preview'
    windowTitlePostfix: 'complain-preview'
    headerTitle: 'Complain preview'
    preload: true
    hrefList: [ 'complain-preview' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    showOnSideNav: false
    showPrintButton: true
  }

  {
    name: 'complain-list'
    element: 'page-complain-list'
    windowTitlePostfix: 'complain-list'
    headerTitle: 'Complain List'
    preload: true
    hrefList: [ 'complain-list' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'view-list'
    showOnSideNav: false
    accessId: 'C047'
  }

  {
    name: 'duty-roster-manager'
    element: 'page-duty-roster-manager'
    windowTitlePostfix: 'duty-roster-manager'
    headerTitle: 'Manage Duty Roster'
    preload: true
    hrefList: [ 'manage-duty-roster' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'C043'
  }

  {
    name: 'ambulance-manager'
    element: 'page-ambulance-manager'
    windowTitlePostfix: 'ambulance-manager-manager'
    headerTitle: 'Manage Ambulance'
    preload: true
    hrefList: [ 'ambulance-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
    icon: 'group-work'
    showOnSideNav: false
    accessId: 'C048'
  }

  {
    name: 'page-patients-queue'
    element: 'page-patients-queue'
    windowTitlePostfix: 'patients-queue'
    headerTitle: 'Patients Queue'
    preload: true
    hrefList: [ 'patients-queue' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
  }

  {
    name: 'organization-unit-price-public'
    element: 'page-organization-unit-price-public'
    windowTitlePostfix: 'unit-price-public'
    headerTitle: 'Hospital Product Price'
    preload: true
    hrefList: [ 'unit-price-public' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: false
    accessId: 'none'
  }

  {
    name: 'set-package'
    element: 'page-set-package'
    windowTitlePostfix: 'set-package'
    headerTitle: 'Create Package'
    preload: true
    hrefList: [ 'set-package' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'none'
  }


  {
    name: 'create-invoice'
    element: 'page-create-invoice'
    windowTitlePostfix: 'create-invoice'
    headerTitle: 'Create Invoice'
    preload: true
    hrefList: [ 'create-invoice' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'D016'
  }

  {
    name: 'outpatient-invoice'
    element: 'page-outpatient-invoice'
    windowTitlePostfix: 'outpatient-invoice'
    headerTitle: 'Outpatient Invoice'
    preload: true
    hrefList: [ 'outpatient-invoice' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    icon: 'date-range'
    accessId: 'C016'
    showOnSideNav: false
    index: 89
  }

  {
    name: 'emergencypatient-invoice'
    element: 'page-emergencypatient-invoice'
    windowTitlePostfix: 'emergencypatient-invoice'
    headerTitle: 'Emergency Patient Invoice'
    preload: true
    hrefList: [ 'emergencypatient-invoice' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    icon: 'date-range'
    accessId: 'C017'
    showOnSideNav: false
    index: 91
  }

  {
    name: 'sample-invoice'
    element: 'page-sample-invoice'
    windowTitlePostfix: 'sample-invoice'
    headerTitle: 'Sample Invoice'
    preload: true
    hrefList: [ 'sample-invoice' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
  }

  {
    name: 'pharmacy-invoice-editor'
    element: 'page-pharmacy-invoice-editor'
    windowTitlePostfix: 'pharmacy-invoice-editor'
    headerTitle: 'Pharmacy Invoice'
    preload: true
    hrefList: [ 'pharmacy-invoice-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none',
    showPrintButton: true
  }

  {
    name: 'canteen-invoice-editor'
    element: 'page-canteen-invoice-editor'
    windowTitlePostfix: 'canteen-invoice-editor'
    headerTitle: 'Canteen Invoice'
    preload: true
    hrefList: [ 'canteen-invoice-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none',
    showPrintButton: true
  }

  {
    name: 'print-invoice'
    element: 'page-print-invoice'
    windowTitlePostfix: 'print-invoice'
    headerTitle: 'print Invoice'
    preload: true
    hrefList: [ 'print-invoice' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'blank-prescription'
    element: 'page-blank-prescription'
    windowTitlePostfix: 'page-blank-prescription'
    headerTitle: 'Blank Prescription'
    preload: true
    hrefList: [ 'blank-prescription' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'print-respirator-fit-test'
    element: 'page-print-respirator-fit-test'
    windowTitlePostfix: 'print-respirator-fit-test'
    headerTitle: 'Print Respirator Fit Test'
    preload: true
    hrefList: [ 'print-respirator-fit-test' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'print-covid-vaccination-details'
    element: 'page-print-covid-vaccination-details'
    windowTitlePostfix: 'Print Covid Vaccination Details'
    headerTitle: 'Print Covid Vaccination Details'
    preload: true
    hrefList: [ 'print-covid-vaccination-details' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'editor'
    element: 'page-editor'
    windowTitlePostfix: 'Editor'
    headerTitle: 'editor'
    preload: true
    hrefList: [ 'editor' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
  }

  {
    name: 'print-preview-individual-invoice'
    element: 'page-print-preview-individual-invoice'
    windowTitlePostfix: 'print-preview-individual-invoice'
    headerTitle: 'Invoice Print Preview'
    preload: true
    hrefList: [ 'print-preview-individual-invoice' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'assistant-manager'
    element: 'page-assistant-manager'
    windowTitlePostfix: 'Assistant Manager'
    headerTitle: 'Assistant Manager'
    preload: true
    hrefList: [ 'assistant-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    accessId: 'D005'
  }

  {
    name: 'organization-manager'
    element: 'page-organization-manager'
    windowTitlePostfix: 'Organization Manager'
    headerTitle: 'Organization Manager'
    preload: true
    hrefList: [ 'organization-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }
  {
    name: 'organization-dashboard'
    element: 'page-organization-dashboard'
    windowTitlePostfix: 'Organization dashboard'
    headerTitle: 'Organization dashboard'
    preload: true
    hrefList: [ 'organization-dashboard' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
    showOnSideNav: true
    icon: 'account-balance'
    index: 19
  }
  {
    name: 'organization-records'
    element: 'page-organization-records'
    windowTitlePostfix: 'Organization Records'
    headerTitle: 'Organization Records'
    preload: true
    hrefList: [ 'organization-records' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }
  {
    name: 'organization-editor'
    element: 'page-organization-editor'
    windowTitlePostfix: 'Organization Editor'
    headerTitle: 'Organization Editor'
    preload: true
    hrefList: [ 'organization-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showOrganizationsName: true
    accessId: 'D010'
  }

  {
    name: 'join-organization'
    element: 'page-join-organization'
    windowTitlePostfix: 'Join Organization'
    headerTitle: 'Join Organization'
    preload: true
    hrefList: [ 'join-organization' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showOrganizationsName: true
    accessId: 'D010'
  }

  {
    name: 'video-chat'
    element: 'page-video-chat'
    windowTitlePostfix: 'Video Chat'
    headerTitle: 'Video Chat'
    preload: true
    hrefList: [ 'video-chat' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: true
    showPatientsDetails: false
    accessId: 'none'
    showOnSideNav: false
    icon: 'settings'
    index: 500
  }

  {
    name: 'manage-joining-request'
    element: 'page-manage-joining-request'
    windowTitlePostfix: 'Manage Joining Request'
    headerTitle: 'Manage Joining Request'
    preload: true
    hrefList: [ 'manage-joining-request' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'view-user-profile'
    element: 'page-view-user-profile'
    windowTitlePostfix: 'View User Profile'
    headerTitle: 'View User Profile'
    preload: true
    hrefList: [ 'view-user-profile' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'organization-medicine-sales-statistics'
    element: 'page-organization-medicine-sales-statistics'
    windowTitlePostfix: 'Medicine Sales Statistics'
    headerTitle: 'Medicine Sales Statistics'
    preload: true
    hrefList: [ 'organization-medicine-sales-statistics' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showToolbar: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'organization-rolewise-member-statistics'
    element: 'page-organization-rolewise-member-statistics'
    windowTitlePostfix: 'Organization rolewise member statistics'
    headerTitle: 'Organization rolewise member statistics'
    preload: true
    hrefList: [ 'organization-rolewise-member-statistics' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D010'
  }

  {
    name: 'organization-manage-users'
    element: 'page-organization-manage-users'
    windowTitlePostfix: 'Organization Manage Users'
    headerTitle: 'Organization Manage Users'
    preload: true
    hrefList: [ 'organization-manage-users' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'organization-manage-patient'
    element: 'page-organization-manage-patient'
    windowTitlePostfix: 'Organization Wallet for Patient (BADAS)'
    headerTitle: 'Organization Wallet for Patient (BADAS)'
    preload: true
    hrefList: [ 'organization-manage-patient' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showToolbar: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'select-organization'
    element: 'page-select-organization'
    windowTitlePostfix: 'Select Organization'
    headerTitle: 'Select Organization'
    preload: true
    hrefList: [ '/', 'select-organization' ]
    requireAuthentication : true
    showToolbar: false
    headerType: 'normal'
    leftMenuEnabled: false
    accessId: 'none'
  }

  {
    name: 'invoice-report'
    element: 'page-invoice-report'
    windowTitlePostfix: 'Invoice Report'
    headerTitle: 'Invoice Report'
    preload: true
    hrefList: [ 'invoice-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D016'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'covid-fit-test'
    element: 'page-covid-fit-test'
    windowTitlePostfix: 'COVID Respirator Fit Test'
    headerTitle: 'COVID Respirator Fit Test'
    preload: true
    hrefList: [ 'covid-fit-test' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: false
    showMediumTallToolbar: true    
    accessId: 'D016'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'covid-vaccination'
    element: 'page-covid-vaccination'
    windowTitlePostfix: 'Covid Vaccination'
    headerTitle: 'Covid Vaccination'
    preload: true
    hrefList: [ 'covid-vaccination' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: false
    showMediumTallToolbar: true    
    # accessId: 'D016'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'manage-covid-lockdown'
    element: 'page-manage-covid-lockdown'
    windowTitlePostfix: 'Manage Covid Lockdown'
    headerTitle: 'Manage Covid Lockdown'
    preload: true
    hrefList: [ 'manage-covid-lockdown' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'D016'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'my-attendance-sessions'
    element: 'page-my-attendance-sessions'
    windowTitlePostfix: 'My Attendance Sessions'
    headerTitle: 'My Attendance Sessions'
    preload: true
    hrefList: [ 'my-attendance-sessions' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showMediumTallToolbar: true    
    accessId: 'D016'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'organization-patient-report'
    element: 'page-organization-patient-report'
    windowTitlePostfix: 'Patient Report'
    headerTitle: 'Patient Report'
    preload: true
    hrefList: [ 'organization-patient-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    # showAccountsDashboardTabs: true
    # showMediumTallToolbar: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'third-party-payment-manager'
    element: 'page-third-party-payment-manager'
    windowTitlePostfix: 'Third Party Payment Manager'
    headerTitle: 'Third Party Payment Manager'
    preload: true
    hrefList: [ 'third-party-payment-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    showOnSideNav: false
    icon: 'receipt'
    index: 89
    accessId: 'C050'
  }

  {
    name: 'third-party-supervisor-manager'
    element: 'page-third-party-supervisor-manager'
    windowTitlePostfix: 'Third Party Supervisor Manager'
    headerTitle: 'Third Party Supervisor Manager'
    preload: true
    hrefList: [ 'third-party-supervisor-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showOnSideNav: false
    icon: 'face'
    index: 56
    accessId: 'C049'
  }

  {
    name: 'profile-editor'
    element: 'page-profile-editor'
    windowTitlePostfix: 'My Profile'
    headerTitle: 'My Profile'
    preload: true
    hrefList: [ 'profile-editor' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: true
    showOnSideNav: false
    icon: 'face'
    showToolbar: true
    hideHeaderTitle: false
    index: 53
    accessId: 'C063'
  }

  {
    name: 'top-sheet'
    element: 'page-top-sheet'
    windowTitlePostfix: 'Top Sheet of Accounts'
    headerTitle: 'Top Sheet of Accounts'
    preload: true
    hrefList: [ 'top-sheet' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'C038'
    showOnSideNav: false
    icon: 'receipt'
    index: 89
  }

  {
    name: 'commission-report'
    element: 'page-commission-report'
    windowTitlePostfix: 'Commission Report'
    headerTitle: 'Commission Report'
    preload: true
    hrefList: [ 'commission-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D018'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'commission-report-rmh'
    element: 'page-commission-report-rmh'
    windowTitlePostfix: 'Commission Report RMH'
    headerTitle: 'Commission Report RMH'
    preload: true
    hrefList: [ 'commission-report-rmh' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D018'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'commission-report-cmh'
    element: 'page-commission-report-cmh'
    windowTitlePostfix: 'Commission Report CMH'
    headerTitle: 'Commission Report CMH'
    preload: true
    hrefList: [ 'commission-report-cmh' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D018'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'commission-report-print-preview'
    element: 'page-commission-report-print-preview'
    windowTitlePostfix: 'Commission Report Print'
    headerTitle: 'Commission Report Print'
    preload: true
    hrefList: [ 'commission-report-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPrintButton: true    
    showOrganizationsName: true
  }

  {
    name: 'print-commission-payment-details'
    element: 'page-print-commission-payment-details'
    windowTitlePostfix: 'Commission Payment Details'
    headerTitle: 'Commission Payment Details'
    preload: true
    hrefList: [ 'print-commission-payment-details' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPrintButton: true    
    showOrganizationsName: true
  }

  {
    name: 'invoice-report-print-preview'
    element: 'page-invoice-report-print-preview'
    windowTitlePostfix: 'Invoice Report Print'
    headerTitle: 'Invoice Report Print'
    preload: true
    hrefList: [ 'invoice-report-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPrintButton: true    
    showOrganizationsName: true
  }

  {
    name: 'salary-report-print-preview'
    element: 'page-salary-report-print-preview'
    windowTitlePostfix: 'Salary Report Print'
    headerTitle: 'Salary Report Print'
    preload: true
    hrefList: [ 'salary-report-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    showPrintButton: true    
    showOrganizationsName: true
  }

  {
    name: 'commission-category-manager'
    element: 'page-commission-category-manager'
    windowTitlePostfix: 'Commission Category Manager'
    headerTitle: 'Commission Category Manager'
    preload: true
    hrefList: [ 'commission-category-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'C031'
    showOnSideNav: false
    icon:'description'
    index: 89
  }  

  {
    name: 'fund-report'
    element: 'page-fund-report'
    windowTitlePostfix: 'Fund Report'
    headerTitle: 'Fund Report'
    preload: true
    hrefList: [ 'fund-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D024'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }  

  {
    name: 'referral-report'
    element: 'page-referral-report'
    windowTitlePostfix: 'Referral Report'
    headerTitle: 'Referral Report'
    preload: true
    hrefList: [ 'referral-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'D025'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'due-guarantor-report'
    element: 'page-due-guarantor-report'
    windowTitlePostfix: 'Due Guarantor Report'
    headerTitle: 'Due Guarantor Report'
    preload: true
    hrefList: [ 'due-guarantor-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'C039'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'discount-report'
    element: 'page-discount-report'
    windowTitlePostfix: 'Discount Report'
    headerTitle: 'Discount Report'
    preload: true
    hrefList: [ 'discount-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true
    accessId: 'D027'
    showOnSideNav: false
    icon:'assessment'
    index: 99
  }

  {
    name: 'pharmacy-manager'
    element: 'page-pharmacy-manager'
    windowTitlePostfix: 'Pharmacy Manager'
    headerTitle: 'Pharmacy Manager'
    preload: true
    hrefList: [ 'pharmacy-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'D020'
    showOnSideNav: true
    icon: 'description'
    index: 89
  }

  {
    name: 'canteen-manager'
    element: 'page-canteen-manager'
    windowTitlePostfix: 'Canteen Manager'
    headerTitle: 'Canteen Manager'
    preload: true
    hrefList: [ 'canteen-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'D032'
    showOnSideNav: false
    icon: 'description'
    index: 89
  }


  {
    name: 'internal-inventory-manager'
    element: 'page-internal-inventory-manager'
    windowTitlePostfix: 'Internal inventory manager'
    headerTitle: 'Internal inventory manager'
    preload: true
    hrefList: [ 'internal-inventory-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'C035'
    showOnSideNav: false
    icon: 'description'
    index: 89
  }

  {
    name: 'message-share'
    element: 'page-message-share'
    windowTitlePostfix: 'Message Share'
    headerTitle: 'Message Share'
    preload: true
    hrefList: [ 'message-share' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    hideSMSBalance: true
    hideSyncButton: true
    icon: 'question-answer'
    index: 89
  }

  {
    name: 'third-party-manager'
    element: 'page-third-party-manager'
    windowTitlePostfix: 'Third Party Manager'
    headerTitle: 'Third Party Manager'
    preload: true
    hrefList: [ 'third-party-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'C033'
    showOnSideNav: false
    hideSMSBalance: true
    hideSyncButton: true
    icon: 'question-answer'
    index: 95
  }

  {
    name: 'referral-doctor-manager'
    element: 'page-referral-doctor-manager'
    windowTitlePostfix: 'Referral Doctor Manager'
    headerTitle: 'Referral Doctor Manager'
    preload: true
    hrefList: [ 'referral-doctor-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'C069'
    showOnSideNav: false
    hideSMSBalance: true
    hideSyncButton: true
    icon: 'face'
    index: 95
  }

  {
    name: 'store-manager'
    element: 'page-store-manager'
    windowTitlePostfix: 'Store Manager'
    headerTitle: 'Store Manager'
    preload: true
    hrefList: [ 'store-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'C034'
    showOnSideNav: false
    icon: 'question-answer'
    showStores: true
    index: 90
  }

  {
    name: 'store-audit-editor'
    element: 'page-store-audit-editor'
    windowTitlePostfix: 'Store Audit'
    headerTitle: 'Store Audit'
    preload: true
    hrefList: [ 'store-audit-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'question-answer'
    showStores: true
    index: 90
  }

  {
    name: 'store-audit-preview'
    element: 'page-store-audit-preview'
    windowTitlePostfix: 'Audit Preview'
    headerTitle: 'Audit Preview'
    preload: true
    hrefList: [ 'store-audit-preview' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'question-answer'
    showStores: true
    index: 90
  }

  {
    name: 'accounts-manager'
    element: 'page-accounts-manager'
    windowTitlePostfix: 'Accounts Manager'
    headerTitle: 'Accounts Manager'
    preload: true
    hrefList: [ 'accounts-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-salary-manager'
    element: 'page-accounts-salary-manager'
    windowTitlePostfix: 'Accounts Salary Manager'
    headerTitle: 'Accounts Salary Manager'
    preload: true
    hrefList: [ 'accounts-salary-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    leftMenuEnabled: true
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-salary-creator'
    element: 'page-accounts-salary-creator'
    windowTitlePostfix: 'Accounts Salary Creator'
    headerTitle: 'Accounts Salary Creator'
    preload: true
    hrefList: [ 'accounts-salary-creator' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-view-salary-sheet'
    element: 'page-accounts-view-salary-sheet'
    windowTitlePostfix: 'View Salary Sheet'
    headerTitle: 'View Salary Sheet'
    preload: true
    hrefList: [ 'accounts-view-salary-sheet' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-income-manager'
    element: 'page-accounts-income-manager'
    windowTitlePostfix: 'Accounts Income Manager'
    headerTitle: 'Accounts Income Manager'
    preload: true
    hrefList: [ 'accounts-income-manager' ]
    requireAuthentication : true
    showToolbar: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true     
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true      
    accessId: 'D019'
  }

  {
    name: 'accounts-income-editor'
    element: 'page-accounts-income-editor'
    windowTitlePostfix: 'Accounts Income Editor'
    headerTitle: 'Accounts Income Editor'
    preload: true
    hrefList: [ 'accounts-income-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    accessId: 'D019'
  }

  {
    name: 'accounts-clone-income-manager'
    element: 'page-accounts-clone-income-manager'
    windowTitlePostfix: 'Clone Accounts Income Manager'
    headerTitle: 'Clone Accounts Income Manager'
    preload: true
    hrefList: [ 'accounts-clone-income-manager' ]
    requireAuthentication : true
    showToolbar: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true     
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true      
    accessId: 'C029'
  }

  {
    name: 'accounts-clone-income-editor'
    element: 'page-accounts-clone-income-editor'
    windowTitlePostfix: 'Clone Accounts Income Editor'
    headerTitle: 'Clone Accounts Income Editor'
    preload: true
    hrefList: [ 'accounts-clone-income-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    accessId: 'C029'
  }

  {
    name: 'accounts-expense-manager'
    element: 'page-accounts-expense-manager'
    windowTitlePostfix: 'Accounts Expense Manager'
    headerTitle: 'Accounts Expense Manager'
    preload: true
    hrefList: [ 'accounts-expense-manager' ]
    requireAuthentication : true
    showToolbar: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-expense-editor'
    element: 'page-accounts-expense-editor'
    windowTitlePostfix: 'Accounts Expense Editor'
    headerTitle: 'Accounts Expense Editor'
    preload: true
    hrefList: [ 'accounts-expense-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    accessId: 'D019'
  }

  {
    name: 'accounts-manager-dashboard'
    element: 'page-accounts-manager-dashboard'
    windowTitlePostfix: 'Accounts Dashboard'
    headerTitle: 'Accounts Dashboard'
    preload: true
    hrefList: [ 'accounts-manager-dashboard' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true
    accessId: 'D019'
    showOnSideNav: false
    icon: 'account-balance-wallet'
    index: 89
  }
  
  {
    name: 'accounts-income-print-preview'
    element: 'page-accounts-income-print-preview'
    windowTitlePostfix: 'Accounts Income Print Preview'
    headerTitle: 'Accounts Income Print Preview'
    preload: true
    hrefList: [ 'accounts-income-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    showPrintButton: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'accounts-clone-income-print-preview'
    element: 'page-accounts-clone-income-print-preview'
    windowTitlePostfix: 'Accounts Income Print Preview'
    headerTitle: 'Accounts Income Print Preview'
    preload: true
    hrefList: [ 'accounts-clone-income-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'accounts-income-print-preview-incomplete'
    element: 'page-accounts-income-print-preview-incomplete'
    windowTitlePostfix: 'Accounts Income Print Preview In Progress'
    headerTitle: 'Accounts Income Print Preview In Progress'
    preload: true
    hrefList: [ 'accounts-income-print-preview-incomplete' ]
    requireAuthentication : false
    showToolbar: true
    showPrintButton: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'accounts-expense-print-preview'
    element: 'page-accounts-expense-print-preview'
    windowTitlePostfix: 'Accounts Expense Print Preview'
    headerTitle: 'Accounts Expense Print Preview'
    preload: true
    hrefList: [ 'accounts-expense-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    showPrintButton: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'accounts-expense-print-preview-incomplete'
    element: 'page-accounts-expense-print-preview-incomplete'
    windowTitlePostfix: 'Accounts Expense Print Preview In Progress'
    headerTitle: 'Accounts Expense Print Preview In Progress'
    preload: true
    hrefList: [ 'accounts-expense-print-preview-incomplete' ]
    requireAuthentication : false
    showToolbar: true
    showPrintButton: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'accounts-refund-invoice'
    element: 'page-accounts-refund-invoice'
    windowTitlePostfix: 'Refund Invoice'
    headerTitle: 'Refund Invoice'
    preload: true
    hrefList: [ 'accounts-refund-invoice' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    accessId: 'C067'
  }

  {
    name: 'accounts-cash-balance'
    element: 'page-accounts-cash-balance'
    windowTitlePostfix: 'Accounts Cash Balance'
    headerTitle: 'Accounts Cash Balance'
    preload: true
    hrefList: [ 'accounts-cash-balance' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    leftMenuEnabled: true
    showOrganizationsName: true
    accessId: 'D019'
  }

  {
    name: 'accounts-handover'
    element: 'page-accounts-handover'
    windowTitlePostfix: 'Accounts Handover'
    headerTitle: 'Accounts Handover'
    preload: true
    hrefList: [ 'accounts-handover' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D019'
    # showOnSideNav: false
    icon: 'question-answer'
    # index: 89
  }

  {
    name: 'accounts-report'
    element: 'page-accounts-report'
    windowTitlePostfix: 'Accounts Report'
    headerTitle: 'Accounts Report'
    preload: true
    hrefList: [ 'accounts-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'C070'
    showOnSideNav: false
    icon: 'assessment'
    index: 89
  }

  {
    name: 'accounts-report-print-preview'
    element: 'page-accounts-report-print-preview'
    windowTitlePostfix: 'Accounts report print preview'
    headerTitle: 'Accounts report print preview'
    preload: true
    hrefList: [ 'accounts-report-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'normal'
    showPrintButton: true
    leftMenuEnabled: true
    showOrganizationsName: true
  }

  {
    name: 'supplier-invoice-editor'
    element: 'page-supplier-invoice-editor'
    windowTitlePostfix: 'Supplier Invoice'
    headerTitle: 'Supplier Invoice'
    preload: true
    hrefList: [ 'supplier-invoice-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
  }

  {
    name: 'supplier-invoice-print-preview'
    element: 'page-supplier-invoice-print-preview'
    windowTitlePostfix: 'supplier-invoice Print Preview'
    headerTitle: 'supplier-invoice Print Preview'
    preload: true
    hrefList: [ 'supplier-invoice-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    accessId: 'none'
  }

  {
    name: 'supplier-invoice-manager'
    element: 'page-supplier-invoice-manager'
    windowTitlePostfix: 'Supplier Invoice Manager'
    headerTitle: 'Supplier Invoice Manager'
    preload: true
    hrefList: [ 'supplier-invoice-manager' ]
    requireAuthentication : true
    showToolbar: true  
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C018'
    showOnSideNav: false
    icon: 'assessment'
    index: 93        
  }

  {
    name: 'fund-manager'
    element: 'page-fund-manager'
    windowTitlePostfix: 'Fund Manager'
    headerTitle: 'Fund Manager'
    preload: true
    hrefList: [ 'fund-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showOrganizationsName: true
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    accessId: 'D026'
    showOnSideNav: false
    icon: 'description'
    index: 89
  }

  {
    name: 'patient-stay-editor'
    element: 'page-visit-patient-stay-editor'
    windowTitlePostfix: 'Patient Stay'
    headerTitle: 'Patient Stay'
    preload: true
    hrefList: [ 'patient-stay-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    accessId: 'D015'
  }

  {
    name: 'print-patient-stay'
    element: 'page-print-patient-stay'
    windowTitlePostfix: 'Print Patient Stay'
    headerTitle: 'Print Patient Stay'
    preload: true
    hrefList: [ 'print-patient-stay' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'patient-stay-print-preview'
    element: 'page-patient-stay-print-preview'
    windowTitlePostfix: 'Patient Stay Print Preview'
    headerTitle: 'Patient Stay Print Preview'
    preload: true
    hrefList: [ 'patient-stay-print-preview' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'organization-manage-patient-stay'
    element: 'page-organization-manage-patient-stay'
    windowTitlePostfix: 'Organization Manage Patient Stay'
    headerTitle: 'Manage Patient Stay'
    preload: true
    hrefList: [ 'organization-manage-patient-stay' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showOrganizationsName: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }
  {
    name: 'preconception-record'
    element: 'page-preconception-record'
    windowTitlePostfix: 'Preconception Record'
    headerTitle: 'PCC Record'
    preload: true
    hrefList: [ 'preconception-record' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: false
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'none'
    showPrintButton: false
    hideAd: false
    accessId: 'none'
  }

  {
    name: 'preview-preconception-record'
    element: 'page-preview-preconception-record'
    windowTitlePostfix: 'Preview Preconception Record'
    headerTitle: 'Preview Preconception Record'
    preload: true
    hrefList: [ 'preview-preconception-record' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    hideAd: false
    hideHeaderTitle: false
    accessId: 'none'

  }
  
  {
    name: 'dev-tools'
    element: 'dev-tools'
    windowTitlePostfix: 'Dev Tools'
    headerTitle: 'Dev Tools'
    preload: true
    hrefList: [ 'dev-tools' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: false
    accessId: 'none'
  }

  {
    name: 'billing-report'
    element: 'page-billing-report'
    windowTitlePostfix: 'Billing Report'
    headerTitle: 'Billing Report'
    preload: true
    hrefList: [ 'billing-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'D021'
    showOnSideNav: false
    showAccountsDashboardTabs: true
    showMediumTallToolbar: true    
    icon: 'assessment'
    index: 99
  }

  {
    name: 'my-wallet'
    element: 'page-my-wallet'
    windowTitlePostfix: 'my-wallet'
    headerTitle: 'My Wallet'
    preload: true
    hrefList: [ 'my-wallet' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPrintButton: false
    accessId: 'none'
    showOnSideNav: false
    icon: 'account-balance-wallet'
    index: 89
  }

  {
    name: 'organization-wallet'
    element: 'page-organization-wallet'
    windowTitlePostfix: 'organization-wallet'
    headerTitle: 'Organization Wallet'
    preload: true
    hrefList: [ 'organization-wallet' ]
    requireAuthentication : true
    headerType: 'modal'
    showToolbar: true
    leftMenuEnabled: true
    showPrintButton: false
    hideHeaderTitle: false
    accessId: 'none'
  }

  {
    name: 'pcc-reports'
    element: 'page-pcc-reports'
    windowTitlePostfix: 'PCC Reports'
    headerTitle: 'PCC Reports'
    preload: true
    hrefList: [ 'pcc-reports' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'C903'
    showOnSideNav: false
    forPccOnly: true
    icon: 'assessment'
    index: 201
  },

  # {
  #   name: 'ndr-record-list'
  #   element: 'page-ndr-record-list'
  #   windowTitlePostfix: 'View NDR Records'
  #   headerTitle: 'View NDR Records'
  #   preload: true
  #   hrefList: [ 'ndr-record-list' ]
  #   requireAuthentication : true
  #   showToolbar: true
  #   headerType: 'modal'
  #   leftMenuEnabled: false
  #   showSaveButton: false
  #   showPatientsDetails: false
  #   hideAd: false
  #   hideHeaderTitle: false
  #   accessId: 'none' 
  # }

  {
    name: 'nwdr-reports'
    element: 'page-nwdr-reports'
    windowTitlePostfix: 'NWDR Report'
    headerTitle: 'NWDR Report'
    preload: true
    hrefList: [ 'nwdr-reports' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'C904'
    showOnSideNav: false
    forNwdrOnly: true
    icon: 'assessment'
    index: 200
  }

  {
    name: 'test-report'
    element: 'page-test-report'
    windowTitlePostfix: 'Test Reports'
    headerTitle: 'Test Reports'
    preload: true
    hrefList: [ 'test-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D028'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'operation-report'
    element: 'page-operation-report'
    windowTitlePostfix: 'Operation Reports'
    headerTitle: 'Operation Reports'
    preload: true
    hrefList: [ 'operation-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: ''
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'diagnosis-report'
    element: 'page-diagnosis-report'
    windowTitlePostfix: 'Diagnosis Reports'
    headerTitle: 'Diagnosis Reports'
    preload: true
    hrefList: [ 'diagnosis-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D030'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
    accessId: 'C051'
  }

  {
    name: 'agent-panel'
    element: 'page-agent-panel'
    windowTitlePostfix: 'Agent Panel'
    headerTitle: 'Agent Panel'
    preload: true
    hrefList: [ 'agent-panel' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'assessment'
    index: 99
    accessId: 'C068'
  }

  {
    name: 'investigation-report'
    element: 'page-investigation-report'
    windowTitlePostfix: 'Investigation Report'
    headerTitle: 'Investigation Report'
    preload: true
    hrefList: [ 'investigation-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'D029'
    showOnSideNav: false
    icon: 'assessment'
    index: 99
  }

  {
    name: 'patient-stay-report'
    element: 'page-patient-stay-report'
    windowTitlePostfix: 'Patient Stay Reports'
    headerTitle: 'Patient Stay Reports'
    preload: true
    hrefList: [ 'patient-stay-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    hideHeaderTitle: false
    accessId: 'C030'
    showOnSideNav: false
    icon: 'supervisor-account'
    index: 99
  }

  {
    name: 'template-manager'
    element: 'page-template-manager'
    windowTitlePostfix: 'Template Manager'
    headerTitle: 'Template Manager'
    preload: true
    hrefList: [ 'template-manager' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    showOnSideNav: false
    hideHeaderTitle: false
    accessId: 'C022'
    icon: 'polymer'
    index: 99
  }

  {
    name: 'view-template'
    element: 'page-view-template'
    windowTitlePostfix: 'View Template'
    headerTitle: 'View Template'
    preload: true
    hrefList: [ 'view-template' ]
    headerType: 'normal'
    leftMenuEnabled: true
    showToolbar: true
    showOnSideNav: false
    hideHeaderTitle: false
    icon: 'visibility'
    index: 99
  }

  {
    name: 'print-consent-form'
    element: 'page-print-consent-form'
    windowTitlePostfix: 'Print Consent Form'
    headerTitle: 'Print Consent Form'
    preload: true
    hrefList: [ 'print-consent-form' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showPrintButton: true
  }

  {
    name: 'patient-consent-form'
    element: 'page-patient-consent-form'
    windowTitlePostfix: 'Consent Form'
    headerTitle: 'Consent Form'
    preload: true
    hrefList: [ 'patient-consent-form' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
  }

  {
    name: 'page-token-preview'
    element: 'page-token-preview'
    windowTitlePostfix: 'Token Preview'
    headerTitle: 'Token Preview'
    preload: true
    hrefList: [ 'token-preview' ]
    requireAuthentication :true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showPrintButton: true
  }

  {
    name: 'organization-department-manager'
    element: 'page-organization-department-manager'
    windowTitlePostfix: 'Department Manager'
    headerTitle: 'Department Manager'
    preload: true
    hrefList: [ 'organization-department-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }

  {
    name: 'organization-designation-manager'
    element: 'page-organization-designation-manager'
    windowTitlePostfix: 'Designation Manager'
    headerTitle: 'Designation Manager'
    preload: true
    hrefList: [ 'organization-designation-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }

  {
    name: 'organization-employee-manager'
    element: 'page-organization-employee-manager'
    windowTitlePostfix: 'Employee Manager'
    headerTitle: 'Employee Manager'
    preload: true
    hrefList: [ 'organization-employee-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }

  {
    name: 'organization-employee-salary-manager'
    element: 'page-organization-employee-salary-manager'
    windowTitlePostfix: 'Employee Salary Manager'
    headerTitle: 'Employee Salary Manager'
    preload: true
    hrefList: [ 'organization-employee-salary-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }

  {
    name: 'organization-employee-leave-manager'
    element: 'page-organization-employee-leave-manager'
    windowTitlePostfix: 'Employee Leave Manager'
    headerTitle: 'Employee Leave Manager'
    preload: true
    hrefList: [ 'organization-employee-leave-manager' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }


  {
    name: 'organization-employee-editor'
    element: 'page-organization-employee-editor'
    windowTitlePostfix: 'Employee Editor'
    headerTitle: 'Employee Editor'
    preload: true
    hrefList: [ 'organization-employee-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    accessId: 'C031'
  }

  {
    name: 'organization-employee-salary-editor'
    element: 'page-organization-employee-salary-editor'
    windowTitlePostfix: 'Employee Salary Editor'
    headerTitle: 'Employee Salary Editor'
    preload: true
    hrefList: [ 'organization-employee-salary-editor' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    accessId: 'C031'
  }

  {
    name: 'organization-salary-report'
    element: 'page-organization-salary-report'
    windowTitlePostfix: 'Salary Report'
    headerTitle: 'Salary Report'
    preload: true
    hrefList: [ 'organization-salary-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    accessId: 'C031'
  }

  {
    name: 'medicine-dispensation'
    element: 'page-medicine-dispensation'
    windowTitlePostfix: 'Medicine Dispensation'
    headerTitle: 'Medicine Dispensation'
    preload: true
    hrefList: [ 'medicine-dispensation' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    hideHeaderTitle: false
    accessId: 'D004'
    showOnSideNav: false
    icon: 'assignment'
    index: 89
  }

  {
    name: 'organization-manage-waitlist'
    element: 'page-organization-manage-waitlist'
    windowTitlePostfix: 'Organization Manage Waitlist'
    headerTitle: 'Organization Manage Waitlist'
    preload: true
    hrefList: [ 'organization-manage-waitlist' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOrganizationManagerTabs: true
    showMediumTallToolbar: true
    accessId: 'D010'
  }

  {
    name: 'put-patient-to-waitlist'
    element: 'page-put-patient-to-waitlist'
    windowTitlePostfix: 'Put to Waitlist'
    headerTitle: 'Put to Waitlist'
    preload: true
    hrefList: [ 'put-patient-to-waitlist' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: true
    accessId: 'C032'
  }

  {
    name: 'view-single-waitlist'
    element: 'page-view-single-waitlist'
    windowTitlePostfix: 'View Waitlist'
    headerTitle: 'View Waitlist'
    preload: true
    hrefList: [ 'view-single-waitlist' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: false
    showPatientsDetails: false
    showToolbar: true
    accessId: 'C032'
  }

  {
    name: 'organization-view-all-waitlist'
    element: 'page-organization-view-all-waitlist'
    windowTitlePostfix: 'View Waitlists'
    headerTitle: 'View Waitlists'
    preload: true
    hrefList: [ 'organization-view-all-waitlist' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    showOnSideNav: false
    index: 89
    icon: 'list'
    accessId: 'C032'
  }

  {
    name: 'print-patient-card'
    element: 'page-print-patient-card'
    windowTitlePostfix: 'print-patient-card'
    headerTitle: 'Patient Card'
    preload: true
    hrefList: [ 'print-patient-card' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'print-patient-card-new'
    element: 'page-print-patient-card-new'
    windowTitlePostfix: 'print-patient-card-new'
    headerTitle: 'Patient Card'
    preload: true
    hrefList: [ 'print-patient-card-new' ]
    requireAuthentication : false
    showToolbar: true
    headerType: 'modal'
    leftMenuEnabled: false
    showSaveButton: false
    showPatientsDetails: false
    showPrintButton: true
    accessId: 'none'
  }

  {
    name: 'my-id-card'
    element: 'page-my-id-card'
    windowTitlePostfix: 'my-id-card'
    headerTitle: 'My ID Card'
    preload: true
    hrefList: [ 'my-id-card' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'line-style'
    index: 301
  }

  {
    name: 'organization-id-scan-report'
    element: 'page-organization-id-scan-report'
    windowTitlePostfix: 'id-scan-report'
    headerTitle: 'Organization ID Scan Report'
    preload: true
    hrefList: [ 'organization-id-scan-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'C057'
    showOnSideNav: false
    icon: 'line-style'
    index: 301
  }

  {
    name: 'my-id-scan-report'
    element: 'page-my-id-scan-report'
    windowTitlePostfix: 'id-scan-report'
    headerTitle: 'My ID Scan Report'
    preload: true
    hrefList: [ 'my-id-scan-report' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'line-style'
    index: 301
  }

  {
    name: 'my-invoice-card'
    element: 'page-my-Invoice-card'
    windowTitlePostfix: 'my-Invoice-card'
    headerTitle: 'My Invoice Card'
    preload: true
    hrefList: [ 'my-invoice-card' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'view-carousel'
    index: 302
  }

  {
    name: 'news-feed'
    element: 'page-news-feed'
    windowTitlePostfix: 'Message (Role wise)'
    headerTitle: 'Message (Role wise)'
    preload: true
    hrefList: [ 'news-feed' ]
    requireAuthentication : true
    showToolbar: true
    headerType: 'normal'
    leftMenuEnabled: true
    showSaveButton: false
    showOrganizationsName: true
    accessId: 'none'
    showOnSideNav: false
    icon: 'line-style'
    index: 301
  }

  {
    name: 'Public Appointments Booking'
    element: 'page-public-booking'
    windowTitlePostfix: 'Public Appointments Booking'
    headerTitle: 'Public Appointment Booking'
    preload: true
    hrefList: [ 'public-booking' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showPrintButton: false
    accessId: 'none'
    hideHeaderTitle: false
  }

  
  {
    name: 'online-exam-admin-panel'
    element: 'page-online-exam-admin-panel'
    windowTitlePostfix: 'Online Exam Admin Panel'
    headerTitle: 'Online Exam Admin Panel'
    preload: true
    hrefList: [ 'online-exam-admin-panel' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'C058'
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'track-changes'
    index: 100
  }

  {
    name: 'add-or-update-online-exam'
    element: 'page-add-or-update-online-exam'
    windowTitlePostfix: 'Add / Update Exam Details'
    headerTitle: 'Add / Update Exam Details'
    preload: true
    hrefList: [ 'add-or-update-online-exam' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'C059'
    hideHeaderTitle: false
    showOnSideNav: false
    index: 100
  }

  {
    name: 'analyze-online-exam'
    element: 'page-analyze-online-exam'
    windowTitlePostfix: 'Analyze Online Exam'
    headerTitle: 'Analyze Online Exam'
    preload: true
    hrefList: [ 'analyze-online-exam' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'C060'
    hideHeaderTitle: false
    showOnSideNav: false
    index: 100
  }

  {
    name: 'scan-user-for-invoices'
    element: 'page-scan-user-for-invoices'
    windowTitlePostfix: 'Scan User Invoices'
    headerTitle: 'Scan User Invoices'
    preload: true
    hrefList: [ 'scan-user-for-invoices' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'none'
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'track-changes'
    index: 100
  }

  {
    name: 'scan-user-profile'
    element: 'page-scan-user-profile'
    windowTitlePostfix: 'Scan User info'
    headerTitle: 'Scan User info'
    preload: true
    hrefList: [ 'scan-user-profile' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'none'
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'track-changes'
    index: 100
  }

  {
    name: 'scan-user-pass'
    element: 'page-scan-user-pass'
    windowTitlePostfix: 'Scan User Pass'
    headerTitle: 'Scan User Pass'
    preload: true
    hrefList: [ 'scan-user-pass' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    accessId: 'none'
    hideHeaderTitle: false
    showOnSideNav: false
    icon: 'track-changes'
    index: 100
  }

  {
    name: 'attendance-manager'
    element: 'page-attendance-manager'
    windowTitlePostfix: 'Attendance Manager'
    headerTitle: 'Attendance Manager'
    preload: true
    hrefList: [ 'attendance-manager' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
    index: 88
    icon: 'description'
  }

  {
    name: 'admin-user-report'
    element: 'page-admin-user-report'
    windowTitlePostfix: 'Admin User Report'
    headerTitle: 'Admin User Report'
    preload: true
    hrefList: [ 'admin-user-report' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
    index: 5
    icon: 'description'
  }

  {
    name: 'academic-session-editor'
    element: 'page-academic-session-editor'
    windowTitlePostfix: 'Academic Session Details'
    headerTitle: 'Academic Session Details'
    preload: true
    hrefList: [ 'academic-session-editor' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
  }

  {
    name: 'manage-group-editor'
    element: 'page-manage-group-editor'
    windowTitlePostfix: 'Group Editor'
    headerTitle: 'Group Editor'
    preload: true
    hrefList: [ 'manage-group-editor' ]
    requireAuthentication : true
    headerType: 'modal'
    # leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
  }

  {
    name: 'manage-academic-session'
    element: 'page-manage-academic-session'
    windowTitlePostfix: 'Manage Academic Session'
    headerTitle: 'Manage Academic Session'
    preload: true
    hrefList: [ 'manage-academic-session' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
  }

  {
    name: 'view-academic-session'
    element: 'page-view-academic-session'
    windowTitlePostfix: 'Academic Session'
    headerTitle: 'Academic Session'
    preload: true
    hrefList: [ 'view-academic-session' ]
    requireAuthentication : true
    headerType: 'modal'
    showPatientsDetails: false
    showToolbar: true
    hideHeaderTitle: false
    showOnSideNav: false
    accessId: 'none'
  }

  {
    name: 'my-bookings'
    element: 'page-my-bookings'
    windowTitlePostfix: 'My Bookings'
    headerTitle: 'My Bookings'
    preload: true
    hrefList: [ 'my-bookings' ]
    requireAuthentication : true
    headerType: 'normal'
    showToolbar: true
    leftMenuEnabled: true
    showPrintButton: false
    showOnSideNav: false
  }  
  
  {
    name: 'print-booking-details'
    element: 'page-print-booking-details'
    windowTitlePostfix: 'Print Booking Details'
    headerTitle: 'Print Booking Details'
    preload: true
    hrefList: [ 'print-booking-details' ]
    requireAuthentication : true
    headerType: 'modal'
    showToolbar: true
    leftMenuEnabled: true
    showPrintButton: true
    showOnSideNav: false
  }

]

app.pages.error404 = {
  name: '404'
  element: 'page-error-404'
  windowTitlePostfix: 'Not Found'
  headerTitle: '404 Not Found'
  preload: true
  href: [ '/404' ]
  requireAuthentication : false
  headerType: 'normal'
  leftMenuEnabled: true
}

app.pages.accessDenied = {
  name: 'access-denied'
  element: 'page-access-denied'
  windowTitlePostfix: 'Access Denied'
  headerTitle: 'Access Denied'
  preload: true
  href: [ '/access-denied' ]
  requireAuthentication : false
  headerType: 'normal'
  leftMenuEnabled: true
}