describe 'CodingKeyword', ->
  codingKeyword = null

  beforeEach ->
    codingKeyword = new CodingKeyword()

  it 'includes header', ->
    codingKeyword.set('header', 'HEADER')
    codingKeyword.save()
    expect(codingKeyword.header).to.eq('HEADER')

  it 'includes subHeader', ->
    codingKeyword.set('subHeader', 'SUBHEADER')
    codingKeyword.save()
    expect(codingKeyword.subHeader).to.eq('SUBHEADER')

  it 'includes keyword', ->
    codingKeyword.set('keyword', 'KEYWORD')
    codingKeyword.save()
    expect(codingKeyword.keyword).to.eq('KEYWORD')
