
Polymer({
  is: 'page-accounts-salary-creator',
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
    employeeList: Array,
    departmentList: Array,
    designationList: Array,
    salary: {
      type: Object,
      value: {}
    },
    salarySheet: {
      type: Object,
      value: {}
    },
    invoice: {
      type: Object,
      value: {}
    },
    totalSalaryExpense: Number,
    providentFundAmount: Number,
    loading: {
      type: Boolean,
      value: false
    }

  },

  observers: [
    'calculateTotalSalaryExpense(salarySheet.data.splices)',
    'salaryObjectPropertyChanged(salary.*)'
  ],


  navigatedIn() {
    const params = this.domHost.getPageParams()
    let { organization, salary } = params;
    this._loadUser();
    if (organization) {
      this._loadOrganization(organization, () => {
        this._loadEmployeeList(this.organization.idOnServer)
        this._makeNewSalaryExpenseInvoice()
        if (salary === 'new') {
          this._makeNewSalarySheet()
        } else {
          this._loadSalarySheet(salary)
        }
        
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

  _makeNewSalaryExpenseInvoice() {
    const expense = {
      serial: '',
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      modificationHistory: [],
      lastModifiedDatetimeStamp: null,
      invoiceType: 'salary',
      category: 'Salary',
      totalBilled: 0,
      discount: 0,
      vatOrTax: 0,
      totalAmountPaid: 0,
      flags: {
        flagAsError: false,
        markAsCompleted: false
      },
      data: []
    };
    return this.set('expense', expense);
  },

  _loadEmployeeList(organizationIdentifier) {
    const query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.loading = true;
    this.callApi('/bdemr-organization-get-employee-list-with-salary', query, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (response.data.length) {
        this.set('employeeList', response.data);
      }
    })
  },

  _loadDepartmentList(organizationIdentifier) {
    const query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.loading = true;
    this.callApi('/bdemr--organizations-get-department-list', query, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (response.data.length) {
        this.set('departmentList', response.data);
      }
    })
  },

  _loadDesignationList(organizationIdentifier) {
    const query = {
      apiKey: this.user.apiKey,
      organizationId: organizationIdentifier
    }
    this.loading = true;
    this.callApi('/bdemr--organizations-get-designation-list', query, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      if (response.data.length) {
        this.set('designationList', response.data);
      }
    })
  },

  getDepartment(departmentId) {
    let department = this.departmentList.find(item => item._id === departmentId)
    return department ? department.name : ''
  },

  getDesignation(designationId) {
    let designation = this.designationList.find(item => item._id === designationId)
    return designation ? designation.name : ''
  },

  _makeNewSalarySheet() {
    const salarySheet = {
      createdDatetimeStamp: lib.datetime.now(),
      createdByUserSerial: this.user.serial,
      organizationId: this.organization.idOnServer,
      lastModifiedDatetimeStamp: lib.datetime.now(),
      data: [],
      totalSalaryExpense: 0
    }
    this.set('salarySheet', salarySheet)
  },

  _loadSalarySheet(salarySheetIdentifier) {
    this.loading = true;
    this.callApi('/bdemr-organization-get-salary-sheet', { apiKey: this.user.apiKey, id: salarySheetIdentifier }, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      let salarySheet = response.data[0];
      this._makeNewSalarySheet()
      salarySheet.data.forEach((item) => {
        this.push('salarySheet.data', item);
      })

    })
  },




  getTotal(unitPrice = 0, unit = 1) {
    return parseInt(unitPrice) * parseInt(unit);
  },

  paySalaryButtonClicked(e) {
    const item = e.model.item;
    let salary = Object.assign({
      employeeSerial: item.serial,
      employeeId: item.employeeId,
      employeeName: item.name,
      employeeMobile: item.mobile,
      designationId: item.designationId,
      departmentId: item.departmentId,
      salaryUnit: 1,
      dues: 0,
      advances: 0,
      advanceDeduction: 0
    }, item.salaryTemplate);
    this.set('salary', salary);
    console.log(this.salary)
    this.$$('#salaryEditorDialog').toggle();
  },

  addSalaryButtonClicked() {
    if (!this.salary.salaryUnit) {
      return this.domHost.showModalDialog('Please specify a salary unit')
    }
    if (this.salarySheet.data.findIndex(item => item.employeeSerial === this.salary.employeeSerial) > -1) {
      this.$$('#salaryEditorDialog').toggle()
      return this.domHost.showModalDialog('Already Added')
    }
    this.salary.grossSalary = this.getGrossSalary(this.salary);
    this.salary.totalDeductibles = this.getSalaryDeductibles(this.salary);
    this.salary.netSalary = this.salary.grossSalary - this.salary.totalDeductibles
    this.salary.providentFundAmount = this.providentFundAmount
    console.log(this.salary)    
    this.push('salarySheet.data', this.salary);
    this.$$('#salaryEditorDialog').toggle()
    this.set('salary', {})
  },

  getGrossSalary(salary) {
    let basic = this.calculateSalaryByDayOrMonth(salary);
    let overtime = salary.overtimeUnitPrice * (salary.overtimeUnit ? parseInt(salary.overtimeUnit) : 0);
    let festival = salary.festivalBonusUnitPrice * (salary.festivalBonusUnit ? parseInt(salary.festivalBonusUnit) : 0);
    let houseRent = salary.houseRent ? parseInt(salary.houseRent) : 0;
    let conveyance = salary.conveyance ? parseInt(salary.conveyance) : 0;
    let medicalAllowance = salary.medicalAllowance ? parseInt(salary.medicalAllowance) : 0;
    let education = salary.education ? parseInt(salary.education) : 0;
    let lfc = salary.lfc ? parseInt(salary.lfc) : 0;
    let dues = salary.dues ? parseInt(salary.dues) : 0;
    let advances = salary.advances ? parseInt(salary.advances) : 0;
    return basic + overtime + festival + houseRent + conveyance + medicalAllowance + education + lfc + dues + advances;
  },

  getSalaryDeductibles(salary) {
    let taxDeduction = salary.taxDeduction ? parseInt(salary.taxDeduction) : 0;
    let insurance = salary.insurance ? parseInt(salary.insurance) : 0;
    let gratuityFund = salary.gratuityFund ? parseInt(salary.gratuityFund) : 0;
    let providentFund = this.calculateProvidentFundInPercentage(salary)
    let advanceDeduction = salary.advanceDeduction ? parseInt(salary.advanceDeduction) : 0;
    return taxDeduction + insurance + providentFund + gratuityFund + advanceDeduction
  },

  salaryObjectPropertyChanged() {
    let grossSalary = this.getGrossSalary(this.salary);
    this.set('grossSalary', grossSalary);
    let salaryDeductibles = this.getSalaryDeductibles(this.salary);
    this.set('salaryDeductibles', salaryDeductibles)
    let netSalary = grossSalary - salaryDeductibles;
    this.set('salary.paid', netSalary);
  },

  deleteSalaryEntry(e) {
    let { index } = e.model;
    this.splice('salarySheet.data', index, 1)
  },

  calculateTotalSalaryExpense(changeRecord) {
    if (changeRecord) {
      let total = this.salarySheet.data.reduce((total, item) => {
        return total += item.netSalary;
      }, 0)
      this.set('salarySheet.totalSalaryExpense', total);
    }
  },

  calculateSalaryByDayOrMonth(salary) {
    if (salary.dayCount == 30) {
      let basic = salary.salaryUnitPrice * (salary.salaryUnit ? parseInt(salary.salaryUnit) : 0)
      return basic
    }
    else {
      let salaryPerDay = (salary.salaryUnitPrice * (salary.salaryUnit ? parseInt(salary.salaryUnit) : 0)) / 30
      let basic = salaryPerDay * (salary.dayCount ? parseInt(salary.dayCount) : 0)
      return basic
    }
  },

  calculateProvidentFundInPercentage(salary) {
    let providentFundAmount = ((salary.providentFund ? parseInt(salary.providentFund) : 0) / 100) * (salary.salaryUnitPrice * (salary.salaryUnit ? parseInt(salary.salaryUnit) : 0));
    this.set('providentFundAmount', providentFundAmount)
    return providentFundAmount
  },

  salaryPaidChanged(e) {
    this.salary.paid = e.target.value;
  },

  checkIfAlreadyPaid(employeeSerial) {
    return this.salarySheet.data.findIndex(item => item.employeeSerial === employeeSerial) > -1
  },

  saveSalarySheet(cbfn) {
    this.loading = true;
    this.callApi('/bdemr-organization-create-salary-sheet', { apiKey: this.user.apiKey, salarySheet: this.salarySheet }, (err, response) => {
      this.loading = false;
      if (err) return this.domHost.showModalDialog(err.message);
      if (response.hasError) return this.domHost.showModalDialog(response.error.message);
      cbfn()
    })
  },

  // Saving Invoice
  calculateGrossPrice(expenseData) {
    return expenseData.reduce((total, item) => {
      return total += (item.qty * item.unitPrice);
    }, 0)
  },

  generateExpenseDataFromSalarySheet(salarySheetData) {
    return salarySheetData.map((item) => {
      return {
        qty: 1,
        unitPrice: item.netSalary,
        name: item.employeeName,
        category: 'salary',
        serial: item.employeeSerial
      }
    })
  },

  saveButtonClicked() {
    if (!this.salarySheet.data.length) return this.domHost.showModalDialog('No Salary Added');

    if (!this.expense.serial) this.expense.serial = this.generateSerialForExpense();

    this.expense.data = this.generateExpenseDataFromSalarySheet(this.salarySheet.data);
    this.expense.totalBilled = this.calculateGrossPrice(this.expense.data);
    this.expense.totalAmountPaid = this.expense.totalBilled;

    this.expense.lastModifiedDatetimeStamp = Date.now()
    this.saveSalarySheet(() => {
      app.db.upsert('organization-accounts-expense', this.expense, ({ serial }) => serial === this.expense.serial);
      console.log(this.salarySheet)
      this.domHost.showSuccessToast('Saved Successfully')
      this.domHost.navigateToPreviousPage()
    });

  },

  arrowBackButtonPressed() {
    return this.domHost.navigateToPreviousPage()
  },
  
  cancelButtonClicked() {
    return this.domHost.navigateToPreviousPage()
  }
})