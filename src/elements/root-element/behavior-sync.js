if (!app.behaviors.local['root-element']) {
  app.behaviors.local['root-element'] = {};
}
app.behaviors.local['root-element'].newSync = {

  _getLastSyncedDatetimeStamp() { return parseInt(window.localStorage.getItem('lastSyncedDatetimeStamp')) || 0; },

  _updateLastSyncedDatetimeStamp() { return window.localStorage.setItem('lastSyncedDatetimeStamp', lib.datetime.now()); },

  _getModifiedDataFromDB(collectionNameList, lastSyncedDatetimeStamp) {
    return collectionNameList.reduce((list, clientCollectionName) => {
      const docList = app.db.find(clientCollectionName, ({ lastModifiedDatetimeStamp }) => lastModifiedDatetimeStamp > lastSyncedDatetimeStamp);
      const docListWithClientCollectionName = docList.map(doc => {
        doc.clientCollectionName = clientCollectionName;
        doc.lastSyncedDatetimeStamp = lastSyncedDatetimeStamp; // added as sync 'modified & last-synced' issue resolution
        return doc;
      });
      return list.concat(docListWithClientCollectionName);
    }, [])
  },


  _newSync(cbfn) {

    const collectionNameMap = {
      'bdemr--doctor-visit': 'doctor-visit',
      'bdemr--visit-prescription': 'visit-prescription',
      'custom-investigation-list': 'custom-investigation-list',
      'favorite-advised-test': 'favorite-advised-test',
      'user-added-institution-list': 'user-added-institution-list',
      'organization-added-custom-investigation': 'organization-added-custom-investigation',
      'bdemr--visit-advised-test': 'visit-advised-test',
      'bdemr--patient-test-results': 'patient-test-results',
      'bdemr--patient-gallery--online-attachment': 'patient-gallery--online-attachment',
      'bdemr--clinic-investigation-price-list': 'investigation-price-list',
      'bdemr--clinic-doctor-fees-price-list': 'doctor-fees-price-list',
      'bdemr--clinic-service-price-list': 'service-price-list',
      'bdemr--clinic-pharmacy-price-list': 'pharmacy-price-list',
      'bdemr--clinic-supply-price-list': 'supply-price-list',
      'bdemr--clinic-ambulance-price-list': 'ambulance-price-list',
      'bdemr--clinic-package-price-list': 'package-price-list',
      'bdemr--clinic-other-price-list': 'other-price-list',
      'bdemr--patient-invoice': 'patient-invoice',
      'bdemr--patient-type-logs': 'patient-type-logs',
      'bdemr--clinic-organization-inventory': 'organization-inventory',
      'bdemr--clinic-organization-internal-inventory': 'organization-internal-inventory',
      'bdemr--clinic-organization-internal-inventory-transaction': 'organization-internal-inventory-transaction',
      'bdemr--clinic-organization-other-income': 'organization-other-income',
      'bdemr--clinic-organization-other-expense': 'organization-other-expense',
      'bdemr--clinic-organization-salary-expense': 'organization-salary-expense',
      'bdemr--clinic-organization-utility-expense': 'organization-utility-expense',
      'bdemr--patient-stay': 'visit-patient-stay',
      'bdemr--clinic-third-party-user-list': 'third-party-user-list',
      'bdemr--clinic-invoice-category-list': 'invoice-category-list',
      'bdemr--clinic-invoice-reference-list': 'invoice-reference-by-list',
      'bdemr--clinic-user-defined-notification-group': 'user-defined-notification-group',
      'bdemr--clinic-operation-list': 'ot-management',
      'bdemr--patient-template-record-list': 'patient-template-record',
      'bdemr--pcc-records': 'pcc-records',
      'bdemr--ndr-records': 'ndr-records',
      'bdemr--clinic-patient-consent-form': 'patient-consent-form',
      'bdemr--clinic-app-settings': 'settings',
      'bdemr--clinic-organization-settings': 'organization-settings',
      'bdemr--clinic-commission-category-list': 'commission-category-list',
      'bdemr--clinic-organization-accounts-income': 'organization-accounts-income',
      'bdemr--clinic-organization-accounts-expense': 'organization-accounts-expense',
      'bdemr--clinic-pharmacy-supplier-invoice': 'pharmacy-supplier-invoice',
      'bdemr--clinic-organization-accounts-expense-categories': 'organization-accounts-expense-categories',
      'bdemr--clinic-organization-accounts-income-categories': 'organization-accounts-income-categories',
      'bdemr--clinic-pharmacy-supplier-invoice-categories': 'pharmacy-supplier-invoice-categories',
      'bdemr--clinic-third-party-payment-list': 'third-party-payment-list',
      'bdemr--organization-message-share': 'organization-message-share',
      'bdemr--clinic-top-sheet-entry-list': 'top-sheet-entry-list',
      'bdemr--clinic-third-party-supervisor-list': 'third-party-supervisor-list',
      'bdemr--clinic-academic-session': 'academic-session',
      'bdemr--covid-test-result': 'covid-test-result',
      'bdemr--covid-vaccination': 'covid-vaccination',
      'bdemr--covid-respirator-fit-test': 'covid-respirator-fit-test',
      'bdemr--custom-covid-respirator-fit-test': 'custom-covid-respirator-fit-test',
      'bdemr--user-activity-log': 'activity',
    };

    const deleteCollectionNameMap = {
      'bdemr--doctor-visit--deleted': 'doctor-visit--deleted',
      'custom-investigation-list--deleted': 'custom-investigation-list--deleted',
      'favorite-advised-test--deleted': 'favorite-advised-test--deleted',
      'user-added-institution-list--deleted': 'user-added-institution-list--deleted',
      'organization-added-custom-investigation--deleted': 'organization-added-custom-investigation--deleted',
      'bdemr--visit-advised-test--deleted': 'visit-advised-test--deleted',
      'bdemr--patient-test-results--deleted': 'patient-test-results--deleted',
      'bdemr--patient-gallery--online-attachment--deleted': 'patient-gallery--online-attachment--deleted',
      'bdemr--clinic-investigation-price-list--deleted': 'investigation-price-list--deleted',
      'bdemr--clinic-doctor-fees-price-list--deleted': 'doctor-fees-price-list--deleted',
      'bdemr--clinic-service-price-list--deleted': 'service-price-list--deleted',
      'bdemr--clinic-pharmacy-price-list--deleted': 'pharmacy-price-list--deleted',
      'bdemr--clinic-supply-price-list--deleted': 'supply-price-list--deleted',
      'bdemr--patient-type-logs--deleted': 'patient-type-logs--deleted',
      'bdemr--clinic-ambulance-price-list--deleted': 'ambulance-price-list--deleted',
      'bdemr--clinic-package-price-list--deleted': 'package-price-list--deleted',
      'bdemr--clinic-other-price-list--deleted': 'other-price-list--deleted',
      'bdemr--patient-invoice--deleted': 'patient-invoice--deleted',
      'bdemr--clinic-organization-inventory--deleted': 'organization-inventory--deleted',
      'bdemr--clinic-organization-internal-inventory--deleted': 'organization-internal-inventory--deleted',
      'bdemr--clinic-organization-internal-inventory-transaction--deleted': 'organization-internal-inventory-transaction--deleted',
      'bdemr--clinic-organization-other-income--deleted': 'organization-other-income--deleted',
      'bdemr--clinic-organization-other-expense--deleted': 'organization-other-expense--deleted',
      'bdemr--clinic-organization-salary-expense--deleted': 'organization-salary-expense--deleted',
      'bdemr--clinic-organization-utility-expense--deleted': 'organization-utility-expense--deleted',
      'bdemr--patient-stay--deleted': 'visit-patient-stay--deleted',
      'bdemr--clinic-third-party-user-list--deleted': 'third-party-user-list--deleted',
      'bdemr--clinic-invoice-category-list--deleted': 'invoice-category-list--deleted',
      'bdemr--clinic-invoice-reference-list--deleted': 'invoice-reference-by-list--deleted',
      'bdemr--clinic-user-defined-notification-group--deleted': 'user-defined-notification-group--deleted',
      'bdemr--clinic-operation-list--deleted': 'ot-management--deleted',
      'bdemr--patient-template-record-list--deleted': 'patient-template-record--deleted',
      'bdemr--pcc-records--deleted': 'pcc-records--deleted',
      'bdemr--ndr-records--deleted': 'ndr-records--deleted',
      'bdemr--clinic-patient-consent-form--deleted': 'patient-consent-form--deleted',
      'bdemr--clinic-app-settings--deleted': 'settings--deleted',
      'bdemr--clinic-organization-settings--deleted': 'organization-settings--deleted',
      'bdemr--clinic-commission-category-list--deleted': 'commission-category-list--deleted',
      'bdemr--clinic-organization-accounts-income--deleted': 'organization-accounts-income--deleted',
      'bdemr--clinic-organization-accounts-expense--deleted': 'organization-accounts-expense--deleted',
      'bdemr--clinic-pharmacy-supplier-invoice--deleted': 'pharmacy-supplier-invoice--deleted',
      'bdemr--clinic-organization-accounts-expense-categories--deleted': 'organization-accounts-expense-categories--deleted',
      'bdemr--clinic-organization-accounts-income-categories--deleted': 'organization-accounts-income-categories--deleted',
      'bdemr--clinic-pharmacy-supplier-invoice-categories--deleted': 'pharmacy-supplier-invoice-categories--deleted',
      'bdemr--clinic-third-party-payment-list--deleted': 'third-party-payment-list--deleted',
      'bdemr--organization-message-share--deleted': 'organization-message-share--deleted',
      'bdemr--clinic-top-sheet-entry-list--deleted': 'top-sheet-entry-list--deleted',
      'bdemr--clinic-third-party-supervisor-list--deleted': 'third-party-supervisor-list--deleted',
      'bdemr--clinic-academic-session--deleted': 'academic-session--deleted',
      'bdemr--covid-test-result--deleted': 'covid-test-result--deleted',
      'bdemr--covid-vaccination--deleted': 'covid-vaccination--deleted',
      'bdemr--covid-respirator-fit-test--deleted': 'covid-respirator-fit-test--deleted',
      'bdemr--custom-covid-respirator-fit-test--deleted': 'custom-covid-respirator-fit-test--deleted',
      'bdemr--user-activity-log--deleted': 'activity--deleted',

    }

    const lastSyncedDatetimeStamp = this._getLastSyncedDatetimeStamp();
    const organizationId = this.getCurrentOrganization().idOnServer;
    const patientList = app.db.find('patient-list');
    const knownPatientSerialList = patientList.map((patient) => patient.serial);
    const { apiKey } = this.getCurrentUser();

    const collectionNameList = Object.keys(collectionNameMap).map(serverCollectionName => collectionNameMap[serverCollectionName]);
    const deletedCollectionNameList = Object.keys(deleteCollectionNameMap).map(serverCollectionName => deleteCollectionNameMap[serverCollectionName]);

    const clientToServerDocList = this._getModifiedDataFromDB(collectionNameList, lastSyncedDatetimeStamp);
    const removedDocList = this._getModifiedDataFromDB(deletedCollectionNameList, lastSyncedDatetimeStamp);

    const data = {
      apiKey,
      organizationId,
      knownPatientSerialList,
      lastSyncedDatetimeStamp,
      clientToServerDocList,
      removedDocList,
      client: 'clinic'
    };


    this.callApi('/bdemr--sync', data, (err, response) => {

      if (err) {
        return cbfn(err)
      } else if (response.hasError) {
        return cbfn(response.error.message);
      } else {

        let { serverToClientItems, serverToClientDeletedItems } = response.data;
        // let serverToClientItems = response.data;

        if (serverToClientItems.length) {
          app.db.__allowCommit = false;
          for (let index = 0; index < serverToClientItems.length; index++) {
            var item = serverToClientItems[index];
            const collectionName = collectionNameMap[item.collection];
            delete item.collection;
            if (index === (serverToClientItems.length - 1)) {
              app.db.__allowCommit = true;
            }
            if (collectionName) {
              app.db.upsert(collectionName, item, ({ serial }) => item.serial === serial);
            }
          }
          app.db.__allowCommit = true;
        }

        // Deleted Docs from Server
        if (serverToClientDeletedItems.length) {
          serverToClientDeletedItems.forEach((item) => {
            const deletedCollectionName = deleteCollectionNameMap[item.collection];
            console.log('item collection', item.collection);
            console.log('deletedCollectionName', deletedCollectionName);
            if (deletedCollectionName) {
              const collectionName = deletedCollectionName.split('--')[0]
              let docList = app.db.find(collectionName, ({ serial }) => serial == item.serial);
              console.log(docList)
              if (docList.length) app.db.remove(collectionName, docList[0]._id);
            }
          })
        }

        this._updateLastSyncedDatetimeStamp();

        return cbfn();
      }
    });
  }
};
