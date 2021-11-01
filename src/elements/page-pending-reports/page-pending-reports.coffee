Polymer {

  is: 'page-pending-reports'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
  ]

  properties:
    isPatientValid: 
      type: Boolean
      notify: false
      value: true

    user:
      type: Object
      notify: true
      value: null

    patient:
      type: Object
      notify: true
      value: null

    

  # Helper
  # ================================

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  $findCreator: (creatorSerial)-> 'me'

  _isEmptyString: (data)->
    if data == null || data == 'undefined' || data == ''
      return true
    else
      return false

  _isEmptyArray: (data)->
    if data.length is 0
      return true
    else
      return false

  _compareFn: (left, op, right) ->
    if op is '<'
      return left < right
    if op is '>'
      return left > right
    if op is '=='
      return left == right
    if op is '>='
      return left >= right
    if op is '<='
      return left <= right
    if op is '!='
      return left != right

  getFullName:(data)->
    honorifics = ''
    first = ''
    last = ''
    middle = ''

    if data.honorifics  
      honorifics = data.honorifics + ". "
    if data.first
      first = data.first
    if data.middle
      middle = " " + data.middle
    if data.last
      last = " " + data.last
      
    return honorifics + first + middle + last 

  _sortByDate: (a, b)->
    if a.date < b.date
      return 1
    if a.date > b.date
      return -1

  _formatDateTime: (dateTime)->
    lib.datetime.format((new Date dateTime), 'mmm d, yyyy')

  _returnSerial: (index)->
    index+1




  navigatedIn: ->

    params = @domHost.getPageParams()

    @_loadUser()

  navigatedOut: ->
    @patient = null
    @isPatientValid = false


      
  

}
