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

  describe '#textWithAnnotations', =>
    it 'returns the text with the given annotations represented with spans', ->
      code = CodingKeywords.findOne()
      code.color = 1
      annotation1 = new Annotation({startOffset: 0, endOffset: 1, codeId: code._id})
      annotation1.save()
      annotation2 = new Annotation({startOffset: 3, endOffset: 6, codeId: code._id})
      annotation2.save()

      document.set('body', "Test body")
      annotatedText = document.textWithAnnotations([annotation1, annotation2])
      expect(annotatedText).to.eq("<span data-annotation-id='#{annotation1._id}' class='annotation-highlight-1'>T</span>es<span data-annotation-id='#{annotation2._id}' class='annotation-highlight-1'>t b</span>ody")
