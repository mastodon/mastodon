# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module Eucla
          include TimezoneDefinition
          
          timezone 'Australia/Eucla' do |tz|
            tz.offset :o0, 30928, 0, :LMT
            tz.offset :o1, 31500, 0, :'+0845'
            tz.offset :o2, 31500, 3600, :'+0945'
            
            tz.transition 1895, 11, :o1, -2337928528, 13033051967, 5400
            tz.transition 1916, 12, :o2, -1672562640, 871642489, 360
            tz.transition 1917, 3, :o1, -1665387900, 232445969, 96
            tz.transition 1941, 12, :o2, -883637100, 77771527, 32
            tz.transition 1942, 3, :o1, -876123900, 233322929, 96
            tz.transition 1942, 9, :o2, -860395500, 77780135, 32
            tz.transition 1943, 3, :o1, -844674300, 233357873, 96
            tz.transition 1974, 10, :o2, 152039700
            tz.transition 1975, 3, :o1, 162926100
            tz.transition 1983, 10, :o2, 436295700
            tz.transition 1984, 3, :o1, 447182100
            tz.transition 1991, 11, :o2, 690311700
            tz.transition 1992, 2, :o1, 699383700
            tz.transition 2006, 12, :o2, 1165079700
            tz.transition 2007, 3, :o1, 1174756500
            tz.transition 2007, 10, :o2, 1193505300
            tz.transition 2008, 3, :o1, 1206810900
            tz.transition 2008, 10, :o2, 1224954900
            tz.transition 2009, 3, :o1, 1238260500
          end
        end
      end
    end
  end
end
