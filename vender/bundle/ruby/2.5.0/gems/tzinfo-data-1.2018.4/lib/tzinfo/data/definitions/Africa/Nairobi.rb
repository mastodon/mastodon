# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Nairobi
          include TimezoneDefinition
          
          timezone 'Africa/Nairobi' do |tz|
            tz.offset :o0, 8836, 0, :LMT
            tz.offset :o1, 10800, 0, :EAT
            tz.offset :o2, 9000, 0, :'+0230'
            tz.offset :o3, 9900, 0, :'+0245'
            
            tz.transition 1928, 6, :o1, -1309746436, 52389253391, 21600
            tz.transition 1929, 12, :o2, -1262314800, 19407819, 8
            tz.transition 1939, 12, :o3, -946780200, 116622211, 48
            tz.transition 1959, 12, :o1, -315629100, 233945701, 96
          end
        end
      end
    end
  end
end
