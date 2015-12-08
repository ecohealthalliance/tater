QueryHelpers = {}
# Construct a Documents query that will only returns documents the given user
# has access to.
QueryHelpers.userDocsQuery = (user, options)->
  if user?.admin
    groups = Groups.find()
    groupIds = _.pluck(groups.fetch(), '_id')
    { groupId: {$in: groupIds} }
  else
    { groupId: user.group }
# Add a documentId: { $in: ... } clause to the given query object
# that limits the query to only the documents the users has access to.
QueryHelpers.limitQueryToUserDocs = (query, user)->
  documents = Documents.find(QueryHelpers.userDocsQuery(user))
  docIds = documents.map((d)-> d._id)
  if query.documentId
    if _.isString query.documentId
      userDocIds = [query.documentId]
    else if query.documentId.$in
      userDocIds = query.documentId.$in
    else
      throw Meteor.Error("Query is not supported")
    if _.difference(userDocIds, docIds).length > 0
      throw Meteor.Error("Invalid docIds")
  else
    query.documentId = {$in: docIds}
  query
