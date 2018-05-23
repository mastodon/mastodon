# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Atlantic
        module Reykjavik
          include TimezoneDefinition
          
          timezone 'Atlantic/Reykjavik' do |tz|
            tz.offset :o0, -5280, 0, :LMT
            tz.offset :o1, -3600, 0, :'-01'
            tz.offset :o2, -3600, 3600, :'+00'
            tz.offset :o3, 0, 0, :GMT
            
            tz.transition 1908, 1, :o1, -1956609120, 435229481, 180
            tz.transition 1917, 2, :o2, -1668211200, 4842559, 2
            tz.transition 1917, 10, :o1, -1647212400, 58116541, 24
            tz.transition 1918, 2, :o2, -1636675200, 4843289, 2
            tz.transition 1918, 11, :o1, -1613430000, 58125925, 24
            tz.transition 1919, 2, :o2, -1605139200, 4844019, 2
            tz.transition 1919, 11, :o1, -1581894000, 58134685, 24
            tz.transition 1921, 3, :o2, -1539561600, 4845537, 2
            tz.transition 1921, 6, :o1, -1531350000, 58148725, 24
            tz.transition 1939, 4, :o2, -968025600, 4858767, 2
            tz.transition 1939, 10, :o1, -952293600, 29154787, 12
            tz.transition 1940, 2, :o2, -942008400, 19437477, 8
            tz.transition 1940, 11, :o1, -920239200, 29159239, 12
            tz.transition 1941, 3, :o2, -909957600, 29160667, 12
            tz.transition 1941, 11, :o1, -888789600, 29163607, 12
            tz.transition 1942, 3, :o2, -877903200, 29165119, 12
            tz.transition 1942, 10, :o1, -857944800, 29167891, 12
            tz.transition 1943, 3, :o2, -846453600, 29169487, 12
            tz.transition 1943, 10, :o1, -826495200, 29172259, 12
            tz.transition 1944, 3, :o2, -815004000, 29173855, 12
            tz.transition 1944, 10, :o1, -795045600, 29176627, 12
            tz.transition 1945, 3, :o2, -783554400, 29178223, 12
            tz.transition 1945, 10, :o1, -762991200, 29181079, 12
            tz.transition 1946, 3, :o2, -752104800, 29182591, 12
            tz.transition 1946, 10, :o1, -731541600, 29185447, 12
            tz.transition 1947, 4, :o2, -717631200, 29187379, 12
            tz.transition 1947, 10, :o1, -700092000, 29189815, 12
            tz.transition 1948, 4, :o2, -686181600, 29191747, 12
            tz.transition 1948, 10, :o1, -668642400, 29194183, 12
            tz.transition 1949, 4, :o2, -654732000, 29196115, 12
            tz.transition 1949, 10, :o1, -636588000, 29198635, 12
            tz.transition 1950, 4, :o2, -623282400, 29200483, 12
            tz.transition 1950, 10, :o1, -605743200, 29202919, 12
            tz.transition 1951, 4, :o2, -591832800, 29204851, 12
            tz.transition 1951, 10, :o1, -573688800, 29207371, 12
            tz.transition 1952, 4, :o2, -559778400, 29209303, 12
            tz.transition 1952, 10, :o1, -542239200, 29211739, 12
            tz.transition 1953, 4, :o2, -528328800, 29213671, 12
            tz.transition 1953, 10, :o1, -510789600, 29216107, 12
            tz.transition 1954, 4, :o2, -496879200, 29218039, 12
            tz.transition 1954, 10, :o1, -479340000, 29220475, 12
            tz.transition 1955, 4, :o2, -465429600, 29222407, 12
            tz.transition 1955, 10, :o1, -447890400, 29224843, 12
            tz.transition 1956, 4, :o2, -433980000, 29226775, 12
            tz.transition 1956, 10, :o1, -415836000, 29229295, 12
            tz.transition 1957, 4, :o2, -401925600, 29231227, 12
            tz.transition 1957, 10, :o1, -384386400, 29233663, 12
            tz.transition 1958, 4, :o2, -370476000, 29235595, 12
            tz.transition 1958, 10, :o1, -352936800, 29238031, 12
            tz.transition 1959, 4, :o2, -339026400, 29239963, 12
            tz.transition 1959, 10, :o1, -321487200, 29242399, 12
            tz.transition 1960, 4, :o2, -307576800, 29244331, 12
            tz.transition 1960, 10, :o1, -290037600, 29246767, 12
            tz.transition 1961, 4, :o2, -276127200, 29248699, 12
            tz.transition 1961, 10, :o1, -258588000, 29251135, 12
            tz.transition 1962, 4, :o2, -244677600, 29253067, 12
            tz.transition 1962, 10, :o1, -226533600, 29255587, 12
            tz.transition 1963, 4, :o2, -212623200, 29257519, 12
            tz.transition 1963, 10, :o1, -195084000, 29259955, 12
            tz.transition 1964, 4, :o2, -181173600, 29261887, 12
            tz.transition 1964, 10, :o1, -163634400, 29264323, 12
            tz.transition 1965, 4, :o2, -149724000, 29266255, 12
            tz.transition 1965, 10, :o1, -132184800, 29268691, 12
            tz.transition 1966, 4, :o2, -118274400, 29270623, 12
            tz.transition 1966, 10, :o1, -100735200, 29273059, 12
            tz.transition 1967, 4, :o2, -86824800, 29274991, 12
            tz.transition 1967, 10, :o1, -68680800, 29277511, 12
            tz.transition 1968, 4, :o3, -54770400, 29279443, 12
          end
        end
      end
    end
  end
end
