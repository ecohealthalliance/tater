describe 'UserProfile attributes', ->
  profile = null

  beforeEach ->
    profile = new UserProfile()

  it 'includes firstName', ->
    profile.set('firstName', 'First Name')
    profile.save
    expect(profile.firstName).to.eq('First Name')

  it 'includes middleName', ->
    profile.set('middleName', 'Middle Name')
    profile.save
    expect(profile.middleName).to.eq('Middle Name')

  it 'includes lastName', ->
    profile.set('lastName', 'Last Name')
    profile.save
    expect(profile.lastName).to.eq('Last Name')

  it 'includes jobTitle', ->
    profile.set('jobTitle', 'Job Title Here')
    profile.save
    expect(profile.jobTitle).to.eq('Job Title Here')

  it 'includes bio', ->
    profile.set('bio', 'This is my bio')
    profile.save
    expect(profile.bio).to.eq('This is my bio')

  it 'includes emailHidden', ->
    profile.set('emailHidden', true)
    profile.save
    expect(profile.emailHidden).to.eq(true)

  it 'includes userId', ->
    profile.set('userId', "someMongoId")
    profile.save
    expect(profile.userId).to.eq("someMongoId")

  it 'includes emailAddress', ->
    profile.set('emailAddress', "test@example.com")
    profile.save
    expect(profile.emailAddress).to.eq("test@example.com")

  it 'includes phoneNumber', ->
    profile.set('phoneNumber', "+1 (800) 555-1234")
    profile.save
    expect(profile.phoneNumber).to.eq("+1 (800) 555-1234")

  it 'includes createdAt', ->
    profile.save
    expect(profile.createdAt).not.to.be.an('undefined')

  it 'includes updatedAt', ->
    profile.save
    expect(profile.updatedAt).not.to.be.an('undefined')

  it 'includes address1', ->
    profile.set('address1', "1234 Test St.")
    profile.save
    expect(profile.address1).to.eq("1234 Test St.")

  it 'includes address2', ->
    profile.set('address2', "Apt 1B")
    profile.save
    expect(profile.address2).to.eq("Apt 1B")

  it 'includes city', ->
    profile.set('city', "Paper Town")
    profile.save
    expect(profile.city).to.eq("Paper Town")

  it 'includes zip', ->
    profile.set('zip', "00000")
    profile.save
    expect(profile.zip).to.eq("00000")

  it 'includes country', ->
    profile.set('country', "Computerland")
    profile.save
    expect(profile.country).to.eq("Computerland")

describe 'UserProfile#update', ->
  profile = null

  beforeEach ->
    profile = new UserProfile()
    profile.set(bio: "First bio", userId: 'testUserId')
    profile.save

  it 'updates fields on the profile', ->
    profile.update(bio: "Second bio")
    expect(profile.bio).to.eq("Second bio")

  it 'does not update fields that are not on the profile', ->
    profile.update(somethingElse: "Fake information")
    expect(profile.somethingElse).to.not.be.ok

  it 'does not update userId', ->
    profile.update(userId: "securityRisk")
    expect(profile.userId).to.eq('testUserId')
