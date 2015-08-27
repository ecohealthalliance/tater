describe 'Group', ->
  group = null
  Meteor.users.remove()

  beforeEach ->
    group = new Group()

  it 'includes name', ->
    group.set('name', 'Group Name')
    group.save
    expect(group.name).to.eq('Group Name')

  it 'includes description', ->
    group.set('description', 'Description')
    group.save
    expect(group.description).to.eq('Description')

  it 'truncates description', ->
    group.set('description', """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse leo risus, blandit non sem in, tempus tempor ex. Curabitur a mauris at orci sagittis scelerisque. Morbi ligula sapien, viverra ac condimentum vitae, maximus in massa. Aenean convallis est non odio feugiat condimentum. Morbi sollicitudin sit amet quam ac venenatis. Aenean id facilisis nisl. Interdum et malesuada fames ac ante ipsum primis in faucibus. Cras eu sem condimentum, congue turpis viverra, dictum elit. Nullam ornare nisi leo, ac aliquet ante pretium et. Proin volutpat tortor eu est blandit, sit amet ultricies nisl vulputate. Nullam malesuada aliquet orci, id vehicula quam dictum a. Nulla quis mollis leo. Donec dapibus justo nec enim ultricies auctor. Duis fringilla velit ut ex tempus, nec lobortis tellus pretium. Sed sit amet ligula ac odio efficitur convallis sed at massa.""")
    truncatedDescription = group.truncateDescription()
    expect(truncatedDescription.split(' ')).length('50')

  it 'includes createdById', ->
    group.set('createdById', 'fakeid')
    group.save
    expect(group.createdById).to.eq('fakeid')

  it 'includes codeAccessible', ->
    group.set('codeAccessible', true)
    group.save
    expect(group.codeAccessible).to.eq(true)

  describe '#viewableByUser', ->
    it 'returns true if user belongs to group', ->
      group.save()
      userId = Meteor.users.insert(email: 'test@example.com', group: group._id)
      user = Meteor.users.findOne(userId)
      expect(group.viewableByUser(user)).to.be.ok

    it 'returns true if user is admin', ->
      userId = Meteor.users.insert(email: 'test@example.com', admin: true)
      user = Meteor.users.findOne(userId)
      expect(group.viewableByUser(user)).to.be.ok

    it 'returns false otherwise', ->
      group.save()
      userId = Meteor.users.insert(email: 'test@example.com')
      user = Meteor.users.findOne(userId)
      expect(group.viewableByUser(user)).not.to.be.ok

  describe '#documents', ->
    it 'returns the documents that have been added to the group', ->
      id = group.save
      expect(group.documents().count()).to.eq(0)
      document = new Document({groupId: id})
      document.save ->
        expect(group.documents().count()).to.eq(1)
