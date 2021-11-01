
app.behaviors.dbUsing = 

  isUserLoggedIn: ->
    userList = app.db.find 'user'
    if (userList.length is 0) or (not userList[0].apiKey)
      return false
    else if userList.length is 1
      return true
    else
      throw new Error 'More than one active user'

  removeAllUserInfo: ->
    app.db.remove 'user', item._id for item in app.db.find 'user'
    app.db.remove '--persistent-session', item._id for item in app.db.find '--persistent-session'
    app.db.remove '--serial-generator', item._id for item in app.db.find '--serial-generator'
    
  removeUserUnlessSessionIsPersistent: ->
    userList = app.db.find 'user'
    persistentSessionList = app.db.find '--persistent-session'

    if userList.length is 1 and persistentSessionList.length is 1
      if persistentSessionList[0].shouldRememberUser isnt true
        item = lib.tabStorage.getItem 'is-tab-authenticated'
        if item
          if (lib.json.parse item) is false
            @removeAllUserInfo()
        else
          @removeAllUserInfo()

  loginDbAction: (user, shouldRememberUser) ->
    previousUser = (app.db.find 'user')[0]
    @removeAllUserInfo()
    if previousUser 
      unless user.serial is previousUser.serial
        app.db.removeExistingDatabase()
        window.localStorage.clear()
        app.db.initializeDatabase()
        

    app.db.insert 'user', user

    persistentSession = 
      shouldRememberUser: shouldRememberUser
    app.db.insert '--persistent-session', persistentSession

    serialGenerator = 
      'patient-seed': 0
      'doctor-visit-seed': 0
      'patient-type-log-seed': 0
      'doctor-pcc-seed': 0
      'doctor-ndr-seed': 0
      'offline-patient-serial-seed': 1
      'doctor-visit-test-advise-seed': 0
      'doctor-visit-test-results-seed': 0
      'doctor-patient-stay-seed': 0
      'covid-respirator-fit-test-seed': 0
      'custom-covid-respirator-fit-test-seed': 0
      'covid-vaccination-seed': 1
      'favorite-investigation-seed': 0
      'custom-investigation-name-seed': 0
      'user-added-institution-list-seed': 0
      'attachment-record-seed': 0
      'user-added-reported-doctor-seed': 0
      'user-added-checked-by-user-list-seed': 1
      'patient-invoice-seed': 1
      'investigation-price-list-seed': 1
      'service-price-list-seed': 1
      'supply-price-list-seed': 1
      'ambulance-price-list-seed': 1
      'package-price-list-seed': 1
      'other-price-list-seed': 1
      'income-item-seed': 1
      'expense-item-seed': 1
      'vital-record-seed': 0
      'inventory-seed': 1
      'internal-inventory-seed': 1
      'message-share-seed': 1
      'third-party-user-seed': 1
      'notification-group': 1
      'visited-patient-log': 1
      'ot-management-seed': 1
      'ot-template-seed': 1
      'org-role-item-log': 1
      'organization-chamber-seed': 1
      'organization-discount-fund-seed': 1
      'patient-consent-form-seed': 1
      'slocation-seed': 1
      'accounts-income-seed': 0
      'accounts-income-categories-seed': 0
      'accounts-expense-seed': 0
      'pharmacy-supplier-invoice-seed': 1
      'accounts-expense-categories-seed': 0
      'employee-serial-seed': 1
      'third-party-seed': 0
      'top-sheet-seed': 0
      'duty-roster-location-seed': 0
      'complain-box-seed': 0
      'exam-question-seed' : 1
      'exam-choices-id-seed': 0
      'academic-session-seed': 1
      'referral-doctor-seed': 0
      'organization-third-party-payment-seed': 1

    app.db.insert '--serial-generator', serialGenerator

    lib.tabStorage.setItem 'is-tab-authenticated', (lib.json.stringify true)

  getDashboardMetrics: ->

    metrics = {}

    ## NOTE newPatientCount
    # patientList = app.db.find 'patient-list', ({createdDatetimeStamp})-> 
    #   lhs = lib.datetime.mkDate (new Date createdDatetimeStamp)
    #   rhs = lib.datetime.mkDate lib.datetime.now()
    #   return (lhs is rhs)
    # metrics.newPatientCount = patientList.length

    ## NOTE totalPatientCount
    # metrics.totalPatientCount = (app.db.find 'patient-list').length

    ## NOTE newVisitCount
    # metrics.newVisitCount = 0

    ## NOTE totalVisitCount
    # metrics.totalVisitCount = 0

    ## NOTE totalUnpaidInvoiceCount
    # metrics.totalUnpaidInvoiceCount = 0

    ## NOTE daysLeft
    user = (app.db.find 'user')[0]
    dt = new Date user.accountExpiresOnDate
    now = new Date lib.datetime.mkDate lib.datetime.now()
    metrics.daysLeft = Math.floor ((lib.datetime.diff dt, now) / 1000 / 60 / 60 / 24)

    return metrics

  getCurrentUser: -> (app.db.find 'user')[0]
  getCurrentUserSerial: -> (app.db.find 'user')[0].serial
  getCurrentOrganization: -> (app.db.find 'organization')[0]

  generateSerialForPatient: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'P'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    patientSeed = serialGenerator['patient-seed']
    serialGenerator['patient-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + patientSeed)

  generateSerialForVisit: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'V'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-seed']
    serialGenerator['doctor-visit-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  
  generateSerialForPatientTypeLog: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PTPLOG'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['patient-type-log-seed']
    serialGenerator['patient-type-log-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForTestAdvised: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TA'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-test-advise-seed']
    serialGenerator['doctor-visit-test-advise-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForTestAdvisedInvestigation: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TAI'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-test-advise-seed']
    serialGenerator['doctor-visit-test-advise-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  generateSerialForSettings: ->
    appIdentifier = 'C'
    itemType = 'Setting'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType )

  generateSerialForCustomInvestigation: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CI'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-test-advise-seed']
    serialGenerator['doctor-visit-test-advise-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForTestResuts: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TR'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-test-results-seed']
    serialGenerator['doctor-visit-test-results-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForTestResutSamples: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'S'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-visit-test-results-seed']
    serialGenerator['doctor-visit-test-results-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForPatientStay: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PS'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-patient-stay-seed']
    serialGenerator['doctor-patient-stay-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateSerialForCovidRespirator: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CRFT'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['covid-respirator-fit-test-seed']
    serialGenerator['covid-respirator-fit-test-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateSerialForCustomCovidRespiratorModel: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CCRTM'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['custom-covid-respirator-fit-test-seed']
    serialGenerator['custom-covid-respirator-fit-test-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForCovidVaccination: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CV'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['covid-vaccination-seed']
    serialGenerator['covid-vaccination-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateSerialForFavoriteInvestigation: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'FI'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['favorite-investigation-seed']
    serialGenerator['favorite-investigation-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForReferenceByList: ()->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'RBL'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['invoice-reference-by-list']
    serialGenerator['invoice-reference-by-list'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + itemType + seed)


  generateSerialForUserAddedInstituion: (forItem)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'UI'
    forItem = forItem
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['user-added-institution-list-seed']
    serialGenerator['user-added-institution-list-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + forItem + seed)

  generateSerialForAttachmentBlob: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'AttBlob'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['attachment-record-seed']
    serialGenerator['attachment-record-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForAttachmentSync: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'AttSync'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['attachment-record-seed']
    serialGenerator['attachment-record-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForUserAddedCheckedByUser: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'RD'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['user-added-reported-doctor-seed']
    serialGenerator['user-added-reported-doctor-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForUserAddedReportedDoctor: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CB'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['user-added-checked-by-user-list-seed']
    serialGenerator['user-added-checked-by-user-list-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  
  
  generateSerialForInvestigationPriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'InvP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialDoctorFees: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'DocFeeP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)
  
  generateSerialForServicePriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'SvcP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForAmbulancePriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'AmbP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForPharmacyPriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PhaP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForSupplyPriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'SupP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForPackagePriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PackP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForOtherPriceList: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + orgnizationId)

  generateSerialForInvoice: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Inv'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['patient-invoice-seed']
    serialGenerator['patient-invoice-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForIncome: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'AccI'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['accounts-income-seed'] or 0
    serialGenerator['accounts-income-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForExpense: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'AccEx'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['accounts-expense-seed'] or 0
    serialGenerator['accounts-expense-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForSupplierInvoice: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PharmaSuppInv'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['pharmacy-supplier-invoice-seed'] or 0
    serialGenerator['pharmacy-supplier-invoice-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForInventoryItem: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Inventory'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['inventory-seed']
    serialGenerator['inventory-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForInternalInventoryItem: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'II'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['internal-inventory-seed']
    serialGenerator['internal-inventory-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForMessageShare: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'MS'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['message-share-seed']
    serialGenerator['message-share-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForThirdParty: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['third-party-seed']
    serialGenerator['third-party-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForIncomeItem: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OI'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['income-item-seed'] or 0
    serialGenerator['income-item-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  
  generateSerialForThirdPartyUser: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TPU'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['third-party-user-seed']
    serialGenerator['third-party-user-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateSerialForNotificationGroup: ()->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'NG'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['notification-group-seed']
    serialGenerator['notification-group-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForVisitedPatientLog: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'VP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['visited-patient-log']
    serialGenerator['visited-patient-log'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialInvoiceCategory: ()->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'IC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + 'only')

  generateSerialForOt: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Ot'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['ot-management-seed']
    serialGenerator['ot-management-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  
  generateSerialForOtTemplate: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OTTMPLT'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['ot-template-seed']
    serialGenerator['ot-template-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  

  generateSerialForThirdPartySuperVisor: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TPS'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['third-party-supervisor-list-seed']
    serialGenerator['third-party-supervisor-list-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
    
  generateSerialCustomCategory: ()->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'UC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType + 'only')


  generateSerialForOrgRole: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'R'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['org-role-item-log']
    serialGenerator['org-role-item-log'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForPccRecord: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'PCC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-pcc-seed']
    serialGenerator['doctor-pcc-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForNdrRecord: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'NDR'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['doctor-ndr-seed']
    console.log 'seed', seed
    serialGenerator['doctor-ndr-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForVitals: (forItem)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'V'
    forItem = forItem
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['vital-record-seed']
    serialGenerator['vital-record-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + forItem + seed)

  generateSerialForDiagnosis: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Dg'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['diagnosis-seed']
    serialGenerator['diagnosis-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForOfflinePatient: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OFFPT'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['offline-patient-serial-seed']
    console.log 'seed', seed
    serialGenerator['offline-patient-serial-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForChamber: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Chamber'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['organization-chamber-seed'] or 0
    serialGenerator['organization-chamber-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForDiscountFund: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'DF'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['organization-discount-fund-seed']
    serialGenerator['organization-discount-fund-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForCommissionCategory: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['organization-commission-category-seed']
    serialGenerator['organization-commission-category-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForThirdPartyPayment: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TP'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['organization-third-party-payment-seed'] or 0
    serialGenerator['organization-third-party-payment-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateSerialForTopSheetEntry: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'TSE'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['top-sheet-seed']
    serialGenerator['top-sheet-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  generateConsentFormSerial:->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CF'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['patient-consent-form-seed'] or 0
    serialGenerator['patient-consent-form-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForSeatLocations:(item)->
    appIdentifier = window.osntifier + 'C'
    itemType = 'SL'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['seat-location-seed'] or 0
    serialGenerator['seat-location-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)


  getSerialForSettings: ->
    appIdentifier = 'C'
    itemType = 'Setting'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    return (appIdentifier + userSerial + itemType )

  generateSerialForCustomIncomeCategory:->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OIC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['accounts-income-categories-seed'] or 0
    serialGenerator['accounts-income-categories-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForCustomExpenseCategory:->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'OEC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['accounts-expense-categories-seed'] or 0
    serialGenerator['accounts-expense-categories-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)
  
  generateSerialForNewEmployee: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Employee'
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['employee-serial-seed'] or 0
    serialGenerator['employee-serial-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier +  itemType + orgnizationId + seed)
  
  generateSerialForDutyRosterLocation: (orgnizationId)->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'DTY'
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['duty-roster-location-seed'] or 0
    serialGenerator['duty-roster-location-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier +  itemType + seed)
  
  generateSerialForComplainBox: ()->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'CCB'
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['complain-box-seed'] or 0
    serialGenerator['complain-box-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier +  itemType + seed)

  generateSerialForOnlineExamQuestion: ->
    appIdentifier = 'C'
    itemType = 'OE'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    unless 'exam-question-seed' of serialGenerator
      serialGenerator['exam-question-seed'] = 0
    seed = serialGenerator['exam-question-seed']
    serialGenerator['exam-question-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial.toUpperCase() + sessionSerial + itemType + seed)

  generateIdForChoices: ->
    appIdentifier = 'C'
    itemType = 'ID'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    unless 'exam-choices-id-seed' of serialGenerator
      serialGenerator['exam-choices-id-seed'] = 0
    seed = serialGenerator['exam-choices-id-seed']
    serialGenerator['exam-choices-id-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + sessionSerial + itemType + seed)
    
  generateSerialForNewAcademicSession: (orgnizationId)->
    appIdentifier = 'C'
    itemType = 'AS'
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['academic-session-seed'] or 0
    serialGenerator['academic-session-seed'] = seed + 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier +  itemType + orgnizationId + seed)
  
  generateSerialForActivity: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'Act'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['activity-seed']
    serialGenerator['activity-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)

  generateSerialForReferralDoctor: ->
    appIdentifier = window.onsiteDeploymentIdentifier + 'C'
    itemType = 'REFDOC'
    { serial: userSerial, sessionSerial } = (app.db.find 'user')[0]
    serialGenerator = (app.db.find '--serial-generator')[0]
    seed = serialGenerator['referral-doctor-seed'] or 0
    serialGenerator['referral-doctor-seed'] += 1
    app.db.update '--serial-generator', serialGenerator._id, serialGenerator
    return (appIdentifier + userSerial + sessionSerial + itemType + seed)