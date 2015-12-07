Meteor.methods
  createDefaultCodes: (headerLabel, subHeaderLabel, keywordLabel) ->
    if (Headers.find().count() == 0)
      headerId = Headers.insert(label: headerLabel or "Test Header", color: 1, admin: true)
      subHeaderId = SubHeaders.insert(headerId: headerId, label: subHeaderLabel or "Test Sub-Header")
      CodingKeywords.insert(subHeaderId: subHeaderId, label: keywordLabel or "Test Keyword")
    else
      throw new Meteor.Error("Already have codes in the database")
