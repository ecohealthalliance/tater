Template.codingKeywords.helpers
  codingKeywords: () ->
    CodingKeywords.find()
  subHeadings: () ->
    for subHeading, keywords of @subHeadings
      subHeading: subHeading
      keywords: keywords
