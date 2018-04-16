# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Phoenix
          include TimezoneDefinition
          
          timezone 'America/Phoenix' do |tz|
            tz.offset :o0, -26898, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -25200, 3600, :MDT
            tz.offset :o3, -25200, 3600, :MWT
            
            tz.transition 1883, 11, :o1, -2717643600, 57819199, 24
            tz.transition 1918, 3, :o2, -1633273200, 19373471, 8
            tz.transition 1918, 10, :o1, -1615132800, 14531363, 6
            tz.transition 1919, 3, :o2, -1601823600, 19376383, 8
            tz.transition 1919, 10, :o1, -1583683200, 14533547, 6
            tz.transition 1942, 2, :o3, -880210800, 19443199, 8
            tz.transition 1944, 1, :o1, -820519140, 3500770681, 1440
            tz.transition 1944, 4, :o3, -812653140, 3500901781, 1440
            tz.transition 1944, 10, :o1, -796845540, 3501165241, 1440
            tz.transition 1967, 4, :o2, -84380400, 19516887, 8
            tz.transition 1967, 10, :o1, -68659200, 14638757, 6
          end
        end
      end
    end
  end
end
