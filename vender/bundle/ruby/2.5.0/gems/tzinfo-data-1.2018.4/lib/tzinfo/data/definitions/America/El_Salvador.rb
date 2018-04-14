# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module El_Salvador
          include TimezoneDefinition
          
          timezone 'America/El_Salvador' do |tz|
            tz.offset :o0, -21408, 0, :LMT
            tz.offset :o1, -21600, 0, :CST
            tz.offset :o2, -21600, 3600, :CDT
            
            tz.transition 1921, 1, :o1, -1546279392, 2180421673, 900
            tz.transition 1987, 5, :o2, 547020000
            tz.transition 1987, 9, :o1, 559717200
            tz.transition 1988, 5, :o2, 578469600
            tz.transition 1988, 9, :o1, 591166800
          end
        end
      end
    end
  end
end
