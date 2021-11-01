
staticData = null

cbfnQueue = []

unless app.behaviors.local['root-element']
  app.behaviors.local['root-element'] = {} 
app.behaviors.local['root-element'].dataLoader = 

  loadStaticData: ->
    @requestForLoadingStaticData()

  getStaticData: (name, cbfn)->
    unless name of staticData
      throw new Error 'Unknown static data "' + name + '" requested'

    if staticData[name] isnt null
      lib.util.setImmediate cbfn, staticData[name]
    else
      cbfnQueue.push {
        cbfn: cbfn
        name: name
      }

  afterLoadingStaticData: (collectedData)->
    staticData = collectedData

    for item in cbfnQueue
      lib.util.setImmediate item.cbfn, staticData[item.name]
  
  requestForLoadingStaticData: ->

    staticDataListProduction = [
      {
        name: 'investigationList'
        url: 'https://bdemr.b-cdn.net/investigation-list-8-7-2018.json'
      }
      
      {
        name: 'medicineCompositionList'
        url: 'https://bdemr.b-cdn.net/medicine-list-19-10-2017.json'
      }
      {
        name: 'pccMedicineList'
        url: 'https://bdemr.b-cdn.net/pcc-medicine-list-19-02-2018.json'
      }
      {
        name: 'proceduralAdviceList'
        url: 'https://bdemr.b-cdn.net/ophthalmology-procedural-advice-list-27-11-2019.json'
      }
      {
        name: 'operationList'
        url: 'https://bdemr.b-cdn.net/operation-list-05-12-2019.json'
      }
      {
        name: 'countryCityList'
        url: 'https://bdemr.b-cdn.net/countries-cities-list-10-11-2020.json'
      }      
    ]

    staticDataListLocal = [
      {
        name: 'investigationList'
        url: 'static-data/investigation-list.json'
      }
      {
        name: 'medicineCompositionList'
        url: 'static-data/medicine-list.json'
      }
      {
        name: 'pccMedicineList'
        url: 'static-data/pcc-medicine-list.json'
      }
      {
        name: 'proceduralAdviceList'
        url: 'static-data/ophthalmology-procedural-advice-list.json'
      }
      {
        name: 'operationList'
        url: 'static-data/operation-list.json'
      }
      {
        name: 'countryCityList'
        url: 'static-data/countries-cities-list.json'
      }
    ]

    if (app.mode is 'production') and (app.config.clientPlatform is 'web')
      staticDataList = staticDataListProduction
    else
      staticDataList = staticDataListLocal


    staticData = {}
    for item in staticDataList
      staticData[item.name] = null

    collection1 = new lib.util.Collector staticDataList.length

    it = new lib.util.Iterator staticDataList

    it.forEach (next, index, item)=>
      id = @notifyDownloadAction 'start', item.url
      successFn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'done', item.url, id
      lib.network.request item.url, 'GET', { fromApp: "#{app.config.clientIdentifier}-#{app.config.clientVersion}" }, (errorResponse, response)=>
        if errorResponse
          # alert 'xhr error'
          # console.log errorResponse
          @notifyDownloadAction 'error', item.url, id
          return

        successFn()
        json = JSON.parse response.target.responseText
        collection1.collect item.name, json
      next()

    it.finally -> null

    collection1.finally (collectedData)=> 
      @afterLoadingStaticData collectedData



