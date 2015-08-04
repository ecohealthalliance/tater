describe 'Annotation', ->
  annotation = null

  beforeEach ->
    annotation = new Annotation()

  it 'includes documentId', ->
    annotation.set('documentId', 'fakedocid')
    annotation.save
    expect(annotation.documentId).to.eq('fakedocid')

  it 'includes userId', ->
    annotation.set('userId', 'fakeuserid')
    annotation.save
    expect(annotation.userId).to.eq('fakeuserid')

  it 'includes keyword', ->
    annotation.set('keyword', 'Annotation keyword')
    annotation.save
    expect(annotation.keyword).to.eq('Annotation keyword')

  it 'includes startIndex', ->
    annotation.set('startIndex', 12)
    annotation.save
    expect(annotation.startIndex).to.eq(12)

  it 'includes endIndex', ->
    annotation.set('endIndex', 15)
    annotation.save
    expect(annotation.endIndex).to.eq(15)
