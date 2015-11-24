// Updates the annotated property of all the documents
// with the total number of corresponding annotations.
// Usage Example:
// mongo localhost:3001/meteor updateCounts.js
var annoSums = db.annotations.aggregate({
    $group: {
        _id: "$documentId",
        total: { $sum: 1 }
    }
}).toArray();
print("Updating " + annoSums.length + " documents.");
annoSums.forEach(function(annoSum){
    db.documents.update({ _id: annoSum._id }, {
        $set: { annotated: annoSum.total }
    });
});
print("Document annotation counts updated.");