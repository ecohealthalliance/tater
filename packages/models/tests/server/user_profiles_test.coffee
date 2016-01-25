describe 'UserProfile attributes', ->
  profile = null

  beforeEach ->
    profile = new UserProfile()

  it 'includes fullName', ->
    profile.set('fullName', 'Full Name')
    profile.save
    expect(profile.fullName).to.eq('Full Name')

  it 'includes jobTitle', ->
    profile.set('jobTitle', 'Job Title Here')
    profile.save
    expect(profile.jobTitle).to.eq('Job Title Here')

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
    profile.set(fullName: "Initial Name", userId: 'testUserId')
    profile.save

  it 'updates fields on the profile', ->
    profile.update(fullName: "Changed Name")
    expect(profile.fullName).to.eq("Changed Name")

  it 'does not update fields that are not on the profile', ->
    profile.update(somethingElse: "Fake information")
    expect(profile.somethingElse).to.not.be.ok

  it 'does not update userId', ->
    profile.update(userId: "securityRisk")
    expect(profile.userId).to.eq('testUserId')
