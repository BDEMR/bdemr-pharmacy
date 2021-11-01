
Polymer({
  is: 'page-accounts-expense-editor',
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

    expenseItem: {
      type: Object,
      value: {}
    },

    expense: {
      type: Object,
      value: {}
    },

    expenseCategories: {
      type: Array,
      value: []
    },

    expenseGross: Number,
    expenseVatOrTax: Number
  },

  observers: [
    'calculateGrossPrice(expense.data.*)',
    'calculateTotalBilled(expenseGross, expense.discount, expense.vatOrTax)'
  ],

  navigatedIn() {
    const params = this.domHost.getPageParams()
    this._loadUser();
    if (params['organization']) {
      this._loadOrganization(params['organization'], () => {
        if (params['expense'] === 'new') {
          refreshExpensePageFlag = JSON.parse(localStorage.getItem('refreshExpenseEditorPage'));
          if (refreshExpensePageFlag && !refreshExpensePageFlag.value) {
            previewExpenseInvoice = JSON.parse(localStorage.getItem('previewExpenseInvoiceObject'))
            this.set('expense', previewExpenseInvoice);
            localStorage.removeItem('refreshExpenseEditorPage');
            localStorage.removeItem('previewExpenseInvoiceObject');
          } else {
            this._makeNewExpenseItem();
          }
        } else {
          this._loadExpenseItem(params['expense'])
          if (this.expense.vatOrTax) {
            const vatOrTaxPercentage = (this.expense.vatOrTax / this.expenseGross) * 100;
            this.$.vatTax.value = vatOrTaxPercentage;
          }
        }
        this._loadExpenseCategories(params['organization'])
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
    this.set('expenseItem', {
      name: '',
      category: '',
      qty: 1,
      unitPrice: 0
    })
  },

  _makeNewExpenseItem() {
    const expense = {
      serial: '',
      recordCreatedDateTimeStamp: lib.datetime.now(),
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: null,
      invoiceType: 'expense',
      category: '',
      totalBilled: 0,
      discount: 0,
      vatOrTax: 0,
      totalAmountPaid: 0,
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
    return this.set('expense', expense);
  },

  _loadExpenseItem(expenseItemIdentifier) {
    // let list = app.db.find('organization-accounts-expense', ({ serial }) => serial === expenseItemIdentifier);
    // if (list.length) {
    //   this.set('expense', list[0])
    // } else {
    //   return this.domHost.showModalDialog("Invalid Expense Item");
    // }

    // switched to API based calling
    const query = {
      apiKey: this.user.apiKey,
      invoiceSerial: expenseItemIdentifier
    };
    this.callApi('/bdemr--organization-accounts-get-single-expense-invoice', query, (err, response) => {
      if (response.hasError) {
        return this.domHost.showModalDialog("Invalid Income Item");
      }
      else {
        const expenseItem = response.data[0];
        console.log('EXPENSE', expenseItem);
        this.set('expense', expenseItem)
      }
    });   
    
  },

  _loadExpenseCategories(organizationIdentifier) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    };
    this.callApi('/bdemr--organization-expense-invoice-category-list', data, (err, response) => {
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      else {
        let expenseCategoryList = response.data
        this.set('expenseCategories', expenseCategoryList);
        console.log("Categories: ", this.expenseCategories)
        return
      }
    });
    // let list = app.db.find('organization-accounts-expense-categories', ({ organizationId }) => organizationId === organizationIdentifier);
    // if (list.length) {
    //   this.set('expenseCategories', list)
    // }
    // console.log("expense cateogyr", this.expenseCategories)
  },

  categorySelected(e) {
    let selectedCategory = e.detail.value;
    if (!selectedCategory) return;
    this.expenseItem.categoryId = selectedCategory.serial;
    this.expense.category = selectedCategory.name
  },

  expenseCategoryCustomSet(e) {
    let categoryName = e.detail.trim();
    let found = this.expenseCategories.some((item) => item.name.toLowerCase() === categoryName.toLowerCase())
    if (!found) {
      let newCategory = {
        serial: this.generateSerialForCustomExpenseCategory(),
        createdDatetimeStamp: lib.datetime.now(),
        createdByUserSerial: this.user.serial,
        lastModifiedDatetimeStamp: lib.datetime.now(),
        organizationId: this.organization.idOnServer,
        name: categoryName
      }
      app.db.upsert('organization-accounts-expense-categories', newCategory, ({ serial }) => serial === newCategory.serial);
      this.push('expenseCategories', newCategory);
      this.set('expense.category', categoryName)
      this.expenseItem.categoryId = newCategory.serial;
    }
  },

  _validateNewItem(expenseItem) {
    let { name, category, qty, unitPrice } = expenseItem;
    if (!name || !category || !qty || !unitPrice) {
      return false;
    }
    return true;
  },

  addItemButtonClicked() {
    // return console.log(this.expenseItem)
    let valid = this._validateNewItem(this.expenseItem);
    if (valid) {
      this.expenseItem.qty = parseInt(this.expenseItem.qty)
      this.expenseItem.unitPrice = parseFloat(this.expenseItem.unitPrice)
      this.push('expense.data', this.expenseItem)
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
        this.splice('expense.data', index, 1);
      }
    })
  },

  calculateGrossPrice() {
    if (!this.expense.data) return;
    let gross = this.expense.data.reduce((total, item) => {
      return total += (item.qty * item.unitPrice);
    }, 0)
    this.set('expenseGross', gross);
  },

  vatTaxInputChanged(e) {
    let vatOrTax = parseFloat(e.target.value);
    const vatOrTaxtAmt = (this.expenseGross * vatOrTax) / 100;
    this.set("expense.vatOrTax", vatOrTaxtAmt);
  },

  calculateTotalBilled(gross, discount, vat) {
    let total = (parseFloat(gross) - parseFloat(discount ? discount : 0)) + parseFloat(vat ? vat : 0);
    this.set('expense.totalBilled', total)
  },

  cacluateDue(totalBilled, totalAmountPaid) {
    let due = parseFloat(totalBilled) - parseFloat(totalAmountPaid ? totalAmountPaid : 0)
    return due > 0 ? this.$toTwoDecimalPlace(due) : 0
  },

  _validateExpenseObject(expense) {
    if (!expense.data.length || !expense.totalAmountPaid) {
      this.domHost.showWarningToast('Please Add Some Item and Input Paid Amount')
      return false;
    }
    if (expense.totalAmountPaid > expense.totalBilled) {
      this.domHost.showWarningToast('Amount Recieved Can not be greater than Amount Billed')
      return false;
    }
    return true;
  },

  saveButtonClicked() {
    console.log(this.expense);
    let valid = this._validateExpenseObject(this.expense);
    if (!valid) return;


    // Converting Input to Number Type
    if (this.expense.discount) this.expense.discount = parseFloat(this.expense.discount)
    if (this.expense.totalAmountPaid) this.expense.totalAmountPaid = parseFloat(this.expense.totalAmountPaid)


    if (!this.expense.serial) this.expense.serial = this.generateSerialForExpense();
    this.expense.lastModifiedDatetimeStamp = Date.now()
    // app.db.upsert('organization-accounts-expense', this.expense, ({ serial }) => serial === this.expense.serial);
    const data = {
      apiKey: this.user.apiKey,
      expense: this.expense
    };
    this.callApi('/bdemr--clinic-add-expense-from-expense-manager', data, (err, response) => {
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      return
    });
    this.domHost.showSuccessToast('Saved Successfully')
    this._makeNewExpenseItem()
  },

  invoiceDateChangeOpenModalClicked() {
    this.customVisitDate = ""
    this.customVisitTime = ""
    this.$.invoiceDateModal.toggle()
  },

  saveNewInvoiceDateButtonClicked() {
    if (!this.customVisitDate) return;
    let invoiceDateTime = +new Date(`${this.customVisitDate} ${this.customVisitTime}`)
    this.set('expense.createdDatetimeStamp', invoiceDateTime)
    this.$.invoiceDateModal.toggle()
  },



  cancelButtonClicked() {
    return this.domHost.navigateToPreviousPage();
  },

  arrowBackButtonPressed() {
    return this.domHost.navigateToPreviousPage();
  },

  _printPreviewButtonPressed(e) {
    localStorage.removeItem('previewExpenseInvoiceObject')
    localStorage.removeItem('refreshExpenseEditorPage')

    localStorage.setItem('previewExpenseInvoiceObject', JSON.stringify(this.expense))
    localStorage.setItem('refreshExpenseEditorPage', JSON.stringify({ value: false }))

    this.domHost.navigateToPage('#/accounts-expense-print-preview-incomplete/organization:' + this.organization.idOnServer);
  },



})