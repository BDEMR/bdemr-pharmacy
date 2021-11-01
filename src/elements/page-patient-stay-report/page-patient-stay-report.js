Polymer({
  is: 'page-patient-stay-report',
  behaviors: [
    app.behaviors.commonComputes,
    app.behaviors.dbUsing,
    app.behaviors.apiCalling,
    app.behaviors.pageLike
  ],
  properties: {
    user: Object,
    organization: Object,
    patientStayObject: Object,
    matchingSeatList: {
      type: Array,
      value: []
    },
    unitList: {
      type: Array,
      value: []
    },
    wardList: {
      type: Array,
      value: []
    },
    selectedDepartmentName: String,
    selectedUnitName: String,
    selectedWardName: String,
    loadingCounter: {
      type: Number,
      value: 0
    },
    showVaccantOnly: {
      type: Boolean,
      value: false
    },
    selectedPage: {
      type: Number,
      value: 0
    },
    patientStayRecordList: {
      type: Array,
      value: []
    },
    unitListForAll: {
      type: Array,
      value: []
    },
    wardListForAll: {
      type: Array,
      value: []
    },
    selectedDepartmentNameForAll: String,
    selectedUnitNameForAll: String,
    selectedWardNameForAll: String,
  },

  ready(){
    console.log("inside stay report ready");
    this._loadUser();
    console.log("loaded user");
    this._loadOrganization(()=>{
      console.log("loaded org");
      this._loadPatientStayObject(this.organization.idOnServer);
    });
  },

  navigatedIn() {
    console.log("inside stay report navigated in");
  },

  _notifyInvalidOrganization() {
    this.isOrganizationValid = false
    this.domHost.showModalDialog('Invalid Organization Provided');
  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length === 1) {
      return this.user = userList[0];
    } else {
      return this.domHost.showModalDialog('User not found')
    }
  },

  _loadOrganization(cbfn) {
    const organizationList = app.db.find('organization');
    if (organizationList.length === 1) {
      this.set('organization', organizationList[0]);
      cbfn();
      return
    }
    else {
      return this.domHost.showModalDialog('Organization not found')
    }
  },

  _loadPatientStayObject(organizationIdentifier) {
    this.loadingCounter++
    const data = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    };
    this.callApi('/bdemr-organization-patient-stay-get-object', data, (err, response) => {
      this.loadingCounter--
      if (err) {
        this.domHost.showModalDialog(err.message);
      } else if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set('patientStayObject', response.data.patientStayObject);
        this.seatList = this.patientStayObject.seatList;
        this.set('matchingSeatList', this.seatList);
        this.patientStayObject.locations = this.patientStayObject.locations || [];
        return console.log(this.patientStayObject);
      }
    });
  },

  _groupMatchingSeatList(seatList){
    vacantList = seatList.filter((seat)=>{
      return seat.patientSerial === null || seat.patientSerial === undefined || seat.patientSerial === '' 
    });

    occupiedList = seatList.filter((seat)=>{
      return seat.patientSerial !== null && seat.patientSerial !== undefined && seat.patientSerial !== '' 
    });

    return vacantList.concat(occupiedList);
  },

  _loadAllPatientStayRecord(organizationIdentifier) {
    this.loadingCounter++
    const data = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier,
      searchParameters: {
        selectedDepartmentName: this.selectedDepartmentNameForAll,
        selectedUnitName: this.selectedUnitNameForAll,
        selectedWardName: this.selectedWardNameForAll,
      }
    };
    console.log('query data', data);
    this.callApi('/bdemr-organization-get-all-patient-stay-record', data, (err, response) => {
      this.loadingCounter--
      if (err) {
        this.domHost.showModalDialog(err.message);
      } else if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        let tempPatientStayRecord = response.data
        console.log('all patient stay record', tempPatientStayRecord);
        let dischargedPatientStayRecord = tempPatientStayRecord.filter((record)=>{
          return record.dischargeDatetimeStamp !== null && record.dischargeDatetimeStamp !== undefined && record.dischargeDatetimeStamp !== '' && record.dischargeDatetimeStamp !== 'undefined' && this._isAdmittedOnWithinRangeDischargeReport(record)
        });
        console.log('discharged patient stay record', dischargedPatientStayRecord);
        this.set('patientStayRecordList', dischargedPatientStayRecord);

        // this.seatList = this.patientStayObject.seatList;
        // this.set('matchingSeatList', this.seatList);
        // this.patientStayObject.locations = this.patientStayObject.locations || [];
        // return console.log(this.patientStayObject);
      }
    });
  },
  departmentDropdownValueChangedForAll(e) {
    if (!e.detail.value) return;
    let { name, unitList } = e.detail.value;
    this.set('unitListForAll', unitList);
    this.set('selectedUnitNameForAll', '');
    this.set('selectedDepartmentNameForAll', name);
  },
  unitDropdownValueChangedForAll(e) {
    if (!e.detail.value) return;
    let { name, wardList } = e.detail.value;
    this.set('wardListForAll', wardList);
    this.set('selectedWardNameForAll', '');
    this.set('selectedUnitNameForAll', name);
  },
  wardDropdownValueChangedForAll(e) {
    if (!e.detail.value) return;
    this.set('selectedWardNameForAll', e.detail.value.name);
  },

  _calculateStayDuration(admissionDate, dischargeDate) {
    if(!dischargeDate){
      dischargeDate = Date.now();
    }
    let duration = dischargeDate - admissionDate;
    return duration;
  },

  _formatStayDurationResult(duration) {
    let durationFormattedString = '';
    let oneDay = 1000*60*60*24;
    let oneHour = 1000*60*60;
    let durationInDays = Number.parseInt(duration / oneDay);
    durationFormattedString = `${durationInDays} d`;

    // let durationInHours = Number.parseInt((duration % oneDay) / oneHour);
    // durationFormattedString = `${durationInDays} day(s) and ${durationInHours} hour(s)`;

    return durationFormattedString;
  },

  _calculateStayDurationAndFormatResult(admissionDate, dischargeDate) {
    let duration = this._calculateStayDuration(admissionDate, dischargeDate);
    return this._formatStayDurationResult(duration);
  },

  _calculateTotalStayDurationAndFormatResult(patientStayRecordList) {
    let totalStay = patientStayRecordList.reduce((total, stay)=>{
      return total + this._calculateStayDuration(stay.admissionDateTimeStamp, stay.dischargeDatetimeStamp);
    }, 0);
    console.log('total stay duration', totalStay);
    return this._formatStayDurationResult(totalStay);
  },

  _calculateAverageStayDurationAndFormatResult(patientStayRecordList) {
    let totalStay = patientStayRecordList.reduce((total, stay)=>{
      return total + this._calculateStayDuration(stay.admissionDateTimeStamp, stay.dischargeDatetimeStamp);
    }, 0);
    let averageStay  = Number.parseInt(totalStay / patientStayRecordList.length);
    return this._formatStayDurationResult(averageStay);
  },

  showAllPatientStayRecord(){
    this._loadAllPatientStayRecord(this.organization.idOnServer);
  },

  departmentDropdownValueChanged(e) {
    if (!e.detail.value) return;
    let { name, unitList } = e.detail.value
    this.set('unitList', unitList);
    this.set('selectedDepartmentName', name)
  },
  unitDropdownValueChanged(e) {
    if (!e.detail.value) return;
    let { name, wardList } = e.detail.value;
    this.set('wardList', wardList)
    this.set('selectedUnitName', name);
  },
  wardDropdownValueChanged(e) {
    if (!e.detail.value) return;
    this.set('selectedWardName', e.detail.value.name)
  },

  _setMatchingSeatList(seatList){
    groupedList = this._groupMatchingSeatList(seatList);
    console.log('grouped list', groupedList);
    this.set('matchingSeatList', groupedList);
  },

  _isAdmittedOnWithinRangeCurrentReport(item){
    let isGreaterThanFrom = true;
    let isLessThanTo = true;

    if(this.currentReportDateCreatedFrom){
      isGreaterThanFrom = item.patientAdmittedDatetimeStamp >= this.currentReportDateCreatedFrom;
    }
    if(this.currentReportDateCreatedTo){
      isLessThanTo = item.patientAdmittedDatetimeStamp <= this.currentReportDateCreatedTo;
    }
    return isGreaterThanFrom && isLessThanTo;

  },

  _isAdmittedOnWithinRangeDischargeReport(item){
    let isGreaterThanFrom = true;
    let isLessThanTo = true;
    if(this.dischargeReportDateCreatedFrom){
      isGreaterThanFrom = item.dischargeDatetimeStamp >= this.dischargeReportDateCreatedFrom;
    }
    if(this.dischargeReportDateCreatedTo){
      isLessThanTo = item.dischargeDatetimeStamp <= this.dischargeReportDateCreatedTo;
    }
    return isGreaterThanFrom && isLessThanTo;

  },

  searchButtonClicked() {
    const filterdSeatList = this.seatList.filter(item => (this.selectedDepartmentName ? item.department == this.selectedDepartmentName : true) && (this.selectedUnitName ? item.unit == this.selectedUnitName : true) && (this.selectedWardName ? item.ward == this.selectedWardName : true) && (this.showVaccantOnly ? (item.patientSerial ? false : true) : true) && this._isAdmittedOnWithinRangeCurrentReport(item));
    this._setMatchingSeatList(filterdSeatList);
  },

  filterByDateClickedCurrentReport(e){
    let startDate = new Date(e.detail.startDate);
    startDate.setHours(0,0,0,0);
    let endDate = new Date(e.detail.endDate);
    endDate.setHours(23,59,59,999);
    this.set('currentReportDateCreatedFrom', (startDate.getTime()));
    this.set('currentReportDateCreatedTo', (endDate.getTime()));
  },

  filterByDateClearButtonClickedCurrentReport(){
    this.currentReportDateCreatedFrom = '';
    this.currentReportDateCreatedTo = '';
  },

  filterByDateClickedDischargeReport(e){
    let startDate = new Date(e.detail.startDate);
    startDate.setHours(0,0,0,0);
    let endDate = new Date(e.detail.endDate);
    endDate.setHours(23,59,59,999);
    this.set('dischargeReportDateCreatedFrom', (startDate.getTime()));
    this.set('dischargeReportDateCreatedTo', (endDate.getTime()));
  },

  filterByDateClearButtonClickedDischargeReport(){
    this.dischargeReportDateCreatedFrom = '';
    this.dischargeReportDateCreatedTo = '';
  }

})