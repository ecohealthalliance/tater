// Add header ids to code keywords that have a sub-header id but no header id.
// Usage Example:
// mongo localhost:3001/meteor addHeaderIds.js
var keywordsUpdated = 0;
db.keywords.find({
    headerId: null,
    subHeaderId: { $ne: null }
}).forEach(function(keyword){
    var headerId = db.subHeaders.findOne({_id: keyword.subHeaderId}).headerId;
    db.keywords.update({_id: keyword._id}, {
        $set: { headerId: headerId }
    });
    keywordsUpdated++;
});
print("Updated " + keywordsUpdated + " keywords");
