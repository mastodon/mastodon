require 'fog/openstack/models/model'

module Fog
  module ContainerInfra
    class OpenStack
      class Base < Fog::OpenStack::Model       
        def convert_update_params(params)
          params = params.map do |key, value|
          {
            "path"  => "/#{key}",
            "op"    => value ? "replace" : "remove"
          }.merge(value ? {"value" => value} : {})
          end
          params.each {|k,v| params[k] = v.to_s.capitalize if [true, false].include?(v)} 
        end
      end
    end
  end
end