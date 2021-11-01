var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  slice = [].slice;

window.globallyExposed = {};

window.ClientLibrariesIsolatedScope = function(SystemInitCompleteCbfn) {
  var AjaxCallHandler, ApiGenerator, BasicObjectOperations, BasicOperationHelper, ClientErrorLogger, ClientStorageDataProcessing, DataSecurity, GenericApiCaller, GenericApiResponseHandler, LibraryConfigs, RootLibraryObject, Schema, SchemaObjectHandler, StringHandler, SystemInitializer, TopologicalSort, UrlManager, XhrHandler;
  RootLibraryObject = null;
  LibraryConfigs = (function() {
    function LibraryConfigs() {}

    LibraryConfigs.devApiServerPort = '8671';

    LibraryConfigs.devApiServerUrl = 'http://localhost';

    LibraryConfigs.devServerPossibleLocalUrls = ['http://localhost', 'https://localhost'];

    LibraryConfigs.apiKeyNameInStorage = 'app-apiKey';

    LibraryConfigs.apiKeyTimeInStorage = 'app-apiKeyTime';

    LibraryConfigs.schemaListInStorage = 'app-schemaList';

    LibraryConfigs.schemaListTimeInStorage = 'app-schemaListTime';

    LibraryConfigs.anaesmonLiveServerRedirectLink = 'https://anaesmon.com:1337/auto-login/';

    LibraryConfigs.autoDestroyApiKeyAfterInDays = 7;

    LibraryConfigs.autoDestroySchemaListAfterInHours = 2;

    LibraryConfigs.apiServerPartialUrl = '/api/1/';

    LibraryConfigs.apiServerSchemaListGetUrl = 'get-client-schemas';

    LibraryConfigs.schemaNameConstantString = 'schemaName';

    LibraryConfigs.errorsExemptedFromServerNotification = ['XML_HTTP_REQUEST_FAILED', 'XML_HTTP_REQUEST_ABORTED'];

    LibraryConfigs.errorsFromApiExemptedFromServerNotification = ['CallProcessClientErrorsApi'];

    LibraryConfigs.schemaInternalMethodNamesForSerialization = ['fn', 'mutationFn'];

    LibraryConfigs.defaultOptionsForPortalApiList = {
      'requireApiKey': true,
      'saveApiKey': false,
      'destroyApiKey': false,
      'hasData': true,
      'schema': null
    };

    return LibraryConfigs;

  })();
  BasicOperationHelper = (function() {
    function BasicOperationHelper() {}

    BasicOperationHelper.objectString = 'object';

    BasicOperationHelper.undefinedString = 'undefined';

    BasicOperationHelper.isNotNull = function(obj, propertyName) {
      if (propertyName === null || (typeof propertyName) === BasicOperationHelper.undefinedString) {
        if (obj === null || (typeof obj) === BasicOperationHelper.undefinedString) {
          return false;
        }
        return true;
      }
      if (obj[propertyName] === null || (typeof obj[propertyName]) === BasicOperationHelper.undefinedString) {
        return false;
      }
      return true;
    };

    BasicOperationHelper.cloneObj = function(obj) {
      var flags, key, newInstance, res;
      if ((obj == null) || typeof obj !== this.objectString) {
        return obj;
      }
      if (obj instanceof Date) {
        res = new Date(obj.getTime());
        return res;
      }
      if (obj instanceof RegExp) {
        flags = '';
        if (obj.global != null) {
          flags += 'g';
        }
        if (obj.ignoreCase != null) {
          flags += 'i';
        }
        if (obj.multiline != null) {
          flags += 'm';
        }
        if (obj.sticky != null) {
          flags += 'y';
        }
        return new RegExp(obj.source, flags);
      }
      newInstance = new obj.constructor();
      for (key in obj) {
        newInstance[key] = this.cloneObj(obj[key]);
      }
      return newInstance;
    };

    BasicOperationHelper.getXhrObject = function() {
      return new RootLibraryObject.utility.XhrHandler();
    };

    BasicOperationHelper.isRunningOnLiveServer = function() {
      var item, k, l, len1, len2, len3, len4, m, n, possibleLocationProperties, property, ref, ref1, res;
      res = false;
      possibleLocationProperties = ['href', 'origin'];
      for (k = 0, len1 = possibleLocationProperties.length; k < len1; k++) {
        property = possibleLocationProperties[k];
        if ((BasicOperationHelper.isNotNull(location, property)) === true) {
          ref = RootLibraryObject.systemConfigs.liveServerPossibleUrls;
          for (l = 0, len2 = ref.length; l < len2; l++) {
            item = ref[l];
            if ((location[property].search(item)) === 0) {
              res = true;
              break;
            }
          }
        }
      }
      for (m = 0, len3 = possibleLocationProperties.length; m < len3; m++) {
        property = possibleLocationProperties[m];
        if ((BasicOperationHelper.isNotNull(location, property)) === true) {
          ref1 = RootLibraryObject.libraryConfigs.devServerPossibleLocalUrls;
          for (n = 0, len4 = ref1.length; n < len4; n++) {
            item = ref1[n];
            if ((location[property].search(item)) === 0) {
              res = false;
              break;
            }
          }
        }
      }
      return res;
    };

    BasicOperationHelper.extractMethodParameterNames = function(methodReference) {
      var argumentNameRegex, fnStr, result, stripCommentsRegex;
      stripCommentsRegex = /(\/\/.*$)|(\/\*[\s\S]*?\*\/)|(\s*=[^,\)]*(('(?:\\'|[^'\r\n])*')|("(?:\\"|[^"\r\n])*"))|(\s*=[^,\)]*))/mg;
      argumentNameRegex = /([^\s,]+)/g;
      fnStr = methodReference.toString().replace(stripCommentsRegex, '');
      result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(argumentNameRegex);
      if (result === null) {
        result = [];
      }
      return result;
    };

    BasicOperationHelper.getCurTimeInMiliSec = function() {
      return (new Date()).getTime();
    };

    return BasicOperationHelper;

  })();
  SystemInitializer = (function() {
    function SystemInitializer() {}

    SystemInitializer.initializeRootLibraryObject = function() {
      var item, k, len1, ref, results;
      window.globallyExposed.cbfnListFromClientLibraries = [];
      RootLibraryObject = {};
      ref = ['apis', 'utility', 'schemas', 'systemConfigs', 'libraryConfigs'];
      results = [];
      for (k = 0, len1 = ref.length; k < len1; k++) {
        item = ref[k];
        if ((BasicOperationHelper.isNotNull(RootLibraryObject, item)) === false) {
          results.push(RootLibraryObject[item] = {});
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    SystemInitializer.doClientInitializationOperation = function() {
      var key, ref, value;
      if ((BasicOperationHelper.isNotNull(window, 'systemConfigs')) === false) {
        if (window.globallyExposed.systemInitiationComplete === true) {
          SystemInitCompleteCbfn(window.globallyExposed.rootLibraryObject);
        } else {
          window.globallyExposed.cbfnListFromClientLibraries.push(SystemInitCompleteCbfn);
        }
        return;
      }
      SystemInitializer.initializeRootLibraryObject();
      ref = window.systemConfigs;
      for (key in ref) {
        value = ref[key];
        RootLibraryObject.systemConfigs[key] = value;
      }
      delete window.systemConfigs;
      RootLibraryObject.libraryConfigs = LibraryConfigs;
      RootLibraryObject.utility.BasicOperationHelper = BasicOperationHelper;
      RootLibraryObject.utility.UrlManager = UrlManager;
      RootLibraryObject.utility.StringHandler = StringHandler;
      RootLibraryObject.utility.DataSecurity = DataSecurity;
      RootLibraryObject.utility.ClientErrorLogger = ClientErrorLogger;
      RootLibraryObject.utility.TopologicalSort = TopologicalSort;
      RootLibraryObject.utility.Schema = Schema;
      RootLibraryObject.utility.XhrHandler = XhrHandler;
      RootLibraryObject.utility.AjaxCallHandler = AjaxCallHandler;
      RootLibraryObject.utility.ClientStorageDataProcessing = ClientStorageDataProcessing;
      RootLibraryObject.utility.GenericApiCaller = GenericApiCaller;
      RootLibraryObject.utility.ApiGenerator = ApiGenerator;
      RootLibraryObject.utility.GenericApiResponseHandler = GenericApiResponseHandler;
      RootLibraryObject.utility.BasicObjectOperations = BasicObjectOperations;
      return new SchemaObjectHandler(SystemInitializer.systemInitFinished);
    };

    SystemInitializer.systemInitFinished = function() {
      var item, k, len1, ref;
      if ((BasicOperationHelper.isNotNull(SystemInitCompleteCbfn)) === false || (typeof SystemInitCompleteCbfn) !== 'function') {
        throw new Error('Please provide callback function for "ClientLibrariesIsolatedScope" global method.');
      }
      if (RootLibraryObject.systemConfigs.exposeRootLibraryObjectToWindowLib === true) {
        window.lib = RootLibraryObject;
      }
      window.globallyExposed.rootLibraryObject = RootLibraryObject;
      window.globallyExposed.systemInitiationComplete = true;
      SystemInitCompleteCbfn(RootLibraryObject);
      ref = window.globallyExposed.cbfnListFromClientLibraries;
      for (k = 0, len1 = ref.length; k < len1; k++) {
        item = ref[k];
        item(RootLibraryObject);
      }
      return window.globallyExposed.cbfnListFromClientLibraries = [];
    };

    return SystemInitializer;

  })();
  UrlManager = (function() {
    function UrlManager() {}

    UrlManager.getLocalApiServerRootUrl = function() {
      return RootLibraryObject.libraryConfigs.devApiServerUrl + ':' + RootLibraryObject.libraryConfigs.devApiServerPort;
    };

    UrlManager.getLiveApiServerRootUrl = function() {
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(RootLibraryObject.systemConfigs, 'liveApiServerPort')) === true) {
        return RootLibraryObject.systemConfigs.liveApiServerUrl + ':' + RootLibraryObject.systemConfigs.liveApiServerPort;
      }
      return RootLibraryObject.systemConfigs.liveApiServerUrl;
    };

    UrlManager.getApiServerRootUrl = function() {
      if (RootLibraryObject.utility.BasicOperationHelper.isRunningOnLiveServer() === true) {
        return UrlManager.getLiveApiServerRootUrl();
      } else {
        return UrlManager.getLocalApiServerRootUrl();
      }
    };

    return UrlManager;

  })();
  StringHandler = (function() {
    function StringHandler() {}

    StringHandler.htmlEscape = function(stringData) {
      return String(stringData).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/'/g, '&#39;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    };

    StringHandler.htmlUnescape = function(stringData) {
      return String(stringData).replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
    };

    StringHandler.onlyContainsDigits = function(stringData) {
      var i, k, len, ref, res;
      len = stringData.length;
      res = true;
      for (i = k = 0, ref = len; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        if (!(stringData.charCodeAt(i) >= '0'.charCodeAt(0) && stringData.charCodeAt(i) <= '9'.charCodeAt(0))) {
          return false;
        }
      }
      return true;
    };

    StringHandler.generateRandomString = function(randomStringLength) {
      var characterList, idx, item, k, l, len, m, n, randomString, ref;
      randomString = '';
      characterList = [];
      for (item = k = 0; k <= 25; item = ++k) {
        characterList.push(String.fromCharCode('a'.charCodeAt() + item));
      }
      for (item = l = 0; l <= 25; item = ++l) {
        characterList.push(String.fromCharCode('A'.charCodeAt() + item));
      }
      for (item = m = 0; m <= 9; item = ++m) {
        characterList.push(String.fromCharCode('0'.charCodeAt() + item));
      }
      len = characterList.length;
      for (item = n = 1, ref = randomStringLength; 1 <= ref ? n <= ref : n >= ref; item = 1 <= ref ? ++n : --n) {
        idx = (Math.floor(Math.random() * 10000363)) % 10000019;
        idx %= len;
        randomString += characterList[idx];
      }
      return randomString;
    };

    StringHandler.generateRandomNumericString = function(randomStringLength) {
      var characterList, idx, item, k, l, len, randomString, ref;
      randomString = '';
      characterList = [];
      for (item = k = 0; k <= 9; item = ++k) {
        characterList.push(String.fromCharCode('0'.charCodeAt() + item));
      }
      len = characterList.length;
      for (item = l = 1, ref = randomStringLength; 1 <= ref ? l <= ref : l >= ref; item = 1 <= ref ? ++l : --l) {
        idx = (Math.floor(Math.random() * 10000363)) % 10000019;
        idx %= len;
        randomString += characterList[idx];
      }
      return randomString;
    };

    StringHandler.replaceAllTheNewLineCharacters = function(dataString) {
      var i, k, len, ref, ref1, res;
      res = '';
      len = dataString.length;
      for (i = k = 0, ref = len; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        if ((ref1 = dataString.charCodeAt(i)) === 3 || ref1 === 4 || ref1 === 10 || ref1 === 13 || ref1 === 23 || ref1 === 25) {
          continue;
        }
        res += dataString.charAt(i);
      }
      return res;
    };

    StringHandler.trimEndingSpaces = function(dataString) {
      var i, idx, j, k, l, len, ref, ref1, ref2, res;
      res = '';
      len = dataString.length;
      idx = len;
      j = -1;
      for (i = k = 0, ref = len; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        idx--;
        if (!((ref1 = dataString.charCodeAt(idx)) === 32)) {
          j = idx;
          break;
        }
      }
      for (i = l = 0, ref2 = j; 0 <= ref2 ? l <= ref2 : l >= ref2; i = 0 <= ref2 ? ++l : --l) {
        res += dataString.charAt(i);
      }
      return res;
    };

    return StringHandler;

  })();
  DataSecurity = (function() {
    function DataSecurity() {}

    DataSecurity.hash = function(str) {
      return sjcl.codec.base64.fromBits(sjcl.hash.sha256.hash(str));
    };

    DataSecurity.encrypt = function(passPhrase, data) {
      return sjcl.encrypt(passPhrase, data);
    };

    DataSecurity.decrypt = function(passPhrase, sjclEncryptedObject) {
      return sjcl.decrypt(passPhrase, sjclEncryptedObject);
    };

    return DataSecurity;

  })();
  ClientErrorLogger = (function() {
    function ClientErrorLogger() {}

    ClientErrorLogger.genericApiResponseErrorCheck = function(responseObj, notifyServer) {
      var code, details, message, name, resolution;
      if (responseObj.hasError === true) {
        name = 'API_RESPONSE_ERROR';
        resolution = 'Error supplied from server due to invalid operation(s).';
        message = 'Api response has error.';
        code = 400;
        details = responseObj.error;
        if (notifyServer === true) {
          ClientErrorLogger.constructGenericErrorObjectAndNotifyServer(name, resolution, message, code, details);
        } else {
          ClientErrorLogger.constructGenericErrorObject(name, resolution, message, code, details);
        }
        return false;
      }
      return true;
    };

    ClientErrorLogger.handleErrorStackFromExceptionObject = function(exObj, message) {
      var errorStack, fileDetails, item, k, l, len1, len2, newErrorStack, nextIdx, res, stackItem;
      res = [];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(exObj, 'stack')) === true) {
        errorStack = exObj.stack;
        errorStack = errorStack.replace('Error: ' + message, '');
        errorStack = errorStack.split('at ');
        errorStack.splice(0, 3);
        newErrorStack = [];
        for (k = 0, len1 = errorStack.length; k < len1; k++) {
          item = errorStack[k];
          newErrorStack.push(RootLibraryObject.utility.StringHandler.trimEndingSpaces(RootLibraryObject.utility.StringHandler.replaceAllTheNewLineCharacters(item)));
        }
        errorStack = [];
        for (l = 0, len2 = newErrorStack.length; l < len2; l++) {
          item = newErrorStack[l];
          stackItem = {};
          nextIdx = 1;
          if ((item.split('(')).length === 1) {
            nextIdx = 0;
          } else {
            stackItem.methodDetails = RootLibraryObject.utility.StringHandler.trimEndingSpaces((item.split('('))[0]);
          }
          fileDetails = (item.split('('))[nextIdx];
          fileDetails = fileDetails.replace(')', '');
          fileDetails = fileDetails.split('/');
          fileDetails = fileDetails[fileDetails.length - 1];
          fileDetails = fileDetails.split(':');
          stackItem.fileName = fileDetails[0];
          stackItem.lineNumber = fileDetails[1];
          stackItem.columnNumber = fileDetails[2];
          errorStack.push(stackItem);
        }
        res = errorStack;
      }
      return res;
    };

    ClientErrorLogger.genericMethodParameterValueCheck = function(parameterList, methodName, className, exemptionPropertyList) {
      var key, value;
      for (key in parameterList) {
        value = parameterList[key];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(exemptionPropertyList)) === true) {
          if (indexOf.call(exemptionPropertyList, key) >= 0) {
            continue;
          }
        }
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(value)) === false) {
          RootLibraryObject.utility.ClientErrorLogger.reportMethodParameterMissingError(ClientErrorLogger.genericMethodParameterMissingErrorMessageConstruction(key, methodName, className));
          return false;
        }
      }
      return true;
    };

    ClientErrorLogger.genericMethodParameterMissingErrorMessageConstruction = function(parameterName, methodName, className) {
      return '"' + parameterName + '" parameter is missing in "' + methodName + '" method of "' + className + '" class. Proper value has not been supplied.';
    };

    ClientErrorLogger.notifyServerAboutTheClientError = function(errorObj) {
      var ref;
      if (RootLibraryObject.systemConfigs.suppressClientSideErrorsInDevMode === true) {
        return;
      }
      if ((ref = errorObj.name, indexOf.call(RootLibraryObject.libraryConfigs.errorsExemptedFromServerNotification, ref) >= 0) === false) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(RootLibraryObject.apis, 'CallProcessClientErrorsApi')) === true) {
          return RootLibraryObject.apis.CallProcessClientErrorsApi(errorObj, function(responseObj) {
            if (RootLibraryObject.utility.BasicOperationHelper.isRunningOnLiveServer() === false) {
              if (responseObj.hasError === false) {
                return console.log('DEV_MESSAGE:', responseObj.data);
              }
            }
          });
        }
      }
    };

    ClientErrorLogger.constructGenericErrorObject = function(name, resolution, message, code, details) {
      var errorObj, exObj;
      errorObj = {};
      errorObj.name = name;
      errorObj.resolution = resolution;
      errorObj.message = message;
      errorObj.code = code;
      errorObj.type = 'CLIENT';
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(details)) === true) {
        errorObj.details = details;
      }
      try {
        throw new Error(message);
      } catch (error1) {
        exObj = error1;
        errorObj.stack = ClientErrorLogger.handleErrorStackFromExceptionObject(exObj, message);
      }
      if (RootLibraryObject.utility.BasicOperationHelper.isRunningOnLiveServer() === false) {
        if (RootLibraryObject.systemConfigs.suppressClientSideErrorsInDevMode === false) {
          console.log('DEV_MESSAGE:', errorObj);
        }
      }
      return errorObj;
    };

    ClientErrorLogger.constructGenericErrorObjectAndNotifyServer = function(name, resolution, message, code, details) {
      var errorObj;
      errorObj = ClientErrorLogger.constructGenericErrorObject(name, resolution, message, code, details);
      return ClientErrorLogger.notifyServerAboutTheClientError(errorObj);
    };

    ClientErrorLogger.reportSevereError = function(message) {
      return ClientErrorLogger.constructGenericErrorObjectAndNotifyServer('SEVERE_ERROR', 'Please contact the site developer to fix this error immediately.', message, 500);
    };

    ClientErrorLogger.reportMethodParameterMissingError = function(message) {
      return ClientErrorLogger.constructGenericErrorObjectAndNotifyServer('METHOD_PARAMETER_MISSING_ERROR', 'Please provide value in correct format in method parameter.', message, 500);
    };

    ClientErrorLogger.reportXmlHttpError = function(name, message, code, details) {
      return ClientErrorLogger.constructGenericErrorObjectAndNotifyServer(name, 'Problem with internet connectivity with the server. Please connect to the internet or reset the internet connection.', message, code, details);
    };

    ClientErrorLogger.reportSchemaFailureError = function(name, message, code, details) {
      return ClientErrorLogger.constructGenericErrorObjectAndNotifyServer(name, 'Supplied data has failed to pass though the schema definitions.', message, code, details);
    };

    return ClientErrorLogger;

  })();

  /*
  The schema and TopologicalSort class is taken from 'schema-engine' repository. The exports and other library uses are converted to respective client libraries under RootLibraryObject.
   */
  TopologicalSort = (function() {
    TopologicalSort.graphAdjList = null;

    TopologicalSort.timeCounter = null;

    function TopologicalSort() {
      this._runThirdDfs = bind(this._runThirdDfs, this);
      this._runSecondDfs = bind(this._runSecondDfs, this);
      this._runFirstDfs = bind(this._runFirstDfs, this);
      this._buildChildListFromSchema = bind(this._buildChildListFromSchema, this);
      this._clearGraph();
    }

    TopologicalSort.prototype._clearGraph = function() {
      this.graphAdjList = {};
      this.reverseGraphAdjList = {};
      this.visitedProperties = {};
      this.vis = [];
      this.timeCounter = 1;
      this.rootPropertyName = 'ROOT_OBJECT';
      this.globalSchemaJsonSignature = {};
      this.propertyChildList = {};
      return this.propertyPathList = {};
    };

    TopologicalSort.prototype._addNewDirectedEdge = function(source, destination) {
      if (source === destination) {
        return;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.graphAdjList, source)) === false) {
        this.graphAdjList[source] = [];
      }
      this.graphAdjList[source].push(destination);
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.reverseGraphAdjList, destination)) === false) {
        this.reverseGraphAdjList[destination] = [];
      }
      return this.reverseGraphAdjList[destination].push(source);
    };

    TopologicalSort.prototype.passSchemaJsonSignature = function(schemaJsonSignature) {
      this.globalSchemaJsonSignature = schemaJsonSignature;
      this.visitedProperties = {};
      return this._buildChildListFromSchema(this.globalSchemaJsonSignature, [this.rootPropertyName], this.rootPropertyName);
    };

    TopologicalSort.prototype._calculatePropertyPath = function(parameterList, parentList) {
      var computeChildList, computeParentList, item, k, len1, numberOfParents, paramPathList, requiredParentList, singleParameter, wholePathFromRoot;
      paramPathList = [];
      for (k = 0, len1 = parameterList.length; k < len1; k++) {
        singleParameter = parameterList[k];
        if (singleParameter === '.') {
          wholePathFromRoot = (function() {
            var l, len2, results;
            results = [];
            for (l = 0, len2 = parentList.length; l < len2; l++) {
              item = parentList[l];
              results.push(item);
            }
            return results;
          })();
          paramPathList.push(wholePathFromRoot);
          continue;
        }
        computeParentList = singleParameter.split('^');
        numberOfParents = computeParentList.length - 1;
        computeChildList = computeParentList[computeParentList.length - 1].split('.');
        requiredParentList = parentList.slice(0, parentList.length - numberOfParents);
        requiredParentList = requiredParentList.slice(1, requiredParentList.length);
        if (computeChildList.length === 1 && computeChildList[0] === '') {
          wholePathFromRoot = requiredParentList;
        } else {
          wholePathFromRoot = requiredParentList.concat(computeChildList);
        }
        paramPathList.push(wholePathFromRoot);
      }
      return paramPathList;
    };

    TopologicalSort.prototype._buildChildListFromSchema = function(schemaJsonSignature, parentList, currentPropertyName) {
      var childObject, currentNodeChildList, item, newParentList, newPropertyName, schemaObject;
      currentNodeChildList = [];
      childObject = {};
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature, 'map')) === true) {
        childObject = schemaJsonSignature.map;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature, 'def')) === true) {
        childObject = schemaJsonSignature.def;
      }
      for (newPropertyName in childObject) {
        schemaObject = childObject[newPropertyName];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, newPropertyName)) === false) {
          this.visitedProperties[newPropertyName] = true;
          this._addNewDirectedEdge(currentPropertyName, newPropertyName);
          currentNodeChildList.push(newPropertyName);
          newParentList = (function() {
            var k, len1, results;
            results = [];
            for (k = 0, len1 = parentList.length; k < len1; k++) {
              item = parentList[k];
              results.push(item);
            }
            return results;
          })();
          newParentList.push(newPropertyName);
          this._buildChildListFromSchema(schemaObject, newParentList, newPropertyName);
          this._buildChildListFromCustomFunctionParams(schemaObject, newParentList, newPropertyName);
          this._buildChildListFromValidationParams(schemaObject, newParentList, newPropertyName);
        }
      }
      this.propertyChildList[currentPropertyName] = currentNodeChildList;
      return this.propertyPathList[currentPropertyName] = parentList;
    };

    TopologicalSort.prototype._buildChildListFromValidationParams = function(schemaJsonSignature, parentList, sourcePropertyName) {
      var destinationPropertyName, item, k, len1, paramPathList, results;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature, 'validation')) === true) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature.validation, 'custom')) === true) {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature.validation.custom, 'params')) === true) {
            paramPathList = this._calculatePropertyPath(schemaJsonSignature.validation.custom.params, parentList);
            results = [];
            for (k = 0, len1 = paramPathList.length; k < len1; k++) {
              item = paramPathList[k];
              destinationPropertyName = item[item.length - 1];
              results.push(this._addNewDirectedEdge(sourcePropertyName, destinationPropertyName));
            }
            return results;
          }
        }
      }
    };

    TopologicalSort.prototype._buildChildListFromCustomFunctionParams = function(schemaJsonSignature, parentList, sourcePropertyName) {
      var destinationPropertyName, item, k, len1, paramPathList, results;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature, 'compute')) === true) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignature.compute, 'params')) === true) {
          paramPathList = this._calculatePropertyPath(schemaJsonSignature.compute.params, parentList);
          results = [];
          for (k = 0, len1 = paramPathList.length; k < len1; k++) {
            item = paramPathList[k];
            destinationPropertyName = item[item.length - 1];
            results.push(this._addNewDirectedEdge(sourcePropertyName, destinationPropertyName));
          }
          return results;
        }
      }
    };

    TopologicalSort.prototype._runFirstDfs = function(parentPropertyName) {
      var child, childList, k, len1;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, parentPropertyName)) === true) {
        return;
      }
      this.visitedProperties[parentPropertyName] = this.timeCounter;
      childList = this.graphAdjList[parentPropertyName];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(childList)) === true) {
        for (k = 0, len1 = childList.length; k < len1; k++) {
          child = childList[k];
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, child)) === false) {
            this._runFirstDfs(child);
          }
        }
      }
      this.orderedNodeList.push({
        'property': parentPropertyName,
        'timeCounterValue': this.timeCounter
      });
      return this.timeCounter++;
    };

    TopologicalSort.prototype._runSecondDfs = function(parentPropertyName, color) {
      var child, childList, k, len1, results;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.coloredProperties, parentPropertyName)) === true) {
        return;
      }
      this.coloredProperties[parentPropertyName] = color;
      childList = this.reverseGraphAdjList[parentPropertyName];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(childList)) === true) {
        results = [];
        for (k = 0, len1 = childList.length; k < len1; k++) {
          child = childList[k];
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.coloredProperties, child)) === false) {
            results.push(this._runSecondDfs(child, color));
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    };

    TopologicalSort.prototype._runThirdDfs = function(parentPropertyName, color) {
      var child, childList, error, k, len1, results;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, parentPropertyName)) === true) {
        return;
      }
      this.visitedProperties[parentPropertyName] = color;
      childList = this.graphAdjList[parentPropertyName];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(childList)) === true) {
        results = [];
        for (k = 0, len1 = childList.length; k < len1; k++) {
          child = childList[k];
          if (((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, child)) === false) && (this.coloredProperties[child] === color)) {
            results.push(this._runThirdDfs(child, color));
          } else if (((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.visitedProperties, child)) === true) && (this.visitedProperties[child] === color)) {
            error = new Error;
            error.errorDetails = 'Cycle found in topological sorting.';
            throw error;
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    };

    TopologicalSort.prototype.runTopologicalSort = function() {
      var color, k, l, len1, len2, len3, m, obj, ref, ref1, ref2, res;
      this.orderedNodeList = [];
      this.visitedProperties = {};
      this._runFirstDfs(this.rootPropertyName);
      this.orderedNodeList = this.orderedNodeList.sort(function(left, right) {
        return left.timeCounterValue - right.timeCounterValue;
      });
      res = [];
      ref = this.orderedNodeList;
      for (k = 0, len1 = ref.length; k < len1; k++) {
        obj = ref[k];
        res.push({
          'propertyName': obj.property,
          'pathList': this.propertyPathList[obj.property]
        });
      }
      this.orderedNodeList = this.orderedNodeList.sort(function(left, right) {
        return right.timeCounterValue - left.timeCounterValue;
      });
      this.coloredProperties = {};
      color = 1;
      ref1 = this.orderedNodeList;
      for (l = 0, len2 = ref1.length; l < len2; l++) {
        obj = ref1[l];
        this._runSecondDfs(obj.property, color);
        color++;
      }
      this.visitedProperties = {};
      ref2 = this.orderedNodeList;
      for (m = 0, len3 = ref2.length; m < len3; m++) {
        obj = ref2[m];
        this._runThirdDfs(obj.property, this.coloredProperties[obj.property]);
      }
      this._clearGraph();
      return res;
    };

    return TopologicalSort;

  })();
  Schema = (function() {
    Schema.prototype.self = {};

    function Schema(jsonSignature, options) {
      if (jsonSignature == null) {
        jsonSignature = {};
      }
      if (options == null) {
        options = {};
      }
      this.extract = bind(this.extract, this);
      this._operateOnEachInstanceOfAProperty = bind(this._operateOnEachInstanceOfAProperty, this);
      this._extractMethodExecution = bind(this._extractMethodExecution, this);
      this._checkForValidation = bind(this._checkForValidation, this);
      this.isValid = bind(this.isValid, this);
      this._checkForRequiredPropertiesRecursively = bind(this._checkForRequiredPropertiesRecursively, this);
      this._checkForValidationPropertiesOutsideOfValidationObject = bind(this._checkForValidationPropertiesOutsideOfValidationObject, this);
      this._checkForRequiredValidationPropertiesRecursively = bind(this._checkForRequiredValidationPropertiesRecursively, this);
      this._calculateMapOrderedKeyList = bind(this._calculateMapOrderedKeyList, this);
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(options, 'suppressCyclicDataErrors')) === false) {
        options.suppressCyclicDataErrors = false;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(options, 'ignoreUnidentifiedData')) === false) {
        options.ignoreUnidentifiedData = false;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(options, 'alwaysEscapeHtml')) === false) {
        options.alwaysEscapeHtml = false;
      }
      jsonSignature = this._checkForRequiredPropertiesRecursively(jsonSignature);
      this.schemaOptions = options;
      this.schemaJsonSignature = jsonSignature;
      this._calculateMapOrderedKeyList(jsonSignature);
      this.topoSortObj = new RootLibraryObject.utility.TopologicalSort();
      this.topoSortObj.passSchemaJsonSignature(this.schemaJsonSignature);
      this.orderedPropertyListWithPath = this.topoSortObj.runTopologicalSort();
      return null;
    }

    Schema.prototype._calculateMapOrderedKeyList = function(jsonSignature) {
      var childProperty, childValue, ref, ref1, results;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'map')) === true) {
        jsonSignature.__mapOrderedKeyList = [];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'customEvaluationOrder')) === true) {
          jsonSignature.__mapOrderedKeyList = jsonSignature.customEvaluationOrder;
        }
        ref = jsonSignature.map;
        for (childProperty in ref) {
          childValue = ref[childProperty];
          if (indexOf.call(jsonSignature.__mapOrderedKeyList, childProperty) >= 0) {
            continue;
          }
          if ('compute' in childValue) {
            jsonSignature.__mapOrderedKeyList.push(childProperty);
          } else {
            jsonSignature.__mapOrderedKeyList.unshift(childProperty);
          }
        }
        ref1 = jsonSignature.map;
        results = [];
        for (childProperty in ref1) {
          childValue = ref1[childProperty];
          results.push(this._calculateMapOrderedKeyList(childValue));
        }
        return results;
      }
    };

    Schema.prototype._checkForRequiredValidationPropertiesRecursively = function(jsonSignature) {
      var err, item, k, key, l, len1, len2, ref, ref1, res, value;
      for (key in jsonSignature) {
        value = jsonSignature[key];
        if (key === 'OR') {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(value)) === false) {
            jsonSignature[key] = [];
          } else {
            res = [];
            ref = jsonSignature[key];
            for (k = 0, len1 = ref.length; k < len1; k++) {
              item = ref[k];
              res.push(this._checkForRequiredValidationPropertiesRecursively(item));
            }
            jsonSignature[key] = res;
          }
        }
        if (key === 'AND') {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(value)) === false) {
            jsonSignature[key] = [];
          } else {
            res = [];
            ref1 = jsonSignature[key];
            for (l = 0, len2 = ref1.length; l < len2; l++) {
              item = ref1[l];
              res.push(this._checkForRequiredValidationPropertiesRecursively(item));
            }
            jsonSignature[key] = res;
          }
        }
        if (key === 'NOT') {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(value)) === false) {
            jsonSignature[key] = {};
          }
        }
        if (key === 'custom') {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature[key], 'fn')) === false) {
            err = new Error;
            err.errorDetails = 'No function defined for custom validation property.';
            throw err;
          }
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature[key], 'params')) === false) {
            err = new Error;
            err.errorDetails = 'No params defined for custom validation property.';
            throw err;
          }
        }
      }
      return jsonSignature;
    };

    Schema.prototype._checkForValidationPropertiesOutsideOfValidationObject = function(jsonSignature) {
      var key, obj, res, val, validationKeywords, value;
      validationKeywords = ['minLength', 'maxLength', 'OR', 'NOT', 'AND', 'message'];
      res = {};
      for (key in jsonSignature) {
        value = jsonSignature[key];
        if (indexOf.call(validationKeywords, key) >= 0) {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature.validation, 'AND')) === false) {
            val = jsonSignature.validation;
            jsonSignature.validation = {};
            jsonSignature.validation.AND = [];
            if ((JSON.stringify(val)) !== '{}') {
              jsonSignature.validation.AND.push(val);
            }
          }
          obj = {};
          obj[key] = value;
          jsonSignature.validation.AND.push(obj);
        } else {
          res[key] = value;
        }
      }
      res.validation = jsonSignature.validation;
      return res;
    };

    Schema.prototype._checkForRequiredPropertiesRecursively = function(jsonSignature) {
      var key, ref, value;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'allowNull')) === false) {
        jsonSignature.allowNull = true;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'validation')) === false) {
        jsonSignature.validation = {};
      }
      jsonSignature.validation = this._checkForRequiredValidationPropertiesRecursively(jsonSignature.validation);
      jsonSignature = this._checkForValidationPropertiesOutsideOfValidationObject(jsonSignature);
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'type')) === false) {
        jsonSignature.type = RootLibraryObject.utility.BasicOperationHelper.objectString;
      }
      if (jsonSignature.type === RootLibraryObject.utility.BasicOperationHelper.objectString && (jsonSignature.map === null || (typeof jsonSignature.map) === RootLibraryObject.utility.BasicOperationHelper.undefinedString)) {
        jsonSignature.map = {};
      }
      if (jsonSignature.type === 'literal') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'minLength')) === false) {
          jsonSignature.minLength = 0;
        }
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'maxLength')) === false) {
          jsonSignature.maxLength = Number.POSITIVE_INFINITY;
        }
      }
      if (jsonSignature.type === 'number') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'minLength')) === false) {
          jsonSignature.minLength = Number.NEGATIVE_INFINITY;
        }
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature, 'maxLength')) === false) {
          jsonSignature.maxLength = Number.POSITIVE_INFINITY;
        }
      }
      ref = jsonSignature.map;
      for (key in ref) {
        value = ref[key];
        jsonSignature.map[key] = this._checkForRequiredPropertiesRecursively(value);
      }
      return jsonSignature;
    };

    Schema.prototype._isOfValidLength = function(propertyName, dataString, minLength, maxLength) {
      var error;
      if ((typeof dataString) === 'number') {
        dataString = '' + dataString;
      }
      error = new Error;
      if (dataString === null) {
        error.errorDetails = 'null value supplied in "dataString" parameter for "_isOfValidLength" method';
        throw error;
      }
      if (minLength !== null && (typeof minLength) === 'number' && dataString.length < minLength) {
        error.errorDetails = 'Minimum length not satisfied of ' + propertyName + '. Expected length of at least ' + minLength + ' and received a length of ' + dataString.length;
        throw error;
      }
      if (minLength !== null && (typeof maxLength) === 'number' && dataString.length > maxLength) {
        error.errorDetails = 'Maximum length not satisfied of ' + propertyName + '. Expected length of at most ' + maxLength + ' and received a length of ' + dataString.length;
        throw error;
      }
      return true;
    };

    Schema.prototype._isValidEmail = function(emailAddress) {
      var emailRegex;
      emailRegex = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
      return emailRegex.test(emailAddress);
    };

    Schema.prototype.isValid = function(suppliedObject) {
      var ex;
      try {
        this.extract(suppliedObject);
        return true;
      } catch (error1) {
        ex = error1;
        return false;
      }
    };

    Schema.prototype._checkForValidationOfLiteralType = function(validationObj, value, key) {
      var ex, returnObj;
      returnObj = {};
      returnObj.res = [];
      returnObj.errorDetails = [];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(value)) === false) {
        return returnObj;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'minLength')) === true || (RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'maxLength')) === true) {
        try {
          this._isOfValidLength(key, '' + value, validationObj.minLength, validationObj.maxLength);
        } catch (error1) {
          ex = error1;
          returnObj.errorDetails.push({
            message: ex.errorDetails,
            code: 'ERR_UNDECIDED',
            origin: 'system'
          });
          returnObj.res.push(false);
        }
      }
      return returnObj;
    };

    Schema.prototype._checkForValidationOfStringType = function(validationObj, value, key, schemaObjectType) {
      var itemString, k, l, len1, len2, ref, ref1, returnObj;
      returnObj = {};
      returnObj.res = [];
      returnObj.errorDetails = [];
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'validateAs')) === true && validationObj.validateAs === 'email') {
        if (this._isValidEmail(value) === false) {
          returnObj.errorDetails.push({
            message: 'Email not in valid format.',
            code: 'ERR_UNDECIDED',
            origin: 'validation'
          });
          returnObj.res.push(false);
        } else {
          returnObj.res.push(true);
        }
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'matchesExactly')) === true) {
        if (value !== validationObj.matchesExactly) {
          returnObj.errorDetails.push({
            message: 'Supplied string value doesn\'t match with expected string "' + validationObj.matchesExactly + '".',
            code: 'ERR_UNDECIDED',
            origin: 'system'
          });
        }
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'startsWith')) === true) {
        if (value.indexOf(validationObj.startsWith !== 0)) {
          returnObj.errorDetails.push({
            message: 'Supplied string value doesn\'t start with expected string "' + validationObj.startsWith + '".',
            code: 'ERR_UNDECIDED',
            origin: 'system'
          });
        }
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'endsWith')) === true) {
        if (value.indexOf(validationObj.endsWith !== (value.length - validationObj.endsWith.length))) {
          returnObj.errorDetails.push({
            message: 'Supplied string value doesn\'t end with expected string "' + validationObj.endsWith + '".',
            code: 'ERR_UNDECIDED',
            origin: 'system'
          });
        }
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'contains')) === true) {
        if ((typeof validationObj.contains) === 'string') {
          validationObj.contains = [validationObj.contains];
        }
        ref = validationObj.contains;
        for (k = 0, len1 = ref.length; k < len1; k++) {
          itemString = ref[k];
          if ((value.indexOf(itemString)) === -1) {
            returnObj.errorDetails.push({
              message: 'Supplied string value doesn\'t contain expected string "' + itemString + '".',
              code: 'ERR_UNDECIDED',
              origin: 'system'
            });
            returnObj.res.push(false);
          } else {
            returnObj.res.push(true);
          }
        }
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'doesNotContain')) === true) {
        ref1 = validationObj.doesNotContain;
        for (l = 0, len2 = ref1.length; l < len2; l++) {
          itemString = ref1[l];
          if (value.indexOf(itemString !== -1)) {
            returnObj.errorDetails.push({
              message: 'Supplied string value contains unexpected string "' + itemString + '".',
              code: 'ERR_UNDECIDED',
              origin: 'system'
            });
          }
        }
      }
      return returnObj;
    };

    Schema.prototype._calculatePropertyValueFromParamList = function(parameterList, currentValue, parentList, arrayIndexUsage) {
      var childPropertyName, computeChildList, computeParentList, item, k, l, len1, len2, len3, m, numberOfParents, obj, paramValues, requiredParentList, singleParameter, wholePathFromRoot;
      paramValues = [];
      for (k = 0, len1 = parameterList.length; k < len1; k++) {
        singleParameter = parameterList[k];
        if (singleParameter === '.') {
          paramValues.push(currentValue);
          continue;
        }
        computeParentList = singleParameter.split('^');
        numberOfParents = computeParentList.length - 1;
        computeChildList = computeParentList[computeParentList.length - 1].split('.');
        requiredParentList = parentList.slice(0, parentList.length - numberOfParents);
        if (computeChildList.length === 1 && computeChildList[0] === '') {
          wholePathFromRoot = requiredParentList;
        } else {
          wholePathFromRoot = requiredParentList.concat(computeChildList);
        }
        obj = RootLibraryObject.utility.BasicOperationHelper.cloneObj(this.globalRes);
        for (l = 0, len2 = wholePathFromRoot.length; l < len2; l++) {
          childPropertyName = wholePathFromRoot[l];
          if (childPropertyName === 'ARRAY-ITEM') {
            continue;
          }
          obj = obj[childPropertyName];
          for (m = 0, len3 = arrayIndexUsage.length; m < len3; m++) {
            item = arrayIndexUsage[m];
            if (item.property === childPropertyName) {
              obj = obj[item.index];
            }
          }
        }
        paramValues.push(obj);
      }
      return paramValues;
    };

    Schema.prototype._calculatePropertyValueFromPathList = function(pathList) {
      var k, len1, obj, pathItem;
      pathList = pathList.slice(1, pathList.length);
      obj = RootLibraryObject.utility.BasicOperationHelper.cloneObj(this.globalSuppliedObject);
      if (pathList.length === 0) {
        return obj;
      }
      for (k = 0, len1 = pathList.length; k < len1; k++) {
        pathItem = pathList[k];
        if (pathItem === 'ARRAY-ITEM') {
          continue;
        }
        obj = obj[pathItem];
      }
      return obj;
    };

    Schema.prototype._setValueToProperty = function(pathList, val, res, isArray) {
      var fl, i, newPathList, obj, pathItem;
      if (pathList.length === 0) {
        res = val;
        return val;
      }
      pathItem = pathList[0];
      newPathList = pathList.slice(1, pathList.length);
      if (pathItem === 'ARRAY-ITEM') {
        res = [];
        res[pathItem] = this._setValueToProperty(newPathList, val, res, true);
      } else if (isArray === true) {
        fl = 0;
        obj = res;
        i = 0;
        while (i < pathItem) {
          obj.push({});
          i++;
        }
        res[pathItem] = this._setValueToProperty(newPathList, val, obj[pathItem], false);
      } else {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res, pathItem)) === false) {
          res[pathItem] = {};
        }
        res[pathItem] = this._setValueToProperty(newPathList, val, res[pathItem], false);
      }
      return res;
    };

    Schema.prototype._calculatePropertySignatureFromPathList = function(pathList, jsonSignature) {
      var error, newPathList;
      pathList = pathList.slice(1, pathList.length);
      if (pathList.length === 0) {
        return jsonSignature;
      }
      if (jsonSignature.type === 'object') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature.map, pathList[0])) === false) {
          error = new Error;
          error.errorDetails = 'No json signature map found for ' + pathList[0] + ' property.';
          throw error;
        }
        newPathList = pathList.slice(1, pathList.length);
        return this._calculatePropertySignatureFromPathList(newPathList, jsonSignature.map[pathList[0]]);
      } else if (jsonSignature.type === 'array') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(jsonSignature.def, pathList[0])) === false) {
          error = new Error;
          error.errorDetails = 'No json signature map found for ' + pathList[0] + ' property.';
          throw error;
        }
        newPathList = pathList.slice(1, pathList.length);
        return this._calculatePropertySignatureFromPathList(newPathList, jsonSignature.def[pathList[0]]);
      }
      error = new Error;
      error.errorDetails = 'Invalid path list found in \'_calculatePropertySignatureFromPathList\' method. Path list wanted to go beyond the primitive data type in json signature.';
      throw error;
    };

    Schema.prototype._checkForValidation = function(validationObj, value, key, schemaObjectType, parentList, arrayIndexUsage) {
      var andResult, arrayItem, curResult, customFunctionResult, customMessage, err, errorMessage, ex, item, k, l, len1, len2, len3, len4, len5, len6, m, n, notResult, o, orResult, p, paramValues, property, propertyName, propertyValue, r1, ref, ref1, ref2, returnObj, tempErrorDetails;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(validationObj, 'message')) === true) {
        errorMessage = validationObj.message;
      } else {
        errorMessage = '';
      }
      returnObj = {};
      returnObj.res = [];
      returnObj.errorDetails = [];
      for (propertyName in validationObj) {
        propertyValue = validationObj[propertyName];
        if (propertyName === 'AND') {
          andResult = true;
          tempErrorDetails = [];
          for (k = 0, len1 = propertyValue.length; k < len1; k++) {
            item = propertyValue[k];
            r1 = this._checkForValidation(item, value, key, schemaObjectType, parentList, arrayIndexUsage);
            curResult = true;
            ref = r1.res;
            for (l = 0, len2 = ref.length; l < len2; l++) {
              arrayItem = ref[l];
              andResult &= arrayItem;
              curResult &= arrayItem;
            }
            if (curResult === false || curResult === 0) {
              tempErrorDetails = tempErrorDetails.concat(r1.errorDetails);
            }
          }
          if (andResult === 0 || andResult === false) {
            andResult = false;
          } else {
            andResult = true;
          }
          if (andResult === false) {
            returnObj.errorDetails = returnObj.errorDetails.concat(tempErrorDetails);
          }
          returnObj.res.push(andResult);
        } else if (propertyName === 'OR') {
          orResult = false;
          tempErrorDetails = [];
          for (m = 0, len3 = propertyValue.length; m < len3; m++) {
            item = propertyValue[m];
            r1 = this._checkForValidation(item, value, key, schemaObjectType, parentList, arrayIndexUsage);
            curResult = false;
            ref1 = r1.res;
            for (n = 0, len4 = ref1.length; n < len4; n++) {
              arrayItem = ref1[n];
              orResult |= arrayItem;
              curResult |= arrayItem;
            }
            if (curResult === false || curResult === 0) {
              tempErrorDetails = tempErrorDetails.concat(r1.errorDetails);
            }
            if (orResult === 0 || orResult === false) {
              orResult = false;
            } else {
              orResult = true;
            }
          }
          if (orResult === false) {
            returnObj.errorDetails = returnObj.errorDetails.concat(tempErrorDetails);
          }
          returnObj.res.push(orResult);
        } else if (propertyName === 'NOT') {
          property = null;
          tempErrorDetails = [];
          notResult = true;
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'OR')) === true) {
            notResult = false;
            property = propertyValue.OR;
          } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'AND')) === true) {
            notResult = true;
            property = propertyValue.AND;
          }
          if (property !== null) {
            for (o = 0, len5 = property.length; o < len5; o++) {
              item = property[o];
              r1 = this._checkForValidation(item, value, key, schemaObjectType, parentList, arrayIndexUsage);
              if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'OR')) === true) {
                curResult = false;
              } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'AND')) === true) {
                curResult = true;
              }
              ref2 = r1.res;
              for (p = 0, len6 = ref2.length; p < len6; p++) {
                arrayItem = ref2[p];
                if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'OR')) === true) {
                  notResult |= arrayItem;
                  curResult |= arrayItem;
                } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(propertyValue, 'AND')) === true) {
                  notResult &= arrayItem;
                  curResult &= arrayItem;
                }
              }
              if (notResult === false || notResult === 0) {
                notResult = false;
              } else {
                notResult = true;
              }
              if (curResult === false || curResult === 0) {
                tempErrorDetails = tempErrorDetails.concat(r1.errorDetails);
              }
            }
            notResult = !notResult;
            if (notResult === 0 || notResult === false) {
              notResult = false;
            } else {
              notResult = true;
            }
          }
          if (notResult === false) {
            returnObj.errorDetails = returnObj.errorDetails.concat(tempErrorDetails);
          }
          returnObj.res.push(notResult);
        } else if (propertyName === 'custom') {
          customMessage = propertyValue.message;
          paramValues = this._calculatePropertyValueFromParamList(propertyValue.params, value, parentList, arrayIndexUsage);
          try {
            customFunctionResult = propertyValue.fn.apply({}, paramValues);
            if (!(customFunctionResult === true || customFunctionResult === false)) {
              err = new Error;
              err.errorDetails = 'Unrecognized value returned from custom validator function of "' + key + '" property. Expected the value to be boolean.';
              throw err;
            }
          } catch (error1) {
            ex = error1;
            customFunctionResult = false;
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(ex, 'customErrorMessage')) === true) {
              returnObj.errorDetails.push({
                message: ex.customErrorMessage,
                code: 'ERR_UNDECIDED',
                origin: 'custom-fn'
              });
            }
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(ex, 'errorDetails')) === true) {
              returnObj.errorDetails.push({
                message: 'Error thrown from custom validator function of "' + key + '" property.',
                code: 'ERR_UNDECIDED',
                origin: 'system'
              });
              returnObj.errorDetails.push({
                message: ex.errorDetails,
                code: 'ERR_UNDECIDED',
                origin: 'system'
              });
            }
          }
          returnObj.res.push(customFunctionResult);
          if (customFunctionResult === false) {
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(customMessage)) === true) {
              returnObj.errorDetails.push({
                message: customMessage,
                code: 'ERR_UNDECIDED',
                origin: 'user'
              });
            }
          }
        } else {
          if (schemaObjectType === 'literal' || schemaObjectType === 'string' || schemaObjectType === 'number' || schemaObjectType === 'float' || schemaObjectType === 'integer') {
            r1 = this._checkForValidationOfLiteralType(validationObj, value, key);
            returnObj.res = returnObj.res.concat(r1.res);
            returnObj.errorDetails = returnObj.errorDetails.concat(r1.errorDetails);
          }
          if (schemaObjectType === 'string') {
            r1 = this._checkForValidationOfStringType(validationObj, value, key);
            returnObj.res = returnObj.res.concat(r1.res);
            returnObj.errorDetails = returnObj.errorDetails.concat(r1.errorDetails);
          }
        }
      }
      return returnObj;
    };

    Schema.prototype._updateErrorDetailsObject = function(errorDetails, errorDetailsMessagesPath, parentList, propertyName, errorMessageList) {
      var errorMessagePathItem, i, item, k, l, len1, newErrorDetailsMessagesPath, newErrorMessageList, newParentList, newSz, obj, parentItem, parentListCopy, ref, sz;
      if (errorMessageList.length === 0) {
        return errorDetails;
      }
      parentListCopy = (function() {
        var k, len1, results;
        results = [];
        for (k = 0, len1 = parentList.length; k < len1; k++) {
          item = parentList[k];
          results.push(item);
        }
        return results;
      })();
      newParentList = parentListCopy.slice(1, parentListCopy.length);
      parentItem = parentList[0];
      errorMessagePathItem = errorDetailsMessagesPath[0];
      newErrorDetailsMessagesPath = errorDetailsMessagesPath.slice(1, errorDetailsMessagesPath.length);
      if (errorMessagePathItem === propertyName) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetails, errorMessagePathItem)) === false) {
          errorDetails[errorMessagePathItem] = [];
        }
        newErrorMessageList = errorDetails[errorMessagePathItem];
        if ((Array.isArray(newErrorMessageList)) === false) {
          newErrorMessageList = [];
        }
        for (k = 0, len1 = errorMessageList.length; k < len1; k++) {
          item = errorMessageList[k];
          if ((indexOf.call(newErrorMessageList, item) >= 0) === false) {
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(newErrorMessageList)) === false) {
              newErrorMessageList = [];
            }
            newErrorMessageList.push(item);
          }
        }
        errorDetails[errorMessagePathItem] = newErrorMessageList;
        return errorDetails;
      }
      if (errorMessagePathItem === 'ARRAY-ITEM') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetails)) === false || (Array.isArray(errorDetails)) === false) {
          errorDetails = [];
        }
        obj = errorDetails;
        errorDetails = this._updateErrorDetailsObject(obj, newErrorDetailsMessagesPath, newParentList, propertyName, errorMessageList);
      } else if ((typeof errorMessagePathItem) === 'number') {
        sz = errorDetails.length;
        if (errorMessagePathItem >= sz) {
          newSz = errorMessagePathItem + 1 - sz;
          for (i = l = 0, ref = newSz - 1; 0 <= ref ? l <= ref : l >= ref; i = 0 <= ref ? ++l : --l) {
            errorDetails.push({});
          }
        }
        obj = errorDetails[errorMessagePathItem];
        errorDetails[errorMessagePathItem] = this._updateErrorDetailsObject(obj, newErrorDetailsMessagesPath, newParentList, propertyName, errorMessageList);
      } else {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetails, errorMessagePathItem)) === false) {
          errorDetails[errorMessagePathItem] = {};
        }
        obj = errorDetails[errorMessagePathItem];
        errorDetails[errorMessagePathItem] = this._updateErrorDetailsObject(obj, newErrorDetailsMessagesPath, newParentList, propertyName, errorMessageList);
      }
      return errorDetails;
    };

    Schema.prototype.isNotNull = function(obj, propertyName) {
      if (propertyName === null || (typeof propertyName) === RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
        if (obj === null || (typeof obj) === RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
          return false;
        }
        return true;
      }
      if (obj[propertyName] === null || (typeof obj[propertyName]) === RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
        return false;
      }
      return true;
    };

    Schema.prototype._extractMethodExecution = function(suppliedObject, propertyName, schemaJsonSignatureParameter, parentList, errorDetails, resObj, originalSuppliedObject, arrayIndexUsage, errorDetailsMessagesPath) {
      var allowedObjectTypes, computeParameters, computedObject, customErrorMessage, escapeFlag, item, k, l, len1, len2, newParentList, newSuppliedObject, ref, ref1, res, suppliedObjectType, validationResult;
      if (propertyName == null) {
        propertyName = 'ROOT_OBJECT';
      }
      if (schemaJsonSignatureParameter == null) {
        schemaJsonSignatureParameter = this.schemaJsonSignature;
      }
      if (parentList == null) {
        parentList = [];
      }
      if (errorDetails == null) {
        errorDetails = {
          'ROOT_OBJECT': {}
        };
      }
      res = {};
      allowedObjectTypes = ['literal', 'string', 'number', 'integer', 'float', 'boolean', 'object', 'array', 'schema', 'ARRAY-ITEM'];
      if (propertyName === 'ARRAY-ITEM') {
        suppliedObjectType = propertyName;
      } else {
        suppliedObjectType = schemaJsonSignatureParameter.type;
      }
      newParentList = (function() {
        var k, len1, results;
        results = [];
        for (k = 0, len1 = parentList.length; k < len1; k++) {
          item = parentList[k];
          results.push(item);
        }
        return results;
      })();
      if (suppliedObjectType === 'object' || suppliedObjectType === 'array' || suppliedObjectType === 'schema') {
        suppliedObject = resObj;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(suppliedObject)) === false) {
        suppliedObject = null;
      }
      if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter.compute)) {
        computeParameters = this._calculatePropertyValueFromParamList(schemaJsonSignatureParameter.compute.params, suppliedObject, newParentList, arrayIndexUsage);
        computedObject = schemaJsonSignatureParameter.compute.fn.apply({}, computeParameters);
        suppliedObject = computedObject;
      }
      if (schemaJsonSignatureParameter.allowNull === false && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(suppliedObject)) === false) {
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
          {
            message: 'Required.',
            code: 'ERR_INPUT_REQUIRED',
            origin: 'required'
          }
        ]);
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
          {
            message: 'null value is not applicable for ' + propertyName + ' property.',
            code: 'ERR_NULL_NOT_ALLOWED',
            origin: 'system'
          }
        ]);
      }
      if (schemaJsonSignatureParameter.allowNull === true) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'validation')) === true && (JSON.stringify(schemaJsonSignatureParameter.validation)) !== '{}') {
          newSuppliedObject = suppliedObject;
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(originalSuppliedObject)) === false) {
            newSuppliedObject = null;
          }
          validationResult = this._checkForValidation(schemaJsonSignatureParameter.validation, newSuppliedObject, propertyName, suppliedObjectType, newParentList, arrayIndexUsage);
          customErrorMessage = 'Validation error in "' + propertyName + '" property (custom error message not provided in schema signature).';
          ref = validationResult.res;
          for (k = 0, len1 = ref.length; k < len1; k++) {
            item = ref[k];
            if (item === false) {
              if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter.validation, 'message')) === true) {
                customErrorMessage = schemaJsonSignatureParameter.validation.message;
                validationResult.errorDetails.push({
                  message: customErrorMessage,
                  code: 'ERR_UNDECIDED',
                  origin: 'user'
                });
              } else {
                validationResult.errorDetails.push({
                  message: customErrorMessage,
                  code: 'ERR_UNDECIDED',
                  origin: 'system'
                });
              }
              this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, validationResult.errorDetails);
              break;
            }
          }
        }
      }
      if (indexOf.call(allowedObjectTypes, suppliedObjectType) < 0) {
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
          {
            message: '"type" property value is not recognized for ' + propertyName + ' property.',
            code: 'ERR_UNDECIDED',
            origin: 'system'
          }
        ]);
      }
      if (suppliedObjectType !== 'ARRAY-ITEM' && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'type')) === false) {
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
          {
            message: '"type" property is not set for "' + propertyName + '".',
            code: 'ERR_UNDECIDED',
            origin: 'system'
          }
        ]);
      }
      if (schemaJsonSignatureParameter.allowNull === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(suppliedObject)) === false) {
        return null;
      }
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'validation')) === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(suppliedObject)) === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(originalSuppliedObject)) === true && (JSON.stringify(schemaJsonSignatureParameter.validation)) !== '{}') {
        validationResult = this._checkForValidation(schemaJsonSignatureParameter.validation, suppliedObject, propertyName, suppliedObjectType, newParentList, arrayIndexUsage);
        customErrorMessage = 'Validation error in "' + propertyName + '" property (custom error message not provided in schema signature).';
        ref1 = validationResult.res;
        for (l = 0, len2 = ref1.length; l < len2; l++) {
          item = ref1[l];
          if (item === false) {
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter.validation, 'message')) === true) {
              customErrorMessage = schemaJsonSignatureParameter.validation.message;
              validationResult.errorDetails.push({
                message: customErrorMessage,
                code: 'ERR_UNDECIDED',
                origin: 'user'
              });
            } else {
              validationResult.errorDetails.push({
                message: customErrorMessage,
                code: 'ERR_UNDECIDED',
                origin: 'system'
              });
            }
            this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, validationResult.errorDetails);
            break;
          }
        }
      }
      res = suppliedObject;
      if (suppliedObjectType === 'literal') {
        validationResult = this._checkForValidationOfLiteralType(schemaJsonSignatureParameter, suppliedObject, propertyName);
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, validationResult.errorDetails);
      }
      if (suppliedObjectType === 'string') {
        if ((typeof suppliedObject) !== 'string') {
          this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
            {
              message: 'The data type of \'' + propertyName + '\' property is expected to be \'string\' but found \'' + (typeof suppliedObject) + '\'.',
              code: 'ERR_UNDECIDED',
              origin: 'system'
            }
          ]);
        }
        escapeFlag = false;
        if (this.schemaOptions.alwaysEscapeHtml === true) {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'escapeHtml')) === true) {
            if (schemaJsonSignatureParameter.escapeHtml === true) {
              escapeFlag = true;
            }
          } else {
            escapeFlag = true;
          }
        } else {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'escapeHtml')) === true) {
            if (schemaJsonSignatureParameter.escapeHtml === true) {
              escapeFlag = true;
            }
          }
        }
        if (escapeFlag === true) {
          suppliedObject = RootLibraryObject.utility.StringHandler.htmlEscape(suppliedObject);
          res = suppliedObject;
        }
        validationResult = this._checkForValidationOfStringType(schemaJsonSignatureParameter, suppliedObject, propertyName);
        this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, validationResult.errorDetails);
      }
      if (suppliedObjectType === 'number' || suppliedObjectType === 'float') {
        if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'tryToCoerce')) {
          if (schemaJsonSignatureParameter.tryToCoerce === true) {
            if ((typeof suppliedObject) === 'string') {
              res = parseFloat(suppliedObject);
              if ((isNaN(res)) === true || (RootLibraryObject.utility.StringHandler.onlyContainsDigits(suppliedObject)) === false) {
                this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
                  {
                    message: 'The supplied value of ' + propertyName + ' is not a number, it is expected to be a number.',
                    code: 'ERR_UNDECIDED',
                    origin: 'system'
                  }
                ]);
              }
            }
          }
        }
      }
      if (suppliedObjectType === 'integer') {
        if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'tryToCoerce')) {
          if (schemaJsonSignatureParameter.tryToCoerce === true) {
            if ((typeof suppliedObject) === 'string') {
              res = parseInt(suppliedObject);
              if ((isNaN(res)) === true || (RootLibraryObject.utility.StringHandler.onlyContainsDigits(suppliedObject)) === false) {
                this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
                  {
                    message: 'The supplied value of ' + propertyName + ' is not an integer, it is expected to be an integer.',
                    code: 'ERR_UNDECIDED',
                    origin: 'system'
                  }
                ]);
              }
            }
          } else if ((typeof suppliedObject) !== 'number' || (('' + suppliedObject).indexOf('.')) !== -1) {
            this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
              {
                message: 'The supplied value of ' + propertyName + ' is not an integer, it is expected to be an integer.',
                code: 'ERR_UNDECIDED',
                origin: 'system'
              }
            ]);
          }
        } else if ((typeof suppliedObject) !== 'number' || (('' + suppliedObject).indexOf('.')) !== -1) {
          this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
            {
              message: 'The supplied value of ' + propertyName + ' is not an integer, it is expected to be an integer.',
              code: 'ERR_UNDECIDED',
              origin: 'system'
            }
          ]);
        }
      }
      if (suppliedObjectType === 'float') {
        if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'maxPrecision')) {
          if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'roundingStrategy')) {
            if (schemaJsonSignatureParameter.roundingStrategy === 'ceil') {
              res = suppliedObject.toFixed(schemaJsonSignatureParameter.maxPrecision + 1);
              res = '' + res;
              res = res.substr(0, res.length - 1);
              res += '9';
              res = parseFloat(res);
              if ((isNaN(res)) === true || (RootLibraryObject.utility.StringHandler.onlyContainsDigits(suppliedObject)) === false) {
                this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
                  {
                    message: 'The supplied value of ' + propertyName + ' is not a float, it is expected to be a float.',
                    code: 'ERR_UNDECIDED',
                    origin: 'system'
                  }
                ]);
              }
              res = suppliedObject.toFixed(schemaJsonSignatureParameter.maxPrecision);
            }
            if (schemaJsonSignatureParameter.roundingStrategy === 'floor') {
              res = suppliedObject.toFixed(schemaJsonSignatureParameter.maxPrecision + 1);
              res = '' + res;
              res = res.substr(0, res.length - 1);
              res = parseFloat(res);
              if ((isNaN(res)) === true || (RootLibraryObject.utility.StringHandler.onlyContainsDigits(suppliedObject)) === false) {
                this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
                  {
                    message: 'The supplied value of ' + propertyName + ' is not a float, it is expected to be a float.',
                    code: 'ERR_UNDECIDED',
                    origin: 'system'
                  }
                ]);
              }
            }
            if (schemaJsonSignatureParameter.roundingStrategy === 'approximate') {
              res = suppliedObject.toFixed(schemaJsonSignatureParameter.maxPrecision);
            }
          }
        }
      }
      if (suppliedObjectType === 'boolean') {
        if ((typeof suppliedObject) !== 'boolean') {
          this._updateErrorDetailsObject(errorDetails, errorDetailsMessagesPath, newParentList, propertyName, [
            {
              message: 'Expected "boolean" values and received ' + (typeof suppliedObject),
              code: 'ERR_UNDECIDED',
              origin: 'system'
            }
          ]);
        }
      }
      if (suppliedObjectType === 'literal' || suppliedObjectType === 'string' || suppliedObjectType === 'number' || suppliedObjectType === 'integer' || suppliedObjectType === 'float' || suppliedObjectType === 'boolean') {
        if (RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaJsonSignatureParameter, 'mutationFn')) {
          res = schemaJsonSignatureParameter.mutationFn.apply({}, [suppliedObject]);
          suppliedObject = res;
        }
      }
      return res;
    };

    Schema.prototype._sortErrorMessageListBasedOnPriority = function(errorDetailsObject) {
      var idx, item, k, key, l, len1, len2, newErrorDetailList, priorityList, ref, value;
      if ((typeof errorDetailsObject) === 'object' && (Array.isArray(errorDetailsObject)) === true) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetailsObject[0], 'message')) === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetailsObject[0], 'code')) === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(errorDetailsObject[0], 'origin')) === true) {
          priorityList = {
            'required': 0,
            'custom-fn': 1,
            'user': 2,
            'validation': 3,
            'mutation-fn': 4,
            'compute-fn': 5,
            'system': 6
          };
          errorDetailsObject = errorDetailsObject.sort((function(_this) {
            return function(left, right) {
              return priorityList[left.origin] - priorityList[right.origin];
            };
          })(this));
          newErrorDetailList = [];
          for (k = 0, len1 = errorDetailsObject.length; k < len1; k++) {
            item = errorDetailsObject[k];
            if ((ref = item.message, indexOf.call(newErrorDetailList, ref) >= 0) === false) {
              newErrorDetailList.push(item.message);
            }
          }
          errorDetailsObject = newErrorDetailList;
        } else {
          idx = 0;
          for (l = 0, len2 = errorDetailsObject.length; l < len2; l++) {
            item = errorDetailsObject[l];
            errorDetailsObject[idx] = this._sortErrorMessageListBasedOnPriority(item);
            idx++;
          }
        }
      } else {
        for (key in errorDetailsObject) {
          value = errorDetailsObject[key];
          errorDetailsObject[key] = this._sortErrorMessageListBasedOnPriority(value);
        }
      }
      return errorDetailsObject;
    };

    Schema.prototype._operateOnEachInstanceOfAProperty = function(jsonSignature, pathList, parentPropertyName, propertyName, suppliedObject, errorDetails, res, parentList, arrayIndexUsage, errorDetailsMessagesPath) {
      var error, i, idx, item, k, len1, newArrayIndexUsage, newErrorDetailsMessagesPath, newJsonSignature, newPathList, newVal, pathItem, suppliedArray;
      if (propertyName === 'ROOT_OBJECT') {
        if ((JSON.stringify(errorDetails.ROOT_OBJECT)) !== '{}') {
          error = new Error;
          error.errorDetails = this._sortErrorMessageListBasedOnPriority(errorDetails.ROOT_OBJECT);
          throw error;
        }
      }
      if (pathList.length === 0) {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res, parentPropertyName)) === false) {
          res[parentPropertyName] = {};
        }
        res[parentPropertyName] = this._extractMethodExecution(suppliedObject, propertyName, jsonSignature, parentList, errorDetails, res[parentPropertyName], suppliedObject, arrayIndexUsage, errorDetailsMessagesPath);
        if (propertyName === 'ROOT_OBJECT') {
          if ((JSON.stringify(errorDetails.ROOT_OBJECT)) !== '{}') {
            error = new Error;
            error.errorDetails = errorDetails.ROOT_OBJECT;
            throw error;
          }
        }
        return res;
      }
      pathItem = pathList[0];
      newPathList = pathList.slice(1, pathList.length);
      if (jsonSignature.type === 'object') {
        newJsonSignature = jsonSignature.map[pathItem];
        newVal = suppliedObject[pathItem];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res, parentPropertyName)) === false) {
          res[parentPropertyName] = {};
        }
        newErrorDetailsMessagesPath = (function() {
          var k, len1, results;
          results = [];
          for (k = 0, len1 = errorDetailsMessagesPath.length; k < len1; k++) {
            item = errorDetailsMessagesPath[k];
            results.push(item);
          }
          return results;
        })();
        newErrorDetailsMessagesPath.push(pathItem);
        res[parentPropertyName] = this._operateOnEachInstanceOfAProperty(newJsonSignature, newPathList, pathItem, propertyName, newVal, errorDetails, res[parentPropertyName], parentList, arrayIndexUsage, newErrorDetailsMessagesPath);
      } else if (jsonSignature.type === 'array') {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(suppliedObject)) === false) {
          res[parentPropertyName] = suppliedObject;
        } else {
          newJsonSignature = jsonSignature.def[pathItem];
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res, parentPropertyName)) === false) {
            res[parentPropertyName] = [];
          }
          idx = 0;
          suppliedArray = suppliedObject;
          for (k = 0, len1 = suppliedArray.length; k < len1; k++) {
            item = suppliedArray[k];
            if (idx >= res[parentPropertyName].length) {
              i = 0;
              while (i < (idx - res[parentPropertyName].length + 1)) {
                res[parentPropertyName].push({});
                i++;
              }
            }
            if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res[parentPropertyName][idx], pathItem)) === false) {
              res[parentPropertyName][idx][pathItem] = {};
            }
            newVal = suppliedObject[idx][pathItem];
            newArrayIndexUsage = (function() {
              var l, len2, results;
              results = [];
              for (l = 0, len2 = arrayIndexUsage.length; l < len2; l++) {
                item = arrayIndexUsage[l];
                results.push(item);
              }
              return results;
            })();
            newArrayIndexUsage.push({
              'property': parentPropertyName,
              'index': idx
            });
            newErrorDetailsMessagesPath = (function() {
              var l, len2, results;
              results = [];
              for (l = 0, len2 = errorDetailsMessagesPath.length; l < len2; l++) {
                item = errorDetailsMessagesPath[l];
                results.push(item);
              }
              return results;
            })();
            newErrorDetailsMessagesPath.push('ARRAY-ITEM');
            newErrorDetailsMessagesPath.push(idx);
            newErrorDetailsMessagesPath.push(pathItem);
            res[parentPropertyName][idx] = this._operateOnEachInstanceOfAProperty(newJsonSignature, newPathList, pathItem, propertyName, newVal, errorDetails, res[parentPropertyName][idx], parentList, newArrayIndexUsage, newErrorDetailsMessagesPath);
            idx++;
          }
        }
      } else if (jsonSignature.type === 'schema') {

      } else {
        newVal = suppliedObject[pathItem];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(res, parentPropertyName)) === false) {
          res[parentPropertyName] = {};
        }
        res[parentPropertyName] = this._operateOnEachInstanceOfAProperty(jsonSignature, newPathList, pathItem, propertyName, newVal, errorDetails, res[parentPropertyName], parentList, arrayIndexUsage, errorDetailsMessagesPath);
      }
      return res;
    };

    Schema.prototype.extract = function(suppliedObject) {
      var errorDetails, k, len1, obj, pathListWithoutRootObject, ref, res;
      res = {};
      this.globalSuppliedObject = suppliedObject;
      this.globalRes = res;
      errorDetails = {
        'ROOT_OBJECT': {}
      };
      ref = this.orderedPropertyListWithPath;
      for (k = 0, len1 = ref.length; k < len1; k++) {
        obj = ref[k];
        pathListWithoutRootObject = obj.pathList.slice(1, obj.pathList.length);
        this._operateOnEachInstanceOfAProperty(this.schemaJsonSignature, pathListWithoutRootObject, obj.pathList[0], obj.propertyName, suppliedObject, errorDetails, res, obj.pathList, [], ['ROOT_OBJECT']);
      }
      return res.ROOT_OBJECT;
    };

    Schema.propertyMerger = function(schemaJsonSignatureList, suppressCyclicDataErrors) {
      var error, k, key, len1, res, schemaJsonSignatureObject, secondKey, secondValue, value;
      res = {};
      for (k = 0, len1 = schemaJsonSignatureList.length; k < len1; k++) {
        schemaJsonSignatureObject = schemaJsonSignatureList[k];
        for (key in schemaJsonSignatureObject) {
          value = schemaJsonSignatureObject[key];
          if (key === 'map') {
            for (secondKey in value) {
              secondValue = value[secondKey];
              if (Schema.self[secondKey] === null || (typeof Schema.self[secondKey]) === RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
                Schema.self[secondKey] = true;
                if (res[key] === null || (typeof res[key]) === RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
                  res[key] = {};
                }
                res[key][secondKey] = Schema.propertyMerger([secondValue], suppressCyclicDataErrors);
              } else {
                if (suppressCyclicDataErrors === false) {
                  error = new Error;
                  error.errorDetails = 'Cyclic property found while merge operation.';
                  throw error;
                }
              }
            }
          } else {
            res[key] = value;
          }
        }
      }
      return res;
    };

    Schema.merge = function() {
      var error, k, len1, propertyList, res, schemaList, schemaObject;
      schemaList = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      if (schemaList.length === 0) {
        return schemaList;
      }
      res = new Schema({});
      res.allowNull = true;
      propertyList = [];
      for (k = 0, len1 = schemaList.length; k < len1; k++) {
        schemaObject = schemaList[k];
        if (schemaObject.allowNull !== null && (typeof schemaObject.allowNull) !== RootLibraryObject.utility.BasicOperationHelper.undefinedString && schemaObject.allowNull === false) {
          schemaObject.allowNull = false;
        }
        if (schemaObject.schemaOptions !== null && (typeof schemaObject.schemaOptions) !== RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
          if (schemaObject.schemaOptions.suppressCyclicDataErrors !== null && (typeof schemaObject.schemaOptions.suppressCyclicDataErrors) !== RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
            if (schemaObject.schemaOptions.suppressCyclicDataErrors === true) {
              res.schemaOptions.suppressCyclicDataErrors = true;
            }
          }
          if (schemaObject.schemaOptions.ignoreUnidentifiedData !== null && (typeof schemaObject.schemaOptions.ignoreUnidentifiedData) !== RootLibraryObject.utility.BasicOperationHelper.undefinedString) {
            if (schemaObject.schemaOptions.ignoreUnidentifiedData === true) {
              res.schemaOptions.ignoreUnidentifiedData = true;
            }
          }
        }
        if (propertyList.length > 0 && schemaObject.schemaJsonSignature.type !== propertyList[propertyList.length - 1].type) {
          error = new Error;
          error.errorDetails = 'Two different property type found in the schemaList. The two types are: ' + schemaObject.schemaJsonSignature.type + ' and ' + propertyList[propertyList.length - 1].type;
          throw error;
        }
        propertyList.push(schemaObject.schemaJsonSignature);
      }
      Schema.self = {};
      res.schemaJsonSignature = Schema.propertyMerger(propertyList, res.schemaOptions.suppressCyclicDataErrors);
      res.topoSortObj = new RootLibraryObject.utility.TopologicalSort();
      res.topoSortObj.passSchemaJsonSignature(res.schemaJsonSignature);
      res.orderedPropertyListWithPath = res.topoSortObj.runTopologicalSort();
      return res;
    };

    return Schema;

  })();
  XhrHandler = (function() {
    XhrHandler.prototype.xhrObj = null;

    XhrHandler.prototype.localCbfnReference = null;

    function XhrHandler() {
      this.transferCanceled = bind(this.transferCanceled, this);
      this.transferFailed = bind(this.transferFailed, this);
      this.transferComplete = bind(this.transferComplete, this);
      this.doRequest = bind(this.doRequest, this);
      this.xhrObj = new XMLHttpRequest();
    }

    XhrHandler.prototype.doRequest = function(urlParam, methodParam, parameterData, cbfn) {
      var isOk;
      isOk = RootLibraryObject.utility.ClientErrorLogger.genericMethodParameterValueCheck({
        urlParam: urlParam,
        methodParam: methodParam,
        parameterData: parameterData,
        cbfn: cbfn
      }, 'doRequest', 'XhrHandler');
      if (isOk === false) {
        return;
      }
      this.localCbfnReference = cbfn;
      if (methodParam === 'GET') {
        this.xhrObj.open(methodParam, urlParam + '?' + parameterData, true);
      } else {
        this.xhrObj.open(methodParam, urlParam, true);
      }
      this.xhrObj.addEventListener('load', this.transferComplete, false);
      this.xhrObj.addEventListener('error', this.transferFailed, false);
      this.xhrObj.addEventListener('abort', this.transferCanceled, false);
      if (methodParam === 'GET') {
        return this.xhrObj.send();
      } else {
        return this.xhrObj.send(JSON.stringify(parameterData));
      }
    };

    XhrHandler.prototype.transferComplete = function(response) {
      return this.localCbfnReference(JSON.parse(response.target.responseText));
    };

    XhrHandler.prototype.transferFailed = function(response) {
      var code, details, message, name;
      name = 'XML_HTTP_REQUEST_FAILED';
      message = 'Failed to connect to the internet.';
      code = 404;
      details = response;
      RootLibraryObject.utility.ClientErrorLogger.reportXmlHttpError(name, message, code, details);
      return this.localCbfnReference({
        'hasError': true,
        'error': {
          'name': name,
          'message': message,
          'code': code,
          'details': details
        }
      });
    };

    XhrHandler.prototype.transferCanceled = function(response) {
      var code, details, message, name;
      name = 'XML_HTTP_REQUEST_ABORTED';
      message = 'Connection to server interrupted.';
      code = 503;
      details = response;
      RootLibraryObject.utility.ClientErrorLogger.reportXmlHttpError(name, message, code, details);
      return this.localCbfnReference({
        'hasError': true,
        'error': {
          'name': name,
          'message': message,
          'code': code,
          'details': details
        }
      });
    };

    return XhrHandler;

  })();
  AjaxCallHandler = (function() {
    function AjaxCallHandler() {}

    AjaxCallHandler.makeTheApiCall = function(partialUrlParam, requestMethod, data, cbfn) {
      var xhrObj;
      xhrObj = RootLibraryObject.utility.BasicOperationHelper.getXhrObject();
      return xhrObj.doRequest(RootLibraryObject.utility.UrlManager.getApiServerRootUrl() + partialUrlParam, requestMethod, data, cbfn);
    };

    AjaxCallHandler.getApiCall = function(partialUrlParam, rootObject, cbfn) {
      return AjaxCallHandler.makeTheApiCall(partialUrlParam, 'GET', rootObject, cbfn);
    };

    AjaxCallHandler.postApiCall = function(partialUrlParam, rootObject, cbfn) {
      return AjaxCallHandler.makeTheApiCall(partialUrlParam, 'POST', rootObject, cbfn);
    };

    return AjaxCallHandler;

  })();
  ClientStorageDataProcessing = (function() {
    function ClientStorageDataProcessing() {}

    ClientStorageDataProcessing._localStorageGetItem = function(key) {
      var data;
      data = localStorage.getItem(key);
      return data;
    };

    ClientStorageDataProcessing._localStorageSetItem = function(key, value) {
      return localStorage.setItem(key, value);
    };

    ClientStorageDataProcessing._localStorageRemoveItem = function(key) {
      return localStorage.removeItem(key);
    };

    ClientStorageDataProcessing._sessionStorageGetItem = function(key) {
      var data;
      data = sessionStorage.getItem(key);
      return data;
    };

    ClientStorageDataProcessing._sessionStorageSetItem = function(key, value) {
      return sessionStorage.setItem(key, value);
    };

    ClientStorageDataProcessing._sessionStorageRemoveItem = function(key) {
      return sessionStorage.removeItem(key);
    };

    ClientStorageDataProcessing.postProcessingLoginResponse = function(rootObject, responseObj) {
      var apiKey;
      ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage);
      ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyTimeInStorage);
      apiKey = responseObj.data.apiKey;
      if (rootObject.rememberMe === true) {
        ClientStorageDataProcessing._setApiKeyTimeInLocalStorage();
        return ClientStorageDataProcessing._localStorageSetItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage, apiKey);
      } else {
        return ClientStorageDataProcessing._sessionStorageSetItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage, apiKey);
      }
    };

    ClientStorageDataProcessing.postProcessingLogoutResponse = function() {
      ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage);
      return ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyTimeInStorage);
    };

    ClientStorageDataProcessing._getApiKeyTimeInLocalStorage = function() {
      var inLocalStorage;
      inLocalStorage = ClientStorageDataProcessing._localStorageGetItem(RootLibraryObject.libraryConfigs.apiKeyTimeInStorage);
      return inLocalStorage;
    };

    ClientStorageDataProcessing._setApiKeyTimeInLocalStorage = function() {
      return ClientStorageDataProcessing._localStorageSetItem(RootLibraryObject.libraryConfigs.apiKeyTimeInStorage, RootLibraryObject.utility.BasicOperationHelper.getCurTimeInMiliSec());
    };

    ClientStorageDataProcessing._getApiKeyInLocalStorage = function() {
      var apiKey;
      apiKey = ClientStorageDataProcessing._localStorageGetItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage);
      return apiKey;
    };

    ClientStorageDataProcessing._getApiKeyInSessionStorage = function() {
      var apiKey;
      apiKey = ClientStorageDataProcessing._sessionStorageGetItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage);
      return apiKey;
    };

    ClientStorageDataProcessing._checkForValidApiKey = function() {
      var curTime, diff, prevTime;
      prevTime = ClientStorageDataProcessing._getApiKeyTimeInLocalStorage();
      curTime = RootLibraryObject.utility.BasicOperationHelper.getCurTimeInMiliSec();
      diff = Math.floor((curTime - prevTime) / 1000 / 60 / 60 / 24);
      if (diff > RootLibraryObject.libraryConfigs.autoDestroyApiKeyAfterInDays) {
        return false;
      }
      return true;
    };

    ClientStorageDataProcessing.getClientApiKey = function() {
      var apiKey, inLocalStorage, inSessionStorage, isOk;
      inLocalStorage = ClientStorageDataProcessing._getApiKeyInLocalStorage();
      inSessionStorage = ClientStorageDataProcessing._getApiKeyInSessionStorage();
      apiKey = null;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(inLocalStorage)) === true) {
        isOk = ClientStorageDataProcessing._checkForValidApiKey();
        if (isOk === false) {
          ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyNameInStorage);
          ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.apiKeyTimeInStorage);
          return null;
        }
        apiKey = inLocalStorage;
      } else {
        apiKey = inSessionStorage;
      }
      return apiKey;
    };

    ClientStorageDataProcessing.bindApiKeyGetInLocalStorageToData = function(data) {
      data.apiKey = ClientStorageDataProcessing.getClientApiKey();
      return data;
    };

    ClientStorageDataProcessing._getSchemaListTimeInLocalStorage = function() {
      var inLocalStorage;
      inLocalStorage = ClientStorageDataProcessing._localStorageGetItem(RootLibraryObject.libraryConfigs.schemaListTimeInStorage);
      return inLocalStorage;
    };

    ClientStorageDataProcessing._setSchemaListTimeInLocalStorage = function() {
      return ClientStorageDataProcessing._localStorageSetItem(RootLibraryObject.libraryConfigs.schemaListTimeInStorage, RootLibraryObject.utility.BasicOperationHelper.getCurTimeInMiliSec());
    };

    ClientStorageDataProcessing._checkForValidSchemaList = function(schemaList) {
      var curTime, diff, prevTime;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaList)) === false) {
        return false;
      }
      prevTime = ClientStorageDataProcessing._getSchemaListTimeInLocalStorage();
      curTime = RootLibraryObject.utility.BasicOperationHelper.getCurTimeInMiliSec();
      diff = Math.floor((curTime - prevTime) / 1000 / 60 / 60);
      if (diff > RootLibraryObject.libraryConfigs.autoDestroySchemaListAfterInHours) {
        return false;
      }
      return true;
    };

    ClientStorageDataProcessing.getSchemaList = function() {
      var isOk, schemaList;
      schemaList = ClientStorageDataProcessing._localStorageGetItem(RootLibraryObject.libraryConfigs.schemaListInStorage);
      isOk = ClientStorageDataProcessing._checkForValidSchemaList(schemaList);
      if (isOk === false) {
        ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.schemaListInStorage);
        ClientStorageDataProcessing._localStorageRemoveItem(RootLibraryObject.libraryConfigs.schemaListTimeInStorage);
        return null;
      }
      return schemaList;
    };

    ClientStorageDataProcessing.setSchemaList = function(schemaList) {
      ClientStorageDataProcessing._localStorageSetItem(RootLibraryObject.libraryConfigs.schemaListInStorage, schemaList);
      return ClientStorageDataProcessing._setSchemaListTimeInLocalStorage();
    };

    return ClientStorageDataProcessing;

  })();
  GenericApiCaller = (function() {
    function GenericApiCaller() {
      this.apiCallback = bind(this.apiCallback, this);
      this.call = bind(this.call, this);
      this.localOptionReference = null;
    }

    GenericApiCaller.prototype.call = function(options) {
      var code, data, details, errorDetails, exObj, isOk, message, name, responseObj;
      this.localOptionReference = RootLibraryObject.utility.BasicOperationHelper.cloneObj(options);
      isOk = RootLibraryObject.utility.ClientErrorLogger.genericMethodParameterValueCheck(options, 'call', 'GenericApiCaller', ['schemaObject']);
      if (isOk === false) {
        return null;
      }
      errorDetails = {};
      data = null;
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(this.localOptionReference, 'schemaObject')) === false) {
        data = this.localOptionReference.rootObject;
      } else {
        try {
          data = this.localOptionReference.schemaObject.extract(this.localOptionReference.rootObject);
        } catch (error1) {
          exObj = error1;
          errorDetails = exObj.errorDetails;
        }
      }
      if (JSON.stringify(errorDetails) === '{}') {
        if (this.localOptionReference.isForJustValidation === true) {
          return this.localOptionReference.cbfn({
            'hasError': false,
            'data': data
          });
        } else {
          if (this.localOptionReference.doesRequireApiKey === true) {
            data = RootLibraryObject.utility.ClientStorageDataProcessing.bindApiKeyGetInLocalStorageToData(data);
          }
          if (this.localOptionReference.isGetCall === true) {
            return RootLibraryObject.utility.AjaxCallHandler.getApiCall(this.localOptionReference.partialApiUrl, data, this.apiCallback);
          } else {
            return RootLibraryObject.utility.AjaxCallHandler.postApiCall(this.localOptionReference.partialApiUrl, data, this.apiCallback);
          }
        }
      } else {
        name = 'CLIENT_SIDE_VALIDATION_ERROR';
        message = 'Invalid data or data-format encountered(client schema failure).';
        code = 406;
        details = errorDetails;
        responseObj = {
          'hasError': true,
          'error': {
            'name': name,
            'message': message,
            'code': code,
            'details': details
          }
        };
        this.localOptionReference.cbfn(responseObj);
        return RootLibraryObject.utility.ClientErrorLogger.reportSchemaFailureError(name, message, code, details);
      }
    };

    GenericApiCaller.prototype.apiCallback = function(responseObj) {
      if (this.localOptionReference.doSaveApiKey === true && responseObj.hasError === false) {
        RootLibraryObject.utility.ClientStorageDataProcessing.postProcessingLoginResponse(this.localOptionReference.rootObject, responseObj);
      }
      if (this.localOptionReference.doDestroyApiKey === true && responseObj.hasError === false) {
        RootLibraryObject.utility.ClientStorageDataProcessing.postProcessingLogoutResponse();
      }
      this.localOptionReference.cbfn(responseObj);
      return RootLibraryObject.utility.ClientErrorLogger.genericApiResponseErrorCheck(responseObj, !this.localOptionReference.doNotReportErrorToServer);
    };

    return GenericApiCaller;

  })();
  ApiGenerator = (function() {
    function ApiGenerator() {
      this.generateAllTheApiClients = bind(this.generateAllTheApiClients, this);
      this.genericApiCallEntryPoint = bind(this.genericApiCallEntryPoint, this);
    }

    ApiGenerator.prototype.genericApiCallEntryPoint = function(bindData, rootObject, cbfn) {
      var gacObj, options, ref;
      options = {};
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'saveApiKey')) === true && bindData.saveApiKey === true) {
        options = this.constructOptionsForPublicGetApisWithDataAndSchema(bindData.path, cbfn, rootObject, bindData.schema);
        options.doSaveApiKey = true;
      } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'destroyApiKey')) === true && bindData.destroyApiKey === true) {
        cbfn = rootObject;
        options = this.constructOptionsForAuthenticatedGetApisWithoutDataAndSchema(bindData.path, cbfn);
        options.doDestroyApiKey = true;
      } else {
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'requireApiKey')) === true && bindData.requireApiKey === true && (RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'schema')) === true) {
          options = this.constructOptionsForAuthenticatedGetApisWithDataAndSchema(bindData.path, cbfn, rootObject, bindData.schema);
        } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'requireApiKey')) === true && bindData.requireApiKey === true) {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'hasData')) === true && bindData.hasData === true) {
            options = this.constructOptionsForAuthenticatedGetApisWithData(bindData.path, cbfn, rootObject);
          } else {
            cbfn = rootObject;
            options = this.constructOptionsForAuthenticatedGetApisWithoutDataAndSchema(bindData.path, cbfn);
          }
        } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'schema')) === true) {
          options = this.constructOptionsForPublicGetApisWithDataAndSchema(bindData.path, cbfn, rootObject, bindData.schema);
        } else if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(bindData, 'hasData')) === true && bindData.hasData === true) {
          options = this.constructOptionsForPublicGetApisWithData(bindData.path, cbfn, rootObject);
        } else {
          cbfn = rootObject;
          options = this.constructOptionsForPublicGetApisWithoutDataAndSchema(bindData.path, cbfn);
        }
      }
      if (ref = bindData.name, indexOf.call(RootLibraryObject.libraryConfigs.errorsFromApiExemptedFromServerNotification, ref) >= 0) {
        options.doNotReportErrorToServer = true;
      }
      gacObj = new RootLibraryObject.utility.GenericApiCaller();
      return gacObj.call(options);
    };

    ApiGenerator.prototype.generateAllTheApiClients = function() {
      var item, k, key, len1, ref, ref1, results, value;
      ref = RootLibraryObject.systemConfigs.portalApiList;
      results = [];
      for (k = 0, len1 = ref.length; k < len1; k++) {
        item = ref[k];
        ref1 = RootLibraryObject.libraryConfigs.defaultOptionsForPortalApiList;
        for (key in ref1) {
          value = ref1[key];
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(item, key)) === false) {
            item[key] = value;
          }
        }
        results.push(RootLibraryObject.apis[item.name] = this.genericApiCallEntryPoint.bind(null, item));
      }
      return results;
    };

    ApiGenerator.prototype.constructDefaultOptions = function() {
      var options;
      options = {};
      options.rootObject = {};
      options.schemaObject = null;
      options.partialApiUrl = null;
      options.isGetCall = false;
      options.cbfn = null;
      options.doesRequireApiKey = false;
      options.doSaveApiKey = false;
      options.doDestroyApiKey = false;
      options.isForJustValidation = false;
      options.doNotReportErrorToServer = false;
      return options;
    };

    ApiGenerator.prototype.constructOptionsForPublicGetApisWithoutDataAndSchema = function(apiUrl, cbfnParam) {
      var options;
      options = this.constructDefaultOptions();
      options.partialApiUrl = RootLibraryObject.libraryConfigs.apiServerPartialUrl + apiUrl;
      options.cbfn = cbfnParam;
      return options;
    };

    ApiGenerator.prototype.constructOptionsForPublicGetApisWithData = function(apiUrl, cbfnParam, rootObjectParam) {
      var options;
      options = this.constructOptionsForPublicGetApisWithoutDataAndSchema(apiUrl, cbfnParam);
      options.rootObject = rootObjectParam;
      return options;
    };

    ApiGenerator.prototype.constructOptionsForPublicGetApisWithDataAndSchema = function(apiUrl, cbfnParam, rootObjectParam, schemaObjectParam) {
      var options;
      options = this.constructOptionsForPublicGetApisWithData(apiUrl, cbfnParam, rootObjectParam);
      options.schemaObject = RootLibraryObject.schemas[schemaObjectParam];
      return options;
    };

    ApiGenerator.prototype.constructOptionsForAuthenticatedGetApisWithoutDataAndSchema = function(apiUrl, cbfnParam) {
      var options;
      options = this.constructOptionsForPublicGetApisWithoutDataAndSchema(apiUrl, cbfnParam);
      options.doesRequireApiKey = true;
      return options;
    };

    ApiGenerator.prototype.constructOptionsForAuthenticatedGetApisWithData = function(apiUrl, cbfnParam, rootObjectParam) {
      var options;
      options = this.constructOptionsForAuthenticatedGetApisWithoutDataAndSchema(apiUrl, cbfnParam);
      options.rootObject = rootObjectParam;
      return options;
    };

    ApiGenerator.prototype.constructOptionsForAuthenticatedGetApisWithDataAndSchema = function(apiUrl, cbfnParam, rootObjectParam, schemaObjectParam) {
      var options;
      options = this.constructOptionsForAuthenticatedGetApisWithData(apiUrl, cbfnParam, rootObjectParam);
      options.schemaObject = RootLibraryObject.schemas[schemaObjectParam];
      return options;
    };

    return ApiGenerator;

  })();
  SchemaObjectHandler = (function() {
    SchemaObjectHandler.prototype._listOfSchemasRequiredInTheApp = null;

    SchemaObjectHandler.prototype._agObj = null;

    SchemaObjectHandler.prototype._cbfnFromSchemaReady = null;

    function SchemaObjectHandler(cbfn) {
      this.getAllTheSchemas = bind(this.getAllTheSchemas, this);
      this._prepareParameterDataForSchemaListGetRequest = bind(this._prepareParameterDataForSchemaListGetRequest, this);
      this._getAllTheSchemasCallback = bind(this._getAllTheSchemasCallback, this);
      this._processSchemaList = bind(this._processSchemaList, this);
      this._schemaListLoaded = bind(this._schemaListLoaded, this);
      var item, k, len1, nameMap, portalApiList;
      this._cbfnFromSchemaReady = cbfn;
      this._listOfSchemasRequiredInTheApp = [];
      portalApiList = RootLibraryObject.systemConfigs.portalApiList;
      nameMap = {};
      for (k = 0, len1 = portalApiList.length; k < len1; k++) {
        item = portalApiList[k];
        if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(item, 'schema')) === true) {
          if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(nameMap, item.schema)) === false) {
            nameMap[item.schema] = true;
            this._listOfSchemasRequiredInTheApp.push(item.schema);
          }
        }
      }
      this._agObj = new RootLibraryObject.utility.ApiGenerator();
      this.getAllTheSchemas();
    }

    SchemaObjectHandler.prototype._schemaListLoaded = function(schemaList) {
      this._processSchemaList(schemaList);
      this._agObj.generateAllTheApiClients();
      return this._cbfnFromSchemaReady();
    };

    SchemaObjectHandler.prototype._processSchemaList = function(schemaList) {
      var item, k, len1, results;
      results = [];
      for (k = 0, len1 = schemaList.length; k < len1; k++) {
        item = schemaList[k];
        item.schema = JSON.parse(item.schema, function(key, val) {
          if (indexOf.call(RootLibraryObject.libraryConfigs.schemaInternalMethodNamesForSerialization, key) >= 0) {
            return eval('(' + val + ')');
          }
          return val;
        });
        results.push(RootLibraryObject.schemas[item.name] = new RootLibraryObject.utility.Schema(item.schema));
      }
      return results;
    };

    SchemaObjectHandler.prototype._getAllTheSchemasCallback = function(responseObj) {
      var isOk;
      isOk = RootLibraryObject.utility.ClientErrorLogger.genericApiResponseErrorCheck(responseObj, true);
      if (isOk === true) {
        RootLibraryObject.utility.ClientStorageDataProcessing.setSchemaList(JSON.stringify(responseObj.data));
        return this._schemaListLoaded(responseObj.data);
      }
    };

    SchemaObjectHandler.prototype._prepareParameterDataForSchemaListGetRequest = function(schemaNameList) {
      var item, k, len1, res, schemaNameObj;
      res = [];
      for (k = 0, len1 = schemaNameList.length; k < len1; k++) {
        item = schemaNameList[k];
        schemaNameObj = {};
        schemaNameObj[RootLibraryObject.libraryConfigs.schemaNameConstantString] = item;
        res.push(schemaNameObj);
      }
      return res;
    };

    SchemaObjectHandler.prototype.getAllTheSchemas = function() {
      var gacObj, options, rootObj, schemaList;
      schemaList = RootLibraryObject.utility.ClientStorageDataProcessing.getSchemaList();
      if ((RootLibraryObject.utility.BasicOperationHelper.isNotNull(schemaList)) === false || RootLibraryObject.utility.BasicOperationHelper.isRunningOnLiveServer() === false) {
        gacObj = new RootLibraryObject.utility.GenericApiCaller();
        rootObj = this._prepareParameterDataForSchemaListGetRequest(this._listOfSchemasRequiredInTheApp);
        options = this._agObj.constructOptionsForPublicGetApisWithData(RootLibraryObject.libraryConfigs.apiServerSchemaListGetUrl, this._getAllTheSchemasCallback, rootObj);
        return gacObj.call(options);
      } else {
        schemaList = JSON.parse(schemaList);
        return this._schemaListLoaded(schemaList);
      }
    };

    return SchemaObjectHandler;

  })();
  GenericApiResponseHandler = (function() {
    function GenericApiResponseHandler() {}

    GenericApiResponseHandler.processErrorMessages = function() {
      var errorMessageList, i, propertyName;
      errorMessageList = arguments[0];
      propertyName = arguments[arguments.length - 1];
      i = 1;
      while (i < arguments.length - 1) {
        errorMessageList = errorMessageList[arguments[i]];
        i++;
      }
      if (Array.isArray(errorMessageList)) {
        if (Array.isArray(errorMessageList)) {
          errorMessageList = errorMessageList.slice(0, 1);
        }
        return errorMessageList;
      } else {
        if (Array.isArray(errorMessageList[propertyName])) {
          errorMessageList[propertyName] = errorMessageList[propertyName].slice(0, 1);
        }
        return errorMessageList[propertyName];
      }
    };

    return GenericApiResponseHandler;

  })();
  BasicObjectOperations = (function() {
    function BasicObjectOperations() {}

    BasicObjectOperations.resolvePathInObject = function() {
      var i, key, keyChain, root;
      root = arguments[0];
      keyChain = [];
      i = 1;
      while (i < arguments.length) {
        keyChain.push(arguments[i]);
        i++;
      }
      for (i in keyChain) {
        key = keyChain[i];
        if (!root) {
          throw new Error('Argument Is Null');
        }
        if (typeof root !== 'object') {
          throw new Error('Argument Is Not An Object');
        }
        if (Array.isArray(root)) {
          if (0 <= key && key < root.length) {
            root = root[key];
          } else {
            throw new Error('index' + JSON.stringify(key) + ' not found in Argument' + JSON.stringify(root));
          }
        } else {
          if (key in root) {
            root = root[key];
          } else {
            throw new Error('key not found in Argument');
          }
        }
      }
      return root;
    };

    return BasicObjectOperations;

  })();
  return SystemInitializer.doClientInitializationOperation();
};


/*
<!--LIBRARIES FOR SYSTEM(start)-->
<script type="text/javascript" src="js/sjcl.js"></script>
<script type="text/javascript" src="js/system-configs.js"></script>
<script type="text/javascript" src="js/client-libraries.js"></script>
<!--LIBRARIES FOR SYSTEM(end)-->
 */


/*
SAMPLE USAGE:
window.lib.apis.CallProcessClientErrorsApi ( responseObj ) =>
  console.log responseObj
window.lib.apis.CallEmailSubscriptionApi { email : 'xyz@abc.com' } , ( responseObj ) =>
  console.log responseObj
 */
