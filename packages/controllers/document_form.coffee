if Meteor.isClient

  handleError = (error) ->
    reason = error.reason
    if reason and _.isString(reason)
      toastr.error('Error: ' + reason)
    else if reason
      for key, value of reason
        toastr.error('Error: ' + value)
    else
      toastr.error('Unknown Error')

  handleUploadedFile = (files) ->
    if !files or files.length < 1
      throw new Meteor.Error 'No files provided'

    file = files[0]

    # Limit the upload size to preserve server resources
    if file.size > 4 * 1024 * 1024
      return toastr.error "File #{file.name} is too large"
    else if file.size < 1
      return toastr.error "File #{file.name} is empty"

    fileReader = new FileReader()

    fileReader.onload = ((theFile, theReader) ->
      (e) ->
        # extract the base64 string from data-URI
        fileDataB64 = theReader.result.split(',').pop()
        Meteor.call 'uploadDocument', fileDataB64, (error, text) ->
          if error
            handleError(error)
          else
            $('#document-title').val theFile.name.replace(/\.[^/.]+$/, '')
            $('#document-body').val text.trim()
    )(file, fileReader)

    fileReader.readAsDataURL file

  Template.documentForm.onCreated ->
    @subscribe 'groups'
    @codeAccessible = new ReactiveVar(false)

  Template.documentForm.onRendered ->
    $("[data-toggle='tooltip']").tooltip()

  Template.documentForm.helpers
    groups: ->
      Groups.find({}, { sort: { name: 1 } })
    codeAccessible: ->
      Template.instance().codeAccessible.get()

  Template.documentForm.events
    'change .drop-zone input': (event, instance) ->
      handleUploadedFile event.target.files
      event.currentTarget.value = '' # if the next file has the same file name

    'dragenter .drop-zone': (event, instance) ->
      $(event.currentTarget).toggleClass('active')

    'dragleave .drop-zone': (event, instance) ->
      $(event.currentTarget).toggleClass('active')

    'dragenter .drop-zone, dragover .drop-zone': (event, instance) ->
      event.preventDefault()
      event.stopPropagation()

    'drop .drop-zone': (event, instance) ->
      event.preventDefault()
      event.stopPropagation()
      handleUploadedFile event.originalEvent.dataTransfer.files

    'submit #new-document-form': (event, instance) ->
      event.preventDefault()
      form = event.target
      fields = {
        title: form.title?.value.trim()
        body: form.body?.value.trim()
      }
      currentUser = Meteor.user()
      if currentUser.admin
        fields.groupId = form.groupId?.value
      else
        fields.groupId = currentUser.group

      Meteor.call 'createDocument', fields, (error, response) ->
        if error
          handleError(error)
        else
          toastr.success('Success')
          go 'documentDetail', { _id: response }


Meteor.methods
  createDocument: (fields) ->
    check fields, Object
    unless fields.groupId
      throw new Meteor.Error('Required', ['A document group has not been selected'])
    check fields.groupId, String
    if @userId
      group = Groups.findOne(fields.groupId)
      user = Meteor.user()
      if group?.viewableByUser(user)
        document = new Document()
        document.set(fields)
        if document.validate()
          document.save()
        else
          document.throwValidationException()
      else
        throw new Meteor.Error('Unauthorized', 'You cannot upload documents to this group')
    else
      throw new Meteor.Error('Unauthorized', 'You must be logged in to add documents')


if Meteor.isServer

  tikaURL = 'http://tika.tater.io:9998/tika'

  Meteor.methods
    uploadDocument: (fileDataB64)->
      @unblock()
      check fileDataB64, String

      blobStringUTF8 = new Buffer(fileDataB64, 'base64')

      res = request.putSync tikaURL,
        body: blobStringUTF8
        encoding: null

      plainText = new Buffer(res.body).toString()

      if plainText.length
        plainText
      else
        throw new Meteor.Error('Upload error', 'Unable to process the document')
