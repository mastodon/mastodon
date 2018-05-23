# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Manila
          include TimezoneDefinition
          
          timezone 'Asia/Manila' do |tz|
            tz.offset :o0, -57360, 0, :LMT
            tz.offset :o1, 29040, 0, :LMT
            tz.offset :o2, 28800, 0, :'+08'
            tz.offset :o3, 28800, 3600, :'+09'
            tz.offset :o4, 32400, 0, :'+09'
            
            tz.transition 1844, 12, :o1, -3944621040, 862175579, 360
            tz.transition 1899, 5, :o2, -2229321840, 869322659, 360
            tz.transition 1936, 10, :o3, -1046678400, 14570839, 6
            tz.transition 1937, 1, :o2, -1038733200, 19428521, 8
            tz.transition 1942, 4, :o4, -873273600, 14582881, 6
            tz.transition 1944, 10, :o2, -794221200, 19451161, 8
            tz.transition 1954, 4, :o3, -496224000, 14609065, 6
            tz.transition 1954, 6, :o2, -489315600, 19479393, 8
            tz.transition 1978, 3, :o3, 259344000
            tz.transition 1978, 9, :o2, 275151600
          end
        end
      end
    end
  end
end
