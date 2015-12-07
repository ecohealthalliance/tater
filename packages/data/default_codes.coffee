Meteor.methods
  createDefaultCodes: (headerLabel, subHeaderLabel, keywordLabel) ->
    if Headers.find().count() == 0
      headerId = Headers.insert
        label: headerLabel or "Header"
        color: 1
      subHeaderId = SubHeaders.insert
        headerId: headerId
        label: subHeaderLabel or "Sub-Header"
      CodingKeywords.insert
        subHeaderId: subHeaderId
        label: keywordLabel or "Keyword"
    else
      throw new Meteor.Error("Already have codes in the database")
