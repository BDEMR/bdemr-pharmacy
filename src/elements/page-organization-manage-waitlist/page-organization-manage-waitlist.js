Polymer({
  is: 'page-organization-manage-waitlist',
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

    waitLists: {
      type: Array,
      value: []
    },

    publicWaitList: {
      type: Array,
      value: []
    }

  },

  navigatedIn() {
    const params = this.domHost.getPageParams()
    const organizationId = params['organization'];
    this._loadUser();
    if (organizationId) {
      this._loadOrganization(organizationId, () => {
        this._loadWaitLists(organizationId, () => {
          this._loadAllPublicWaitList()
        });
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

  _loadWaitLists(organizationId, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId
    };
    this.loading = true;
    this.callApi('/bdemr-organization-get-all-waitlist', data, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      this.set('waitLists', response.data);
      if (cbfn) cbfn();
    });
  },

  _loadAllPublicWaitList() {
    const data = {
      apiKey: this.user.apiKey
    };
    this.loading = true;
    this.callApi('/bdemr-organization-get-all--public-waitlist', data, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      let publicWaitList = [];
      publicWaitList = response.data;
      publicWaitList = publicWaitList.filter(item => item.organizationId != this.organization.idOnServer)
      this.set('publicWaitList', publicWaitList);
      console.log('All Public Waitlists', publicWaitList);
      // allWaitList = publicWaitList.concat(this.waitLists);
      // this.set('waitLists', allWaitList);
      // console.log('All Waitlists', allWaitList);
    });
  },


  _checkIfAlreadyExists(value) {
    if (this.waitLists.some(item => item.name.toLowerCase() === value.toLowerCase())) {
      return true;
    }
    return false;
  },

  _makeNewWaitList(value) {
    if (this._checkIfAlreadyExists(value)) {
      return this.domHost.showModalDialog("Similar Waitlist already Exists");
    }
    let newWaitList = {
      createdDatetimeStamp: Date.now(),
      lastModifiedDatetimeStamp: Date.now(),
      organizationId: this.organization.idOnServer,
      createdByUserId: this.user.idOnServer,
      waitlistPrivacyPublic: false,
      name: value,
      patientList: []
    }

    let data = {
      apiKey: this.user.apiKey,
      waitList: newWaitList
    }
    this.loading = true;
    this.callApi('/bdemr-organization-create-waitlist', data, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      let createdWaitList = response.data;
      this.push('waitLists', createdWaitList);
      this.domHost.showSuccessToast('WaitList Created');
      this.$.waitListInput.value = ''
    })
  },

  makeWaitlistPublic(e) {
    let { item } = e.model;
    let data = {
      apiKey: this.user.apiKey,
    }
    console.log(item);
    if (item.waitlistPrivacyPublic === false) {
      item.waitlistPrivacyPublic = true;
      data.waitList = item
      this.callApi('/bdemr-organization-create-waitlist', data, (err, response) => {
        if (err) return this.domHost.showModalDialog(err.message);
        else this.domHost.showSuccessToast('WaitList Updated to Public');
        return
      })
    }
    else {
      item.waitlistPrivacyPublic = false;
      data.waitList = item;
      this.callApi('/bdemr-organization-create-waitlist', data, (err, response) => {
        if (err) return this.domHost.showModalDialog(err.message);
        else this.domHost.showSuccessToast('WaitList Updated to Private');
        return
      })
    }
  },

  addWaitListButtonClicked() {
    let value = this.$.waitListInput.value;
    if (value !== null && value.trim() !== "") {
      this._makeNewWaitList(value)
    }
  },

  newWaitListAdded(e) {
    if (e.which === 13) {
      let value = e.target.value;
      if (value) {
        this._makeNewWaitList(value)
      }
    }
  },

  viewWaitListButtonPressed(e) {
    let { item } = e.model;
    this.domHost.navigateToPage(`#/view-single-waitlist/organization:${this.organization.idOnServer}/waitlist:${item._id}`);
  },

  _deleteWaitList(id, cbfn) {
    let data = {
      apiKey: this.user.apiKey,
      id
    }
    this.loading = true;
    this.callApi('/bdemr-organization-delete-waitlist', data, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (response.data) cbfn();
    })
  },

  deleteWaitListClicked(e) {
    let { item, index } = e.model;
    this.domHost.showModalPrompt('Are you sure', (yes) => {
      if (yes) {
        this._deleteWaitList(item._id, () => {
          this.splice('waitLists', index, 1);
        })
      }
    })
  }
})
