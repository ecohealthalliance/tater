TenantHelpers = {}
tenant = null

# currently only available server side.  Update package.js if needed on client.
TenantHelpers.getCurrentTenant = () ->
  if !tenant?
    tenant = Tenants.findOne({current: true})
  tenant
