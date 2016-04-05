// Resets the local MTurk database.
// Being triggered by ./restore_database
// in order to wipe the data after restore.
// Usage Example:
// mongo localhost:3001/meteor resetMturk.js

db.mturkJobs.remove({})
print("MTurk jobs flushed.");
