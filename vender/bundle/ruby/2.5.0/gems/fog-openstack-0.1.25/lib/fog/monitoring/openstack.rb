
module Fog
  module Monitoring
    class OpenStack < Fog::Service
      requires   :openstack_auth_url
      recognizes :openstack_auth_token, :openstack_management_url,
                 :persistent, :openstack_service_type, :openstack_service_name,
                 :openstack_tenant, :openstack_tenant_id, :openstack_userid,
                 :openstack_api_key, :openstack_username, :openstack_identity_endpoint,
                 :current_user, :current_tenant, :openstack_region,
                 :openstack_endpoint_type, :openstack_auth_omit_default_port,
                 :openstack_project_name, :openstack_project_id,
                 :openstack_project_domain, :openstack_user_domain, :openstack_domain_name,
                 :openstack_project_domain_id, :openstack_user_domain_id, :openstack_domain_id,
                 :openstack_identity_prefix, :openstack_temp_url_key, :openstack_cache_ttl

      model_path 'fog/monitoring/openstack/models'
      model       :metric
      collection  :metrics
      model       :measurement
      collection  :measurements
      model       :statistic
      collection  :statistics
      model       :notification_method
      collection  :notification_methods
      model       :alarm_definition
      collection  :alarm_definitions
      model       :alarm
      collection  :alarms
      model       :alarm_state
      collection  :alarm_states
      model       :alarm_count
      collection  :alarm_counts
      model       :dimension_value

      request_path 'fog/monitoring/openstack/requests'
      request :create_metric
      request :create_metric_array
      request :list_metrics
      request :list_metric_names

      request :find_measurements

      request :list_statistics

      request :create_notification_method
      request :get_notification_method
      request :list_notification_methods
      request :put_notification_method
      request :patch_notification_method
      request :delete_notification_method

      request :create_alarm_definition
      request :list_alarm_definitions
      request :patch_alarm_definition
      request :update_alarm_definition
      request :get_alarm_definition
      request :delete_alarm_definition

      request :list_alarms
      request :get_alarm
      request :patch_alarm
      request :update_alarm
      request :delete_alarm
      request :get_alarm_counts

      request :list_alarm_state_history_for_specific_alarm
      request :list_alarm_state_history_for_all_alarms

      request :list_dimension_values

      request :list_notification_method_types

      class Real
        include Fog::OpenStack::Core

        def self.not_found_class
          Fog::Monitoring::OpenStack::NotFound
        end

        def initialize(options = {})
          initialize_identity options

          @openstack_service_type           = options[:openstack_service_type] || ['monitoring']
          @openstack_service_name           = options[:openstack_service_name]

          @connection_options               = options[:connection_options] || {}

          authenticate
          @persistent = options[:persistent] || false
          @connection = Fog::Core::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end
      end
    end
  end
end
