Polymer {
  is: 'page-complain-list'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:

    user:
      type: Object
      value: -> (app.db.find 'user')[0]
    
    organization:
      type: Object
      value: -> (app.db.find 'organization')[0]
    
    matchingComplaintList:
      type: Array
      value: []
    
    activeItem:
      observer: '_activeItemChanged'
    
    statusList:
      type: Array
      value: ['pending', 'resolved', 'seen']
    
    complain:
      type: Object
      value: {}
  
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _activeItemChanged: (item)->

    if item?._id
      # @set 'selectedComplain', {}
      # @$$("#dialogComplainPreview").toggle()
      # @set 'complain', item

      @_navigateToComplainPreview item._id
  
  _callSubmitComplain: (cbfn)->
    data =
      apiKey: @user.apiKey
      organizationId: @organization.idOnServer
      complain: @complain

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/organization-submit-complain', data, (err, response)=>
      @domHost.toggleModalLoader()
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        complainId = response.data.complainId
        cbfn complainId
  
  _updateComplainStatus: ()->
    @_callSubmitComplain =>
      @domHost.showToast 'Status updated!'
      @$$("#dialogComplainPreview").close()
  
  _navigateToComplainPreview: (complainId)->
    @domHost.navigateToPage '#/complain-preview/complainId:' + complainId
    

  _callGetComplainList: (organizationId)->
    data =
      apiKey: @user.apiKey
      organizationId: organizationId

    @domHost.toggleModalLoader 'Please wait...'
    @domHost.callApi '/organization-get-complain-list', data, (err, response)=>
      @domHost.toggleModalLoader()
      console.log {response}
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        @set 'matchingComplaintList', response.data

  navigatedIn: ->
    @_callGetComplainList @organization.idOnServer

    
} 