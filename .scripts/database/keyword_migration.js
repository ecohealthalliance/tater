db.headers.drop()
db.subHeaders.drop()
db.keywords.drop()

db.createCollection('headers')
db.createCollection('subHeaders')
db.createCollection('keywords')

headers = db.codingKeywords.find({keyword: null, subHeader: null, caseCount: {$ne: true}})

//track the number of keywords associated with a header or subheader rather than a keyword
headerKeywords = 0;
subheaderKeywords = 0;

otherKeywordCount = 0;
otherSubHeaderCount = 0;

//track the original number of headers/subheaders/keywords so we can compare to post migration numbers
headerCount = headers.count();
subHeaderCount = db.codingKeywords.find({header: {$ne: null}, subHeader: {$ne: null}, keyword: null}).count();
keywordCount = db.codingKeywords.find({header: {$ne: null}, subHeader: {$ne: null}, keyword: {$ne: null}}).count();;

//Insert headers
while(headers.hasNext()){
  header = headers.next();
  db.headers.insert({label: header.header, color: header.color, _id: header._id});
  annotations = db.annotations.find({codeId: header._id, accessCode: null})
  //check to see if any annotations use this header
  if(annotations.count() > 0){
    headerKeywords += annotations.count();
    createOtherSubHeader(header);
  }

  //Insert subheaders
  subHeaders = db.codingKeywords.find({header: header.header, subHeader: {$ne: null}, keyword:null});
  while(subHeaders.hasNext()){
    subHeader = subHeaders.next();
    db.subHeaders.insert({label: subHeader.subHeader, headerId: header._id, _id: subHeader._id});
    annotations = db.annotations.find({codeId: subHeader._id, accessCode: null});
    //check to see if any annotations use this subHeader
    if(annotations.count() > 0){
      subheaderKeywords += annotations.count();
      createOtherKeyword(subHeader);
    }

    keywords = db.codingKeywords.find({header: header.header, subHeader: subHeader.subHeader, keyword: {$ne: null}});

    //Insert keywords
    while(keywords.hasNext()){
      keyword = keywords.next()
      //update this keyword to point back to it's subheader
      db.keywords.insert({_id: keyword._id, headerId: header._id, subHeaderId: subHeader._id, label: keyword.keyword})
    }
  }
}

function createOtherSubHeader(header){
  //Create the new "Other" subHeader and then call function to create "Other" keyword
  otherSubHeaderCount++;
  db.subHeaders.insert({_id: createMeteorId(), label: "Other", headerId: header._id});
  newSubHeader = db.subHeaders.findOne({label: "Other", headerId: header._id});
  createOtherKeyword(newSubHeader, header);
}

function createOtherKeyword(subHeader, header){
  otherKeywordCount++;
  keywordId = createMeteorId();
  db.keywords.insert({_id: keywordId, label: "Other", subHeaderId: subHeader._id});
  //newKeyword = db.keywords.find({label: "Other", subHeaderId: subHeader._id});
  //If a header was passed in, update all annotations that use that header.
  //If no header was passed in, then update all annotations that use the subheader
  updateId = header == null ? subHeader._id : header._id
  db.annotations.update({codeId: updateId, accessCode: null},
    {
      $set:
      {
        codeId: keywordId
      }
  });
}

function createMeteorId(){
  var charset = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";
  var text = "";
  for( var i=0; i < 17; i++ )
      text += charset.charAt(Math.floor(Math.random() * charset.length));
  return text;
}

print("'Other' subHeaders created: " + otherSubHeaderCount);
print("'Other' keywords created: " + otherKeywordCount);

print("Headers before migration: " + headerCount + "*** Headers after migration: " + db.headers.count());
print("subHeaders before migration: " + subHeaderCount + "*** Headers after migration: " + db.subHeaders.count());
print("keywords before migration: " + keywordCount + "*** Headers after migration: " + db.keywords.count());

// print("header keywords: " + headerKeywords)
// print("subHeader keywords: " + subheaderKeywords)
