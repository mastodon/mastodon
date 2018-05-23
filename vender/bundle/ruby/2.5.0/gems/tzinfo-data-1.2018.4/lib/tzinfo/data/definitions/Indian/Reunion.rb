# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Indian
        module Reunion
          include TimezoneDefinition
          
          timezone 'Indian/Reunion' do |tz|
            tz.offset :o0, 13312, 0, :LMT
            tz.offset :o1, 14400, 0, :'+04'
            
            tz.transition 1911, 5, :o1, -1848886912, 3265904267, 1350
          end
        end
      end
    end
  end
end
