# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Punta_Arenas
          include TimezoneDefinition
          
          timezone 'America/Punta_Arenas' do |tz|
            tz.offset :o0, -17020, 0, :LMT
            tz.offset :o1, -16966, 0, :SMT
            tz.offset :o2, -18000, 0, :'-05'
            tz.offset :o3, -14400, 0, :'-04'
            tz.offset :o4, -18000, 3600, :'-04'
            tz.offset :o5, -14400, 3600, :'-03'
            tz.offset :o6, -10800, 0, :'-03'
            
            tz.transition 1890, 1, :o1, -2524504580, 10417112771, 4320
            tz.transition 1910, 1, :o2, -1892661434, 104487049283, 43200
            tz.transition 1916, 7, :o1, -1688410800, 58105097, 24
            tz.transition 1918, 9, :o3, -1619205434, 104623777283, 43200
            tz.transition 1919, 7, :o1, -1593806400, 7266422, 3
            tz.transition 1927, 9, :o4, -1335986234, 104765386883, 43200
            tz.transition 1928, 4, :o2, -1317585600, 7276013, 3
            tz.transition 1928, 9, :o4, -1304362800, 58211777, 24
            tz.transition 1929, 4, :o2, -1286049600, 7277108, 3
            tz.transition 1929, 9, :o4, -1272826800, 58220537, 24
            tz.transition 1930, 4, :o2, -1254513600, 7278203, 3
            tz.transition 1930, 9, :o4, -1241290800, 58229297, 24
            tz.transition 1931, 4, :o2, -1222977600, 7279298, 3
            tz.transition 1931, 9, :o4, -1209754800, 58238057, 24
            tz.transition 1932, 4, :o2, -1191355200, 7280396, 3
            tz.transition 1932, 9, :o3, -1178132400, 58246841, 24
            tz.transition 1942, 6, :o2, -870552000, 7291535, 3
            tz.transition 1942, 8, :o3, -865278000, 58333745, 24
            tz.transition 1947, 4, :o2, -718056000, 7296830, 3
            tz.transition 1947, 5, :o3, -713649600, 7296983, 3
            tz.transition 1968, 11, :o5, -36619200, 7320491, 3
            tz.transition 1969, 3, :o3, -23922000, 19522485, 8
            tz.transition 1969, 11, :o5, -3355200, 7321646, 3
            tz.transition 1970, 3, :o3, 7527600
            tz.transition 1970, 10, :o5, 24465600
            tz.transition 1971, 3, :o3, 37767600
            tz.transition 1971, 10, :o5, 55915200
            tz.transition 1972, 3, :o3, 69217200
            tz.transition 1972, 10, :o5, 87969600
            tz.transition 1973, 3, :o3, 100666800
            tz.transition 1973, 9, :o5, 118209600
            tz.transition 1974, 3, :o3, 132116400
            tz.transition 1974, 10, :o5, 150868800
            tz.transition 1975, 3, :o3, 163566000
            tz.transition 1975, 10, :o5, 182318400
            tz.transition 1976, 3, :o3, 195620400
            tz.transition 1976, 10, :o5, 213768000
            tz.transition 1977, 3, :o3, 227070000
            tz.transition 1977, 10, :o5, 245217600
            tz.transition 1978, 3, :o3, 258519600
            tz.transition 1978, 10, :o5, 277272000
            tz.transition 1979, 3, :o3, 289969200
            tz.transition 1979, 10, :o5, 308721600
            tz.transition 1980, 3, :o3, 321418800
            tz.transition 1980, 10, :o5, 340171200
            tz.transition 1981, 3, :o3, 353473200
            tz.transition 1981, 10, :o5, 371620800
            tz.transition 1982, 3, :o3, 384922800
            tz.transition 1982, 10, :o5, 403070400
            tz.transition 1983, 3, :o3, 416372400
            tz.transition 1983, 10, :o5, 434520000
            tz.transition 1984, 3, :o3, 447822000
            tz.transition 1984, 10, :o5, 466574400
            tz.transition 1985, 3, :o3, 479271600
            tz.transition 1985, 10, :o5, 498024000
            tz.transition 1986, 3, :o3, 510721200
            tz.transition 1986, 10, :o5, 529473600
            tz.transition 1987, 4, :o3, 545194800
            tz.transition 1987, 10, :o5, 560923200
            tz.transition 1988, 3, :o3, 574225200
            tz.transition 1988, 10, :o5, 592372800
            tz.transition 1989, 3, :o3, 605674800
            tz.transition 1989, 10, :o5, 624427200
            tz.transition 1990, 3, :o3, 637124400
            tz.transition 1990, 9, :o5, 653457600
            tz.transition 1991, 3, :o3, 668574000
            tz.transition 1991, 10, :o5, 687326400
            tz.transition 1992, 3, :o3, 700628400
            tz.transition 1992, 10, :o5, 718776000
            tz.transition 1993, 3, :o3, 732078000
            tz.transition 1993, 10, :o5, 750225600
            tz.transition 1994, 3, :o3, 763527600
            tz.transition 1994, 10, :o5, 781675200
            tz.transition 1995, 3, :o3, 794977200
            tz.transition 1995, 10, :o5, 813729600
            tz.transition 1996, 3, :o3, 826426800
            tz.transition 1996, 10, :o5, 845179200
            tz.transition 1997, 3, :o3, 859690800
            tz.transition 1997, 10, :o5, 876628800
            tz.transition 1998, 3, :o3, 889930800
            tz.transition 1998, 9, :o5, 906868800
            tz.transition 1999, 4, :o3, 923194800
            tz.transition 1999, 10, :o5, 939528000
            tz.transition 2000, 3, :o3, 952830000
            tz.transition 2000, 10, :o5, 971582400
            tz.transition 2001, 3, :o3, 984279600
            tz.transition 2001, 10, :o5, 1003032000
            tz.transition 2002, 3, :o3, 1015729200
            tz.transition 2002, 10, :o5, 1034481600
            tz.transition 2003, 3, :o3, 1047178800
            tz.transition 2003, 10, :o5, 1065931200
            tz.transition 2004, 3, :o3, 1079233200
            tz.transition 2004, 10, :o5, 1097380800
            tz.transition 2005, 3, :o3, 1110682800
            tz.transition 2005, 10, :o5, 1128830400
            tz.transition 2006, 3, :o3, 1142132400
            tz.transition 2006, 10, :o5, 1160884800
            tz.transition 2007, 3, :o3, 1173582000
            tz.transition 2007, 10, :o5, 1192334400
            tz.transition 2008, 3, :o3, 1206846000
            tz.transition 2008, 10, :o5, 1223784000
            tz.transition 2009, 3, :o3, 1237086000
            tz.transition 2009, 10, :o5, 1255233600
            tz.transition 2010, 4, :o3, 1270350000
            tz.transition 2010, 10, :o5, 1286683200
            tz.transition 2011, 5, :o3, 1304823600
            tz.transition 2011, 8, :o5, 1313899200
            tz.transition 2012, 4, :o3, 1335668400
            tz.transition 2012, 9, :o5, 1346558400
            tz.transition 2013, 4, :o3, 1367118000
            tz.transition 2013, 9, :o5, 1378612800
            tz.transition 2014, 4, :o3, 1398567600
            tz.transition 2014, 9, :o5, 1410062400
            tz.transition 2016, 5, :o3, 1463281200
            tz.transition 2016, 8, :o5, 1471147200
            tz.transition 2016, 12, :o6, 1480820400
          end
        end
      end
    end
  end
end
