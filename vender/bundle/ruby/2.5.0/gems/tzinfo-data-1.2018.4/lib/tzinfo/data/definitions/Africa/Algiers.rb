# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Algiers
          include TimezoneDefinition
          
          timezone 'Africa/Algiers' do |tz|
            tz.offset :o0, 732, 0, :LMT
            tz.offset :o1, 561, 0, :PMT
            tz.offset :o2, 0, 0, :WET
            tz.offset :o3, 0, 3600, :WEST
            tz.offset :o4, 3600, 0, :CET
            tz.offset :o5, 3600, 3600, :CEST
            
            tz.transition 1891, 3, :o1, -2486679072, 2170625843, 900
            tz.transition 1911, 3, :o2, -1855958961, 69670267013, 28800
            tz.transition 1916, 6, :o3, -1689814800, 58104707, 24
            tz.transition 1916, 10, :o2, -1680397200, 58107323, 24
            tz.transition 1917, 3, :o3, -1665363600, 58111499, 24
            tz.transition 1917, 10, :o2, -1648342800, 58116227, 24
            tz.transition 1918, 3, :o3, -1635123600, 58119899, 24
            tz.transition 1918, 10, :o2, -1616893200, 58124963, 24
            tz.transition 1919, 3, :o3, -1604278800, 58128467, 24
            tz.transition 1919, 10, :o2, -1585443600, 58133699, 24
            tz.transition 1920, 2, :o3, -1574038800, 58136867, 24
            tz.transition 1920, 10, :o2, -1552266000, 58142915, 24
            tz.transition 1921, 3, :o3, -1539997200, 58146323, 24
            tz.transition 1921, 6, :o2, -1531443600, 58148699, 24
            tz.transition 1939, 9, :o3, -956365200, 58308443, 24
            tz.transition 1939, 11, :o2, -950486400, 4859173, 2
            tz.transition 1940, 2, :o4, -942012000, 29156215, 12
            tz.transition 1944, 4, :o5, -812502000, 58348405, 24
            tz.transition 1944, 10, :o4, -796262400, 4862743, 2
            tz.transition 1945, 4, :o5, -781052400, 58357141, 24
            tz.transition 1945, 9, :o4, -766630800, 58361147, 24
            tz.transition 1946, 10, :o2, -733280400, 58370411, 24
            tz.transition 1956, 1, :o4, -439430400, 4871003, 2
            tz.transition 1963, 4, :o2, -212029200, 58515203, 24
            tz.transition 1971, 4, :o3, 41468400
            tz.transition 1971, 9, :o2, 54774000
            tz.transition 1977, 5, :o3, 231724800
            tz.transition 1977, 10, :o4, 246236400
            tz.transition 1978, 3, :o5, 259545600
            tz.transition 1978, 9, :o4, 275274000
            tz.transition 1979, 10, :o2, 309740400
            tz.transition 1980, 4, :o3, 325468800
            tz.transition 1980, 10, :o2, 341802000
            tz.transition 1981, 5, :o4, 357523200
          end
        end
      end
    end
  end
end
