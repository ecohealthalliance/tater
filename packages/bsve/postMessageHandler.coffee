postMessageHandler = (event)->
  if not event.origin.match(/^https:\/\/([\w\-]+\.)*bsvecosystem\.net/) then return
  try
    request = JSON.parse(event.data)
  catch
    return
  if request.type == "eha.dossierRequest"
    title = "TATER"
    url = window.location.toString()
    if $(".document-title").length
      title = $(".document-title").text()
    window.parent.postMessage(JSON.stringify({
      type: "eha.dossierTag"
      html: """<a target="_blank" href='#{url}'>Open TATER</a>"""
      title: title
    }), event.origin)

window.addEventListener("message", postMessageHandler, false)