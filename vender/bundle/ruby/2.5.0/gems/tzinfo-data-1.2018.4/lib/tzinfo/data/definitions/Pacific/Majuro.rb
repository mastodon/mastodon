# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Majuro
          include TimezoneDefinition
          
          timezone 'Pacific/Majuro' do |tz|
            tz.offset :o0, 41088, 0, :LMT
            tz.offset :o1, 39600, 0, :'+11'
            tz.offset :o2, 43200, 0, :'+12'
            
            tz.transition 1900, 12, :o1, -2177493888, 1086923261, 450
            tz.transition 1969, 9, :o2, -7988400, 58571881, 24
          end
        end
      end
    end
  end
end
