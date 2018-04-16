# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Kuching
          include TimezoneDefinition
          
          timezone 'Asia/Kuching' do |tz|
            tz.offset :o0, 26480, 0, :LMT
            tz.offset :o1, 27000, 0, :'+0730'
            tz.offset :o2, 28800, 0, :'+08'
            tz.offset :o3, 28800, 1200, :'+0820'
            tz.offset :o4, 32400, 0, :'+09'
            
            tz.transition 1926, 2, :o1, -1383463280, 2618541209, 1080
            tz.transition 1932, 12, :o2, -1167636600, 38833171, 16
            tz.transition 1935, 9, :o3, -1082448000, 14568355, 6
            tz.transition 1935, 12, :o2, -1074586800, 174826811, 72
            tz.transition 1936, 9, :o3, -1050825600, 14570551, 6
            tz.transition 1936, 12, :o2, -1042964400, 174853163, 72
            tz.transition 1937, 9, :o3, -1019289600, 14572741, 6
            tz.transition 1937, 12, :o2, -1011428400, 174879443, 72
            tz.transition 1938, 9, :o3, -987753600, 14574931, 6
            tz.transition 1938, 12, :o2, -979892400, 174905723, 72
            tz.transition 1939, 9, :o3, -956217600, 14577121, 6
            tz.transition 1939, 12, :o2, -948356400, 174932003, 72
            tz.transition 1940, 9, :o3, -924595200, 14579317, 6
            tz.transition 1940, 12, :o2, -916734000, 174958355, 72
            tz.transition 1941, 9, :o3, -893059200, 14581507, 6
            tz.transition 1941, 12, :o2, -885198000, 174984635, 72
            tz.transition 1942, 2, :o4, -879667200, 14582437, 6
            tz.transition 1945, 9, :o2, -767005200, 19453681, 8
          end
        end
      end
    end
  end
end
