
{ delay } = lib.util

window.editor = {
  isVisible: false
  backButtonCallbackFn: null
}

window.editor.init = ()->
  console.log 'INSIDE EDITOR.COFFEE'
  jQuery('body').append '
    <div id="editorBlock">
      <div class="horizontal layout">
        <div self-center><paper-button class="btn success" id="editorBackButton" raised style="background-color: #43a047; color: #fff">&larr; Go Back</paper-button></div>
        <paper-input-decorator style="margin-left: 10px" label="File Name" hidden>
          <input type="text" is="core-input" id="editorDocumentTitle">
        </paper-input-decorator>
      </div>
      <textarea name="editor1" id="editor1" rows="20" cols="80">...</textarea>
      
      <div class="horizontal layout" hidden>
        <div>Insert Local Image</div>
        <input id="imageInput" type="file" accept="image/*" />
      </div>
      
    </div>'
  delay 100, =>
    POLYEDITOR.replace (document.querySelector '#editor1'),
      uiColor: '#FFFFFF'
      height: 400
      allowedContent: true
      pasteFromWordRemoveFontStyles: false
      pasteFromWordRemoveStyles: false
      pasteFromWordPromptCleanup: false
      toolbarGroups: [
        {
          name: 'document'
          groups: [
            'mode'
            'document'
            'doctools'
          ]
        }
        {
          name: 'clipboard'
          groups: [
            'clipboard'
            'undo'
          ]
        }
        {
          name: 'editing'
          groups: [
            'find'
            'selection'
            'spellchecker'
            'editing'
          ]
        }
        {
          name: 'forms'
          groups: [ 'forms' ]
        }
        {
          name: 'basicstyles'
          groups: [
            'basicstyles'
            'cleanup'
          ]
        }
        {
          name: 'paragraph'
          groups: [
            'list'
            'indent'
            'blocks'
            'align'
            'bidi'
            'paragraph'
          ]
        }
        {
          name: 'links'
          groups: [ 'links' ]
        }
        {
          name: 'insert'
          groups: [ 'insert' ]
        }
        {
          name: 'styles'
          groups: [ 'styles' ]
        }
        {
          name: 'colors'
          groups: [ 'colors' ]
        }
        {
          name: 'tools'
          groups: [ 'tools' ]
        }
        {
          name: 'others'
          groups: [ 'others' ]
        }
        {
          name: 'about'
          groups: [ 'about' ]
        }
      ]
      removeButtons: 'Save,Templates,Scayt,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,CreateDiv,Blockquote,Language,BidiRtl,Anchor,Flash,Smiley,Format,Maximize,ShowBlocks,About'
    jQuery('#editorBackButton').click (e)->
      window.editor.hide()
      if window.editor.backButtonCallbackFn
        cbfn = window.editor.backButtonCallbackFn
        window.editor.backButtonCallbackFn = null
        delay 50, => 
          cbfn()

    document.querySelector('#imageInput').addEventListener 'change', (event) ->
      input = event.target
      reader = new FileReader

      reader.onload = ->
        data = reader.result
        POLYEDITOR.instances.editor1.insertHtml '<img src="' + data + '"/>'

      reader.readAsDataURL input.files[0]




window.editor.show = ->
  jQuery('root-element').hide()
  jQuery('#editorBlock').show()
  window.editor.isVisible = true

window.editor.hide = ->
  jQuery('root-element').show()
  jQuery('#editorBlock').hide()
  window.editor.isVisible = false

window.editor.toggle =->
  if window.editor.isVisible
    window.editor.hide()
  else
    window.editor.show()

window.editor.setContent = (content)->
  delay 1000, =>
    POLYEDITOR.instances.editor1.setData content

window.editor.getContent = (content)->
  return POLYEDITOR.instances.editor1.getData()

window.editor.setTitle = (title)->
  jQuery('#editorDocumentTitle').val(title)

window.editor.getTitle = ()->
  jQuery('#editorDocumentTitle').val()

window.editor.setBackButtonCallbackFn = (cbfn)->
  window.editor.backButtonCallbackFn = cbfn

