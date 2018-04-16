# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module North_Dakota
          module Center
            include TimezoneDefinition
            
            timezone 'America/North_Dakota/Center' do |tz|
              tz.offset :o0, -24312, 0, :LMT
              tz.offset :o1, -25200, 0, :MST
              tz.offset :o2, -25200, 3600, :MDT
              tz.offset :o3, -25200, 3600, :MWT
              tz.offset :o4, -25200, 3600, :MPT
              tz.offset :o5, -21600, 0, :CST
              tz.offset :o6, -21600, 3600, :CDT
              
              tz.transition 1883, 11, :o1, -2717643600, 57819199, 24
              tz.transition 1918, 3, :o2, -1633273200, 19373471, 8
              tz.transition 1918, 10, :o1, -1615132800, 14531363, 6
              tz.transition 1919, 3, :o2, -1601823600, 19376383, 8
              tz.transition 1919, 10, :o1, -1583683200, 14533547, 6
              tz.transition 1942, 2, :o3, -880210800, 19443199, 8
              tz.transition 1945, 8, :o4, -769395600, 58360379, 24
              tz.transition 1945, 9, :o1, -765388800, 14590373, 6
              tz.transition 1967, 4, :o2, -84380400, 19516887, 8
              tz.transition 1967, 10, :o1, -68659200, 14638757, 6
              tz.transition 1968, 4, :o2, -52930800, 19519799, 8
              tz.transition 1968, 10, :o1, -37209600, 14640941, 6
              tz.transition 1969, 4, :o2, -21481200, 19522711, 8
              tz.transition 1969, 10, :o1, -5760000, 14643125, 6
              tz.transition 1970, 4, :o2, 9968400
              tz.transition 1970, 10, :o1, 25689600
              tz.transition 1971, 4, :o2, 41418000
              tz.transition 1971, 10, :o1, 57744000
              tz.transition 1972, 4, :o2, 73472400
              tz.transition 1972, 10, :o1, 89193600
              tz.transition 1973, 4, :o2, 104922000
              tz.transition 1973, 10, :o1, 120643200
              tz.transition 1974, 1, :o2, 126694800
              tz.transition 1974, 10, :o1, 152092800
              tz.transition 1975, 2, :o2, 162378000
              tz.transition 1975, 10, :o1, 183542400
              tz.transition 1976, 4, :o2, 199270800
              tz.transition 1976, 10, :o1, 215596800
              tz.transition 1977, 4, :o2, 230720400
              tz.transition 1977, 10, :o1, 247046400
              tz.transition 1978, 4, :o2, 262774800
              tz.transition 1978, 10, :o1, 278496000
              tz.transition 1979, 4, :o2, 294224400
              tz.transition 1979, 10, :o1, 309945600
              tz.transition 1980, 4, :o2, 325674000
              tz.transition 1980, 10, :o1, 341395200
              tz.transition 1981, 4, :o2, 357123600
              tz.transition 1981, 10, :o1, 372844800
              tz.transition 1982, 4, :o2, 388573200
              tz.transition 1982, 10, :o1, 404899200
              tz.transition 1983, 4, :o2, 420022800
              tz.transition 1983, 10, :o1, 436348800
              tz.transition 1984, 4, :o2, 452077200
              tz.transition 1984, 10, :o1, 467798400
              tz.transition 1985, 4, :o2, 483526800
              tz.transition 1985, 10, :o1, 499248000
              tz.transition 1986, 4, :o2, 514976400
              tz.transition 1986, 10, :o1, 530697600
              tz.transition 1987, 4, :o2, 544611600
              tz.transition 1987, 10, :o1, 562147200
              tz.transition 1988, 4, :o2, 576061200
              tz.transition 1988, 10, :o1, 594201600
              tz.transition 1989, 4, :o2, 607510800
              tz.transition 1989, 10, :o1, 625651200
              tz.transition 1990, 4, :o2, 638960400
              tz.transition 1990, 10, :o1, 657100800
              tz.transition 1991, 4, :o2, 671014800
              tz.transition 1991, 10, :o1, 688550400
              tz.transition 1992, 4, :o2, 702464400
              tz.transition 1992, 10, :o5, 720000000
              tz.transition 1993, 4, :o6, 733910400
              tz.transition 1993, 10, :o5, 752050800
              tz.transition 1994, 4, :o6, 765360000
              tz.transition 1994, 10, :o5, 783500400
              tz.transition 1995, 4, :o6, 796809600
              tz.transition 1995, 10, :o5, 814950000
              tz.transition 1996, 4, :o6, 828864000
              tz.transition 1996, 10, :o5, 846399600
              tz.transition 1997, 4, :o6, 860313600
              tz.transition 1997, 10, :o5, 877849200
              tz.transition 1998, 4, :o6, 891763200
              tz.transition 1998, 10, :o5, 909298800
              tz.transition 1999, 4, :o6, 923212800
              tz.transition 1999, 10, :o5, 941353200
              tz.transition 2000, 4, :o6, 954662400
              tz.transition 2000, 10, :o5, 972802800
              tz.transition 2001, 4, :o6, 986112000
              tz.transition 2001, 10, :o5, 1004252400
              tz.transition 2002, 4, :o6, 1018166400
              tz.transition 2002, 10, :o5, 1035702000
              tz.transition 2003, 4, :o6, 1049616000
              tz.transition 2003, 10, :o5, 1067151600
              tz.transition 2004, 4, :o6, 1081065600
              tz.transition 2004, 10, :o5, 1099206000
              tz.transition 2005, 4, :o6, 1112515200
              tz.transition 2005, 10, :o5, 1130655600
              tz.transition 2006, 4, :o6, 1143964800
              tz.transition 2006, 10, :o5, 1162105200
              tz.transition 2007, 3, :o6, 1173600000
              tz.transition 2007, 11, :o5, 1194159600
              tz.transition 2008, 3, :o6, 1205049600
              tz.transition 2008, 11, :o5, 1225609200
              tz.transition 2009, 3, :o6, 1236499200
              tz.transition 2009, 11, :o5, 1257058800
              tz.transition 2010, 3, :o6, 1268553600
              tz.transition 2010, 11, :o5, 1289113200
              tz.transition 2011, 3, :o6, 1300003200
              tz.transition 2011, 11, :o5, 1320562800
              tz.transition 2012, 3, :o6, 1331452800
              tz.transition 2012, 11, :o5, 1352012400
              tz.transition 2013, 3, :o6, 1362902400
              tz.transition 2013, 11, :o5, 1383462000
              tz.transition 2014, 3, :o6, 1394352000
              tz.transition 2014, 11, :o5, 1414911600
              tz.transition 2015, 3, :o6, 1425801600
              tz.transition 2015, 11, :o5, 1446361200
              tz.transition 2016, 3, :o6, 1457856000
              tz.transition 2016, 11, :o5, 1478415600
              tz.transition 2017, 3, :o6, 1489305600
              tz.transition 2017, 11, :o5, 1509865200
              tz.transition 2018, 3, :o6, 1520755200
              tz.transition 2018, 11, :o5, 1541314800
              tz.transition 2019, 3, :o6, 1552204800
              tz.transition 2019, 11, :o5, 1572764400
              tz.transition 2020, 3, :o6, 1583654400
              tz.transition 2020, 11, :o5, 1604214000
              tz.transition 2021, 3, :o6, 1615708800
              tz.transition 2021, 11, :o5, 1636268400
              tz.transition 2022, 3, :o6, 1647158400
              tz.transition 2022, 11, :o5, 1667718000
              tz.transition 2023, 3, :o6, 1678608000
              tz.transition 2023, 11, :o5, 1699167600
              tz.transition 2024, 3, :o6, 1710057600
              tz.transition 2024, 11, :o5, 1730617200
              tz.transition 2025, 3, :o6, 1741507200
              tz.transition 2025, 11, :o5, 1762066800
              tz.transition 2026, 3, :o6, 1772956800
              tz.transition 2026, 11, :o5, 1793516400
              tz.transition 2027, 3, :o6, 1805011200
              tz.transition 2027, 11, :o5, 1825570800
              tz.transition 2028, 3, :o6, 1836460800
              tz.transition 2028, 11, :o5, 1857020400
              tz.transition 2029, 3, :o6, 1867910400
              tz.transition 2029, 11, :o5, 1888470000
              tz.transition 2030, 3, :o6, 1899360000
              tz.transition 2030, 11, :o5, 1919919600
              tz.transition 2031, 3, :o6, 1930809600
              tz.transition 2031, 11, :o5, 1951369200
              tz.transition 2032, 3, :o6, 1962864000
              tz.transition 2032, 11, :o5, 1983423600
              tz.transition 2033, 3, :o6, 1994313600
              tz.transition 2033, 11, :o5, 2014873200
              tz.transition 2034, 3, :o6, 2025763200
              tz.transition 2034, 11, :o5, 2046322800
              tz.transition 2035, 3, :o6, 2057212800
              tz.transition 2035, 11, :o5, 2077772400
              tz.transition 2036, 3, :o6, 2088662400
              tz.transition 2036, 11, :o5, 2109222000
              tz.transition 2037, 3, :o6, 2120112000
              tz.transition 2037, 11, :o5, 2140671600
              tz.transition 2038, 3, :o6, 2152166400, 14792981, 6
              tz.transition 2038, 11, :o5, 2172726000, 59177635, 24
              tz.transition 2039, 3, :o6, 2183616000, 14795165, 6
              tz.transition 2039, 11, :o5, 2204175600, 59186371, 24
              tz.transition 2040, 3, :o6, 2215065600, 14797349, 6
              tz.transition 2040, 11, :o5, 2235625200, 59195107, 24
              tz.transition 2041, 3, :o6, 2246515200, 14799533, 6
              tz.transition 2041, 11, :o5, 2267074800, 59203843, 24
              tz.transition 2042, 3, :o6, 2277964800, 14801717, 6
              tz.transition 2042, 11, :o5, 2298524400, 59212579, 24
              tz.transition 2043, 3, :o6, 2309414400, 14803901, 6
              tz.transition 2043, 11, :o5, 2329974000, 59221315, 24
              tz.transition 2044, 3, :o6, 2341468800, 14806127, 6
              tz.transition 2044, 11, :o5, 2362028400, 59230219, 24
              tz.transition 2045, 3, :o6, 2372918400, 14808311, 6
              tz.transition 2045, 11, :o5, 2393478000, 59238955, 24
              tz.transition 2046, 3, :o6, 2404368000, 14810495, 6
              tz.transition 2046, 11, :o5, 2424927600, 59247691, 24
              tz.transition 2047, 3, :o6, 2435817600, 14812679, 6
              tz.transition 2047, 11, :o5, 2456377200, 59256427, 24
              tz.transition 2048, 3, :o6, 2467267200, 14814863, 6
              tz.transition 2048, 11, :o5, 2487826800, 59265163, 24
              tz.transition 2049, 3, :o6, 2499321600, 14817089, 6
              tz.transition 2049, 11, :o5, 2519881200, 59274067, 24
              tz.transition 2050, 3, :o6, 2530771200, 14819273, 6
              tz.transition 2050, 11, :o5, 2551330800, 59282803, 24
              tz.transition 2051, 3, :o6, 2562220800, 14821457, 6
              tz.transition 2051, 11, :o5, 2582780400, 59291539, 24
              tz.transition 2052, 3, :o6, 2593670400, 14823641, 6
              tz.transition 2052, 11, :o5, 2614230000, 59300275, 24
              tz.transition 2053, 3, :o6, 2625120000, 14825825, 6
              tz.transition 2053, 11, :o5, 2645679600, 59309011, 24
              tz.transition 2054, 3, :o6, 2656569600, 14828009, 6
              tz.transition 2054, 11, :o5, 2677129200, 59317747, 24
              tz.transition 2055, 3, :o6, 2688624000, 14830235, 6
              tz.transition 2055, 11, :o5, 2709183600, 59326651, 24
              tz.transition 2056, 3, :o6, 2720073600, 14832419, 6
              tz.transition 2056, 11, :o5, 2740633200, 59335387, 24
              tz.transition 2057, 3, :o6, 2751523200, 14834603, 6
              tz.transition 2057, 11, :o5, 2772082800, 59344123, 24
              tz.transition 2058, 3, :o6, 2782972800, 14836787, 6
              tz.transition 2058, 11, :o5, 2803532400, 59352859, 24
              tz.transition 2059, 3, :o6, 2814422400, 14838971, 6
              tz.transition 2059, 11, :o5, 2834982000, 59361595, 24
              tz.transition 2060, 3, :o6, 2846476800, 14841197, 6
              tz.transition 2060, 11, :o5, 2867036400, 59370499, 24
              tz.transition 2061, 3, :o6, 2877926400, 14843381, 6
              tz.transition 2061, 11, :o5, 2898486000, 59379235, 24
              tz.transition 2062, 3, :o6, 2909376000, 14845565, 6
              tz.transition 2062, 11, :o5, 2929935600, 59387971, 24
              tz.transition 2063, 3, :o6, 2940825600, 14847749, 6
              tz.transition 2063, 11, :o5, 2961385200, 59396707, 24
              tz.transition 2064, 3, :o6, 2972275200, 14849933, 6
              tz.transition 2064, 11, :o5, 2992834800, 59405443, 24
              tz.transition 2065, 3, :o6, 3003724800, 14852117, 6
              tz.transition 2065, 11, :o5, 3024284400, 59414179, 24
              tz.transition 2066, 3, :o6, 3035779200, 14854343, 6
              tz.transition 2066, 11, :o5, 3056338800, 59423083, 24
              tz.transition 2067, 3, :o6, 3067228800, 14856527, 6
              tz.transition 2067, 11, :o5, 3087788400, 59431819, 24
              tz.transition 2068, 3, :o6, 3098678400, 14858711, 6
              tz.transition 2068, 11, :o5, 3119238000, 59440555, 24
            end
          end
        end
      end
    end
  end
end
