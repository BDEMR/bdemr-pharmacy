Polymer {
  is: 'page-organization-wallet'
  
  behaviors: [ 
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    walletTransaction:
      type: Object
      notify: true
      value: null

    addFund:
      type: Object
      notify: true
      value: null

    user:
      type: Object
      notify: true
      value: null

    currencyList:
      type: Array
      notify: true
      value: [
        'BDT',
        'USD'
      ]

    currencyIndex:
      type: Number
      notify: true
      value: 0

    walletTransactionList:
      type: Array
      notify: true
      value: ()-> []

    currentOrganization:
      type: Object
      notify: true
      value: null


    smsBuyer:
      type: Object
      notify: true
      value: -> {
        id: null
        type: null
      }

    bulkSms:
      type: Object
      notify: true
      value: null

    orgSmsBalance:
      type: Number
      notify: true
      value: 0

    sendMoneyVerification:
      type: Object
      notify: true
      value: null

    searchFieldOrganizationInput: 
      type: String
      notify: true
      value: ''
    selectedOrganizationId:
      type: String
      value: ''



  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  ## 01. Util Functions - start --------------->
  ## Util Functions - start


  ## 02. Wallet - Transaction History - start --------------->
  loadTransactionHistory: ()->
    data = {
      apiKey: @user.apiKey
      organizationId: @currentOrganization.idOnServer
    }
    @callApi '/bdemr-wallet-get-organization-balance-and-transaction-details', data, (err, response)=>
      console.log(response)
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        # console.log response
        @walletTransaction = response.data
        @walletTransactionList = @walletTransaction.transactionList

  ## Wallet - Transaction History - end
  
  ## Float parsing function for wallet balance - Start ------>

  _fixedToTwoDecimal: (balance)->
    # console.log balance
    parseFloat(balance).toFixed(2)

  ## Float parsing function for wallet balance - End --------->

  ## 03. Wallet - Add Fund(s) - start --------------->
  _makeAddFunds: ()->
    @addFund =
      organizationId: @currentOrganization.idOnServer
      apiKey: null
      amountToAdd: 0
      currency: 'BDT',
      notes: ''
      clientIdentifier: 'bdemr-doctor-app'

  showAddFundsDialog: ()->
    @$$('#dialogAddFund').toggle()

  addFundRequest: ()->
    @addFund.apiKey = @user.apiKey
    @addFund.amountToAdd = Number @addFund.amountToAdd
    @addFund.organizationId = @currentOrganization.idOnServer

    # console.log 'AddFund:', @addFund

    @callApi '/bdemr-organization-wallet-add-funds', @addFund, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        # console.log 'Add Fund Response:', response.data
        @_makeAddFunds()
        @$$('#dialogAddFund').close()
        window.location.href = response.data.redirectionUrl

  ## Wallet - Add Fund(s) - end


  ## 04. Wallet - Send Money - start --------------->
  _makeSendMoney: ()->
    @sendMoney =
      apiKey: null
      recipientsType: 'organization'
      organizationId: @currentOrganization.idOnServer
      recipientsOrganizationId: null
      recipientsEmailOrPhone: ''
      amountInBdt: 0,
      notes: ''

  _makeVerificationCodeForSendMoney: ()->
    @sendMoneyVerification =
      apiKey: null
      verificationCode: ''

  showSendMoneyDialog: ()->
    @_makeSendMoney()
    @$$('#dialogSendMoney').toggle()

  sendMoneyRequest: ()->
    @sendMoney.apiKey = @user.apiKey
    @sendMoney.amountInBdt = Number @sendMoney.amountInBdt

    # console.log 'SendMoney:', @sendMoney

    @callApi '/bdemr-organization-wallet-send-money-request', @sendMoney, (err, response)=>
      # console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @$$('#dialogSendMoney').close()
        
        @_makeVerificationCodeForSendMoney()
        @$$('#dialogSendMoneyVerificationCode').toggle()


  checkVerificaitonCodeForSendMoney: ()->
    @sendMoneyVerification.apiKey = @user.apiKey
    @sendMoneyVerification.organizationId = @currentOrganization.idOnServer

    @callApi '/bdemr-organization-wallet-send-money-verification-code-check', @sendMoneyVerification, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @loadTransactionHistory()
        @domHost.showModalDialog 'Amount has been sent successfully!'
        @$$('#dialogSendMoneyVerificationCode').close()


  _searchOrganization: ->
    data = { 
      apiKey: @user.apiKey
      searchString: @searchFieldOrganizationInput
    }
    @callApi '/bdemr-organization-search', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.matchingOrganizationList
        # console.log response
        if data.length > 0
          organizationSuggestionArray = (item for item in data)
          @$$("#organizationSearch").suggestions organizationSuggestionArray
        else
          @domHost.showToast 'No Match Found'
    
  
  organizationSearchStartKeyPressed: (e)->
    return unless e.which is 13
    @_searchOrganization()

  organizationSearchButtonPressed: ->
    @_searchOrganization()

  
  organizationSelected: (e)->
    e.preventDefault()
    organizationId = e.detail.value
    @set 'sendMoney.recipientsOrganizationId', organizationId


    # console.log @sendMoney

  organizationSearchCleared: ->
     @set 'searchFieldOrganizationInput', ''



  ## Wallet - Send Money - end


  ## 05. Wallet - Valided Voucher - start --------------->
  _makeValidedVoucher: ()->
    @validedVoucher =
      apiKey: null
      voucherCode: ''

  showValidedVoucherDialog: ()->
    @$$('#dialogValidedVoucher').toggle()

  sendValidedVoucherRequest: ()->

    @validedVoucher.apiKey = @user.apiKey

    # console.log 'validedVoucher:', @validedVoucher

    @callApi '/bdemr-com-voucher-validate', @sendMoney, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @domHost.showModalDialog 'Your Voucher Code:' + @validedVoucher.voucherCode + ' has been sent successfully!'

      @_makeValidedVoucher()
      @$$('#dialogValidedVoucher').close()
      
  ## Wallet - Valided Voucher - end

  ## 06. Wallet - Redeem Voucher - start --------------->
  _makeRedeemVoucher: ()->
    @redeemVoucher =
      apiKey: null
      voucherCode: ''

  showRedeemVoucherDialog: ()->
    @$$('#dialogRedeemVoucher').toggle()

  sendRedeemVoucherRequest: ()->
    @redeemVoucher.apiKey = @user.apiKey

    @callApi '/bdemr-wallet-redeem-voucher', @redeemVoucher, (err, response)=>
      # console.log 'Reedem Voucher:', response
      if response.hasError
        if response.error.message is 'No data found'
          @domHost.showModalDialog 'Your provieded voucher code is invalid!'
      else
        @domHost.showModalDialog 'Voucher Redeemed successfully!'

      @_makeRedeemVoucher()
      @$$('#dialogRedeemVoucher').close()

  ## Wallet - Redeem Voucher - end


  ## BULK SMS ---- start ---->

  # _makeSmsPurchaseTypeList: ()->

  #   @set 'purchaseSMSForList', [
  #     {
  #       id: @currentOrganization.idOnServer
  #       type: @currentOrganization.name
  #     }
  #     {
  #       id: @user.idOnServer
  #       type: 'Personal'
  #     }
  #   ]

  _makeBulkSms: ()->
    @bulkSms =
      apiKey: null
      quantity: 100
      organizationId: @currentOrganization.idOnServer
      usage:
        id: @currentOrganization.idOnServer
        type: 'organization'
      calcAmount: 0
      currency: 'BDT'

    @set 'bulkSms.calcAmount', @bulkSms.quantity * 2.5


  showBuySmsDialog: ()->
    @_makeBulkSms()
    @$$('#dialogBulkSms').open()


  buyBulkSmsBtnPressed: ()->
    @bulkSms.quantity = Number @bulkSms.quantity

    if @smsBuyer.type is @currentOrganization.name
      @set 'bulkSms.usage.id', @currentOrganization.idOnServer

    # console.log 'bulkSms', @bulkSms

    if @bulkSms.quantity > 0
      @callBulkSmsApi @bulkSms
    else
      @domHost.showToast 'Please enter Quantity!'

  callBulkSmsApi: (data)->
    data.apiKey = @user.apiKey

    @callApi '/bdemr-organization-wallet-buy-bulk-sms', data, (err, response)=>
      console.log 'bdemr-organization-wallet-buy-bulk-sms', response
      if response.hasError
        # console.log response
        @domHost.showModalDialog response.error.message
      else
        @loadOrganizationSmsBalance @currentOrganization.idOnServer
        @domHost.loadOrganizationSmsBalance (@getCurrentOrganization()).idOnServer
        @loadTransactionHistory()
        @domHost.showModalDialog "You'r SMS Purchase has been Successful!"

      @$$('#dialogBulkSms').close()

  quntityEntered: (e)->
    @bulkSms.quantity = Number @bulkSms.quantity
    @set 'bulkSms.calcAmount', @bulkSms.quantity * 2.5
   

  loadOrganizationSmsBalance: (organizationId)->
    # console.log 'organizationId', organizationId
    data = {
      apiKey: @user.apiKey
      organizationId: organizationId
    }
    @callApi '/bdemr-get-organization-sms-balance', data, (err, response)=>
      console.log 'bdemr-get-organization-sms-balance', response
      if response.hasError
        if response.error.message is "No data found"
          @set 'orgSmsBalance', 0
      else
        @set 'orgSmsBalance', response.data.smsBalance

  _searchOrganization2: ->
    data = { 
      apiKey: @user.apiKey
      searchString: @searchFieldOrganizationInput2
    }
    @callApi '/bdemr-organization-search', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data.matchingOrganizationList
        # console.log response
        if data.length > 0
          organizationSuggestionArray = (item for item in data)
          @$$("#organizationSearch2").suggestions organizationSuggestionArray
        else
          @domHost.showToast 'No Match Found'
    
  
  organizationSearchStartKeyPressed2: (e)->
    return unless e.which is 13
    @_searchOrganization2()

  organizationSearchButtonPressed2: ->
    @_searchOrganization2()

  
  organizationSelected2: (e)->
    e.preventDefault()
    organizationId = e.detail.value
    @set 'bulkSms.usage.id', organizationId


  organizationSearchCleared: ->
     @set 'searchFieldOrganizationInput2', ''


  
      
  _loadOrganization: (idOnServer, cbfn)->
    data = { 
      apiKey: @user.apiKey
      idList: [ idOnServer ]
    }
    @loadingCounter++    
    @callApi '/bdemr-organization-list-organizations-by-ids', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        unless response.data.matchingOrganizationList.length is 1
          @domHost.showModalDialog "Invalid Organization"
          return
        organization = response.data.matchingOrganizationList[0]

        if typeof organization.serial is 'undefined'
          organization.serial = ''
        
        @set 'currentOrganization', organization

        @set 'isOrganizationValid', true
      
        cbfn()

  ## BULK SMS ---- end ---->


  navigatedIn: ->
    params = @domHost.getPageParams()


    if params['funding'] is 'successful'
      @domHost.showModalDialog 'Fund Added successfully!'

    @_loadUser()

    @_loadOrganization params['organization'], =>
      @set 'smsBuyer.type', @currentOrganization.name
      @set 'smsBuyer.id', @currentOrganization.idOnServer

      @loadTransactionHistory()
      @loadOrganizationSmsBalance @currentOrganization.idOnServer

      @_makeValidedVoucher()
      @_makeAddFunds()
      @_makeSendMoney()
      @_makeRedeemVoucher()

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()


  
}