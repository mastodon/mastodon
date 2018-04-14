# OpenStack Planning Service (Tuskar) Example

require 'fog/openstack'
require 'pp'

auth_url = "https://example.net/v2.0/tokens"
username = 'admin@example.net'
password = 'secret'
tenant   = 'My Compute Tenant' # String

planning ||= ::Fog::Openstack.new(
  :service            => :planning,
  :openstack_api_key  => password,
  :openstack_username => username,
  :openstack_auth_url => auth_url,
  :openstack_tenant   => tenant
)

pp planning

#
# Listing of Tuskar roles
#
roles = planning.roles.each do |role|
  pp role
end

#
# Listing of Tuskar plans
#
plans = planning.plans.each do |plan|
  pp plan
end

#
# Creating new Tuskar plan
#
plan = planning.plans.new({
  :name        => 'New Plan Name',
  :description => 'New Plan Description'
})
pp plan

#
# Assign role to plan
#
role_uuid = roles.first.uuid
plan.add_role(role_uuid)

#
# Output Heat templates for plan
#
pp plan.templates
