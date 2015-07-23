describe 'Group', ->
  group = null

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

  describe '#editableByUserWithGroup', ->
    it 'returns true if user belongs to group', ->
      group.save
      id = group._id
      expect(group.editableByUserWithGroup(id)).to.be.ok

    it 'returns true if user is admin', ->
      expect(group.editableByUserWithGroup('admin')).to.be.ok

    it 'returns false otherwise', ->
      expect(group.editableByUserWithGroup('fake')).not.to.be.ok
