# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Bangkok
          include TimezoneDefinition
          
          timezone 'Asia/Bangkok' do |tz|
            tz.offset :o0, 24124, 0, :LMT
            tz.offset :o1, 24124, 0, :BMT
            tz.offset :o2, 25200, 0, :'+07'
            
            tz.transition 1879, 12, :o1, -2840164924, 52006648769, 21600
            tz.transition 1920, 3, :o2, -1570084924, 52324168769, 21600
          end
        end
      end
    end
  end
end
