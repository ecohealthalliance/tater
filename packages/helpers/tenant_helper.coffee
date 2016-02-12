TenantHelpers = {}
tenant = null

TenantHelpers.getCurrentTenant = () ->
  if !tenant?
    tenant = Tenants.findOne({current: true})
  tenant