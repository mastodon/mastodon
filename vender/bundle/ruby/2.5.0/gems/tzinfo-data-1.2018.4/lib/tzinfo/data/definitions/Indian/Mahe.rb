# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Indian
        module Mahe
          include TimezoneDefinition
          
          timezone 'Indian/Mahe' do |tz|
            tz.offset :o0, 13308, 0, :LMT
            tz.offset :o1, 14400, 0, :'+04'
            
            tz.transition 1906, 5, :o1, -2006653308, 17405008891, 7200
          end
        end
      end
    end
  end
end
