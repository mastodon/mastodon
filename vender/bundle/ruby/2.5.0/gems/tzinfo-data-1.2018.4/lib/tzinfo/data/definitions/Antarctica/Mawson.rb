# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module Mawson
          include TimezoneDefinition
          
          timezone 'Antarctica/Mawson' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, 21600, 0, :'+06'
            tz.offset :o2, 18000, 0, :'+05'
            
            tz.transition 1954, 2, :o1, -501206400, 4869573, 2
            tz.transition 2009, 10, :o2, 1255809600
          end
        end
      end
    end
  end
end
