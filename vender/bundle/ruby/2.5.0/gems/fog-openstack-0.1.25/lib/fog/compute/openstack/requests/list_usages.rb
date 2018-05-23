module Fog
  module Compute
    class OpenStack
      class Real
        def list_usages(date_start = nil, date_end = nil, detailed = false)
          params = {}
          params[:start] = date_start.iso8601.gsub(/\+.*/, '') if date_start
          params[:end]   = date_end.iso8601.gsub(/\+.*/, '')   if date_end
          params[:detailed] = (detailed ? '1' : '0')           if detailed

          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => 'os-simple-tenant-usage',
            :query   => params
          )
        end
      end

      class Mock
        def list_usages(_date_start = nil, _date_end = nil, _detailed = false)
          response        = Excon::Response.new
          response.status = 200
          response.body   = {"tenant_usages" => [{
            "total_memory_mb_usage" => 0.00036124444444444445,
            "total_vcpus_usage"     => 7.055555555555556e-07,
            "start"                 => "2012-03-06 05:05:56.349001",
            "tenant_id"             => "b97c8abba0c44a0987c63b858a4823e5",
            "stop"                  => "2012-03-06 05:05:56.349255",
            "total_hours"           => 7.055555555555556e-07,
            "total_local_gb_usage"  => 0.0
          }]}
          response
        end
      end
    end
  end
end
