describe 'MTurkJob', ->

  it 'submits a HIT to the mechanical turk website when saved', ->
    unless process.env.AWS_ACCESS_KEY
      console.log "Skipping MTurk test because AWS_ACCESS_KEY is not defined."
    doc = new Document(
      title: "test doc"
      body: "test doc body"
    )
    doc.save()
    job = new MTurkJob(
      title: "Tater test"
      description: "tater"
      rewardUSD: 1
      docId: doc._id
      HITLifetimeInSeconds: 120
      maxAssignments: 1
    )
    job.save()
    expect(job.createHITResponse.HIT.HITId).not.to.be.an('undefined')
