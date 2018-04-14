# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module Palmer
          include TimezoneDefinition
          
          timezone 'Antarctica/Palmer' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, -14400, 3600, :'-03'
            tz.offset :o2, -14400, 0, :'-04'
            tz.offset :o3, -10800, 0, :'-03'
            tz.offset :o4, -10800, 3600, :'-02'
            
            tz.transition 1965, 1, :o1, -157766400, 4877523, 2
            tz.transition 1965, 3, :o2, -152658000, 19510565, 8
            tz.transition 1965, 10, :o1, -132955200, 7317146, 3
            tz.transition 1966, 3, :o2, -121122000, 19513485, 8
            tz.transition 1966, 10, :o1, -101419200, 7318241, 3
            tz.transition 1967, 4, :o2, -86821200, 19516661, 8
            tz.transition 1967, 10, :o1, -71092800, 7319294, 3
            tz.transition 1968, 4, :o2, -54766800, 19519629, 8
            tz.transition 1968, 10, :o1, -39038400, 7320407, 3
            tz.transition 1969, 4, :o2, -23317200, 19522541, 8
            tz.transition 1969, 10, :o3, -7588800, 7321499, 3
            tz.transition 1974, 1, :o4, 128142000
            tz.transition 1974, 5, :o3, 136605600
            tz.transition 1982, 5, :o2, 389070000
            tz.transition 1982, 10, :o1, 403070400
            tz.transition 1983, 3, :o2, 416372400
            tz.transition 1983, 10, :o1, 434520000
            tz.transition 1984, 3, :o2, 447822000
            tz.transition 1984, 10, :o1, 466574400
            tz.transition 1985, 3, :o2, 479271600
            tz.transition 1985, 10, :o1, 498024000
            tz.transition 1986, 3, :o2, 510721200
            tz.transition 1986, 10, :o1, 529473600
            tz.transition 1987, 4, :o2, 545194800
            tz.transition 1987, 10, :o1, 560923200
            tz.transition 1988, 3, :o2, 574225200
            tz.transition 1988, 10, :o1, 592372800
            tz.transition 1989, 3, :o2, 605674800
            tz.transition 1989, 10, :o1, 624427200
            tz.transition 1990, 3, :o2, 637124400
            tz.transition 1990, 9, :o1, 653457600
            tz.transition 1991, 3, :o2, 668574000
            tz.transition 1991, 10, :o1, 687326400
            tz.transition 1992, 3, :o2, 700628400
            tz.transition 1992, 10, :o1, 718776000
            tz.transition 1993, 3, :o2, 732078000
            tz.transition 1993, 10, :o1, 750225600
            tz.transition 1994, 3, :o2, 763527600
            tz.transition 1994, 10, :o1, 781675200
            tz.transition 1995, 3, :o2, 794977200
            tz.transition 1995, 10, :o1, 813729600
            tz.transition 1996, 3, :o2, 826426800
            tz.transition 1996, 10, :o1, 845179200
            tz.transition 1997, 3, :o2, 859690800
            tz.transition 1997, 10, :o1, 876628800
            tz.transition 1998, 3, :o2, 889930800
            tz.transition 1998, 9, :o1, 906868800
            tz.transition 1999, 4, :o2, 923194800
            tz.transition 1999, 10, :o1, 939528000
            tz.transition 2000, 3, :o2, 952830000
            tz.transition 2000, 10, :o1, 971582400
            tz.transition 2001, 3, :o2, 984279600
            tz.transition 2001, 10, :o1, 1003032000
            tz.transition 2002, 3, :o2, 1015729200
            tz.transition 2002, 10, :o1, 1034481600
            tz.transition 2003, 3, :o2, 1047178800
            tz.transition 2003, 10, :o1, 1065931200
            tz.transition 2004, 3, :o2, 1079233200
            tz.transition 2004, 10, :o1, 1097380800
            tz.transition 2005, 3, :o2, 1110682800
            tz.transition 2005, 10, :o1, 1128830400
            tz.transition 2006, 3, :o2, 1142132400
            tz.transition 2006, 10, :o1, 1160884800
            tz.transition 2007, 3, :o2, 1173582000
            tz.transition 2007, 10, :o1, 1192334400
            tz.transition 2008, 3, :o2, 1206846000
            tz.transition 2008, 10, :o1, 1223784000
            tz.transition 2009, 3, :o2, 1237086000
            tz.transition 2009, 10, :o1, 1255233600
            tz.transition 2010, 4, :o2, 1270350000
            tz.transition 2010, 10, :o1, 1286683200
            tz.transition 2011, 5, :o2, 1304823600
            tz.transition 2011, 8, :o1, 1313899200
            tz.transition 2012, 4, :o2, 1335668400
            tz.transition 2012, 9, :o1, 1346558400
            tz.transition 2013, 4, :o2, 1367118000
            tz.transition 2013, 9, :o1, 1378612800
            tz.transition 2014, 4, :o2, 1398567600
            tz.transition 2014, 9, :o1, 1410062400
            tz.transition 2016, 5, :o2, 1463281200
            tz.transition 2016, 8, :o1, 1471147200
            tz.transition 2016, 12, :o3, 1480820400
          end
        end
      end
    end
  end
end
