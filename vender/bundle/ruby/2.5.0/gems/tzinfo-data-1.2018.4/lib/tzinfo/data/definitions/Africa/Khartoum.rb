# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Khartoum
          include TimezoneDefinition
          
          timezone 'Africa/Khartoum' do |tz|
            tz.offset :o0, 7808, 0, :LMT
            tz.offset :o1, 7200, 0, :CAT
            tz.offset :o2, 7200, 3600, :CAST
            tz.offset :o3, 10800, 0, :EAT
            
            tz.transition 1930, 12, :o1, -1230775808, 3275562253, 1350
            tz.transition 1970, 4, :o2, 10360800
            tz.transition 1970, 10, :o1, 24786000
            tz.transition 1971, 4, :o2, 41810400
            tz.transition 1971, 10, :o1, 56322000
            tz.transition 1972, 4, :o2, 73432800
            tz.transition 1972, 10, :o1, 87944400
            tz.transition 1973, 4, :o2, 104882400
            tz.transition 1973, 10, :o1, 119480400
            tz.transition 1974, 4, :o2, 136332000
            tz.transition 1974, 10, :o1, 151016400
            tz.transition 1975, 4, :o2, 167781600
            tz.transition 1975, 10, :o1, 182552400
            tz.transition 1976, 4, :o2, 199231200
            tz.transition 1976, 10, :o1, 214174800
            tz.transition 1977, 4, :o2, 230680800
            tz.transition 1977, 10, :o1, 245710800
            tz.transition 1978, 4, :o2, 262735200
            tz.transition 1978, 10, :o1, 277246800
            tz.transition 1979, 4, :o2, 294184800
            tz.transition 1979, 10, :o1, 308782800
            tz.transition 1980, 4, :o2, 325634400
            tz.transition 1980, 10, :o1, 340405200
            tz.transition 1981, 4, :o2, 357084000
            tz.transition 1981, 10, :o1, 371941200
            tz.transition 1982, 4, :o2, 388533600
            tz.transition 1982, 10, :o1, 403477200
            tz.transition 1983, 4, :o2, 419983200
            tz.transition 1983, 10, :o1, 435013200
            tz.transition 1984, 4, :o2, 452037600
            tz.transition 1984, 10, :o1, 466635600
            tz.transition 1985, 4, :o2, 483487200
            tz.transition 1985, 10, :o1, 498171600
            tz.transition 2000, 1, :o3, 947930400
            tz.transition 2017, 10, :o1, 1509483600
          end
        end
      end
    end
  end
end
