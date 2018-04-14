# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Indian
        module Chagos
          include TimezoneDefinition
          
          timezone 'Indian/Chagos' do |tz|
            tz.offset :o0, 17380, 0, :LMT
            tz.offset :o1, 18000, 0, :'+05'
            tz.offset :o2, 21600, 0, :'+06'
            
            tz.transition 1906, 12, :o1, -1988167780, 10443929611, 4320
            tz.transition 1995, 12, :o2, 820436400
          end
        end
      end
    end
  end
end
