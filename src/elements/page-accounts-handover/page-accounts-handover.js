Polymer({
  is: 'page-accounts-handover',

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
      value: null
    },
    organizationUserAutoCompleteSourceList: {
      type: Array,
      value: []
    },
    isLoading: {
      type: Boolean,
      value: false
    },
    selectedReciever: {
      type: Object,
      value: null
    },
    searchFieldMainInput: {
      type: String,
      notify: true,
      value: ''
    },
    requestedMessageList: {
      type: Array,
      value: [],
      notify: true
    },
    recievedMessageList: {
      type: Array,
      value: [],
      notify: true
    },
    selectedPage: {
      type: Number,
      value: 0
    },
  },


  navigatedIn() {
    const params = this.domHost.getPageParams()
    const organizationId = params['organization'];
    if (!organizationId) {
      return this.domHost.showModalDialog("Invalid Organization");
    }
    this._loadUser();
    this._loadOrganization(organizationId, () => {
      this._loadOrganizationsUserDetails(organizationId, _ => null)
      this._getHandOverData(_ => null);
    })
  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      this.set('user', userList[0]);
    }
  },

  _generateFlatUserInfo(userList) {
    return userList.map((user) => {
      return {
        name: this.$getFullName(user.name),
        phone: user.phoneNumberList.lenght ? user.phoneNumberList[0].phoneNumber : "",
        email: user.emailAddressList.length ? user.emailAddressList[0].emailAddress : "",
        idOnServer: user.userId
      }
    })
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

  _loadOrganizationsUserDetails(organizationIdentifier, cbfn) {
    let query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.loading = true;
    this.callApi('/bdemr--get-organization-user-details', query, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      let flatUserInfo = this._generateFlatUserInfo(response.data)
      this.set('organizationUserAutoCompleteSourceList', flatUserInfo);
      cbfn();
    })
  },

  arrowBackButtonPressed(e) {
    return this.domHost.navigateToPreviousPage();
  },

  showSendRequestDialog() {
    this._resetMessageShareObject();
    this.$$('#dialogRequestMessage').toggle();
  },

  _resetMessageShareObject() {
    let msgObj = {
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      createdDatetimeStamp: null,
      lastSyncedDatetimeStamp: 0,
      requestFrom: {
        userId: this.user.idOnServer,
        name: this.user.name,
        email: this.user.email,
        phone: this.user.phone
      },
      requestTo: null,
      requestStatus: '',
      message: "",
      logs: [],
    };
    this.set('msgObj', msgObj);
  },

  sendRequestBtnPressed() {
    if (this.msgObj.requestTo == null) {
      this.domHost.showToast('Select recipient name first!');
      return;
    }
    this.msgObj.createdDatetimeStamp = lib.datetime.now();
    this.msgObj.logs.push(this.addLog('request'));
    this.updateMessageShare(this.msgObj, () => {
      this.$$('#dialogRequestMessage').close();
    });
  },

  getButtonStatus(requestStatus) {
    switch (requestStatus) {
      case 'canceled':
        return true
        break;
      case 'accepted':
        return true
        break;
      default:
        return false;
        break;
    }
  },
  getButtonClass(requestStatus) {
    switch (requestStatus) {
      case 'canceled':
        return 'danger'
        break;
      case 'accepted':
        return 'success'
        break;
      default:
        return '';
        break;
    }
  },
  _onTapCancel(e) {
    let index = e.model.index;
    let msgObj = this.requestedMessageList[index];
    this.cancelRequest(msgObj);
  },
  _onTapCancelFromRecieved(e) {
    let index = e.model.index;
    let msgObj = this.recievedMessageList[index];
    this.cancelRequest(msgObj);
  },
  cancelRequest(msgObj) {
    msgObj.logs.push(this.addLog('canceled'));
    msgObj.requestStatus = 'canceled';
    this.updateMessageShare(msgObj, () => {
      null;
    });
  },
  _onTapAccept(e) {
    index = e.model.index;
    let msgObj = this.recievedMessageList[index];
    msgObj.logs.push(this.addLog('accepted'));
    msgObj.requestStatus = 'accepted';
    this.updateMessageShare(msgObj, () => {
      null;
    });
  },

  addLog(logType) {
    return {
      type: logType,
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
    }
  },

  updateMessageShare(data, cbfn) {
    data.lastModifiedDatetimeStamp = lib.datetime.now();
    this._sendHandoverRequest(data, (updatedData) => {
      this._getHandOverData(cbfn);
    });
  },
  _sendHandoverRequest(data, cbfn) {
    const query = {
      apiKey: this.user.apiKey,
      requestObj: data
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--organizatio-accounts-set-handover', query, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        cbfn();
      }
    });
  },
  _getHandOverData(cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--organizatio-accounts-get-handovers', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('requestedMessageList', response.data.requestedMessageList);
        this.set('recievedMessageList', response.data.recievedMessageList);
      }
      cbfn()
    });
  },

  userSelected(e) {
    const idOnServer = e.detail.value;
    if (!idOnServer) return;
    let user = this.organizationUserAutoCompleteSourceList.find(user => user.idOnServer === idOnServer);
    this.msgObj.requestTo = user;
  },


});