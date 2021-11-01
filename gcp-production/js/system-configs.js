window.systemConfigs = {};

window.systemConfigs.exposeRootLibraryObjectToWindowLib = true;

window.systemConfigs.suppressClientSideErrorsInDevMode = false;

window.systemConfigs.liveApiServerPort = null;

window.systemConfigs.liveApiServerUrl = 'https://bdemr.services';

window.systemConfigs.liveServerPossibleUrls = ['https://bdemr.com', 'http://bdemr.com', 'https://www.bdemr.com', 'http://www.bdemr.com'];


/*
DEFAULTS:
requireApiKey : true
saveApiKey : false
destroyApiKey : false
hasData : true
schema : null
 */

window.systemConfigs.portalApiList = [
  {
    name: 'CallProcessClientErrorsApi',
    path: 'process-client-error',
    requireApiKey: false
  }, {
    name: 'CallDirectSignupApi',
    path: 'user-direct-signup-new',
    schema: 'directSignUp',
    requireApiKey: false
  }, {
    name: 'CallContactUsApi',
    path: 'contact-us',
    schema: 'contactUs',
    requireApiKey: false
  }, {
    name: 'CallEmailSubscriptionApi',
    path: 'subscribe-mail-list',
    schema: 'emailSubscription',
    requireApiKey: false
  }, {
    name: 'CallGetListOfAgentsApi',
    path: 'get-list-of-agents',
    requireApiKey: false,
    hasData: false
  }, {
    name: 'CallGetListOfDoctorApi',
    path: 'get-list-of-doctors',
    requireApiKey: false,
    hasData: false
  }, {
    name: 'CallGetDoctorPublicDetailsApi',
    path: 'get-doctor-public-details',
    requireApiKey: false
  }, {
    name: 'CallGetImageDataApi',
    path: 'get-image-data',
    requireApiKey: false
  }, {
    name: 'GetCountryList',
    path: 'get-country-list',
    hasData: false,
    requireApiKey: false
  }, {
    name: 'UserVerifyEmailWithToken',
    path: 'user-verify-email-with-token',
    hasData: true,
    requireApiKey: false
  }
];
