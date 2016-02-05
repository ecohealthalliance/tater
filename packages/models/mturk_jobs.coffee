MTurkJobs = new Mongo.Collection('mturkJobs')
MTurkJob = Astro.Class
  name: 'MTurkJob'
  collection: MTurkJobs
  fields:
    documentId: 'string'
    title:
      type: 'string'
      default: """
      Annotate a document
      """
      validator: [
        Validators.required()
        Validators.maxLength(128, 'Mechanical Turk does not allow titles longer than 128 characters.')
      ]
    description:
      type: 'string'
      default: """
      Highlight spans of text and assign coding keywords to them.
      """
      validator: [
        Validators.required()
        Validators.maxLength(2000, 'Mechanical Turk does not allow descriptions longer than 2000 characters.')
      ]
    HITId: 'string'
    createHITResponse: 'object'
    disableHITResponse: 'object'
  behaviors: ['timestamp']

  events:
    afterSave: ->
      if Meteor.isServer and not @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          console.log "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        # Parameters documented here:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_CreateHITOperation.html
        service   = "AWSMechanicalTurkRequester"
        operation = "CreateHIT"
        timestamp = new Date().toISOString()
        signature = CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA1(
          service + operation + timestamp,
          Meteor.settings.private.AWS_SECRET_KEY
        ))
        # rootUrl cannot be localhost or calls to mturk will fail.
        if process.env.ROOT_URL.match("localhost")
          rootUrl = "https://staging.tater.io"
        else
          rootUrl = process.env.ROOT_URL
        if process.env.MTURK_URL
          mturkUrl = process.env.MTURK_URL
        else
          console.log "MTURK_URL is not defined, defaulting to the sandbox API."
          mturkUrl = "https://mechanicalturk.sandbox.amazonaws.com"
        response = HTTP.post(mturkUrl, {
          params:
            Service: service
            AWSAccessKeyId: Meteor.settings.private.AWS_ACCESS_KEY
            Version: "2014-08-15"
            Operation: operation
            Timestamp: timestamp
            Signature: signature
            Title: @title
            Description: @description
            Question: """
            <ExternalQuestion xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd">
              <ExternalURL>#{Meteor.absoluteUrl("documents", {
                secure: true
                rootUrl: rootUrl
              })}/#{@documentId}</ExternalURL>
              <FrameHeight>600</FrameHeight>
            </ExternalQuestion>
            """
            "Reward.1.Amount": 1
            "Reward.1.CurrencyCode": "USD"
            AssignmentDurationInSeconds: 6000
            # HIT lifetime must be greater than 30 seconds.
            # HIT lifetime cannot exceed 31536000 seconds.
            LifetimeInSeconds: 30 * 24 * 60 * 60 # 30 days
            MaxAssignments: 1
            Keywords: "annotation, highlighting, QDA, tater"
            # Leaving this at 0 for instant approval until we add some review
            # features to the application.
            AutoApprovalDelayInSeconds: 0
        })
        CreateHITResponseJSON = xml2json(response.content).CreateHITResponse
        @set('createHITResponse', CreateHITResponseJSON)
        if CreateHITResponseJSON.HIT?.HITId
          @set('HITId', CreateHITResponseJSON.HIT.HITId)
          document = Documents.findOne(@documentId)
          document.set('mTurkEnabled', true)
          document.save()
        @save()

  methods:
    cancel: ->
      if Meteor.isServer and @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          console.log "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        # Parameters documented here:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_DisableHITOperation.html
        service   = "AWSMechanicalTurkRequester"
        operation = "DisableHIT"
        timestamp = new Date().toISOString()
        signature = CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA1(
          service + operation + timestamp,
          Meteor.settings.private.AWS_SECRET_KEY
        ))
        # rootUrl cannot be localhost or calls to mturk will fail.
        if process.env.ROOT_URL.match("localhost")
          rootUrl = "https://staging.tater.io"
        else
          rootUrl = process.env.ROOT_URL
        if process.env.MTURK_URL
          mturkUrl = process.env.MTURK_URL
        else
          console.log "MTURK_URL is not defined, defaulting to the sandbox API."
          mturkUrl = "https://mechanicalturk.sandbox.amazonaws.com"
        response = HTTP.post(mturkUrl, {
          params:
            Service: service
            AWSAccessKeyId: Meteor.settings.private.AWS_ACCESS_KEY
            Version: "2014-08-15"
            Operation: operation
            Timestamp: timestamp
            Signature: signature
            HITId: @HITId
        })
        DisableHITResponseJSON = xml2json(response.content).DisableHITResponse
        @set('disableHITResponse', DisableHITResponseJSON)
        if DisableHITResponseJSON.DisableHITResult?.Request?.IsValid is 'True'
          document = Documents.findOne(@documentId)
          document.set('mTurkEnabled', false)
          document.save()
        @save()

    obtainSubmitUrl: (assignmentId) ->
      if Meteor.isServer and @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          console.log "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        if process.env.MTURK_WORKER_URL
          mturkWorkerUrl = process.env.MTURK_WORKER_URL
        else
          console.log "MTURK_URL is not defined, defaulting to the sandbox API."
          mturkWorkerUrl = "https://workersandbox.mturk.com"
        "#{mturkWorkerUrl}/mturk/externalSubmit?assignmentId=#{assignmentId}&t=#{(Date.now())}"


xml2json = (xml) ->
  xml2js.parseStringSync(xml, {
    explicitArray: false
  })
