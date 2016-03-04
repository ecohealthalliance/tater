// Recalculate popularity of keywords
// Usage Example:
// mongo localhost:3001/meteor updateKeywordUsage.js
db.keywords.find().forEach(function(keyword){
  var popularity = db.annotations.find({codeId: keyword._id}).count()
  db.keywords.update({_id: keyword._id}, {$set: {used: popularity}});
});
print("Annotation' usage has just been recalculated.");
