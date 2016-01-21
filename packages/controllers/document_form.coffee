if Meteor.isClient

  handleUploadedFile = (files) ->
    if !files or files.length < 1
      throw new Meteor.Error 'No files provided'

    file = files[0]

    if file.size > 4000000
      return toastr.error "File #{file.name} is too large"
    else if file.size < 1
      return toastr.error "File #{file.name} is empty"

    fileReader = new FileReader()

    fileReader.onload = ((theFile, theReader) ->
      (e) ->
        # extract the base64 string from the data-URI
        fileDataB64 = theReader.result.split(',').pop()
        # Meteor.call 'uploadDocument', fileDataB64, (error, text) ->
        Meteor.call 'parseDocumentLocally', fileDataB64, (error, text) ->
          if error
            if error.reason
              for key, value of error.reason
                toastr.error('Error: ' + value)
            else
              toastr.error('Unknown Error')
          else
            $('#document-title').val theFile.name.replace(/\.[^/.]+$/, '')
            $('#document-body').val text.trim()
    )(file, fileReader)

    fileReader.readAsDataURL file

  Template.documentForm.onCreated ->
    @subscribe 'groups'

  Template.documentForm.helpers
    groups: ->
      Groups.find({}, { sort: { name: 1 } })

  Template.documentForm.events
    'change .drop-zone input': (event, instance) ->
      handleUploadedFile event.target.files
      event.currentTarget.value = '' # if the next file has the same file name

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
          if error.reason
            for key, value of error.reason
              toastr.error('Error: ' + value)
          else
            toastr.error('Unknown Error')
        else
          toastr.success('Success')
          go 'documentDetail', { _id: response }


Meteor.methods
  createDocument: (fields) ->
    unless fields.groupId
      throw new Meteor.Error('Required', ['A document group has not been selected'])
    if @userId
      group = Groups.findOne fields.groupId
      user = Meteor.user()
      if group?.viewableByUser(user)
        document = new Document()
        document.set(fields)

        if document.validate()
          document.save ->
            document
        else
          document.throwValidationException()
      else
        throw new Meteor.Error('Unauthorized')
    else
      throw new Meteor.Error('Not logged in')


if Meteor.isServer


  # Load future from fibers
  Future = Npm.require("fibers/future")
  # Load exec
  spawn = Npm.require("child_process").spawn
  exec = Npm.require("child_process").exec

  tikaURL = 'http://localhost:9998/tika'

  Meteor.methods
    uploadDocument: (fileDataB64)->
      @unblock()
      check fileDataB64, String

      blobStringUTF8 = new Buffer(fileDataB64, 'base64')#.toString()

      res = request.putSync(tikaURL, {
        body: blobStringUTF8,
        encoding: null
      })

      plainText = new Buffer(res.body).toString()

      if plainText.length
        plainText
      else
        throw new Meteor.Error('Unable to process the document')

    parseDocumentLocally: (fileDataB64)->
      @unblock()
      future = new Future()

      ###
      # Run node with the child.js file as an argument
      child = spawn 'java', ['-jar', '/tmp/tika.jar', '-t', '-']
      # Send data to the child process via its stdin stream
      child.stdin.write("Hello there!") # new Buffer(fileDataB64, 'base64').toString()
      # Listen for any response from the child:
      child.stdout.on 'data', (data)->
        console.log('We received a reply: ' + data)
      # Listen for any errors:
      child.stderr.on 'data', (data)->
        console.log('There was an error: ' + data)
      ###

      command = "echo #{fileDataB64} | base64 -D | java -jar /tmp/tika.jar -t -"
      exec command, (error, stdout, stderr)->
        if error
          console.log(error)
          throw new Meteor.Error(500, command + " failed")
        console.log stdout
        future.return stdout
      future.wait()
