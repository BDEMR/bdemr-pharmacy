
Polymer({
  is: 'page-accounts-refund-invoice',
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

    patient: {
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

    patientSearchQuery: {
      type: String,
      value: "",
      observer: 'patientSearchKeyPressed'
    },

    inventoryItemSearchQuery: {
      type: String,
      value: "",
      observer: 'inventoryItemSearchQueryChanged'
    },

    showPatientSearchBox: {
      type: Boolean,
      value: true,
      notify: true
    },

    invoiceDiscount: {
      type: Number,
      value: 0,
      observer: 'discountInputChanged'
    },

    discountType: {
      type: Number,
      value: 0,
    },

    expenseGross: Number,
    expenseVatOrTax: Number
  },

  observers: [
    'calculateGrossPrice(expense.data.*)',
    'calculateTotalBilled(expenseGross, expense.discount, expense.vatOrTax)'
  ],

  navigatedIn() {
    this._loadUser();
    this._loadOrganization(() => {
      this._makeNewExpenseItem();
      this._makeNewItem()
    });
  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },

  _loadOrganization(cbfn) {
    organization = (app.db.find('organization'))[0];
    const data = {
      apiKey: this.user.apiKey,
      idList: [organization.idOnServer]
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
      unitPrice: 0,
      itemId: null
    })
  },

  _makeNewExpenseItem() {
    const expense = {
      serial: null,
      recordCreatedDateTimeStamp: lib.datetime.now(),
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: null,
      invoiceType: 'expense',
      category: 'refund',
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
    let list = app.db.find('organization-accounts-expense', ({ serial }) => serial === expenseItemIdentifier);
    if (list.length) {
      this.set('expense', list[0])
    } else {
      return this.domHost.showModalDialog("Invalid Expense Item");
    }
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
    let { name, qty, unitPrice } = expenseItem;
    if (!name || !qty || !unitPrice) {
      return false;
    }
    return true;
  },

  addItemButtonClicked() {
    console.log(this.expenseItem)
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

  saveButtonClicked(cbfn, serial) {
    console.log(this.expense);
    let valid = this._validateExpenseObject(this.expense);
    if (!valid) return;


    // Converting Input to Number Type
    if (this.expense.discount) this.expense.discount = parseFloat(this.expense.discount)
    if (this.expense.totalAmountPaid) this.expense.totalAmountPaid = parseFloat(this.expense.totalAmountPaid)
    this._refundInventoryItems(this.expense)
    

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
    cbfn(this.expense.serial)
  },

  saveInvoice() {
    this.saveButtonClicked((serial) => {
      console.log("Invoice updated", serial)
      this._makeNewExpenseItem()
    })
  },

  savePlusPrintPreview() {
    this.saveButtonClicked((serial) => {
      console.log("Invoice updated", serial)
      this._printPreviewButtonPressed(serial)
    })
  },

  _refundInventoryItems(invoice) {
    var apiData, data, filterItems;
    if (invoice.data.length === 0) {
      return;
    }
    data = invoice.data;
    filterItems = data.map((function (_this) {
      return function (item) {
        if(item.itemId) {
          return {
            productId: item.itemId,
            reduceQty: item.qty
          };
        }
        else {
          this.domHost.showModalDialog("Item data corrupted, no product id");
        }
      };
    })(this));
    apiData = {
      apiKey: this.user.apiKey,
      list: filterItems,
      organizationId: this.organization.idOnServer,
      addedByUserName: this.user.name
    };
    return this.callApi('/bdemr-cmh-refund-organization-inventory-item', apiData, (function (_this) {
      return function (err, response) {
        if (response.hasError) {
          return _this.domHost.showModalDialog(response.error.message);
        } else {
          return console.log('Successfully refunded item quantity');
        }
      };
    })(this));
  },


  invoiceDateChangeOpenModalClicked(){
    this.customVisitDate = ""
    this.customVisitTime = ""
    this.$.invoiceDateModal.toggle()
  },

  saveNewInvoiceDateButtonClicked(){
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

  _printPreviewButtonPressed(serial) {
    this.domHost.navigateToPage('#/accounts-expense-print-preview/organization:' + this.organization.idOnServer + '/expense:' + serial);
  },


  showAddPatientDialog() {
    this.patientSearchCleared()
    this.$$("#addPatientDialog").toggle()
  },

  patientSearchCleared() {
    this.patientSearchQuery = ""
    this.$$("#patientSearch").cancel()
  },

  patientSearchKeyPressed(searchQuery) {
    this.debounce('search-patient', () =>
      this._searchPatient(searchQuery)
    , 700)
  },

  _searchPatient(searchQuery) {
    if (!searchQuery) {
      return;
    }
    this.$$("#patientSearch").invalid = false;
    this.fetchingPatientSearchResult = true;
    return this.callApi('/bdemr--clinic-pharmacy-invoice-patient-search', {
      apiKey: this.user.apiKey,
      searchQuery: searchQuery
    }, 
    (err, response)=> {
      var data;
      this.fetchingPatientSearchResult = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        data = response.data;
        if (data.length) {
          return this.$$("#patientSearch").items = data;
        } else {
          return this.$$("#patientSearch").invalid = true;
        }
      }
    })
  },

  patientSelected(e) {
    var userId;
    if (!e.detail.value) {
      return;
    }
    else {
      this.set('showPatientSearchBox', false);
      userId = e.detail.value;
      this.$$("#patientSearch")._clear();
      this.$$("#addPatientDialog").close();
      return this.importSelectedPatient(userId, ()=> {
        this.patientSearchCleared();
      })
    }
  },

  importSelectedPatient(userId, cbfn) {
    var data;
    data = {
      apiKey: this.user.apiKey,
      userId: userId
    };
    this.importingPatientData = true;
    return this.callApi('/bdemr--clinic-pharmacy-invoice-get-patient-basic-details', data, (err, response)=> {
      this.importingPatientData = false;
      if (err) {
        return this.domHost.showModalDialog('Something went wrong with the Server.');
      } else if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else if (!response.data.length) {
        return this.domHost.showModalDialog('No Patient Found');
      } else {
        this.set('patient', response.data[0]);
        console.log(this.patient)
        this.set('expense.customerDetails.name', this.$getFullName(this.patient.name));
        this.set('expense.customerDetails.phone', this.patient.phone);
        this.set('expense.customerDetails.address', this.$getAddress(this.patient));
        // this.set('patient', response.data[0]);

      }
      return cbfn();
      
    });
  },


  inventoryItemSearchQueryChanged(searchQuery) {
    this.debounce('search-inventory', () =>
      this._searchInventoryItem(searchQuery)
      , 700)
  },

  _searchInventoryItem(searchQuery) {
    if (!searchQuery) {
      return;
    }
    this.fetchingInventoryItemSearchResult = true;
    return this.callApi('/bdemr-get-organization-inventory', {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      filterBy: {
        category: null,
        name: searchQuery.trim()        
      }
    },
    (err, response) => {
      var data;
      this.fetchingInventoryItemSearchResult = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('inventoryItemList', [])
        data = response.data;
        if (data.length) {
          console.log('Inventory', data);
          this.set('inventoryItemList', data)
        } else {
          return this.domHost.showModalDialog('No match found');
        }
      }
    })
  },

  inventoryItemSelected(e) {
    console.log(this.selectedItemValue)
    var selectedItemValue;
    if (!e.detail.value) {
      return;
    }
    else {
      selectedItemValue = e.detail.value;
      console.log(selectedItemValue)
      this.set('selectedItemValue', selectedItemValue.name)
      this.set('expenseItem.name', selectedItemValue.name)
      this.set('expenseItem.itemId', selectedItemValue._id)
      this.set('expenseItem.unitPrice', selectedItemValue.price)
    }
  },

  // New discount system start

  convertDiscountPercentageToAmount(percentage) {
    return (this.expenseGross * percentage) / 100;
  },
  convertDiscountAmountToPercentage(amount) {
    return (amount * 100) / this.expenseGross;
  },

  discountTypeChanged() {
    if (this.invoiceDiscount) {
      return this.discountInputChanged(this.invoiceDiscount);
    }
  },
  discountInputChanged(value) {
    var discountAmt, discountPercentage;
    value = parseFloat(value);
    if (this.discountType === 0) {
      discountPercentage = this.convertDiscountAmountToPercentage(value);
      return this.set("expense.discount", value);
    } else {
      discountPercentage = value;
      discountAmt = this.convertDiscountPercentageToAmount(value);
      console.log({
        discountAmt: discountAmt,
        expenseGross: this.expenseGross,
        value: value
      });
      return this.set("expense.discount", discountAmt);
    }
  },

  // New discount system end

})