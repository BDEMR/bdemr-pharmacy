Polymer {
  is: 'page-my-id-card'

  behaviors: [
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.commonComputes
  ]

  properties:
    code:
      type: String
      value: null
    
    organization:
      type: Object
      value: (app.db.find 'organization')[0]
    
    user:
      type: Object
      value: (app.db.find 'user')[0]
   
  navigatedIn: ->
    console.log @organization, @user

}