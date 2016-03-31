describe 'CodingKeyword', ->
  codingKeyword = null

  beforeEach ->
    codingKeyword = new CodingKeyword()
    Annotations.remove({})

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

  describe '#archive', ->
    it 'removes the coding keyword if there are no annotations', ->
      codingKeyword.archive()
      expect(codingKeyword._id).not.to.be.ok

    it 'archives the coding keyword if there are annotations', ->
      Annotations.insert {codeId: codingKeyword._id}
      codingKeyword.archive()
      expect(codingKeyword.archived).to.be.ok

  describe '#unarchive', ->
    it 'unarchives the coding keyword', ->
      Annotations.insert {codeId: codingKeyword._id}
      codingKeyword.unarchive()
      expect(codingKeyword.archived).not.to.be.ok

  describe '#used', ->
    it 'returns undefined if the coding keyword has not been used in annotation', ->
      expect(codingKeyword.used()).to.be.an('undefined')

    it 'checks if a coding keyword has been used in annotation', ->
      annotation = new Annotation({codeId: codingKeyword._id})
      annotation.save()
      expect(codingKeyword.used()).not.to.be.an('undefined')

  describe '#documents', ->
    it 'returns empty collection if no documents are found with annotations using coding keyword', ->
      documentId = Documents.insert({title: 'Test'})
      documentCount = codingKeyword.documents().count()
      expect(documentCount).to.be.eq(0)

    it 'returns the documents that use a coding keyword', ->
      documentId = Documents.insert({title: 'Test'})
      annotation = new Annotation({documentId:documentId, codeId: codingKeyword._id})
      annotation.save()
      documentCount = codingKeyword.documents().count()
      expect(documentCount).to.be.eq(1)
