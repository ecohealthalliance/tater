Meteor.startup ->
  if process.env.ALLOW_TOKEN_ACCESS is 'true'
    if not Groups.findOne(name: "BSVE")
      group = new Group(
        name: "BSVE"
      )
      group.save()
    if CodingKeywords.find().count() == 0
      headerId = Headers.insert
        label: "Disease"
        color: 1
      subHeaderId = SubHeaders.insert
        headerId: headerId
        label: "Fever"
      CodingKeywords.insert
        subHeaderId: subHeaderId
        label: "Ebola Hemorrhagic Fever"
      CodingKeywords.insert
        subHeaderId: subHeaderId
        label: "Dengue Fever"
