
Polymer({
  is: 'page-accounts-income-editor',
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

    incomeItem: {
      type: Object,
      value: {}
    },

    income: {
      type: Object,
      value: {}
    },

    incomeCategories: {
      type: Array,
      value: []
    },

    incomeGross: Number,
    incomeVatOrTax: Number
  },

  observers: [
    'calculateGrossPrice(income.data.*)',
    'calculateTotalBilled(incomeGross, income.discount, income.vatOrTax)'
  ],

  navigatedIn() {
    const params = this.domHost.getPageParams()
    this._loadUser();
    if (params['organization']) {
      this._loadOrganization(params['organization'], () => {
        if (params['income'] === 'new') {
          refreshIncomePageFlag = JSON.parse(localStorage.getItem('refreshIncomeEditorPage'));
          if (refreshIncomePageFlag && !refreshIncomePageFlag.value) {
            previewIncomeInvoice = JSON.parse(localStorage.getItem('previewIncomeInvoiceObject'))
            this.set('income', previewIncomeInvoice);
            localStorage.removeItem('refreshIncomeEditorPage');
            localStorage.removeItem('previewIncomeInvoiceObject');
          } else {
            this._makeNewIncomeItem()
          }
        } else {
          this._loadIncomeItem(params['income'])
          if (this.income.vatOrTax) {
            const vatOrTaxPercentage = (this.income.vatOrTax / this.incomeGross) * 100;
            this.$.vatTax.value = vatOrTaxPercentage;
          }
        }
        this._loadIncomeCategories(params['organization'])
        this._makeNewItem()
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

  _makeNewItem() {
    this.set('incomeItem', {
      name: '',
      category: '',
      categoryId: '',
      qty: 1,
      unitPrice: 0,
      actualCost: 0
    })
  },

  _makeNewIncomeItem() {
    const income = {
      serial: '',
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      createdByUserName: this.user.name,
      organizationId: this.organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: null,
      invoiceType: 'income',
      category: '',
      totalBilled: 0,
      discount: 0,
      vatOrTax: 0,
      totalAmountReceieved: 0,
      flags: {
        flagAsError: false,
        markAsCompleted: false
      },
      data: [],
      customerDetails: {
        name: "",
        phone: "",
        address: ""
      }
    };

    return this.set('income', income);
  },

  _loadIncomeItem(incomeItemIdentifier) {
    // let list = app.db.find('organization-accounts-income', ({ serial }) => serial === incomeItemIdentifier);
    // if (list.length) {
    //   this.set('income', list[0])
    // } else {
    //   return this.domHost.showModalDialog("Invalid Income Item");
    // }

    // switched to API based calling
    const query = {
      apiKey: this.user.apiKey,
      invoiceSerial: incomeItemIdentifier
    };
    this.callApi('/bdemr--organization-accounts-get-single-income-invoice', query, (err, response) => {
      if (response.hasError) {
        return this.domHost.showModalDialog("Invalid Income Item");
      }
      else {
        const incomeItem = response.data[0];
        console.log('INCOME', incomeItem);
        this.set('income', incomeItem)
      }
    });      
  },

  _loadIncomeCategories(organizationIdentifier) {
    // let list = app.db.find('organization-accounts-income-categories', ({ organizationId }) => organizationId === organizationIdentifier);
    // if (list.length) {
    //   this.set('incomeCategories', list)
    // }
    const data = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    };
    this.callApi('/bdemr--organization-income-invoice-category-list', data, (err, response) => {
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      else {
        let incomeCategoryList = response.data
        this.set('incomeCategories', incomeCategoryList);
        console.log("Categories: ", this.incomeCategories)
        return
      }
    });
  },

  incomeCategoryCustomSet(e) {
    let categoryName = e.detail.trim();
    let found = this.incomeCategories.some((item) => item.name.toLowerCase() === categoryName.toLowerCase())
    if (!found) {
      let newCategory = {
        serial: this.generateSerialForCustomIncomeCategory(),
        createdDatetimeStamp: lib.datetime.now(),
        createdByUserSerial: this.user.serial,
        organizationId: this.organization.idOnServer,
        lastModifiedDatetimeStamp: lib.datetime.now(),
        name: categoryName
      }
      app.db.upsert('organization-accounts-income-categories', newCategory, ({ serial }) => serial === newCategory.serial);
      this.push('incomeCategories', newCategory);
      this.incomeItem.categoryId = newCategory.serial;
    }
  },

  categorySelected(e) {
    let selectedCategory = e.detail.value;
    if (!selectedCategory) return;
    this.incomeItem.categoryId = selectedCategory.serial;
  },

  _validateNewItem(incomeItem) {
    let { name, category, qty, unitPrice } = incomeItem;
    if (!name || !category || !qty || !unitPrice) {
      return false;
    }
    return true;
  },

  addItemButtonClicked() {
    // return console.log(this.incomeItem)
    let valid = this._validateNewItem(this.incomeItem);
    if (valid) {
      this.incomeItem.qty = parseInt(this.incomeItem.qty)
      this.incomeItem.unitPrice = parseFloat(this.incomeItem.unitPrice)
      if (this.incomeItem.actualCost) this.incomeItem.actualCost = parseFloat(this.incomeItem.actualCost)
      this.push('income.data', this.incomeItem)
      this._makeNewItem()
    } else {
      return this.domHost.showModalDialog('Please Correct the Input')
    }
  },

  getItemTotal(item) {
    return this.$toTwoDecimalPlace(item.qty * item.unitPrice)
  },

  deleteItemClicked(e) {
    let index = e.model.index;
    this.domHost.showModalPrompt('Are you sure to Delete this Item', (yes) => {
      if (yes) {
        this.splice('income.data', index, 1);
      }
    })
  },

  calculateGrossPrice() {
    if (!this.income.data) return;
    let gross = this.income.data.reduce((total, item) => {
      return total += (item.qty * item.unitPrice);
    }, 0)
    this.set('incomeGross', gross);
  },

  vatTaxInputChanged(e) {
    let vatOrTax = parseFloat(e.target.value);
    const vatOrTaxtAmt = (this.incomeGross * vatOrTax) / 100;
    this.set("income.vatOrTax", vatOrTaxtAmt);
  },

  calculateTotalBilled(gross, discount, vat) {
    let total = (parseFloat(gross) - parseFloat(discount ? discount : 0)) + parseFloat(vat ? vat : 0);
    this.set('income.totalBilled', total)
  },

  cacluateDue(totalBilled, totalAmountReceieved) {
    let due = parseFloat(totalBilled) - parseFloat(totalAmountReceieved ? totalAmountReceieved : 0)
    return due > 0 ? this.$toTwoDecimalPlace(due) : 0
  },

  _validateIncomeObject(income) {
    if (!income.data.length || !income.totalAmountReceieved) {
      this.domHost.showWarningToast('Please Add Some Item and Input Received Amount')
      return false;
    }
    if (income.totalAmountReceieved > income.totalBilled) {
      this.domHost.showWarningToast('Amount Recieved Can not be greater than Amount Billed')
      return false;
    }
    return true;
  },

  saveButtonClicked() {
    // return console.log(this.income);
    let valid = this._validateIncomeObject(this.income);
    if (!valid) return;

    // Converting Input to Number Type
    if (this.income.discount) this.income.discount = parseFloat(this.income.discount)
    if (this.income.totalAmountReceieved) this.income.totalAmountReceieved = parseFloat(this.income.totalAmountReceieved)

    if (!this.income.serial) this.income.serial = this.generateSerialForIncome();
    this.income.lastModifiedDatetimeStamp = Date.now()
    const data = {
      apiKey: this.user.apiKey,
      income: this.income
    };
    this.callApi('/bdemr--clinic-add-income-from-income-manager', data, (err, response) => {
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      return
    });   
    // app.db.upsert('organization-accounts-income', this.income, ({ serial }) => serial === this.income.serial);
    app.db.upsert('organization-accounts-clone-income', this.income, ({ serial }) => serial === this.income.serial);
    this.domHost.showSuccessToast('Saved Successfully')
    this._makeNewIncomeItem()
  },

  invoiceDateChangeOpenModalClicked() {
    this.customVisitDate = ""
    this.customVisitTime = ""
    this.$.invoiceDateModal.toggle()
  },

  saveNewInvoiceDateButtonClicked() {
    if (!this.customVisitDate) return;
    let invoiceDateTime = +new Date(`${this.customVisitDate} ${this.customVisitTime}`)
    this.set('income.createdDatetimeStamp', invoiceDateTime)
    this.$.invoiceDateModal.toggle()
  },

  cancelButtonClicked() {
    return this.domHost.navigateToPreviousPage();
  },

  arrowBackButtonPressed() {
    this.domHost.navigateToPreviousPage()
  },

  _printPreviewButtonPressed(e) {
    localStorage.removeItem('previewIncomeInvoiceObject')
    localStorage.removeItem('refreshIncomeEditorPage')

    localStorage.setItem('previewIncomeInvoiceObject', JSON.stringify(this.income))
    localStorage.setItem('refreshIncomeEditorPage', JSON.stringify({ value: false }))

    this.domHost.navigateToPage('#/accounts-income-print-preview-incomplete/organization:' + this.organization.idOnServer);
  },



})