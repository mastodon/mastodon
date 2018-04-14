module Fog
  module Monitoring
    class OpenStack
      class Real
        def list_dimension_values(dimension_name, options = {})
          request(
            :expects => [200],
            :method  => 'GET',
            :path    => "metrics/dimensions/names/values",
            :query   => options.merge(:dimension_name => dimension_name)
          )
        end
      end

      class Mock
        # def list_dimension_values(dimension_name, options = {})
        # end
      end
    end
  end
end
