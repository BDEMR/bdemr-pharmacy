
# Dialog - Validate Voucher

dialogValidateVoucher = ->
  el = document.getElementById('dialogValidateVoucher')
  el.style.visibility = if el.style.visibility == 'visible' then 'hidden' else 'visible'
  return

# Dialog - Purchase Voucher

dialogPurchaseVoucher = ->
  el = document.getElementById('dialogPurchaseVoucher')
  el.style.visibility = if el.style.visibility == 'visible' then 'hidden' else 'visible'

# Pressed on purchase voucher

dialogPurchaseVoucherPurchasePressed = (e)->
  valuePerVoucher = parseInt (jQuery('#inputPurchaseVoucherType option:selected').text())
  numberOfVouchers = parseInt (jQuery('#inputPurchaseVoucherCount').val())
  email = jQuery('#inputPurchaseVoucherEmail').val()

  unless valuePerVoucher > 0
    return alert 'Invalid voucher amount'

  unless numberOfVouchers > 0
    return alert 'Invalid voucher count'

  if numberOfVouchers > 100
    return alert 'Can only print less than 100 vouchers at once'

  data = {
    valuePerVoucher
    numberOfVouchers
    email
  }

  json = JSON.stringify data

  if window.location.hostname is 'localhost'
    targetHost = 'http://localhost:8671'
  else
    targetHost = 'https://bdemr.services'

  apiUrl = targetHost + '/api/1/' + 'bdemr-com-voucher-purchase'

  jQuery.ajax {
    url: apiUrl
    data: json
    method: 'POST'
    dataType: 'json'
    success: (response, textStatus, jqXHR)->
      if response.hasError
        alert response.error.message
      else
        { redirectionUrl } = response.data
        if redirectionUrl
          window.location = redirectionUrl
        else
          alert 'Server Error. Expected redirectionUrl'
    error: (jqXHR, textStatus, errorThrown)->
      console.log jqXHR, textStatus, errorThrown
      alert textStatus + errorThrown
  }

# Pressed on Validate Voucher

dialogValidateVoucherValidatePressed = (e)->
  voucherCode = (jQuery('#inputValidateVoucherCode').val())

  unless voucherCode.length > 10
    return alert 'Invalid voucher code'

  data = {
    voucherCode: voucherCode
  }

  json = JSON.stringify data

  if window.location.hostname is 'localhost'
    targetHost = 'http://localhost:8671'
  else
    targetHost = 'https://bdemr.services'

  apiUrl = targetHost + '/api/1/' + 'bdemr-com-voucher-validate'

  jQuery.ajax {
    url: apiUrl
    data: json
    method: 'POST'
    dataType: 'json'
    success: (response, textStatus, jqXHR)->
      if response.hasError
        alert response.error.message
      else
        alert response.data.message

    error: (jqXHR, textStatus, errorThrown)->
      console.log jqXHR, textStatus, errorThrown
      alert textStatus + errorThrown
  }

## On Ready

jQuery(document).on 'ready', (e)->
  jQuery('#dialogPurchaseVoucherPurchaseButton').click dialogPurchaseVoucherPurchasePressed
  jQuery('#dialogValidateVoucherValidateButton').click dialogValidateVoucherValidatePressed
  
  if getQueryVariable('op') is 'retrieve-voucher'
    return retrieveVouchers()

## This part deals with retrieving tokens

`
  function getQueryVariable(variable) {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if (pair[0] == variable) {
        return pair[1];
      }
    }
    return null
  }
`

# http://localhost:4000/?op=retrieve-voucher&public-token=FAKEFAKEFAKEFAKE3

retrieveVouchers = ->
  publicToken = getQueryVariable('public-token')
  unless publicToken
    alert 'Missing public token'

  data = {
    publicToken
  }

  json = JSON.stringify data

  if window.location.hostname is 'localhost'
    targetHost = 'http://localhost:8671'
  else
    targetHost = 'https://bdemr.services'

  apiUrl = targetHost + '/api/1/' + 'bdemr-com-voucher-retrieve'

  jQuery.ajax {
    url: apiUrl
    data: json
    method: 'POST'
    dataType: 'json'
    success: (response, textStatus, jqXHR)->
      if response.hasError
        alert response.error.message
      else
        if 'status' of response.data and response.data.status is 'success'
          { voucherList } = response.data
          message = 'Your ordered vouchers are: ' + (voucherList.join ', ')
          alert message
        else
          alert 'Unknown server side error'
    error: (jqXHR, textStatus, errorThrown)->
      console.log jqXHR, textStatus, errorThrown
      alert textStatus + errorThrown
  }




