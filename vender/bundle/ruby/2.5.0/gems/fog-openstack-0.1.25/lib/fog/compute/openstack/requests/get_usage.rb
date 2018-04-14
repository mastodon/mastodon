module Fog
  module Compute
    class OpenStack
      class Real
        def get_usage(tenant_id, date_start, date_end)
          params = {}
          params[:start] = date_start.utc.iso8601.chop!
          params[:end]   = date_end.utc.iso8601.chop!
          request(
            :expects => [200, 203],
            :method  => 'GET',
            :path    => "os-simple-tenant-usage/#{tenant_id}",
            :query   => params
          )
        end
      end

      class Mock
        def get_usage(tenant_id, date_start, date_end)
          response        = Excon::Response.new
          response.status = 200
          response.body   = {"tenant_usage" =>
                                               {"total_memory_mb_usage" => 0.0,
                                                "total_vcpus_usage"     => 0.0,
                                                "total_hours"           => 0.0,
                                                "tenant_id"             => tenant_id,
                                                "stop"                  => date_start,
                                                "start"                 => date_end,
                                                "total_local_gb_usage"  => 0.0,
                                                "server_usages"         => [{
                                                  "hours"      => 0.0,
                                                  "uptime"     => 69180,
                                                  "local_gb"   => 0,
                                                  "ended_at"   => nil,
                                                  "name"       => "test server",
                                                  "tenant_id"  => tenant_id,
                                                  "vcpus"      => 1,
                                                  "memory_mb"  => 512,
                                                  "state"      => "active",
                                                  "flavor"     => "m1.tiny",
                                                  "started_at" => "2012-03-05 09:11:44"
                                                }]}}
          response
        end
      end
    end
  end
end
