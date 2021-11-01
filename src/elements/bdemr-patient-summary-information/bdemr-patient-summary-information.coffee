Polymer {

  is: 'bdemr-patient-summary-information'

  behaviors: [
    app.behaviors.translating
    app.behaviors.commonComputes
  ]

  properties:
    patient:
      type: Object
      value: null

  editPatientBtnPressed: ()->
    @domHost.domHost.navigateToPage "#/patient-editor/patient:" + @patient.serial

  createPatientCardPressed: ()->
    @domHost.domHost.navigateToPage "#/print-patient-card/patient:" + @patient.serial
  
}