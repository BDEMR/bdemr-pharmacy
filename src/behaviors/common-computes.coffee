app.behaviors.commonComputes = 

  $equals: (left, right)-> left is right

  $if: (value, thenValue, elseValue)-> if value then thenValue else elseValue

  $iff: (value)-> value

  $sum: (a,b)-> (parseInt a) + (parseInt b)

  $and: (a,b)-> a and b

  $toTwoDecimalPlace: (number)->
    # console.log "number", number
    return 0 if isNaN(number) or not number
    return Number.parseFloat(number).toFixed(2)
  
  $truncate: (string, maxCount)->
    return string if string.length <= maxCount
    return (string.substr 0, (maxCount - 3)) + '...'

  $loadPatientLocallyBySerial: (patientIdentifier)->
    patient = {}
    list = app.db.find 'patient-list', ({serial})-> serial is patientIdentifier
    if list.length is 1 then return list[0]
    return null


  $getTodayDate: ()-> new Date().toISOString().split('T')[0]


  $mkDate: (date)-> lib.datetime.mkDate date

  $compareFn: (left, op, right) ->
    # console.log left, op, right
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

  $mkDateTime: (ms)->
    if typeof ms is 'undefined'
      return lib.datetime.now()
    else
      return lib.datetime.format((new Date ms), 'mmm d, yyyy h:MMTT')

  $mkTime: (ms)-> lib.datetime.format((new Date ms), 'HH-MM-ss')

  $formatDate: (date)->
    return '' unless date
    formatObj = { 
      timeZone: 'Asia/Dhaka' 
      day: 'numeric'
      month: 'short'
      year: 'numeric'
    }
    return new Date(date).toLocaleString('en-GB', formatObj)

  $formatDateTime: (dateTime)->
    return '' unless dateTime
    formatObj = { 
      timeZone: 'Asia/Dhaka' 
      day: 'numeric'
      month: 'short'
      year: 'numeric'
      hour: '2-digit'
      minute: '2-digit'
    }
    # lib.datetime.format((new Date dateTime), 'mmm d, yyyy h:MMTT')
    return new Date(dateTime).toLocaleString('en-IN', formatObj)

  
  $getFormatted12HRTimeFromMS: (ms)->
    return lib.datetime.format ((new Date).setTime ms), 'hh:MM TT'

  $getFormatted24HRTimeFromMS: (ms)->
    return lib.datetime.format ((new Date).setTime ms), 'HH:mm'


  # This Function takes string as an input and then formats the string to a 12 hour format time string.
  # Example String: "18:00:00" Formatted String: '6 PM'
  $formatTimeString: (timeString)->
    if timeString
      H = +timeString.substr(0, 2)
      h = (H % 12) || 12
      ampm = " PM"
      if H < 12 
        ampm = " AM"
      timeString = h + timeString.substr(2, 3) + ampm
      return timeString
  
  # This functions takes our internal timeslot (ex: "18-00-00 to 22-00-00") as input and process it to a 12 hour format using the $formatTimeString Function
  # Example String: "18-00-00 to 22-00-00", Formatted String: "6 PM to 8 PM"
  $formatTimeSlotString: (timeSlotString)->
    fromTimeStr = timeSlotString.substr(0, 7)
    toTimeStr = timeSlotString.substr(12, 7)
    timeStr = @$formatTimeString(fromTimeStr) + " to " + @$formatTimeString(toTimeStr)
    return timeStr
    
  $getFormatted12HRTimeFromMS: (ms)->
    return lib.datetime.format ((new Date).setTime ms), 'hh:MM TT'

  $getFormatted24HRTimeFromMS: (ms)->
    return lib.datetime.format ((new Date).setTime ms), 'HH:mm'
    
  $formatTimeStampToTimeString: (dateTimeStamp)->
    dateObject = new Date dateTimeStamp
    hour = dateObject.getHours()
    if hour.toString().length is 1
      hour = '0' + hour
    minute = dateObject.getMinutes()
    if minute.toString().length is 1
      minute = '0' + minute
    timeString = hour + ':' + minute
    H = +timeString.substr(0, 2)
    h = (H % 12) || 12
    ampm = " PM"
    if H < 12 
      ampm = " AM"
    timeString = h + timeString.substr(2, 3) + ampm
    return timeString

  $getDay: (dayCount)->
    day = new Date(new Date().setDate(new Date().getDate() + dayCount))
    dd = day.getDate()
    mm = day.getMonth() + 1
    yyyy = day.getFullYear()
    if dd < 10
      dd = '0'+ dd
    if mm < 10
      mm = '0' + mm
    date = yyyy + '-' + mm + '-'+ dd
    return date


  $in: (item, list...)->
    item in list

  $returnSerial: (index)->
    index+1

  $formatCurrency: (num = 0)->
    return 0 if (isNaN(parseFloat num))
    return parseFloat(num).toLocaleString 'en-US', { style: 'currency', currency: 'BDT' }

  $isEmptyArray: (len)->
    if len is 0
      return true
    else
      return false
  
  $isEmptyString: (data)->
    if data is null or data is '' or data is 'undefined'
      return true
    else
      return false

  $getFormattedDate: (date, format='dd/mm/yyyy')->
    return '' unless date
    return lib.datetime.format (new Date date), format

  $getFormattedDateTime: (date, format='dd/mm/yyyy h:MMTT')->
    return '' unless date
    return lib.datetime.format (new Date date), format
  

  $computeAge: (dateString)->
    return "" unless dateString
    today = new Date()
    birthDate = new Date dateString
    yearDiff = today.getFullYear() - birthDate.getFullYear()
    monthDiff = today.getMonth() - birthDate.getMonth()
    dateDiff = today.getDate() - birthDate.getDate()

    if monthDiff is 0
      if dateDiff < 0
        yearDiff-- unless yearDiff is 0
        monthDiff = 11
    else if monthDiff < 0
      yearDiff-- unless yearDiff is 0
      monthDiff = 12 - Math.abs monthDiff
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0
    else
      monthDiff-- if dateDiff < 0 and monthDiff isnt 0

    return "#{yearDiff} years" if yearDiff isnt 0
    return "#{monthDiff} months" if monthDiff isnt 0

    # previous code
    # return '' unless dateString
    # today = new Date()
    # birthDate = new Date dateString
    # age = today.getFullYear() - birthDate.getFullYear()
    # m = today.getMonth() - birthDate.getMonth()
    # if m < 0 || (m == 0 && today.getDate() < birthDate.getDate())
    #   age--
    # return age

  $getFullName:(data)->

    return '' unless data

    if typeof data is "object"
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

    else
      # data= data.slice(2)
      return data


  $makeNameObject: (fullName)->

    if typeof fullName is 'string'

      fullName = fullName.trim()

      middle = null
      last = null

      partArray = fullName.split('.')

      namePart = partArray.pop()

      if partArray.length is 0 
        honorifics = ''
      else
        honorifics = partArray.join('.').trim()

      partArray = (namePart.trim()).split(' ')

      nameObject = {}

      if (partArray.length <= 1)
        first = partArray[0]
      else
        first = partArray.shift()
        last = partArray.pop()
        middle = partArray.join(' ')

        if middle is ''
          middle = null
        
        if last is ''
          last = null

      if honorifics is ''
        honorifics = null

      nameObject.honorifics = honorifics
      nameObject.first = first
      nameObject.middle = middle
      nameObject.last = last
      return nameObject
    else
      return fullName


  $getProfileImage: (data)->
    # console.log {data}
    if data
      return data
    else
      return 'images/avatar.png'


  $getAuthorizedOrganizationList: ()->

    list = app.db.find 'settings', ({serial})=> @user.serial is serial

    serialList = []

    if list
      if list.length > 0
        authorizedOrganiztionList = list[0].authorizedOrganiztionList

        for item in authorizedOrganiztionList
          if item.isChecked
            serialList.push item.idOnServer
 
    return serialList
  
  $checkUserAccess: (accessId)->
    currentOrganization = @getCurrentOrganization()

    if accessId is 'none'
      return true
    else
      if currentOrganization

        if currentOrganization.isCurrentUserAnAdmin
          return true
        else if currentOrganization.isCurrentUserAMember
          if currentOrganization.userActiveRole
            privilegeList = currentOrganization.userActiveRole.privilegeList
            unless privilegeList.length is 0
              for privilege in privilegeList
                if privilege.serial is accessId
                  return true
          else
            return true

          return false
        else
          return false

      else
        # @navigateToPage "#/select-organization"
        return true

  
  _isUserExistOnLocation: (assignedUserList, userIdentifier)->
    currentOrganization = @getCurrentOrganization()
    if currentOrganization.isCurrentUserAnAdmin
      return true
    else 
      for item in assignedUserList
        if item.idOnServer is userIdentifier
          return true
      return false

  $getWardListFilterByUserId: (departmentList, userIdentifier)->
    # console.log departmentList, userIdentifier
    wardList = []
    for dept in departmentList
      if @_isUserExistOnLocation dept.assignedUserList, userIdentifier
        for unit in dept.unitList
          for ward in unit.wardList
            object = 
              name: ward.name
              serial: ward.serial
              deptSerial: dept.serial
              unitSerial: unit.serial
              deptName: dept.name
              unitName: unit.name
            wardList.push object
      else
        for unit in dept.unitList
          if @_isUserExistOnLocation unit.assignedUserList, userIdentifier
            for ward in unit.wardList
              object = 
                name: ward.name
                serial: ward.serial
                deptSerial: dept.serial
                unitSerial: unit.serial
                deptName: dept.name
                unitName: unit.name
          else
              wardList.push object
            for ward in unit.wardList
              if @_isUserExistOnLocation ward.assignedUserList, userIdentifier
                object = 
                  name: ward.name
                  serial: ward.serial
                  deptSerial: dept.serial
                  unitSerial: unit.serial
                  deptName: dept.name
                  unitName: unit.name
                wardList.push object
    
    # console.log wardList
    
    return wardList

  $getOrganizationSpecificUserSettings: (apiKey, organizationId, cbfn)->
    data =
      apiKey:  apiKey
      organizationId: organizationId

    @callApi '/bdemr-get-organization-specific-user-settings', data, (err, response)=>
      if response.hasError
        if response.error.message is "NO_DATA_FOUND"
          cbfn null
      else
        settings = response.data
        cbfn settings
  
  $setOrganizationSpecificUserSettings: (apiKey, organizationId, settings, cbfn)->
    settings.lastModifiedDatetimeStamp = lib.datetime.now()
    app.db.upsert 'settings', settings, ({idOnServer})=> settings.idOnServer is idOnServer
    
    # because settings.idOnServer does contain db id of this settings object. we need to set that to _id in order to save on server
    settings._id = settings.idOnServer
    delete settings.idOnServer

    data = { apiKey, organizationId, settings}
    @callApi '/bdemr-set-organization-specific-user-settings', data, (err, response)=>
      # console.log response
      if response.hasError
        @domHost.showModalDialog response.error.message
      else
        cbfn()


  $isEmptyArray: (len)->
    if len is 0
      return true
    else
      return false

  $isGreaterThanZero: (value)->
    if value > 0
      return true
    else
      return false

  $islessThanZero: (value)->
    if value <= 0
      return true
    else
      return false

  $getAddress:(patient)->
    return null if patient.addressList.length is 0

    address = patient.addressList[0]

    delete address.addressTitle
    delete address.addressType

    address = Object.values address
    address = address.filter (item) => item

    return address.join()
  
  $getActiveUserList: ()->
    socket = io "http://localhost:8671"

    socket.on 'active user list', (data)=>
      activeUserList = data.activeUserList
      console.log {activeUserList}
      return [] if typeof activeUserList is 'object'
      return activeUserList if Array.isArray activeUserList
      
  $getDoctorFeeWithChargesIncluded: (fee)->
    fee = parseFloat fee
    govTax = (fee * 5) / 100
    feeWithGovTax = fee + govTax
    agentCommission = (fee * 12) / 100
    feeWithGovTaxAndServiceCharge = feeWithGovTax + 25 + agentCommission
    return feeWithGovTaxAndServiceCharge


