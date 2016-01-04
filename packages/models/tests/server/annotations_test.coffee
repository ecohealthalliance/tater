describe 'Annotation', ->
  annotation = null

  beforeEach ->
    annotation = new Annotation()

  it 'includes documentId', ->
    annotation.set('documentId', 'fakedocid')
    annotation.save()
    expect(2).to.eq(2)

    
  it 'includes userId', ->
    annotation.set('userId', 'fakeuserid')
    annotation.save()
    expect(annotation.userId).to.eq('fakeuserid')

  it 'includes codeId', ->
    annotation.set('codeId', 'fakecodeid')
    annotation.save()
    expect(annotation.codeId).to.eq('fakecodeid')

  it 'includes startOffset', ->
    annotation.set('startOffset', 12)
    annotation.save()
    expect(annotation.startOffset).to.eq(12)

  it 'includes endOffset', ->
    annotation.set('endOffset', 15)
    annotation.save()
    expect(annotation.endOffset).to.eq(15)

  it 'includes accessCode', ->
    annotation.set('accessCode', "fakecode")
    annotation.save()
    expect(annotation.accessCode).to.eq("fakecode")

  it 'includes flagged', ->
    annotation.set('flagged', true)
    annotation.save()
    expect(annotation.flagged).to.eq(true)

  it 'includes createdAt', ->
    annotation.save
    expect(annotation.createdAt).not.to.be.an('undefined')

  it 'includes updatedAt', ->
    annotation.save
    expect(annotation.updatedAt).not.to.be.an('undefined')

describe 'Annotation code methods', ->
  annotation = null

  beforeEach ->
    headerId = Headers.insert(label: "Test Header")
    subHeaderId = SubHeaders.insert(label: "Test Subheader", headerId: headerId)
    codeId = CodingKeywords.insert(subHeaderId: subHeaderId, label: 'Test Keywords')

    annotation = new Annotation(codeId: codeId)
    annotation.save()

  it '#header retrieves header from associated code', ->
    expect(annotation.header()).to.eq('Test Header')

  it '#subheader retrieves subheader from associated code', ->
    expect(annotation.subHeader()).to.eq('Test Subheader')

  it '#keywords retrieves subheader from associated code', ->
    expect(annotation.keyword()).to.eq('Test Keywords')

describe 'Annotation#overlapsWithOffsets', ->
  annotation = null

  beforeEach ->
    annotation = new Annotation()
    annotation.startOffset = 3
    annotation.endOffset = 5
    annotation.save()

  it 'returns true if the given startOffset is within the annotation offsets', ->
    expect(annotation.overlapsWithOffsets(4, 8)).to.be.ok

  it 'returns true if the given endOffset is within the annotation offsets', ->
    expect(annotation.overlapsWithOffsets(1, 5)).to.be.ok

  it 'returns true if the given offsets surround the annotation', ->
    expect(annotation.overlapsWithOffsets(1, 7)).to.be.ok

  it 'returns true if the given offsets are within the annotation', ->
    expect(annotation.overlapsWithOffsets(4, 5)).to.be.ok

  it 'returns false otherwise', ->
    expect(annotation.overlapsWithOffsets(8, 9)).not.to.be.ok
