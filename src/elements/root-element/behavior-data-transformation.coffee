
app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']

app.behaviors.local['root-element'].dataTransformation = 

  _applyTransformations: (collectedData)->
    # console.log collectedData
    list = collectedData['dynamicElementDefinitionOperationAnaesthesia'].childList

    obj = {
      type: "category"
      key: "graph"
      label: "Graph"
      isCustomCategory: true
      customElementName: 'custom-graph'
    }
    list.splice 1, 0, obj
