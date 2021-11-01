
Polymer {

  is: 'page-add-or-update-online-exam'

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


    newExam:
      type: Object
      value: ()-> {}

    newMcqExam:
      type: Object
      value: ()-> {}

    groupList:
      type: Array
      value: ()-> []

    answerIndexList:
      type: Array
      value: ()-> []

    showFreeFrom:
      type: Boolean
      value: false

    showMcq:
      type: Boolean
      value: false

    userCameToEdit:
      type: Boolean
      value: false

    customExamDate:
      type: String
      value: ""

    editExamObj:
      type: Object
      value: ()-> {}

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]    



  _loadUser:()->
    userList = app.db.find 'user'
    if userList.length is 1
      @user = userList[0]

  _loadGroupList: ()->
    data = { 
      apiKey: @user.apiKey
      payload: {
        organizationId: @organization.idOnServer
      }
    }
    @callApi '/get-organization-attendance-groups', data, (err, response)=>
      if response.hasError
        return @domHost.showModalDialog response.error.message
      else
        groupList = response.data
        @set 'groupList', groupList
        console.log {@groupList}
        

  showFreeFormQuestionTapped: (e)->
    @showFreeFrom = true
    if @showMcq is true
      @showMcq = false

  showMcqQuestionTapped: (e)->
    @showMcq = true
    if @showFreeFrom is true
      @showFreeFrom = false


  navigatedIn: ->
    @_loadUser()
    @_loadGroupList()

    if window.__tanvirHackExam
      editExamObj = window.__tanvirHackExam
      console.log editExamObj
      # startTime = @$getFormatted24HRTimeFromMS(editExamObj.startDatetimeStamp)
      # endTime = @$getFormatted24HRTimeFromMS(editExamObj.endDatetimeStamp)
      # editExamObj.startDatetimeStamp = startTime
      # editExamObj.endDatetimeStamp = endTime
      @userCameToEdit = true

      for item in editExamObj.data
        if item.type is 'textarea'
          @showFreeFormQuestionTapped()
          @newExam = editExamObj
        else
          @showMcqQuestionTapped()
          @newMcqExam = editExamObj
    else    
      @_makeNewFreeFormExam()
      @_makeNewFreeFormQuestion()
      @_makeNewMcqExam()
      @_makeNewMcqQuestion()
    
    

  _makeNewFreeFormExam: ()->
    @set "newExam", {
      organizationId: @organization.idOnServer
      code:""
      isActive: true
      revealStudentsMarks: false
      name: ""
      duration: ""
      startDatetimeStamp: null
      endDatetimeStamp: null
      examAccessCode: null
      data: []
      participentList: []
    }

  _makeNewFreeFormQuestion: ()->
    newQuestion = {
      id: @generateSerialForOnlineExamQuestion()
      question: ""
      type: "textarea"
      marks: null
    }
    @push "newExam.data", newQuestion

  _makeNewMcqExam: ()->
    @set "newMcqExam", {
      organizationId: @organization.idOnServer
      code:""
      isActive: true
      revealStudentsMarks: false
      name: ""
      duration: ""
      startDatetimeStamp: null
      endDatetimeStamp: null
      examAccessCode: null
      data: []
      participentList: []
    }

  _makeNewMcqQuestion: ()->
    newQuestion = {
      id: @generateSerialForOnlineExamQuestion()
      question: ""
      type: "checkbox"
      marks: null
      marksPerCorrectAnswer: null
      answerIndexList: null
      choices: [ 
        { 
          choiceId: @generateIdForChoices()
          value: ""
          label: "Answer 1"
          checked: false
        }
        {
          choiceId: @generateIdForChoices()
          value: ""
          label: "Answer 2"
          checked: false
        }
        {
          choiceId: @generateIdForChoices()
          value: ""
          label: "Answer 3"
          checked: false
        }
        {
          choiceId: @generateIdForChoices()
          value: ""
          label: "Answer 4"
          checked: false
        }
      ]
    }
    @push "newMcqExam.data", newQuestion


  groupSelectedFromFreeForm: (e)-> 
    if !e.target.checked
      return
    else 
      value = e.target.value
      console.log value
      for item in value.attendees
        @push 'newExam.participentList', {
          participentId: item,
          isPresent: false,
          examEndDatetimeStamp: null,
          examStartDatetimeStamp: null,
          groupId: value._id,
          examAccess: true,
          totalMarks: 0,
          answerList: []
        }

  groupSelectedFromMCQ: (e)-> 
    if !e.target.checked
      return
    else 
      value = e.target.value
      console.log value
      for item in value.attendees
        @push 'newMcqExam.participentList', {
          participentId: item,
          isPresent: false,
          examEndDatetimeStamp: null,
          examStartDatetimeStamp: null,
          groupId: value._id,
          examAccess: true,
          totalMarks: 0,
          answerList: []
        }

  _convertFreeformDateTimeStringToStamp: ()->
    if @newExam.startDatetimeStamp && @newExam.endDatetimeStamp
      start = new Date(@customExamDate + "T" + @newExam.startDatetimeStamp).getTime()
      end = new Date(@customExamDate + "T" + @newExam.endDatetimeStamp).getTime()
      @newExam.startDatetimeStamp = start
      @newExam.endDatetimeStamp = end
    else
      @domHost.showModalDialog "Date Time missing"

  _convertMcqDateTimeStringToStamp: ()->
    if @newMcqExam.startDatetimeStamp && @newMcqExam.endDatetimeStamp
      start = new Date(@customExamDate + "T" + @newMcqExam.startDatetimeStamp).getTime()
      end = new Date(@customExamDate + "T" + @newMcqExam.endDatetimeStamp).getTime()
      @newMcqExam.startDatetimeStamp = start
      @newMcqExam.endDatetimeStamp = end
    else
      @domHost.showModalDialog "Date Time missing"
    

  submitOrUpdateFreeFormExamButtonClicked:(e)->

    if !@newExam.examAccessCode
      @newExam.examAccessCode = @generateExamAccessCode()

    if !@userCameToEdit
      @_convertFreeformDateTimeStringToStamp()

    console.log "Free-Form Exam", @newExam
    data = {
      payload: @newExam
      apiKey: @user.apiKey
    }
    @callApi '/set-organization-online-exam', data, (err,response)=>
      @domHost.showModalDialog "Exam Details Added!"
      @domHost.navigateToPage '#/online-exam-admin-panel'

  submitOrUpdateMcqExamButtonClicked:(e)->

    if !@newMcqExam.examAccessCode
      @newMcqExam.examAccessCode = @generateExamAccessCode()

    if !@userCameToEdit
      @_convertMcqDateTimeStringToStamp()

    for question in @newMcqExam.data
      answerIndexList = []
      for item in question.choices
        if item.checked
          answerIndexList.push(item.choiceId)
      question.answerIndexList = answerIndexList
      if answerIndexList.length
        question.marksPerCorrectAnswer = question.marks/ answerIndexList.length
          
    
    console.log "Checkbox Exam", @newMcqExam
    data = {
      payload: @newMcqExam
      apiKey: @user.apiKey
    }
    @callApi '/set-organization-online-exam', data, (err,response)=>
      @domHost.showModalDialog "Exam Details Added!"
      @domHost.navigateToPage '#/online-exam-admin-panel'
    

  CancelButtonPressed: (e)->
    @domHost.navigateToPage '#/online-exam-admin-panel'
  
  addAnotherFreeFormQuestion: (e)->
    @_makeNewFreeFormQuestion()

  addAnotherMcqQuestion: (e)->
    @_makeNewMcqQuestion()

  deleteQuestionBtnPressed: (e)->
    index = e.model.index
    if index > 0
      console.log {index}
      @splice "newExam.data", index, 1
      @domHost.showToast "Question Deleted!"
    else @domHost.showModalDialog "There is only 1 Question, Cannot Delete"
  
  deleteMcqQuestionBtnPressed: (e)->
    index = e.model.index
    if index > 0
      console.log {index}
      @splice "newMcqExam.data", index, 1
      @domHost.showToast "Question Deleted!"
    else @domHost.showModalDialog "There is only 1 Question, Cannot Delete"


  generateExamAccessCode: (e)->
    accessCode = Math.random().toString(10).substr(2, 6)
    return accessCode

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _returnSerial: (index)->
    index+1

  navigatedOut: ()->
    @showFreeFrom = false
    @showMcq = false
    @customExamDate = ""

}
