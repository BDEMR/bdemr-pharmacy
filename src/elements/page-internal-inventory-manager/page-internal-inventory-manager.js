Polymer({
  is: 'page-internal-inventory-manager',

  behaviors: [
    app.behaviors.dbUsing,
    app.behaviors.apiCalling,
    app.behaviors.translating,
    app.behaviors.commonComputes,
    app.behaviors.pageLike
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

    inventoryList: {
      type: Array,
      value: []
    },

    internalInventory: {
      type: Object,
      value: {}
    },

    isLoading: {
      type: Boolean,
      value: false
    },

    selectedPage: {
      type: Number,
      value: 0
    },

    brandNameSourceDataList: {
      type: Array,
      value: []
    },

    statusList: {
      type: Array,
      value: ['recieved', 'Urgent request']
    },

    addStatus: {
      type: Object,
      value: {}
    },

    selectedPage: {
      type: Number,
      value: 0,
      observer: "_tabIndexChange"
    },

    selectedSubSection: {
      type: Number,
      value: 0
    },

    wardList: {
      type: Array,
      value: []
    },

    selectedWard: {
      type: Object,
      value: {}
    },

    pharmacyItemList: {
      type: Array,
      value: []
    },

    selectedPharmacyItem: {
      type: Object,
      value: null
    },

    selectedPage: {
      type: Number,
      value: 0
    }

  },

  _formatDate(dateTime) {
    return lib.datetime.format(dateTime, 'mmm d, yyyy');
  },
  _returnSerial (index){
    return index+1;
  },
  _tabIndexChange(newIndex, oldIndex) {
    if (this.wardList)
      this.selectedWard = this.wardList[this.selectedPage];

    if (this.selectedWard) {
      this._loadData();
    }

      
  },

  attached() {
    // this.domHost.getStaticData('medicineCompositionList', medicineCompositionList => {
    //   this._loadMedicineCompositionList(medicineCompositionList);
    // });
  },

  navigatedIn() {
    this._loadUser();

    this._loadOrganization(this.getCurrentOrganization().idOnServer, () => {
      this._loadPatientStayObject(() => {
        this._loadData();
        this._resetInternalInventoryForm();
      });
      
    });
  },

  _loadData() {
    this._loadPharmacyInventoryItems(this.organization.idOnServer);
    this._loadInternalInventoryItems(this.selectedWard.serial);
    this._loadInternalInventoryTransactionList(this.selectedWard.serial);
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
    this.set('isLoading', true);
    this.callApi('/bdemr-organization-list-organizations-by-ids', data, (err, response) => {
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        if (response.data.matchingOrganizationList.length !== 1) {
          this.domHost.showModalDialog("Invalid Organization");
          return;
        }
        this.set('organization', response.data.matchingOrganizationList[0]);
        this.set('isLoading', false);
        return cbfn();
      }
    });
  },

  
  _loadInternalInventoryItems(locationIdentifier) {
    return this.inventoryList = app.db.find('organization-internal-inventory', ({ location }) => location.serial === locationIdentifier);
  },

  _loadPharmacyInventoryItems(idOnServer) {
    list = app.db.find('organization-inventory', ({ organizationId }) => organizationId === idOnServer);
    
    pharmacyItemList = []

    if (list.length > 0) {
      for (let item of list) {
        object = {
          label: item.data.name,
          value: item
        }
        pharmacyItemList.push(object);
      }
    }

    

    this.set('pharmacyItemList',pharmacyItemList);
    console.log(this.pharmacyItemList);
  },


  _loadMedicineCompositionList(medicineCompositionList) {
    console.log(medicineCompositionList);
    const brandNameMap = {};
    for (let item of medicineCompositionList) {
      brandNameMap[item.brandName] = null;
    }
    this.brandNameSourceDataList = Object.keys(brandNameMap)

    console.log(this.brandNameSourceDataList);
  },

  _resetInternalInventoryForm() {
    // Setting Expiry Date to One Year From Now
    const d = new Date();
    d.setFullYear(d.getFullYear() + 1);

    const internalInventory = {
      serial: this.generateSerialForInventoryItem(),
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      lastSyncedDatetimeStamp: 0,

      location: {
        serial: null,
        type: null,
        name: null
      },
        
      data: {
        name: "",
        buyingPrice: null,
        sellingPrice: null,
        qty: 1,
        category: 'pharmacy',
        batch: '',
        expiryDate: lib.datetime.mkDate(d)
      }
    };
    return this.set('internalInventory', internalInventory);
  },


  _validateInput(internalInventory) {
    if (!internalInventory.data.name || !internalInventory.data.buyingPrice || !internalInventory.data.sellingPrice || !internalInventory.data.qty) {
      this.domHost.showToast('Please Input Required Information!');
      return false;
    }
    return true;
  },

  _addToInventoryButtonClicked() {
    if (!this._validateInput(this.internalInventory)) return;
    this.internalInventory.lastModifiedDatetimeStamp = lib.datetime.now();
    app.db.upsert('organization-internal-inventory', this.internalInventory, ({ serial }) => serial === this.internalInventory.serial);
    this._resetInternalInventoryForm();
    this.$$('#dialogAddNewPharmacyItem').close();
    this._loadInternalInventoryItems(this.selectedWard.serial);
  },

  editInventoryItemButtonClicked(e) {
    const { item, index } = e.model;
    const internalInventory = {
      serial: item.serial,
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: item.createdByUserSerial,
      organizationId: item.organizationId,
      data: {
        name: item.data.name,
        buyingPrice: item.data.buyingPrice,
        sellingPrice: item.data.sellingPrice,
        qty: item.data.qty,
        batch: item.data.batch || '',
        expiryDate: item.data.expiryDate
      }
    };
    this.set('internalInventory', internalInventory);
    this.$$('#dialogAddNewPharmacyItem').toggle();
  },

  deleteInventoryItemButtonClicked(e) {
    this.domHost.showModalPrompt('Are you sure you want to delete this', (done) => {
      if (done) {
        const { item, index } = e.model;
        item.lastModifiedDatetimeStamp = lib.datetime.now();
        app.db.remove('organization-internal-inventory', item._id);
        app.db.insert('organization-internal-inventory--deleted', item);
        this.splice('inventoryList', index, 1);
      }
    })
  },


  _notifyInvalidOrganization() {
    return this.domHost.showModalDialog('No Organization is Present. Please Select an Organization first.');
  },

  _notifyInvalidAccess() {
    return this.domHost.showModalPrompt('You Do Not Have Access To This Page!', () => {
      return this.domHost.navigateToPreviousPage();
    });
  },

  arrowBackButtonPressed(e) {
    return this.domHost.navigateToPreviousPage();
  },

  goToPharmacyInvoice() {
    this.domHost.navigateToPage("#/pharmacy-invoice-editor/location:ward/locationId:" + this.selectedWard.serial + "/invoice:new");
  },

  showPharmacyItemEditorDialog() {
    this.$$('#dialogAddNewPharmacyItem').toggle();
  },

  inventoryEditModalClosed(e) {
    this._resetInternalInventoryForm();
  },


  // Internal inventory transation (request) - start

  requestAnItemButtonPressed () {
    this._resetInternalOrderObject();
    this.set('ORDER_EDIT_MODE_ON', false);
    this.showRequestPharmacyItemDialog();
  },

  showRequestPharmacyItemDialog() {
    this.set('selectedPharmacyItem', null);
    this.$$('#dialogRequestPharmacyItem').toggle();
  },

  _loadInternalInventoryTransactionList(selectedWardSerial) {
    return this.inventoryTransactionList = app.db.find('organization-internal-inventory-transaction', ({ location }) => location.serial === selectedWardSerial);
  },
  
  _resetInternalOrderObject() {
    var internalOrder = {
      serial: 'new',
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      createdDatetimeStamp: null,
      lastSyncedDatetimeStamp: 0,
      clientCollectionName: 'organization-internal-inventory-transaction',
      isSelected: false,

      location: {
        serial: this.selectedWard.serial,
        name: this.selectedWard.name,
        type: 'ward'
      },
        
      data:[],
      status: [
        {
          type: 'requested',
          createdDatetimeStamp: lib.datetime.now(),
          by: this.user.idOnServer,
          name: this.user.name,
          class: '',
          isDone: true,
          fromLocationName: this.selectedWard.name, 
          fromLocationSerial: this.selectedWard.serial
        }
      ],
      buttonState: {
        hideRecievedButton: true,
        hideAcceptButton: false,
        hideDeliveredButton:true,
        hideCancelButton: false,
        hideRerequestButton: false,
        hideEditButton: false,
        hidePrintButton: false,
      }
      
    };
    this.set('internalOrder', internalOrder);
  },

  makeInternalItemObject(pharmacyItem) {
    return {
      serial: pharmacyItem.serial,
      name: pharmacyItem.data.name,
      qty: 0,
    };
  },

  addInternalItem() {
    console.log(this.selectedPharmacyItem);
    if (!this.selectedPharmacyItem) {
      return this.domHost.showToast('Select a pharmacy item first!');
    }
    var item = this.makeInternalItemObject(this.selectedPharmacyItem);
    this.push('internalOrder.data', item);
    this.set('selectedPharmacyItem', null);

  },
  removeInternalItem(e) {
    index = e.model.index;
    this.splice('internalOrder.data', index, 1);
  },

  sendRequestBtnPressed(){
    if (this.internalOrder.data.length == 0) {
      this.domHost.showToast('Add atleast one item!');
      return;
    }

    if (this.internalOrder.serial == 'new')
      this.internalOrder.serial = this.generateSerialForInternalInventoryItem();
      this.internalOrder.createdDatetimeStamp = lib.datetime.now();
    
    if (this.internalOrder.location.serial == null) {
      this.internalOrder.location.serial = this.selectedWard.serial;
      this.internalOrder.location.name = this.selectedWard.name;
      this.internalOrder.location.type = 'ward';
    }

    this.internalOrder.lastModifiedDatetimeStamp = lib.datetime.now();

    console.log(this.internalOrder);

    app.db.upsert('organization-internal-inventory-transaction', this.internalOrder, ({ serial }) => serial === this.internalOrder.serial);
    console.log(this.internalOrder);
    this._resetInternalOrderObject();
    this.$$('#dialogRequestPharmacyItem').close();
    return this._loadInternalInventoryTransactionList(this.selectedWard.serial);
  },

  _onTapRecievedButtonPressed(e) {
    index = e.model.index;
    internalOrder = this.inventoryTransactionList[index];
    var statusObject = {
      type: 'recieved',
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: 'success',
      isDone: true,
      fromLocationName: this.selectedWard.name, 
      fromLocationSerial: this.selectedWard.serial
    };
    internalOrder.status.push(statusObject);
    internalOrder.lastModifiedDatetimeStamp = lib.datetime.now();

    //update button state
    internalOrder.buttonState.hideCancelButton = true;
    internalOrder.buttonState.hideDeliveredButton = true;
    internalOrder.buttonState.hideRecievedButton = true;
    internalOrder.buttonState.hideAcceptButton = true;
    internalOrder.buttonState.hideRerequestButton = false;
    internalOrder.buttonState.hideEditButton = true;

    app.db.upsert('organization-internal-inventory-transaction', internalOrder, ({ serial }) => serial === internalOrder.serial);
    
    internalOrder.data.forEach(internalOrder => {
      this._addToInternalInventoryFromPharmacy(internalOrder);
    });

    
    this._loadInternalInventoryTransactionList(this.selectedWard.serial);
  },
  _onTapCancelButtonPressed(e) {
    index = e.model.index;
    internalOrder = this.inventoryTransactionList[index];
    var statusObject = {
      type: 'canceled',
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: 'danger',
      isDone: true,
      fromLocationName: this.selectedWard.name, 
      fromLocationSerial: this.selectedWard.serial
    };
    internalOrder.status.push(statusObject);
    internalOrder.lastModifiedDatetimeStamp = lib.datetime.now();

    //update button state
    internalOrder.buttonState.hideCancelButton = true;
    internalOrder.buttonState.hideDeliveredButton = true;
    internalOrder.buttonState.hideRecievedButton = true;
    internalOrder.buttonState.hideAcceptButton = true;
    internalOrder.buttonState.hideRerequestButton = false;
    internalOrder.buttonState.hideEditButton = true;


    app.db.upsert('organization-internal-inventory-transaction', internalOrder, ({ serial }) => serial === internalOrder.serial);
    this._loadInternalInventoryTransactionList(this.selectedWard.serial);
  },

  _onTapPrintButtonPressed(e) {
    index = e.model.index;
    item = this.inventoryTransactionList[index];
    this.domHost.navigateToPage("#/internal-inventory-transaction-preview/record:" + item.serial);
  },

  _onTapEditButtonPressed(e) {
    index = e.model.index;
    this.internalOrder = this.inventoryTransactionList[index];
    this.set('ORDER_EDIT_MODE_ON', true);
    this.showRequestPharmacyItemDialog();
    
  },

  _addToInternalInventoryFromPharmacy(requestItem) {
    // TO do
    pharmacyItemIdentifier = requestItem.serial

    item = (app.db.find('organization-inventory', ({ serial }) => serial === pharmacyItemIdentifier))[0];

    this.internalInventory.location.serial = this.selectedWard.serial;
    this.internalInventory.location.type = 'ward';
    this.internalInventory.location.name = this.selectedWard.name;

    this.internalInventory.data = item.data;
    this.internalInventory.data.qty = requestItem.qty;

    this.internalInventory.lastModifiedDatetimeStamp = lib.datetime.now();

    app.db.upsert('organization-internal-inventory', this.internalInventory, ({ serial }) => serial === this.internalInventory.serial);
    
    this._loadInternalInventoryItems(this.selectedWard.serial);
    this._resetInternalInventoryForm();

    return;
  },

  _checkIfOrderSatusAvailable () {
    if (status && typeIdentifier) {
      for (let item of status) {
        if ((item.type == typeIdentifier) && (item.isDone)) {
          return true;
        }
      }
    }
    return false;
  },

  _loadPatientStayObject(cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/bdemr-organization-patient-stay-get-object', data, (err, response) => {
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        departmentList = response.data.patientStayObject.departmentList
        var wardList = this.$getWardListFilterByUserId(departmentList, this.user.idOnServer);

        if (wardList.length === 0) {
          this.domHost.showModalDialog("You don't have access on Internal Inventory Manager. Please contact with your administrator!");
          this.arrowBackButtonPressed();
          return;
        }

        this.set("wardList", wardList);

        this.selectedWard = wardList[0];
        this.set('selectedPage', 0);
        console.log(this.selectedWard);
        this.set('isLoading', false);
        return cbfn();
      }
    });
  },

  _hideButtonByOrderStatus (statusList) {
    if (statusList) {
      for (let item of statusList) {
        if (item.type == 'recieved') {
          return true;
        }
        if (item.type == 'canceled') {
          return true;
        }
      }
      return false;
    } 
  }

  // Internal inventory transation (request) - end


});