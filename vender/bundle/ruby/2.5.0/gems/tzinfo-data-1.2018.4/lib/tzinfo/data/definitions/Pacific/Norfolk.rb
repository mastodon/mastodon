# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Norfolk
          include TimezoneDefinition
          
          timezone 'Pacific/Norfolk' do |tz|
            tz.offset :o0, 40312, 0, :LMT
            tz.offset :o1, 40320, 0, :'+1112'
            tz.offset :o2, 41400, 0, :'+1130'
            tz.offset :o3, 41400, 3600, :'+1230'
            tz.offset :o4, 39600, 0, :'+11'
            
            tz.transition 1900, 12, :o1, -2177493112, 26086158361, 10800
            tz.transition 1950, 12, :o2, -599656320, 73009411, 30
            tz.transition 1974, 10, :o3, 152029800
            tz.transition 1975, 3, :o2, 162912600
            tz.transition 2015, 10, :o4, 1443882600
          end
        end
      end
    end
  end
end
