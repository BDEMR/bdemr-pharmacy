Polymer({

  is: 'page-commission-report',

  behaviors: [
    app.behaviors.translating,
    app.behaviors.pageLike,
    app.behaviors.apiCalling,
    app.behaviors.commonComputes,
    app.behaviors.dbUsing
  ],

  properties: {

    user: {
      type: Object,
      value: {}
    },

    organization: {
      type: Object,
      value: {}
    },

    commissionList: {
      type: Array,
      notify: true,
      value: []
    },

    filterDate: {
      type: Object,
      value: {}
    },

    matchingCommissionList: {
      type: Array,
      notify: true,
      value: []
    },

    paidInvoicesList: {
      type: Array,
      notify: true,
      value: []
    },

    paidStatusList: {
      type: Array,
      notify: true,
      value: [
        'All',
        'Paid',
        'Unpaid',
      ]
    },

    isLoading: {
      type: Boolean,
      value: false
    },

    totalCommission: {
      type: Number,
      value: 0
    },

    commissionCategoryList: {
      type: Array,
      value() { return []; }
    },

    saveReportToLocalStorageObj: {
      type: Object,
      value: null
    },

    thirdPartySuperVisorList: {
      type: Array,
      value: []
    },

    thirdPartyIdList: {
      type: Array,
      value: []
    }
  },


  _sortByDate(a, b) {
    if (a.createdDatetimeStamp < b.createdDatetimeStamp) {
      return 1;
    }
    if (a.createdDatetimeStamp > b.createdDatetimeStamp) {
      return -1;
    }
  },

  _formatDateTime(dateTime) {
    return lib.datetime.format(dateTime, 'mmm d, yyyy');
  },

  $isAdmin(userId, userList) {
    for (let user of Array.from(userList)) {
      if (userId === user.id) {
        return user.isAdmin;
        break;
      }
    }
    return false;
  },

  _getTotalPaid(paid, lastPaid) {
    if (paid == null) { paid = 0; }
    if (lastPaid == null) { lastPaid = 0; }
    return (parseInt(paid)) + (parseInt(lastPaid));
  },

  navigatedIn() {
    this.isLoading = true;
    this._loadUser();
    return this._loadOrganization(organizationIdentifier => {
      this._loadCommissionCategoryList(this.organization.idOnServer);

      this.loadSuperVisorList();
      return this.isLoading = false;
    });
  },

  loadSuperVisorList() {
    thirdPartySuperVisorList = app.db.find('third-party-supervisor-list'), ({ organizationId }) => organizationId === this.organization.idOnServer
    this.set('thirdPartySuperVisorList', thirdPartySuperVisorList);
    console.log('supervisor list', this.thirdPartySuperVisorList);
  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },


  _loadOrganization(cbfn) {
    const organizationId = this.getCurrentOrganization().idOnServer;
    if (!organizationId) {
      this._notifyInvalidOrganization();
      return;
    }
    const data = {
      apiKey: this.user.apiKey,
      idList: [organizationId]
    };
    return this.callApi('/bdemr-organization-list-organizations-by-ids', data, (err, response) => {
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        if (response.data.matchingOrganizationList.length !== 1) {
          this.domHost.showModalDialog("Invalid Organization");
          return;
        }
        this.set('organization', response.data.matchingOrganizationList[0]);
        return cbfn(this.organization.idOnServer);
      }
    });
  },

  _loadCommissionCategoryList() {
    this.commissionCategoryList = app.db.find('commission-category-list', ({ organizationId }) => organizationId === this.organization.idOnServer);
    return console.log({ commissionCategoryList: this.commissionCategoryList });
  },

  _notifyInvalidOrganization() {
    return this.domHost.showModalDialog('No Organization is Present. Please Select an Organization first.');
  },


  filterByDateClicked(e) {
    const startDate = new Date(e.detail.startDate);
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date(e.detail.endDate);
    endDate.setHours(23, 59, 59, 999);
    this.set('dateCreatedFrom', (startDate.getTime()));
    return this.set('dateCreatedTo', (endDate.getTime()));
  },

  filterByDateClearButtonClicked() {
    this.dateCreatedFrom = 0;
    return this.dateCreatedTo = 0;
  },


  searchButtonClicked() {
    const query = {
      apiKey: this.user.apiKey,
      organizationIdList: [this.organization.idOnServer],
      searchParameters: {
        dateCreatedFrom: this.dateCreatedFrom != null ? this.dateCreatedFrom : (this.dateCreatedFrom = ""),
        dateCreatedTo: this.dateCreatedTo != null ? this.dateCreatedTo : (this.dateCreatedTo = ""),
        searchString: this.searchString,
        commissionCategorySerial: this.selectedCategorySerial,
        paidStatus: this.paidStatus,
        thirdPartyIdList: this.thirdPartyIdList
      }
    };
    this.isLoading = true;
    return this.callApi('/bdemr--clinic-commission-report', query, (err, response) => {
      this.isLoading = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        const invoiceItems = response.data;
        this.set('matchingCommissionList', invoiceItems);
        console.log(this.matchingCommissionList);
        this._calculateTotalCommission(this.matchingCommissionList);
        this.setCommissionReportToLocalStorage(this.matchingCommissionList);
      }
    });
  },

  setCommissionReportToLocalStorage(data) {
    this.set('saveReportToLocalStorageObj', data);
    return localStorage.setItem("saveReportToLocalStorageObj", JSON.stringify(this.saveReportToLocalStorageObj));
  },

  _printButtonPressed() {
    this.domHost.navigateToPage("#/commission-report-print-preview");
  },


  filterByCategoryNameChanged(e) {
    const index = e.detail.selected;
    const category = this.commissionCategoryList[index];
    return this.selectedCategorySerial = category.serial;
  },

  filterByPayStatusChanged(e) {
    const index = e.detail.selected;
    if (index === 0) {
      this.paidStatus = "all";
    }
    if (index === 1) {
      this.paidStatus = "paid";
    }
    if (index === 2) {
      return this.paidStatus = "unPaid";
    }
  },

  filterBySuperVisorNameChanged(e) {
    index = e.detail.selected;
    supervisor = this.thirdPartySuperVisorList[index];
    thirdPartyList = supervisor.thirdPartyArr;
    for (let item of Array.from(thirdPartyList)) {
      this.thirdPartyIdList.push(item.thirdPartyId);
    }
    return console.log(this.thirdPartyIdList);

  },

  _calculateTotalCommission(list) {
    let totalCommission = 0;
    for (let item of Array.from(list)) {
      totalCommission += parseInt(item.commission.amount != null ? item.commission.amount : (item.commission.amount = 0));
    }
    return this.set('totalCommission', totalCommission);
  },

  // invoiceTicked(e) {
  //   const { item } = e.model;
  //   console.log(item);
  //   const { checked } = e.target;
  //   const value = e.target.serial;
  //   if (checked) {
  //     this.push('paidInvoicesList', value);
  //     return console.log({ paidInvoicesList: this.paidInvoicesList });
  //   } else {
  //     const index = this.paidInvoicesList.indexOf(value);
  //     if (index > -1) {
  //       return this.splice('paidInvoicesList', index, 1);
  //     }
  //   }
  // },

  // _payButtonPressed(e) {
  //   if (!this.paidInvoicesList.length) {
  //     return this.domHost.showModalDialog("You haven't selected any invoice");
  //   }

  //   const data = {
  //     apiKey: this.user.apiKey,
  //     serialList: this.paidInvoicesList
  //   };

  //   return this.callApi('/bdemr--clinic-update-commission-paid-status', data, (err, response) => {
  //     if (response.hasError) {
  //       return this.domHost.showModalDialog(response.error.message);
  //     } else {
  //       this.paidInvoicesList = [];
  //       return window.location.reload();
  //     }
  //   });
  // },

  _saveAsExpenseInvoice(invoice) {
    const expense = {
      serial: this.generateSerialForExpense(),
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: lib.datetime.now(),
      invoiceType: 'general',
      category: 'commission',
      totalBilled: parseFloat(invoice.commission.amount),
      discount: 0,
      vatOrTax: 0,
      totalAmountPaid: parseFloat(invoice.commission.amount),
      flags: {
        flagAsError: false,
        markAsCompleted: false
      },
      data: [{
        name: `Commiision to ${invoice.commission.name}`,
        category: 'commission',
        qty: 1,
        unitPrice: parseFloat(invoice.commission.amount)
      }],
      customerDetails: {
        name: invoice.commission.name || '',
        phone: invoice.commission.mobile || '',
        address: invoice.commission.address || ''
      }
    };
    app.db.upsert('organization-accounts-expense', expense, ({ serial }) => serial === expense.serial);
  },


  _payButtonPressed(e) {
    const { item } = e.model;
    console.log(item);

    if (item.commission._id) {
      this._callThirdPartyWithdrawApi(item.commission._id, item.commission.amount, () => {
        null;
      });
    }

    const data = {
      apiKey: this.user.apiKey,
      serialList: [item.serial]
    };
    // return console.log(data)

    return this.callApi('/bdemr--clinic-update-commission-paid-status', data, (err, response) => {
      console.log('error', err);
      console.log('response', response);

      if (err) {
        return this.domHost.showModalDialog(err.message);
      }
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this._saveAsExpenseInvoice(item);
        this.searchButtonClicked()
        return this.domHost.showModalDialog('Updated Successfully');
      }


    });
  },

  _callThirdPartyWithdrawApi(thirdPartyId, widthdrawAmount, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      thirdPartyId: thirdPartyId,
      widthdrawAmount: widthdrawAmount,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--organization-third-party-withdraw', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },


  viewCommissionButtonPressed(e) {
    const { item } = e.model;
    return this.domHost.navigateToPage(`#/print-invoice/invoice:${item.referenceNumber}/patient:${item.patientSerial}`);
  },

  resetButtonClicked(e) {
    return window.location.reload();
  }

});
