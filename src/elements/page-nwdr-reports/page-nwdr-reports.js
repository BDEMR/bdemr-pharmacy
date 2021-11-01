Polymer({

  is: 'page-nwdr-reports',

  behaviors: [
    app.behaviors.dbUsing,
    app.behaviors.translating,
    app.behaviors.pageLike,
    app.behaviors.commonComputes,
    app.behaviors.apiCalling
  ],

  properties: {

    selectedPageIndex: {
      type: Number,
      notify: true,
      value: 0
    },

    user: {
      type: Object,
      notify: true,
      value: null
    },

    organization: {
      type: Object,
      notify: true,
      value: null
    },

    childOrganizationList: {
      type: Array,
      notify: true,
      value: []
    },

    loading: {
      type: Boolean,
      value: false
    },

    categoryList: {
      type: Array,
      value() { return ['Symptoms', 'Diagnosis', 'Investigation', 'Medicine']; }
    },

    ageGroupList: {
      type: Array,
      value() {
        return [
          'All',
          '0 to 18',
          '18 to 25',
          '25 to 35',
          '35 to 50',
          '50 to above'
        ];
      }
    },

    salaryRangeList: {
      type: Array,
      value() {
        return [
          "All",
          "0 to 10,000",
          "10,000 to 20,000",
          "20,000 to 30,000",
          "30,000 to 40,000",
          "40,000 to 50,000",
          "50,000 to above"
        ];
      }
    },

    reportResults: {
      type: Array,
      value: []
    },

    visitReasonList: {
      type: Array,
      value() { 
        return [
          'All',
          'Preconception',
          '1st ANC (6 - 14 weeks)',
          '2nd ANC (24 - 28 weeks)',
          'At Delivery',
          '6 weeks after delivery',
          '1 year after delivery',
          '5 years after delivery'
        ];
      }
    },
    childOrganizationCounter: {
      type: Array,
      value: []
    },

    questionList: {
      type: Array,
      value() {
        return [
          {
            question: {
              en: 'Appropriate medical advice before pregnancy may reduce the risk of diabetes,gestational diabetes (diabetes during pregnancy) and heart problems',
              bd: 'গর্ভধারণের আগে সঠিক সেবা ভবিষ্যতে ডায়াবেটিস ,গর্ভকালীন ডায়াবেটিস ও হৃদরোগের ঝুঁকি কমায়'
            },
            value: ''
          }, {
            question: {
              en: 'Every married woman should take the following vaccinations before pregnancy: Tetanus, Measles, Mumps, Rubella, Chicken Pox, Hepatitis-B, if not taken previously',
              bd: 'আগে থেকে দেয়া না থাকলে প্রত্যেক বিবাহিত নারীর গর্ভধারণের পূর্বে টিটেনাস, হাম, মাম্পস, রুবালা, জলবসন্ত ও বি-ভাইরাসের টিকাগুলি নেয়া উচিত'
            },
            value: ''
          }, {
            question: {
              en: 'Before pregnancy every women should know their blood group',
              bd: 'গর্ভধারণের পূর্বেই প্রত্যেক মহিলার রক্তের গ্রুপ জেনে নেয়া প্রয়োজন'
            },
            value: ''
          }, {
            question: {
              en: 'People who are overweight and have family members with diabetes are most likely to get diabetes (by family members only parents, siblings and grandparents are implied)',
              bd: 'যাদের ওজনাধিক্য ও বংশে ডায়াবেটিস আছে, তাদের ডায়াবেটিস হবার ঝুঁকি বেশি'
            },
            value: ''
          }, {
            question: {
              en: 'Uncontrolled gestational diabetes (diabetes during pregnancy) may create complications for the mother and child',
              bd: 'অনিয়ন্ত্রিত গর্ভকালীন ডায়াবেটিস মা ও শিশুর নানান জটিলতা সৃষ্টি করতে পারে'
            },
            value: ''
          }, {
            question: {
              en: 'Overeating and less physical activity are among the many causes for overweight and obesity',
              bd: 'অতিরিক্ত খাদ্যাভ্যাস ও কম শারীরিক পরিশ্রম ওজনাধিক্য ও স্থুলতার অন্যতম কারণ'
            },
            value: ''
          }, {
            question: {
              en: 'Low Hemoglobin Level (Anemia) increases the risk of complications before and after pregnancy',
              bd: 'রক্তস্বল্পতার কারণে গর্ভকালীন, প্রসবকালীন ও প্রসব পরবর্তী জটিলতা বৃদ্ধি পায়'
            },
            value: ''
          }, {
            question: {
              en: 'Stroke, heart problems, kidney and respiratory disorders may be caused by high blood pressure',
              bd: 'উচ্চ রক্তচাপের কারণে স্ট্রোক, হৃদরোগ, স্নায়ুরোগ ও কিডনির সমস্যা দেখা দিতে পারে'
            },
            value: ''
          }, {
            question: {
              en: 'The condition where pregnant women with blood pressure, experience convulsions/fit is called Eclampsia',
              bd: 'গর্ভকালীন উচ্চ রক্তচাপসহ খিঁচুনি হওয়াকে এক্লাম্পশিয়া বলে '
            },
            value: ''
          }, {
            question: {
              en: 'If Urinary Tract Infection (infection related with urine & bladder) is not treated properly before/during pregnancy, the risk of underweight childbirth and premature baby increases',
              bd: 'গর্ভকালীন মূত্রনালির সংক্রমণের সঠিক চিকিৎসা না করালে কম ওজনের শিশুর জন্ম ও অকালে সন্তান প্রসবের ঝুঁকি বাড়ে'
            },
            value: ''
          }
        ];
      }
    },

    totalCostByReport: {
      type: Number,
      notify: true,
      computed: '_getTotalCostByReport(reportResults)'
    },

    totalDrugCostByReport: {
      type: Number,
      notify: true,
      computed: '_getTotalCategoryCostByReport("Medicine", reportResults)'
    },

    totalInvestigationCostByReport: {
      type: Number,
      notify: true,
      computed: '_getTotalCategoryCostByReport("Investigation", reportResults)'
    },

    totalConsultancyCostByReport: {
      type: Number,
      notify: true,
      computed: '_getTotalCategoryCostByReport("Consultancy" ,reportResults)'
    },

    matchingOrganizationPatientList: {
      type: Array,
      notify: true,
      value: []
    },

    dateCreatedFrom: String,
    dateCreatedTo: String,
    selectedGender: String,
    selectedOrganizationId: String

  },

  onPageChange () {
    // console.log(this.selectedPageIndex);
  },

  isEmptyArray (length){
    if (length == 0)
      return true;
    else
      return false;
  },

  $getList (list) {
    console.log(list);
    return list;
  },

  onItemDeleteBtnPressed (e) {
    index = e.model.index;
    console.log(index);
    serial = this.reportResults[index].nwdr.serial;
    this._callDeleteRecordApi(serial, index);

  },

  _callDeleteRecordApi (recordIdentifier, index) {
    const query = {
      apiKey: this.user.apiKey,
      recordSerial: recordIdentifier
    }
    this.callApi('/delete-selected-nwdr-records', query, (err, response) => {
      console.log(response);

      if (response.hasError) {
        this.domHost.showToast(response.error.message);
      }
      else {
        this.domHost.showToast("Record deleted Successfully!");
        this.splice('reportResults', index, 1);
      }
    })
  },

  navigatedIn() {
    this._loadUser();
    this._loadOrganization();
  },


  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length == 1) this.set('user', userList[0]);
  },


  _loadOrganization() {
    const organizationList = app.db.find('organization');
    if (organizationList.length === 1) {
      this.set('organization', organizationList[0]);
      this._loadChildOrganizationList(this.organization.idOnServer)
    }

  },

  _loadChildOrganizationList(organizationIdentifier) {
    this.organizationLoading = true;
    const query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.callApi('/bdemr--get-child-organization-list', query, (err, response) => {
      console.log(response);
      this.organizationLoading = false;
      const organizationList = response.data
      this.set('childOrganizationCounter', organizationList.length);
      if (organizationList.length) {
        const mappedValue = organizationList.map((item) => {
          return { label: item.name, value: item._id }
        })
        mappedValue.unshift({ label: 'All', value: '' })
        this.set('childOrganizationList', mappedValue)
      } else {
        this.domHost.showToast('No Child Organization Found')
      }
    })
  },

  $getItemCounter(index) {
    return index + 1
  },

  $formatDateTime(dateTime) {
    if (!dateTime) return;
    return lib.datetime.format((new Date(dateTime)), 'mmm d, yyyy h:MMTT')
  },

  organizationSelected(e) {
    const organizationId = e.detail.value;
    this.set('selectedOrganizationId', organizationId)
  },

  filterByDateClicked(e) {
    const startDate = new Date(e.detail.startDate);
    startDate.setHours(0, 0, 0, 0);
    const endDate = new Date(e.detail.endDate);
    endDate.setHours(23, 59, 59, 999);
    this.set('dateCreatedFrom', (startDate.getTime()));
    this.set('dateCreatedTo', (endDate.getTime()));
  },

  filterByDateClearButtonClicked() {
    this.dateCreatedFrom = 0;
    this.dateCreatedTo = 0;
  },

  $getCategoryCost(category, invoice) {
    return invoice && invoice.data.length ? invoice.data.filter((invoiceItem) => category == invoiceItem.category).reduce((totalCost, invoiceItem) => totalCost + (invoiceItem.price ? parseInt(invoiceItem.price) : 0), 0) : 0
  },

  $getTotalCost(invoice) {
    return invoice && invoice.totalBilled ? parseInt(invoice.totalBilled) : 0
  },

  $computeAge(dateString) {
    if (!dateString) { return ""; }
    const today = new Date();
    const birthDate = new Date(dateString);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if ((m < 0) || ((m === 0) && (today.getDate() < birthDate.getDate()))) {
      age--;
    }
    return age;
  },

  _getTotalCostByReport(reports) {
    return reports.reduce((total, item) => {
      return total + this.$getTotalCost(item.invoice)
    }, 0)
  },

  _getTotalCategoryCostByReport(category, reports) {
    return reports.reduce((total, item) => {
      return total + this.$getCategoryCost(category, item.invoice)
    }, 0)
  },

  resetButtonClicked() { return this.domHost.reloadPage(); },

  genderSelected(e) {
    const index = e.detail.selected;
    let gender;
    if (index == 1) {
      gender = 'male'
    } else if (index == 2) {
      gender = 'female'
    } else {
      gender = ''
    }
    return this.set('selectedGender', gender);
  },

  visitTypeSelected(e) {
    const index = e.detail.selected;
    let visitType;
    if(index == 0) {
      return this.set('selectedVisitType', '');
    } else {
      visitType = this.visitReasonList[index];
      return this.set('selectedVisitType', visitType);
    }
    
  },

  _createAgeGroupFromString(ageGroupString) {
    const ageGroupStringArr = ageGroupString.split('to');
    const fromAge = parseInt(ageGroupStringArr[0]);
    const toAge = (isNaN(parseInt(ageGroupStringArr[1])) ? 999 : (parseInt(ageGroupStringArr[1])));
    return [fromAge, toAge];
  },

  ageGroupSelected(e) {
    const index = e.detail.selected;
    let selectedAgeGroup;
    if (index == 0) {
      // all selected
      selectedAgeGroup = []
    } else {
      let selectedAgeGroupString = this.ageGroupList[index];
      selectedAgeGroup = this._createAgeGroupFromString(selectedAgeGroupString);
    }
    return this.set('selectedAgeGroup', selectedAgeGroup);
  },


  _createSalarRangeFromString(salaryRangeString) {
    const salaryRangeStringArr = salaryRangeString.split('to');
    salaryRangeStringArr.splice(0, 1, (salaryRangeStringArr[0].split(",").join("")));
    salaryRangeStringArr.splice(1, 1, (salaryRangeStringArr[1].split(",").join("")));
    const fromSalary = (isNaN(parseInt(salaryRangeStringArr[0])) ? 0 : (parseInt(salaryRangeStringArr[0])));
    const toSalary = (isNaN(parseInt(salaryRangeStringArr[1])) ? 99999999999 : (parseInt(salaryRangeStringArr[1])));
    return [fromSalary, toSalary];
  },

  salaryRangeSelected(e) {
    const index = e.detail.selected;
    let selectedSalaryRange;
    if (index == 0) {
      // all selected
      selectedSalaryRange = []
    } else {
      let selectedSalaryRangeString = this.salaryRangeList[index];
      selectedSalaryRange = this._createSalarRangeFromString(selectedSalaryRangeString);
    }
    return this.set('selectedSalaryRange', selectedSalaryRange);
  },

  searchButtonClicked() {
    let query = {
      apiKey: this.user.apiKey,
      searchParameters: {
        dateCreatedFrom: this.dateCreatedFrom || '',
        dateCreatedTo: this.dateCreatedTo || '',
        searchString: this.searchString || '',
        gender: this.selectedGender || '',
        ageGroup: this.selectedAgeGroup || [],
        salaryRange: this.selectedSalaryRange || [],
        visitType: this.selectedVisitType || ''
      }
    }
    // search parent+child when selecting all
    if (!this.selectedOrganizationId) {
      organizationIdList = this.childOrganizationList.map(item => item.value);
      organizationIdList.splice(0, 1);
      
      query.organizationIdList = organizationIdList;
      query.organizationIdList.push(this.organization.idOnServer);


    } else {
      query.organizationIdList = [this.selectedOrganizationId];
    }

    if (this.selectedPageIndex == 0) {
      this._callGetAllNwdrReportApi(query);
    }

    else if (this.selectedPageIndex == 1) {
      this._callGetOrganizationAllPatientListApi(query);
    } 
  },

  _callGetAllNwdrReportApi (query) {

    this.loading = true;
    this.callApi('/get-all-nwdr-report', query, (err, response) => {
      console.log(response);
      if (response.hasError) {
        this.domHost.showModalDialog(response.error.message);
        this.reportResults = [];
        return this.loading = false;
      } else {

        this.reportResults = response.data
        this.loading = false;
      }
    });
  },

  _callGetOrganizationAllPatientListApi (query) {

    this.loading = true;
    this.callApi('/bdemr-get-organization-all-patient-list', query, (err, response) => {
      console.log(response);
      if (response.hasError) {
        this.domHost.showModalDialog(response.error.message);
        return this.loading = false;
      } else {
        this.set('matchingPatientList', response.data);
        this.loading = false;
      }
    });
  },

  getMedicationList (list) {
    string = '';

    if (list) {

      if (list.length > 0) {
        list.forEach(function (item){
          string += (item.ogldDrugName + ' ' + item.drugDosage) + ", ";
        });
      }
    }

    index = string.lastIndexOf(",");

    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  getActivityList (list) {

    string = '';

    if (list) {

      if (list.length > 0) {
        list.forEach(function (item){
          string += (item.name + ': ' + item.duration + item.unit + ", ");
        });
      }
    }

    index = string.lastIndexOf(",");

    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  getDietaryHistoryByName(type, consumeTime, data) {
    // console.log(type, consumeTime, data);
    value = ''

    if (data.length > 0) {
      data.forEach(function(item) {
        if (item.type == type)  {
          consumeAmount = item.consumeAmount
          consumeAmount.forEach(function(subItem) {
            if (subItem.time == consumeTime)  {
              value = subItem.value;
            }
          });
        }
      });
    }
    return value;
  },
  _getCalorieByName(type, data) {
    // console.log(type, consumeTime, data);
    value = ''

    if (data.length > 0) {
      data.forEach(function(item) {
        if (item.type == type)  {
          value = item.calorie
        }
      });
    }
    return value;
  },
  _getDietChartByName(type, data) {
    // console.log(type, consumeTime, data);
    value = ''

    if (data.length > 0) {
      data.forEach(function(item) {
        if (item.type == type)  {
          value = item.dietChart
        }
      });
    }
    return value;
  },

  _getOtherFamilyDiseaseList(list) {
    string = '';
    if (list.length > 3) {
      for (i = 4 ; i<list.length; i++) {
        string += (list[i].disease + ": " + list[i].value + ", ");
      }
    }

    index = string.lastIndexOf(",");
    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  _getOtherLabInvestigation(list) {
    string = '';
    if (list) {
      if (list.length > 13) {
        for (i = 14 ; i<list.length; i++) {
          string += (list[i].name + ": " + list[i].value + list[i].unit + ", ");
        }
      }
  
      index = string.lastIndexOf(",");
      if (index != -1) {
        partOne = string.substring(0, index);
        partTwo = string.substring(index + 1, string.length);
        string = partOne + partTwo
      }
    }
    return string;
  },

  _getOtherComplicationList(list) {
    string = '';
    if (list.length > 12) {
      for (i = 13 ; i<list.length; i++) {
        string += (list[i].name + ", ");
      }
    }

    index = string.lastIndexOf(",");
    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  _getPersonalHabitList(list) {
    string = '';
    if (list.length > 4) {
      for (i = 5 ; i<list.length; i++) {
        string += (list[i].type + "(" + list[i].isYes + list[i].amount + "), ");
      }
    }

    index = string.lastIndexOf(",");
    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  _getOtherExamination(list) {
    string = '';
    if (list.length > 5) {
      for (i = 6 ; i<list.length; i++) {
        string += (list[i].type + ": " + list[i].value + list[i].unit + ", ");
      }
    }

    index = string.lastIndexOf(",");
    if (index != -1) {
      partOne = string.substring(0, index);
      partTwo = string.substring(index + 1, string.length);
      string = partOne + partTwo
    }
    
    return string;
  },

  _checkIfComplicationIsSelected (isSelected) {
    if (isSelected == true) {
      return 'Yes';
    } 
    return 'No';
    
  },

  _getEcgData (data) {
    console.log(data);
    if (data == 'undefined') {
      return '';
    }
    string = '';
    if (data.value == 'abnormal') {
      string += data.value
      if (data.ecgAbnormalityList.length > 0) {
        string += "(";
        data.ecgAbnormalityList.forEach(function(item) {
          string += item + ", ";
        });
        string += ")";
      }
    } else if (data.value == 'normal') {
      string = data.value;
    } else {
      string = '';
    }
    if (string.length > 0) {
      index = string.lastIndexOf(",");
      if (index != -1) {
        partOne = string.substring(0, index);
        partTwo = string.substring(index + 1, string.length);
        string = partOne + partTwo
      }
    }
    return string;
  },

  _prepareNwdrJsonData(rawReport) {
    return rawReport.map((item) => {
      var object = {
        'Record ID': (item.nwdr && item.nwdr.serial) ? item.nwdr.serial : '',
        'Created Date': (item.nwdr && item.nwdr.createdDatetimeStamp) ? this.$formatDateTime(item.nwdr.createdDatetimeStamp) : '',
        'Organization': (item.organizationInfo && item.organizationInfo.name) ? item.organizationInfo.name : '',
        'Record ID': (item.nwdr && item.nwdr.serial) ? item.nwdr.serial : '',
        'Visit Type': (item.nwdr && item.nwdr.visitReason && item.nwdr.visitReason.type) ? item.nwdr.visitReason.type : '',
        'Patient ID': (item.patientInfo && item.patientInfo.serial) ? item.patientInfo.serial : '',
        'Name': (item.patientInfo && item.patientInfo.name) ? item.patientInfo.name : '',
        'Email Address': (item.patientInfo && item.patientInfo.email) ? item.patientInfo.email : '',
        'Contact Number': (item.patientInfo && item.patientInfo.phone) ? item.patientInfo.phone : '',
        'Additional Contact Number': (item.patientInfo && item.patientInfo.additionalPhone) ? item.patientInfo.additionalPhone : '',
        'Date of Birth (mm/dd/yyyy)': (item.patientInfo && item.patientInfo.dateOfBirth) ? item.patientInfo.dateOfBirth : '',
        'Age': (item.patientInfo && item.patientInfo.dateOfBirth) ? this.$computeAge(item.patientInfo.dateOfBirth) : '',
        'Spouse Name': (item.patientInfo && item.patientInfo.patientSpouseName) ? item.patientInfo.patientSpouseName : '',
        "Father's Name": (item.patientInfo && item.patientInfo.patientFatherName) ? item.patientInfo.patientFatherName : '',
        "Mother's Name": (item.patientInfo && item.patientInfo.patientMotherName) ? item.patientInfo.patientMotherName : '',
        "Expenditure": (item.patientInfo && item.patientInfo.expenditure) ? item.patientInfo.expenditure : '',
        "Profession": (item.patientInfo && item.patientInfo.profession) ? item.patientInfo.profession : '',
        "National ID": (item.patientInfo && item.patientInfo.nationalIdCardNumber) ? item.patientInfo.nationalIdCardNumber : '',
        "Division": (item.patientInfo && item.patientInfo.addressDivision) ? item.patientInfo.addressDivision : '',
        "District": (item.patientInfo && item.patientInfo.addressDistrict) ? item.patientInfo.addressDistrict : '',
        "Area":(item.patientInfo && item.patientInfo.addressArea) ? item.patientInfo.addressArea : '',
        "Marital Status": (item.patientInfo && item.patientInfo.maritalStatus) ? item.patientInfo.maritalStatus : '',
        "Marital Age": (item.patientInfo && item.patientInfo.maritalAge) ? item.patientInfo.maritalAge : '',
        "Number of Family Member": (item.patientInfo && item.patientInfo.numberOfFamilyMember) ? item.patientInfo.numberOfFamilyMember : '',
        "Number of children": (item.patientInfo && item.patientInfo.numberOfChildren) ? item.patientInfo.numberOfChildren : '',
        "Blood Group": (item.patientInfo && item.patientInfo.bloodGroup) ? item.patientInfo.bloodGroup : '',
        "Have Allergy?": (item.patientInfo && item.patientInfo.allergy) ? item.patientInfo.allergy : '',

        // Diabetes History - start
        "Symptomatic?": (item.nwdr) ? item.nwdr.data.symptomatic.isYes : '',
        "Symptomatic Type": (item.nwdr) ? item.nwdr.data.symptomatic.value : '',
        "Patient Type": (item.nwdr) ? item.nwdr.data.diabeticsInfo.patientType : '',
        "Registration Center": (item.nwdr) ? item.nwdr.data.registeredCenter.name : '',
        "Diabetes Duration": (item.nwdr) ? item.nwdr.data.diabeticsInfo.duration : '',
        "Patient Guide Book No.": (item.nwdr) ? item.nwdr.data.diabeticsInfo.patientBookSerial : '',
        "Type of Diabetes": (item.nwdr) ? item.nwdr.data.diabeticsInfo.typeOfDiabetics : '',
        // Diabetes History - end

        // General Examination - start
        "Height": (item.nwdr) ? item.nwdr.data.clinicalInfoList[0].value : '',
        "Weight": (item.nwdr) ? item.nwdr.data.clinicalInfoList[1].value : '',
        "Waist": (item.nwdr) ? item.nwdr.data.clinicalInfoList[2].value : '',
        "Hip": (item.nwdr) ? item.nwdr.data.clinicalInfoList[3].value : '',
        "SBP": (item.nwdr) ? item.nwdr.data.clinicalInfoList[4].value : '',
        "DBP": (item.nwdr) ? item.nwdr.data.clinicalInfoList[5].value : '',
        "Other Examination": (item.nwdr) ? this._getOtherExamination(item.nwdr.data.clinicalInfoList) : '',
        // General Examination - end

        // Laboratory Investigation - start
        "HbA1c": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[0].value) ? (item.nwdr.data.laboratoryTestList[0].value + ' ' + item.nwdr.data.laboratoryTestList[0].unit) : '',
        "FPG": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[1].value) ? (item.nwdr.data.laboratoryTestList[1].value + ' ' + item.nwdr.data.laboratoryTestList[1].unit) : '',
        "2hPG": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[2].value) ? (item.nwdr.data.laboratoryTestList[2].value + ' ' + item.nwdr.data.laboratoryTestList[2].unit) : '',
        "Post Meal": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[3].value) ? (item.nwdr.data.laboratoryTestList[3].value + ' ' + item.nwdr.data.laboratoryTestList[3].unit) : '',
        "Urine Acetone": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[4].value) ? (item.nwdr.data.laboratoryTestList[4].value + ' ' + item.nwdr.data.laboratoryTestList[4].unit) : '',
        "Urine Albumin": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[5].value) ? (item.nwdr.data.laboratoryTestList[5].value + ' ' + item.nwdr.data.laboratoryTestList[5].unit) : '',
        "S. Creatinine": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[6].value) ? (item.nwdr.data.laboratoryTestList[6].value + ' ' + item.nwdr.data.laboratoryTestList[6].unit) : '',
        "SGPT": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[7].value) ? (item.nwdr.data.laboratoryTestList[7].value + ' ' + item.nwdr.data.laboratoryTestList[7].unit) : '',
        "HB": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[8].value) ? (item.nwdr.data.laboratoryTestList[8].value + ' ' + item.nwdr.data.laboratoryTestList[8].unit) : '',
        "ECG": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[9].value) ? (item.nwdr.data.laboratoryTestList[9].value + ' ' + item.nwdr.data.laboratoryTestList[9].unit) : '',
        "T.Chol": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[10].value) ? (item.nwdr.data.laboratoryTestList[10].value + ' ' + item.nwdr.data.laboratoryTestList[10].unit) : '',
        "LDL-C": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[11].value) ? (item.nwdr.data.laboratoryTestList[11].value + ' ' + item.nwdr.data.laboratoryTestList[11].unit) : '',
        "HDL-C": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[12].value) ? (item.nwdr.data.laboratoryTestList[12].value + ' ' + item.nwdr.data.laboratoryTestList[12].unit) : '',
        "Triglycerides": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length && item.nwdr.data.laboratoryTestList[13].value) ? (item.nwdr.data.laboratoryTestList[13].value + ' ' + item.nwdr.data.laboratoryTestList[13].unit) : '',
        "Other Investigation": (item.nwdr && item.nwdr.data && item.nwdr.data.laboratoryTestList.length) ? this._getOtherLabInvestigation(item.nwdr.data.laboratoryTestList) : '',
        // Laboratory Investigation - start

        // Complication - start
        "Hypogycemia": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[0].isSelected) ? 'Yes' : '',
        "DKA": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[1].isSelected) ? 'Yes' : '',
        "HHNS": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[2].isSelected) ? 'Yes' : '',

        "Neuropathy": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[3].isSelected) ? 'Yes' : '',
        "Nephropathy": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[4].isSelected) ? 'Yes' : '',
        "Retinopathy": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[5].isSelected) ? 'Yes' : '',

        "Cerebrovascular": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[6].isSelected) ? 'Yes' : '',
        "PVD": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[7].isSelected) ? 'Yes' : '',
        "CVD": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[8].isSelected) ? 'Yes' : '',

        "HTN": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[9].isSelected) ? 'Yes' : '',
        "Dyslipidaemia": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[10].isSelected) ? 'Yes' : '',
        "Gastro Complications": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[11].isSelected) ? 'Yes' : '',
        
        "Others": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length && item.nwdr.data.complicationList[12].isSelected) ? 'Yes' : '',

        "Other Complication": (item.nwdr && item.nwdr.data && item.nwdr.data.complicationList.length) ? this._getOtherComplicationList(item.nwdr.data.complicationList) : '',


        // Complication - end

        // Personal Habit(s) - start
        "Cigarette/Bidi": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? (item.nwdr.data.medicalInfo.drugAddictionList[0].isYes + " " + item.nwdr.data.medicalInfo.drugAddictionList[0].amount) : '',
        "Tobacco": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? (item.nwdr.data.medicalInfo.drugAddictionList[1].isYes + " " + item.nwdr.data.medicalInfo.drugAddictionList[1].amount) : '',
        "Betal Leaf/Betal Nut (Shupari)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? (item.nwdr.data.medicalInfo.drugAddictionList[2].isYes + " " + item.nwdr.data.medicalInfo.drugAddictionList[2].amount) : '',
        "Alcohol": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? (item.nwdr.data.medicalInfo.drugAddictionList[2].isYes + " " + item.nwdr.data.medicalInfo.drugAddictionList[2].amount) : '',
        "Others": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? (item.nwdr.data.medicalInfo.drugAddictionList[3].isYes + " " + item.nwdr.data.medicalInfo.drugAddictionList[3].amount) : '',
        "Other Personal Habit(s)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.drugAddictionList.length) ? this._getPersonalHabitList(item.nwdr.data.medicalInfo.drugAddictionList) : '',
        // Personal Habit(s) - end

        // Family History - start
        "Diabetes": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.familyHistoryList.length) ? item.nwdr.data.medicalInfo.familyHistoryList[0].value : '',
        "Hypertension": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.familyHistoryList.length) ? item.nwdr.data.medicalInfo.familyHistoryList[1].value : '',
        "Coronary Artery Disease": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.familyHistoryList.length) ? item.nwdr.data.medicalInfo.familyHistoryList[2].value : '',
        "Cerebro-Vascular Disease": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.familyHistoryList.length) ? item.nwdr.data.medicalInfo.familyHistoryList[3].value : '',
        "Other Family History": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.familyHistoryList.length) ? this._getOtherFamilyDiseaseList(item.nwdr.data.medicalInfo.familyHistoryList) : '',
        // Family History - end

        // Previous Advice - Dietary History - start
        "[Previous Adv.] Rice (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Rice', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Rice (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Rice (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Rice', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Rice (Calorie)": this._getCalorieByName('Rice', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Rice (Diet Chart)": this._getDietChartByName('Rice', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Ruti/Chapati (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Ruti/Chapati (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Ruti/Chapati (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Ruti/Chapati (Calorie)": this._getCalorieByName('Ruti/Chapati', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Ruti/Chapati (Diet Chart)": this._getDietChartByName('Ruti/Chapati', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Fish (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fish', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fish (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fish', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fish (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fish', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Fish (Calorie)": this._getCalorieByName('Fish', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Fish (Diet Chart)": this._getDietChartByName('Fish', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Meat (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Meat', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Meat (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Meat', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Meat (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Meat', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Meat (Calorie)": this._getCalorieByName('Meat', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Meat (Diet Chart)": this._getDietChartByName('Meat', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Green Vegetable (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Green Vegetable', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Green Vegetable (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Green Vegetable', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Green Vegetable (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Green Vegetable', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Green Vegetable (Calorie)": this._getCalorieByName('Green Vegetable', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Green Vegetable (Diet Chart)": this._getDietChartByName('Green Vegetable', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Fruits (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fruits', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fruits (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fruits', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fruits (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fruits', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Fruits (Calorie)": this._getCalorieByName('Fruits', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Fruits (Diet Chart)": this._getDietChartByName('Fruits', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Soft drinks (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Soft drinks', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Soft drinks (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Soft drinks', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Soft drinks (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Soft drinks', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Soft drinks (Calorie)": this._getCalorieByName('Soft drinks', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Soft drinks (Diet Chart)": this._getDietChartByName('Soft drinks', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Table Salt (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Table Salt', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Table Salt (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Table Salt', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Table Salt (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Table Salt', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Table Salt (Calorie)": this._getCalorieByName('Table Salt', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Table Salt (Diet Chart)": this._getDietChartByName('Table Salt', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Sweets (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Sweets', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Sweets (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Sweets', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Sweets (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Sweets', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Sweets (Calorie)": this._getCalorieByName('Sweets', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Sweets (Diet Chart)": this._getDietChartByName('Sweets', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Fast Foods (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fast Foods', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fast Foods (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fast Foods', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Fast Foods (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Fast Foods', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Fast Foods (Calorie)": this._getCalorieByName('Fast Foods', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Fast Foods (Diet Chart)": this._getDietChartByName('Fast Foods', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Ghee/butter (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ghee/butter', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Ghee/butter (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ghee/butter', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Ghee/butter (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Ghee/butter', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Ghee/butter (Calorie)": this._getCalorieByName('Ghee/butter', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Ghee/butter (Diet Chart)": this._getDietChartByName('Ghee/butter', item.nwdr.data.medicalInfo.dietaryHistoryList2),

        "[Previous Adv.] Hotel Food (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Hotel Food', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Hotel Food (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Hotel Food', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',
        "[Previous Adv.] Hotel Food (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList2.length) ? this.getDietaryHistoryByName('Hotel Food', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList2) : '',

        "[Previous Adv.] Hotel Food (Calorie)": this._getCalorieByName('Hotel Food', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        "[Previous Adv.] Hotel Food (Diet Chart)": this._getDietChartByName('Hotel Food', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        // "[Previous Adv.] Other Food List": this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList2),
        // Previous Advice - Dietary History - end

        // Previous Advice - Type of cooking oil - start
        "[Previous Adv.] Soyebean oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[0].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[0].amount : '',
        "[Previous Adv.] Mustard oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[1].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[1].amount : '',
        "[Previous Adv.] Palm oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[2].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[2].amount : '',
        "[Previous Adv.] [Previous Adv.] Olive oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[3].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[3].amount : '',
        "[Previous Adv.] Rice bran oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[4].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[4].amount : '',
        "[Previous Adv.] Other Oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList2.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList2[5].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList2[5].amount : '',
        // Previous Advice -Type of cooking oil - end

        
        "[Previous Adv.] Physical Activity": (item.nwdr && item.nwdr.data && item.nwdr.data.physicalActivityList2.length) ? this.getActivityList(item.nwdr.data.physicalActivityList2) : '',
        "[Previous Adv.] Medication": (item.nwdr && item.nwdr.data && item.nwdr.data.ogld2 &&item.nwdr.data.ogld2.ogldDrugList.length) ? this.getMedicationList(item.nwdr.data.ogld2.ogldDrugList) : '',

        // Previous Advice - Insulin - start
        "[Previous Adv.] Insulin Type": (item.nwdr && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinType) ? item.nwdr.data.insulin2.insulinType : '',

        "[Previous Adv.] Basal": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[0].drugName : '',
        "[Previous Adv.] Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[0].dosageList[0].value : '',
        "[Previous Adv.] Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[0].dosageList[1].value : '',
        "[Previous Adv.] Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[0].dosageList[2].value : '',

        "[Previous Adv.] Bolus": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[1].drugName : '',
        "[Previous Adv.] Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[1].dosageList[0].value : '',
        "[Previous Adv.] Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[1].dosageList[1].value : '',
        "[Previous Adv.] Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[1].dosageList[2].value : '',

        "[Previous Adv.] Premix": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[2].drugName : '',
        "[Previous Adv.] Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[2].dosageList[0].value : '',
        "[Previous Adv.] Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[2].dosageList[1].value : '',
        "[Previous Adv.] Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[2].dosageList[2].value : '',

        "[Previous Adv.] Other": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[3].drugName : '',
        "[Previous Adv.] Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[3].dosageList[0].value : '',
        "[Previous Adv.] Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[3].dosageList[1].value : '',
        "[Previous Adv.] Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin2 && item.nwdr.data.insulin2.insulinTherapyList.length) ? item.nwdr.data.insulin2.insulinTherapyList[3].dosageList[2].value : '',
        // Previous Advice -Insulin - end

        // Previous Advice - other Medication - start
        "[Previous Adv.] Anti HTN": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? item.nwdr.data.otherMedicationList2[0].isYes : '',
        "[Previous Adv.] Anti HTN Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList2[0].medicineList) : '',

        "[Previous Adv.] Anti lipids": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? item.nwdr.data.otherMedicationList2[1].isYes : '',
        "[Previous Adv.] Anti lipids Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList2[1].medicineList) : '',

        "[Previous Adv.] Aspirin": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? item.nwdr.data.otherMedicationList2[2].isYes : '',
        "[Previous Adv.] Aspirin Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList2[2].medicineList) : '',

        "[Previous Adv.] Anti-obesity": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? item.nwdr.data.otherMedicationList2[3].isYes : '',
        "[Previous Adv.] Anti-obesity Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList2[3].medicineList) : '',

        "[Previous Adv.] Other Medication?": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? item.nwdr.data.otherMedicationList2[4].isYes : '',
        "[Previous Adv.] Other Medication Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList2.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList2[4].medicineList) : '',
        // Previous Advice - other Medication - end

        // Current Advice - Dietary History - start
        "Rice (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Rice (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Rice (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Rice (Calorie)": this._getCalorieByName('Rice', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Rice (Diet Chart)": this._getDietChartByName('Rice', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Ruti/Chapati (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ruti/Chapati (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ruti/Chapati (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Ruti/Chapati (Calorie)": this._getCalorieByName('Ruti/Chapati', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Ruti/Chapati (Diet Chart)": this._getDietChartByName('Ruti/Chapati', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Fish (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fish (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fish (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fish (Calorie)": this._getCalorieByName('Fish', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Fish (Diet Chart)": this._getDietChartByName('Fish', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Meat (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Meat (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Meat (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Meat (Calorie)": this._getCalorieByName('Meat', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Meat (Diet Chart)": this._getDietChartByName('Meat', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Green Vegetable (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Green Vegetable (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Green Vegetable (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Green Vegetable (Calorie)": this._getCalorieByName('Green Vegetable', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Green Vegetable (Diet Chart)": this._getDietChartByName('Green Vegetable', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Fruits (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fruits (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fruits (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fruits (Calorie)": this._getCalorieByName('Fruits', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Fruits (Diet Chart)": this._getDietChartByName('Fruits', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Soft drinks (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Soft drinks (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Soft drinks (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Soft drinks (Calorie)": this._getCalorieByName('Soft drinks', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Soft drinks (Diet Chart)": this._getDietChartByName('Soft drinks', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Table Salt (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Table Salt (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Table Salt (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Table Salt (Calorie)": this._getCalorieByName('Table Salt', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Table Salt (Diet Chart)": this._getDietChartByName('Table Salt', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Sweets (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Sweets (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Sweets (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Sweets (Calorie)": this._getCalorieByName('Sweets', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Sweets (Diet Chart)": this._getDietChartByName('Sweets', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Fast Foods (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fast Foods (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fast Foods (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fast Foods (Calorie)": this._getCalorieByName('Fast Foods', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Fast Foods (Diet Chart)": this._getDietChartByName('Fast Foods', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Ghee/butter (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ghee/butter (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ghee/butter (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Ghee/butter (Calorie)": this._getCalorieByName('Ghee/butter', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Ghee/butter (Diet Chart)": this._getDietChartByName('Ghee/butter', item.nwdr.data.medicalInfo.dietaryHistoryList),

        "Hotel Food (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Hotel Food (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Hotel Food (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Hotel Food (Calorie)": this._getCalorieByName('Hotel Food', item.nwdr.data.medicalInfo.dietaryHistoryList),
        "Hotel Food (Diet Chart)": this._getDietChartByName('Hotel Food', item.nwdr.data.medicalInfo.dietaryHistoryList),
        
        // "Other Food List": this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList),
        // Current Advice - Dietary History - end

        // Current Advice - Type of cooking oil - start
        "Soyebean oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[0].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[0].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[0].unit : '',
        "Mustard oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[1].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[1].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[1].unit : '',
        "Palm oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[2].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[2].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[2].unit : '',
        "Olive oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[3].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[3].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[3].unit : '',
        "Rice bran oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[4].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[4].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[4].unit : '',
        "Other Oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[5].isYes + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[5].amount + " " + item.nwdr.data.medicalInfo.typeOfCookingOilList[5].unit : '',
        // Current Advice -Type of cooking oil - end

        
        "Physical Activity": (item.nwdr && item.nwdr.data && item.nwdr.data.physicalActivityList.length) ? this.getActivityList(item.nwdr.data.physicalActivityList) : '',
        "Medication": (item.nwdr && item.nwdr.data && item.nwdr.data.ogld2 &&item.nwdr.data.ogld2.ogldDrugList.length) ? this.getMedicationList(item.nwdr.data.ogld2.ogldDrugList) : '',

        // Current Advice - Insulin - start
        "Insulin Type": (item.nwdr && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinType) ? item.nwdr.data.insulin.insulinType : '',

        "Basal": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[2].value : '',

        "Bolus": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[2].value : '',

        "Premix": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[2].value : '',

        "Other": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[2].value : '',
        // Current Advice -Insulin - end

        // Current Advice - other Medication - start
        "Anti HTN": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[0].isYes : '',
        "Anti HTN Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[0].medicineList) : '',

        "Anti lipids": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[1].isYes : '',
        "Anti lipids Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[1].medicineList) : '',

        "Aspirin": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[2].isYes : '',
        "Aspirin Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[2].medicineList) : '',

        "Anti-obesity": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[3].isYes : '',
        "Anti-obesity Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[3].medicineList) : '',

        "Other Medication?": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[4].isYes : '',
        "Other Medication Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[4].medicineList) : '',
        // Current Advice - other Medication - end

        // Current Advice - Dietary History - start
        "Rice (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Rice (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Rice (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Rice', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Ruti/Chapati (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ruti/Chapati (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ruti/Chapati (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ruti/Chapati', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fish (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fish (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fish (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fish', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Meat (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Meat (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Meat (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Meat', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Green Vegetable (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Green Vegetable (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Green Vegetable (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Green Vegetable', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fruits (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList.length) : '',
        "Fruits (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList.length) : '',
        "Fruits (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fruits', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList.length) : '',

        "Soft drinks (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Soft drinks (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Soft drinks (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Soft drinks', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Table Salt (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Table Salt (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Table Salt (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Table Salt', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Sweets (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Sweets (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Sweets (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Sweets', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Fast Foods (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fast Foods (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Fast Foods (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Fast Foods', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Ghee/butter (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ghee/butter (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Ghee/butter (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Ghee/butter', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',

        "Hotel Food (daily)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'daily', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Hotel Food (weekly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        "Hotel Food (monthly)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.dietaryHistoryList.length) ? this.getDietaryHistoryByName('Hotel Food', 'monthly', item.nwdr.data.medicalInfo.dietaryHistoryList) : '',
        
        // "Other Food List": this.getDietaryHistoryByName('Rice', 'weekly', item.nwdr.data.medicalInfo.dietaryHistoryList),
        // Current Advice - Dietary History - end

        // Current Advice - Type of cooking oil - start
        "Soyebean oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[0].amount : '',
        "Mustard oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[1].amount : '',
        "Palm oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[2].amount : '',
        "Olive oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[3].amount : '',
        "Rice bran oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[4].amount : '',
        "Other Oil (litr)": (item.nwdr && item.nwdr.data && item.nwdr.data.medicalInfo && item.nwdr.data.medicalInfo.typeOfCookingOilList.length) ? item.nwdr.data.medicalInfo.typeOfCookingOilList[5].amount : '',
        // Current Advice -Type of cooking oil - end

        
        "Physical Activity": (item.nwdr && item.nwdr.data && item.nwdr.data.physicalActivityList2.length) ? this.getActivityList(item.nwdr.data.physicalActivityList2) : '',
        "Medication": (item.nwdr && item.nwdr.data && item.nwdr.data.ogld2 &&item.nwdr.data.ogld2.ogldDrugList.length) ? this.getMedicationList(item.nwdr.data.ogld2.ogldDrugList) : '',

        // Current Advice - Insulin - start
        "Insulin Type": (item.nwdr && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinType) ? item.nwdr.data.insulin.insulinType : '',

        "Basal": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[0].dosageList[2].value : '',

        "Bolus": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[1].dosageList[2].value : '',

        "Premix": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[2].dosageList[2].value : '',

        "Other": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].drugName : '',
        "Morning": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[0].value : '',
        "Noon": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[1].value : '',
        "Night": (item.nwdr && item.nwdr.data && item.nwdr.data.insulin && item.nwdr.data.insulin.insulinTherapyList.length) ? item.nwdr.data.insulin.insulinTherapyList[3].dosageList[2].value : '',
        // Current Advice -Insulin - end

        // Current Advice - other Medication - start
        "Anti HTN": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[0].isYes : '',
        "Anti HTN Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[0].medicineList) : '',

        "Anti lipids": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[1].isYes : '',
        "Anti lipids Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[1].medicineList) : '',

        "Aspirin": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[2].isYes : '',
        "Aspirin Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[2].medicineList) : '',

        "Anti-obesity": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[3].isYes : '',
        "Anti-obesity Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[3].medicineList) : '',

        "Other Medication?": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? item.nwdr.data.otherMedicationList[4].isYes : '',
        "Other Medication Dosage": (item.nwdr && item.nwdr.data && item.nwdr.data.otherMedicationList.length) ? this._getAllAntiMedicineList(item.nwdr.data.otherMedicationList[4].medicineList) : '',
        // Current Advice - other Medication - end
        
        
      };

      // console.log (object);

      return object;
    })
  },

  _checkForDiabetic (diabeticStatus) {
    if (diabeticStatus == 'Diabetic') {
      return true;
    } else {
      return false;
    }
  },

  _getAllAntiMedicineList(list) {
    // console.log(list);
    if (!(typeof list == 'undefined')) {
      if (list.length) {
        string = '';
        list.forEach(function(item) {
          if (item.name) 
            string += item.name + ': ' + item.dose + ", ";
        });
      }
      return string;
    } else
      return '';
    
    
  },

  _preparePatientJsonData(rawReport) {
    return rawReport.map((item) => {
      return {
        'Organization': (item.orgName) ? item.orgName : '',
        'Serial': (item.serial) ? item.serial : '',
        'Patient ID': (item.nwdrPatientId) ? item.nwdrPatientId : '',
        'Created Date & Time': this.$formatDateTime(item.cratedDatetimeStamp),
        'Name': (item.name) ? item.name : '',
        'Email Address': (item.email) ? item.email : '',
        'Contact Number': (item.phone) ? item.phone : '',
        'Additional Contact Number': (item.additionalPhone) ? item.additionalPhone : '',
        'Date of Birth (mm/dd/yyyy)': (item.dateOfBirth) ? item.dateOfBirth : '',
        'Age': (item.dateOfBirth) ? this.$computeAge(item.dateOfBirth) : '',
        'Spouse Name': (item.patientSpouseName) ? item.patientSpouseName : '',
        "Father's Name": (item.patientFatherName) ? item.patientFatherName : '',
        "Mother's Name": (item.patientMotherName) ? item.patientMotherName : '',
        "Expenditure": (item.expenditure) ? item.expenditure : '',
        "Profession": (item.profession) ? item.profession : '',
        "National ID": (item.nationalIdCardNumber) ? item.nationalIdCardNumber : '',
        "Division": (item.addressDivision) ? item.addressDivision : '',
        "District": (item.addressDistrict) ? item.addressDistrict : '',
        "Area":(item.addressArea) ? item.addressArea : '',
        "Marital Status": (item.maritalStatus) ? item.maritalStatus : '',
        "Marital Age": (item.maritalAge) ? item.maritalAge : '',
        "Number of Family Member": (item.numberOfFamilyMember) ? item.numberOfFamilyMember : '',
        "Number of children": (item.numberOfChildren) ? item.numberOfChildren : '',
        "Blood Group": (item.bloodGroup) ? item.bloodGroup : '',
        "Have Allergy?": (item.allergy) ? item.allergy : ''        
      }
    })
  },

  downloadCsv(csv, exportedFilenmae) {
    // var exportedFilenmae = 'nwdr-report-export.csv';
    var blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement("a");
    var url = URL.createObjectURL(blob);
    link.setAttribute("href", url);
    link.setAttribute("download", exportedFilenmae);
    link.style.visibility = 'hidden';
    link.target = '_blank'
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

  },

  exportButtonClicked() {

    

    data = null

    if (this.selectedPageIndex == 0) {
      if (!this.reportResults.length) return this.domHost.showModalDialog('Search for a Report First!')
      else {
        data = this._prepareNwdrJsonData(this.reportResults);
      }
    }

    else if (this.selectedPageIndex == 1) {
      if (!this.matchingPatientList.length) return this.domHost.showModalDialog('Search for a Patient First!')
      else {
        data = this._preparePatientJsonData(this.matchingPatientList);
      }
    }
    
    const preppedData = data;
    const csvString = Papa.unparse(preppedData);

    if (this.selectedPageIndex == 0)
      this.downloadCsv(csvString, 'nwdr-report-export.csv');
    else
      this.downloadCsv(csvString, 'patient-list-export.csv');
    
  }

});