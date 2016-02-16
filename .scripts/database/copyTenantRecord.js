var currentTenant = db;
db = db.getSiblingDB("www");
var tenant = db.tenants.findOne({'tenantName': currentTenant});

tenant.current = true;

db = db.getSiblingDB(currentTenant);
db.tenants.insert(tenant);
