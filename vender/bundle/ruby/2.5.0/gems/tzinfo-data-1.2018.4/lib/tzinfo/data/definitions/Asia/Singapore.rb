# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Singapore
          include TimezoneDefinition
          
          timezone 'Asia/Singapore' do |tz|
            tz.offset :o0, 24925, 0, :LMT
            tz.offset :o1, 24925, 0, :SMT
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 25200, 1200, :'+0720'
            tz.offset :o4, 26400, 0, :'+0720'
            tz.offset :o5, 27000, 0, :'+0730'
            tz.offset :o6, 32400, 0, :'+09'
            tz.offset :o7, 28800, 0, :'+08'
            
            tz.transition 1900, 12, :o1, -2177477725, 8347571291, 3456
            tz.transition 1905, 5, :o2, -2038200925, 8353142363, 3456
            tz.transition 1932, 12, :o3, -1167634800, 58249757, 24
            tz.transition 1935, 12, :o4, -1073028000, 87414055, 36
            tz.transition 1941, 8, :o5, -894180000, 87488575, 36
            tz.transition 1942, 2, :o6, -879665400, 38886499, 16
            tz.transition 1945, 9, :o5, -767005200, 19453681, 8
            tz.transition 1981, 12, :o7, 378664200
          end
        end
      end
    end
  end
end
