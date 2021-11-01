
defaultNewTemplate = {
  pathString: '/',
  name: 'Untitled',
  content: '<h1>Title goes here</h1><br><div>Content goes here</div>'
}

Polymer {
  
  is: 'page-view-template'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
    app.behaviors.commonComputes
    app.behaviors.dbUsing
  ]

  properties:
    matchingTemplateList: 
      type: Array
      value: -> []

    pathString: 
      type: String,
      value: '/'

    newTemplate:
      type: Object
      value: => JSON.parse(JSON.stringify(defaultNewTemplate))

    organization:
      type: Object
      notify: true
      value: (app.db.find 'organization')[0]

  navigatedIn: ->
    @_getTree()
    if window.editor.toEdit && window.editor.toEdit.length > 2
      this.newTemplate.content = window.editor.toEdit
    this._assertTemplateContent();

  _assertTemplateContent: ->
    this.$$('.editor-content').innerHTML = this.newTemplate.content

  _list: ->
    data = {
      apiKey: (app.db.find 'user')[0].apiKey
      pathString: this.pathString
      organizationIdList: [@organization.idOnServer]
    }
    this.domHost.callApi '/bdemr--template-manager--list', data, (err, response)=>
      if (not err) and (not response.hasError)
        # console.log(response)
        this.matchingTemplateList = response.data.templateList
        # @domHost.navigateToPage '#/record-editor/record:' + template._recordSerial
  
  _getTree: ->
    data = {
      apiKey: (app.db.find 'user')[0].apiKey
      organizationIdList: [@organization.idOnServer]
    }
    this.domHost.callApi '/bdemr--template-manager--get-tree', data, (err, response)=>
      if (not err) and (not response.hasError)
        templateMap = response.data.templateMap
        fn = (name, map)=>
          childList = []
          for key, value of map
            childList.push(fn(key, value))
          return {name, childList, selectedIndex: 0}
        templateMap = fn('Root', templateMap['Root']);
        console.log('template map',templateMap)
        this.templateMap = templateMap
          
  reportValue: (pathString)->
    pathString = pathString.replace('Root','')
    this.set('newTemplate.pathString', pathString);
    this.pathString = pathString
    this._list();

  editTapped: (e = null)->
    window.editor.toEdit = this.newTemplate.content
    @domHost.navigateToPage '#/editor'

  saveTapped: (e = null)->
    data = {
      apiKey: (app.db.find 'user')[0].apiKey
      organizationId: @organization.idOnServer
    }
    Object.assign(data, this.newTemplate)
    this.domHost.callApi '/bdemr--template-manager--set', data, (err, response)=>
      if (not err) and (not response.hasError)
        this.domHost.showModalDialog("Thank You. Your template has been saved");
      this._list();

  templatePressed: (e)->
    { template } = e.model
    console.log('template', template);
    this.newTemplate = template
    this._assertTemplateContent();

  resetTapped: (e = null)->
    path = this.pathString
    this.newTemplate = JSON.parse(JSON.stringify(defaultNewTemplate));
    this.set('newTemplate.pathString', this.pathString);
    this._assertTemplateContent();

}
