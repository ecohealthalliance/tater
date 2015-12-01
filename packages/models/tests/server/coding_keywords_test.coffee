describe 'CodingKeyword', ->
  codingKeyword = null

  beforeEach ->
    codingKeyword = new CodingKeyword()

  describe '#subHeaderLabel', ->
    it 'returns the label of the associated subHeader', ->
      subHeaderId = SubHeaders.insert(label: "Test SubHeader")

      codingKeyword.set('subHeaderId', subHeaderId)
      codingKeyword.save()
      expect(codingKeyword.subHeaderLabel()).to.eq('Test SubHeader')

  describe '#headerLabel', ->
    it 'returns the label of the associated header', ->
      headerId = Headers.insert(label: "Test Header")
      subHeaderId = SubHeaders.insert(headerId: headerId)

      codingKeyword.set('subHeaderId', subHeaderId)
      expect(codingKeyword.headerLabel()).to.eq('Test Header')

  describe '#color', ->
    it 'returns the color of the associated header', ->
      headerId = Headers.insert(color: 2)
      subHeaderId = SubHeaders.insert(headerId: headerId)

      codingKeyword.set('subHeaderId', subHeaderId)
      expect(codingKeyword.color()).to.eq(2)
