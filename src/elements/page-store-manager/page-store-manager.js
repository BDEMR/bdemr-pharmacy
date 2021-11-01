Polymer({
  is: 'page-store-manager',

  behaviors: [
    app.behaviors.dbUsing,
    app.behaviors.apiCalling,
    app.behaviors.translating,
    app.behaviors.commonComputes,
    app.behaviors.pageLike
  ],

  properties: {
    EDIT_MODE: {
      type: Boolean,
      value: false
    },
    selectedStore: {
      type: Number,
      value: 0,
      observer: 'selectedStoreChanged'
    },

    selectedPage: {
      type: Number,
      value: 1,
      observer: 'selectedPageChanged'
    },
    
    user: {
      type: Object,
      value: {},
      notify: true
    },

    organization: {
      type: Object,
      value: {},
      notify: true
    },

    stores: {
      type: Array,
      value: [],
      notify: true,
      reflectToAttribute: true
    },

    editStore: {
      type: Array,
      value: []
    },

    pages: {
      type: Array,
      value: [
        // {
        //   name: 'Manage',
        //   icon: 'home'
        // },
        {
          name: 'Inventory',
          icon: 'home'
        },
        {
          name: 'Internal Transaction',
          icon: 'home'
        },
        {
          name: 'Vendor',
          icon: 'home'
        },
        {
          name: 'Audit',
          icon: 'home'
        }
      ]
    },
      
    isLoading: {
      type: Boolean,
      value: false
    },
    
    storeTitle: {
      type: String,
      value: null,
      observer: 'storeTitleChanged'
    },
    audits: {
      type: Array,
      value: []
    }
  },

  /*
    return human readable date format from ms
  */
  _formatDate(dateTime) {
    return lib.datetime.format(dateTime, 'mmm d, yyyy');
  },

  // _storesObserve(stores) {
  //   storeNames = stores.map(item => item.data.name);
  // },

  ironPagesSelectedEvent (e) {
    const nodeName = e.detail.item.nodeName;
    // console.log(nodeName);
    if (e.detail.item.navigatedIn) {
      e.detail.item.navigatedIn();
      return;
    }
  },



  navigatedIn() {
    /*
      required initialization after page loads
    */
    this._loadUser(); // load user data

    /*
      First, if current organization id matches with what found in server only/if load/get organization data
    */
    this._loadOrganization(this.getCurrentOrganization().idOnServer, () => {
      this._loadData();
    });
  },

  _loadData() {
    this._getStores(this.organization.idOnServer);
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

  _validateInput(inventory) {
    if (!inventory.data.name || !inventory.data.categoryName ||  !inventory.data.buyingPrice || !inventory.data.sellingPrice || !inventory.data.qty) {
      this.domHost.showToast('Please Input Required Information!');
      return false;
    }
    return true;
  },

  _notifyInvalidOrganization() {
    return this.domHost.showModalDialog('No/Invalid Organization!');
  },

  _notifyInvalidUser() {
    return this.domHost.showModalDialog('No/Invalid User!');
  },

  _notifyInvalidAccess() {
    return this.domHost.showModalPrompt('You Do Not Have Access To This Page!', () => {
      return this.domHost.navigateToPreviousPage();
    });
  },

  arrowBackButtonPressed(e) {
    return this.domHost.navigateToPreviousPage();
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

  /*
    Show Add store dialog
  */
  _showAddStoreDialog() {
    this._resetStore(); // reseted store object.
    this._changeDialogViewMode('add');
  },

  _changeStoreTitle (title) {
    this.set('storeTitle', title);
  },

  _changeDialogViewMode(mode) {
    if (mode == 'add') {
      this.set('EDIT_MODE', false);
      this._changeStoreTitle('Add Store');
    } else {
      this.set('EDIT_MODE', true);
      this._changeStoreTitle('Edit Store');
    }
    this.$$('#editStoreDialog').toggle();
  },

  _showEditStoreDialog() {
    this.set('editStore', this.store);
    this._changeDialogViewMode('edit');
  },

  /*
    Reset Store Object
  */

  _resetStore() {
    this.set('editStore', {
      createdByUserId: this.user.idOnServer,
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      organizationId: this.organization.idOnServer,
      data: {
        name: '',
        type: '',
        location: ''
      }
    });
  },

  selectedStoreChanged (index) {
    // console.log(this.stores);
    if (this.stores) {
      if (this.stores.length > 0) {
        this._getStore(index);
      }
    }
  },

  selectedPageChanged (index) {
    // console.log(index);
  },

  storeTitleChanged (newTitle) {
    // console.log(newTitle);
    return newTitle;
  },
 
  /*
    Get all stores if organization have any
  */
  _getStore(index) {
    store = this.stores[index];
    storeIdentifier = store._id;
    if (storeIdentifier) {
      this._getStoreApi(storeIdentifier);
      this._getAudits(storeIdentifier);
    }
  },

  _getStoreApi(storeIdentifier) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store', data, (err, response) => {
      // console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.store = response.data;
        // console.log(this.store);
      }
    })
  },
 
  _getStores() {
    const params = this.domHost.getPageParams();
    this._getStoresApi(this.organization.idOnServer, () => {
      if (this.stores) {
        if (this.stores.length > 0) {
          if (params['selected']) {
            this._getStore(params['selected']);
          } else {
            this._getStore(0);
          }
          
        }
      }
      
    });
  },

  _getStoresApi(organizationIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      organizationId: organizationIdentifier
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-stores', data, (err, response) => {
      // console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.stores = response.data;
        cbfn();
      }
    })
  },

  /*
    Add/Modify store
  */
 _validateInput(store) {
    if (!store.data.name ) {
      this.domHost.showToast('Please Input Required Information!');
      return false;
    }
    return true;
  },
 
  _editStore() {
    if (!this._validateInput(this.editStore)) return;
    this.editStore.lastModifiedDatetimeStamp = lib.datetime.now();
    this._setStoreApi(this.organization.idOnServer, this.editStore, () => {
      this._getStores();
      this.$$('#editStoreDialog').close();
    });
  },

  _setStoreApi(organizationIdentifier, storeData, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      organizationId: organizationIdentifier,
      store: storeData
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store', data, (err, response) => {
      // console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.domHost.showToast(response.data.message);
        cbfn();
      }
    })
  },

  /*
    Delete a store
  */

  _deleteStorePressed() {
    this.domHost.showModalPrompt( 'Are you sure?', (answer)=> {
      if (answer == true) {
        this._deleteStoreApi(this.organization.idOnServer, this.store._id);
      }
    });
      
  },
 
  _deleteStoreApi(organizationIdentifier, storeIdentifier) {
    const data = {
      apiKey: this.getApiKey(),
      organizationId: organizationIdentifier,
      storeId: storeIdentifier
    };
    console.log(data)
    this.set('isLoading', true);
    this.callApi('/delete-organization-store', data, (err, response) => {
      this.set('isLoading', false);

      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.domHost.showToast("Store Deleted!");
        this._getStores(this.organization.idOnServer);
      }
    })
  },

  /* Store audit - start */
  _addNewAudit () {
    this.domHost.navigateToPage("#/store-audit-editor/storeId:" + this.store._id + "/id:new");
  },

  _editAuditReport (e) {
    let index = e.model.index;
    let audit = this.audits[index];
    this.domHost.navigateToPage("#/store-audit-editor/storeId:" + this.store._id + "/id:" + audit._id);
  },

  _previewAuditReport (e) {
    let index = e.model.index;
    let audit = this.audits[index];
    this.domHost.navigateToPage("#/store-audit-preview/id:" + audit._id);
  },


  _getAudits(storeId) {
    this._getAuditsApi(storeId, ()=> {
      null;
    });
  },

  _getAuditsApi(storeId, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeId,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-audits', data, (err, response) => {
      console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.audits = response.data;
      }
    });
  },

  // timer(duration, display) {
  //   var timer = duration, hours, minutes, seconds;
  //   that = this;
  //   setInterval(function () {
  //     hours = parseInt((timer /3600)%24, 10)
  //     minutes = parseInt((timer / 60)%60, 10)
  //     seconds = parseInt(timer % 60, 10);

  //     hours = hours < 10 ? "0" + hours : hours;
  //     minutes = minutes < 10 ? "0" + minutes : minutes;
  //     seconds = seconds < 10 ? "0" + seconds : seconds;

  //     console.log(display);

  //     that.$$("#" + display).innerHtml = hours +":"+minutes + ":" + seconds;

  //     --timer;
  //   }, 1000);
  // },

  // _generateTempAuditId (index) {
  //   return ('audit' + index);
  // },

  // _calcAuditLockTime (auditEndMs, index) {
  //   let auditId = this._generateTempAuditId(index); 
  //   var currentMs = (new Date()).getTime();
  //   let remainingMs = (currentMs - auditEndMs);
  //   this.timer(remainingMs, auditId);
  // }, 
    
  /* Store audit - end */
  
});