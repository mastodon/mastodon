# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Indian
        module Christmas
          include TimezoneDefinition
          
          timezone 'Indian/Christmas' do |tz|
            tz.offset :o0, 25372, 0, :LMT
            tz.offset :o1, 25200, 0, :'+07'
            
            tz.transition 1895, 1, :o1, -2364102172, 52125664457, 21600
          end
        end
      end
    end
  end
end
