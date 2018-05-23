# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Dawson_Creek
          include TimezoneDefinition
          
          timezone 'America/Dawson_Creek' do |tz|
            tz.offset :o0, -28856, 0, :LMT
            tz.offset :o1, -28800, 0, :PST
            tz.offset :o2, -28800, 3600, :PDT
            tz.offset :o3, -28800, 3600, :PWT
            tz.offset :o4, -28800, 3600, :PPT
            tz.offset :o5, -25200, 0, :MST
            
            tz.transition 1884, 1, :o1, -2713881544, 26019109807, 10800
            tz.transition 1918, 4, :o2, -1632060000, 29060375, 12
            tz.transition 1918, 10, :o1, -1615129200, 19375151, 8
            tz.transition 1942, 2, :o3, -880207200, 29164799, 12
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765385200, 19453831, 8
            tz.transition 1947, 4, :o2, -715788000, 29187635, 12
            tz.transition 1947, 9, :o1, -702486000, 19459655, 8
            tz.transition 1948, 4, :o2, -684338400, 29192003, 12
            tz.transition 1948, 9, :o1, -671036400, 19462567, 8
            tz.transition 1949, 4, :o2, -652888800, 29196371, 12
            tz.transition 1949, 9, :o1, -639586800, 19465479, 8
            tz.transition 1950, 4, :o2, -620834400, 29200823, 12
            tz.transition 1950, 9, :o1, -608137200, 19468391, 8
            tz.transition 1951, 4, :o2, -589384800, 29205191, 12
            tz.transition 1951, 9, :o1, -576082800, 19471359, 8
            tz.transition 1952, 4, :o2, -557935200, 29209559, 12
            tz.transition 1952, 9, :o1, -544633200, 19474271, 8
            tz.transition 1953, 4, :o2, -526485600, 29213927, 12
            tz.transition 1953, 9, :o1, -513183600, 19477183, 8
            tz.transition 1954, 4, :o2, -495036000, 29218295, 12
            tz.transition 1954, 9, :o1, -481734000, 19480095, 8
            tz.transition 1955, 4, :o2, -463586400, 29222663, 12
            tz.transition 1955, 9, :o1, -450284400, 19483007, 8
            tz.transition 1956, 4, :o2, -431532000, 29227115, 12
            tz.transition 1956, 9, :o1, -418230000, 19485975, 8
            tz.transition 1957, 4, :o2, -400082400, 29231483, 12
            tz.transition 1957, 9, :o1, -386780400, 19488887, 8
            tz.transition 1958, 4, :o2, -368632800, 29235851, 12
            tz.transition 1958, 9, :o1, -355330800, 19491799, 8
            tz.transition 1959, 4, :o2, -337183200, 29240219, 12
            tz.transition 1959, 9, :o1, -323881200, 19494711, 8
            tz.transition 1960, 4, :o2, -305733600, 29244587, 12
            tz.transition 1960, 9, :o1, -292431600, 19497623, 8
            tz.transition 1961, 4, :o2, -273679200, 29249039, 12
            tz.transition 1961, 9, :o1, -260982000, 19500535, 8
            tz.transition 1962, 4, :o2, -242229600, 29253407, 12
            tz.transition 1962, 10, :o1, -226508400, 19503727, 8
            tz.transition 1963, 4, :o2, -210780000, 29257775, 12
            tz.transition 1963, 10, :o1, -195058800, 19506639, 8
            tz.transition 1964, 4, :o2, -179330400, 29262143, 12
            tz.transition 1964, 10, :o1, -163609200, 19509551, 8
            tz.transition 1965, 4, :o2, -147880800, 29266511, 12
            tz.transition 1965, 10, :o1, -131554800, 19512519, 8
            tz.transition 1966, 4, :o2, -116431200, 29270879, 12
            tz.transition 1966, 10, :o1, -100105200, 19515431, 8
            tz.transition 1967, 4, :o2, -84376800, 29275331, 12
            tz.transition 1967, 10, :o1, -68655600, 19518343, 8
            tz.transition 1968, 4, :o2, -52927200, 29279699, 12
            tz.transition 1968, 10, :o1, -37206000, 19521255, 8
            tz.transition 1969, 4, :o2, -21477600, 29284067, 12
            tz.transition 1969, 10, :o1, -5756400, 19524167, 8
            tz.transition 1970, 4, :o2, 9972000
            tz.transition 1970, 10, :o1, 25693200
            tz.transition 1971, 4, :o2, 41421600
            tz.transition 1971, 10, :o1, 57747600
            tz.transition 1972, 4, :o2, 73476000
            tz.transition 1972, 8, :o5, 84013200
          end
        end
      end
    end
  end
end
