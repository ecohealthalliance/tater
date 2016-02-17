describe 'MTurkJob', ->

  describe '#costInCents', ->
    it 'calculates the cost with a 25% margin', ->
      job = new MTurkJob(rewardAmount: 3, maxAssignments: 2)
      expect(job.costInCents()).to.eq(800)

  it 'submits a HIT to the mechanical turk website when saved', ->
    if process.env.AWS_ACCESS_KEY
      doc = new Document(
        title: "test doc"
        body: "test doc body"
      )
      doc.save()
      job = new MTurkJob(
        title: "Tater test"
        description: "tater"
        rewardAmount: 1
        documentId: doc._id
        HITLifetimeInSeconds: 120
        maxAssignments: 1
      )
      job.save()
      expect(job.createHITResponse.HIT.HITId).not.to.be.an('undefined')
    else
      console.log "Skipping MTurk test because AWS_ACCESS_KEY is not defined."

  it 'should append random string to end of descrption', ->
    job = new MTurkJob(
      description: "tater"
    )
    expect(job.descriptionWithHash()).not.to.eq(job.descriptionWithHash())
