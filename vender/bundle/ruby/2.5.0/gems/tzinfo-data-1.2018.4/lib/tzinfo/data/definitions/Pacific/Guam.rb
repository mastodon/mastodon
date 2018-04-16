# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Guam
          include TimezoneDefinition
          
          timezone 'Pacific/Guam' do |tz|
            tz.offset :o0, -51660, 0, :LMT
            tz.offset :o1, 34740, 0, :LMT
            tz.offset :o2, 36000, 0, :GST
            tz.offset :o3, 36000, 0, :ChST
            
            tz.transition 1844, 12, :o1, -3944626740, 1149567407, 480
            tz.transition 1900, 12, :o2, -2177487540, 1159384847, 480
            tz.transition 2000, 12, :o3, 977493600
          end
        end
      end
    end
  end
end
