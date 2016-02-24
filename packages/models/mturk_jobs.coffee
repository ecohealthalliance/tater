if Meteor.isServer
  ### Shared constants ###
  if process.env.ROOT_URL.match("localhost")
    rootUrl = "https://staging.tater.io"
  else
    rootUrl = process.env.ROOT_URL
  # Note: rootUrl cannot be localhost or calls to mturk will fail
  if process.env.MTURK_URL
    mturkUrl = process.env.MTURK_URL
  else
    console.log "MTURK_URL is not defined, defaulting to the sandbox API"
    mturkUrl = "https://mechanicalturk.sandbox.amazonaws.com"
  if process.env.MTURK_WORKER_URL
    mturkWorkerUrl = process.env.MTURK_WORKER_URL
  else
    console.log "MTURK_WORKER_URL is not defined, defaulting to the sandbox API"
    mturkWorkerUrl = "https://workersandbox.mturk.com"
  service = "AWSMechanicalTurkRequester"

  ### Common functions ###
  xml2json = (xml) -> xml2js.parseStringSync(xml, explicitArray: false)
  sign = (service, operation, timestamp) ->
    CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA1(
      service + operation + timestamp,
      Meteor.settings.private.AWS_SECRET_KEY
    ))

MTurkJobs = new Mongo.Collection('mturkJobs')
MTurkJob = Astro.Class
  name: 'MTurkJob'
  collection: MTurkJobs
  fields:
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
      default: "Highlight spans of text and assign coding keywords to them."
      validator: [
        Validators.required()
        Validators.maxLength(2000, 'Mechanical Turk does not allow descriptions longer than 2000 characters.')
      ]
    userId:
      type: 'string'
      validator: [
        Validators.required()
        Validators.minLength(17, 'The userId can only be 17 characters long.')
        Validators.maxLength(17, 'The userId can only be 17 characters long.')
      ]
    documentId: 'string'
    HITId: 'string'
    rewardAmount:
      type: 'number'
      default: 1
      validator: [
        Validators.required()
        Validators.lt(30, 'Rewards greater than 30 USD are not supported as a precaution.')
      ]
    HITLifetimeInSeconds:
      type: 'number'
      default: 30 * 24 * 60 * 60 # 30 days
      validator: [
        Validators.gte(30, 'HIT lifetime must be equal to at least 30 seconds.')
        Validators.lte(31536000, 'HIT lifetime cannot exceed 31536000 seconds.')
      ]
    maxAssignments:
      type: 'number'
      default: 1
      validator: [
        Validators.lte(100, 'Max assignments is limited to 100 as a precaution.')
      ]
    createHITResponse: 'object'
    chargeDetails: 'object'
    completionTimestamp: 'date'
    workerId: 'string'
    paymentFailed: 'boolean'
  behaviors: ['timestamp']

  events:
    afterSave: ->
      if Meteor.isServer and not @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          console.log "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        # Parameters documented here:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_CreateHITOperation.html
        operation = "CreateHIT"
        timestamp = new Date().toISOString()
        signature = sign(service, operation, timestamp)
        response = HTTP.post(mturkUrl, {
          params:
            Service: service
            AWSAccessKeyId: Meteor.settings.private.AWS_ACCESS_KEY
            Version: "2014-08-15"
            Operation: operation
            Timestamp: timestamp
            Signature: signature
            Title: @title
            Description: @descriptionWithHash()
            Question: """
            <ExternalQuestion xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd">
              <ExternalURL>#{Meteor.absoluteUrl("documents", {
                secure: true
                rootUrl: rootUrl
              })}/#{@documentId}?noHeader=1</ExternalURL>
              <FrameHeight>600</FrameHeight>
            </ExternalQuestion>
            """
            "Reward.1.Amount": @rewardAmount
            "Reward.1.CurrencyCode": "USD"
            AssignmentDurationInSeconds: 6000
            LifetimeInSeconds: @HITLifetimeInSeconds
            MaxAssignments: @maxAssignments
            Keywords: "annotation, highlighting, QDA, tater"
            # Leaving this at 0 for instant approval until we add some review
            # features to the application.
            AutoApprovalDelayInSeconds: 0
        })
        responseJSON = xml2js.parseStringSync(response.content, {
          explicitArray: false
        }).CreateHITResponse
        @set('createHITResponse', responseJSON)
        if responseJSON.HIT?.HITId
          @set('HITId', responseJSON.HIT.HITId)
          document = Documents.findOne(@documentId)
          document.set('mTurkEnabled', true)
          document.save()
        @save()

  methods:
    inProgress: ->
      if Meteor.isServer and @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          throw new Meteor.Error "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
        # API reference:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_GetHITOperation.html
        operation = "GetHIT"
        timestamp = new Date().toISOString()
        signature = sign(service, operation, timestamp)
        response = HTTP.post(mturkUrl, {
          params:
            Service: service
            AWSAccessKeyId: Meteor.settings.private.AWS_ACCESS_KEY
            Version: "2014-08-15"
            Operation: operation
            Signature: signature
            Timestamp: timestamp
            HITId: @HITId
        })
        GetHITResponseJSON = xml2json(response.content).GetHITResponse
        GetHITResponseJSON.HIT.HITStatus is 'Unassignable'

    descriptionWithHash: ->
      @description + " " +  Random.id()

    costInCents: ->
      # 25% margin - so the user is charged 1.33333 times the cost
      mechanicalTurkPrice = @rewardAmount * @maxAssignments
      Math.round(mechanicalTurkPrice * 100 * 1.333333)

    cancel: ->
      if Meteor.isServer and @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          throw new Meteor.Error "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
        if @inProgress()
          throw new Meteor.Error "This HIT has active worker sessions."
        # Parameters documented here:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_DisableHITOperation.html
        operation = "DisableHIT"
        timestamp = new Date().toISOString()
        signature = sign(service, operation, timestamp)
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
        responseRequest = DisableHITResponseJSON.DisableHITResult?.Request
        # Note: the cancel operation should be considered successful if we got both 'True' and "HITDoesNotExist" responses.
        if responseRequest?.IsValid is 'True'
          ok = true
        else if responseRequest?.Errors?.Error?.Code is 'AWS.MechanicalTurk.HITDoesNotExist'
          ok = true
        otherMturkJobsForThisDocument = MTurkJobs.findOne(documentId: @documentId, _id: {$ne: @_id})
        if ok and not otherMturkJobsForThisDocument
          document = Documents.findOne(@documentId)
          document.set('mTurkEnabled', false)
          document.save()
        @save()
        ok

    obtainSubmitUrl: (assignmentId) ->
      if Meteor.isServer and @createHITResponse
        unless Meteor.settings.private.AWS_ACCESS_KEY
          console.log "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        "#{mturkWorkerUrl}/mturk/externalSubmit?assignmentId=#{assignmentId}&t=#{Date.now()}"
