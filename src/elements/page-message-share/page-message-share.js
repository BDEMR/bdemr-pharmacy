Polymer({
  is: 'page-message-share',

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
    receivedMessageList: {
      type: Array,
      value: [],
      notify: true
    },
    selectedPage: {
      type: Number,
      value: 0
    },
    requestedToUserList: {
      type: Array,
      value: []
    },
    receivedFromUserList: {
      type: Array,
      value: []
    }

  },
  _formatDate(dateTime) {
    return lib.datetime.format(dateTime, 'mmm d, yyyy');
  },
  _returnSerial(index) {
    return index + 1;
  },

  navigatedIn() {
    this._loadUser();
    this._loadOrganization(() => {
      this._loadData(()=>{
        this._loadRequestedReceivedUsers();
      });
    });
  },

  _loadData(cbfn) {
    this._callGetMessageShareApi(cbfn);
    // if (window.navigator.onLine) {
    //   this._callGetMessageShareApi();
    // } else {
    //   this.loadreceivedMessageList(this.user.idOnServer);
    //   this.loadRequestMessageList(this.user.idOnServer);
    // }
  },


  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    }
  },

  _loadOrganization(cbfn) {
    this.organization = this.getCurrentOrganization()
    if (this.organization === null) {
      this.domHost.navigateToPage("#/select-organization");
    }
    cbfn();
    return
  },

  _loadRequestedReceivedUsers() {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-shared-message-user-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('requestedToUserList', response.data.requestedToUserList);
        this.set('receivedFromUserList', response.data.receivedFromUserList);
        return;
      }
    });
  },

  arrowBack(e) {
    return this.domHost.navigateToPreviousPage();
  },

  requestedFilterByDateClicked(e){
    startDate = new Date(e.detail.startDate);
    startDate.setHours(0,0,0,0);
    endDate = new Date(e.detail.endDate);
    endDate.setHours(23,59,59,999);
    this.set('requestedDateCreatedFrom', (startDate.getTime()));
    this.set('requestedDateCreatedTo', (endDate.getTime()));
  },

  requestedFilterByDateClearButtonClicked(){
    this.requestedDateCreatedFrom = 0;
    this.requestedDateCreatedTo = 0;
  },

  requestedToUserSelected(e){
    if(!e.detail.value){
      this.selectedRequestedToUser = null
      return
    }
    this.selectedRequestedToUser = e.detail.value
    console.log('requested to user', this.selectedRequestedToUser);
  },

  requestedSearchButtonClicked(e){

    selectedUserId = null
    if(this.selectedRequestedToUser){
      selectedUserId = this.selectedRequestedToUser.idOnServer;
    }

    searchKeywordList = null
    if(this.filterByRequestedToSubject){
      searchKeywordList = this.filterByRequestedToSubject.trim().split(' ').map((keyword)=>{
        return keyword.trim();
      })
    }
    console.log('search keywords', searchKeywordList);

    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters:{
        messageType: 'requested',
        dateCreatedFrom: this.requestedDateCreatedFrom,
        dateCreatedTo: this.requestedDateCreatedTo,
        requestedToUser: selectedUserId,
        searchKeywordList
        // showOnlyPending: true
      }
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-filtered-shared-message-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('requestedMessageList', response.data);
        console.log('filtered requested msg', this.requestedMessageList);
        return;
      }
    });
  },

  requestedResetClearFields(){
    this.selectedRequestedToUser = null;
    this.filterByRequestedToSubject = ''
    this.filterByRequestedToUser = ''
    this.requestedFilterByDateClearButtonClicked();
    
  },
  requestedResetButtonClicked(e){
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters:{
        messageType: 'requested',
        showOnlyPending: true
      }
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-filtered-shared-message-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      this.requestedResetClearFields();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('requestedMessageList', response.data);
        console.log('filtered requested msg', this.requestedMessageList);
        return;
      }
    });
  },

  receivedFilterByDateClicked(e){
    startDate = new Date(e.detail.startDate);
    startDate.setHours(0,0,0,0);
    endDate = new Date(e.detail.endDate);
    endDate.setHours(23,59,59,999);
    this.set('receivedDateCreatedFrom', (startDate.getTime()));
    this.set('receivedDateCreatedTo', (endDate.getTime()));
  },

  receivedFilterByDateClearButtonClicked(){
    this.receivedDateCreatedFrom = 0;
    this.receivedDateCreatedTo = 0;
  },

  receivedFromUserSelected(e){
    if(!e.detail.value){
      this.selectedReceivedFromUser = null
      return
    }
    this.selectedReceivedFromUser = e.detail.value
    console.log('received from user', this.selectedReceivedFromUser);
  },

  receivedSearchButtonClicked(e){
    selectedUserId = null
    if(this.selectedReceivedFromUser){
      selectedUserId = this.selectedReceivedFromUser.userId;
    }
    searchKeywordList = null
    if(this.filterByReceivedFromSubject){
      searchKeywordList = this.filterByReceivedFromSubject.trim().split(' ').map((keyword)=>{
        return keyword.trim();
      })
    }
    console.log('search keywords', searchKeywordList);

    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters:{
        messageType: 'received',
        dateCreatedFrom: this.receivedDateCreatedFrom,
        dateCreatedTo: this.receivedDateCreatedTo,
        receivedFromUser: selectedUserId,
        searchKeywordList
      }
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-filtered-shared-message-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('receivedMessageList', response.data);
        console.log('filtered received msg', this.receivedMessageList);
        return;
      }
    });
  },

  receivedResetClearFields(){
    this.selectedReceivedFromUser = null;
    this.filterByReceivedFromSubject = ''
    this.filterByReceivedFromUser = ''
    this.receivedFilterByDateClearButtonClicked();
  },

  receivedResetButtonClicked(e){
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      searchParameters:{
        messageType: 'received',
        showOnlyPending: true
      }
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-filtered-shared-message-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      this.receivedResetClearFields();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('receivedMessageList', response.data);
        console.log('filtered received msg', this.receivedMessageList);
        return;
      }
    });
  },

  showSendRequestDialog() {
    this._resetMessageShareObject();
    this.showRequestMessageDialog();
  },

  showRequestMessageDialog() {
    this.$$('#dialogRequestMessage').toggle();
  },

  loadRequestMessageList(userIdentifier) {
    list = app.db.find('organization-message-share', ({ requestFrom }) => requestFrom.userId === userIdentifier);
    this.set('requestedMessageList', list);
  },

  loadreceivedMessageList(userIdentifier) {
    list = app.db.find('organization-message-share', ({ requestTo }) => requestTo.idOnServer === userIdentifier);
    this.set('receivedMessageList', list)
  },

  _resetMessageShareObject() {
    var msgObj = {
      serial: null,
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      availableOnline: false,
      requestFrom: {
        userId: this.user.idOnServer,
        name: this.user.name,
        email: this.user.email,
        phone: this.user.phone
      },
      requestTo: {},
      organizationId: this.organization.idOnServer,
      createdDatetimeStamp: null,
      lastSyncedDatetimeStamp: 0,
      clientCollectionName: 'organization-message-share',
      isSelected: false,
      data: null,
      dataSubject: null,
      logs: [],
      buttonState: {
        hideRecievedButton: true,
        hideAcceptButton: false,
        hideDeliveredButton: true,
        hideCancelButton: false,
        hideRerequestButton: true,
        hideEditButton: true,
        hidePrintButton: true,
      }

    };
    this.set('msgObj', msgObj);
  },

  sendRequestBtnPressed() {
    console.log(this.msgObj);
    if (this.msgObj.requestTo == null) {
      this.domHost.showToast('Select recipient name first!');
      return;
    }
    if (this.msgObj.serial == null)
      this.msgObj.serial = this.generateSerialForMessageShare();
    this.msgObj.createdDatetimeStamp = lib.datetime.now();

    this.msgObj.logs.push(this.addLog('request'));
    this.updateMessageShare(this.msgObj, () => {
      this.$$('#dialogRequestMessage').close();
    });
  },
  _onTapCancel(e) {
    index = e.model.index;
    msgObj = this.requestedMessageList[index];
    this.cancelRequest(msgObj);
  },
  _onTapCancelFromRecieved(e) {
    index = e.model.index;
    msgObj = this.receivedMessageList[index];
    this.cancelRequest(msgObj);
  },
  cancelRequest(msgObj) {
    msgObj.logs.push(this.addLog('canceled', 'danger'));
    msgObj.buttonState = this.updateButtonState(msgObj.buttonState, 'canceled');
    this.updateMessageShare(msgObj, () => {
      null;
    });
  },
  _onTapAccept(e) {
    index = e.model.index;
    msgObj = this.receivedMessageList[index];

    msgObj.logs.push(this.addLog('accepted', 'success'));
    msgObj.buttonState = this.updateButtonState(msgObj.buttonState, 'accepted');
    this.updateMessageShare(msgObj, () => {
      null;
    });
  },

  addLog(logType, classType) {
    return {
      type: logType,
      createdDatetimeStamp: lib.datetime.now(),
      by: this.user.idOnServer,
      name: this.user.name,
      class: classType,
      isDone: true
    }
  },
  updateButtonState(buttonState, stateType) {
    switch (stateType) {
      case 'accepted':
        buttonState.hideAcceptButton = true;
        buttonState.hideCancelButton = true;
        break;
      case 'canceled':
        buttonState.hideCancelButton = true;
        buttonState.hideAcceptButton = true;
        break;
    }
    return buttonState
  },
  saveMessageDataLocally(data, cbfn) {
    app.db.upsert('organization-message-share', data, ({ serial }) => serial === data.serial);
    return cbfn();
  },
  updateMessageShare(data, cbfn) {
    data.lastModifiedDatetimeStamp = lib.datetime.now();
    // if (window.navigator.onLine) {
    //   this._callSetMessageShareApi(data, (updatedData) => {  
    //     this._callGetMessageShareApi();
    //   });
    // }
    // this.saveMessageDataLocally(data, () => {
    //   this.loadreceivedMessageList(this.user.idOnServer);
    //   this.loadRequestMessageList(this.user.idOnServer);
    // });

    this._callSetMessageShareApi(data, (updatedData) => {
      this._callGetMessageShareApi();
    });

    return cbfn();
  },
  _callSetMessageShareApi(newData, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      newData: newData,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--set-shared-message', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        cbfn(response.data);
      }
    });
  },
  _callGetMessageShareApi(cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-shared-message-list', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('requestedMessageList', response.data.requestedMessageList);
        this.set('receivedMessageList', response.data.receivedMessageList);
        if(cbfn){
          cbfn();
        }
        return;
      }
    });
  },
  // Search for user - start
  _searchUser: function (id, searchQuery) {
    if (!searchQuery) {
      return;
    }
    return this.callApi('/bdemr-user-search-for-notification', {
      searchString: searchQuery
    }, (function (_this) {
      return function (err, response) {
        var data, item, userSuggestionArray;
        if (response.hasError) {
          return _this.domHost.showModalDialog(response.error.message);
        } else {
          data = response.data;
          if (data.length > 0) {
            userSuggestionArray = (function () {
              var i, len, results;
              results = [];
              for (i = 0, len = data.length; i < len; i++) {
                item = data[i];
                results.push(item);
              }
              return results;
            })();
            return _this.$$("#userSearch").suggestions(userSuggestionArray);
          } else {
            return _this.domHost.showToast('No Match Found');
          }
        }
      };
    })(this));
  },

  userSearchEnterKeyPressed: function (e) {
    var id, searchQuery;
    if (e.keyCode !== 13) {
      return;
    }
    searchQuery = this.$$("#userSearch").text;
    console.log(searchQuery);
    return this._searchUser(id, searchQuery);
  },

  userSearch: function () {
    var id, searchQuery;
    searchQuery = this.$$("#userSearch").text;
    return this._searchUser(id, searchQuery);
  },
  userSelected: function (e) {
    this.msgObj.requestTo = e.detail.option;
  },

  userAddedToGroup: function (e) {
    var user;
    user = e.detail.option;
    if (this.userGroup.length > 10) {
      this.domHost.showModalDialog("Can't send notification to more than 10 people");
      return;
    }
    if ((this.userGroup.findIndex((function (_this) {
      return function (item) {
        return item.idOnServer === user.idOnServer;
      };
    })(this))) > -1) {
      this.domHost.showModalDialog("User Already added");
      return;
    }
    this.push('userGroup', user);
    return this.async((function (_this) {
      return function () {
        return _this.$$("#groupUserSearch").clear();
      };
    })(this));
  },

  userSearchCleared: function () {
    var id;
    id = this.selectedPage === 0 ? 'userSearch' : 'groupUserSearch';
    return this.$$("#" + id).clear();
  }
  // Search for user - end

});