Polymer({
  is: 'page-ndr-record-list',

  behaviors: [
    app.behaviors.commonComputes,
    app.behaviors.dbUsing,
    app.behaviors.translating,
    app.behaviors.pageLike,
    app.behaviors.apiCalling
  ],

  properties: {
    user: Object,

    patient: Object,

    ndrRecordList: {
      type: Array,
      value: function () { return [] }
    },

    loading: Boolean
  },

  // Utils
  _computeAge(dateString) {
    const today = new Date();
    const birthDate = new Date(dateString);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if ((m < 0) || ((m === 0) && (today.getDate() < birthDate.getDate()))) {
      age--;
    }
    return age;
  },


  navigatedIn() {
    let params = this.domHost.getPageParams()

    this._loadUser();

    this._loadNdrRecords(params['patient']);
  },

  _loadUser() {
    let userList = app.db.find('user');
    if (userList.length) {
      this.set('user', userList[0]);
    } else {
      return this.domHost.showModalDialog('Invalid User');
    }
  },

  _loadNdrRecords(patientSerial) {
    let data = {
      apiKey: this.user.apiKey,
      patientSerial
    }

    this.loading = true;

    this.callApi('bdemr--get-patient-ndr-records', data, (err, response) => {
      this.loading = false;
      console.log(response);
      if (err) {
        this.domHost.showModalDialog(err.message);
        this.domHost.showModalDialog('Could not conect to Server');
      } else if (response.hasError) {
        this.domHost.showModalDialog(response.error.message)
      } else {
        let { patientInfo, ndrList } = response.data;
        if (patientInfo) {
          this.set('patient', patientInfo);
        }
        if (ndrList.length) {
          this.set('ndrRecordList', ndrList)
        }
      }
    })
  },

  viewNdrRecord(e) {
    let record = e.model.item;
    record.patientInfo = this.patient;
    // return console.log(record);
    window.localStorage.setItem('previewTempNDRRecord', JSON.stringify(record))
    let url = "#/preview-ndr/record:" + record.serial + "/patient:" + record.patientSerial + "/recordOnline:true"
    this.domHost.navigateToPage(url);
  },


  arrowBackButtonPressed(e) {
    this.domHost.navigateToPreviousPage();
  }





})