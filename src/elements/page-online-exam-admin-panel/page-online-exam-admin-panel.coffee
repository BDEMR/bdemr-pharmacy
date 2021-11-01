
Polymer {

  is: 'page-online-exam-admin-panel'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]

  properties:
    user:
      type: Object
      notify: true
      value: null

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

    examList:
      type: Array
      value: ()-> []

    currentlySelectedExam:
      type: Object
      value: ()-> {}

    examCodeSentToStudent:
      type: Boolean
      value: false
    

  _loadUser: (cbfn)->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]
      console.log @user
      cbfn()

  navigatedIn: ->
    @_loadUser =>
      @fetchAllCurrentExams()
    

  fetchAllCurrentExams: ()->
    data = {
      apiKey: @user.apiKey
      payload: {
        organizationId: @organization.idOnServer
        filterBy: {}
      }
    }
    @callApi '/get-organization-online-exam-list', data, (err,response)=>
      # sort in desc order
      examList = response.data
      examList.sort (a, b)-> 
        if a.createdDatetimeStamp < b.createdDatetimeStamp
          return 1
        if a.createdDatetimeStamp > b.createdDatetimeStamp
          return -1
      
      @set "examList", examList
      console.log @examList


  sendExamCodeClicked:(e)->
    message = 'Your exam code is: ' + @currentlySelectedExam.examAccessCode
    console.log message
    for item in @currentlySelectedExam.participentList
      @_sendNotification item.participentId, message


  _sendNotification: (userId, message)->  
    unless userId
      @domHost.showModalDialog 'target user id is missing'

    user = @getCurrentUser()
    request = {
      operation: 'notify-single'
      apiKey: user.apiKey
      notificationCategory: 'general'
      notificationMessage: message
      notificationTargetId: userId
      sender: user.name
    }
    @domHost.socket.emit 'message', request
    @domHost.showModalDialog 'Successfuly Sent' 

  viewExamButtonClicked:(e)->
    index = e.model.index
    exam = @examList[index]
    @set "currentlySelectedExam", exam
    @$$('#dialogViewForExams').toggle()
    console.log exam
    
  viewExamOkBtnPrsd: (e)->
    @set 'currentlySelectedExam', {}

  updateExamButtonClicked: (e)->
    console.log "Exam List", e.model.exam
    window.__tanvirHackExam = e.model.exam
    @domHost.navigateToPage '#/add-or-update-online-exam'

  analyzeExamButtonClicked: (e)->
    @domHost.navigateToPage '#/analyze-online-exam/examId:' + e.model.exam._id
  
  addOrUpdateExamButtonClicked:(e)->
    window.__tanvirHackExam = null
    @domHost.navigateToPage '#/add-or-update-online-exam'

  # viewAllExamsCorrectlyAnsweredParticipantsStat: (e)->
  #   @domHost.navigateToPage '#/exam-stat'

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()
  
  _getRightAnswer: (list)->
    rightAnswerArr = []
    for item in list
      if item.checked
        rightAnswerArr.push(item.value)
    return rightAnswerArr
    console.log rightAnswerArr
}
