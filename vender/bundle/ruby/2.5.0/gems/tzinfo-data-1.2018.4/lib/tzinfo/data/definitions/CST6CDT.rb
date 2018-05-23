# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module CST6CDT
        include TimezoneDefinition
        
        timezone 'CST6CDT' do |tz|
          tz.offset :o0, -21600, 0, :CST
          tz.offset :o1, -21600, 3600, :CDT
          tz.offset :o2, -21600, 3600, :CWT
          tz.offset :o3, -21600, 3600, :CPT
          
          tz.transition 1918, 3, :o1, -1633276800, 14530103, 6
          tz.transition 1918, 10, :o0, -1615136400, 58125451, 24
          tz.transition 1919, 3, :o1, -1601827200, 14532287, 6
          tz.transition 1919, 10, :o0, -1583686800, 58134187, 24
          tz.transition 1942, 2, :o2, -880214400, 14582399, 6
          tz.transition 1945, 8, :o3, -769395600, 58360379, 24
          tz.transition 1945, 9, :o0, -765392400, 58361491, 24
          tz.transition 1967, 4, :o1, -84384000, 14637665, 6
          tz.transition 1967, 10, :o0, -68662800, 58555027, 24
          tz.transition 1968, 4, :o1, -52934400, 14639849, 6
          tz.transition 1968, 10, :o0, -37213200, 58563763, 24
          tz.transition 1969, 4, :o1, -21484800, 14642033, 6
          tz.transition 1969, 10, :o0, -5763600, 58572499, 24
          tz.transition 1970, 4, :o1, 9964800
          tz.transition 1970, 10, :o0, 25686000
          tz.transition 1971, 4, :o1, 41414400
          tz.transition 1971, 10, :o0, 57740400
          tz.transition 1972, 4, :o1, 73468800
          tz.transition 1972, 10, :o0, 89190000
          tz.transition 1973, 4, :o1, 104918400
          tz.transition 1973, 10, :o0, 120639600
          tz.transition 1974, 1, :o1, 126691200
          tz.transition 1974, 10, :o0, 152089200
          tz.transition 1975, 2, :o1, 162374400
          tz.transition 1975, 10, :o0, 183538800
          tz.transition 1976, 4, :o1, 199267200
          tz.transition 1976, 10, :o0, 215593200
          tz.transition 1977, 4, :o1, 230716800
          tz.transition 1977, 10, :o0, 247042800
          tz.transition 1978, 4, :o1, 262771200
          tz.transition 1978, 10, :o0, 278492400
          tz.transition 1979, 4, :o1, 294220800
          tz.transition 1979, 10, :o0, 309942000
          tz.transition 1980, 4, :o1, 325670400
          tz.transition 1980, 10, :o0, 341391600
          tz.transition 1981, 4, :o1, 357120000
          tz.transition 1981, 10, :o0, 372841200
          tz.transition 1982, 4, :o1, 388569600
          tz.transition 1982, 10, :o0, 404895600
          tz.transition 1983, 4, :o1, 420019200
          tz.transition 1983, 10, :o0, 436345200
          tz.transition 1984, 4, :o1, 452073600
          tz.transition 1984, 10, :o0, 467794800
          tz.transition 1985, 4, :o1, 483523200
          tz.transition 1985, 10, :o0, 499244400
          tz.transition 1986, 4, :o1, 514972800
          tz.transition 1986, 10, :o0, 530694000
          tz.transition 1987, 4, :o1, 544608000
          tz.transition 1987, 10, :o0, 562143600
          tz.transition 1988, 4, :o1, 576057600
          tz.transition 1988, 10, :o0, 594198000
          tz.transition 1989, 4, :o1, 607507200
          tz.transition 1989, 10, :o0, 625647600
          tz.transition 1990, 4, :o1, 638956800
          tz.transition 1990, 10, :o0, 657097200
          tz.transition 1991, 4, :o1, 671011200
          tz.transition 1991, 10, :o0, 688546800
          tz.transition 1992, 4, :o1, 702460800
          tz.transition 1992, 10, :o0, 719996400
          tz.transition 1993, 4, :o1, 733910400
          tz.transition 1993, 10, :o0, 752050800
          tz.transition 1994, 4, :o1, 765360000
          tz.transition 1994, 10, :o0, 783500400
          tz.transition 1995, 4, :o1, 796809600
          tz.transition 1995, 10, :o0, 814950000
          tz.transition 1996, 4, :o1, 828864000
          tz.transition 1996, 10, :o0, 846399600
          tz.transition 1997, 4, :o1, 860313600
          tz.transition 1997, 10, :o0, 877849200
          tz.transition 1998, 4, :o1, 891763200
          tz.transition 1998, 10, :o0, 909298800
          tz.transition 1999, 4, :o1, 923212800
          tz.transition 1999, 10, :o0, 941353200
          tz.transition 2000, 4, :o1, 954662400
          tz.transition 2000, 10, :o0, 972802800
          tz.transition 2001, 4, :o1, 986112000
          tz.transition 2001, 10, :o0, 1004252400
          tz.transition 2002, 4, :o1, 1018166400
          tz.transition 2002, 10, :o0, 1035702000
          tz.transition 2003, 4, :o1, 1049616000
          tz.transition 2003, 10, :o0, 1067151600
          tz.transition 2004, 4, :o1, 1081065600
          tz.transition 2004, 10, :o0, 1099206000
          tz.transition 2005, 4, :o1, 1112515200
          tz.transition 2005, 10, :o0, 1130655600
          tz.transition 2006, 4, :o1, 1143964800
          tz.transition 2006, 10, :o0, 1162105200
          tz.transition 2007, 3, :o1, 1173600000
          tz.transition 2007, 11, :o0, 1194159600
          tz.transition 2008, 3, :o1, 1205049600
          tz.transition 2008, 11, :o0, 1225609200
          tz.transition 2009, 3, :o1, 1236499200
          tz.transition 2009, 11, :o0, 1257058800
          tz.transition 2010, 3, :o1, 1268553600
          tz.transition 2010, 11, :o0, 1289113200
          tz.transition 2011, 3, :o1, 1300003200
          tz.transition 2011, 11, :o0, 1320562800
          tz.transition 2012, 3, :o1, 1331452800
          tz.transition 2012, 11, :o0, 1352012400
          tz.transition 2013, 3, :o1, 1362902400
          tz.transition 2013, 11, :o0, 1383462000
          tz.transition 2014, 3, :o1, 1394352000
          tz.transition 2014, 11, :o0, 1414911600
          tz.transition 2015, 3, :o1, 1425801600
          tz.transition 2015, 11, :o0, 1446361200
          tz.transition 2016, 3, :o1, 1457856000
          tz.transition 2016, 11, :o0, 1478415600
          tz.transition 2017, 3, :o1, 1489305600
          tz.transition 2017, 11, :o0, 1509865200
          tz.transition 2018, 3, :o1, 1520755200
          tz.transition 2018, 11, :o0, 1541314800
          tz.transition 2019, 3, :o1, 1552204800
          tz.transition 2019, 11, :o0, 1572764400
          tz.transition 2020, 3, :o1, 1583654400
          tz.transition 2020, 11, :o0, 1604214000
          tz.transition 2021, 3, :o1, 1615708800
          tz.transition 2021, 11, :o0, 1636268400
          tz.transition 2022, 3, :o1, 1647158400
          tz.transition 2022, 11, :o0, 1667718000
          tz.transition 2023, 3, :o1, 1678608000
          tz.transition 2023, 11, :o0, 1699167600
          tz.transition 2024, 3, :o1, 1710057600
          tz.transition 2024, 11, :o0, 1730617200
          tz.transition 2025, 3, :o1, 1741507200
          tz.transition 2025, 11, :o0, 1762066800
          tz.transition 2026, 3, :o1, 1772956800
          tz.transition 2026, 11, :o0, 1793516400
          tz.transition 2027, 3, :o1, 1805011200
          tz.transition 2027, 11, :o0, 1825570800
          tz.transition 2028, 3, :o1, 1836460800
          tz.transition 2028, 11, :o0, 1857020400
          tz.transition 2029, 3, :o1, 1867910400
          tz.transition 2029, 11, :o0, 1888470000
          tz.transition 2030, 3, :o1, 1899360000
          tz.transition 2030, 11, :o0, 1919919600
          tz.transition 2031, 3, :o1, 1930809600
          tz.transition 2031, 11, :o0, 1951369200
          tz.transition 2032, 3, :o1, 1962864000
          tz.transition 2032, 11, :o0, 1983423600
          tz.transition 2033, 3, :o1, 1994313600
          tz.transition 2033, 11, :o0, 2014873200
          tz.transition 2034, 3, :o1, 2025763200
          tz.transition 2034, 11, :o0, 2046322800
          tz.transition 2035, 3, :o1, 2057212800
          tz.transition 2035, 11, :o0, 2077772400
          tz.transition 2036, 3, :o1, 2088662400
          tz.transition 2036, 11, :o0, 2109222000
          tz.transition 2037, 3, :o1, 2120112000
          tz.transition 2037, 11, :o0, 2140671600
          tz.transition 2038, 3, :o1, 2152166400, 14792981, 6
          tz.transition 2038, 11, :o0, 2172726000, 59177635, 24
          tz.transition 2039, 3, :o1, 2183616000, 14795165, 6
          tz.transition 2039, 11, :o0, 2204175600, 59186371, 24
          tz.transition 2040, 3, :o1, 2215065600, 14797349, 6
          tz.transition 2040, 11, :o0, 2235625200, 59195107, 24
          tz.transition 2041, 3, :o1, 2246515200, 14799533, 6
          tz.transition 2041, 11, :o0, 2267074800, 59203843, 24
          tz.transition 2042, 3, :o1, 2277964800, 14801717, 6
          tz.transition 2042, 11, :o0, 2298524400, 59212579, 24
          tz.transition 2043, 3, :o1, 2309414400, 14803901, 6
          tz.transition 2043, 11, :o0, 2329974000, 59221315, 24
          tz.transition 2044, 3, :o1, 2341468800, 14806127, 6
          tz.transition 2044, 11, :o0, 2362028400, 59230219, 24
          tz.transition 2045, 3, :o1, 2372918400, 14808311, 6
          tz.transition 2045, 11, :o0, 2393478000, 59238955, 24
          tz.transition 2046, 3, :o1, 2404368000, 14810495, 6
          tz.transition 2046, 11, :o0, 2424927600, 59247691, 24
          tz.transition 2047, 3, :o1, 2435817600, 14812679, 6
          tz.transition 2047, 11, :o0, 2456377200, 59256427, 24
          tz.transition 2048, 3, :o1, 2467267200, 14814863, 6
          tz.transition 2048, 11, :o0, 2487826800, 59265163, 24
          tz.transition 2049, 3, :o1, 2499321600, 14817089, 6
          tz.transition 2049, 11, :o0, 2519881200, 59274067, 24
          tz.transition 2050, 3, :o1, 2530771200, 14819273, 6
          tz.transition 2050, 11, :o0, 2551330800, 59282803, 24
          tz.transition 2051, 3, :o1, 2562220800, 14821457, 6
          tz.transition 2051, 11, :o0, 2582780400, 59291539, 24
          tz.transition 2052, 3, :o1, 2593670400, 14823641, 6
          tz.transition 2052, 11, :o0, 2614230000, 59300275, 24
          tz.transition 2053, 3, :o1, 2625120000, 14825825, 6
          tz.transition 2053, 11, :o0, 2645679600, 59309011, 24
          tz.transition 2054, 3, :o1, 2656569600, 14828009, 6
          tz.transition 2054, 11, :o0, 2677129200, 59317747, 24
          tz.transition 2055, 3, :o1, 2688624000, 14830235, 6
          tz.transition 2055, 11, :o0, 2709183600, 59326651, 24
          tz.transition 2056, 3, :o1, 2720073600, 14832419, 6
          tz.transition 2056, 11, :o0, 2740633200, 59335387, 24
          tz.transition 2057, 3, :o1, 2751523200, 14834603, 6
          tz.transition 2057, 11, :o0, 2772082800, 59344123, 24
          tz.transition 2058, 3, :o1, 2782972800, 14836787, 6
          tz.transition 2058, 11, :o0, 2803532400, 59352859, 24
          tz.transition 2059, 3, :o1, 2814422400, 14838971, 6
          tz.transition 2059, 11, :o0, 2834982000, 59361595, 24
          tz.transition 2060, 3, :o1, 2846476800, 14841197, 6
          tz.transition 2060, 11, :o0, 2867036400, 59370499, 24
          tz.transition 2061, 3, :o1, 2877926400, 14843381, 6
          tz.transition 2061, 11, :o0, 2898486000, 59379235, 24
          tz.transition 2062, 3, :o1, 2909376000, 14845565, 6
          tz.transition 2062, 11, :o0, 2929935600, 59387971, 24
          tz.transition 2063, 3, :o1, 2940825600, 14847749, 6
          tz.transition 2063, 11, :o0, 2961385200, 59396707, 24
          tz.transition 2064, 3, :o1, 2972275200, 14849933, 6
          tz.transition 2064, 11, :o0, 2992834800, 59405443, 24
          tz.transition 2065, 3, :o1, 3003724800, 14852117, 6
          tz.transition 2065, 11, :o0, 3024284400, 59414179, 24
          tz.transition 2066, 3, :o1, 3035779200, 14854343, 6
          tz.transition 2066, 11, :o0, 3056338800, 59423083, 24
          tz.transition 2067, 3, :o1, 3067228800, 14856527, 6
          tz.transition 2067, 11, :o0, 3087788400, 59431819, 24
          tz.transition 2068, 3, :o1, 3098678400, 14858711, 6
          tz.transition 2068, 11, :o0, 3119238000, 59440555, 24
        end
      end
    end
  end
end
