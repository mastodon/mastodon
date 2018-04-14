# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Pohnpei
          include TimezoneDefinition
          
          timezone 'Pacific/Pohnpei' do |tz|
            tz.offset :o0, 37972, 0, :LMT
            tz.offset :o1, 39600, 0, :'+11'
            
            tz.transition 1900, 12, :o1, -2177490772, 52172317307, 21600
          end
        end
      end
    end
  end
end
