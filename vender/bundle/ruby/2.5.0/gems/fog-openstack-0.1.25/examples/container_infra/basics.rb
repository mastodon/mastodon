# OpenStack Container Infra (Magnum) Example
require 'fog/openstack'

# Initialize a connection to the Magnum API
params = {
  openstack_auth_url:     'https://example.net/v3/auth/tokens',
  openstack_username:     'username',
  openstack_api_key:      'password',
  openstack_project_name: 'magnum'
}

container_infra = Fog::ContainerInfra::OpenStack.new(params)

# Get the Fedora Atomic image
image = Fog::Image::OpenStack.new(params)

unless image.images.map(&:name).include?("fedora-atomic-latest")
  puts "Couldn't find Fedora Atomic. Uploading to Glance..."
  fedora = image.images.create name: "fedora-atomic-latest",
                               disk_format: "qcow2",
                               visibility: 'public',
                               container_format: 'bare',
                               copy_from: 'https://fedorapeople.org/groups/magnum/fedora-atomic-latest.qcow2',
                               properties: {'os_distro' => 'fedora-atomic'}.to_json
  fedora.wait_for { status == "active" }
end

# Create a cluster template for using Docker Swarm and Fedora Atomic
params = {
  name:                'swarm-cluster-template',
  image_id:            'fedora-atomic-latest',
  keypair_id:          'YOUR_KEYPAIR_NAME',
  external_network_id: 'public',
  master_flavor_id:    'm1.small',
  flavor_id:           'm1.small',
  coe:                 'swarm',
  docker_volume_size:  3,
  dns_nameserver:      '8.8.8.8',
  tls_disabled:        true
}

cluster_template = container_infra.cluster_templates.create(params)
puts "Created cluster template #{cluster_template.name} (#{cluster_template.uuid})"

# Create a swarm cluster and wait for it to build
params = {
  name:                'swarm-cluster',
  cluster_template_id: 'swarm-cluster-template',
  master_count:        1,
  node_count:          1
}

cluster = container_infra.clusters.create(params)
start = Time.now
puts "Building cluster #{cluster.name} (#{cluster.uuid})"

cluster.wait_for { status != 'CREATE_IN_PROGRESS' }

puts "Finished building #{cluster.name} in #{(Time.now - start).round} seconds. Status: #{cluster.status}."

puts "More info: #{cluster.status_reason}" if cluster.status == 'CREATE_FAILED'
