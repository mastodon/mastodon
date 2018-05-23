module Fog
  module Network
    class OpenStack
      class Real
        def delete_lb_vip(vip_id)
          request(
            :expects => 204,
            :method  => 'DELETE',
            :path    => "lb/vips/#{vip_id}"
          )
        end
      end

      class Mock
        def delete_lb_vip(vip_id)
          response = Excon::Response.new
          if list_lb_vips.body['vips'].map { |r| r['id'] }.include? vip_id
            data[:lb_vips].delete(vip_id)
            response.status = 204
            response
          else
            raise Fog::Network::OpenStack::NotFound
          end
        end
      end
    end
  end
end
