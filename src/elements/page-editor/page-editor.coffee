
Polymer {

  is: 'page-editor'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
  ]

  properties: {
    fromTemplate:
      type: Boolean
      value: false
  }

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  presentEditor: ->
    editor.hide()
    editor.show()
    editor.setContent(editor.toEdit)
    editor.setBackButtonCallbackFn (@editorBackButtonPressed.bind @)

  navigatedIn: ->
    params = @domHost.getPageParams()
    
    @set 'fromTemplate', JSON.parse localStorage.getItem 'from_generic_template'
    localStorage.removeItem 'from_generic_template'

    # if params['patient']
    #   @_loadPatient params['patient']
    # else
    #   @_notifyInvalidPatient()
    # resetLayout 
    if editor.isInitialized
      @presentEditor()
    else
      lib.util.delay 100, =>
        editor.init()
        editor.isInitialized = true
        @presentEditor()

  editorBackButtonPressed: (content)->
    content = editor.getContent()
    el = @domHost.querySelector 'app-drawer-layout'
    el.resetLayout()
    editor.toEdit = content

    if @fromTemplate
      localStorage.setItem 'returning_from_generic_editor', JSON.stringify true
      localStorage.setItem 'updated_template_content', JSON.stringify content
      
    @domHost.navigateToPreviousPage()

  navigatedOut: ->
    

}
