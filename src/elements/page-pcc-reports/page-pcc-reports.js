Polymer({

  is: 'page-pcc-reports',

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

  onPageChange() {
    console.log(this.selectedPageIndex);
  },

  isEmptyArray(length) {
    if (length == 0)
      return true;
    else
      return false;
  },

  $getList(list) {
    console.log(list);
    return list;
  },

  onItemDeleteBtnPressed(e) {
    index = e.model.index;
    console.log(index);
    serial = this.reportResults[index].pcc.serial;
    this._callDeleteRecordApi(serial, index);

  },

  _callDeleteRecordApi(recordIdentifier, index) {
    const query = {
      apiKey: this.user.apiKey,
      recordSerial: recordIdentifier
    }
    this.callApi('/delete-selected-pcc-records', query, (err, response) => {
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

  _checkIfDiabetic(data) {
    if ((data == 'undefined') || (data == null) || (data == 'Non-Diabetic')) {
      return false;
    } else if (data == 'Diabetic') {
      return true;
    } else {
      return false;
    }

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
        this.push('childOrganizationList', { label: this.organization.name, value: this.organization.idOnServer });
        // this.domHost.showToast('No Child Organization Found')
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
    if (index == 0) {
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
      // organizationIdList = this.childOrganizationList.map(item => item.value);
      // organizationIdList.splice(0, 1);

      // query.organizationIdList = organizationIdList;
      // query.organizationIdList.push(this.organization.idOnServer);

      query.organizationIdList = []


    } else {
      query.organizationIdList = [this.selectedOrganizationId];
    }

    if (this.selectedPageIndex == 0) {
      this._callGetAllPccReportApi(query);
    }

    else if (this.selectedPageIndex == 1) {
      this._callGetOrganizationAllPatientListApi(query);
    }
  },

  _callGetAllPccReportApi(query) {

    this.loading = true;
    this.callApi('/get-all-pcc-report', query, (err, response) => {
      console.log(response);
      if (response.hasError) {
        this.domHost.showModalDialog(response.error.message);
        return this.loading = false;
      } else {
        this.set('reportResults', response.data);
        // var counter = 0;
        // this.reportResults.forEach(function (item){
        //   console.log("item:", counter++, ", length: ", item.pcc.medicalInfo.typeOfCookingOilList.length);
        // });

        this.loading = false;
      }
    });
  },

  _callGetOrganizationAllPatientListApi(query) {

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

  getActivityList(list) {

    string = '';

    if (list) {

      if (list.length > 0) {
        list.forEach(function (item) {
          string += (item.name + ': ' + item.duration + item.unit);
        });
      }
    }

    return string;
  },

  _preparePccJsonData(rawReport) {
    return rawReport.map((item) => {
      var object = {
        'Record ID': (item.pcc && item.pcc.serial) ? item.pcc.serial : '',
        'Created Date': (item.pcc && item.pcc.createdDatetimeStamp) ? this.$formatDateTime(item.pcc.createdDatetimeStamp) : '',
        'Organization': (item.pcc && item.pcc.centerInfo && item.pcc.centerInfo.centerName) ? item.pcc.centerInfo.centerName : '',
        'Record ID': (item.pcc && item.pcc.serial) ? item.pcc.serial : '',
        'Visit Type': (item.pcc && item.pcc.visitReason && item.pcc.visitReason.type) ? item.pcc.visitReason.type : '',
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
        "Area": (item.patientInfo && item.patientInfo.addressArea) ? item.patientInfo.addressArea : '',
        "Marital Status": (item.patientInfo && item.patientInfo.maritalStatus) ? item.patientInfo.maritalStatus : '',
        "Marital Age": (item.patientInfo && item.patientInfo.maritalAge) ? item.patientInfo.maritalAge : '',
        "Number of Family Member": (item.patientInfo && item.patientInfo.numberOfFamilyMember) ? item.patientInfo.numberOfFamilyMember : '',
        "Number of children": (item.patientInfo && item.patientInfo.numberOfChildren) ? item.patientInfo.numberOfChildren : '',

        "How did you find out about this project?": (item.pccOthers && item.pccOthers.survey.length && item.pccOthers.survey[0].answer) ? item.pccOthers.survey[0].answer : '',
        "Blood Group.": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length) ? item.pcc.clinical.labReportsList[3].value : '',
        "Have Allergy?": (item.patientInfo && item.patientInfo.allergy) ? item.patientInfo.allergy : '',

        "Tetanus": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.vaccinationList.length && item.pcc.medicalInfo.vaccinationList[0].value) ? item.pcc.medicalInfo.vaccinationList[0].value : '',
        "MMR": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.vaccinationList.length && item.pcc.medicalInfo.vaccinationList[1] && item.pcc.medicalInfo.vaccinationList[1].value) ? item.pcc.medicalInfo.vaccinationList[1].value : '',
        "Varicella": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.vaccinationList.length && item.pcc.medicalInfo.vaccinationList[2] && item.pcc.medicalInfo.vaccinationList[2].value) ? item.pcc.medicalInfo.vaccinationList[2].value : '',
        "Hepatitis": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.vaccinationList.length && item.pcc.medicalInfo.vaccinationList[3] && item.pcc.medicalInfo.vaccinationList[3].value) ? item.pcc.medicalInfo.vaccinationList[3].value : '',

        "Previous Preconception Care": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.didPreviousPreconceptionCare) ? item.pcc.medicalInfo.didPreviousPreconceptionCare : '',
        "Have Family Planning": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.familyPlanning && item.pcc.medicalInfo.familyPlanning.haveFamilyPlanning) ? item.pcc.medicalInfo.familyPlanning.haveFamilyPlanning : '',

        "Cigarette Smoking  ": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.drugAddictionList.length && item.pcc.medicalInfo.drugAddictionList[0] && item.pcc.medicalInfo.drugAddictionList[0].amount) ? item.pcc.medicalInfo.drugAddictionList[0].amount : '',
        "Tobacco leaf": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.drugAddictionList.length && item.pcc.medicalInfo.drugAddictionList[1] && item.pcc.medicalInfo.drugAddictionList[1].amount) ? item.pcc.medicalInfo.drugAddictionList[1].amount : '',

        "Betel leaf": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.drugAddictionList.length && item.pcc.medicalInfo.drugAddictionList[2] && item.pcc.medicalInfo.drugAddictionList[2].amount) ? item.pcc.medicalInfo.drugAddictionList[2].amount : '',
        "Alcohol": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.drugAddictionList.length && item.pcc.medicalInfo.drugAddictionList[3] && item.pcc.medicalInfo.drugAddictionList[3].amount) ? item.pcc.medicalInfo.drugAddictionList[3].amount : '',
        "Others": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.drugAddictionList.length && item.pcc.medicalInfo.drugAddictionList[4] && item.pcc.medicalInfo.drugAddictionList[4].amount) ? item.pcc.medicalInfo.drugAddictionList[4].amount : '',

        "Physical Activity": (item.pcc) ? this.getActivityList(item.pcc.physicalActivityList) : '',
        "Watching TV (min)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.otherActivityList.length && item.pcc.medicalInfo.otherActivityList[0] && item.pcc.medicalInfo.otherActivityList[0].duration) ? item.pcc.medicalInfo.otherActivityList[0].duration : '',
        "Sleeping (hrs)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.otherActivityList.length && item.pcc.medicalInfo.otherActivityList[1].duration) ? item.pcc.medicalInfo.otherActivityList[1].duration : '',

        "Rice (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length && item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount.length && item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[0].value) ? item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[0].value : '',

        "Rice (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length && item.pcc.medicalInfo.dietaryHistoryList[0] && item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount.length && item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[1].value) ? item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[1].value : '',

        "Rice (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length && item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[2].value) ? item.pcc.medicalInfo.dietaryHistoryList[0].consumeAmount[2].value : '',

        "Ruti/Chapati (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[1].consumeAmount[0].value : '',
        "Ruti/Chapati (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[1].consumeAmount[1].value : '',
        "Ruti/Chapati (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[1].consumeAmount[2].value : '',

        "Fish (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[2].consumeAmount[0].value : '',
        "Fish (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[2].consumeAmount[1].value : '',
        "Fish (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[2].consumeAmount[2].value : '',

        "Meat (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[3].consumeAmount[0].value : '',
        "Meat (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[3].consumeAmount[1].value : '',
        "Meat (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.lengthc) ? item.pcc.medicalInfo.dietaryHistoryList[3].consumeAmount[2].value : '',

        "Green Vegetable (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[4].consumeAmount[0].value : '',
        "Green Vegetable (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[4].consumeAmount[1].value : '',
        "Green Vegetable (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[4].consumeAmount[2].value : '',

        "Fruits (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[5].consumeAmount[0].value : '',
        "Fruits (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[5].consumeAmount[1].value : '',
        "Fruits (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[5].consumeAmount[2].value : '',

        "Soft drinks (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[6].consumeAmount[0].value : '',
        "Soft drinks (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[6].consumeAmount[1].value : '',
        "Soft drinks (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[6].consumeAmount[2].value : '',

        "Table Salt (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[7].consumeAmount[0].value : '',
        "Table Salt (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[7].consumeAmount[1].value : '',
        "Table Salt (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[7].consumeAmount[2].value : '',


        "Sweets (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[8].consumeAmount[0].value : '',
        "Sweets (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[8].consumeAmount[1].value : '',
        "Sweets (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[8].consumeAmount[2].value : '',

        "Fast Foods (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[9].consumeAmount[0].value : '',
        "Fast Foods (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[9].consumeAmount[1].value : '',
        "Fast Foods (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[9].consumeAmount[2].value : '',

        "Ghee/butter (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[10].consumeAmount[0].value : '',
        "Ghee/butter (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[10].consumeAmount[1].value : '',
        "Ghee/butter (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[10].consumeAmount[2].value : '',

        "Hotel Food (daily)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[11].consumeAmount[0].value : '',
        "Hotel Food (weekly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[11].consumeAmount[1].value : '',
        "Hotel Food (yearly)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.dietaryHistoryList.length) ? item.pcc.medicalInfo.dietaryHistoryList[11].consumeAmount[2].value : '',

        "Soyebean oil (litr)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.typeOfCookingOilList.length) ? item.pcc.medicalInfo.typeOfCookingOilList[0].amount : '',
        "Mustard oil (litr)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.typeOfCookingOilList.length) ? item.pcc.medicalInfo.typeOfCookingOilList[1].amount : '',
        "Palm oil (litr)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.typeOfCookingOilList.length) ? item.pcc.medicalInfo.typeOfCookingOilList[2].amount : '',
        "Olive oil (litr)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.typeOfCookingOilList.length) ? item.pcc.medicalInfo.typeOfCookingOilList[3].amount : '',
        "Rice bran oil (litr)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.typeOfCookingOilList.length) ? item.pcc.medicalInfo.typeOfCookingOilList[4].amount : '',

        "Diabetes_": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[0].value : '',
        "Pregnancy diabetes ": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[1].value : '',
        "Hypertension_": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[2].value : '',
        "Heart disease_": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[3].value : '',
        "Asthma": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[4].value : '',
        "Tuberculosis": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[5].value : '',
        "Mental disorder": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[6].value : '',
        "Preeclampsia": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[7].value : '',
        "Eclampsia": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[8].value : '',
        "Still-Birth": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[9].value : '',
        "Pre-term ( less than 37 weeks )": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[10].value : '',
        "Macrosomia (Large Baby >4kg)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[11].value : '',
        "LBW (Small Baby bellow 2.5kg)": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[12].value : '',
        "Pre-term ( less than 37 weeks )": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[13].value : '',
        "IUD": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfDeseaseList.length) ? item.pcc.medicalInfo.historyOfDeseaseList[14].value : '',

        "On Insulin": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfMedicationList.length) ? item.pcc.medicalInfo.historyOfMedicationList[0].type : '',
        "OADs": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfMedicationList.length) ? item.pcc.medicalInfo.historyOfMedicationList[1].type : '',
        "Anti HTN_": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfMedicationList.length) ? item.pcc.medicalInfo.historyOfMedicationList[2].type : '',
        "Anti lipids_": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfMedicationList.length) ? item.pcc.medicalInfo.historyOfMedicationList[3].type : '',
        "Cardiac Medication": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.historyOfMedicationList.length && item.pcc.medicalInfo.historyOfMedicationList[4]) ? item.pcc.medicalInfo.historyOfMedicationList[4].value : '',

        "Diabetes": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.familyHistoryList.length && item.pcc.medicalInfo.familyHistoryList[0].value) ? item.pcc.medicalInfo.familyHistoryList[0].value : '',
        "Hypertension": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.familyHistoryList.length && item.pcc.medicalInfo.familyHistoryList[1].value) ? item.pcc.medicalInfo.familyHistoryList[1].value : '',
        "Heart disease": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.familyHistoryList.length && item.pcc.medicalInfo.familyHistoryList[2].value) ? item.pcc.medicalInfo.familyHistoryList[2].value : '',
        "Stroke": (item.pcc && item.pcc.medicalInfo && item.pcc.medicalInfo.familyHistoryList.length && item.pcc.medicalInfo.familyHistoryList[3].value) ? item.pcc.medicalInfo.familyHistoryList[3].value : '',

        "(Mother) Birth Weight": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[0].value : '',
        "(Mother) Height": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[1].value : '',
        "(Mother) Weight": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[2].value : '',
        "BMI": (item.pcc && item.pcc.computedData) ? this.$toTwoDecimalPlace(item.pcc.computedData.bmi.results) : '',
        "BMI Status": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.bmi.comment : '',

        "(Mother) Ideal Weight": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.idealWeight : '',
        "(Mother) Calorie": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.estimateCaloriesIntake : '',
        "(Mother) Food Chart": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.foodChartName : '',

        "(Mother) Waist": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[3].value : '',
        "(Mother) Hip": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[4].value : '',

        "(Mother) Waist-Hip Ratio": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.waistHipRatio.value : '',
        "(Mother) Waist-Hip Status": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.waistHipRatio.comment : '',

        "(Mother) SBP ": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[5].value : '',
        "(Mother) DBP": (item.pcc && item.pcc.clinical && item.pcc.clinical.clinicalExaminationList.length) ? item.pcc.clinical.clinicalExaminationList[6].value : '',
        "(Mother) Hypertension Type": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.hypertension.type : '',
        "(Mother) Comment": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.hypertension.comment : '',

        "Diabetic FPG": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length && this._checkIfDiabetic(item.pcc.clinical.diabeticStatus)) ? (item.pcc.clinical.labReportsList[0].value) : '',
        "Diabetic Post Meal": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length && this._checkIfDiabetic(item.pcc.clinical.diabeticStatus)) ? item.pcc.clinical.labReportsList[1].value : '',
        "Diabetic Status": (item.pcc && item.pcc.computedData && (this._checkIfDiabetic(item.pcc.clinical.diabeticStatus))) ? (item.pcc.computedData.glycemiaType.additionalMsg) : '',
        "Non-Diabetic FPG": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length && (!this._checkIfDiabetic(item.pcc.clinical.diabeticStatus))) ? item.pcc.clinical.labReportsList[0].value : '',
        "Non-Diabetic 2hPG": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length && (!this._checkIfDiabetic(item.pcc.clinical.diabeticStatus))) ? item.pcc.clinical.labReportsList[1].value : '',
        "Non-Diabetic Status": (item.pcc && item.pcc.computedData && (!this._checkIfDiabetic(item.pcc.clinical.diabeticStatus))) ? item.pcc.computedData.glycemiaType.value : '',

        "Hb": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length) ? item.pcc.clinical.labReportsList[2].value : '',

        "Hb Status": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.hbStatus : '',

        "Blood Group": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length) ? item.pcc.clinical.labReportsList[3].value : '',

        "Urine Albumin": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length) ? item.pcc.clinical.labReportsList[4].value : '',
        "Urine Albumin Status": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.albuminType : '',
        "Urine Pus cell": (item.pcc && item.pcc.clinical && item.pcc.clinical.labReportsList.length) ? item.pcc.clinical.labReportsList[5].value : '',
        "Urine Pus cell Status": (item.pcc && item.pcc.computedData) ? item.pcc.computedData.urinePusCellStatus : '',

        "Appropriate medical advice before pregnancy may reduce the risk of diabetes,gestational diabetes (diabetes during pregnancy) and heart problems": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[0] && item.pcc.pccOthers.questionList[0].value) ? item.pcc.pccOthers.questionList[0].value : '',

        "Every married woman should take the following vaccinations before pregnancy: Tetanus, Measles, Mumps, Rubella, Chicken Pox, Hepatitis-B, if not taken previously": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[1] && item.pcc.pccOthers.questionList[1].value) ? item.pcc.pccOthers.questionList[1].value : '',

        "Before pregnancy every women should know their blood group": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[2] && item.pcc.pccOthers.questionList[2].value) ? item.pcc.pccOthers.questionList[2].value : '',

        "People who are overweight and have family members with diabetes are most likely to get diabetes (by family members only parents, siblings and grandparents are implied)": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[3] && item.pcc.pccOthers.questionList[3].value) ? item.pcc.pccOthers.questionList[3].value : '',

        "Uncontrolled gestational diabetes (diabetes during pregnancy) may create complications for the mother and child": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[4] && item.pcc.pccOthers.questionList[4].value) ? item.pcc.pccOthers.questionList[4].value : '',

        "Overeating and less physical activity are among the many causes for overweight and obesity": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[5] && item.pcc.pccOthers.questionList[5].value) ? item.pcc.pccOthers.questionList[5].value : '',

        "Low Hemoglobin Level (Anemia) increases the risk of complications before and after pregnancy": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[6] && item.pcc.pccOthers.questionList[6].value) ? item.pcc.pccOthers.questionList[6].value : '',

        "Stroke, heart problems, kidney and respiratory disorders may be caused by high blood pressure": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[7] && item.pcc.pccOthers.questionList[7].value) ? item.pcc.pccOthers.questionList[7].value : '',

        "The condition where pregnant women with blood pressure, experience convulsions/fit is called Eclampsia": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[8] && item.pcc.pccOthers.questionList[8].value) ? item.pcc.pccOthers.questionList[8].value : '',

        "If Urinary Tract Infection (infection related with urine & bladder) is not treated properly before/during pregnancy, the risk of underweight childbirth and premature baby increases": (item.pcc && item.pcc.pccOthers && item.pcc.pccOthers.questionList.length && item.pcc.pccOthers.questionList[9] && item.pcc.pccOthers.questionList[9].value) ? item.pcc.pccOthers.questionList[9].value : '',

        "Lifestyle": (item.pcc && item.pcc.medicalManagement.lifeStyleType && item.pcc.medicalManagement && item.pcc.medicalManagement.lifeStyleType) ? item.pcc.medicalManagement.lifeStyleType : '',

        "Oral anti-diabetics (OADs)": (item.pcc && item.pcc.medicalManagement && item.pcc.medicalManagement.medicationList.length && item.pcc.medicalManagement.medicationList[0].list.length && item.pcc.medicalManagement.medicationList[0].list[0].value) ? item.pcc.medicalManagement.medicationList[0].list[0].value : '',

        "Insulin": (item.pcc && item.pcc.medicalManagement && item.pcc.medicalManagement.medicationList.length && item.pcc.medicalManagement.medicationList[1].list.length && item.pcc.medicalManagement.medicationList[1].list[0].value) ? (item.pcc.medicalManagement.medicationList[1].list[0].value + " " + item.pcc.medicalManagement.medicationList[1].list[0].typeOfDevice) : '',

        "Anti HTN": (item.pcc && item.pcc.medicalManagement) ? (item.pcc.medicalManagement.medicationList[2].list[1].isYes) : '',
        "Anti HTN Dosage": (item.pcc && item.pcc.medicalManagement) ? this._getAllAntiMedicineList(item.pcc.medicalManagement.medicationList[2].list[2].medicineList) : '',

        "Anti lipids": (item.pcc && item.pcc.medicalManagement) ? (item.pcc.medicalManagement.medicationList[2].list[2].isYes) : '',

        "Anti lipids Dosage": (item.pcc && item.pcc.medicalManagement) ? this._getAllAntiMedicineList(item.pcc.medicalManagement.medicationList[2].list[2].medicineList) : '',

        "Anti-obesity": (item.pcc && item.pcc.medicalManagement) ? (item.pcc.medicalManagement.medicationList[2].list[3].isYes) : '',

        "Anti-obesity Dosage": (item.pcc && item.pcc.medicalManagement) ? this._getAllAntiMedicineList(item.pcc.medicalManagement.medicationList[2].list[3].medicineList) : ''

      };

      // console.log (object);

      return object;
    })
  },

  // _checkForDiabetic (diabeticStatus) {
  //   if (diabeticStatus == 'Diabetic') {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // },

  _getAllAntiMedicineList(list) {
    console.log(list);
    if (!(typeof list == 'undefined')) {
      if (list.length) {
        string = '';
        list.forEach(function (item) {
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
        'Patient ID': (item.pccPatientId) ? item.pccPatientId : '',
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
        "Area": (item.addressArea) ? item.addressArea : '',
        "Marital Status": (item.maritalStatus) ? item.maritalStatus : '',
        "Marital Age": (item.maritalAge) ? item.maritalAge : '',
        "Number of Family Member": (item.numberOfFamilyMember) ? item.numberOfFamilyMember : '',
        "Number of children": (item.numberOfChildren) ? item.numberOfChildren : '',
        "Blood Group": (item.bloodGroup) ? item.bloodGroup : '',
        "Have Allergy?": (item.allergy) ? item.allergy : '',


      }
    })
  },

  downloadCsv(csv, exportedFilenmae) {
    // var exportedFilenmae = 'pcc-report-export.csv';
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
        data = this._preparePccJsonData(this.reportResults);
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
      this.downloadCsv(csvString, 'pcc-report-export.csv');
    else
      this.downloadCsv(csvString, 'patient-list-export.csv');

  }

});