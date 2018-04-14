# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Atikokan
          include TimezoneDefinition
          
          timezone 'America/Atikokan' do |tz|
            tz.offset :o0, -21988, 0, :LMT
            tz.offset :o1, -21600, 0, :CST
            tz.offset :o2, -21600, 3600, :CDT
            tz.offset :o3, -21600, 3600, :CWT
            tz.offset :o4, -21600, 3600, :CPT
            tz.offset :o5, -18000, 0, :EST
            
            tz.transition 1895, 1, :o1, -2366733212, 52125006697, 21600
            tz.transition 1918, 4, :o2, -1632067200, 14530187, 6
            tz.transition 1918, 10, :o1, -1615136400, 58125451, 24
            tz.transition 1940, 9, :o2, -923248800, 9719607, 4
            tz.transition 1942, 2, :o3, -880214400, 14582399, 6
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o5, -765392400, 58361491, 24
          end
        end
      end
    end
  end
end
