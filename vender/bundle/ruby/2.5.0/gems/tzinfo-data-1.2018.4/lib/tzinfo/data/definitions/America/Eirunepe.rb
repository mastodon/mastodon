# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Eirunepe
          include TimezoneDefinition
          
          timezone 'America/Eirunepe' do |tz|
            tz.offset :o0, -16768, 0, :LMT
            tz.offset :o1, -18000, 0, :'-05'
            tz.offset :o2, -18000, 3600, :'-04'
            tz.offset :o3, -14400, 0, :'-04'
            
            tz.transition 1914, 1, :o1, -1767208832, 3267180487, 1350
            tz.transition 1931, 10, :o2, -1206950400, 14559709, 6
            tz.transition 1932, 4, :o1, -1191355200, 7280396, 3
            tz.transition 1932, 10, :o2, -1175367600, 58247609, 24
            tz.transition 1933, 4, :o1, -1159819200, 7281491, 3
            tz.transition 1949, 12, :o2, -633812400, 58398041, 24
            tz.transition 1950, 4, :o1, -622062000, 58401305, 24
            tz.transition 1950, 12, :o2, -602276400, 58406801, 24
            tz.transition 1951, 4, :o1, -591825600, 7301213, 3
            tz.transition 1951, 12, :o2, -570740400, 58415561, 24
            tz.transition 1952, 4, :o1, -560203200, 7302311, 3
            tz.transition 1952, 12, :o2, -539118000, 58424345, 24
            tz.transition 1953, 3, :o1, -531345600, 7303313, 3
            tz.transition 1963, 12, :o2, -191358000, 58520945, 24
            tz.transition 1964, 3, :o1, -184190400, 7315367, 3
            tz.transition 1965, 1, :o2, -155156400, 58531001, 24
            tz.transition 1965, 3, :o1, -150062400, 7316552, 3
            tz.transition 1965, 12, :o2, -128890800, 58538297, 24
            tz.transition 1966, 3, :o1, -121118400, 7317557, 3
            tz.transition 1966, 11, :o2, -99946800, 58546337, 24
            tz.transition 1967, 3, :o1, -89582400, 7318652, 3
            tz.transition 1967, 11, :o2, -68410800, 58555097, 24
            tz.transition 1968, 3, :o1, -57960000, 7319750, 3
            tz.transition 1985, 11, :o2, 499755600
            tz.transition 1986, 3, :o1, 511243200
            tz.transition 1986, 10, :o2, 530600400
            tz.transition 1987, 2, :o1, 540273600
            tz.transition 1987, 10, :o2, 562136400
            tz.transition 1988, 2, :o1, 571204800
            tz.transition 1993, 10, :o2, 750834000
            tz.transition 1994, 2, :o1, 761716800
            tz.transition 2008, 6, :o3, 1214283600
            tz.transition 2013, 11, :o1, 1384056000
          end
        end
      end
    end
  end
end
