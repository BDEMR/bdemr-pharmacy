Polymer {
  is: 'page-duty-roster-editor'
  
  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.pageLike
    app.behaviors.translating
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]
  
  properties:
    selectedPage:
      type: Number
      value: 0

   
  
  navigatedIn: ->
    console.log 'hello from duty roster editor'
    
} 