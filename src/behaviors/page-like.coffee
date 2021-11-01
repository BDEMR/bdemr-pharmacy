
app.behaviors.pageLike = [
  {

    ready: ->
      # @debugInfo 'ready'
      if @domHost.pageReady
        @domHost.pageReady @
      else
        # console.log '@', @
        # console.log 'domhost', @domHost
        # console.log 'domhost of domhost', @domHost.domHost
        @domHost.domHost.pageReady @, true

    locateParentNode: (el, nodeName)->
      while el.nodeName isnt nodeName
        el = el.parentNode
      
      return el

    # region: wallet - START =============================================

    $gte: (a, b)-> a >= b

    addBalanceTapped: (e)->
      amount = e.target.getAttribute('data-amount') or '100';
      this.domHost.showModalInput "Enter amount in BDT", amount, (answer)=>
        if answer
          amount = parseInt answer
          if amount < 10
            this.domHost.showModalDialog "Insert an amount of 10 or more."
            return
          this._addFunds(amount)
          
    _addFunds: (amount)->
      query = {
        apiKey: (app.db.find 'user')[0].apiKey
        amountToAdd:amount
        currency: 'BDT'
        notes: 'Funding for "My Tests"'
      }
      this.domHost.callApi '/bdemr-wallet-add-funds', query, (err, response)=>
        if (not err) and (not response.hasError)
          window.location = response.data.redirectionUrl.replace('//', 'https://')
      
    _showWalletFundingDialog: ->
      params = this.domHost.getPageParams()
      if 'funding' of params
        if params.funding is 'successful'
          this.domHost.showModalDialog "Thank you for your payment."
        else
          this.domHost.showModalDialog "Something went wrong with your payment. Please try again."

    _loadWallet: (cbfn = null)->
      this._showWalletFundingDialog()
      query = {
        apiKey: (app.db.find 'user')[0].apiKey
      }
      this.domHost.callApi '/bdemr-wallet-get-balance-and-transaction-details', query, (err, response)=>
        if (not err) and (not response.hasError)
          this.walletBalance = response.data.balance
        else
          this.walletBalance = -1;
        this.domHost.set('walletBalance',this.walletBalance)
        if (cbfn)
          cbfn()

    _chargeUser: (amount, purpose, cbfn)->
      query = {
        apiKey: (app.db.find 'user')[0].apiKey
        amountInBdt: amount
        notes: purpose
      }
      this.domHost.callApi '/bdemr-wallet-charge-user', query, (err, response)=>
        if (err)
          return cbfn err
        if response.hasError
          return cbfn response.error
        return cbfn()

    _chargePatient: (patientId, amount, purpose, cbfn)->
      query = {
        apiKey: (app.db.find 'user')[0].apiKey
        amountInBdt: amount
        notes: purpose
        userIdOverride: patientId
      }
      this.domHost.callApi '/bdemr-wallet-charge-user', query, (err, response)=>
        if (err)
          return cbfn err
        if response.hasError
          return cbfn response.error
        return cbfn()

    _chargePatientContextual: (chargeDoc, cbfn)->
      # NOTE: context can be either 'indoor' or 'outdoor'
      {patientId, amount, purpose, context, organizationId} = chargeDoc
      query = {
        apiKey: (app.db.find 'user')[0].apiKey
        amountInBdt: amount
        notes: purpose
        userIdOverride: patientId
        context
        organizationId
      }
      @domHost.callApi '/bdemr-wallet-charge-user', query, (err, response)=>
        if (err)
          return cbfn err
        if response.hasError
          return cbfn response.error
        return cbfn()

    # region: end - START =============================================

    # navigatedIn: ->
    #   @debugInfo 'navigatedIn'

    # navigatedOut: ->
    #   @debugInfo 'navigatedOut'


  }
  , app.behaviors.debug
]