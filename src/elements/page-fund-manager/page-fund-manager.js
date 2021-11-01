Polymer({

  is: 'page-fund-manager',

  behaviors: [
    app.behaviors.translating,
    app.behaviors.pageLike,
    app.behaviors.dbUsing,
    app.behaviors.apiCalling,
    app.behaviors.commonComputes
  ],

  properties: {
    user: {
      type: Object,
      notify: true,
      value: null
    },

    organization: {
      type: Object,
      value: {}
    },

    fund: {
      type: Object,
      value() { return {}; }
    },

    fundList: {
      type: Array,
      value() { return []; }
    },

    loadingCounter: {
      type: Number,
      value() { return 0; }
    }

  },


  navigatedIn() {
    this._loadUser();
    this._loadOrganization();
    this.makeNewFund();
    this.getFundList();
  },


  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },


  _loadOrganization() {
    const organizationList = app.db.find('organization');
    if (organizationList.length === 1) {
      return this.set('organization', organizationList[0]);
    } else {
      return this.domHost.showModalDialog('Invalid Organization')
    }
  },

  getFundList() {
    this.loadingCounter++
    let data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    }
    this.callApi('/bdemr--clinic-get-discount-fund-list', data, (err, response) => {
      this.loadingCounter--
      if (err) {
        return this.domHost.showModalDialog('Something went wrong with the server')
      } else if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message)
      } else {
        let fundList = response.data
        fundList.sort((a, b) => b.createdDatetimeStamp - a.createdDatetimeStamp);
        this.set("fundList", fundList)
        console.log(this.fundList);
      }
    })
  },

  makeNewFund() {
    return this.fund = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: null,
      organizationId: this.organization.idOnServer,
      serial: null,
      name: '',
      amount: null,
      transactionLogs: []
    };
  },

  _addFundRequest() {

    if (!this.fund.amount) {
      return this.domHost.showModalDialog('Please Add Amount');
    }

    if (!this.fund.name) {
      return this.domHost.showModalDialog('Please Add Name');
    }

    else {
      this.loadingCounter++
      this.fund.lastModifiedDatetimeStamp = lib.datetime.now();
      if (!this.fund.serial) this.fund.serial = this.generateSerialForDiscountFund();
      this.fund.transactionLogs.push({
        createdByUserId: this.user.idOnServer,
        type: 'Added',
        amount: this.fund.amount,
        createdDatetimeStamp: lib.datetime.now()
      });

      let data = Object.assign({ apiKey: this.user.apiKey }, this.fund)
      this.callApi('/bdemr--clinic-add-new-discount-fund', data, (err, response) => {
        this.loadingCounter--
        if (err) {
          return this.domHost.showModalDialog('Something went wrong with the server')
        } else if (response.hasError) {
          return this.domHost.showModalDialog(response.error.message)
        } else {
          this.domHost.showModalDialog('Fund Added Successfully');
          this.getFundList()
        }
      })
      this.makeNewFund()
      console.log(this.fund)
      return this.$$('#dialogAddNewFund').close();
    }

  },

  _viewTransactionLogsButtonClicked(e) {
    let item = e.model.item
    this.transactionLogObj = item
    this.$$('#dialogTransactionLogs').toggle()
  },

  _editFundButtonClicked(e) {
    let item = e.model.item
    this.fund = item
    this.$$('#dialogAddNewFund').toggle();
  },

  _deleteFundButtonClicked(e) {
    let { item, index } = e.model;
    this.domHost.showModalPrompt('Are you sure, you want to delete this fund?', (done) => {

      this.loadingCounter++
      this.fund.transactionLogs.push({
        createdByUserId: this.user.idOnServer,
        type: 'Deleted',
        amount: this.fund.amount,
        createdDatetimeStamp: lib.datetime.now()
      });

      let data = { apiKey: this.user.apiKey, serial: item.serial }
      this.callApi('/bdemr--clinic-delete-discount-fund', data, (err, response) => {
        this.loadingCounter--
        if (err) {
          return this.domHost.showModalDialog('Something went wrong with the server')
        } else if (response.hasError) {
          return this.domHost.showModalDialog(response.error.message)
        } else {
          this.splice('fundList', index, 1)
          console.log(this.fundList)
          return this.domHost.showModalDialog('Deleted Successfully')
        }
      })
    })
  },

  _addNewFundButtonClicked(e) {
    return this.$$('#dialogAddNewFund').toggle();
  }



});