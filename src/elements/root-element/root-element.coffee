
__isPreloadCalled = false

Polymer {

  is: 'root-element'

  behaviors: [
    app.behaviors.commonComputes
    app.behaviors.apiCalling
    app.behaviors.dbUsing
    app.behaviors.debug
    app.behaviors.local['root-element'].dataLoader
    app.behaviors.local['root-element'].newSync
    # app.behaviors.local['root-element'].dataSyncConfig
    # app.behaviors.local['root-element'].dataSync
    # app.behaviors.local['root-element'].userDataSync
    # app.behaviors.local['root-element'].userDataSyncConfig
    # app.behaviors.local['root-element'].organizationDataSyncConfig
    # app.behaviors.local['root-element'].organizationDataSync
  ]

  properties:

    page:
      type: Object
      observer: '_mainViewPageChanged'

    downloadActions:
      type: Object
      value: 
        count: 0
        seed: 0
        list: []
    
    organizationSelectedPageIndex:
      type: Number
      value: 0
      notify: true
      observer: '_organiztionPageIndexChanged'

    accountsSelectedPageIndex:
      type: Number
      value: 0
      notify: true
      observer: '_accountsPageIndexChanged'

    syncActions:
      type: Object
      value:
        count: 0
        seed: 0
        list: []

    apiActions:
      type: Object
      value: 
        count: 0
        seed: 0
        list: []

    currentNavigationCandidate:
      type: String
      value: ''

    readyPageNodeNameList:
      type: Array
      value: []

    genericModalDialogContents: 
      type: String
      value: 'Content goes here...'

    genericToastContents:
      type: String
      value: 'Content goes here...'

    genericModalInputFieldValue: 
      type: String
      value: ''
      notify: true

    currentPatientsName:
      type: String
      value: null

    currentOrganization:
      type: Object
      value: {}

    currentAd: 
      type: Object

    hideAd:
      type: Boolean
      value: false

    isMobile:
      type: Boolean
      value: false

    currentPatientsDetails:
      type: Object
      value:
        name: null
        serial: null
      notify: true
    
    organizationFeatureList:
      type: Array
      value: []

    accountsFeatureList:
      type: Array
      value: []

    navigationList:
      type: Array
      value: []
    
    typesOfBalance:
      type: Object
      value: null
    
    showVidoeBtn:
      type: Boolean
      value: false
    
    incomingVideoCall:
      type: Object
      value: null
    
    activeUserList:
      type: Object
      value: []

    walletBalance:
      type: Number
      value: 0      


  observers: [ 
    '_routerHrefChanged(routeData.page)'
  ]


  _checkUserActivation: (user, cbfn)->
    # console.log user.mode
    if user.mode is 'dev'
      cbfn()
      return
  
    dt = new Date user.accountExpiresOnDate
    now = new Date lib.datetime.mkDate lib.datetime.now()
    daysLeft = Math.floor ((lib.datetime.diff dt, now) / 1000 / 60 / 60 / 24)
    if daysLeft < 0
      @navigateToPage '#/activate'
      return
    else
      cbfn()

  removeOldAndSaveNewSettings: (newSettings, cbfn)->
    newSettings.idOnServer = newSettings._id
    app.db.remove 'settings', item._id for item in app.db.find 'settings'
    app.db.insert 'settings', newSettings
    cbfn()

  _organiztionPageIndexChanged: (newIndex, oldIndex)->
    # console.log(newIndex, oldIndex)
    @set 'organizationSelectedPageIndex', newIndex

  _accountsPageIndexChanged: (newIndex, oldIndex)->
    @set 'accountsSelectedPageIndex', newIndex

  getFullName:(data)->

    if typeof data is "object"
      honorifics = ''
      first = ''
      last = ''
      middle = ''

      if data.honorifics  
        honorifics = data.honorifics + ". "
      if data.first
        first = data.first
      if data.middle
        middle = " " + data.middle
      if data.last
        last = " " + data.last
        
      return honorifics + first + middle + last

    else return data

  _computeAge: (dateString)->
    today = new Date()
    birthDate = new Date dateString
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()

    if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
      age--
    
    return age


  notifySyncAction: (action, moreData...)->
    if action is 'start'
      @syncActions.count += 1
      @notifyPath 'syncActions.count'
      [ path ] = moreData
      obj =
        id: @syncActions.seed++
        path: moreData[path]
        time: lib.datetime.now()
        action: 'start'
      @syncActions.list.push obj
      return obj.id
    else if action is 'done'
      @syncActions.count -= 1 unless @syncActions.count is 0
      @notifyPath 'syncActions.count'
      [ path, refId ] = moreData
      obj =
        id: @syncActions.seed++
        path: path
        refId: refId
        action: 'done'
      @syncActions.list.push obj
      return obj.id
    else if action is 'error'
      @apiActions.count -= 1 unless @apiActions.count is 0
      @notifyPath 'apiActions.count'
      [ path, refId ] = moreData
      obj =
        id: @apiActions.seed++
        path: path
        refId: refId
        action: 'error'
      @apiActions.list.push obj
      return obj.id

  notifyApiAction: (action, moreData...)->
    if action is 'start'
      @apiActions.count += 1
      @notifyPath 'apiActions.count'
      [ path ] = moreData
      obj = 
        id: @apiActions.seed++
        path: moreData[path]
        time: lib.datetime.now()
        action: 'start'
      @apiActions.list.push obj
      return obj.id
    else if action is 'done'
      @apiActions.count -= 1 unless @apiActions.count is 0
      @notifyPath 'apiActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @apiActions.seed++
        path: path
        refId: refId
        action: 'done'
      @apiActions.list.push obj
      return obj.id
    else if action is 'error'
      @apiActions.count -= 1 unless @apiActions.count is 0
      @notifyPath 'apiActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @apiActions.seed++
        path: path
        refId: refId
        action: 'error'
      @apiActions.list.push obj
      return obj.id

  notifyDownloadAction: (action, moreData...)->
    if action is 'start'
      @downloadActions.count += 1
      @notifyPath 'downloadActions.count'
      [ path ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: moreData[path]
        time: lib.datetime.now()
        action: 'start'
      @downloadActions.list.push obj
      return obj.id
    else if action is 'done'
      @downloadActions.count -= 1 unless @downloadActions.count is 0
      @notifyPath 'downloadActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: path
        refId: refId
        action: 'done'
      @downloadActions.list.push obj
      return obj.id
    else if action is 'error'
      @downloadActions.count -= 1 unless @downloadActions.count is 0
      @notifyPath 'downloadActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: path
        refId: refId
        action: 'error'
      @downloadActions.list.push obj
      return obj.id

  _generateSideNavigationLinks: ->
    currentOrganization = @getCurrentOrganization()

    if currentOrganization
      navigationList = app.pages.pageList.filter (item)=>
        return item.showOnSideNav and (@_checkUserAccess item.accessId) and (if item.forPccOnly then currentOrganization.markAsPccOrganization else true) and (if item.forNwdrOnly then currentOrganization.markAsNwdrOrganization else true)
      @set 'navigationList', navigationList

  getLink:(name)-> 
    pagesNeedOrganizationId = [
      'organization-dashboard',
      'accounts-manager-dashboard', 
      'organization-view-all-waitlist'
    ]
    if name in pagesNeedOrganizationId 
      return "#/#{name}/organization:#{@currentOrganization.idOnServer}"
    return "#/#{name}"

  sortFn:(a,b)-> a.index - b.index

  filterFn: (searchString)->
    if !searchString
      return null
    else
      return (item)->
        regex = new RegExp "\\b#{searchString}", 'gi'
        return true if regex.test item.headerTitle

  _routerHrefChanged: (href) ->
    # @debug '_routerHrefChanged', href
    href = '/' unless href
    wasPageFound = false
    possiblePage = null

    for page in app.pages.pageList
      if href in page.hrefList
        possiblePage = page
        wasPageFound = true
        break

    if wasPageFound
      
        if possiblePage.requireAuthentication
          if @isUserLoggedIn()
            if @_checkUserAccess possiblePage.accessId
              if possiblePage.requireAuthentication
                user = (app.db.find 'user')[0]
                @_checkUserActivation user, =>
                  @page = possiblePage
              else
                @page = possiblePage
            else
              @page = app.pages.accessDenied
          else
            @navigateToPage '#/login'
        else
          @page = possiblePage
    else
      @page = app.pages.error404


  _preloadOtherPages: ->
    # @debug '_preloadOtherPages'
    fullPageList = [].concat app.pages.pageList, [ app.pages.error404, app.pages.accessDenied ]

    for page in fullPageList
      do (page)=>
        unless page.name is @page.name
          pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
          id = @notifyDownloadAction 'start', pagePath
          successCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'done', pagePath, id
          failureCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'error', pagePath, id
          @importHref pagePath, successCbfn, failureCbfn, true

  _mainViewPageChanged: (page) ->
    # @debug '_mainViewPageChanged', page.name

    ## call preload only if not already preloaded
    callPreloaderAfterCheckingFn = =>
      return if __isPreloadCalled
      __isPreloadCalled = true
      ## FIXME - This feature does not work
      # @_preloadOtherPages() 

    ## load page import on demand.
    pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
    @importHref pagePath, callPreloaderAfterCheckingFn, callPreloaderAfterCheckingFn, false

    @_hideAd page.name
    # @toggleVideoBtn page.name

  _fillIronPagesFromPageList: ->
    ironPages = Polymer.dom(@root).querySelector 'iron-pages'

    fullPageList = [].concat app.pages.pageList, app.pages.error404, app.pages.accessDenied

    for page in fullPageList
      pageElement = document.createElement page.element
      pageElement.setAttribute 'name', page.name

      Polymer.dom(ironPages).appendChild pageElement

  created: ->
    @removeUserUnlessSessionIsPersistent()

  _clearVideoCallData: ->
    localStorage.setItem "visibleVideoButton", false
    localStorage.setItem "videoCallSessionId", ''

  toggleVideoBtn: (pageName)->
    if pageName is 'video-chat'
      @set "showVidoeBtn", false
      return

    visibleVideoButton = localStorage.getItem("visibleVideoButton")
    # console.log {visibleVideoButton}
    if visibleVideoButton is "true"
      @set "showVidoeBtn", true
      return
    else
      @set "showVidoeBtn", false

  _joinSessionCalled: (sessionId, cbfn)->
    @callApi '/bdemr-tokbox-get-session-token', { apiKey: @user.apiKey, sessionId: sessionId }, (err, response) =>
      return err if err
      return @domHost.showModalDialog response.error.message if response.hasError
      cbfn response.data

  _createNewSessionFromServer: (cbfn)->
    this.callApi '/bdemr-tokbox-create-session' , { apiKey: @user.apiKey }, (err, response) =>
      return @domHost.showModalDialog response.error.message if response.hasError
      return err if err
      cbfn response.data

  # goToVideoCall: ->
  #   @navigateToPage '#/video-chat'
    
  attached: ->
    @loadStaticData()

  checkKeyPress:(key)->
    if @page.showAccountsDashboardTabs
      if key.keyCode is 9
        console.log {item, index}
        
        @set 'accountsSelectedPageIndex', @accountsSelectedPageIndex + 1
        if @accountsSelectedPageIndex >= @accountsFeatureList.length
          @set 'accountsSelectedPageIndex', 0
          @navigateToPage '#/' + @accountsFeatureList[@accountsSelectedPageIndex].url + '/organization:' + @currentOrganization.idOnServer           
        else
          @navigateToPage '#/' + @accountsFeatureList[@accountsSelectedPageIndex].url + '/organization:' + @currentOrganization.idOnServer           


  ready: ->
    title = document.getElementsByTagName('title')[0]
    title.innerText =  "Pharmacy App " + app.config.clientVersion

    # reset visibleVideoButton prop
    localStorage.setItem "visibleVideoButton", false
    this.addEventListener('keydown', @checkKeyPress,false)
    
    # @showModalDialog 'Our service was down for technical issues at Google Server, We are sorry for the earlier inconvience, Thank you for your patience'

    @_fillIronPagesFromPageList()
    @_generateSideNavigationLinks()
    @makeOrganizationFeatureListMap()
    @makeAccountsFeatureListMap()
    @currentPatientsName = localStorage.getItem("currentPatientsName")

    patientsDetails = localStorage.getItem("currentPatientsDetails")
    @currentPatientsDetails = JSON.parse(patientsDetails)

    if @isUserLoggedIn()
      @_callAfterUserLogsIn()
      if @currentOrganization
        @$getOrganizationSpecificUserSettings @user.apiKey, @currentOrganization.idOnServer, (newSettings)=>
          @removeOldAndSaveNewSettings newSettings, => null


  _openSocket: ()->
    serverHost = app.config.variableConfigs[app.mode].serverHost
    @socket = io serverHost
    @socket.emit "new user", { userId: @user.idOnServer, isUserThemselvesADoctor: @user.isUserThemselvesADoctor }
    apiKey = @getCurrentUser().apiKey
    @socket.emit "message", { operation: 'register', apiKey } 

    @socket.on 'active user list', (data)=>
      @activeUserList = data.activeUserList
      console.log {@activeUserList}
      
      @fire "active-users", { activeUserList: @activeUserList }, {
        node: @$$ 'agent-panel'
        bubbles: true
      }

    @socket.on 'message', (json)=>
      console.log {json}
      json.markedAsRead = false

      if json.category is "video-chat"
        @incomingVideoCall = json
        @set "videoCallSessionId", json.videoChatSessionId
        # @incomingVideoCall.index = (app.db.find 'in-app-notification', ({category})=> return true if category is 'video-chat').length - 1
        @$$('#incomingCallTone').play()
        @$$("#incomingVideoCallDialog").toggle()
      else
        app.db.insert 'in-app-notification', json
        @updateNotificationView()
        @showNotification json


  _closeSocket: ()->
    # serverHost = app.config.variableConfigs[app.mode].serverHost
    # socket = io serverHost
    @socket.emit "remove user", { userId: @user.idOnServer, isUserThemselvesADoctor: @user.isUserThemselvesADoctor }

  makeOrganizationFeatureListMap: ()->
    currentOrganization = @getCurrentOrganization()
    
    organizationFeatureList = [
      {
        type: 'organization-dashboard'
        title: 'Dashboard'
        url: 'organization-dashboard'
        isHidden: false
      }
      {
        type: 'organization-manager'
        title: 'Manage Organization'
        url: 'organization-manager'
        isHidden: false
      }
      {
        type: 'manage-joining-request'
        title: 'Manage Joining Request'
        url: 'manage-joining-request'
        isHidden: false
      }

      {
        type: 'pcc-reports'
        title: 'PCC'
        url: 'pcc-reports'
        isHidden: true
      }
      {
        type: 'nwdr-reports'
        title: 'NWDR'
        url: 'nwdr-reports'
        isHidden: true
      }
      {
        type: 'organization-manage-users'
        title: 'Users'
        url: 'organization-manage-users'
        isHidden: false
      }
      {
        type: 'organization-manage-patient-stay'
        title: 'Patient Stay'
        url: 'organization-manage-patient-stay'
        isHidden: false
      }
      {
        type: 'organization-manage-waitlist'
        title: 'Waitlist'
        url: 'organization-manage-waitlist'
        isHidden: false
      }
      {
        type: 'organization-medicine-sales-statistics'
        title: 'Medicine sales'
        url: 'organization-medicine-sales-statistics'
        isHidden: false
      }
      {
        type: 'organization-manage-patient'
        title: 'Wallet for Patient'
        url: 'organization-manage-patient'
        isHidden: false
      }
      {
        type: 'organization-records'
        title: 'Records'
        url: 'organization-records'
        isHidden: false
      }
      # {
      #   type: 'set-unit-price'
      #   title: 'Unit Price'
      #   url: 'set-unit-price'
      # }
      # {
      #   type: 'pharmacy-manager'
      #   title: 'Pharmacy'
      #   url: 'pharmacy-manager'
      # }
    ]   

    if currentOrganization
      for item, index in organizationFeatureList
        if (item.type is 'pcc-reports') and (currentOrganization.markAsPccOrganization)
          organizationFeatureList[index].isHidden = false
        if (item.type is 'nwdr-reports') and (currentOrganization.markAsNwdrOrganization)
          organizationFeatureList[index].isHidden = false
      # console.log organizationFeatureList, currentOrganization
      @set 'organizationFeatureList', organizationFeatureList
    
  onOrganizationFeaturePaperTabButtonPressed:(e)->
    {item, index} = e.model
    @navigateToPage '#/' + item.url + '/organization:' + @currentOrganization.idOnServer

  makeAccountsFeatureListMap: ()->
    currentOrganization = @getCurrentOrganization()
    
    accountsFeatureList = [
      {
        type: 'accounts-manager-dashboard'
        title: 'Accounts Dashboard'
        url: 'accounts-manager-dashboard'
        isHidden: false
      }
      {
        type: 'invoice-report'
        title: 'Invoice Report'
        url: 'invoice-report'
        isHidden: false
      }          
      {
        type: 'accounts-cash-balance'
        title: 'Cash Balance'
        url: 'accounts-cash-balance'
        isHidden: false
      }      
      {
        type: 'accounts-salary-manager'
        title: 'Salary Manager'
        url: 'accounts-salary-manager'
        isHidden: false
      }      
      {
        type: 'accounts-income-manager'
        title: 'Income Manager'
        url: 'accounts-income-manager'
        isHidden: false
      }      
      {
        type: 'accounts-clone-income-manager'
        title: 'Clone Income Manager'
        url: 'accounts-clone-income-manager'
        isHidden: false
      }      
      {
        type: 'accounts-expense-manager'
        title: 'Expense Manager'
        url: 'accounts-expense-manager'
        isHidden: false
      }      
      {
        type: 'accounts-handover'
        title: 'Accounts Handover'
        url: 'accounts-handover'
        isHidden: false
      }      
      {
        type: 'third-party-payment-manager'
        title: 'Third Party Payment Manager'
        url: 'third-party-payment-manager'
        isHidden: false
      }      
      {
        type: 'top-sheet'
        title: 'Top Sheet'
        url: 'top-sheet'
        isHidden: false
      }      
      {
        type: 'commission-category-manager'
        title: 'Commission Category Manager'
        url: 'commission-category-manager'
        isHidden: false
      }      
      {
        type: 'accounts-report'
        title: 'Accounts Report'
        url: 'accounts-report'
        isHidden: false
      }      
      {
        type: 'commission-report'
        title: 'Commission Report'
        url: 'commission-report'
        isHidden: false
      }      
      {
        type: 'fund-report'
        title: 'Fund Report'
        url: 'fund-report'
        isHidden: false
      }      
      {
        type: 'due-guarantor-report'
        title: 'Due Guarantor Report'
        url: 'due-guarantor-report'
        isHidden: false
      }      
      {
        type: 'discout-report'
        title: 'Discount Report'
        url: 'discount-report'
        isHidden: false
      }      
      {
        type: 'billing-report'
        title: 'Billing Report'
        url: 'billing-report'
        isHidden: false
      }      
    ]

    @set 'accountsFeatureList', accountsFeatureList

  onAccountsFeaturePaperTabButtonPressed:(e)->
    {item, index} = e.model
    console.log event
    @navigateToPage '#/' + item.url + '/organization:' + @currentOrganization.idOnServer           


  # _getUserInfo: ()->
  #   @callApi '/get-user-info-without-organization-id', { apiKey: @user.apiKey }, (err, response)=>
  #     if response.hasError
  #       @showModalDialog response.error.message
  #     else
  #       user = response.data
  #       # console.log user
  #       for role in user.roles
  #         if role.roleType == 'agent'
  #           @isUserAgent = true
  #           return

  _callAfterUserLogsIn: ->
    @user = @getCurrentUser()
    # console.log 'user', @user
    if @user.apiKey
      @isUserAgent = @user.isUserAgent
      @_loadWallet()
    # @inAppNotificationSystemInitiate()
    # @_openSocket()
    # @updateNotificationView()
    # @initiateAdvertisement()
    currentOrganization = @getCurrentOrganization()
    
    if currentOrganization
      @set 'currentOrganization', currentOrganization
      @loadTypesOfUserBalance currentOrganization.idOnServer
    else
      @set 'currentOrganization', null
      return @navigateToPage "#/select-organization"

  setCurrentPatientsDetails:(data)->
    @set 'currentPatientsDetails', data
    localStorage.setItem("currentPatientsDetails", JSON.stringify @currentPatientsDetails)


  _showSyncButton: (syncActionsCount, downloadActionsCount)->
    if downloadActionsCount
      return false
    else if syncActionsCount
      return false
    else
      return true

  _hideAd: (pageName)->
    if @isMobile
      hideOnPage = ['login', 'patient-manager', 'create-invoice', 'print-invoice', 'video-chat']
    else
      hideOnPage = ['login', 'create-invoice', 'print-invoice', 'video-chat']

    if pageName in hideOnPage
      @set 'hideAd', true
      @toggleClass 'show-ad', false, @.$.mainHeader
    else
      @set 'hideAd', false
      @toggleClass 'show-ad', true, @.$.mainHeader

  setCurrentPatientsName:(currentPatientsName)->
    @currentPatientsName = currentPatientsName
    localStorage.setItem("currentPatientsName", @currentPatientsName);

  getYear: ->
    return (new Date).getFullYear()

  refreshButtonPressed: (e)->
    @reloadPage()

  logoutPressed: (e)->
    user = (app.db.find 'user')[0]
    @_closeSocket()
    if navigator.onLine and e
      @callApi '/bdemr-app-logout', {apiKey: user.apiKey}, (err, response)=> @$$('app-drawer').toggle()

    app.db.remove 'user', user._id
    @navigateToPage '#/login'

    # @reloadPage()

  # === NOTE - Common Dialog Boxes ===

  showModalDialog: (content)->
    @genericModalDialogContents = content
    @$$('#generic-modal-dialog').toggle()
    @$$('#generic-modal-dialog').center()

  toggleModalLoader: (message=null)->
    @set 'loaderMessage', message
    @$$("#generic-loader-dialog").toggle()

  showModalPrompt: (content, doneCallback)->
    @genericModalPromptContents = content
    @$$('#generic-modal-prompt').toggle()
    @genericModalPromptDoneCallback = doneCallback

  showModalInput: (content, defaultString, doneCallback)->
    @genericModalInputContents = content
    @genericModalInputFieldValue = defaultString
    @$$('#generic-modal-input').toggle()
    @genericModalInputDoneCallback = doneCallback

  genericModalInputClosed: (e)->
    if e.detail.confirmed
      @genericModalInputDoneCallback @genericModalInputFieldValue
    else
      @genericModalInputDoneCallback false
    @genericModalInputDoneCallback = null

  genericModalPromptClosed: (e)->
    if e.detail.confirmed
      @genericModalPromptDoneCallback true
    else
      @genericModalPromptDoneCallback false
    @genericModalPromptDoneCallback = null

  showToast: (content)->
    @genericToastContents = content
    @$$('#toast1').open()

  genericToastTapped: (e)->
    @$$('#toast1').close()

  showSuccessToast: (content)->
    @genericToastContents = content
    @$$('#successToast').open()

  successToastTapped: (e)->
    @$$('#successToast').close()

  showWarningToast: (content)->
    @genericToastContents = content
    @$$('#warningToast').open()

  warningToastTapped: (e)->
    @$$('#warningToast').close()

  # === NOTE - These events are manually delegated to pages ===

  saveButtonPressed: (e)->
    @$$('iron-pages').selectedItem.saveButtonPressed e

  printButtonPressed: (e)->
    @$$('iron-pages').selectedItem.printButtonPressed e

  arrowBackButtonPressed: (e)->
    @$$('iron-pages').selectedItem.arrowBackButtonPressed e

  # === NOTE - navigation code ===

  getPageParams: ->
    hash = window.location.hash
    hash = hash.replace '#/', ''
    partArray = hash.split '/'
    partArray.shift()
    params = {}
    for part in partArray
      if part.indexOf(':') is -1
        @showModalDialog 'Malformatted Url Given'
        break
      [ left, right ] = part.split ':'
      params[left] = right
    return params

  navigateToPage: (path)->
    window.location = path

  navigateToPreviousPage: ->
    window.history.back()

  modifyCurrentPagePath: (newPath)->
    window.history.replaceState {}, newPath, newPath

  reloadPage: ->
    window.location.reload()


  # === NOTE - The code below generates the pseudo-lifetime-callback 'navigatedIn' ===

  ironPagesSelectedEvent: (e)->
    return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
    nodeName = e.detail.item.nodeName
    for readyPageNodeName in @readyPageNodeNameList
      if readyPageNodeName is nodeName
        e.detail.item.navigatedIn() if e.detail.item.navigatedIn
        return
    @currentNavigationCandidate = nodeName

  pageReady: (pageElement, templateElement=false)->
    if templateElement
      pageElement.navigatedIn() if pageElement.navigatedIn
      return
    @readyPageNodeNameList.push pageElement.nodeName
    if @currentNavigationCandidate is pageElement.nodeName
      @currentNavigationCandidate = ''
      pageElement.navigatedIn() if pageElement.navigatedIn

  ironPagesDeselectedEvent: (e)->
    return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
    nodeName = e.detail.item.nodeName
    for readyPageNodeName in @readyPageNodeNameList
      if readyPageNodeName is nodeName
        e.detail.item.navigatedOut() if e.detail.item.navigatedOut
        return

  changeOrganizationClicked: ->
    @navigateToPage "#/select-organization"

  # Load Organization SMS Balance ======================================

  loadTypesOfUserBalance: (organizationId)->
    data = {
      apiKey: @user.apiKey
      organizationId
    }

    @callApi '/bdemr-get-types-of-balance', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'typesOfBalance', response.data
  
  # Notification Area ======================================
  
  _formatDateTime: (dateTime)->
    return unless dateTime
    lib.datetime.format dateTime, 'mmm d, yyyy h:MMTT'

  inAppNotificationSystemInitiate: ->
    webSocketHost = app.config.variableConfigs[app.mode].serverWsHost
    @set 'ws', (new WebSocket webSocketHost, [
      'soap'
      'xmpp'
    ])
    console.log {@ws}
    @ws.addEventListener 'open', (e)=>
      @inAppNotificationRegister()
      @ws.addEventListener 'message', ((e)=> @inAppNotificationMessageHandler e), false, false

  inAppNotificationMessageHandler: (e)->
    json = JSON.parse e.data
    if json.operation is 'register' and json.status is 'successful'
      @inAppNotificationMyId = json.userId
    else if json.operation is 'incoming-notification'
      # console.log 'incoming'
      json.markedAsRead = false
      console.log json

      if json.category is "video-chat"
        @incomingVideoCall = json
        @set "videoCallSessionId", json.videoChatSessionId
        # @incomingVideoCall.index = (app.db.find 'in-app-notification', ({category})=> return true if category is 'video-chat').length - 1
        @$$('#incomingCallTone').play()
        @$$("#incomingVideoCallDialog").toggle()
      else
        app.db.insert 'in-app-notification', json
        @updateNotificationView()
        @showNotification json


  inAppNotificationRegister: ->
    apiKey = @getCurrentUser().apiKey
    request = {
      operation: 'register'
      apiKey
    }
    @socket.emmit('message', JSON.stringify request);

  showNotification: (json)->
    switch json.category
      when 'patientNote' then title = 'New Patient Note'
      when 'report' then title = 'Report'
      when 'onlineConsultation' then title = 'New Consulation Request'
      when 'general' then title = 'General'
      else title = 'New Notification'

    notificationConfig = {
      body: json.message
      icon: '../../images/web-app-icon/app-icon-72.png'
      timestamp: json.createdDateTimeStamp
      sound: '../../assets/notification.mp3'
    }

    if !('Notification' of window)
      alert message
    else if Notification.permission == 'granted'
      notification = new Notification 'New Notification', notificationConfig
    else if Notification.permission != 'denied'
      Notification.requestPermission (permission) ->
        if permission == 'granted'
          notification = new Notification 'New Notification', notificationConfig
          audio = new Audio '../../assets/notification.mp3'
          audio.play()
  
  updateNotificationView: ->
    @reportNotification = app.db.find 'in-app-notification', ({category})=> return true if category is 'report'
    @userNoteNotification = app.db.find 'in-app-notification', ({category})=> return true if category is 'patientNote'
    @onlineConsultationNotification = app.db.find 'in-app-notification', ({category})=> return true if category is 'onlineConsultation'
    @generalNotification = app.db.find 'in-app-notification', ({category})=> return true if category is 'general'
    @allNotification = app.db.find 'in-app-notification'
    # @videoChat = app.db.find 'in-app-notification', ({category})=> return true if category is 'video-chat'
  
  markAllDonePressed: ->
    console.log @allNotification
    
    @allNotification.map (delNotification)=>
      app.db.remove 'in-app-notification',delNotification._id
    @reportNotification = []
    @userNoteNotification = []
    @onlineConsultationNotification = []
    @generalNotification = []
    @videoChat = []
  
  # -- old one --
  markAsRead: (e)->
    app.db.remove 'in-app-notification', e.model.item._id
    if e.model.item.category is 'report'
      @splice 'reportNotification', e.model.index, 1
    else if e.model.item.category is 'patientNote'
      @splice 'patientNoteNotification', e.model.index, 1
    else if e.model.item.category is 'onlineConsultation'
      @splice 'onlineConsultationNotification', e.model.index, 1
    else if e.model.item.category is 'general'
      @splice 'generalNotification', e.model.index, 1
    else
      console.log e.model.index

  # markAsRead: (item, index)->
  #   console.log item._id
  #   app.db.remove 'in-app-notification', item._id
  #   if item.category is 'report'
  #     @splice 'reportNotification', index, 1
  #   else if item.category is 'patientNote'
  #     @splice 'patientNoteNotification', index, 1
  #   else if item.category is 'onlineConsultation'
  #     @splice 'onlineConsultationNotification', index, 1
  #   else if item.category is 'general'
  #     @splice 'generalNotification', index, 1
    # else if item.category is 'video-chat'
    #   @splice 'videoChat', index, 1
    # else
    #   console.log e.model.index

  
  incomingVidoeCallPromptClosed: (e)->
    @$$('#incomingCallTone').pause()
    
    if e.detail.confirmed
      if @videoCallSessionId
        @set "ENABLE_VIDEO_CALL", true
        @markAsRead @incomingVideoCall, @incomingVideoCall.index
    
  
  acceptVideoChatBtnPresd: (e)->
    { item } = e.model
    console.log {item}
    if item.videoChatSessionId
      localStorage.setItem 'VC_SHOULD_I_BE_CHARGED', false
      @navigateToPage '#/video-chat/id:' + item.videoChatSessionId
      @markAsRead item
      @reloadPage()


  notificationToggleButtonPressed: (e)->
    @.$.notificationDrawer.toggle()

  toggleGeneralNotification: ()->
    @.$.generalNotification.toggle()

  togglevideoChatNotification: ()->
    @.$.videoChatNotification.toggle()

  # Notification Area End ======================================
  
  # Load Wallet Balance ========================================

  _loadWallet: ()->
    query = {
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-wallet-get-balance-and-transaction-details', query, (err, response)=>
      if (not err) and (not response.hasError)
        walletBalance = response.data.balance
        @set 'walletBalance', walletBalance
      else
        this.walletBalance = -1;


  # = REGION ====================================== Advertisement - Start

  _callGetAdvertisementApi: (cbfn)->
    { apiKey } = (app.db.find 'user')[0]
    @callApi '/get-advertisement-list', {apiKey}, { automaticallyHandleNetworkErrors: false }, (err, response)=>
      if err
        console.log 'Network error suppressed willingly since showing an advert is not crucial.'
      else if response.hasError
        @showModalDialog response.error.message
      else
        adList = response.data.advertisementLongList
        cbfn adList

  switchAdvertisement: ->
    if @adList.length is 0
      @set 'currentAd', null
    else
      if @currentAd and ('audio' of @currentAd)
        player = @$$('#audioPlayer')
        unless player.paused
          lib.util.delay 2000, (=> @switchAdvertisement())
          return

      if @adListSelectedIndex is null
        @adListSelectedIndex = 0
      else
        @adListSelectedIndex += 1
        if @adListSelectedIndex is @adList.length
          @adListSelectedIndex = 0
      @currentAd = @adList[@adListSelectedIndex]
      lib.util.delay 2000, (=> @switchAdvertisement())

  initiateAdvertisement: ->
    list = (app.db.find 'user')
    return if list.length is 0
    @_callGetAdvertisementApi (adList)=>
      @adList = adList
      @adListSelectedIndex = null
      @switchAdvertisement()

  _changeToolbarClass: (showMediumTallToolbar) ->
    if showMediumTallToolbar is true
      return 'medium-tall'

    else return ''

  _checkUserAccess: (accessId)->
    currentOrganization = @getCurrentOrganization()
    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return true

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true

  # = REGION offline patient 
  _createOnlinePatient: (patient, cbfn) ->
    patient.apiKey = @user.apiKey
    patient.organizationId = @currentOrganization.idOnServer
    patient.organizationSerial = @currentOrganization.serial or null
    @callApi '/bdemr-app-patient-signup-partial', patient, (err, response)=>
      # console.log response
      if response.hasError
        if response.error.message is "Phone number already exists."
          # @showModalInput "Phone number already exists. Please Enter Another Phone Number instead of #{patient.phone}", patient.phone, (answer)=>
          #   if answer
          #     patient.phone = answer
          #     @_createOnlinePatient patient, cbfn
          patient.userAlreadyExist = true
          # console.log 'patientserial', patient.serial
          @getExisitingPatientInfo patient.name, patient.serial, patient.phone, =>
            return cbfn patient

        else
          @showModalDialog response.error.message
      else
        patientSerial = response.data.patientSerial
        patient.serial = patientSerial
        patient.userAlreadyExist = false
        return cbfn patient

  getExisitingPatientInfo: (patientOldName, oldSerial, phoneNumber, cbfn)->
    data =
      apiKey: @user.apiKey
      phoneNumber: phoneNumber

    @callApi '/bdemr-get-patient-info', data, (err, response)=>
      # console.log response
      if response.hasError
        # console.log response
      else
        patient =
          oldSerial: oldSerial
          patientOldName: patientOldName
          doctorAccessPin: '0000'
          data: null

        patient.data = response.data
        # console.log "PATIENT INFO", patient
        app.db.insert 'conflicted-patient-list', patient
        cbfn()



  _updateLocalPatient: (patient, patientTempSerial)->
    id = (app.db.find 'patient-list', ({serial})-> serial is patientTempSerial)[0]._id
    patient.isTemporaryOfflinePatient = false
    patient.flags = {
      isImported: false
      isLocalOnly: false
      isOnlineOnly: false
    }
    patient.flags.isImported = true
    app.db.remove 'patient-list', id      
    app.db.insert 'patient-list', patient


  _removeLocalPatient: (patientTempSerial)->
    id = (app.db.find 'patient-list', ({serial})-> serial is patientTempSerial)[0]._id
    app.db.remove 'patient-list', id
    # console.log 'deleted already exist patient data'


  _convertOfflinePatientToOnline: (patient, cbfn)->
    oldSerial = patient.serial
    @_createOnlinePatient patient, (patient)=>
      if !patient.userAlreadyExist
        @updatePatientSerialOnExisitingRecords patient.serial, oldSerial, =>
          @_updateLocalPatient patient, oldSerial
          cbfn()
      else
        cbfn()
      return

  checkAndupdateSerialOnCollection: (newSerial, oldSerial, collectionName)->
    list = app.db.find collectionName, ({patientSerial})-> patientSerial is oldSerial

    if list.length > 0
      for item in list
        item.patientSerial = newSerial
        app.db.update collectionName, item._id, item


  updatePatientSerialOnExisitingRecords: (patientActualSerial, patientOldSerial, cbfn)->
    collectionMap = ['unregsitered-patient-details', 'doctor-visit', 'visit-advised-test', 'patient-test-results', 'patient-gallery--local-attachment', 'patient-gallery--online-attachment', 'in-app-notification', 'local-patient-pin-code-list', 'patient-invoice', 'visit-patient-stay', 'visited-patient-log', 'pcc-records', 'ndr-records', 'offline-patient-pin']

    for collectionName in collectionMap
      @checkAndupdateSerialOnCollection patientActualSerial, patientOldSerial, collectionName

    cbfn()

  _syncTemporaryOfflinePatients:(cbfn)->
    userList = app.db.find 'patient-list', (patient)=> patient.isTemporaryOfflinePatient is true
    return cbfn() if userList.length is 0
    it1 = new lib.util.Iterator userList
    it1.forEach (next, index, patient)=>
      @_convertOfflinePatientToOnline patient, ()=>
        next()
    it1.finally =>
      return cbfn()


  # = REGION ====================================== Advertisement - End

  addActivityLog: (type, subject, action, data)->
    object = {
      serial: @generateSerialForActivity()
      userSerial: @getCurrentUserSerial()
      patientSerial: data.patientSerial or null
      userName: @getCurrentUser().name
      subject
      action
      data
      type
      lastModifiedDatetimeStamp: (new Date).getTime()
    }

    app.db.insert 'activity', object

  # = REGION SYNC ======================================
  _syncOnlyPatientGallery: (cbfn)->
    @_newSync cbfn

  _syncOnlyPatientInvoice: (cbfn)->
    @_newSync cbfn

  _syncOnlyPatientData: (cbfn)->
    @_newSync cbfn

  syncButtonPressed: (e)->

    this.toggleModalLoader 'SYNC is in progress, please wait...'

    @_syncTemporaryOfflinePatients =>
      
      @_newSync (errMessage)=>

        this.toggleModalLoader()
    
        if errMessage
          @async => @showModalDialog(errMessage);
        else
          @reloadPage()
      
  remoteSyncPressed: (e)->
    if (!window.isOnsite)
      @showModalDialog("Sorry! Onsite to Remote Sync is available for onsite deployments only.")
      return
    if (!window.isOnsiteSyncEnabled)
      @showModalDialog("Sorry! You are not subscribed to our onsite remote sync. Please contact our customer care to learn more.")
      return

    @callApi '/bdemr--onsite-sync--init', {}, (err, response)=>
      if response.hasError
        @showModalDialog("Please make sure you are connected to the internet and try again.")
        console.log("Response: ", response)
      else
        @showModalDialog("Thank you. Everything is uploaded to remote server for safekeeping.")

  __download: (filename, text) ->
    element = document.createElement('a')
    element.setAttribute 'href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text)
    element.setAttribute 'download', filename
    element.style.display = 'none'
    document.body.appendChild element
    element.click()
    document.body.removeChild element
    return

  backupEverythingPressed: (e)->
    keyList = Object.keys(localStorage)
    map = {}
    keyList.forEach((key) => map[key] = localStorage[key])
    data = JSON.stringify(map)
    name = 'bdemr-backup ' + (new Date).toString() + '.bdemrplainbc'
    @__download(name, data)

  restoreEverythingPressed: (e)->
    this.$.restoreFileSelector.click()

  restoreFileSelectorFileSelected: (e)->
    input = event.target
    if (input.files.length == 0)
      return
    reader = new FileReader
    reader.onload = ->
      text = reader.result
      data = JSON.parse(text)
      for key, value of data
        localStorage[key] = value
      window.location.reload()
    reader.readAsText input.files[0]
      
  accountsManagerPressed: (e)->
    @navigateToPage '#/accounts-manager-dashboard/organization:' + @currentOrganization.idOnServer
    @$$('app-drawer').toggle()

}
