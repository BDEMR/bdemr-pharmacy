Polymer({
  is: 'page-store-transaction',

  behaviors: [
  app.behaviors.dbUsing,
  app.behaviors.apiCalling,
  app.behaviors.translating,
  app.behaviors.commonComputes
  ],

  properties: {
    selectedPage: {
      type: Number,
      value: 0
    },
    user: {
      type: Object,
      value: null
    },
    organization: {
      type: Object,
      value: null
    },
    store: {
      type: Object,
      value: null,
      observer: 'storeChanged'
    },
    stores: {
      type: Array,
      value: [],
      observers: 'storesListObserver'
    },
    product: {
      type: Object,
      value: {}
    },
    validates: {
      type: Array,
      value: []
    },
    activeItem: {
      type: Object,
      value: [],
      observer: 'activeItemChanged'
    },

    requestDialogTitle: {
      type: String,
      value: 'New Request'
    },

    EDIT_MODE: {
      type: Boolean,
      value: false
    },
    toggleProductEditor: {
      type: Boolean,
      value: false
    },
    selectedStore: {
      type: Object,
      value: {}
    },
    selectedStoreId: {
      type: Number,
      value: 0
    },
    internalOrder: {
      type: Object,
      value: {}
    },
    storeInventory: {
      type: Array,
      value: []
    },
    requestedList: {
      type: Array,
      value: []
    },
    recievedList: {
      type: Array,
      value: []
    },
    selectedStoreItem: {
      type: Object,
      value: null
    }
    
  },


  storeChanged (store) {
    this._getAllRequestedList(store._id);
    this._getAllRecievedList(store._id);
    this._resetInternalOrderObject();
  },

  _getAllRequestedList(storeId) {
    this._callGetAllRequestListApi(storeId, ()=> {
      null;
    });
  },

  _callGetAllRequestListApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-item-request-list', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.requestedList = response.data;
        cbfn();
      }
    });
  },

  _getAllRecievedList(storeId) {
    this._callGetAllRecievedListApi(storeId, ()=> {
      null;
    });
  },

  _callGetAllRecievedListApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-item-recieved-list', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.recievedList = response.data;
        cbfn();
      }
    });
  },

  _resetInternalOrderObject() {
    var internalOrder = {
      serial: 'new',
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      createdDatetimeStamp: null,
      lastSyncedDatetimeStamp: 0,
      clientCollectionName: 'organization-store-internal-transaction',
      isSelected: false,
      requestedStore: {
        _id: this.store._id,
        name: this.store.data.name
      },

      recievedStore: {
        _id: null,
        name: null
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
          storeId: this.store._id,
          storeName: this.store.data.name
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

  _onTapAcceptButtonPressed(e) {
    index = e.model.index;
    console.log(index);
    requestedItem = this.recievedList[index];
    var statusObject = {
      type: 'accepted',
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: 'success',
      isDone: true,
      storeId: this.store._id,
      storeName: this.store.data.name
    };
    requestedItem.status.push(statusObject);
    requestedItem.lastModifiedDatetimeStamp = lib.datetime.now();

    //update button state
    requestedItem.buttonState.hideCancelButton = true;
    requestedItem.buttonState.hideDeliveredButton = false;
    requestedItem.buttonState.hideRecievedButton = false;
    requestedItem.buttonState.hideAcceptButton = true;
    requestedItem.buttonState.hideRerequestButton = true;

    this._setStoreItemRequestApi(this.store._id, requestedItem, ()=> {
      this._callDeductQtyFromItemApi(requestedItem, () => {
        this._getAllRequestedList(this.store._id);
        this._getAllRecievedList(this.store._id);
      });
    });

  },

  _callDeductQtyFromItemApi (internalOrder, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      internalOrder: internalOrder
    };
    this.set('isLoading', true);
    this.callApi('/organization-store-reduce-item-qty', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },

  _callIncreaseItemQtyApi (internalOrder, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      internalOrder: internalOrder,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/organization-store-increase-item-qty', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },

  _getInventory(storeId) {
    if (storeId) {
      this._getInventoryApi(storeId, ()=> {
        null;
      });
    }
  },

  _getInventoryApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-inventory', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.mapStoreInventory(response.data);
        cbfn();
      }
    });
  },

  mapStoreInventory(list) {

    const mapInventory = list.map(item => { 
      return { label: item.data.name, value: item }
    });


    this.set('storeInventory', mapInventory);

    console.log(this.storeInventory);
  }, 


  _storeSelected (e) {
    this.selectedStoreItem = null;
    this.set('storeInventory', []);
    this.selectedStore = null;
    

    this.selectedStore = this.stores[this.selectedStoreId];
    this._resetInternalOrderObject();
  
    this._getInventory(this.selectedStore._id);




  },

  makeInternalItemObject(storeItem) {
    const item = storeItem;
    item.data.qty = 0;
    return item
  },

  _returnSerial(index) {
    return index + 1;
  },

  addInternalItem() {
    this._resetValidates();

    if (!this.selectedStoreItem) {
      
      return this._setValidationMessage('Select a store item!', 'danger');
    }

    if ( typeof this.selectedStoreItem == 'string') {
      return this._setValidationMessage('Sorry, this item is not available on store!', 'danger');
    }

    var item = this.makeInternalItemObject(this.selectedStoreItem);
    this.push('internalOrder.data', item);
    this.set('selectedStoreItem', null);

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

    if (this.internalOrder.serial == 'new') {
      this.internalOrder.serial = this.generateSerialForInternalInventoryItem();
      this.internalOrder.createdDatetimeStamp = lib.datetime.now();
    }
      

    this.internalOrder.recievedStore._id = this.selectedStore._id;
    this.internalOrder.recievedStore.name = this.selectedStore.data.name;
    this.internalOrder.lastModifiedDatetimeStamp = lib.datetime.now();

    console.log(this.internalOrder);

   this._setStoreItemRequestApi(this.store._id, this.internalOrder, ()=> {
      this._resetInternalOrderObject();
      this._getAllRequestedList(this.store._id);
      this._getAllRecievedList(this.store._id);
    });
    
  },

  _setStoreItemRequestApi(storeIdentifier, internalOrder, cbfn) {
    console.log(internalOrder);
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer,
      internalOrder: internalOrder
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store-item-request', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        console.log(response.data.message);
        cbfn();
      }
    });
  },

  _onTapRecievedButtonPressed(e) {
    index = e.model.index;
    internalOrder = this.requestedList[index];
    var statusObject = {
      type: 'recieved',
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: 'success',
      isDone: true
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

    this._setStoreItemRequestApi(this.store._id, internalOrder, ()=> {
      this._callIncreaseItemQtyApi(internalOrder, () => {
        this._getAllRequestedList(this.store._id);
        this._getAllRecievedList(this.store._id);
      });
    });
  },
  _onTapCancelButtonPressedFromRecievedItem (e) {
    index = e.model.index;
    internalOrder = this.recievedList[index];
    this._cancelledRequest(internalOrder);
  },
  _onTapCancelButtonPressed(e) {
    index = e.model.index;
    internalOrder = this.requestedList[index];
    this._cancelledRequest(internalOrder);
  },

  _cancelledRequest(internalOrder) {
    var statusObject = {
      type: 'canceled',
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: 'danger',
      isDone: true,
      storeId: this.store._id,
      storeName: this.store.data.name
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


    this._setStoreItemRequestApi(this.store._id, internalOrder, ()=> {
      this._resetInternalOrderObject();
      this._getAllRequestedList(this.store._id);
      this._getAllRecievedList(this.store._id);
    });
  },

  navigateToPage (path) {
    window.location = path;
  },

  navigatedIn () {
    // intialize selected store data
    this.selectedStoreId = 0;
    this.selectedStore = this.stores[this.selectedStoreId];

    console.log(this.store);
    
    if (this.store) {
      this._getAllRequestedList(this.store._id);
      this._getAllRecievedList(this.store._id);
    } 
  },
    

  _onTapPrintButtonPressed(e) {
    index = e.model.index;
    item = this.requestedList[index];
    localStorage.setItem("selectedStoreTransactionRecord", JSON.stringify(item));
    this.navigateToPage("#/store-inventory-transaction-preview/record:" + item.serial);
  },

  _onTapEditButtonPressed(e) {
    index = e.model.index;
    this.internalOrder = this.requestedList[index];
    this.set('ORDER_EDIT_MODE_ON', true);
    this.showRequestPharmacyItemDialog();
    
  },

  _addToStore(requestItem) {
    // todo - call set to store inventory api

  },

  activeItemChanged(product) {
    // console.log(product)
    if (this.inventory && this.inventory.length > 0) { // don't trigger on init
      this.$$('#inventory').selectedItems = product ? [product] : [];

      this.set('EDIT_MODE', true);
      this.set('requestDialogTitle', 'Edit Product');
      this.set('product', product);
      console.log('product', this.product);
    }
  },
 
  /*
    Get api key
  */
  getApiKey() {
    if (this.user) {
      return this.user.apiKey;
    } else {
      this._notifyInvalidUser();
    }
  },


  _resetValidates() {
    this.set('validates',  []);
  },

  _setValidationMessage (message, classType) {
    this.push('validates',  {
      message: message,
      classType: classType
    });
  },

  _validateInput(product) {
    if (!product.data.name || !product.data.categoryName ||  !product.data.buyingPrice || !product.data.sellingPrice || !product.data.qty) {
      this._setValidationMessage('Please Input Required Information!', 'danger');
      return false;
    }
    return true;
  },


  _deleteRequest(e) {
    console.log('product', this.product._id);
    this._callDeleteProductApi( this.product._id, ()=> {
      this.set('requestDialogTitle', 'New Request');
      this.set('EDIT_MODE', false);
      this._resetValidates();
      this._resetInternalOrderObject();
      // this._getInternalRequestList(this.store._id);
    });
    
  },

  _clearButtonPressed() {
    this.set('requestDialogTitle', 'New Request');
    this.set('EDIT_MODE', false);
    this._resetValidates();
    // this._resetInternalOrderObject();
  },

 

  _toggleProductEditor() {
    this.toggleProductEditor = !this.toggleProductEditor;
  },

  ready() {
    // this._resetInternalOrderObject();
  }

});