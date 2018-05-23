# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Matamoros
          include TimezoneDefinition
          
          timezone 'America/Matamoros' do |tz|
            tz.offset :o0, -24000, 0, :LMT
            tz.offset :o1, -21600, 0, :CST
            tz.offset :o2, -21600, 3600, :CDT
            
            tz.transition 1922, 1, :o1, -1514743200, 9692223, 4
            tz.transition 1988, 4, :o2, 576057600
            tz.transition 1988, 10, :o1, 594198000
            tz.transition 1996, 4, :o2, 828864000
            tz.transition 1996, 10, :o1, 846399600
            tz.transition 1997, 4, :o2, 860313600
            tz.transition 1997, 10, :o1, 877849200
            tz.transition 1998, 4, :o2, 891763200
            tz.transition 1998, 10, :o1, 909298800
            tz.transition 1999, 4, :o2, 923212800
            tz.transition 1999, 10, :o1, 941353200
            tz.transition 2000, 4, :o2, 954662400
            tz.transition 2000, 10, :o1, 972802800
            tz.transition 2001, 5, :o2, 989136000
            tz.transition 2001, 9, :o1, 1001833200
            tz.transition 2002, 4, :o2, 1018166400
            tz.transition 2002, 10, :o1, 1035702000
            tz.transition 2003, 4, :o2, 1049616000
            tz.transition 2003, 10, :o1, 1067151600
            tz.transition 2004, 4, :o2, 1081065600
            tz.transition 2004, 10, :o1, 1099206000
            tz.transition 2005, 4, :o2, 1112515200
            tz.transition 2005, 10, :o1, 1130655600
            tz.transition 2006, 4, :o2, 1143964800
            tz.transition 2006, 10, :o1, 1162105200
            tz.transition 2007, 4, :o2, 1175414400
            tz.transition 2007, 10, :o1, 1193554800
            tz.transition 2008, 4, :o2, 1207468800
            tz.transition 2008, 10, :o1, 1225004400
            tz.transition 2009, 4, :o2, 1238918400
            tz.transition 2009, 10, :o1, 1256454000
            tz.transition 2010, 3, :o2, 1268553600
            tz.transition 2010, 11, :o1, 1289113200
            tz.transition 2011, 3, :o2, 1300003200
            tz.transition 2011, 11, :o1, 1320562800
            tz.transition 2012, 3, :o2, 1331452800
            tz.transition 2012, 11, :o1, 1352012400
            tz.transition 2013, 3, :o2, 1362902400
            tz.transition 2013, 11, :o1, 1383462000
            tz.transition 2014, 3, :o2, 1394352000
            tz.transition 2014, 11, :o1, 1414911600
            tz.transition 2015, 3, :o2, 1425801600
            tz.transition 2015, 11, :o1, 1446361200
            tz.transition 2016, 3, :o2, 1457856000
            tz.transition 2016, 11, :o1, 1478415600
            tz.transition 2017, 3, :o2, 1489305600
            tz.transition 2017, 11, :o1, 1509865200
            tz.transition 2018, 3, :o2, 1520755200
            tz.transition 2018, 11, :o1, 1541314800
            tz.transition 2019, 3, :o2, 1552204800
            tz.transition 2019, 11, :o1, 1572764400
            tz.transition 2020, 3, :o2, 1583654400
            tz.transition 2020, 11, :o1, 1604214000
            tz.transition 2021, 3, :o2, 1615708800
            tz.transition 2021, 11, :o1, 1636268400
            tz.transition 2022, 3, :o2, 1647158400
            tz.transition 2022, 11, :o1, 1667718000
            tz.transition 2023, 3, :o2, 1678608000
            tz.transition 2023, 11, :o1, 1699167600
            tz.transition 2024, 3, :o2, 1710057600
            tz.transition 2024, 11, :o1, 1730617200
            tz.transition 2025, 3, :o2, 1741507200
            tz.transition 2025, 11, :o1, 1762066800
            tz.transition 2026, 3, :o2, 1772956800
            tz.transition 2026, 11, :o1, 1793516400
            tz.transition 2027, 3, :o2, 1805011200
            tz.transition 2027, 11, :o1, 1825570800
            tz.transition 2028, 3, :o2, 1836460800
            tz.transition 2028, 11, :o1, 1857020400
            tz.transition 2029, 3, :o2, 1867910400
            tz.transition 2029, 11, :o1, 1888470000
            tz.transition 2030, 3, :o2, 1899360000
            tz.transition 2030, 11, :o1, 1919919600
            tz.transition 2031, 3, :o2, 1930809600
            tz.transition 2031, 11, :o1, 1951369200
            tz.transition 2032, 3, :o2, 1962864000
            tz.transition 2032, 11, :o1, 1983423600
            tz.transition 2033, 3, :o2, 1994313600
            tz.transition 2033, 11, :o1, 2014873200
            tz.transition 2034, 3, :o2, 2025763200
            tz.transition 2034, 11, :o1, 2046322800
            tz.transition 2035, 3, :o2, 2057212800
            tz.transition 2035, 11, :o1, 2077772400
            tz.transition 2036, 3, :o2, 2088662400
            tz.transition 2036, 11, :o1, 2109222000
            tz.transition 2037, 3, :o2, 2120112000
            tz.transition 2037, 11, :o1, 2140671600
            tz.transition 2038, 3, :o2, 2152166400, 14792981, 6
            tz.transition 2038, 11, :o1, 2172726000, 59177635, 24
            tz.transition 2039, 3, :o2, 2183616000, 14795165, 6
            tz.transition 2039, 11, :o1, 2204175600, 59186371, 24
            tz.transition 2040, 3, :o2, 2215065600, 14797349, 6
            tz.transition 2040, 11, :o1, 2235625200, 59195107, 24
            tz.transition 2041, 3, :o2, 2246515200, 14799533, 6
            tz.transition 2041, 11, :o1, 2267074800, 59203843, 24
            tz.transition 2042, 3, :o2, 2277964800, 14801717, 6
            tz.transition 2042, 11, :o1, 2298524400, 59212579, 24
            tz.transition 2043, 3, :o2, 2309414400, 14803901, 6
            tz.transition 2043, 11, :o1, 2329974000, 59221315, 24
            tz.transition 2044, 3, :o2, 2341468800, 14806127, 6
            tz.transition 2044, 11, :o1, 2362028400, 59230219, 24
            tz.transition 2045, 3, :o2, 2372918400, 14808311, 6
            tz.transition 2045, 11, :o1, 2393478000, 59238955, 24
            tz.transition 2046, 3, :o2, 2404368000, 14810495, 6
            tz.transition 2046, 11, :o1, 2424927600, 59247691, 24
            tz.transition 2047, 3, :o2, 2435817600, 14812679, 6
            tz.transition 2047, 11, :o1, 2456377200, 59256427, 24
            tz.transition 2048, 3, :o2, 2467267200, 14814863, 6
            tz.transition 2048, 11, :o1, 2487826800, 59265163, 24
            tz.transition 2049, 3, :o2, 2499321600, 14817089, 6
            tz.transition 2049, 11, :o1, 2519881200, 59274067, 24
            tz.transition 2050, 3, :o2, 2530771200, 14819273, 6
            tz.transition 2050, 11, :o1, 2551330800, 59282803, 24
            tz.transition 2051, 3, :o2, 2562220800, 14821457, 6
            tz.transition 2051, 11, :o1, 2582780400, 59291539, 24
            tz.transition 2052, 3, :o2, 2593670400, 14823641, 6
            tz.transition 2052, 11, :o1, 2614230000, 59300275, 24
            tz.transition 2053, 3, :o2, 2625120000, 14825825, 6
            tz.transition 2053, 11, :o1, 2645679600, 59309011, 24
            tz.transition 2054, 3, :o2, 2656569600, 14828009, 6
            tz.transition 2054, 11, :o1, 2677129200, 59317747, 24
            tz.transition 2055, 3, :o2, 2688624000, 14830235, 6
            tz.transition 2055, 11, :o1, 2709183600, 59326651, 24
            tz.transition 2056, 3, :o2, 2720073600, 14832419, 6
            tz.transition 2056, 11, :o1, 2740633200, 59335387, 24
            tz.transition 2057, 3, :o2, 2751523200, 14834603, 6
            tz.transition 2057, 11, :o1, 2772082800, 59344123, 24
            tz.transition 2058, 3, :o2, 2782972800, 14836787, 6
            tz.transition 2058, 11, :o1, 2803532400, 59352859, 24
            tz.transition 2059, 3, :o2, 2814422400, 14838971, 6
            tz.transition 2059, 11, :o1, 2834982000, 59361595, 24
            tz.transition 2060, 3, :o2, 2846476800, 14841197, 6
            tz.transition 2060, 11, :o1, 2867036400, 59370499, 24
            tz.transition 2061, 3, :o2, 2877926400, 14843381, 6
            tz.transition 2061, 11, :o1, 2898486000, 59379235, 24
            tz.transition 2062, 3, :o2, 2909376000, 14845565, 6
            tz.transition 2062, 11, :o1, 2929935600, 59387971, 24
            tz.transition 2063, 3, :o2, 2940825600, 14847749, 6
            tz.transition 2063, 11, :o1, 2961385200, 59396707, 24
            tz.transition 2064, 3, :o2, 2972275200, 14849933, 6
            tz.transition 2064, 11, :o1, 2992834800, 59405443, 24
            tz.transition 2065, 3, :o2, 3003724800, 14852117, 6
            tz.transition 2065, 11, :o1, 3024284400, 59414179, 24
            tz.transition 2066, 3, :o2, 3035779200, 14854343, 6
            tz.transition 2066, 11, :o1, 3056338800, 59423083, 24
            tz.transition 2067, 3, :o2, 3067228800, 14856527, 6
            tz.transition 2067, 11, :o1, 3087788400, 59431819, 24
            tz.transition 2068, 3, :o2, 3098678400, 14858711, 6
            tz.transition 2068, 11, :o1, 3119238000, 59440555, 24
          end
        end
      end
    end
  end
end
