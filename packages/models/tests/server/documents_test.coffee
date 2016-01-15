describe 'Document', ->
  document = null

  beforeEach ->
    document = new Document()

  it 'includes title', ->
    document.set('title', 'Document Title')
    document.save
    expect(document.title).to.eq('Document Title')

  it 'includes body', ->
    document.set('body', 'Body text here')
    document.save
    expect(document.body).to.eq('Body text here')

  it 'truncates body', ->
    document.set('body', """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse leo risus, blandit non sem in, tempus tempor ex. Curabitur a mauris at orci sagittis scelerisque. Morbi ligula sapien, viverra ac condimentum vitae, maximus in massa. Aenean convallis est non odio feugiat condimentum. Morbi sollicitudin sit amet quam ac venenatis. Aenean id facilisis nisl. Interdum et malesuada fames ac ante ipsum primis in faucibus. Cras eu sem condimentum, congue turpis viverra, dictum elit. Nullam ornare nisi leo, ac aliquet ante pretium et. Proin volutpat tortor eu est blandit, sit amet ultricies nisl vulputate. Nullam malesuada aliquet orci, id vehicula quam dictum a. Nulla quis mollis leo. Donec dapibus justo nec enim ultricies auctor. Duis fringilla velit ut ex tempus, nec lobortis tellus pretium. Sed sit amet ligula ac odio efficitur convallis sed at massa.""")
    truncatedBody = document.truncatedBody()
    expect(truncatedBody.split(' ')).length('25')

  it 'includes groupId', ->
    document.set('groupId', 'fakeid')
    document.save
    expect(document.groupId).to.eq('fakeid')

  it 'includes createdAt', ->
    document.save
    expect(document.createdAt).not.to.be.an('undefined')

  it 'includes updatedAt', ->
    document.save
    expect(document.updatedAt).not.to.be.an('undefined')

  describe '#textWithAnnotation', =>
    it 'returns the text with the given annotations represented with spans', ->
      headerId = Headers.insert(color: 2)
      subHeaderId = SubHeaders.insert(headerId: headerId)
      codeId = CodingKeywords.insert(subHeaderId: subHeaderId)
      annotation = new Annotation({startOffset: 0, endOffset: 1, codeId: codeId})
      annotation.save()

      document.set('body', "Test body")
      annotatedText = document.textWithAnnotation(annotation)
      expect(annotatedText).to.eq("<span data-annotation-id='#{annotation._id}' class='annotation-highlight annotation-highlight-2'>T</span>est body")

  describe '#groupName', =>
    it 'returns the name of the group to which the document belongs', ->
      group = new Group(name: 'Test Group Name')
      group.save()

      document.set('groupId', group._id)
      expect(document.groupName()).to.eq('Test Group Name')

  describe '#mTurkEnabled', =>
    it 'checks if a Mechanical Turk job has been created for the document', ->
      if process.env.AWS_ACCESS_KEY
        job = new MTurkJob(
          title: "Tater test"
          description: "tater"
          rewardUSD: 1
          docId: document._id
          HITLifetimeInSeconds: 120
          maxAssignments: 1
        )
        job.save()
        expect(document.mTurkEnabled()).to.be.ok()
      else
        console.log "Skipping MTurk test because AWS_ACCESS_KEY is not defined."
