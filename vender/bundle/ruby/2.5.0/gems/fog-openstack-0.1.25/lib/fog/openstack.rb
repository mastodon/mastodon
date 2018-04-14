require 'fog/openstack/version'
require 'fog/core'
require 'fog/json'

require 'fog/openstack/core'
require 'fog/openstack/errors'

require 'fog/planning/openstack'

module Fog
  module Baremetal
    autoload :OpenStack, File.expand_path('../baremetal/openstack', __FILE__)
  end

  module Compute
    autoload :OpenStack, File.expand_path('../compute/openstack', __FILE__)
  end

  module ContainerInfra
    autoload :OpenStack, File.expand_path('../container_infra/openstack', __FILE__)
  end

  module DNS
    autoload :OpenStack, File.expand_path('../dns/openstack', __FILE__)

    class OpenStack
      autoload :V1, File.expand_path('../dns/openstack/v1', __FILE__)
      autoload :V2, File.expand_path('../dns/openstack/v2', __FILE__)
    end
  end

  module Event
    autoload :OpenStack, File.expand_path('../event/openstack', __FILE__)
  end

  module Identity
    autoload :OpenStack, File.expand_path('../identity/openstack', __FILE__)

    class OpenStack
      autoload :V2, File.expand_path('../identity/openstack/v2', __FILE__)
      autoload :V3, File.expand_path('../identity/openstack/v3', __FILE__)
    end
  end

  module Image
    autoload :OpenStack, File.expand_path('../image/openstack', __FILE__)

    class OpenStack
      autoload :V1, File.expand_path('../image/openstack/v1', __FILE__)
      autoload :V2, File.expand_path('../image/openstack/v2', __FILE__)
    end
  end

  module Introspection
    autoload :OpenStack, File.expand_path('../introspection/openstack', __FILE__)
  end

  module KeyManager
    autoload :OpenStack, File.expand_path('../key_manager/openstack', __FILE__)
  end

  module Metering
    autoload :OpenStack, File.expand_path('../metering/openstack', __FILE__)
  end

  module Metric
    autoload :OpenStack, File.expand_path('../metric/openstack', __FILE__)
  end

  module Monitoring
    autoload :OpenStack, File.expand_path('../monitoring/openstack', __FILE__)
  end

  module Network
    autoload :OpenStack, File.expand_path('../network/openstack', __FILE__)
  end

  module NFV
    autoload :OpenStack, File.expand_path('../nfv/openstack', __FILE__)
  end

  module Orchestration
    autoload :OpenStack, File.expand_path('../orchestration/openstack', __FILE__)
    autoload :Util, File.expand_path('../orchestration/util/recursive_hot_file_loader', __FILE__)
  end

  module SharedFileSystem
    autoload :OpenStack, File.expand_path('../shared_file_system/openstack', __FILE__)
  end

  module Storage
    autoload :OpenStack, File.expand_path('../storage/openstack', __FILE__)
  end

  module Volume
    autoload :OpenStack, File.expand_path('../volume/openstack', __FILE__)

    class OpenStack
      autoload :V1, File.expand_path('../volume/openstack/v1', __FILE__)
      autoload :V2, File.expand_path('../volume/openstack/v2', __FILE__)
    end
  end

  module Workflow
    autoload :OpenStack, File.expand_path('../workflow/openstack', __FILE__)

    class OpenStack
      autoload :V2, File.expand_path('../workflow/openstack/v2', __FILE__)
    end
  end

  module OpenStack
    extend Fog::Provider

    service(:baremetal,          'Baremetal')
    service(:compute,            'Compute')
    service(:container_infra,    'ContainerInfra')
    service(:dns,                'DNS')
    service(:event,              'Event')
    service(:identity,           'Identity')
    service(:image,              'Image')
    service(:introspection,      'Introspection')
    service(:key,                'KeyManager')
    service(:metering,           'Metering')
    service(:metric,             'Metric')
    service(:monitoring,         'Monitoring')
    service(:network,            'Network')
    service(:nfv,                'NFV')
    service(:orchestration,      'Orchestration')
    service(:planning,           'Planning')
    service(:shared_file_system, 'SharedFileSystem')
    service(:storage,            'Storage')
    service(:volume,             'Volume')
    service(:workflow,           'Workflow')

    @token_cache = {}

    class << self
      attr_accessor :token_cache
    end

    def self.clear_token_cache
      Fog::OpenStack.token_cache = {}
    end

    def self.authenticate(options, connection_options = {})
      case options[:openstack_auth_uri].path
      when /v1(\.\d+)?/
        authenticate_v1(options, connection_options)
      when /v2(\.\d+)?/
        authenticate_v2(options, connection_options)
      when /v3(\.\d+)?/
        authenticate_v3(options, connection_options)
      else
        authenticate_v2(options, connection_options)
      end
    end

    # legacy v1.0 style auth
    def self.authenticate_v1(options, connection_options = {})
      uri = options[:openstack_auth_uri]
      connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)
      @openstack_api_key  = options[:openstack_api_key]
      @openstack_username = options[:openstack_username]

      response = connection.request({
        :expects  => [200, 204],
        :headers  => {
          'X-Auth-Key'  => @openstack_api_key,
          'X-Auth-User' => @openstack_username
        },
        :method   => 'GET',
        :path     =>  (uri.path and not uri.path.empty?) ? uri.path : 'v1.0'
      })

      return {
        :token => response.headers['X-Auth-Token'],
        :server_management_url => response.headers['X-Server-Management-Url'] || response.headers['X-Storage-Url'],
        :identity_public_endpoint => response.headers['X-Keystone']
      }
    end

    # Keystone Style Auth
    def self.authenticate_v2(options, connection_options = {})
      uri                   = options[:openstack_auth_uri]
      tenant_name           = options[:openstack_tenant]
      service_type          = options[:openstack_service_type]
      service_name          = options[:openstack_service_name]
      identity_service_type = options[:openstack_identity_service_type]
      endpoint_type         = (options[:openstack_endpoint_type] || 'publicURL').to_s
      openstack_region      = options[:openstack_region]

      body = retrieve_tokens_v2(options, connection_options)
      service = get_service(body, service_type, service_name)

      options[:unscoped_token] = body['access']['token']['id']

      unless service
        unless tenant_name
          response = Fog::Core::Connection.new(
            "#{uri.scheme}://#{uri.host}:#{uri.port}/v2.0/tenants", false, connection_options).request({
            :expects => [200, 204],
            :headers => {'Content-Type' => 'application/json',
                         'Accept' => 'application/json',
                         'X-Auth-Token' => body['access']['token']['id']},
            :method  => 'GET'
          })

          body = Fog::JSON.decode(response.body)
          if body['tenants'].empty?
            raise Fog::Errors::NotFound.new('No Tenant Found')
          else
            options[:openstack_tenant] = body['tenants'].first['name']
          end
        end

        body = retrieve_tokens_v2(options, connection_options)
        service = get_service(body, service_type, service_name)

      end

      unless service
        available = body['access']['serviceCatalog'].map { |endpoint|
          endpoint['type']
        }.sort.join ', '

        missing = service_type.join ', '

        message = "Could not find service #{missing}.  Have #{available}"

        raise Fog::Errors::NotFound, message
      end

      service['endpoints'] = service['endpoints'].select do |endpoint|
        endpoint['region'] == openstack_region
      end if openstack_region

      if service['endpoints'].empty?
        raise Fog::Errors::NotFound.new("No endpoints available for region '#{openstack_region}'")
      end if openstack_region

      regions = service["endpoints"].map{ |e| e['region'] }.uniq
      if regions.count > 1
        raise Fog::Errors::NotFound.new("Multiple regions available choose one of these '#{regions.join(',')}'")
      end

      identity_service = get_service(body, identity_service_type) if identity_service_type
      tenant = body['access']['token']['tenant']
      user = body['access']['user']

      management_url = service['endpoints'].find{|s| s[endpoint_type]}[endpoint_type]
      identity_url   = identity_service['endpoints'].find{|s| s['publicURL']}['publicURL'] if identity_service

      {
        :user                     => user,
        :tenant                   => tenant,
        :identity_public_endpoint => identity_url,
        :server_management_url    => management_url,
        :token                    => body['access']['token']['id'],
        :expires                  => body['access']['token']['expires'],
        :current_user_id          => body['access']['user']['id'],
        :unscoped_token           => options[:unscoped_token]
      }
    end

    # Keystone Style Auth
    def self.authenticate_v3(options, connection_options = {})
      uri                   = options[:openstack_auth_uri]
      project_name          = options[:openstack_project_name]
      service_type          = options[:openstack_service_type]
      service_name          = options[:openstack_service_name]
      identity_service_type = options[:openstack_identity_service_type]
      endpoint_type         = map_endpoint_type(options[:openstack_endpoint_type] || 'publicURL')
      openstack_region      = options[:openstack_region]

      token, body = retrieve_tokens_v3 options, connection_options

      service = get_service_v3(body, service_type, service_name, openstack_region, options)

      options[:unscoped_token] = token

      unless service
        unless project_name
          request_body = {
              :expects => [200],
              :headers => {'Content-Type' => 'application/json',
                           'Accept' => 'application/json',
                           'X-Auth-Token' => token},
              :method => 'GET'
          }
          user_id = body['token']['user']['id']
          project_uri = uri.clone
          project_uri.path = uri.path.sub('/auth/tokens', "/users/#{user_id}/projects")
          project_uri_param = "#{project_uri.scheme}://#{project_uri.host}:#{project_uri.port}#{project_uri.path}"
          response = Fog::Core::Connection.new(project_uri_param, false, connection_options).request(request_body)

          projects_body = Fog::JSON.decode(response.body)
          if projects_body['projects'].empty?
            options[:openstack_domain_id] = body['token']['user']['domain']['id']
          else
            options[:openstack_project_id] = projects_body['projects'].first['id']
            options[:openstack_project_name] = projects_body['projects'].first['name']
            options[:openstack_domain_id] = projects_body['projects'].first['domain_id']
          end
        end

        token, body = retrieve_tokens_v3(options, connection_options)
        service = get_service_v3(body, service_type, service_name, openstack_region, options)
      end

      # If no identity endpoint is found, try the auth uri (slicing /auth/tokens)
      # It covers the case where identityv3 endpoint is not present in the catalog but we have to use it
      unless service
        if service_type.include? "identity"
          identity_uri = uri.to_s.sub('/auth/tokens', '')
          response = Fog::Core::Connection.new(identity_uri, false, connection_options).request({:method => 'GET'})
          if response.status == 200
            service = {
              "endpoints" => [{
                 "url"       => identity_uri,
                 "region"    => openstack_region,
                 "interface" => endpoint_type
              }],
              "type"      => service_type,
              "name"      => service_name
            }
          end
        end
      end

      unless service
        available_services = body['token']['catalog'].map { |service|
          service['type']
        }.sort.join ', '

        available_regions = body['token']['catalog'].map { |service|
          service['endpoints'].map { |endpoint|
            endpoint['region']
          }.uniq
        }.uniq.sort.join ', '

        missing = service_type.join ', '

        message = "Could not find service #{missing}#{(' in region '+openstack_region) if openstack_region}."+
            " Have #{available_services}#{(' in regions '+available_regions) if openstack_region}"

        raise Fog::Errors::NotFound, message
      end

      service['endpoints'] = service['endpoints'].select do |endpoint|
        endpoint['region'] == openstack_region && endpoint['interface'] == endpoint_type
      end if openstack_region

      if service['endpoints'].empty?
        raise Fog::Errors::NotFound.new("No endpoints available for region '#{openstack_region}'")
      end if openstack_region

      regions = service["endpoints"].map { |e| e['region'] }.uniq
      if regions.count > 1
        raise Fog::Errors::NotFound.new("Multiple regions available choose one of these '#{regions.join(',')}'")
      end

      identity_service = get_service_v3(body, identity_service_type, nil, nil, :openstack_endpoint_path_matches => /\/v3/) if identity_service_type

      management_url = service['endpoints'].find { |e| e['interface']==endpoint_type }['url']
      identity_url = identity_service['endpoints'].find { |e| e['interface']=='public' }['url'] if identity_service

      if body['token']['project']
        tenant = body['token']['project']
      elsif body['token']['user']['project']
        tenant = body['token']['user']['project']
      end

      return {
          :user                     => body['token']['user']['name'],
          :tenant                   => tenant,
          :identity_public_endpoint => identity_url,
          :server_management_url    => management_url,
          :token                    => token,
          :expires                  => body['token']['expires_at'],
          :current_user_id          => body['token']['user']['id'],
          :unscoped_token           => options[:unscoped_token]
      }
    end

    def self.get_service(body, service_type=[], service_name=nil)
      if not body['access'].nil?
        body['access']['serviceCatalog'].find do |s|
          if service_name.nil? or service_name.empty?
            service_type.include?(s['type'])
          else
            service_type.include?(s['type']) and s['name'] == service_name
          end
        end
      elsif not body['token']['catalog'].nil?
        body['token']['catalog'].find do |s|
          if service_name.nil? or service_name.empty?
            service_type.include?(s['type'])
          else
            service_type.include?(s['type']) and s['name'] == service_name
          end
        end

      end
    end

    def self.retrieve_tokens_v2(options, connection_options = {})
      api_key           = options[:openstack_api_key].to_s
      username          = options[:openstack_username].to_s
      tenant_name       = options[:openstack_tenant].to_s
      auth_token        = options[:openstack_auth_token] || options[:unscoped_token]
      uri               = options[:openstack_auth_uri]
      omit_default_port = options[:openstack_auth_omit_default_port]

      identity_v2_connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)
      request_body = {:auth => Hash.new}

      if auth_token
        request_body[:auth][:token] = {
          :id => auth_token
        }
      else
        request_body[:auth][:passwordCredentials] = {
          :username => username,
          :password => api_key
        }
      end
      request_body[:auth][:tenantName] = tenant_name if tenant_name

      request = {
        :expects => [200, 204],
        :headers => {'Content-Type' => 'application/json'},
        :body    => Fog::JSON.encode(request_body),
        :method  => 'POST',
        :path    => (uri.path and not uri.path.empty?) ? uri.path : 'v2.0'
      }
      request[:omit_default_port] = omit_default_port unless omit_default_port.nil?

      response = identity_v2_connection.request(request)

      Fog::JSON.decode(response.body)
    end

    def self.retrieve_tokens_v3(options, connection_options = {})

      api_key           = options[:openstack_api_key].to_s
      username          = options[:openstack_username].to_s
      userid            = options[:openstack_userid]
      domain_id         = options[:openstack_domain_id]
      domain_name       = options[:openstack_domain_name]
      project_domain    = options[:openstack_project_domain]
      project_domain_id = options[:openstack_project_domain_id]
      user_domain       = options[:openstack_user_domain]
      user_domain_id    = options[:openstack_user_domain_id]
      project_name      = options[:openstack_project_name]
      project_id        = options[:openstack_project_id]
      auth_token        = options[:openstack_auth_token] || options[:unscoped_token]
      uri               = options[:openstack_auth_uri]
      omit_default_port = options[:openstack_auth_omit_default_port]
      cache_ttl         = options[:openstack_cache_ttl] || 0

      connection = Fog::Core::Connection.new(uri.to_s, false, connection_options)
      request_body = {:auth => {}}

      scope = {}

      if project_name || project_id
        scope[:project] = if project_id.nil? then
                            if project_domain || project_domain_id
                              {:name => project_name, :domain => project_domain_id.nil? ? {:name => project_domain} : {:id => project_domain_id}}
                            else
                              {:name => project_name, :domain => domain_id.nil? ? {:name => domain_name} : {:id => domain_id}}
                            end
                          else
                            {:id => project_id}
                          end
      elsif domain_name || domain_id
        scope[:domain] = domain_id.nil? ? {:name => domain_name} : {:id => domain_id}
      else
        # unscoped token
      end

      if auth_token
        request_body[:auth][:identity] = {
            :methods => %w{token},
            :token => {
                :id => auth_token
            }
        }
      else
        request_body[:auth][:identity] = {
            :methods => %w{password},
            :password => {
                :user => {
                    :password => api_key
                }
            }
        }

        if userid
          request_body[:auth][:identity][:password][:user][:id] = userid
        else
          if user_domain || user_domain_id
            request_body[:auth][:identity][:password][:user].merge! :domain => user_domain_id.nil? ? {:name => user_domain} : {:id => user_domain_id}
          elsif domain_name || domain_id
            request_body[:auth][:identity][:password][:user].merge! :domain => domain_id.nil? ? {:name => domain_name} : {:id => domain_id}
          end
          request_body[:auth][:identity][:password][:user][:name] = username
        end

      end
      request_body[:auth][:scope] = scope unless scope.empty?

      path     = (uri.path and not uri.path.empty?) ? uri.path : 'v3'

      response, expires = Fog::OpenStack.token_cache[{:body => request_body, :path => path}] if cache_ttl > 0

      unless response && expires > Time.now
        request = {
          :expects => [201],
          :headers => {'Content-Type' => 'application/json'},
          :body    => Fog::JSON.encode(request_body),
          :method  => 'POST',
          :path    => path
        }
        request[:omit_default_port] = omit_default_port unless omit_default_port.nil?

        response = connection.request(request)
        if cache_ttl > 0
          cache = Fog::OpenStack.token_cache
          cache[{:body => request_body, :path => path}] = response, Time.now + cache_ttl
          Fog::OpenStack.token_cache = cache
        end
      end

      [response.headers["X-Subject-Token"], Fog::JSON.decode(response.body)]
    end

    def self.get_service_v3(hash, service_type=[], service_name=nil, region=nil, options={})

      # Find all services matching any of the types in service_type, filtered by service_name if it's non-nil
      services = hash['token']['catalog'].find_all do |s|
        if service_name.nil? or service_name.empty?
          service_type.include?(s['type'])
        else
          service_type.include?(s['type']) and s['name'] == service_name
        end
      end if hash['token']['catalog']

      # Filter the found services by region (if specified) and whether the endpoint path matches the given regex (e.g. /\/v3/)
      services.find do |s|
        s['endpoints'].any? { |ep| endpoint_region?(ep, region) && endpoint_path_match?(ep, options[:openstack_endpoint_path_matches])}
      end if services

    end

    def self.endpoint_region?(endpoint, region)
      region.nil? || endpoint['region'] == region
    end

    def self.endpoint_path_match?(endpoint, match_regex)
      match_regex.nil? || URI(endpoint['url']).path =~ match_regex
    end

    def self.get_supported_version(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      version = supported_version['id'] if supported_version
      version_raise(supported_versions) if version.nil?

      version
    end

    def self.get_supported_version_path(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      link = supported_version['links'].find { |l| l['rel'] == 'self' } if supported_version
      path = URI.parse(link['href']).path if link
      version_raise(supported_versions) if path.nil?

      path.chomp '/'
    end

    def self.get_supported_microversion(supported_versions, uri, auth_token, connection_options = {})
      supported_version = get_version(supported_versions, uri, auth_token, connection_options)
      supported_version['version'] if supported_version
    end

    # CGI.escape, but without special treatment on spaces
    def self.escape(str, extra_exclude_chars = '')
      str.gsub(/([^a-zA-Z0-9_.-#{extra_exclude_chars}]+)/) do
        '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      end
    end

    def self.map_endpoint_type type
      case type
        when "publicURL"
          "public"
        when "internalURL"
          "internal"
        when "adminURL"
          "admin"
      end

    end

    def self.get_version(supported_versions, uri, auth_token, connection_options = {})
      version_cache = "#{uri}#{supported_versions}"
      return @version[version_cache] if @version && @version[version_cache]
      connection = Fog::Core::Connection.new("#{uri.scheme}://#{uri.host}:#{uri.port}", false, connection_options)
      response = connection.request(
        :expects => [200, 204, 300],
        :headers => {'Content-Type' => 'application/json',
                     'Accept'       => 'application/json',
                     'X-Auth-Token' => auth_token},
        :method  => 'GET'
      )

      body = Fog::JSON.decode(response.body)

      @version                = {} unless @version
      @version[version_cache] = extract_version_from_body(body, supported_versions)
    end

    def self.extract_version_from_body(body, supported_versions)
      return nil if body['versions'].empty?
      versions = body['versions'].kind_of?(Array) ? body['versions'] : body['versions']['values']
      version = nil
      # order is important, preffered status should be first
      %w(CURRENT stable SUPPORTED DEPRECATED).each do |status|
        version = versions.find { |x| x['id'].match(supported_versions) && (x['status'] == status) }
        break if version
      end

      version
    end

    def self.version_raise(supported_versions)
      raise Fog::OpenStack::Errors::ServiceUnavailable,
            "OpenStack service only supports API versions #{supported_versions.inspect}"
    end
  end
end
