# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Managua
          include TimezoneDefinition
          
          timezone 'America/Managua' do |tz|
            tz.offset :o0, -20708, 0, :LMT
            tz.offset :o1, -20712, 0, :MMT
            tz.offset :o2, -21600, 0, :CST
            tz.offset :o3, -18000, 0, :EST
            tz.offset :o4, -21600, 3600, :CDT
            
            tz.transition 1890, 1, :o1, -2524500892, 52085564777, 21600
            tz.transition 1934, 6, :o2, -1121105688, 8739402263, 3600
            tz.transition 1973, 5, :o3, 105084000
            tz.transition 1975, 2, :o2, 161758800
            tz.transition 1979, 3, :o4, 290584800
            tz.transition 1979, 6, :o2, 299134800
            tz.transition 1980, 3, :o4, 322034400
            tz.transition 1980, 6, :o2, 330584400
            tz.transition 1992, 1, :o3, 694260000
            tz.transition 1992, 9, :o2, 717310800
            tz.transition 1993, 1, :o3, 725868000
            tz.transition 1997, 1, :o2, 852094800
            tz.transition 2005, 4, :o4, 1113112800
            tz.transition 2005, 10, :o2, 1128229200
            tz.transition 2006, 4, :o4, 1146384000
            tz.transition 2006, 10, :o2, 1159682400
          end
        end
      end
    end
  end
end
