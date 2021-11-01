
Polymer {

  is: 'page-analyze-online-exam'

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

    participentList:
      type: Array
      value: ()-> []

    examList:
      type: Object
      value: ()-> {}

    selectedParticipant:
      type: Object
      value: ()-> {}

    ShowSubmitButton:
      type: Boolean
      value: false


  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]


  _loadExamDetails: (examId)->
    data = {
      apiKey: @user.apiKey
      payload: {
        organizationId: @organization.idOnServer
        docId: examId
      }
    }
    @callApi '/get-organization-online-exam', data, (err,response)=>
      if err
        return @domHost.showModalDialog "There is a problem connecting to the Server. Please Try Again."
      else if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        @set "examList", response.data
        @_getStudentDetailInfo()
        for item in @examList.data
          if item.type is 'textarea' && @ShowSubmitButton is false
            @ShowSubmitButton = true


  navigatedIn: ->
    params = @domHost.getPageParams()
    @id = params.examId
    @_loadUser()
    @_loadExamDetails @id
  
  navigatedOut: ()->
    @ShowSubmitButton = false
    @selectedParticipant = {}
    @selectedParticipantsAnswerDetails = []

  viewAnswerBtnPrsd: (e)->
    selectedParticipant = e.model.item
    console.log 'selected participant', selectedParticipant
    @set 'selectedParticipant', selectedParticipant
    @set 'selectedParticipantsAnswerDetails', selectedParticipant.answerList
    # data =
    #   apiKey: @user.apiKey
    #   payload: {
    #     organizationId: @organization.idOnServer
    #     docId: @examList._id
    #     participentId: item.participentId
    #   }
    # @callApi '/get-organization-participent-answer-sheet', data, (err,response)=>
    #   if err
    #     return @domHost.showModalDialog "There is a problem connecting to the Server. Please Try Again."
    #   else if response.hasError
    #     return @domHost.showModalDialog response.error.message
    #   else
    #     participent = response.data    
    #     @set "selectedParticipantsAnswerDetails", participent
    @$$('#dialogViewAnswerSheet').toggle()
    
    

  _getStudentDetailInfo: (e)->
    data =
      apiKey: @user.apiKey
      payload: {
        docId: @examList._id
        organizationId: @organization.idOnServer
      }
    @callApi '/get-online-exam-participent-detail-info', data, (err,response)=>
      if err
        return @domHost.showModalDialog "There is a problem connecting to the Server. Please Try Again."
      else if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        participent = response.data
        @set 'examList.participentList', participent
        
        console.log 'exam with participant list', @examList


  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _returnSerial: (index)->
    index+1

  _getRightAnswer: (questionId)->
    
    originalQuestion = @examList.data.find (question)=> 
      return question.id is questionId

    answerIds = originalQuestion.answerIndexList

    answers = originalQuestion.choices.filter((choice)=> 
      return answerIds.includes choice.choiceId
    ).map((filteredChoice) =>
      return filteredChoice.value
    )

    console.log "right answer for question: #{questionId} ", answers
    return answers.join ', '


  _getStudentAnswer: (question)->
    answerIds = question.studentAnswerIndexList
    answers = question.choices.filter((choice)=> 
      return answerIds.includes choice.choiceId
    ).map((filteredChoice) =>
      return filteredChoice.value
    )
    
    console.log "student answer for question: #{question.id} ", answers

    @_setMarksOfMcqAutomatically()

    return answers.join ', '


  
  _setMarksOfMcqAutomatically: ()->
    @examList.participentList.forEach (participant)=>
      totalmarks = 0
      participant.answerList.forEach (question)=>
        correctAnswers = question.studentAnswerIndexList.filter (answer)=> 
          question.answerIndexList.includes answer
        
        mark = correctAnswers.length * Number.parseFloat question.marksPerCorrectAnswer
        question.givenMark = mark
        totalmarks += mark
      participant.totalMarks = totalmarks

    console.log 'exam', @examList
    @updateExamMarking()


  setTextAnswerMarksOfParticipent: (e)->
    tempTotalMark = 0

    for item in @examList.participentList
      if item.participentId = @selectedParticipant.participentId
        for answer in item.answerList
          tempTotalMark = tempTotalMark + parseFloat(answer.givenMark)

        item.totalMarks = tempTotalMark
        console.log @examList
        @updateExamMarking()
        @$$('#dialogViewAnswerSheet').toggle()
        return

  updateExamMarking:(e)->
    console.log "Free-Form Exam", @examList
    data = {
      payload: @examList
      apiKey: @user.apiKey
    }
    @callApi '/set-organization-online-exam', data, (err,response)=>
      @_loadExamDetails @id
      @domHost.showModalDialog "Exam Marks Added!"



}