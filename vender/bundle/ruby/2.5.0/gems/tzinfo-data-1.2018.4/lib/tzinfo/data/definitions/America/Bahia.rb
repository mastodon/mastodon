# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Bahia
          include TimezoneDefinition
          
          timezone 'America/Bahia' do |tz|
            tz.offset :o0, -9244, 0, :LMT
            tz.offset :o1, -10800, 0, :'-03'
            tz.offset :o2, -10800, 3600, :'-02'
            
            tz.transition 1914, 1, :o1, -1767216356, 52274885911, 21600
            tz.transition 1931, 10, :o2, -1206957600, 29119417, 12
            tz.transition 1932, 4, :o1, -1191362400, 29121583, 12
            tz.transition 1932, 10, :o2, -1175374800, 19415869, 8
            tz.transition 1933, 4, :o1, -1159826400, 29125963, 12
            tz.transition 1949, 12, :o2, -633819600, 19466013, 8
            tz.transition 1950, 4, :o1, -622069200, 19467101, 8
            tz.transition 1950, 12, :o2, -602283600, 19468933, 8
            tz.transition 1951, 4, :o1, -591832800, 29204851, 12
            tz.transition 1951, 12, :o2, -570747600, 19471853, 8
            tz.transition 1952, 4, :o1, -560210400, 29209243, 12
            tz.transition 1952, 12, :o2, -539125200, 19474781, 8
            tz.transition 1953, 3, :o1, -531352800, 29213251, 12
            tz.transition 1963, 12, :o2, -191365200, 19506981, 8
            tz.transition 1964, 3, :o1, -184197600, 29261467, 12
            tz.transition 1965, 1, :o2, -155163600, 19510333, 8
            tz.transition 1965, 3, :o1, -150069600, 29266207, 12
            tz.transition 1965, 12, :o2, -128898000, 19512765, 8
            tz.transition 1966, 3, :o1, -121125600, 29270227, 12
            tz.transition 1966, 11, :o2, -99954000, 19515445, 8
            tz.transition 1967, 3, :o1, -89589600, 29274607, 12
            tz.transition 1967, 11, :o2, -68418000, 19518365, 8
            tz.transition 1968, 3, :o1, -57967200, 29278999, 12
            tz.transition 1985, 11, :o2, 499748400
            tz.transition 1986, 3, :o1, 511236000
            tz.transition 1986, 10, :o2, 530593200
            tz.transition 1987, 2, :o1, 540266400
            tz.transition 1987, 10, :o2, 562129200
            tz.transition 1988, 2, :o1, 571197600
            tz.transition 1988, 10, :o2, 592974000
            tz.transition 1989, 1, :o1, 602042400
            tz.transition 1989, 10, :o2, 624423600
            tz.transition 1990, 2, :o1, 634701600
            tz.transition 1990, 10, :o2, 656478000
            tz.transition 1991, 2, :o1, 666756000
            tz.transition 1991, 10, :o2, 687927600
            tz.transition 1992, 2, :o1, 697600800
            tz.transition 1992, 10, :o2, 719982000
            tz.transition 1993, 1, :o1, 728445600
            tz.transition 1993, 10, :o2, 750826800
            tz.transition 1994, 2, :o1, 761709600
            tz.transition 1994, 10, :o2, 782276400
            tz.transition 1995, 2, :o1, 793159200
            tz.transition 1995, 10, :o2, 813726000
            tz.transition 1996, 2, :o1, 824004000
            tz.transition 1996, 10, :o2, 844570800
            tz.transition 1997, 2, :o1, 856058400
            tz.transition 1997, 10, :o2, 876106800
            tz.transition 1998, 3, :o1, 888717600
            tz.transition 1998, 10, :o2, 908074800
            tz.transition 1999, 2, :o1, 919562400
            tz.transition 1999, 10, :o2, 938919600
            tz.transition 2000, 2, :o1, 951616800
            tz.transition 2000, 10, :o2, 970974000
            tz.transition 2001, 2, :o1, 982461600
            tz.transition 2001, 10, :o2, 1003028400
            tz.transition 2002, 2, :o1, 1013911200
            tz.transition 2002, 11, :o2, 1036292400
            tz.transition 2003, 2, :o1, 1045360800
            tz.transition 2011, 10, :o2, 1318734000
            tz.transition 2012, 2, :o1, 1330221600
          end
        end
      end
    end
  end
end
