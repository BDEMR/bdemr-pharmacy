Polymer {
  is: 'custom-vital-search'

  behaviors: [ 
    app.behaviors.translating
  ]

  properties:
    startDate:
      type: String
      value: ''
      
    endDate:
      type: String
      value: ''
      
    filterDateRange:
      type: String
      value: ''
      reflectToAttribute: true

  filterButtonClicked: (e, detail)->
    @filterDateRange = "#{lib.datetime.format @startDate, 'mmm d, yyyy'} - #{lib.datetime.format @endDate, 'mmm d, yyyy'}"
    @fire 'date-select', {startDate: @startDate, endDate: @endDate}

  clearIconClicked: ()->
    @filterDateRange = ''
    @startDate = ''
    @endDate = ''
    @fire 'clear', {}
  
  showFilterModalButtonClicked: (e)->
    @.$.filterModal.toggle()
    #reset data
    @startDate = ''
    @endDate = ''

}