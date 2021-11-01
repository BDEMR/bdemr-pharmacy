Polymer({
  is: 'page-organization-settings',
  behaviors: [
    app.behaviors.commonComputes,
    app.behaviors.dbUsing,
    app.behaviors.pageLike
  ],
  properties: {
    user: Object,
    organization: Object,
    organizationSettings: Object
  },

  navigatedIn() {
    params = this.domHost.getPageParams()

    this._loadUser();

    if (params['organization']) {
      const organizationId = params['organization'];
      this._loadOrganization(organizationId)
      this._loadOrganizationSettings(organizationId);
    } else {
      return this.domHost.showModalDialog('Invalid Organization Provided')
    }


  },

  _loadUser() {
    const userList = app.db.find('user');
    if (userList.length) {
      return this.user = userList[0];
    } else {
      return this.domHost.showModalDialog('User not found')
    }
  },

  _loadOrganization(organizationIdentifier) {
    const organizationList = app.db.find('organization', ({ idOnServer }) => idOnServer === organizationIdentifier);
    if (organizationList.length) {
      return this.set('organization', organizationList[0]);
    } else {
      return this.domHost.showModalDialog('Organization not found')
    }
  },

  _loadOrganizationSettings(organizationIdentifier) {
    const list = app.db.find('organization-settings', ({ serial }) => serial === organizationIdentifier)
    console.log(list);
    if (list.length) {
      this.set('organizationSettings', list[0]);
    } else {
      this._makeNewOrganizationSettings(organizationIdentifier)
    }
  },

  _makeNewOrganizationSettings(organizationIdentifier) {
    this.set('organizationSettings', {
      serial: organizationIdentifier,
      organizationId: organizationIdentifier,
      createdByUserSerial: this.user.serial,
      lastModifiedDatetimeStamp: null,
      createdDatetimeStamp: lib.datetime.now(),
      lastSyncedDatetimeStamp: null,
      data: {
        generalDiscountPercentageLimit: 100,
        minimumPaymentPercentageLimit: 0,
        vatOrTaxPercentage: 0,
        nocText: ''
      }
    });
  },

  _validate(doc) {
    if (doc.generalDiscountPercentageLimit > 100 || doc.generalDiscountPercentageLimit < 0) {
      this.$.generalDiscount.invalid = true;
      return false;
    } else {
      this.$.generalDiscount.invalid = false;
    }
    if (doc.minimumPaymentPercentageLimit > 100 || doc.minimumPaymentPercentageLimit < 0) {
      this.$.minPayment.invalid = true;
      return false;
    } else {
      this.$.minPayment.invalid = false;
    }
    if (doc.vatOrTaxPercentage > 100 || doc.vatOrTaxPercentage < 0) {
      this.$.vatTaxPercent.invalid = true;
      return false;
    } else {
      this.$.vatTaxPercent.invalid = false;
    }
    return true;
  },

  saveButtonClicked(e) {
    const valid = this._validate(this.organizationSettings.data)
    if (!valid) return;
    this.organizationSettings.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert('organization-settings', this.organizationSettings, ({ serial }) => serial === this.organizationSettings.serial)
    this.domHost.showToast('Saved Successfully');
  },

  arrowBackButtonPressed(e) { this.domHost.navigateToPreviousPage() }


});