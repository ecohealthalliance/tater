describe 'Tenants attributes', ->
  tenant = null

  beforeEach ->
    tenant = new Tenant()

  it 'includes fullName', ->
    tenant.set('fullName', 'Full Name')
    tenant.save
    expect(tenant.fullName).to.eq('Full Name')

  it 'includes emailAddress', ->
    tenant.set('emailAddress', "test@example.com")
    tenant.save
    expect(tenant.emailAddress).to.eq("test@example.com")

  it 'includes orgName', ->
    tenant.set('orgName', "Test Organization Name")
    tenant.save
    expect(tenant.orgName).to.eq("Test Organization Name")

  it 'includes tenantName', ->
    tenant.set('tenantName', "Test Tenant Name")
    tenant.save
    expect(tenant.tenantName).to.eq("Test Tenant Name")

  it 'includes createdAt', ->
    tenant.save
    expect(tenant.createdAt).not.to.be.an('undefined')

  it 'includes updatedAt', ->
    tenant.save
    expect(tenant.updatedAt).not.to.be.an('undefined')
