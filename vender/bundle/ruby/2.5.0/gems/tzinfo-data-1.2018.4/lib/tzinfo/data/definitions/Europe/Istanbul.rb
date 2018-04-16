# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Istanbul
          include TimezoneDefinition
          
          timezone 'Europe/Istanbul' do |tz|
            tz.offset :o0, 6952, 0, :LMT
            tz.offset :o1, 7016, 0, :IMT
            tz.offset :o2, 7200, 0, :EET
            tz.offset :o3, 7200, 3600, :EEST
            tz.offset :o4, 10800, 3600, :'+04'
            tz.offset :o5, 10800, 0, :'+03'
            
            tz.transition 1879, 12, :o1, -2840147752, 26003326531, 10800
            tz.transition 1910, 9, :o2, -1869875816, 26124610523, 10800
            tz.transition 1916, 4, :o3, -1693706400, 29051813, 12
            tz.transition 1916, 9, :o2, -1680490800, 19369099, 8
            tz.transition 1920, 3, :o3, -1570413600, 29068937, 12
            tz.transition 1920, 10, :o2, -1552186800, 19380979, 8
            tz.transition 1921, 4, :o3, -1538359200, 29073389, 12
            tz.transition 1921, 10, :o2, -1522551600, 19383723, 8
            tz.transition 1922, 3, :o3, -1507514400, 29077673, 12
            tz.transition 1922, 10, :o2, -1490583600, 19386683, 8
            tz.transition 1924, 5, :o3, -1440208800, 29087021, 12
            tz.transition 1924, 9, :o2, -1428030000, 19392475, 8
            tz.transition 1925, 4, :o3, -1409709600, 29091257, 12
            tz.transition 1925, 9, :o2, -1396494000, 19395395, 8
            tz.transition 1940, 6, :o3, -931140000, 29157725, 12
            tz.transition 1940, 10, :o2, -922762800, 19439259, 8
            tz.transition 1940, 11, :o3, -917834400, 29159573, 12
            tz.transition 1941, 9, :o2, -892436400, 19442067, 8
            tz.transition 1942, 3, :o3, -875844000, 29165405, 12
            tz.transition 1942, 10, :o2, -857358000, 19445315, 8
            tz.transition 1945, 4, :o3, -781063200, 29178569, 12
            tz.transition 1945, 10, :o2, -764737200, 19453891, 8
            tz.transition 1946, 5, :o3, -744343200, 29183669, 12
            tz.transition 1946, 9, :o2, -733806000, 19456755, 8
            tz.transition 1947, 4, :o3, -716436000, 29187545, 12
            tz.transition 1947, 10, :o2, -701924400, 19459707, 8
            tz.transition 1948, 4, :o3, -684986400, 29191913, 12
            tz.transition 1948, 10, :o2, -670474800, 19462619, 8
            tz.transition 1949, 4, :o3, -654141600, 29196197, 12
            tz.transition 1949, 10, :o2, -639025200, 19465531, 8
            tz.transition 1950, 4, :o3, -621828000, 29200685, 12
            tz.transition 1950, 10, :o2, -606970800, 19468499, 8
            tz.transition 1951, 4, :o3, -590032800, 29205101, 12
            tz.transition 1951, 10, :o2, -575434800, 19471419, 8
            tz.transition 1962, 7, :o3, -235620000, 29254325, 12
            tz.transition 1962, 10, :o2, -228279600, 19503563, 8
            tz.transition 1964, 5, :o3, -177732000, 29262365, 12
            tz.transition 1964, 9, :o2, -165726000, 19509355, 8
            tz.transition 1970, 5, :o3, 10533600
            tz.transition 1970, 10, :o2, 23835600
            tz.transition 1971, 5, :o3, 41983200
            tz.transition 1971, 10, :o2, 55285200
            tz.transition 1972, 5, :o3, 74037600
            tz.transition 1972, 10, :o2, 87339600
            tz.transition 1973, 6, :o3, 107910000
            tz.transition 1973, 11, :o2, 121219200
            tz.transition 1974, 3, :o3, 133920000
            tz.transition 1974, 11, :o2, 152676000
            tz.transition 1975, 3, :o3, 165362400
            tz.transition 1975, 10, :o2, 183502800
            tz.transition 1976, 5, :o3, 202428000
            tz.transition 1976, 10, :o2, 215557200
            tz.transition 1977, 4, :o3, 228866400
            tz.transition 1977, 10, :o2, 245797200
            tz.transition 1978, 4, :o3, 260316000
            tz.transition 1978, 10, :o4, 277246800
            tz.transition 1979, 10, :o5, 308779200
            tz.transition 1980, 4, :o4, 323827200
            tz.transition 1980, 10, :o5, 340228800
            tz.transition 1981, 3, :o4, 354672000
            tz.transition 1981, 10, :o5, 371678400
            tz.transition 1982, 3, :o4, 386121600
            tz.transition 1982, 10, :o5, 403128000
            tz.transition 1983, 7, :o4, 428446800
            tz.transition 1983, 10, :o5, 433886400
            tz.transition 1985, 4, :o3, 482792400
            tz.transition 1985, 9, :o2, 496702800
            tz.transition 1986, 3, :o3, 512521200
            tz.transition 1986, 9, :o2, 528246000
            tz.transition 1987, 3, :o3, 543970800
            tz.transition 1987, 9, :o2, 559695600
            tz.transition 1988, 3, :o3, 575420400
            tz.transition 1988, 9, :o2, 591145200
            tz.transition 1989, 3, :o3, 606870000
            tz.transition 1989, 9, :o2, 622594800
            tz.transition 1990, 3, :o3, 638319600
            tz.transition 1990, 9, :o2, 654649200
            tz.transition 1991, 3, :o3, 670374000
            tz.transition 1991, 9, :o2, 686098800
            tz.transition 1992, 3, :o3, 701823600
            tz.transition 1992, 9, :o2, 717548400
            tz.transition 1993, 3, :o3, 733273200
            tz.transition 1993, 9, :o2, 748998000
            tz.transition 1994, 3, :o3, 764118000
            tz.transition 1994, 9, :o2, 780447600
            tz.transition 1995, 3, :o3, 796172400
            tz.transition 1995, 9, :o2, 811897200
            tz.transition 1996, 3, :o3, 828226800
            tz.transition 1996, 10, :o2, 846370800
            tz.transition 1997, 3, :o3, 859676400
            tz.transition 1997, 10, :o2, 877820400
            tz.transition 1998, 3, :o3, 891126000
            tz.transition 1998, 10, :o2, 909270000
            tz.transition 1999, 3, :o3, 922575600
            tz.transition 1999, 10, :o2, 941324400
            tz.transition 2000, 3, :o3, 954025200
            tz.transition 2000, 10, :o2, 972774000
            tz.transition 2001, 3, :o3, 985474800
            tz.transition 2001, 10, :o2, 1004223600
            tz.transition 2002, 3, :o3, 1017529200
            tz.transition 2002, 10, :o2, 1035673200
            tz.transition 2003, 3, :o3, 1048978800
            tz.transition 2003, 10, :o2, 1067122800
            tz.transition 2004, 3, :o3, 1080428400
            tz.transition 2004, 10, :o2, 1099177200
            tz.transition 2005, 3, :o3, 1111878000
            tz.transition 2005, 10, :o2, 1130626800
            tz.transition 2006, 3, :o3, 1143327600
            tz.transition 2006, 10, :o2, 1162076400
            tz.transition 2007, 3, :o3, 1174784400
            tz.transition 2007, 10, :o2, 1193533200
            tz.transition 2008, 3, :o3, 1206838800
            tz.transition 2008, 10, :o2, 1224982800
            tz.transition 2009, 3, :o3, 1238288400
            tz.transition 2009, 10, :o2, 1256432400
            tz.transition 2010, 3, :o3, 1269738000
            tz.transition 2010, 10, :o2, 1288486800
            tz.transition 2011, 3, :o3, 1301274000
            tz.transition 2011, 10, :o2, 1319936400
            tz.transition 2012, 3, :o3, 1332637200
            tz.transition 2012, 10, :o2, 1351386000
            tz.transition 2013, 3, :o3, 1364691600
            tz.transition 2013, 10, :o2, 1382835600
            tz.transition 2014, 3, :o3, 1396227600
            tz.transition 2014, 10, :o2, 1414285200
            tz.transition 2015, 3, :o3, 1427590800
            tz.transition 2015, 11, :o2, 1446944400
            tz.transition 2016, 3, :o3, 1459040400
            tz.transition 2016, 9, :o5, 1473195600
          end
        end
      end
    end
  end
end
