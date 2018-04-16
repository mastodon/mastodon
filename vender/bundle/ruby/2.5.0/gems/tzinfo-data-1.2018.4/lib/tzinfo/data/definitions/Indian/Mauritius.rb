# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Indian
        module Mauritius
          include TimezoneDefinition
          
          timezone 'Indian/Mauritius' do |tz|
            tz.offset :o0, 13800, 0, :LMT
            tz.offset :o1, 14400, 0, :'+04'
            tz.offset :o2, 14400, 3600, :'+05'
            
            tz.transition 1906, 12, :o1, -1988164200, 348130993, 144
            tz.transition 1982, 10, :o2, 403041600
            tz.transition 1983, 3, :o1, 417034800
            tz.transition 2008, 10, :o2, 1224972000
            tz.transition 2009, 3, :o1, 1238274000
          end
        end
      end
    end
  end
end
