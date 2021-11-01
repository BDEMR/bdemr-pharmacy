// -- Details on How Accounts Dashboard works --
// SO basically this feature/Report consists of two types of financial statements
// Income and Expense Statements
// Income > So for incomes there are two types of data we are fetching here, first is patient invoices, which are generated from outpatient, inpatient, Emergency, Pharmacy, Spectacles manager Invoices..
// Income > The second type of invoice that income has is generated from Income manager, Its not related to patients per say, but multitude of things can be added in a income manager invoice, there is no limit.
// Expense > Expense fairly simple, all expense invoices are generated are from Expense manager and Third party Commission payment invoice(which by the will also show up in expense manager table).
// Accounts dashboard can be filtered with dates and Flagged as error invoices. However coming to this page will automatically generate Report, but Search button can be used with filters, search button has te be pressed if any filters are given or changed.
// Accounts Dashboard Print button will print the whole report populated in both tables.
// Individual Income or Expense item can be printed as well

// API Based Feature

Polymer({
  is: 'page-accounts-manager-dashboard',
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
      value: (app.db.find('organization'))[0]
    },

    settings: {
      type: Object,
      notify: true,
      value: (app.db.find('settings'))[0]
    },

    matchingIncomeList: {
      type: Array,
      value: []
    },

    incomeList: {
      type: Array,
      value: []
    },

    matchingExpenseList: {
      type: Array,
      value: []
    },

    featureStatsList: {
      type: Array,
      value: []
    },

    expenseList: {
      type: Array,
      value: []
    },
    searchParameters: {
      type: Object,
      value: function () {
        return {
          organizationId: '',
          startDate: null,
          endDate: null,
          includeErrors: false
        }
      }
    },
    totalReceieved: Number,
    totalCollectibles: Number,
    totalPaid: Number,
    totalDue: Number,
    cashInHand: Number,
    netBalance: Number
  },

  observers: [
    'matchingIncomeListChanged(matchingIncomeList)',
    'matchingExpenseListChanged(matchingExpenseList)'
  ],

  navigatedIn() {
    const params = this.domHost.getPageParams()
    this._loadUser();
    if (params['organization']) {
      this._loadOrganization(params['organization'], () => {
        this._loadReport()
      });
    } else {
      this._notifyInvalidOrganization()
    }
  },

  filterByDateRangeFn(searchParameters) {
    let { organizationIdentifier, startDate, endDate, includeErrors } = searchParameters;
    return function (item) {
      let { createdDatetimeStamp, organizationId } = item;
      return (startDate ? createdDatetimeStamp >= startDate.getTime() : true) && (endDate ? createdDatetimeStamp <= endDate.getTime() : true) && (organizationIdentifier ? organizationId === organizationIdentifier : false) && (includeErrors ? true : !item.flags.flagAsError)
    }
  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },

  _loadOrganization(idOnServer, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      idList: [idOnServer]
    };
    this.loading = true;
    this.callApi('/bdemr-organization-list-organizations-by-ids', data, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (!response.data.matchingOrganizationList.length) return this._notifyInvalidOrganization();
      this.set('organization', response.data.matchingOrganizationList[0]);
      this.searchParameters.organizationIdentifier = this.organization.idOnServer;
      return cbfn();
    });
  },

  _notifyInvalidOrganization() {
    return this.domHost.showModalDialog("Invalid Organization");
  },

  _loadOrganizationInvoices(startDate, endDate, includeErrors, cbfn) {
    let query = {
      apiKey: this.user.apiKey,
      organizationIdList: [this.organization.idOnServer],
      searchParameters: {
        dateCreatedFrom: startDate,
        dateCreatedTo: endDate,
        includeErrors
      }
    }
    this.loading = true;
    this.callApi('/bdemr--clinic-invoice-report', query, (err, response) => {
      this.loading = false;
      if (err) {
        this.domHost.showModalDialog(err.message);
        return cbfn([])
      };
      if (response.hasError) {
        this.domHost.showModalDialog(response.error.message);
        return cbfn([])
      };
      return cbfn(response.data);
    });
  },

  _loadIncomes(startDate, endDate) {
    const query = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters: {
        dateCreatedFrom: startDate,
        dateCreatedTo: endDate,
      }
    };
    this.loading = true;
    this.callApi('/bdemr--organization-accounts-income', query, (err, response) => {
      this.loading = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      }
      else {
        const incomeItems = response.data;
        this.set('incomeList', incomeItems);
      }
    });
  },

  _loadIncomeReport(searchParameters = {}) {
    this._loadIncomes(searchParameters.startDate, searchParameters.endDate)
    this._loadOrganizationInvoices(searchParameters.startDate, searchParameters.endDate, searchParameters.includeErrors, (invoiceList) => {
      let modifiedInvoiceList = invoiceList.map((item) => {
        item.invoiceSerial = item.serial
        delete item.serial;
        return item;
      })
      console.log(modifiedInvoiceList)
      let combinedIncomeList = modifiedInvoiceList.concat(this.incomeList);
      this.set('matchingIncomeList', combinedIncomeList);
    })
  },

  _loadExpenses(startDate, endDate) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters: {
        dateCreatedFrom: startDate,
        dateCreatedTo: endDate,
      }
    }
    this.loading = true;
    this.callApi('/bdemr--organization-accounts-expense', data, (err, response) => {
      this.loading = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      }
      else {
        const expenseList = response.data;
        this.set('matchingExpenseList', expenseList);
        console.log(expenseList)
      }
    });
  },

  _loadExpenseReport(searchParameters = {}) {
    this._loadExpenses(searchParameters.startDate, searchParameters.endDate)
  },

  _loadReport() {
    this._loadIncomeReport(this.searchParameters);
    this._loadExpenseReport(this.searchParameters);
  },

  calculateDue(billed, paid) {
    let due = parseFloat(billed) - parseFloat(paid ? paid : 0)
    return due > 0 ? due : 0;
  },

  matchingIncomeListChanged() {
    const matchingIncomeList = this.matchingIncomeList.filter(item => !item.flags.flagAsError);
    this.totalReceieved = matchingIncomeList.reduce((total, item) => {
      return total + parseFloat(item.totalAmountReceieved ? item.totalAmountReceieved : 0);
    }, 0)
    this.totalCollectibles = matchingIncomeList.reduce((total, item) => {
      return total + this.calculateDue(parseFloat(item.totalBilled ? item.totalBilled : 0), parseFloat(item.totalAmountReceieved ? item.totalAmountReceieved : 0))
    }, 0)
    this.calculateNetBalance()
  },

  matchingExpenseListChanged() {
    const matchingExpenseList = this.matchingExpenseList.filter(item => !item.flags.flagAsError);
    this.totalPaid = matchingExpenseList.reduce((total, item) => {
      return total += parseFloat(item.totalAmountPaid ? item.totalAmountPaid : 0);
    }, 0)
    this.totalDue = matchingExpenseList.reduce((total, item) => {
      return total += this.calculateDue(parseFloat(item.totalBilled ? item.totalBilled : 0), parseFloat(item.totalAmountPaid ? item.totalAmountPaid : 0))
    }, 0)
    this.calculateNetBalance()
  },

  calculateNetBalance() {
    this.netIncome = this.totalReceieved + this.totalCollectibles;
    this.netExpense = this.totalPaid + this.totalDue;
    this.netBalance = this.totalReceieved - this.totalPaid;
    this.toggleClass('negative', (this.netBalance < 0 ? true : false), this.$.balance)
  },

  filterByDateClicked(e) {
    const startDate = new Date(e.detail.startDate);
    startDate.setHours(0, 0, 0, 0);
    this.searchParameters.startDate = startDate;
    const endDate = new Date(e.detail.endDate);
    endDate.setHours(23, 59, 59, 999);
    this.searchParameters.endDate = endDate;
  },

  filterByDateClearButtonClicked(e) {
    this.searchParameters.startDate = null;
    this.searchParameters.endDate = null;
  },

  searchButtonClicked(e) {
    this._loadReport()
  },

  addNewIncomeButtonClicked(e) {
    this.domHost.navigateToPage('#/accounts-income-editor/organization:' + this.organization.idOnServer + '/income:new')
  },

  addNewExpenseButtonClicked(e) {
    this.domHost.navigateToPage('#/accounts-expense-editor/organization:' + this.organization.idOnServer + '/expense:new')
  },

  incomePrintPreviewButtonClicked(e) {
    let item = e.model.item;
    if (item.invoiceSerial) {
      return this.domHost.navigateToPage('#/print-invoice/invoice:' + item.referenceNumber + '/patient:' + item.patientSerial)
    }
    return this.domHost.navigateToPage('#/accounts-income-print-preview/organization:' + this.organization.idOnServer + '/income:' + item.serial);
  },

  expensePrintPreviewButtonClicked(e) {
    let item = e.model.item;
    this.domHost.navigateToPage('#/accounts-expense-print-preview/organization:' + this.organization.idOnServer + '/expense:' + item.serial);
  },

  formatIncomeSerial(serial) {
    if (!serial) return;
    let user = serial.charAt(2);
    let inc = serial.split('AccI')[1]
    return user + '-inc-' + inc
  },

  formatExpenseSerial(serial) {
    if (!serial) return;
    let user = serial.charAt(2);
    let inc = serial.split('AccEx')[1]
    return user + '-exp-' + inc
  },

  _printButtonPressed() {
    this.reportCreatedTime = lib.datetime.now();
    window.print();
  }

})
