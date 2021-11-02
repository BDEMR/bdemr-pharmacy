Polymer({
  is: 'bdemr-video-chat',
  behaviors: [
    app.behaviors.apiCalling,
  ],

  properties: {
    patientId: {
      type: String,
      value: null,
      observer: '_patientIdChanged'
    },
    otCore: {
      type: Object,
      value: null
    },

    callButtonLabel: {
      type: String,
      value: 'Start New Call'
    },
    publisherName: {
      type: String,
      value: ''
    },
    user: {
      type: Object,
      value: {}
    },
    tokBoxApiKey: {
      type: String,
      value: "46831874"
    },
    sessionId: {
      type: String,
      value: null,
      observer: '_sessionIdChanged'
    },
    searchFieldMainInput: {
      type: String,
      notify: true,
      value: ''
    },
    selectedpatientId: {
      type: String,
      value: ''
    },
    selectedPatients: {
      type: Object,
      value: null
    },
    patientSearchQuery: {
      type: String,
      value: "",
      observer: 'patientSearchInputChanged'
    },
    state: {
      type: Object,
      value: {
        connected: false,
        active: false,
        publishers: null,
        subscribers: null,
        meta: null,
        localAudioEnabled: true,
        localVideoEnabled: true,
      }
    },
    options: {
      type: Object,
      value: {}
    },
    selectedPatients: {
      type: Object,
      value: null
    },
  },

  _joinSessionCalled: function (sessionId, cbfn) {
    this.callApi('/bdemr-tokbox-get-session-token', { apiKey: this.user.apiKey, sessionId: sessionId }, (err, response) => {
      if (err) return err;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        return cbfn(response.data);
      }
    });
  },

  togglePictureInPicture: function (e) {

    const video = this.$$(".OT_subscriber video");

    video.addEventListener('leavepictureinpicture', () => {
      this.classList.remove('hidden');
    });

    if (document.pictureInPictureElement) {
      document.exitPictureInPicture().catch((error) => console.log(error))
      console.log(this);
      this.classList.remove('hidden');
    }
    else {
      if (document.pictureInPictureEnabled) {
        video.requestPictureInPicture().catch((error) => console.log(error));
        this.classList.add('hidden');
      }
    }
  },



  leavePictureInPicutre: function () {

  },

  _createNewSessionFromServer: function (cbfn) {
    this.callApi('/bdemr-tokbox-create-session', { apiKey: this.user.apiKey }, (err, response) => {
      if (err) return err;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        return cbfn(response.data);
      }
    });
  },

  initializeSession: function (sessionData, cbfn) {
    console.log('initializeSession');
    const { sessionId, token } = sessionData;
    this._setSessionId(sessionId);
    this.options = this.getOptions(sessionId, token);

    this.init(() => {
      return cbfn();
    });

  },

  /**
   * Update the size and position of video containers based on the number of
   * publishers and subscribers specified in the meta property returned by this.otCore.
  */
  updateVideoContainers: function () {
    const { meta } = this.state;
    console.log({ meta });
    const sharingScreen = meta ? !!meta.publisher.screen : false;
    const viewingSharedScreen = meta ? meta.subscriber.screen : false;
    const activeCameraSubscribers = meta ? meta.subscriber.camera : 0;



    const videoContainerClass = `TokBox-video-container ${(sharingScreen || viewingSharedScreen) ? 'center' : ''}`;
    this.$.TokBoxVideoContainer.setAttribute('class', videoContainerClass);

    const cameraPublisherClass =
      `video-container ${!!activeCameraSubscribers || sharingScreen ? 'small' : ''} ${!!activeCameraSubscribers || sharingScreen ? 'small' : ''} ${sharingScreen || viewingSharedScreen ? 'left' : ''}`;
    this.$.cameraPublisherContainer.setAttribute('class', cameraPublisherClass);

    const screenPublisherClass = `video-container ${!sharingScreen ? 'hidden' : ''}`;
    console.log(this.$.screenPublisherContainer.classList, screenPublisherClass);
    this.$.screenPublisherContainer.setAttribute('class', screenPublisherClass);

    const cameraSubscriberClass =
      `video-container ${!activeCameraSubscribers ? 'hidden' : ''} active-${activeCameraSubscribers} ${viewingSharedScreen || sharingScreen ? 'small' : ''}`;
    this.$.cameraSubscriberContainer.setAttribute('class', cameraSubscriberClass);

    const screenSubscriberClass = `video-container ${!viewingSharedScreen ? 'hidden' : ''}`;
    this.$.screenSubscriberContainer.setAttribute('class', screenSubscriberClass);

    if (activeCameraSubscribers > 0) {
      localStorage.setItem("visibleVideoButton", true);
    } else {
      localStorage.setItem("visibleVideoButton", false);
    }
  },
  /**
   * Update the UI
   * @param {String} update - 'connected', 'active', or 'meta'
  */
  updateUI: function (update) {
    console.log(update);
    const { connected, active } = this.state;

    switch (update) {
      case 'connected':
        if (connected) {
          this.$.connectingMask.classList.add('hidden');
          // this.$.startMask.classList.remove('hidden');
        }
        break;
      case 'active':
        if (active) {
          this.$.cameraPublisherContainer.classList.remove('hidden');
          // this.$.startMask.classList.add('hidden');
          this.$.controls.classList.remove('hidden');
        }
        break;
      case 'meta':
        this.updateVideoContainers();
        break;
      default:
        console.log('nothing to do, nowhere to go');
    }
  },
  /**
  * Update the this.state and UI
  */
  updateState: function (updates) {
    this.state = updates;

    Object.keys(updates).forEach(update => this.updateUI(update));
  },
  /**
   * Start publishing video/audio and subscribe to streams
  */
  startCall: function (cbfn) {
    let that = this;
    console.log(this.otCore);
    this.otCore.startCall().then(function ({ publishers, subscribers, meta }) {
      that.updateState({ publishers, subscribers, meta, active: true });
      console.log('hello from startCall');
      cbfn();
    }).catch(function (error) { console.log(error); });
  },

  endCall: function () {
    window.location.reload()
    // let that = this;
    // this.otCore.disconnect().then(function () {
    // }).catch(function (error) { console.log(error); });
  },

  inviteUser: function () {

  },

  /**
   * Toggle publishing local audio
  */
  toggleLocalAudio: function () {
    const enabled = this.state.localAudioEnabled;
    this.otCore.toggleLocalAudio(!enabled);
    this.updateState({ localAudioEnabled: !enabled });
    const action = enabled ? 'add' : 'remove';
    this.$.toggleLocalAudio.classList[action]('muted');
  },

  /**
   * Toggle publishing local video
  */
  toggleLocalVideo: function () {
    const enabled = this.state.localVideoEnabled;
    this.otCore.toggleLocalVideo(!enabled);
    this.updateState({ localVideoEnabled: !enabled });
    const action = enabled ? 'add' : 'remove';
    this.$.toggleLocalVideo.classList[action]('muted');
  },

  /**
   * Subscribe to this.otCore and UI events
   */
  createEventListeners: function () {
    const events = [
      'subscribeToCamera',
      'unsubscribeFromCamera',
      'subscribeToScreen',
      'unsubscribeFromScreen',
      'startScreenShare',
      'endScreenShare',
    ];
    events.forEach(event => this.otCore.on(event, ({ publishers, subscribers, meta }) => {
      this.updateState({ publishers, subscribers, meta });
    }));

    // this.$$('#start').addEventListener('click', startCall);
    // this.$$('#toggleLocalAudio').addEventListener('click', toggleLocalAudio);
    // this.$$('#toggleLocalVideo').addEventListener('click', toggleLocalVideo);
  },

  getOptions: function (sessionId, token) {
    let that = this;
    return {
      credentials: {
        apiKey: this.tokBoxApiKey,
        sessionId,
        token,
      },
      streamContainers: function streamContainers(pubSub, type, data) {
        return {
          publisher: {
            camera: that.$.cameraPublisherContainer,
            screen: that.$.screenPublisherContainer,
          },
          subscriber: {
            camera: that.$.cameraSubscriberContainer,
            screen: that.$.screenSubscriberContainer,
          },
        }[pubSub][type];
      },
      controlsContainer: that.$.controls,
      packages: [],
      communication: {
        callProperties: null, // Using default
      },
    }
  },
  /**
   * Initialize this.otCore, connect to the session, and listen to events
  */
  init: function (cbfn) {
    let that = this;
    this.otCore = new AccCore(this.options);
    this.otCore.connect().then(function () {
      console.log('hello from connect()');
      that.updateState({ connected: true });
      that.otCore.startCall().then(function ({ publishers, subscribers, meta }) {
        console.log('hello from startCall()');
        that.updateState({ publishers, subscribers, meta, active: true });
        cbfn()
      }).catch(function (error) { console.log(error); });
    });
    this.createEventListeners();

  },

  // Invite user - start
  patchOverlay: function (e) {
    if (e.target.withBackdrop) {
      e.target.parentNode.insertBefore(e.target.backdropElement, e.target);
    }
  },

  patientSearchInputChanged: function (searchQuery) {
    console.log({ searchQuery });
    if (!(searchQuery.length > 2)) {
      return;
    }
    return this.debounce('search-patient', (function () {
      return function () {
        return this._patientSearch(searchQuery);
      };
    })(this), 1000);
  },

  _patientSearch: function (searchQuery) {
    console.log({ searchQuery });
    if (!searchQuery) {
      return;
    }
    this.$$("#patientSearch").items
    this.fetchingPatientSearchResult = true;
    const that = this;

    this.callApi('/bdemr-patient-search-new', {
      apiKey: that.user.apiKey,
      searchQuery: searchQuery
    }, (function () {
      return function (err, response) {
        that.fetchingPatientSearchResult = false;
        if (response.hasError) {
          that.domHost.showToast('No Match Found!');
          return that._clearSelectedPatientData();
        } else {
          that.matchingPatientdata = response.data;
          console.log(that.matchingPatientdata);
          if (that.matchingPatientdata.length > 0) {
            that.$$("#patientSearch").items = that.matchingPatientdata;
          }
        }
      };
    })(this));

  },

  patientSelected: function (e) {
    if (!e.detail.value) {
      return;
    }
    this.set("selectedPatients", e.detail.value);
  },

  _clearSelectedPatientData: function () {
    this.set("patientSearchQuery", '');
    this.set("selectedPatients", null);
    return this.$$("#patientSearch").value = "";
  },

  _setSessionId: function (sessionId) {
    this.set('sessionId', sessionId);
    localStorage.setItem("videoCallSessionId", this.sessionId);
  },

  togglInvitePressed: function () {
    this.$.invitationDialog.toggle();
    this._clearSelectedPatientData();
  },

  sendInvitationButtonPressed: function () {
    console.log(this.selectedPatients);
    if (!this.selectedPatients) {
      this.domHost.showToast("Please select an user first!");
      return;
    }
    // this.commonStartVideoCall(this.selectedPatients.idOnServer);
    this.sendNotificationToUser(this.selectedPatients.idOnServer);
    this.$.invitationDialog.close();
  },

  sendNotificationToUser: function (patientId) {
    let user = this.getCurrentUser();
    console.log({ user });
    let request = {
      operation: 'notify-single',
      apiKey: user.apiKey,
      notificationCategory: 'video-chat',
      notificationMessage: user.name + " has invited you to a video call.",
      videoChatSessionId: this.sessionId,
      sender: user.name,
      notificationTargetId: patientId
    };
    this.domHost.ws.send(JSON.stringify(request));
    this.domHost.showToast("Invitation Sent Successfully!");
  },

  commonStartVideoCall: function (patientId) {
    this.startVideoCall(() => this.sendNotificationToUser(patientId))
  },

  startVideoCall: function (cbfn) {
    console.log('startVideoCall');
    this._createNewSessionFromServer((sessionData) => {
      this.initializeSession(sessionData, () => {
        cbfn(null);
      });
    });
  },

  copyToClipboard: function () {
    var copy;
    copy = (function () {
      return function (e) {
        e.preventDefault();
        if (e.clipboardData) {
          e.clipboardData.setData('text/plain', this.sessionId);
        } else if (window.clipboardData) {
          window.clipboardData.setData('Text', this.sessionId);
        }
      };
    })(this);
    window.addEventListener('copy', copy);
    document.execCommand('copy');
    window.removeEventListener('copy', copy);
    return this.domHost.showToast('Session ID Copied!');
  },

  // Invite user - end

  _patientIdChanged: function (patientId) {
    if (!patientId) return;
    if (!this.user) return;

    console.log({ patientId });
    this.user = (app.db.find('user'))[0];

    if (patientId) {
      this.commonStartVideoCall(patientId)
    }
  },

  _sessionIdChanged: function (sessionId) {
    if (this.patientId) return;
    if (!sessionId) return;

    console.log({ sessionId });

    if (!this.user) return;
    this.user = (app.db.find('user'))[0];

    const that = this;


    if (sessionId) {
      this._joinSessionCalled(sessionId, (sessionData) => {
        this.initializeSession(sessionData, function () {
          that.set("callButtonLabel", "Click here to Join Call");
          // that.publisherName = localStorage.get("publisherName")
        });
      });
    }

  }

})






