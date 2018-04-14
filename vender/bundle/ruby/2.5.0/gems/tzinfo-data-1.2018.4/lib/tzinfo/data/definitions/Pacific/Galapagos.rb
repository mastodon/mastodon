# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Galapagos
          include TimezoneDefinition
          
          timezone 'Pacific/Galapagos' do |tz|
            tz.offset :o0, -21504, 0, :LMT
            tz.offset :o1, -18000, 0, :'-05'
            tz.offset :o2, -21600, 0, :'-06'
            tz.offset :o3, -21600, 3600, :'-05'
            
            tz.transition 1931, 1, :o1, -1230746496, 1091854237, 450
            tz.transition 1986, 1, :o2, 504939600
            tz.transition 1992, 11, :o3, 722930400
            tz.transition 1993, 2, :o2, 728888400
          end
        end
      end
    end
  end
end
