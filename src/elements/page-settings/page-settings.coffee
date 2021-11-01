
Polymer {

  is: 'page-settings'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    user:
      type: Object
      notify: true
    settings:
      type: Object
      value: -> (app.db.find 'settings')[0]
    languageSelectedIndex: 
      type: Number
      value: app.lang.defaultLanguageIndex
      notify: true
      observer: 'languageSelectedIndexChanged'
    maximumLogoImageSizeAllowedInBytes:
      type: Number
      value: 1000 * 1000

    changePassword:
      type: Object
      notify: true

    validationError:
      type: Object
      notify: true
      value: null

    showPrintSection:
      type: Boolean
      value: false

  navigatedIn: ->
    @loadOrganization =>
      @_loadUser()
      # @loadSettings()
      # console.log 'here'
      # @$getOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, (settings)=>
      #   @set 'settings', settings

      @resetChangePasswordObject()
  
  loadOrganization:(cbfn)->
    organization = @getCurrentOrganization()
    if organization
      @set 'organization', organization
    else
      @domHost.navigateToPage '#/select-organization'
    
    cbfn()

  
  languageSelectedIndexChanged: ->
    value = @supportedLanguageList[@languageSelectedIndex]
    # console.log value
    @setActiveLanguage value

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  saveButtonPressed: (e)->
    @$setOrganizationSpecificUserSettings @user.apiKey, @organization.idOnServer, @settings, =>
      @domHost.showToast 'Settings Saved!'
      @arrowBackButtonPressed()

  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  showFooterLine:(e)->
    value = e.target.checked
    if typeof @settings.flags is 'undefined'
      object =
        showFooterLine: value
      @settings.flags = object
    else
      @settings.flags.showFooterLine = value


  # loadSettings: ()->
  #   list = app.db.find 'settings', ({serial})=> serial is @getSerialForSettings()
  #   if list.length
  #     @settings = list[0]
  #     if (typeof @settings.settingsModifiedBy is 'undefined') or (@settings.settingsModifiedBy is 'organization')
  #       if @organization.printSettings
  #         @settings.printDecoration = @organization.printSettings
  #     if (@settings.settingsModifiedBy is 'user') and (@settings.printDecoration.leftSideLine1 is '')
  #       if @organization.printSettings
  #         @settings.printDecoration = @organization.printSettings
  #         @settings.settingsModifiedBy = 'organization'      
  #     console.log @settings
  #     console.log @organization
  #   else
  #    @_makeSettings()

  ## change password - start
  changePasswordBtnPressed: ()->
    if @changePassword.oldPassword and @changePassword.newPassword and @changePassword.newRetypePassword
      @_callChangeUserPasswordApi()
  

  _callChangeUserPasswordApi: ()->
    data = @changePassword
    data.apiKey = @user.apiKey

    @callApi '/change-user-password', data, (err, response)=>
      console.log response
      if response.hasError
        
        # if response.error.message
        #   @domHost.showModalDialog response.error.message
        # else
        @validationError = response.error.details

        @domHost.showModalDialog @_formatErrorMessageAndShow @validationError

      else
        @validationError = null
        @resetChangePasswordObject()
        @domHost.showModalDialog "Password has been changes successfully!"


      console.log 'validationError', @validationError

  _formatErrorMessageAndShow: (err)->
    errList = []

    if err.oldPassword
      errList.push err.oldPassword[0]

    if err.newPassword
      errList.push err.newPassword[0]

    if err.newRetypePassword
      errList.push err.newRetypePassword[0]

    return errList


  resetChangePasswordObject: ()->
    @changePassword =
      oldPassword: null
      newPassword: null
      newRetypePassword: null
      


  _getError: (errObj, prop)->
    console.log 'errObj', errObj

  ## change password - end
  

  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumLogoImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @set 'settings.printDecoration.logoDataUri', dataUri

  fileInputChanged2: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumLogoImageSizeAllowedInBytes
      @domHost.showModalDialog 'Please provide a file less than 1mb in size.'
      return

    reader.readAsDataURL file
    reader.onload = =>
      dataUri = reader.result
      @set 'settings.printDecoration.signatureDataUri', dataUri

  deleteLocalDataPressed: ->
    @domHost.showModalInput "Please enter PIN to delete local data", "0000", (answer)=>
      if answer is '1789'
        window.localStorage.clear()
        @domHost.showToast 'Deleted Successfully'
        @domHost.reloadPage()
      else
        @domHost.showToast 'Wrong PIN'

  sendLocalDateToDevPressed: ->
    now = lib.datetime.now()
    data = {
      from: "clinic@bdemr.com"
      to: 'ab@bdemr.com, taufiq@bdemr.com, mahmudul@bdemr.com'
      subject: "Local Data on #{now}"
      body: JSON.stringify(window.localStorage.getItem('database-engine-db-bdemr-clinic-app-db'))
    }
    @callApi '/extern-scheduler-send-email', data, (err, response)=>
      unless response.hasError
        @domHost.showSuccessToast 'Email sent.'


  hidePrintSectionForTestRslt: (e)->
    @showPrintSection = false
    printSetting = @showPrintSection
    if printSetting is false
      window.localStorage.removeItem('showPrintSectionOnTestResult')
      @domHost.showModalDialog "Settings are now Hidden"

  showPrintSectionForTestRslt: (e)->
    @showPrintSection = true
    printSetting = @showPrintSection
    if printSetting
      window.localStorage.setItem('showPrintSectionOnTestResult', printSetting)
      @domHost.showModalDialog "Settings are now Open"
}