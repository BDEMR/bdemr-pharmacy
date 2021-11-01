Polymer({
  is: 'page-store-staff',

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
    members: {
      type: Array,
      value: [],
    },
    member: {
      type: Object,
      value: {}
    }
  },

  storeChanged(store) {
    storeId = store._id;
    this._getMembers(storeId);
  },

  _getMembers(storeId) {
    if (storeId) {
      this._getMembersApi(storeId, ()=> {
        this._resetMemberObject();
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

  _resetMemberObject() {

    const member = {
      createdDatetimeStamp: lib.datetime.now(),
      lastModifiedDatetimeStamp: lib.datetime.now(),
      organizationId: this.organization.idOnServer,
      storeId: this.store._id,
      createdByUserId: this.user.idOnServer,
      member: {
        id: null,
        name: null,
        phone: null,
        email: null,
        roleId: null
      }
    }
    return this.set('member', member);
  },

  _getMembersApi(storeIdentifier, cbfn) {
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer
    };
    this.set('isLoading', true);
    this.callApi('/get-organization-store-members', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.inventory = response.data;
        cbfn();
      }
    });
  },
  
  _saveMember() {
    this._resetValidates();
    if (!this._validateInput(this.member)) return;
    this.member.lastModifiedDatetimeStamp = lib.datetime.now();

    this._setMemberApi(this.store._id, this.member, ()=> {
      this._getInventory(this.store._id);
      this._resetMember();
      this.set('EDIT_MODE', false);
      this.set('memberDialogTitle', 'Add Member');
      // todo - no need to call _getInventory() for this. just unsift
    });
  },

  _setMemberApi(storeIdentifier, memberObject, cbfn) {
    console.log(memberObject);
    const data = {
      apiKey: this.getApiKey(),
      storeId: storeIdentifier,
      organizationId: this.organization.idOnServer,
      member: memberObject
    };
    this.set('isLoading', true);
    this.callApi('/set-organization-store-member', data, (err, response) => {
      this.set('isLoading', false);
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        console.log(response.data.message);
        cbfn();
      }
    });
  },

  ready() {
    // console.log(this.store.data.name);
  }
});