Polymer({

  is: 'page-commission-category-manager',

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

    commissionCategory: {
      type: Object,
      value() { return {}; }
    },

    commissionCategoryList: {
      type: Array,
      value() { return []; }
    },

    loadingCounter: {
      type: Number,
      value() { return 0; }
    }

  },


  navigatedIn() {
    this._loadUser();
    this._loadOrganization();
    this.makeNewCategory();
    this.getCategoryList();
  },


  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },


  _loadOrganization() {
    const organizationList = app.db.find('organization');
    if (organizationList.length === 1) {
      return this.set('organization', organizationList[0]);
    } else {
      return this.domHost.showModalDialog('Invalid Organization')
    }
  },

  getCategoryList() {
    this.loadingCounter++
    this.commissionCategoryList = app.db.find('commission-category-list', ({ organizationId }) => organizationId === this.organization.idOnServer)
    this.loadingCounter--
    console.log(this.commissionCategoryList);
  },

  makeNewCategory() {
    this.commissionCategory = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: null,
      organizationId: this.organization.idOnServer,
      createdByUserSerial: this.user.serial,
      serial: null,
      name: '',
    };
  },

  _addNewCategory() {
    if (!this.commissionCategory.name) {
      return this.domHost.showModalDialog('Please Add Name');
    }

    else {
      this.commissionCategory.lastModifiedDatetimeStamp = lib.datetime.now();
      if (!this.commissionCategory.serial) this.commissionCategory.serial = this.generateSerialForCommissionCategory();
      app.db.insert('commission-category-list', this.commissionCategory)
      console.log('Category', this.commissionCategory)
      this.makeNewCategory()
      this.getCategoryList()
      return this.$$('#dialogAddNewCategory').close();
    }

  },


  _deleteCategoryButtonClicked(e) {
    let { item, index } = e.model;
    this.domHost.showModalPrompt('Are you sure, you want to delete this Category?', (done) => {
      if (done) {
        this.splice('commissionCategoryList', index, 1);
        app.db.remove('commission-category-list', item._id);
        app.db.insert('commission-category-list--deleted', item)
        console.log('Category Deleted!');
      }
    })
  },

  addNewCategoryBtnPressed(e) {
    return this.$$('#dialogAddNewCategory').toggle();
  }



});