
Polymer {

  is: 'custom-autocomplete'

  properties:
    sourceDataList:
      type: Array
      value: []
    selectedStringObjectList:
      type: Array
      notify: true
      value: -> []
    matchingDataList:
      type: Array
      value: []
    typedValue:
      type: String
      value: ''
    allowCustom: 
      type: Boolean
      value: true
    allowRepeatation:
      type: Boolean
      value: true
    projectedMatchingDataList: 
      type: Array
      value: []
    projectionStartIndex:
      type: Number
      value: 0
    projectionEndIndex:
      type: Number
      value: 0
    projectionCount:
      type: Number
      readonly: true
      value: 5
    projectedMatchingDataListSelectedIndex:
      type: Number
      value: null

  observers: [
    'matchingDataListAltered(matchingDataList)'
  ]

  $getProjectionClass: (projectedMatchingDataIndex, projectedMatchingDataListSelectedIndex)->
    if projectedMatchingDataIndex is projectedMatchingDataListSelectedIndex then 'active' else ''

  _generateProjection: ->
    @projectionEndIndex = Math.min (@projectionStartIndex + @projectionCount), @matchingDataList.length
    projectedMatchingDataList = @matchingDataList.slice @projectionStartIndex, @projectionEndIndex
    @projectedMatchingDataList = projectedMatchingDataList

  matchingDataListAltered: ->
    @projectionStartIndex = 0
    @projectedMatchingDataListSelectedIndex = null
    @_generateProjection()

  _goUpOnProjection: ->
    return if @projectedMatchingDataListSelectedIndex is null
    if @projectedMatchingDataListSelectedIndex is 0
      if @projectionStartIndex is 0
        @projectedMatchingDataListSelectedIndex = null
      else
        @projectionStartIndex -= 1
        @_generateProjection()
    else
      @projectedMatchingDataListSelectedIndex -= 1

  _goDownOnProjection: ->
    if @projectedMatchingDataListSelectedIndex is null
      @projectedMatchingDataListSelectedIndex = 0
    else
      if @projectedMatchingDataListSelectedIndex is @projectionCount - 1
        if @projectionEndIndex < @matchingDataList.length - 1
          @projectionStartIndex += 1
          @_generateProjection()
      else
        @projectedMatchingDataListSelectedIndex += 1

  _insertTypedValueIfAllowed: (valueToInsert)->

    ## NOTE we need to check if value is repeating or not
    # regardless if allowRepeatation is true or false due
    # to restrictions put in place by Polymer.
    matchedStringObject = null
    for stringObject in @selectedStringObjectList
      if stringObject.text is valueToInsert
        matchedStringObject = stringObject
        ## NOTE do not 'break' since we are interested only
        # in the last matching item and not the first
    if matchedStringObject
      unless @allowRepeatation
        return false

    ## NOTE we need to check if typedValue is in sourceDataList
    # in order to figure out if it is a custom value or not.
    matchedSourceData = null
    for sourceData in @sourceDataList
      if sourceData.text is valueToInsert
        matchedSourceData = sourceData
    unless matchedSourceData
      unless @allowCustom
        return false

    serial = (if matchedStringObject then matchedStringObject.serial + 1 else 0)
    stringObjectToInsert = 
      text: valueToInsert
      serial: serial

    @push 'selectedStringObjectList', stringObjectToInsert
    @fire 'autocomplete-select', { selectedStringObject: stringObjectToInsert, typedValue: @typedValue }
    return true

  _match: (typedValue)->

    if typedValue.length is 0
      @matchingDataList = []
      @.$.nomatch.textContent = 'Enter a Medicine Name'
      return

    priority1List = []
    priority2List = []
    priority3List = []
    priority4List = []
    priority5List = []
    priority6List = []
    priority7List = []
    for sourceData in @sourceDataList
      if sourceData.alt is typedValue
        priority1List.push sourceData
      else if sourceData.text is typedValue
        priority2List.push sourceData
      else if sourceData.text.toLowerCase() is typedValue.toLowerCase()
        priority3List.push sourceData
      else if (sourceData.text.indexOf typedValue) is 0
        priority4List.push sourceData
      else if (sourceData.text.toLowerCase().indexOf (typedValue.toLowerCase())) is 0
        priority5List.push sourceData
      else if (sourceData.text.indexOf typedValue) > -1
        priority6List.push sourceData
      else if (sourceData.text.toLowerCase().indexOf (typedValue.toLowerCase())) > -1
        priority7List.push sourceData
    @matchingDataList = [].concat priority1List, priority2List, priority3List, priority4List, priority5List, priority6List, priority7List

    if @matchingDataList.length is 0
      @.$.nomatch.textContent = 'No Match Found'

  projectedMatchingDataDivPressed: (e)->
    item = e.model.projectedMatchingData
    if @_insertTypedValueIfAllowed item.text
      @_match @typedValue

  inputKeyUpped: (e)->
    
    if e.which is 13 # ENTER/RETURN
      if @projectedMatchingDataListSelectedIndex isnt null
        item = @projectedMatchingDataList[@projectedMatchingDataListSelectedIndex]
        if @_insertTypedValueIfAllowed item.text
          @typedValue = item.text
          @projectedMatchingDataList = [] # added to clear the autocomplete suggestion
          # @_match @typedValue
      else
        if @_insertTypedValueIfAllowed @typedValue
          @typedValue = item.text
          @_match @typedValue
    else if e.which is 27 # ESCAPE
      if @projectedMatchingDataListSelectedIndex isnt null
        @projectedMatchingDataListSelectedIndex = null
      else
        @typedValue = ''
        @_match @typedValue
    else if e.which is 38 # UP
      @_goUpOnProjection()
    else if e.which is 40 # DOWN
      @_goDownOnProjection()
    else
      @.$.nomatch.textContent = ''
      @_match @typedValue
      




}
