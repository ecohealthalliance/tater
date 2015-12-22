// Remove annotations and documents that are not part of any groups
groupIds = db.groups.find({}, {_id: 1}).map(function(group) { return group._id })
grouplessDocumentIds = db.documents.find({groupId: {$nin: groupIds}}, {_id: 1}).map(function(document){ return document._id })
db.annotations.remove({documentId: {$in: grouplessDocumentIds}})
db.documents.remove({_id: {$in: grouplessDocumentIds}})

// Remove annotations that are not associated with keywords
codeIds = db.keywords.find({}, {_id: 1}).map(function(code){return code._id})
db.annotations.remove({codeId: {$nin: codeIds}})
