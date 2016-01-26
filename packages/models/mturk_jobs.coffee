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
      default: """
      Highlight spans of text and assign coding keywords to them.
      """
      validator: [
        Validators.required()
        Validators.maxLength(2000, 'Mechanical Turk does not allow descriptions longer than 2000 characters.')
      ]
    docId: 'string'
    rewardUSD:
      type: 'number'
      validator: [
        Validators.required()
        Validators.lt(30, 'Rewards greater than 30 USD are not supported as a precaution.')
      ]
    HITLifetimeInSeconds:
      type: 'number'
      default: 30 * 24 * 60 * 60 # 30 days
      validator: [
        Validators.gte(30, 'HIT lifetime must be greater than 30 seconds.')
        Validators.lte(31536000, 'HIT lifetime cannot exceed 31536000 seconds.')
      ]
    maxAssignments:
      type: 'number'
      default: 1
      validator: [
        Validators.lte(100, 'Max assignments is limited to 100 as a precaution.')
      ]
    createHITResponse: 'object'
  behaviors: ['timestamp']
  events:
    afterSave: () ->
      if Meteor.isServer and not @createHITResponse
        doc = Documents.findOne(@docId)
        doc.set('mTurkEnabled', true)
        doc.save()

        unless process.env.AWS_ACCESS_KEY
          console.warn "AWS_ACCESS_KEY is not defined, cannot call mechanical turk API."
          return
        # Parameters documented here:
        # http://docs.aws.amazon.com/AWSMechTurk/latest/AWSMturkAPI/ApiReference_CreateHITOperation.html
        service = "AWSMechanicalTurkRequester"
        operation = "CreateHIT"
        timestamp = (new Date()).toISOString()
        signature = CryptoJS.enc.Base64.stringify(CryptoJS.HmacSHA1(
          service + operation + timestamp,
          process.env.AWS_SECRET_KEY
        ))
        # rootUrl cannot be localhost or calls to mturk will fail.
        if process.env.ROOT_URL.match("localhost")
          rootUrl = "https://staging.tater.io"
        else
          rootUrl = process.env.ROOT_URL
        if process.env.MTURK_URL
          mturkUrl = process.env.MTURK_URL
        else
          console.warn "MTURK_URL is not defined, defaulting to the sandbox API."
          mturkUrl = "https://mechanicalturk.sandbox.amazonaws.com"
        response = HTTP.post(mturkUrl, {
          params:
            Service: service
            Operation: operation
            Timestamp: timestamp
            Signature: signature
            AWSAccessKeyId: process.env.AWS_ACCESS_KEY
            Version: "2014-08-15"
            Title: @title
            Description: @description
            Question: """
            <ExternalQuestion xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd">
              <ExternalURL>#{Meteor.absoluteUrl("mtAnnotate", {
                secure: true
                rootUrl: rootUrl
              })}/#{@docId}?accessToken=#{@doc.accessCode}</ExternalURL>
              <FrameHeight>600</FrameHeight>
            </ExternalQuestion>
            """
            "Reward.1.Amount": @rewardUSD
            "Reward.1.CurrencyCode": "USD"
            AssignmentDurationInSeconds: 6000
            LifetimeInSeconds: @HITLifetimeInSeconds
            MaxAssignments: @maxAssignments
            Keywords: "annotation, highlighting, QDA, tater"
            # Leaving this at 0 for instant approval until we add some review
            # features to the application.
            AutoApprovalDelayInSeconds: 0
        })
        @set('createHITResponse', xml2js.parseStringSync(response.content, {
          explicitArray: false
        }).CreateHITResponse)
        @save()
