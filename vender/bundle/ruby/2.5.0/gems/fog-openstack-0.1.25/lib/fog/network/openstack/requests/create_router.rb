module Fog
  module Network
    class OpenStack
      class Real
        def create_router(name, options = {})
          data = {
            'router' => {
              'name' => name,
            }
          }

          vanilla_options = [
            :admin_state_up,
            :tenant_id,
            :network_id,
            :status,
            :subnet_id
          ]
          vanilla_options.reject { |o| options[o].nil? }.each do |key|
            data['router'][key] = options[key]
          end

          # remove this in a future
          egi = options[:external_gateway_info]
          if egi
            if egi.kind_of?(Fog::Network::OpenStack::Network)
              Fog::Logger.deprecation "Passing a model objects into options[:external_gateway_info] is deprecated. \
              Please pass  external external gateway as follows options[:external_gateway_info] = { :network_id => NETWORK_ID }]"
              data['router'][:external_gateway_info] = {:network_id => egi.id}
            elsif egi.kind_of?(Hash) && egi[:network_id]
              data['router'][:external_gateway_info] = egi
            else
              raise ArgumentError, 'Invalid external_gateway_info attribute'
            end
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => [201],
            :method  => 'POST',
            :path    => 'routers'
          )
        end
      end

      class Mock
        def create_router(name, options = {})
          response = Excon::Response.new
          response.status = 201

          # remove this in a future
          egi = options[:external_gateway_info]
          if egi && egi.kind_of?(Fog::Network::OpenStack::Network)
            Fog::Logger.deprecation "Passing a model objects into options[:external_gateway_info] is deprecated. \
            Please pass  external external gateway as follows options[:external_gateway_info] = { :network_id => NETWORK_ID }]"
            egi = {:network_id => egi.id}
          end

          data = {
            'router' => {
              :id                    => Fog::Mock.random_numbers(6).to_s,
              :status                => options[:status] || 'ACTIVE',
              :external_gateway_info => egi,
              :name                  => name,
              :admin_state_up        => options[:admin_state_up],
              :tenant_id             => '6b96ff0cb17a4b859e1e575d221683d3'
            }
          }
          self.data[:routers][data['router'][:id]] = data['router']
          response.body = data
          response
        end
      end
    end
  end
end
