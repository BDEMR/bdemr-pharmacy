Polymer({
  is: 'page-store-audit-editor',

  behaviors: [
  app.behaviors.dbUsing,
  app.behaviors.apiCalling,
  app.behaviors.translating,
  app.behaviors.commonComputes
  ],

  properties: {
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
      value: null
    },
    inventory: {
      type: Array,
      value: []
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

    productDialogTitle: {
      type: String,
      value: null
    },

    EDIT_MODE: {
      type: Boolean,
      value: false
    },
    toggleProductEditor: {
      type: Boolean,
      value: false
    },
    flaggedItems: {
      type: Array,
      value: []
    },
    flagedCounter: {
      type: Number,
      value: 0
    },
    audit: {
      type: Object,
      value: {}
    },
    isAuditValid: {
      type: Boolean,
      value: false
    }
  },

  activeItemChanged(product) {
    // console.log(product)
    if (this.inventory && this.inventory.length > 0) { // don't trigger on init
      this.$$('#inventory').selectedItems = product ? [product] : [];

      // this.set('EDIT_MODE', true);
      // this.set('productDialogTitle', 'Edit Product');
      // this.set('product', product);
      // console.log('product', this.product);
    }
  },

  arrowBackButtonPressed() {
    this.domHost.navigateToPreviousPage();
  },
    
  _getInventory(storeId) {
    console.log(storeId);
    if (storeId) {
      this._getInventoryApi(storeId, ()=> {
        null;
      }); 
    }
  },
  /*
    Get api key
  */
  getApiKey() {
    if (this.user) {
      return this.user.apiKey;
    } else {
      // this._notifyInvalidUser();
    }
  },

  _getProductInStockCount (data) {
    console.log(data);
    let list = []
    let count = 0;

    if (data && data.list) {
      list = data.list;
      list.forEach((elem) => {
        let qty = parseInt(elem.qty, 10);
        count += qty;
      });
    }
    return count;
  },

  _makeInventoryAuditable (inventory) {
    console.log(inventory);
    return inventory;
  },

  _getInventoryApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-inventory-for-audit', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        let inventory = response.data;
        this.inventory = this._makeInventoryAuditable(response.data);
        cbfn();
      }
    });
  },

  _getStore(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store', data, (err, response) => {
      console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.store = response.data;
        this._getInventory(this.store._id);
        cbfn()
      }
    })
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

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },

  _onPhysicallyFoundValueChanged(e) {
    let index = e.model.index;
    item = this.inventory[index];
    console.log(item);
    let physicallyFound = parseInt(item.physicallyFound);
    console.log(physicallyFound);
    if (item.inStock != physicallyFound) {
      console.log('here');
      this.set('inventory.#{index}.class', 'type danger');
      this.inventory[index].class= 'type danger';
    } else {
      this.set('inventory.#{index}.class', '');
    }
  },

  _computeClass (physicallyFound, inStock) {
    if (inStock != parseInt(physicallyFound)) {
      return 'type danger';
    } else {
      return '';
    }
  },

  _calcMissingAmount(physicallyFound, inStock) {
    return inStock - parseInt(physicallyFound);
  },

  filterByFlaggedItems () {
    var flaggedItems = [];
    var list = this.inventory;
    list.forEach((item) => {
      if(item.isFlagged) {
        flaggedItems.push(item);
      }
    });
    return flaggedItems;
  },
  
  _getAudit(auditId) {
    this._getAuditApi(this.store._id, auditId, ()=> {
      null;
    });
  },

  _getAuditApi(storeIdentifier, auditIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      auditId: auditIdentifier,
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-audit', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.audit = response.data;
        this.set('isAuditValid', true);
        cbfn(this.audit);
      }
    });
  },

  _callSetStoreAuditApi(cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: this.store._id,
      organizationId: this.organization.idOnServer,
      audit: this.audit
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store-audit', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        let auditIdentifier =  response.data.auditIdentifier
        cbfn(auditIdentifier);
      }
    });
  },

  _saveAudit () {
    this.audit.endAuditDatetimeStamp = lib.datetime.now();
    this.audit.data = this.filterByFlaggedItems();

    this._callSetStoreAuditApi((auditIdentifier)=> {
      this.domHost.navigateToPage("#/store-audit-preview/id:" + auditIdentifier);
    });
  },

  _onToggleFlagButton (e) {
    let checked = e.target.checked;

    if (checked) {
      this.flagedCounter++;
    } else {
      this.flagedCounter--;
    }
  
  },

  _resetAuditObject() {
    this.audit = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      organizationId: this.organization.idOnServer,
      storeId: this.store._id,
      createdByUserId: this.user.idOnServer,
      createdByUserName: this.user.name,
      endAuditDatetimeStamp: null,
      data: [],
      notes: '',
      isLocked: false,
      storeName: this.store.data.name 
    }
    this.set('isAuditValid', true);
  },

  _notifyInvalidAudit () {
    this.isAuditValid = false
    this.domHost.showModalDialog ('Invalid Audit!');
  },


  ready () {

    this._loadUser();
  
    var params = this.domHost.getPageParams();

    this.organization = this.getCurrentOrganization();

    this._loadOrganization(this.getCurrentOrganization().idOnServer, () => {
      if (params['storeId']) {
        this._getStore(params['storeId'], () => {
          if (params['id']) {

            if (params['id'] == 'new') {
              this._resetAuditObject();
            } else {
              this._getAudit(params['id'], () => {
                null;
              });
            }

          } else {
            this._notifyInvalidAudit();
          }
          
        });
      }

      
    });

    
    
  }

});