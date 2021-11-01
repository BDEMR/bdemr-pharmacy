Polymer {
  is: 'page-my-wallet'
  
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


    smsUserType:
      type: String
      notify: true
      value: null

    bulkSms:
      type: Object
      notify: true
      value: null

    userSmsBalance:
      type: Number
      notify: true
      value: 0

    totalIncome:
      type: Number
      computed: '_calculateTotalIncome(walletTransactionList)'

    totalExpense:
      type: Number
      computed: '_calculateTotalExpense(walletTransactionList)'

    sendMoneyVerification:
      type: Object
      notify: true
      value: null
    
    activeItem:
      observer: '_activeItemChanged'
    
    selectedRecord:
      type: Object
      value: null
  

  _activeItemChanged: (item)->

    # if (this.inventory && this.inventory.length > 0)
    #   console.log this.$.list
    #   this.$.transactionList.selectedItems = [e] or [];
    if item
      @set 'selectedRecord', item

      console.log {@selectedRecord}
      @$$('#dialogTransactionDetails').toggle()


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  ## 01. Util Functions - start --------------->
  ## Util Functions - start


  ## 02. Wallet - Transaction History - start --------------->
  loadTransactionHistory: ()->
    data = {
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-wallet-get-balance-and-transaction-details', data, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        console.log response
        @walletTransaction = response.data
        @walletTransactionList = @walletTransaction.transactionList
        @sortIncomeAndExpenseTransactions(@walletTransactionList)

  ## Wallet - Transaction History - end

  sortIncomeAndExpenseTransactions: (transactionList)->
    # console.log transactionList
    walletTransactionList = []
    for item in transactionList
      str = item.type.split(':')[1]
      if str == 'add' or str == 'subtract'
        item.type = str
        walletTransactionList.push item
    @set 'walletTransactionList', walletTransactionList


  _calculateTotalIncome: (list)->
    total = 0
    incomeArr = []
    for item in list
      if item.type is 'add'
        incomeArr.push item

    if incomeArr.length
      for item in incomeArr
        total += item.amount
    return total


  _calculateTotalExpense: (list)->
    total = 0
    expenseArr = []
    for item in list
      if item.type is 'subtract'
        expenseArr.push item    

    if expenseArr.length
      for item in expenseArr
        total += item.amount
    return total


  ## Float parsing function for wallet balance - Start ------>

  _fixedToTwoDecimal: (balance)->
    # console.log balance
    parseFloat(balance).toFixed(2)

  ## Float parsing function for wallet balance - End --------->

  ## 03. Wallet - Add Fund(s) - start --------------->
  _makeAddFunds: ()->
    @addFund =
      apiKey: null
      amount: 0
      notes: ''
      redirectedUrl: "https://clinic.bdemr.com/#/my-wallet"

  showAddFundsDialog: ()->
    @$$('#dialogAddFund').toggle()
  

  addFundRequest: ()->
    @addFund.apiKey = @user.apiKey
    @addFund.amount = Number @addFund.amount

    console.log 'AddFund:', @addFund

    @callApi '/get-new-payment-transaction-url', @addFund, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @_makeAddFunds()
        @$$('#dialogAddFund').close()
        window.location.href = response.data.redirectGatewayURL

  ## Wallet - Add Fund(s) - end


  ## 04. Wallet - Send Money - start --------------->
  _makeSendMoney: ()->
    @sendMoney =
      apiKey: null
      recipientsId: ''
      amountInBdt: 0,
      notes: ''

  _makeVerificationCodeForSendMoney: ()->
    @sendMoneyVerification =
      apiKey: null
      verificationCode: ''

  showSendMoneyDialog: ()->
    @_makeSendMoney()
    @userSearchCleared()
    @$$('#dialogSendMoney').toggle()
  
  sendMoneyRequest: ()->
    @sendMoneyWithoutVerify()
    # @sendMoneyRequestWithVerification()

  sendMoneyWithoutVerify: ()->
    @sendMoney.apiKey = @user.apiKey
    @sendMoney.amountInBdt = Number @sendMoney.amountInBdt

    @callApi '/bdemr-wallet-send-money-without-verification', @sendMoney, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @loadTransactionHistory()
        @$$('#dialogSendMoney').close()
        @domHost.showModalDialog response.data.message

        ########## DISABLED VERIFICATION CODE FOR SEND MONEY ##########
        # @_makeVerificationCodeForSendMoney()
        # @$$('#dialogSendMoneyVerificationCode').toggle()
  
  sendMoneyRequestWithVerification: ()->
    @sendMoney.apiKey = @user.apiKey
    @sendMoney.amountInBdt = Number @sendMoney.amountInBdt

    @callApi '/bdemr-wallet-send-money-with-verification', @sendMoney, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @$$('#dialogSendMoney').close()
        @_makeVerificationCodeForSendMoney()
        @$$('#dialogSendMoneyVerificationCode').toggle()


  checkVerificaitonCodeForSendMoney: ()->
    @sendMoneyVerification.apiKey = @user.apiKey

    @callApi '/bdemr-wallet-send-money-verification-code-check', @sendMoneyVerification, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @loadTransactionHistory()
        @domHost.showModalDialog 'Amount has been sent successfully!'
        @$$('#dialogSendMoneyVerificationCode').close()


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

    console.log 'validedVoucher:', @validedVoucher

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
      console.log 'Reedem Voucher:', response
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
      usage:
        id: @currentOrganization.idOnServer
        type: @smsUserType
      calcAmount: 0
      currency: 'BDT'

    @set 'bulkSms.calcAmount', @bulkSms.quantity * 2


  showBuySmsDialog: ()->
    @_makeBulkSms()
    @$$('#dialogBulkSms').open()


  buyBulkSmsBtnPressed: ()->
    @bulkSms.quantity = Number @bulkSms.quantity

    if @smsUserType is 'Personal'
      @set 'bulkSms.usage.type', 'personal'
      @set 'bulkSms.usage.id', @user.idOnServer

    if @smsUserType is 'Organization'
      @set 'bulkSms.usage.type', 'organization'
      @set 'bulkSms.usage.id', @currentOrganization.idOnServer

    console.log 'bulkSms', @bulkSms

    if @bulkSms.quantity > 0
      @callBulkSmsApi @bulkSms
    else
      @domHost.showToast 'Please enter Quantity!'

  callBulkSmsApi: (data)->
    data.apiKey = @user.apiKey

    

    @callApi '/bdemr-buy-bulk-sms', data, (err, response)=>
      console.log 'Buy SMS:', response
      if response.hasError
        console.log response
        @domHost.showModalDialog response.error.message
      else
        @loadUserSmsBalance()
        @domHost.loadOrganizationSmsBalance @currentOrganization.idOnServer
        @loadTransactionHistory()
        @domHost.showModalDialog "You'r SMS Purchase has been Successful!"

      @$$('#dialogBulkSms').close()

  quntityEntered: (e)->
    @bulkSms.quantity = Number @bulkSms.quantity
    @set 'bulkSms.calcAmount', @bulkSms.quantity * 2

  loadUserSmsBalance: ()->
    data = {
      apiKey: @user.apiKey
    }
    @callApi '/bdemr-get-user-sms-balance', data, (err, response)=>
      console.log 'USER SMS BALNCE:', response
      if response.hasError
        if response.error.message is "No data found"
          @set 'userSmsBalance', 0
      else
        @set 'userSmsBalance', response.data.smsBalance
   

  loadOrganizationSmsBalance: (organizationId)->
    data = {
      apiKey: @user.apiKey
      organizationId: organizationId
    }
    @callApi '/bdemr-get-organization-sms-balance', data, (err, response)=>
      console.log 'ORG SMS BALNCE:', response
      if response.hasError
        if response.error.message is "No data found"
          @set 'orgSmsBalance', 0
      else
        @set 'orgSmsBalance', response.data.smsBalance
  
      
  _loadOrganization: (cbfn)->
    @currentOrganization = @getCurrentOrganization()
    unless @currentOrganization
      @domHost.navigateToPage "#/select-organization"
    cbfn()

  ## BULK SMS ---- end ---->

  # USER SEARCH ---- start -->
  _searchUser: (searchQuery)->
    return unless searchQuery
    @callApi '/bdemr-user-search-for-notification', {searchString: searchQuery}, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        data = response.data
        if data.length > 0
          userSuggestionArray = (item for item in data)
          @$$("#userSearch").suggestions userSuggestionArray
        else
          @domHost.showToast 'No User(s) Found!'
  
  userSearchEnterKeyPressed: (e)->
    return unless e.keyCode is 13
    searchQuery = @$$("#userSearch").text
    @_searchUser(searchQuery)

  userSearchButtonPressed: ->
    searchQuery = @$$("#userSearch").text
    @_searchUser(searchQuery)

  userSelected: (e)->
    id = e.detail.value
    @sendMoney.recipientsId = id
  
  userSearchCleared: () ->
    @$$("#userSearch").clear()
  # USER SEARCH ---- end -->

  filterByDateClicked: (e)->
    startDate = new Date e.detail.startDate
    startDate.setHours(0,0,0,0)
    endDate = new Date e.detail.endDate
    endDate.setHours(23,59,59,999)
    @set 'dateCreatedFrom', startDate
    @set 'dateCreatedTo', endDate

  filterByDateClearButtonClicked: ->
    @dateCreatedFrom = 0
    @dateCreatedTo = 0
    @loadTransactionHistory()

  dateFilterTapped: (e)->
    unless @dateCreatedFrom
      return @domHost.showModalDialog "Please Select Dates first"
    filteredList = (item for item in @walletTransactionList when ( @dateCreatedFrom <= (new Date item.createdDatetimeStamp) <= @dateCreatedTo ))
    @set 'walletTransactionList', filteredList

  resetButtonClicked: (e)->
    window.location.reload()

  navigatedIn: ->
    params = @domHost.getPageParams()


    if params['op'] is 'show-generic-payment-success'
      @domHost.showModalDialog 'Fund Added successfully!'

    @_loadUser()

    @_loadOrganization =>
      @set 'smsBuyerType', @currentOrganization.name

      @loadTransactionHistory()
      @loadUserSmsBalance()
      # @loadOrganizationSmsBalance @currentOrganization.idOnServer

      @_makeValidedVoucher()
      @_makeAddFunds()
      @_makeSendMoney()
      @_makeRedeemVoucher()




  
}