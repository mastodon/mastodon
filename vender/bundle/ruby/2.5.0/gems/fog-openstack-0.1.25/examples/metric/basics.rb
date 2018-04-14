require 'fog/openstack'
require 'time'

auth_url = "http://10.0.0.13:5000/v3/auth/tokens"
username = 'admin'
password = 'njXDF8bKr68RQsfbANvURzkmT'
project  = 'admin'

@connection_params = {
    :openstack_auth_url     => auth_url,
    :openstack_username     => username,
    :openstack_api_key      => password,
    :openstack_project_name => project,
    :openstack_domain_id    => "default"
}

puts "### SERVICE CONNECTION ###"

metric = Fog::Metric::OpenStack.new(@connection_params)

p metric

puts "### RESOURCES ###"

p metric.list_resources

p metric.resources.all(details: true)

p metric.resources.find_by_id("3c6c53c9-25c1-4aca-984d-a20c1926b499")

p metric.get_resource_metric_measures("d1f84147-d4ef-465e-a679-265df36918ed", "disk.ephemeral.size", start: 0, stop: Time.now.iso8601, granularity: 300).body


puts "### METRICS ###"

p metric.metrics.all

p metric.metrics.find_by_id("7feff2ca-2edd-4ea5-96d7-2cc5262bb504")

p metric.get_metric_measures("d8e5e557-e3cc-41bd-9d87-dac3eedd0df7", start: 0, stop: Time.now.iso8601, granularity: 300).body

puts "### END ###"
