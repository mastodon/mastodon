# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Kwajalein
          include TimezoneDefinition
          
          timezone 'Pacific/Kwajalein' do |tz|
            tz.offset :o0, 40160, 0, :LMT
            tz.offset :o1, 39600, 0, :'+11'
            tz.offset :o2, -43200, 0, :'-12'
            tz.offset :o3, 43200, 0, :'+12'
            
            tz.transition 1900, 12, :o1, -2177492960, 1304307919, 540
            tz.transition 1969, 9, :o2, -7988400, 58571881, 24
            tz.transition 1993, 8, :o3, 745848000
          end
        end
      end
    end
  end
end
