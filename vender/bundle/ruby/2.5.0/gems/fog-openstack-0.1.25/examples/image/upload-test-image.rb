require 'securerandom'
require 'rubygems/package'
require 'zlib'
require 'fog/openstack'

#
# Download CirrOS 0.3.0 image from launchpad (~6.5MB) to /tmp
# and upload it to Glance (the OpenStack Image Service).
#
# You will need to source OpenStack credentials since the script
# reads the following envionment variables:
#
#  OS_PASSWORD
#  OS_USERNAME
#  OS_AUTH_URL
#  OS_TENANT_NAME
#
# Should work with Fog >= 1.9, ruby 1.8.7 and 2.0
#
image_url = "https://launchpadlibrarian.net/83305869/cirros-0.3.0-x86_64-uec.tar.gz"
image_out = File.open("/tmp/cirros-image-#{SecureRandom.hex}", 'wb')
extract_path = "/tmp/cirros-#{SecureRandom.hex}-dir"
ami = "#{extract_path}/cirros-0.3.0-x86_64-blank.img"
aki = "#{extract_path}/cirros-0.3.0-x86_64-vmlinuz"
ari = "#{extract_path}/cirros-0.3.0-x86_64-initrd"

FileUtils.mkdir_p extract_path

# Efficient image write
puts "Downloading Cirros image..."
streamer = lambda do |chunk, remaining_bytes, total_bytes|
  image_out.write chunk
end
Excon.get image_url, :response_block => streamer
image_out.close
puts "Image downloaded to #{image_out.path}"

puts "Extracting image contents to #{extract_path}..."
Gem::Package::TarReader.new(Zlib::GzipReader.open(image_out.path)).each do |entry|
  FileUtils.mkdir_p "#{extract_path}/#{File.dirname(entry.full_name)}"
  File.open "#{extract_path}/#{entry.full_name}", 'w' do |f|
    f.write entry.read
  end
end

image_service = Fog::Image::OpenStack.new :openstack_api_key => ENV['OS_PASSWORD'],
                                          :openstack_username => ENV["OS_USERNAME"],
                                          :openstack_auth_url => ENV["OS_AUTH_URL"] + "/tokens",
                                          :openstack_tenant => ENV["OS_TENANT_NAME"]

puts "Uploading AKI..."
aki = image_service.images.create :name => 'cirros-0.3.0-amd64-aki',
                                  :size => File.size(aki),
                                  :disk_format => 'aki',
                                  :container_format => 'aki',
                                  :location => aki

puts "Uploading ARI..."
ari = image_service.images.create :name => 'cirros-0.3.0-amd64-ari',
                                  :size => File.size(ari),
                                  :disk_format => 'ari',
                                  :container_format => 'ari',
                                  :location => ari

puts "Uploading AMI..."
image_service.images.create :name => 'cirros-0.3.0-amd64',
                            :size => File.size(ami),
                            :disk_format => 'ami',
                            :container_format => 'ami',
                            :location => ami,
                            :properties => {
                              'kernel_id'  => aki.id,
                              'ramdisk_id' => ari.id
                            }
