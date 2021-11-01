
var filterByDateRangeFn = function (organizationIdentifier, startDate, endDate) {
  return function (item) {
    let { createdDatetimeStamp, organizationId } = item;
    if (startDate && endDate) {
      return organizationId === organizationIdentifier && createdDatetimeStamp >= startDate.getTime() && createdDatetimeStamp <= endDate.getTime()
    }
    return organizationId === organizationIdentifier;
  }
}

Polymer({
  is: 'page-accounts-cash-balance',
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

    invoiceList: {
      type: Array,
      value: []
    },

    incomeList: {
      type: Array,
      value: []
    },

    expenseList: {
      type: Array,
      value: []
    },

    matchingIncomeList: {
      type: Array,
      value: []
    },

    matchingExpenseList: {
      type: Array,
      value: []
    },

    matchingCashBalanceList: {
      type: Array,
      value: []
    }

  },


  navigatedIn() {
    const params = this.domHost.getPageParams()
    this._loadUser();
    console.log("--Hint--: If debugging cash balance bugs, always check if calculating items are number or not")
    if (params['organization']) {
      this._loadOrganization(params['organization'], () => {
        this._loadReport(() => {
          this._loadCashBalanceReport()
        })
      });
    } else {
      this._notifyInvalidOrganization()
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
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (!response.data.matchingOrganizationList.length) return this._notifyInvalidOrganization();
      this.set('organization', response.data.matchingOrganizationList[0]);
      return cbfn();
    });
  },

  _notifyInvalidOrganization() {
    return this.domHost.showModalDialog("Invalid Organization");
  },



  // _loadInvoices(cbfn) {
  //   const data = {
  //     apiKey: this.user.apiKey,
  //     organizationId: this.organization.idOnServer
  //   };
  //   this.loading = true;
  //   this.callApi('/bdemr--organization-get-all-invoice', data, (err, response) => {
  //     this.loading = false;
  //     if (response.hasError) {
  //       return this.domHost.showModalDialog(response.error.message);
  //     }
  //     else {
  //       const invoiceItems = response.data;
  //       this.set('invoiceList', invoiceItems);
  //       return cbfn()
  //     }
  //   });
  // },

  _loadOrganizationInvoices(startDate, endDate, cbfn) {
    let query = {
      apiKey: this.user.apiKey,
      organizationIdList: [this.organization.idOnServer],
      searchParameters: {
        dateCreatedFrom: startDate,
        dateCreatedTo: endDate,
        includeErrors: false
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
      let invoiceItems = response.data
      this.set('invoiceList', invoiceItems);
      return cbfn();
    });
  },

  _loadIncomes(startDate, endDate, cbfn) {
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
        return cbfn()
      }
    });
  },

  _loadIncomeReport(cbfn) {
    let modifiedInvoiceList = this.invoiceList.map((item) => {
      item.invoiceSerial = item.serial
      delete item.serial;
      return item;
    })
    let combinedIncomeList = modifiedInvoiceList.concat(this.incomeList);
    this.set('matchingIncomeList', combinedIncomeList);
    return cbfn()
  },

  _loadExpenseReport(startDate, endDate, cbfn) {
    const query = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters: {
        dateCreatedFrom: startDate,
        dateCreatedTo: endDate,
      }
    }
    this.loading = true;
    this.callApi('/bdemr--organization-accounts-expense', query, (err, response) => {
      this.loading = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      }
      else {
        const expenseItems = response.data;
        this.set('matchingExpenseList', expenseItems);
        return cbfn()
      }
    });
  },

  _loadReport(cbfn) {
    console.log('REPORT loaded')
    this._loadIncomes(null, null, () => {
      this._loadOrganizationInvoices(null, null, () => {
        this._loadIncomeReport(() => {
          this._loadExpenseReport(null, null, () => {
            return cbfn()
          });
        });
      });
    });

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
    this._loadReport()
    this._loadCashBalanceReport()
  },

  // generate day report

  calculateDue(billed, paid) {
    let due = parseFloat(billed) - parseFloat(paid ? paid : 0)
    return due > 0 ? due : 0;
  },

  calculateEarnings(incomeList) {
    const matchingIncomeList = incomeList.filter(item => !item.flags.flagAsError);
    totalReceieved = matchingIncomeList.reduce((total, item) => {
      return total += parseFloat(item.totalAmountReceieved);
    }, 0)
    totalCollectibles = matchingIncomeList.reduce((total, item) => {
      return total += this.calculateDue(item.totalBilled, item.totalAmountReceieved)
    }, 0)
    return totalReceieved - totalCollectibles;
  },

  calculateExpenditure(expenseList) {
    const matchingExpenseList = expenseList.filter(item => !item.flags.flagAsError);
    totalPaid = matchingExpenseList.reduce((total, item) => {
      return total += parseFloat(item.totalAmountPaid);
    }, 0)
    totalDue = matchingExpenseList.reduce((total, item) => {
      return total += this.calculateDue(item.totalBilled, item.totalAmountPaid)
    }, 0)
    return totalPaid - totalDue
  },


  _generateDateRange(from, to) {
    const startDate = new Date(from)
    const endDate = new Date(to)
    let endTime = endDate.getTime()
    var dates = []
    var currentDate = startDate;
    while (currentDate.getTime() <= endTime) {
      dates.push(currentDate.getTime())
      currentDate.setDate(currentDate.getDate() + 1)
    }
    return dates
  },

  _makeTodaysBalance(datems, lastBalance) {
    let day = new Date(datems)
    day.setHours(0, 0, 0, 0)
    let dayStart = day.getTime()
    day.setHours(23, 59, 59, 59)
    let dayEnd = day.getTime()
    let matchingIncomeList = this.matchingIncomeList.filter(item => item.createdDatetimeStamp >= dayStart && item.createdDatetimeStamp <= dayEnd)
    let matchingExpenseList = this.matchingExpenseList.filter(item => item.createdDatetimeStamp >= dayStart && item.createdDatetimeStamp <= dayEnd)
    let todaysBalance = {
      date: datems,
      previousBalance: lastBalance && lastBalance.net && lastBalance.net > 0 ? lastBalance.net : 0,
      earning: this.calculateEarnings(matchingIncomeList),
      expenditure: this.calculateExpenditure(matchingExpenseList)
    }
    todaysBalance.gross = todaysBalance.earning - todaysBalance.expenditure;
    todaysBalance.net = todaysBalance.gross + todaysBalance.previousBalance;
    return todaysBalance;
  },

  _loadCashBalanceReport(startDate = '', endDate = '') {
    console.log('CASH Balance')
    if (!endDate) {
      endDate = new Date().toISOString().split('T')[0]
      startDate = new Date(endDate)
      startDate.setDate(startDate.getDate() - 30);
    }
    let dataRange = this._generateDateRange(startDate, endDate);
    let cashBalance = dataRange.reduce((arr, datems) => {
      let newbalance = this._makeTodaysBalance(datems, arr[0])
      arr.unshift(newbalance)
      return arr;
    }, []);
    console.log(cashBalance)
    this.set('matchingCashBalanceList', cashBalance)
  },

})
