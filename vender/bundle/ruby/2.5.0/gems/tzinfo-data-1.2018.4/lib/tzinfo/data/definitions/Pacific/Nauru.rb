# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Nauru
          include TimezoneDefinition
          
          timezone 'Pacific/Nauru' do |tz|
            tz.offset :o0, 40060, 0, :LMT
            tz.offset :o1, 41400, 0, :'+1130'
            tz.offset :o2, 32400, 0, :'+09'
            tz.offset :o3, 43200, 0, :'+12'
            
            tz.transition 1921, 1, :o1, -1545131260, 10466081437, 4320
            tz.transition 1942, 3, :o2, -877347000, 116660785, 48
            tz.transition 1944, 8, :o1, -800960400, 19450537, 8
            tz.transition 1979, 4, :o3, 294323400
          end
        end
      end
    end
  end
end
