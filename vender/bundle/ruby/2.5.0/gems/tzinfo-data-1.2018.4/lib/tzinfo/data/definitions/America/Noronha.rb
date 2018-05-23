# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Noronha
          include TimezoneDefinition
          
          timezone 'America/Noronha' do |tz|
            tz.offset :o0, -7780, 0, :LMT
            tz.offset :o1, -7200, 0, :'-02'
            tz.offset :o2, -7200, 3600, :'-01'
            
            tz.transition 1914, 1, :o1, -1767217820, 10454977109, 4320
            tz.transition 1931, 10, :o2, -1206961200, 58238833, 24
            tz.transition 1932, 4, :o1, -1191366000, 58243165, 24
            tz.transition 1932, 10, :o2, -1175378400, 29123803, 12
            tz.transition 1933, 4, :o1, -1159830000, 58251925, 24
            tz.transition 1949, 12, :o2, -633823200, 29199019, 12
            tz.transition 1950, 4, :o1, -622072800, 29200651, 12
            tz.transition 1950, 12, :o2, -602287200, 29203399, 12
            tz.transition 1951, 4, :o1, -591836400, 58409701, 24
            tz.transition 1951, 12, :o2, -570751200, 29207779, 12
            tz.transition 1952, 4, :o1, -560214000, 58418485, 24
            tz.transition 1952, 12, :o2, -539128800, 29212171, 12
            tz.transition 1953, 3, :o1, -531356400, 58426501, 24
            tz.transition 1963, 12, :o2, -191368800, 29260471, 12
            tz.transition 1964, 3, :o1, -184201200, 58522933, 24
            tz.transition 1965, 1, :o2, -155167200, 29265499, 12
            tz.transition 1965, 3, :o1, -150073200, 58532413, 24
            tz.transition 1965, 12, :o2, -128901600, 29269147, 12
            tz.transition 1966, 3, :o1, -121129200, 58540453, 24
            tz.transition 1966, 11, :o2, -99957600, 29273167, 12
            tz.transition 1967, 3, :o1, -89593200, 58549213, 24
            tz.transition 1967, 11, :o2, -68421600, 29277547, 12
            tz.transition 1968, 3, :o1, -57970800, 58557997, 24
            tz.transition 1985, 11, :o2, 499744800
            tz.transition 1986, 3, :o1, 511232400
            tz.transition 1986, 10, :o2, 530589600
            tz.transition 1987, 2, :o1, 540262800
            tz.transition 1987, 10, :o2, 562125600
            tz.transition 1988, 2, :o1, 571194000
            tz.transition 1988, 10, :o2, 592970400
            tz.transition 1989, 1, :o1, 602038800
            tz.transition 1989, 10, :o2, 624420000
            tz.transition 1990, 2, :o1, 634698000
            tz.transition 1999, 10, :o2, 938916000
            tz.transition 2000, 2, :o1, 951613200
            tz.transition 2000, 10, :o2, 970970400
            tz.transition 2000, 10, :o1, 971571600
            tz.transition 2001, 10, :o2, 1003024800
            tz.transition 2002, 2, :o1, 1013907600
          end
        end
      end
    end
  end
end
