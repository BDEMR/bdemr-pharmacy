Polymer({
  is: 'page-store-vendor',

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
      value: null,
      observer: 'storeChanged'
    },
    vendor: {
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

    vendorDialogTitle: {
      type: String,
      value: 'Add Vendor'
    },

    EDIT_MODE: {
      type: Boolean,
      value: false
    },
    toggleVendorEditor: {
      type: Boolean,
      value: true
    }
  },

  activeItemChanged(vendor) {
    // console.log(vendor)
    if (this.vendors && this.vendors.length > 0) { // don't trigger on init
      this.$$('#vendors').selectedItems = vendor ? [vendor] : [];

      this.set('EDIT_MODE', true);
      this.set('vendorDialogTitle', 'Edit Vendor');
      this.set('vendor', vendor);
      console.log('vendor', this.vendor);
    }
  },

  storeChanged(store) {
    console.log('Vendors - Store Name: ', store.data.name);
    storeId = store._id;
    this._getVendors(storeId);
  },

  _getVendors(storeId) {
    if (storeId) {
      this._getVendorsApi(storeId, ()=> {
        this._resetVendor();
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
      this._notifyInvalidUser();
    }
  },

  _getVendorsApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-vendors', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.vendors = response.data;
        cbfn();
      }
    });
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

  _validateInput(vendor) {
    if (!vendor.data.name) {
      this._setValidationMessage('Please type atleast vendor name!', 'danger');
      return false;
    }
    return true;
  },

  _saveVendor() {
    this._resetValidates();
    if (!this._validateInput(this.vendor)) return;
    this.vendor.lastModifiedDatetimeStamp = lib.datetime.now();

    this._setVendorApi(this.store._id, this.vendor, ()=> {
      this._getVendors(this.store._id);
      this._resetVendor();
      this.set('EDIT_MODE', false);
      this.set('vendorDialogTitle', 'Add Vendor');
      // todo - no need to call _getVendors() for this. just unsift
    });
  },

  _setVendorApi(storeIdentifier, vendorObject, cbfn) {
    console.log(vendorObject);
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer,
      vendor: vendorObject
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store-vendor', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        console.log(response.data.message);
        cbfn();
      }
    });
  },

  _showOnVendorEditor (e){
    const index = e.model.index;
    const vendor = this.vendors[index];
    this.set('vendorDialogTitle', 'Edit Vendor');
    
    this._getVendorApi(this.store._id, vendor._id, (vendor)=> {
      this.set('vendor', vendor);
    });
  },

  _deleteVendor(e) {
    console.log('vendor', this.vendor._id);
    this._callDeleteVendorApi( this.vendor._id, ()=> {
      this.set('vendorDialogTitle', 'Add Vendor');
      this.set('EDIT_MODE', false);
      this._resetValidates();
      this._resetVendor();
      this._getVendors(this.store._id);
    });
    
  },

  _clearButtonPressed() {
    this.set('vendorDialogTitle', 'Add Vendor');
    this.set('EDIT_MODE', false);
    this._resetValidates();
    this._resetVendor()
  },

  _resetVendor() {

    const vendor = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      organizationId: this.organization.idOnServer,
      storeId: this.store._id,
      data: {
        name: "",
        phoneNumber: "",
        address: "",
        email: "",
        isActive: 'yes'
      }
    }
    return this.set('vendor', vendor);
  },

  _getVendor(vendor) {
    this._getVendorApi(this.store._id, vendor._id, ()=> {
      null;
    });
  },

  _getVendorApi(storeIdentifier, vendorIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      vendorId: vendorIdentifier,
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-vendor', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.vendor = response.data;
        cbfn(this.vendor);
      }
    });
  },

  _callDeleteVendorApi(vendorIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      vendorId: vendorIdentifier,
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/delete-organization-store-vendor', data, (err, response) => {
      console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },

  _toggleVendorEditor() {
    this.toggleVendorEditor = !this.toggleVendorEditor;
  },


  navigatedIn () {
    this.toggleVendorEditor = true;
    
    if (this.store) {
      storeId = this.store._id;
      this._getVendors(storeId);
    }
    
  },

});