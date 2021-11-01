Polymer {
  is: 'page-agent-bookings'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    page: 
      type: Number
      value:0
      
    pages: Array

    hideEditForm:
      type: Boolean
      value: true
    newAttachment:
      type: Object
      notify: false
      value: null
    attachmentList:
      type: Array
      notify: false
      value: -> []

    EDIT_MODE:
      type: Boolean
      value: false
    category:
      type: Object
      value: {
        category: 'test'
        
      }
    matchingVisitList:
      type: Array
      notify: true
      value: []
    matchingFilter:
      type: Array
      notify: true
      value: []
    bookingList:
      type: Array
      value: []
    isUploading:
      type: Boolean
      value: false 
    snackbar:
      type: Boolean
      value: false 
    user:
      type: Object
      notify: true
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]
    
    inventory:
      type: Array
      value: []
    
    filterBy:
      type: Object
      value:
        fromDate: null
        toDate: null

    patients:
      type: Array
      value: []
    search:
      type: Array
      value: []
      
    itemSearchQuery:
      type: String
      value: ''
      observer: 'itemSearchInputChanged'
    activeItem:
      observer: '_itemsChanged'
  
    activeUserList:
      type: Array
      value: []
  
  listeners:
    'active-users': '_activeUsersHandler'
  
        
  # _load: -> asyncStuff(done ->this.$.scrollTheshold.clearTriggers())
  
        

  # _didRespond: (e)-> 
  #    people = e.detail.response.results

  #    people.forEach((person)-> this.$.list.push('inventories', person))
        
  #    this.$.scrollTheshold.clearTriggers()
      
  

 
  $toMega: (value)-> (Math.ceil ((value / 1000 / 1000) * 100)) / 100
    
  _isSelected: (page, item)-> 
      @page is item - 1
     

  _select: (e)->
      @page = e.model.item - 1
      @_itemsChanged()
        

  _next:-> 
      @page = Math.min(@pages.length - 1, @page + 1)
     
      console.log 'selected item', @page
      @_itemsChanged()
        

  _prev: -> 
      @page = Math.max(0, @page - 1)
      @_itemsChanged()
        

  _itemsChanged: ()-> 
    console.log 'selected item', @matchingFilter
    
    this.$.visitList.items = @matchingFilter
        
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  

  _validateMedicineForm: ()->
    isInputName = @$$("#productSearch").validate()
    isInputActualCost = @$$("#inputActualCost").validate()
    isInputPrice = @$$("#inputPrice").validate()

    # isInputQuantity = @$$("#inputQuantity").validate()
    # isInputBatchNumber = @$$("#inputBatchNumber").validate()
    # isInputGenericName = @$$("#inputGenericName").validate()
    # isInputManufacturer = @$$("#inputManufacturer").validate()
    return isInputName and isInputActualCost and isInputPrice

  


 

  convertToDateString: (dateObject)->
    isoStringArr = dateObject.toISOString().split('T')
    console.log isoStringArr
    return isoStringArr[0]

  _showNewProductForm: ()->
    @_clearProduct()
    @set 'hideEditForm', false
  
  _closeEditForm: ()->
    @set 'hideEditForm', true
  
  _clearProduct: ()->
    @_resetProductObject()
  printBookingDetails: (e)->
    item = e.model.item
    console.log 'Selected CHAMBER', item
    localStorage.setItem 'bookingDetails', JSON.stringify(item)
    window.location = '#/print-booking-details'
  
  viewVisitRecord: (e)->
    # el = @locateParentNode e.target, 'PAPER-BUTTON'
    # el.opened = false
    # repeater = @$$ '#visit-list-repeater'
    # index = repeater.indexForElement el
    # visit = @matchingVisitList[index]
    # @domHost.setSelectedVisitSerial visit.serial
    # @domHost.selectedPatientPageIndex = 0
    visit = e.model.item
    window.localStorage.setItem('doctorId', visit.doctorId)
    window.localStorage.setItem('organizationId', visit.organizationId)

    @domHost.navigateToPage '#/visit-preview/visit:' + visit.visitSerial + '/patient:' + visit.patientSerial
    return
  _listVisits: ()->
    console.log 'id',@user.idOnServer
    data = { 
      apiKey: @user.apiKey
      userId: @user.idOnServer
      startDate : new Date(@filterBy.fromDate).getTime();
      endDate   : new Date(@filterBy.toDate).setHours(24);
    }
    # Object.assign(data, @filterBy.fromDate)
    this.domHost.toggleModalLoader 'Please Wait..'
    @callApi '/bdemr-get-booking-list-by-agent', data, (err, response)=>
      this.domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
      
        @matchingVisitList=response.data
        @updatePatientOnlineStatus()
        
        # @_matchDoctor()

  updatePatientOnlineStatus: ()->
    activeUserList = @domHost.activeUserList
    console.log {activeUserList}
    console.log 'LIST', @matchingVisitList

    return if !@matchingVisitList
    for book, index in @matchingVisitList
      isOnline = activeUserList.some (item) => book.patientId is item.userId
      @set "matchingVisitList.#{index}.isOnline", isOnline
    
  patchOverlay: (e)->
    if e.target.withBackdrop
      e.target.parentNode.insertBefore e.target.backdropElement, e.target
  addAttachmentAgent: (e)->
    attachmentId= e.model.item
    @attachList =attachmentId.patientSerial
  
    @$$('#addAttachment').toggle()  
        
  onFilterTapped: ()->
      @_listVisits()
      @_itemsChanged()
      
    
  
  onClearFilterTapped: ()->
  
    @set "filterBy.fromDate" , @$getDay 0
    @set "filterBy.toDate" , @$getDay 0
    @_listVisits()
    @_itemsChanged()


  _makeBlankAttachment: ->
    @set 'newAttachment', {
      title: ''
      description: ''
      dataUri: ''
      originalName: null 
      originalType: null
      sizeInBytes: 0
      sizeInChars: 0
      isImage: false
      isLoaded: false
      progress: 0
      belongToPatientSerial: null
    }
  fileInputChanged: (e)->
    reader = new FileReader
    file = e.target.files[0]

    if file.size > @maximumImageSizeAllowedInBytes
      @domHost.showModalDialog "Please provide a file less than #{Math.floor(@maximumImageSizeAllowedInBytes / 1000 / 1000)}mb in size."
      return

    reader.readAsDataURL file

    reader.onprogress = (e)=>
      @set 'newAttachment.progress', ((e.loaded / e.total) * 100)

    reader.onload = =>
      dataUri = reader.result
      @set 'newAttachment.isImage', file.type.indexOf('image/') > -1

      @set 'newAttachment.sizeInBytes', file.size
      @set 'newAttachment.title', file.name
      @set 'newAttachment.dataUri', dataUri
      @set 'newAttachment.originalType',  file.type
      @set 'newAttachment.originalName', file.name
      @set 'newAttachment.sizeInChars', dataUri.length
      
      @set 'newAttachment.isLoaded', true
  _prepareAtachment: ->
    { 
      title
      description
      dataUri
      isImage
      originalName
      originalType
      sizeInBytes
      sizeInChars
    } = @newAttachment

    attachment = {
      serial: @generateSerialForAttachmentBlob()
      attSyncSerial: @generateSerialForAttachmentSync()
      lastModifiedDatetimeStamp: lib.datetime.now()
      createdDatetimeStamp: lib.datetime.now()
      mainStorage: null # could be 'server' or 'local' or 'session'
      title
      description
      # dataUri
      isImage
      originalName
      originalType
      sizeInBytes
      sizeInChars
      organizationId: @currentOrganization.idOnServer
      belongToPatientSerial: @attachList
      createdByUserSerial: @user.serial
      createdByUserName: @user.name
      testResultSerial: null
      datatype: @category.category
    }

    return attachment
  attachmentType:(e)->
    index = e.detail.selected
    console.log 'index',index
    if(index is 0)
      @category.category='test'
    else
      @category.category='prescription'

    
  uploadPressed: (e)->
    attachment = @_prepareAtachment()

    if attachment.originalType.indexOf('image') is 0
      amount = 5
    else
      amount = 20

    # this._chargePatient this.patient.idOnServer, amount, 'Payment BDEMR Doctor Generic', (err)=>
    #   if (err)
    #     @domHost.showModalDialog("Unable to charge the patient. #{err.message}")
    #     return

    attachment.mainStorage = 'server'
    attachment.apiKey = (app.db.find 'user')[0].apiKey
    attachment.dataURI = @newAttachment.dataUri
    @set 'isUploading', true
    @callApi 'bdemr/file-uploader', attachment, (err, response)=>
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        attachment._id = response.data.attachmentId
        @push 'attachmentList', attachment
        # following syncable object signature
        onlineAttachment = 
          serial: attachment.attSyncSerial
          createdDatetimeStamp: 0
          lastModifiedDatetimeStamp: attachment.lastModifiedDatetimeStamp
          lastSyncedDatetimeStamp: 0
          patientSerial: @attachList
          datatype: attachment.datatype
          data:
            attachmentId: response.data.attachmentId
        # Saving the attachment ref
        app.db.upsert 'patient-gallery--online-attachment', onlineAttachment, ({serial})=> serial is attachment.serial
        @set 'isUploading', false
        
        # @$$("#toast").duration =5000
       
        # TODO - Sync the refs with server when upload complete
        # Temporary Fix
        console.log 'type',@category.category
        
        @domHost._syncOnlyPatientGallery ()=>
          @_makeBlankAttachment()
          @$$("#addAttachment").toggle()
        @$$("#toast").text ='Upload Complete'
        @$$("#toast").show()
  navigatedIn: ->
    # window.location.reload()

    @set "filterBy.fromDate" , @$getDay 0
    @set "filterBy.toDate" , @$getDay 0
    # console.log 'dateTime' , new Date(@filterBy.fromDate).getTime()

    @currentOrganization = @getCurrentOrganization()
    @_listVisits()
    @_makeBlankAttachment()
    
  navigatedOut:->
    @matchingVisitList=[]
    @matchingFilter=[]
    
    
  goToPharmacyInvoice: ()->
    @domHost.navigateToPage("#/pharmacy-invoice-editor/location:pharmacy/invoice:new")

  goToSupplierInvoice: ()->
    @domHost.navigateToPage("#/supplier-invoice-editor/organization:" + @organization.idOnServer + '/supplier:new')

    

} 