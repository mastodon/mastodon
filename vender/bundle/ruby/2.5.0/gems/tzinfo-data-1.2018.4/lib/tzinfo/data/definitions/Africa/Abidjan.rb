# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Abidjan
          include TimezoneDefinition
          
          timezone 'Africa/Abidjan' do |tz|
            tz.offset :o0, -968, 0, :LMT
            tz.offset :o1, 0, 0, :GMT
            
            tz.transition 1912, 1, :o1, -1830383032, 26129547121, 10800
          end
        end
      end
    end
  end
end
