// Removes all documents and annotations in the test group
// Usage Example:
// mongo localhost:3001/meteor removeTestGroup.js
var testGroupId = db.groups.findOne({
  name: "TEST GROUP"
})._id;
print("Test Group id: " + testGroupId);
db.documents.remove({
  groupId: testGroupId
});
print("Test Group documents removed.");
db.groups.remove({_id: testGroupId});
print("Test Group removed.");
// Remove annotations where the documentId corresponds to a document that
// doesn't exist.
db.annotations.find().forEach(function(annotation){
  if(!db.documents.findOne({_id: annotation.documentId})) {
    db.annotations.remove({_id: annotation._id});
  }
});
print("Annotations without documents removed.");
