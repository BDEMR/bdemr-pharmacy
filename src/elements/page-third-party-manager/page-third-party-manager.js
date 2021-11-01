Polymer({
  is: 'page-third-party-manager',

  behaviors: [
    app.behaviors.dbUsing,
    app.behaviors.apiCalling,
    app.behaviors.translating,
    app.behaviors.commonComputes,
    app.behaviors.pageLike
  ],

  properties: {
    selectedPageIndex: {
      type: Number,
      value: 0
    },
    logs: {
      type: Array,
      value: []
    },
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
    thirdParties: {
      type: Array,
      value: [],
      notify: true
    },
    selectedPage: {
      type: Number,
      value: 0
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
      this._loadData();
    });
  },

  _loadData() {
    this._callGetThirdPartiesApi();
    this._callGetThirdPartyLogsApi();
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
  
  arrowBack(e) {
    return this.domHost.navigateToPreviousPage();
  },

  showAddNewThirdPartyDialog() {
  //  console.log("Hello", this.thirdParty, thirdParty);
    this._resetThirdPartyObject();
    this.$$('#dialogThirdParty').toggle();
  },

  _resetThirdPartyObject() {
   // console.log("Hello", this.thirdParty, thirdParty);
    var thirdParty = {
      serial: null,
      lastModifiedDatetimeStamp: null,
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      createdDatetimeStamp: null,
      lastSyncedDatetimeStamp: 0,
      data: {
        balance: 0,
        user: {}
      },
      logs: [] 
        
    };
    this.set('thirdParty', thirdParty);
   // console.log("Hello", this.thirdParty, thirdParty);
  },

  addBtnPressed() {
   // console.log(this.thirdParty.data.user);
    if (this.thirdParty.data.user == null) {
     return this.domHost.showToast('Add a user first!');
     
    } else {
      if (this.thirdParty.serial == null) {
        this.thirdParty.serial = this.generateSerialForThirdParty();
      }
  
      this.thirdParty.createdDatetimeStamp = lib.datetime.now();
  
      this.updateThirdParty(this.thirdParty, () => {
        this.$$('#dialogThirdParty').close();
      })
    }

    ;
  },
  userSelected: function (e) {
    this.thirdParty.data.user = e.detail.option;
    if (this.thirdParty.data.user == null) {
      return this.domHost.showToast('Add a user first!');
      
     } else {
       if (this.thirdParty.serial == null) {
         this.thirdParty.serial = this.generateSerialForThirdParty();
       }
   
       this.thirdParty.createdDatetimeStamp = lib.datetime.now();
   
       this.updateThirdParty(this.thirdParty, () => {
         this.$$('#dialogThirdParty').close();
       })
     }
    console.log(this.thirdParty);
  },

  updateThirdParty(data, cbfn) {
    data.lastModifiedDatetimeStamp = lib.datetime.now();

    this._callSetThirdPartyApi(data, (updatedData) => {
      this._callGetThirdPartiesApi();
      this._callGetThirdPartyLogsApi();
    });

    return cbfn();
  },

  _callSetThirdPartyApi(newData, cbfn) {
    console.log(newData);
    const data = {
      apiKey: this.user.apiKey,
      newData: newData,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--organization-set-third-party', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        cbfn(response.data);
      }
    });
  },
  
  _callGetThirdPartiesApi() {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-organization-third-party-list', data, (err, response) => {
      console.log(response);
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('thirdParties', response.data);
        return;
      }
    });
  },

  _callGetThirdPartyLogsApi() {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--get-organization-third-party-logs', data, (err, response) => {
      console.log(response);
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('logs', response.data);
        return;
      }
    });
  },

  _callThirdPartyAddCommissionApi (thirdPartyId, commissionAmount, logType, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      thirdPartyId: thirdPartyId,
      commissionAmount: commissionAmount,
      organizationId: this.organization.idOnServer,
      logType: logType
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/bdemr--organization-third-party-add-commission', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        cbfn();
      }
    });
  },
    

  _callDeleteThirdPartyApi(thirdPartyId, cbfn) {
    const data = {
      apiKey: this.user.apiKey,
      organizationId: this.organization.idOnServer,
      thirdPartyId: thirdPartyId
    };
    this.domHost.toggleModalLoader('Updating..');
    this.callApi('/delete-organization-third-party', data, (err, response) => {
      this.domHost.toggleModalLoader();
      if (response.hasError) {
        return console.log(response.error.message);
      } else {
        this.domHost.showToast('Deleted Successfully!');
        cbfn();
      }
    });
  },

  _onTapAddFund(e) {
    index = e.model.index;
    item = this.thirdParties[index];
    givenAmount = -(parseFloat(item.data.givenAmount))

    this._callThirdPartyAddCommissionApi(item._id, givenAmount , 'Advance Given', () => {
      this._callGetThirdPartiesApi();
      this._callGetThirdPartyLogsApi();
    });
  },

  _onTapDeleteThirdParty(e) {
    index = e.model.index;
    item = this.thirdParties[index];
    this._callDeleteThirdPartyApi(item._id, () => {
      this._callGetThirdPartiesApi();
    });
  },

  _onTapEditThirdParty(e) {
    index = e.model.index;
    item = this.thirdParties[index];
    console.log(item.data.user)
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
  // userSelected: function (e) {
  //   this.thirdParty.data.user = e.detail.option;
  //   if (this.thirdParty.data.user == null) {
  //     return this.domHost.showToast('Add a user first!');
      
  //    } else {
  //      if (this.thirdParty.serial == null) {
  //        this.thirdParty.serial = this.generateSerialForThirdParty();
  //      }
   
  //      this.thirdParty.createdDatetimeStamp = lib.datetime.now();
   
  //      this.updateThirdParty(this.thirdParty, () => {
  //        this.$$('#dialogThirdParty').close();
  //      })
  //    }
  //   console.log(this.thirdParty);
  // },

  userSearchCleared: function () {
    return this.$$("#userSearch").clear();
  },
  // Search for user - end

  _checkBalanceClass: function (data) {
    data  = parseFloat(data)
    if(data < 0) {
      return "danger"
    }
    else {
      return "success"
    }
  }

});