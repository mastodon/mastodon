module Fog
  module Errors
    class Error < StandardError
      attr_accessor :verbose

      def self.slurp(error, message = nil)
        new_error = new(message || error.message)
        new_error.set_backtrace(error.backtrace)
        new_error.verbose = error.message
        new_error
      end
    end

    class MockNotImplemented < Fog::Errors::Error; end

    class NotFound < Fog::Errors::Error; end

    class LoadError < Fog::Errors::Error; end

    class TimeoutError < Fog::Errors::Error; end

    class NotImplemented < Fog::Errors::Error; end

    # @return [String] The error message that will be raised, if credentials cannot be found
    def self.missing_credentials
      missing_credentials_message = <<-YML
Missing Credentials

To run as '#{Fog.credential}', add the following to your resource config file: #{Fog.credentials_path}
An alternate file may be used by placing its path in the FOG_RC environment variable

#######################################################
# Fog Credentials File
#
# Key-value pairs should look like:
# :aws_access_key_id:                 022QF06E7MXBSAMPLE
:#{Fog.credential}:
  :aws_access_key_id:
  :aws_secret_access_key:
  :bluebox_api_key:
  :bluebox_customer_id:
  :brightbox_client_id:
  :brightbox_secret:
  :clodo_api_key:
  :clodo_username:
  :digitalocean_api_key:
  :digitalocean_client_id:
  :go_grid_api_key:
  :go_grid_shared_secret:
  :google_client_email:
  :google_key_location:
  :google_project:
  :google_storage_access_key_id:
  :google_storage_secret_access_key:
  :hp_access_key:
  :hp_secret_key:
  :hp_tenant_id:
  :hp_avl_zone:
  :linode_api_key:
  :local_root:
  :bare_metal_cloud_password:
  :bare_metal_cloud_username:
  :public_key_path:
  :private_key_path:
  :openstack_api_key:
  :openstack_username:
  :openstack_auth_url:
  :openstack_tenant:
  :openstack_region:
  :ovirt_username:
  :ovirt_password:
  :ovirt_url:
  :libvirt_uri:
  :rackspace_api_key:
  :rackspace_username:
  :rackspace_servicenet:
  :rackspace_cdn_ssl:
  :rage4_email:
  :rage4_password:
  :riakcs_access_key_id:
  :riakcs_secret_access_key:
  :softlayer_username:
  :softlayer_api_key:
  :softlayer_default_datacenter:
  :softlayer_cluster:
  :softlayer_default_domain:
  :stormondemand_username:
  :stormondemand_password:
  :terremark_username:
  :terremark_password:
  :voxel_api_key:
  :voxel_api_secret:
  :zerigo_email:
  :zerigo_token:
  :dnsimple_email:
  :dnsimple_password:
  :dnsmadeeasy_api_key:
  :dnsmadeeasy_secret_key:
  :dreamhost_api_key:
  :cloudstack_host:
  :cloudstack_api_key:
  :cloudstack_secret_access_key:
  :vsphere_server:
  :vsphere_username:
  :vsphere_password:
  :libvirt_username:
  :libvirt_password:
  :libvirt_uri:
  :libvirt_ip_command:
  :ibm_username:
  :ibm_password:
  :vcloud_director_host:
  :vcloud_director_username:
  :vcloud_director_password:
#
# End of Fog Credentials File
#######################################################

    YML
      raise Fog::Errors::LoadError, missing_credentials_message
    end
  end
end
