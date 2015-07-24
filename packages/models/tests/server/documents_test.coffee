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

  it 'includes groupId', ->
    document.set('groupId', 'fakeid')
    document.save
    expect(document.groupId).to.eq('fakeid')
