# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Belem
          include TimezoneDefinition
          
          timezone 'America/Belem' do |tz|
            tz.offset :o0, -11636, 0, :LMT
            tz.offset :o1, -10800, 0, :'-03'
            tz.offset :o2, -10800, 3600, :'-02'
            
            tz.transition 1914, 1, :o1, -1767213964, 52274886509, 21600
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
          end
        end
      end
    end
  end
end
