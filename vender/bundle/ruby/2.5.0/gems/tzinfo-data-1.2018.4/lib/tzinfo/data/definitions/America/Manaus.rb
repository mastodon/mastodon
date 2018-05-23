# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Manaus
          include TimezoneDefinition
          
          timezone 'America/Manaus' do |tz|
            tz.offset :o0, -14404, 0, :LMT
            tz.offset :o1, -14400, 0, :'-04'
            tz.offset :o2, -14400, 3600, :'-03'
            
            tz.transition 1914, 1, :o1, -1767211196, 52274887201, 21600
            tz.transition 1931, 10, :o2, -1206954000, 19412945, 8
            tz.transition 1932, 4, :o1, -1191358800, 19414389, 8
            tz.transition 1932, 10, :o2, -1175371200, 7280951, 3
            tz.transition 1933, 4, :o1, -1159822800, 19417309, 8
            tz.transition 1949, 12, :o2, -633816000, 7299755, 3
            tz.transition 1950, 4, :o1, -622065600, 7300163, 3
            tz.transition 1950, 12, :o2, -602280000, 7300850, 3
            tz.transition 1951, 4, :o1, -591829200, 19469901, 8
            tz.transition 1951, 12, :o2, -570744000, 7301945, 3
            tz.transition 1952, 4, :o1, -560206800, 19472829, 8
            tz.transition 1952, 12, :o2, -539121600, 7303043, 3
            tz.transition 1953, 3, :o1, -531349200, 19475501, 8
            tz.transition 1963, 12, :o2, -191361600, 7315118, 3
            tz.transition 1964, 3, :o1, -184194000, 19507645, 8
            tz.transition 1965, 1, :o2, -155160000, 7316375, 3
            tz.transition 1965, 3, :o1, -150066000, 19510805, 8
            tz.transition 1965, 12, :o2, -128894400, 7317287, 3
            tz.transition 1966, 3, :o1, -121122000, 19513485, 8
            tz.transition 1966, 11, :o2, -99950400, 7318292, 3
            tz.transition 1967, 3, :o1, -89586000, 19516405, 8
            tz.transition 1967, 11, :o2, -68414400, 7319387, 3
            tz.transition 1968, 3, :o1, -57963600, 19519333, 8
            tz.transition 1985, 11, :o2, 499752000
            tz.transition 1986, 3, :o1, 511239600
            tz.transition 1986, 10, :o2, 530596800
            tz.transition 1987, 2, :o1, 540270000
            tz.transition 1987, 10, :o2, 562132800
            tz.transition 1988, 2, :o1, 571201200
            tz.transition 1993, 10, :o2, 750830400
            tz.transition 1994, 2, :o1, 761713200
          end
        end
      end
    end
  end
end
