describe 'Tenants attributes', ->
  tenant = null

  beforeEach ->
    tenant = new Tenant()

  it 'includes fullName', ->
    tenant.set('fullName', 'Full Name')
    tenant.save
    expect(tenant.fullName).to.eq('Full Name')

  it 'validates fullName', ->
    tenant.set('fullName', '')
    expect(tenant.save).throws()

  it 'includes emailAddress', ->
    tenant.set('emailAddress', 'test@example.com')
    tenant.save
    expect(tenant.emailAddress).to.eq('test@example.com')

  it 'validates emailAddress', ->
    tenant.set('emailAddress', 'testexamplecom')
    expect(tenant.save).throws()

  it 'includes orgName', ->
    tenant.set('orgName', 'Test Organization Name')
    tenant.save
    expect(tenant.orgName).to.eq('Test Organization Name')

  it 'includes tenantName', ->
    tenant.set('tenantName', 'test-tenant')
    tenant.save
    expect(tenant.tenantName).to.eq('test-tenant')

  it 'validates tenantName does not contain special characters', ->
    tenant.set('tenantName', '%test*Name@')
    expect(tenant.save).throws()

  it 'validates tenantName does not contain spaces', ->
    tenant.set('tenantName', 'test Name')
    expect(tenant.save).throws()

  it 'includes createdAt', ->
    tenant.save
    expect(tenant.createdAt).not.to.be.an('undefined')

  it 'includes updatedAt', ->
    tenant.save
    expect(tenant.updatedAt).not.to.be.an('undefined')
