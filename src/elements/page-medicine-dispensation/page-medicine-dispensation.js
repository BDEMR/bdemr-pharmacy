Polymer({
  is: "page-medicine-dispensation",
  behaviors: [
    app.behaviors.commonComputes,
    app.behaviors.dbUsing,
    app.behaviors.pageLike,
    app.behaviors.translating,
    app.behaviors.apiCalling
  ],
  properties: {
    user: {
      type: Object,
      notify: true,
      value: null
    },

    patient: {
      type: Object,
      notify: true,
      value: null
    },

    organization: {
      type: Object,
      value() {
        return null;
      }
    },

    selectedSeatsPageIndex: {
      type: Number,
      value: 0
    },

    matchingMedicationList: {
      type: Array,
      value() { return [] }
    },

    patientStayObject: {
      type: Object,
      value() {
        return null;
      }
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
    selectedDepartmentSerial: String,
    selectedUnitSerial: String,
    selectedWardSerial: String,

    seatList: {
      type: Array,
      value() {
        return [];
      }
    }
  },

  navigatedIn() {
    this._loadUser();
    this._loadOrganization();
    this._loadPatientStayObject(this.organization.idOnServer);
  },

  _loadUser() {
    const userList = app.db.find("user");
    if (userList.length) {
      return (this.user = userList[0]);
    } else {
      return this.domHost.showModalDialog("Invalid Organization");
    }
  },

  _loadOrganization() {
    const organizationList = app.db.find("organization");
    if (organizationList.length) {
      return this.set("organization", organizationList[0]);
    } else {
      return this.domHost.showModalDialog("Invalid Organization");
    }
  },

  _computeTotalDaysCount(endDate, startDate) {
    if (!endDate) {
      return this.$TRANSLATE("As Needed", this.LANG);
    }
    const oneDay = 1000 * 60 * 60 * 24;
    startDate = new Date(startDate);
    const diffMs = endDate - startDate;
    const x = Math.round(diffMs / oneDay);
    return this.$TRANSLATE_NUMBER(x, this.LANG);
  },

  _loadPatientStayObject(organizationId, cbfn) {
    this.loading = true;
    const data = {
      apiKey: this.user.apiKey,
      organizationId
    };
    return this.callApi("/bdemr-organization-patient-stay-get-object", data, (err, response) => {
      this.loading = false;
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        this.set("patientStayObject", response.data.patientStayObject);
        if (cbfn) {
          return cbfn();
        }
      }
    }
    );
  },

  departmentDropdownValueChanged(e) {
    if (!e.detail.value) return;
    let { name, serial, unitList } = e.detail.value;
    this.set("unitList", unitList);
    this.set("selectedDepartmentName", name);
    this.set("selectedDepartmentSerial", serial);
  },
  unitDropdownValueChanged(e) {
    if (!e.detail.value) return;
    let { name, serial, wardList } = e.detail.value;
    this.set("wardList", wardList);
    this.set("selectedUnitName", name);
    this.set("selectedUnitSerial", serial);
  },
  wardDropdownValueChanged(e) {
    if (!e.detail.value) return;
    let { name, serial } = e.detail.value;
    this.set("selectedWardName", name);
    this.set("selectedWardSerial", serial);
  },

  _checkUserAccess(departMentSerial, unitSerial, wardSerial) {
    let userId = this.user.idOnServer
    let assignedUserList = []
    for (let department of this.patientStayObject.departmentList) {
      if (department.assignedUserList && department.assignedUserList.length) {
        for (let user of department.assignedUserList) {
          // assignedUserList.push(user);
          if (user.idOnServer === userId && department.serial === departMentSerial) {
            return true;
          }
        }
      }
      if (department.unitList && department.unitList.length) {
        for (let unit of department.unitList) {
          if (unit.assignedUserList && unit.assignedUserList.length) {
            for (let user of unit.assignedUserList) {
              // assignedUserList.push(user);
              if (user.idOnServer === userId && unit.serial === unitSerial) {
                return true;
              }
            }
          }
          if (unit.wardList && unit.wardList.length) {
            for (let ward of unit.wardList) {
              if (ward.assignedUserList && ward.assignedUserList.length) {
                for (let user of ward.assignedUserList) {
                  // assignedUserList.push(user);
                  if (user.idOnServer === userId && ward.serial === wardSerial) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
    return false;
  },

  showMedicineButtonClicked() {
    if (!this.selectedWardName) {
      return this.domHost.showModalDialog('Please Select a Ward to show medicine list');
    }
    let userHasAccess = this._checkUserAccess(this.selectedDepartmentSerial, this.selectedUnitSerial, this.selectedWardSerial)
    console.log({ userHasAccess })
    if (userHasAccess) {
      const seatList = this.patientStayObject.seatList.filter(item => item.department == this.selectedDepartmentName && item.unit == this.selectedUnitName && item.ward == this.selectedWardName);
      console.log(seatList)
      this._getPatientMedication(seatList, (data) => {
        this.set('matchingMedicationList', data);
      });
    } else {
      return this.domHost.showModalDialog('You do not have access to this ward');
    }

  },

  _getPatientMedication(seatList, cbfn) {
    this.loading = true;
    const data = {
      apiKey: this.user.apiKey,
      seatList
    };
    return this.callApi("/bdemr-get-patient-current-medications", data, (err, response) => {
      this.loading = false;
      if (err) {
        return this.domHost.showModalDialog(err.message);
      } else if (response.hasError) {
        this.domHost.showModalDialog(response.error.message);
        return;
      } else {
        return cbfn(response.data);
      }
    }
    );
  },

  _getFirstDoseDateTime(intakeDateTimeStampList) {
    if (intakeDateTimeStampList.length !== 0) {
      const firstDoseValue = intakeDateTimeStampList[0];
      return this.$formatDateTime(firstDoseValue);
    }
    return "Never Taken";
  },

  _getLastDoseDateTime(intakeDateTimeStampList) {
    if (intakeDateTimeStampList.length !== 0) {
      const lastDoseValue =
        intakeDateTimeStampList[intakeDateTimeStampList.length - 1];
      return this.$formatDateTime(lastDoseValue);
    }
    return "Never Taken";
  },

  _getNextDoseDateTime(intakeDateTimeStampList, nextDoseDateTimeStamp) {
    if (intakeDateTimeStampList.length !== 0) {
      const nextDoseValue = nextDoseDateTimeStamp;
      return this.$formatDateTime(nextDoseValue);
    }
    return "Taken Immediately";
  },

  _getItemDose(dose) {
    switch (false) {
      case dose !== 0.25:
        return "1/4";
      case dose !== 0.5:
        return "1/2";
      default:
        return this.$TRANSLATE_NUMBER(dose, this.LANG);
    }
  },

  _getDosesLeft(qty, intakeDateTimeStampListLength) {
    const dosesLeft = qty - intakeDateTimeStampListLength;
    if (dosesLeft > 0) {
      return dosesLeft;
    } else {
      return 0;
    }
  },

  deleteMedicationClicked(e) {
    const { index, item } = e.model;
    return this.domHost.showModalPrompt("Are you sure to delete this medication", (answer) => {
      if (answer) {
        app.db.remove("patient-medications", item._id);
        app.db.insert("patient-medications--deleted", {
          serial: item.serial
        });
        if (item.data.status === "continue") {
          return this.splice("medicationList", index, 1);
        } else {
          return this.splice("stoppedMedicationList", index, 1);
        }
      }
    }
    );
  },

  tookDoseClicked(e) {
    const { index, medicine } = e.model;
    e.model.push("medicine.data.intakeDateTimeStampList", new Date().getTime());
    const intakeValue = e.model.get([
      "medicine.data.intakeDateTimeStampList",
      medicine.data.intakeDateTimeStampList.length - 1
    ]);
    const next = new Date(intakeValue);
    next.setHours(
      next.getHours() + e.model.get("medicine.data.intervalInHours")
    );
    e.model.set("medicine.data.nextDoseDateTimeStamp", next.getTime());
    return this._updateMedicationData(medicine);
  },

  refillDoseButtonClicked(e) {
    const { item } = e.model;
    e.model.set(
      "item.data.quantityPerPrescription",
      item.data.quantityPerPrescription + 10
    );
    return this._updateMedicationData(item);
  },

  isMedicineOverdue(nextDoseDateTimeStamp) {
    return nextDoseDateTimeStamp < lib.datetime.now();
  },

  _updateMedicationData(prescription) {
    prescription.lastModifiedDatetimeStamp = lib.datetime.now();
    this.loading = true
    const data = {
      apiKey: this.user.apiKey,
      prescription
    };
    return this.callApi("bdemr-update-patient-medication-data", data, (err, response) => {
      this.loading = false
      if (response.hasError) {
        return this.domHost.showModalDialog(response.error.message);
      } else {
        return this.domHost.showToast("Updated Successfully");
      }
    });
  }
});
