Polymer({
  is: 'page-store-inventory',

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
    }
  },

  activeItemChanged(product) {
    // console.log(product)
    if (this.inventory && this.inventory.length > 0) { // don't trigger on init
      this.$$('#inventory').selectedItems = product ? [product] : [];

      this.set('EDIT_MODE', true);
      this.set('productDialogTitle', 'Edit Product');
      this.set('product', product);
      console.log('product', this.product);
    }
  },

  storeChanged(store) {
    console.log('Inventory - Store Name: ', store.data.name);
    storeId = store._id;
    this._getInventory(storeId);
    this.productDialogTitle = 'Add New Product';
  },

  _getInventory(storeId) {
    if (storeId) {
      this._getInventoryApi(storeId, ()=> {
        this._resetProduct();
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
        this.inventory = response.data;
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

  _pushNewBatchObject() {
    // Setting Expiry Date to One Year From Now
    const d = new Date();
    d.setFullYear(d.getFullYear() + 2);

    this.push('product.data.list', {
      batch: '',
      buyingPrice: null,
      sellingPrice: null,
      qty: 0,
      vendorId: 0,
      vendorName: null,
      createdOn: lib.datetime.mkDate(),
      expiredOn: lib.datetime.mkDate(d),
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      lastUpdatedByUserId: this.user.idOnServer
    })
  },

  _removeSelectedBatch(e) {
    index = e.model.index;
    this.splice('product.data.list', index, 1);
  },

  _validateInput(product) {
    if (!product.data.name || !product.data.category ) {
      this._setValidationMessage('Please Input Required Information!', 'danger');
      return false;
    }

    if (product.data.list.length === 0 ) {
      this._setValidationMessage('atleast one batch required!', 'danger');
      return false;
    }
    return true;
  },

  _saveProduct() {
    this._resetValidates();
    if (!this._validateInput(this.product)) return;
    this.product.lastModifiedDatetimeStamp = lib.datetime.now();

    this._setProductApi(this.store._id, this.product, ()=> {
      this._getInventory(this.store._id);
      this._resetProduct();
      this.set('EDIT_MODE', false);
      this.set('productDialogTitle', 'Add Product');
      // todo - no need to call _getInventory() for this. just unsift
    });
  },

  _setProductApi(storeIdentifier, productObject, cbfn) {
    console.log(productObject);
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer,
      product: productObject
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store-product', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        console.log(response.data.message);
        cbfn();
      }
    });
  },

  _showOnProductEditor (e){
    const index = e.model.index;
    const product = this.inventory[index];
    this.set('productDialogTitle', 'Edit Product');
    
    this._getProductApi(this.store._id, product._id, (product)=> {
      this.set('product', product);
    });
  },

  _deleteProduct(e) {
    console.log('product', this.product._id);
    this._callDeleteProductApi( this.product._id, ()=> {
      this.set('productDialogTitle', 'Add Product');
      this.set('EDIT_MODE', false);
      this._resetValidates();
      this._resetProduct();
      this._getInventory(this.store._id);
    });
    
  },

  _clearButtonPressed() {
    this.set('productDialogTitle', 'Add Product');
    this.set('EDIT_MODE', false);
    this._resetValidates();
    this._resetProduct()
  },

  _resetProduct() {

    const product = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      organizationId: this.organization.idOnServer,
      storeId: this.store._id,
      createdByUserId: this.user.idOnServer,
      data: {
        name: "",
        category: "",
        list: []
        
      }
    }
    return this.set('product', product);
  },

  _getProduct(product) {
    this._getProductApi(this.store._id, product._id, ()=> {
      null;
    });
  },

  _getProductApi(storeIdentifier, productIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      productId: productIdentifier,
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-product', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.product = response.data;
        cbfn(this.product);
      }
    });
  },

  _callDeleteProductApi(productIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      productId: productIdentifier,
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/delete-organization-store-product', data, (err, response) => {
      console.log(response);
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },

  _toggleProductEditor() {
    this.toggleProductEditor = !this.toggleProductEditor;
  },


  navigatedIn () {
    this.toggleProductEditor = false;
    
    if (this.store) {
      storeId = this.store._id;
      this._getInventory(storeId);
    }
    
  },

});