
app.db = new lib.DatabaseEngine {
  name: 'bdemr-clinic-app-db'
  storageEngine: lib.localStorage
  serializationEngine: lib.json
  config:
    commitDelay: 0
}

app.db.initializeDatabase { removeExisting: false }
###
  unregsitered-patient-details
###
app.db.defineCollection {
  name: 'unregsitered-patient-details'
}


###
  settings
    isSyncEnabled
###
app.db.defineCollection {
  name: 'settings'
}

app.db.defineCollection {
  name: 'settings--deleted'
}



###
  --serial-generator
    patient-seed Number
    anaesmon-record-seed Number
    progress-note-seed Number
###
app.db.defineCollection {
  name: '--serial-generator'
}

###
  anaesmon-record
    idOnServer
    source = local \ online
    lastSyncedDatetimeStamp
    lastLocallyChangedDatetimeStamp
    createdDatetimeStamp
    createdByUserSerial
    serial
    doctorsPrivateNote: ''
    patientSerial
    recordType: 'anaesmon-record'
    content Object
###

app.db.defineCollection {
  name: 'anaesmon-record'
}

app.db.defineCollection {
  name: 'anaesmon-record--deleted'
}



###
  --persistent-session
    shouldRememberUser Boolean
###
app.db.defineCollection {
  name: '--persistent-session'
}


###
  user
    serial
    name
    email
    phone
    apiKey
    sessionSerial
    usedTokenList
    accountExpiresOnDate
###




app.db.defineCollection {
  name: 'user'
}

###
  patient-list
    idOnServer
    source = local | online
    lastSyncedDatetimeStamp
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    createdByUserSerial
    serial
    name
    email
    phone
    address
        line1
        line2
        postalCode
        cityOrTown
        stateOrProvince
        country
    dob
    nIdOrSsn
    doctorsPrivateNote
###
app.db.defineCollection {
  name: 'patient-list'
}

app.db.defineCollection {
  name: 'patient-list--deleted'
}

app.db.defineCollection {
  name: 'patient-type-logs'
}

app.db.defineCollection {
  name: 'patient-type-logs--deleted'
}

###
  idOnServer
  name
  address
  effectiveRegion
  isCurrentUserAMember
  isCurrentUserAnAdmin
  isClaimed
###

app.db.defineCollection {
  name: 'organization'
}



###
  doctor-visit
    idOnServer
    source = local \ online
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    patientSerial
    doctorName
    hospitalName
    doctorSpeciality
    prescriptionSerial
    doctorNoteSerial
    nextVisitSerial
    advisedTestSerial
    testResults
      serial
      resultType
      resultName


    
###

app.db.defineCollection {
  name: 'doctor-visit'
}


app.db.defineCollection {
  name: 'doctor-visit--deleted'
}



app.db.defineCollection {
  name: 'covid-test-result'
}

app.db.defineCollection {
  name: 'covid-test-result--deleted'
}

app.db.defineCollection {
  name: 'covid-vaccination'
}

app.db.defineCollection {
  name: 'covid-vaccination--deleted'
}


app.db.defineCollection {
  name: 'covid-respirator-fit-test'
}

app.db.defineCollection {
  name: 'covid-respirator-fit-test--deleted'
}


app.db.defineCollection {
  name: 'custom-covid-respirator-fit-test'
}

app.db.defineCollection {
  name: 'custom-covid-respirator-fit-test--deleted'
}

###
  custom-investigation-list
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    data:
      categoryName
      investigationName
    
###

app.db.defineCollection {
  name: 'custom-investigation-list'
}

app.db.defineCollection {
  name: 'custom-investigation-list--deleted'
}

app.db.defineCollection {
  name: 'organization-added-custom-investigation'
}

app.db.defineCollection {
  name: 'organization-added-custom-investigation--deleted'
}





###
  visit-advised-test
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    visitSerial
    patientSerial
    data
      testAdvisedList: [
        {
          testName
          suggestedInstitutionName
          userAddedInstitutionSelectedIndex
        }
      ]
    
###

app.db.defineCollection {
  name: 'visit-advised-test'
}

app.db.defineCollection {
  name: 'visit-advised-test--deleted'
}

###
  favorite-advised-test
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    testName
    
###

app.db.defineCollection {
  name: 'favorite-advised-test'
}

app.db.defineCollection {
  name: 'favorite-advised-test--deleted'
}


###
  user-added-institution-list
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    data
      institutionName

    
###

app.db.defineCollection {
  name: 'user-added-institution-list'
}

app.db.defineCollection {
  name: 'user-added-institution-list--deleted'
}


###
  patient-test-results
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    advisedDoctorSerial
    patientSerial
    advisedTestSerial
    investigationSerial
    investigationName
    attachmentSerialList
    data =
      testList = {
        datePerform
        testName
        testResult
        testUnit
        testUnitList = []
        unitSelectedIndex
        checkedTestIndex
        reportedDoctorSerial
        reportedDoctorName
        reportedDoctorSpeciality
        reportedDoctorSelectedIndex
        referenceRange
      }
          

    
###
app.db.defineCollection {
  name: 'patient-test-results'
}

app.db.defineCollection {
  name: 'patient-test-results--deleted'
}


###
  user-added-reported-doctor-list
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    
    data =
      doctorSerial
      doctorName
      specializationList

    
###
app.db.defineCollection {
  name: 'user-added-reported-doctor-list'
}

app.db.defineCollection {
  name: 'user-added-reported-doctor-list--deleted'
}


app.db.defineCollection {
  name: 'user-added-checked-by-user-list'
}

app.db.defineCollection {
  name: 'user-added-checked-by-user-list--deleted'
}






app.db.defineCollection {
  name: 'patient-gallery--local-attachment'
}

app.db.defineCollection {
  name: 'patient-gallery--online-attachment'
}

app.db.defineCollection {
  name: 'patient-gallery--online-attachment--deleted'
}

app.db.defineCollection {
  name: 'in-app-notification'
}


###
  local-patient-pin-code-list
    patientSerial
    pin
###
app.db.defineCollection {
  name: 'local-patient-pin-code-list'
}

###
  name: String
  price: Number
###

app.db.defineCollection {
  name: 'investigation-price-list'
}

app.db.defineCollection {
  name: 'investigation-price-list--deleted'
}

app.db.defineCollection {
  name: 'doctor-fees-price-list'
}

app.db.defineCollection {
  name: 'doctor-fees-price-list--deleted'
}

app.db.defineCollection {
  name: 'service-price-list'
}

app.db.defineCollection {
  name: 'service-price-list--deleted'
}

app.db.defineCollection {
  name: 'pharmacy-price-list'
}

app.db.defineCollection {
  name: 'pharmacy-price-list--deleted'
}

app.db.defineCollection {
  name: 'supply-price-list'
}

app.db.defineCollection {
  name: 'supply-price-list--deleted'
}

app.db.defineCollection {
  name: 'ambulance-price-list'
}

app.db.defineCollection {
  name: 'ambulance-price-list--deleted'
}

app.db.defineCollection {
  name: 'package-price-list'
}

app.db.defineCollection {
  name: 'package-price-list--deleted'
}

app.db.defineCollection {
  name: 'other-price-list'
}

app.db.defineCollection {
  name: 'other-price-list--deleted'
}

###
  serial:
  patientSerial:
  modificationHistory: [
    {
      userSerial
      lastModifiedDatetimeStamp
    }
  ]
  lastModifiedDatetimeStamp:
  totalCost:
  paid:
  due:
  discount:
  flags:
    flagAsError: false
    markAsCompleted: false
  data: [
    {
      name
      price
      qty
      type
      totalCost
    }
  ]
###

app.db.defineCollection {
  name: 'patient-invoice'
}

app.db.defineCollection {
  name: 'patient-invoice--deleted'
}

app.db.defineCollection {
  name: 'organization-inventory'
}

app.db.defineCollection {
  name: 'organization-inventory--deleted'
}

app.db.defineCollection {
  name: 'organization-internal-inventory-transaction'
}

app.db.defineCollection {
  name: 'organization-internal-inventory-transaction--deleted'
}

app.db.defineCollection {
  name: 'organization-internal-inventory'
}

app.db.defineCollection {
  name: 'organization-internal-inventory--deleted'
}



app.db.defineCollection {
  name: 'organization-other-income'
}

app.db.defineCollection {
  name: 'organization-other-income--deleted'
}

app.db.defineCollection {
  name: 'organization-other-expense'
}

app.db.defineCollection {
  name: 'organization-other-expense--deleted'
}

app.db.defineCollection {
  name: 'organization-salary-expense'
}

app.db.defineCollection {
  name: 'organization-salary-expense--deleted'
}

app.db.defineCollection {
  name: 'organization-utility-expense'
}

app.db.defineCollection {
  name: 'organization-utility-expense--deleted'
}

###
  visit-patient-stay
    serial
    lastModifiedDatetimeStamp
    createdDatetimeStamp
    lastSyncedDatetimeStamp
    createdByUserSerial
    visitSerial
    patientSerial
      data:
        typeNameOfTheInstitution
        typeOutPatientDischargedAdvised
        typeOutPatientAdmissionAdvised
        typeEmergencyDischargedAdvised
        typeEmergencyAdmissionAdvised
        admissionToHospitalName
        admissionToDepartment
        admissionToDateOfAdmissionDateTimeStamp
        admissionToLocationDateOfAdmissionDateTimeStamp
        admissionToNameOfWard
        admissionToNameOfBed
        dischargeDatetimeStamp
        dischargeReason
        dischargeReasonGotBetter
        dischargeReasonRequireCare
        dischargeReasonCurrentCareNotPossible
        dischargeReasonNotRequiredStayHospital
        dischargeReasonDeath
        dischargeToHome
        dischargeToRehabilitation
        dischargeToMortualry
        dischargeToCustom
    
###

app.db.defineCollection {
  name: 'visit-patient-stay'
}

app.db.defineCollection {
  name: 'visit-patient-stay--deleted'
}


app.db.defineCollection {
  name: 'third-party-user-list'
}

app.db.defineCollection {
  name: 'third-party-user-list--deleted'
}

app.db.defineCollection {
  name: 'invoice-category-list'
}

app.db.defineCollection {
  name: 'invoice-category-list--deleted'
}

app.db.defineCollection {
  name: 'invoice-reference-by-list'
}

app.db.defineCollection {
  name: 'invoice-reference-by-list--deleted'
}

app.db.defineCollection {
  name: 'commission-category-list'
}

app.db.defineCollection {
  name: 'commission-category-list--deleted'
}

app.db.defineCollection {
  name: 'third-party-payment-list'
}

app.db.defineCollection {
  name: 'third-party-payment-list--deleted'
}

app.db.defineCollection {
  name: 'third-party-supervisor-list'
}

app.db.defineCollection {
  name: 'third-party-supervisor-list--deleted'
}


app.db.defineCollection {
  name: 'top-sheet-entry-list'
}

app.db.defineCollection {
  name: 'top-sheet-entry-list--deleted'
}


app.db.defineCollection {
  name: 'user-defined-notification-group'
}

app.db.defineCollection {
  name: 'user-defined-notification-group--deleted'
}

app.db.defineCollection {
  name: 'visited-patient-log'
}

app.db.defineCollection {
  name: 'visited-patient-log--deleted'
}

app.db.defineCollection {
  name: 'ot-management'
}

app.db.defineCollection {
  name: 'ot-management--deleted'
}

app.db.defineCollection {
  name: 'patient-template-record'
}

app.db.defineCollection {
  name: 'patient-template-record--deleted'
}

app.db.defineCollection {
  name: 'custom-inventory-category-list'
}

app.db.defineCollection {
  name: 'custom-inventory-category-list--deleted'
}


### 
pcc-record
  serial: null
  lastModifiedDatetimeStamp: 0
  createdDatetimeStamp: 0
  lastSyncedDatetimeStamp: 0
  createdByUserSerial
  patientSerial
  centerInfo:
    centerIdOnServer
    centerSerial
    centerName
    patientId
  medicalInfo

###

app.db.defineCollection {
  name: 'pcc-records'
}

app.db.defineCollection {
  name: 'pcc-records--deleted'
}

app.db.defineCollection {
  name: 'ndr-records'
}

app.db.defineCollection {
  name: 'ndr-records--deleted'
}

### 
patient-insulin-list
  serial: null
  lastModifiedDatetimeStamp: 0
  createdDatetimeStamp: 0
  lastSyncedDatetimeStamp: 0
  createdByUserSerial
  patientSerial
  data:

###

app.db.defineCollection {
  name: 'patient-insulin-list'
}

app.db.defineCollection {
  name: 'patient-insulin-list--deleted'
}

###
favorite-medicine-list
  serial
  createdDatetimeStamp
  lastModifiedDatetimeStamp
  lastSyncedDatetimeStamp
  createdByUserSerial
  data:
    genericName
    brandName
    manufacturer
    dose
    from
    startDateTimeStamp
    endDateTimeType
    endDateTimeStamp
    route
    direction
    quantityPerPrescription
    numberOfRefill
    comments
    intakeDateTimeStampList
    nextDoseDateTimeStamp
    intervalInHours
    status = continue/stopped
###
app.db.defineCollection {
  name: 'favorite-medicine-list'
}

app.db.defineCollection {
  name: 'favorite-medicine-list--deleted'
}

app.db.defineCollection {
  name: 'offline-patient-pin'
}

app.db.defineCollection {
  name: 'offline-patient-pin--deleted'
}

app.db.defineCollection {
  name: 'existing-patient-log-for-pending-pcc-records'
}


###
  patient-vitals-blood-pressure'
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      systolic
      diastolic
      random
      unit
      flags =
        flagAsError: false
###
app.db.defineCollection {
  name: 'patient-vitals-blood-pressure'
}

app.db.defineCollection {
  name: 'patient-vitals-blood-pressure--deleted'
}



###
  patient-vitals-pulse-rate
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      bpm
      flags =
        flagAsError: false
###
app.db.defineCollection {
  name: 'patient-vitals-pulse-rate'
}

app.db.defineCollection {
  name: 'patient-vitals-pulse-rate--deleted'
}



###
  patient-vitals-respiratory-rate
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      respiratoryRate
      unit
      flags =
        flagAsError: false
###
app.db.defineCollection {
  name: 'patient-vitals-respiratory-rate'
}

app.db.defineCollection {
  name: 'patient-vitals-respiratory-rate--deleted'
}



###
  patient-vitals-spo2
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      spO2Percentage
      unit
      flags =
        flagAsError: false
###
app.db.defineCollection {
  name: 'patient-vitals-spo2'
}

app.db.defineCollection {
  name: 'patient-vitals-spo2--deleted'
}

###
  patient-vitals-temperature
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      temparature
      unit
      flags =
        flagAsError: false
###
app.db.defineCollection {
  name: 'patient-vitals-temperature'
}

app.db.defineCollection {
  name: 'patient-vitals-temperature--deleted'
}



###
  patient-vitals-bmi
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      height
      weight
      heightInFt
      heightInInch
      heightUnit
      weightUnit
      calculatedBMI
###
app.db.defineCollection {
  name: 'patient-vitals-bmi'
}

app.db.defineCollection {
  name: 'patient-vitals-bmi--deleted'
}



###
  patient-test-blood-sugar
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      beforeMeal
      afterMeal
      random
      unit
###
app.db.defineCollection {
  name: 'patient-test-blood-sugar'
}

app.db.defineCollection {
  name: 'patient-test-blood-sugar--deleted'
}

###
  patient-test-other
    serial
    createdByUserSerial
    patientSerial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    lastSyncedDatetimeStamp
    data:
      date
      name
      result
      institution
      unit
###
app.db.defineCollection {
  name: 'patient-test-other'
}

app.db.defineCollection {
  name: 'patient-test-other--deleted'
}


###
  Separate Diagnosis List from History Physical
    serial
    createdDatetimeStamp
    lastModifiedDatetimeStamp
    createdByUserSerial
    patientSerial
    doctorName
    doctorSpeciality
    diagnosis
###

app.db.defineCollection {
  name: 'visit-diagnosis'
}

app.db.defineCollection {
  name: 'visit-diagnosis--deleted'
}

app.db.defineCollection {
  name: 'conflicted-patient-list'
}


app.db.defineCollection {
  name: 'visit-prescription'
}

app.db.defineCollection {
  name: 'visit-prescription--deleted'
}

app.db.defineCollection {
  name: 'visit-next-visit'
}

app.db.defineCollection {
  name: 'visit-next-visit--deleted'
}

app.db.defineCollection {
  name: 'patient-medications'
}

app.db.defineCollection {
  name: 'patient-medications--deleted'
}

app.db.defineCollection {
  name: 'patient-vitals-blood-pressure'
}

app.db.defineCollection {
  name: 'patient-vitals-blood-pressure--deleted'
}

app.db.defineCollection {
  name: 'patient-vitals-pulse-rate'
}

app.db.defineCollection {
  name: 'patient-vitals-pulse-rate--deleted'
}

app.db.defineCollection {
  name: 'patient-vitals-respiratory-rate'
}

app.db.defineCollection {
  name: 'patient-vitals-respiratory-rate--deleted'
}

app.db.defineCollection {
  name: 'patient-vitals-spo2'
}

app.db.defineCollection {
  name: 'patient-vitals-spo2--deleted'
}

app.db.defineCollection {
  name: 'patient-vitals-temperature'
}

app.db.defineCollection {
  name: 'patient-vitals-temperature--deleted'
}
app.db.defineCollection {
  name: 'patient-vitals-bmi'
}

app.db.defineCollection {
  name: 'patient-vitals-bmi--deleted'
}

app.db.defineCollection {
  name: 'patient-test-blood-sugar'
}

app.db.defineCollection {
  name: 'patient-test-blood-sugar--deleted'
}
app.db.defineCollection {
  name: 'patient-test-other'
}

app.db.defineCollection {
  name: 'patient-test-other--deleted'
}
app.db.defineCollection {
  name: 'comment-patient'
}

app.db.defineCollection {
  name: 'comment-patient--deleted'
}

app.db.defineCollection {
  name: 'patient-consent-form'
}

app.db.defineCollection {
  name: 'patient-consent-form--deleted'
}

app.db.defineCollection {
  name: 'organization-settings'
}

app.db.defineCollection {
  name: 'organization-settings--deleted'
}

app.db.defineCollection {
  name: 'organization-accounts-income'
}

app.db.defineCollection {
  name: 'organization-accounts-income--deleted'
}

app.db.defineCollection {
  name: 'organization-accounts-clone-income'
}

app.db.defineCollection {
  name: 'organization-accounts-clone-income--deleted'
}

app.db.defineCollection {
  name: 'organization-accounts-expense'
}

app.db.defineCollection {
  name: 'organization-accounts-expense--deleted'
}

app.db.defineCollection {
  name: 'organization-accounts-income-categories'
}

app.db.defineCollection {
  name: 'organization-accounts-income-categories--deleted'
}

app.db.defineCollection {
  name: 'organization-accounts-expense-categories'
}

app.db.defineCollection {
  name: 'organization-accounts-expense-categories--deleted'
}

app.db.defineCollection {
  name: 'organization-message-share'
}

app.db.defineCollection {
  name: 'organization-message-share--deleted'
}

app.db.defineCollection {
  name: 'pharmacy-supplier-invoice'
}

app.db.defineCollection {
  name: 'pharmacy-supplier-invoice--deleted'
}
app.db.defineCollection {
  name: 'pharmacy-supplier-invoice-categories'
}

app.db.defineCollection {
  name: 'pharmacy-supplier-invoice-categories--deleted'
}

app.db.defineCollection {
  name: 'academic-session'
}

app.db.defineCollection {
  name: 'academic-session--deleted'
}

app.db.defineCollection {
  name: 'activity'
}

app.db.defineCollection {
  name: 'activity--deleted'
}




