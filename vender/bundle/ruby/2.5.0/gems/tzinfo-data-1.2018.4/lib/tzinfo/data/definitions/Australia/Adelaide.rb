# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module Adelaide
          include TimezoneDefinition
          
          timezone 'Australia/Adelaide' do |tz|
            tz.offset :o0, 33260, 0, :LMT
            tz.offset :o1, 32400, 0, :ACST
            tz.offset :o2, 34200, 0, :ACST
            tz.offset :o3, 34200, 3600, :ACDT
            
            tz.transition 1895, 1, :o1, -2364110060, 10425132497, 4320
            tz.transition 1899, 4, :o2, -2230189200, 19318201, 8
            tz.transition 1916, 12, :o3, -1672565340, 3486569911, 1440
            tz.transition 1917, 3, :o2, -1665390600, 116222983, 48
            tz.transition 1941, 12, :o3, -883639800, 38885763, 16
            tz.transition 1942, 3, :o2, -876126600, 116661463, 48
            tz.transition 1942, 9, :o3, -860398200, 38890067, 16
            tz.transition 1943, 3, :o2, -844677000, 116678935, 48
            tz.transition 1943, 10, :o3, -828343800, 38896003, 16
            tz.transition 1944, 3, :o2, -813227400, 116696407, 48
            tz.transition 1971, 10, :o3, 57688200
            tz.transition 1972, 2, :o2, 67969800
            tz.transition 1972, 10, :o3, 89137800
            tz.transition 1973, 3, :o2, 100024200
            tz.transition 1973, 10, :o3, 120587400
            tz.transition 1974, 3, :o2, 131473800
            tz.transition 1974, 10, :o3, 152037000
            tz.transition 1975, 3, :o2, 162923400
            tz.transition 1975, 10, :o3, 183486600
            tz.transition 1976, 3, :o2, 194977800
            tz.transition 1976, 10, :o3, 215541000
            tz.transition 1977, 3, :o2, 226427400
            tz.transition 1977, 10, :o3, 246990600
            tz.transition 1978, 3, :o2, 257877000
            tz.transition 1978, 10, :o3, 278440200
            tz.transition 1979, 3, :o2, 289326600
            tz.transition 1979, 10, :o3, 309889800
            tz.transition 1980, 3, :o2, 320776200
            tz.transition 1980, 10, :o3, 341339400
            tz.transition 1981, 2, :o2, 352225800
            tz.transition 1981, 10, :o3, 372789000
            tz.transition 1982, 3, :o2, 384280200
            tz.transition 1982, 10, :o3, 404843400
            tz.transition 1983, 3, :o2, 415729800
            tz.transition 1983, 10, :o3, 436293000
            tz.transition 1984, 3, :o2, 447179400
            tz.transition 1984, 10, :o3, 467742600
            tz.transition 1985, 3, :o2, 478629000
            tz.transition 1985, 10, :o3, 499192200
            tz.transition 1986, 3, :o2, 511288200
            tz.transition 1986, 10, :o3, 530037000
            tz.transition 1987, 3, :o2, 542737800
            tz.transition 1987, 10, :o3, 562091400
            tz.transition 1988, 3, :o2, 574792200
            tz.transition 1988, 10, :o3, 594145800
            tz.transition 1989, 3, :o2, 606241800
            tz.transition 1989, 10, :o3, 625595400
            tz.transition 1990, 3, :o2, 637691400
            tz.transition 1990, 10, :o3, 657045000
            tz.transition 1991, 3, :o2, 667931400
            tz.transition 1991, 10, :o3, 688494600
            tz.transition 1992, 3, :o2, 701195400
            tz.transition 1992, 10, :o3, 719944200
            tz.transition 1993, 3, :o2, 731435400
            tz.transition 1993, 10, :o3, 751998600
            tz.transition 1994, 3, :o2, 764094600
            tz.transition 1994, 10, :o3, 783448200
            tz.transition 1995, 3, :o2, 796149000
            tz.transition 1995, 10, :o3, 814897800
            tz.transition 1996, 3, :o2, 828203400
            tz.transition 1996, 10, :o3, 846347400
            tz.transition 1997, 3, :o2, 859653000
            tz.transition 1997, 10, :o3, 877797000
            tz.transition 1998, 3, :o2, 891102600
            tz.transition 1998, 10, :o3, 909246600
            tz.transition 1999, 3, :o2, 922552200
            tz.transition 1999, 10, :o3, 941301000
            tz.transition 2000, 3, :o2, 954001800
            tz.transition 2000, 10, :o3, 972750600
            tz.transition 2001, 3, :o2, 985451400
            tz.transition 2001, 10, :o3, 1004200200
            tz.transition 2002, 3, :o2, 1017505800
            tz.transition 2002, 10, :o3, 1035649800
            tz.transition 2003, 3, :o2, 1048955400
            tz.transition 2003, 10, :o3, 1067099400
            tz.transition 2004, 3, :o2, 1080405000
            tz.transition 2004, 10, :o3, 1099153800
            tz.transition 2005, 3, :o2, 1111854600
            tz.transition 2005, 10, :o3, 1130603400
            tz.transition 2006, 4, :o2, 1143909000
            tz.transition 2006, 10, :o3, 1162053000
            tz.transition 2007, 3, :o2, 1174753800
            tz.transition 2007, 10, :o3, 1193502600
            tz.transition 2008, 4, :o2, 1207413000
            tz.transition 2008, 10, :o3, 1223137800
            tz.transition 2009, 4, :o2, 1238862600
            tz.transition 2009, 10, :o3, 1254587400
            tz.transition 2010, 4, :o2, 1270312200
            tz.transition 2010, 10, :o3, 1286037000
            tz.transition 2011, 4, :o2, 1301761800
            tz.transition 2011, 10, :o3, 1317486600
            tz.transition 2012, 3, :o2, 1333211400
            tz.transition 2012, 10, :o3, 1349541000
            tz.transition 2013, 4, :o2, 1365265800
            tz.transition 2013, 10, :o3, 1380990600
            tz.transition 2014, 4, :o2, 1396715400
            tz.transition 2014, 10, :o3, 1412440200
            tz.transition 2015, 4, :o2, 1428165000
            tz.transition 2015, 10, :o3, 1443889800
            tz.transition 2016, 4, :o2, 1459614600
            tz.transition 2016, 10, :o3, 1475339400
            tz.transition 2017, 4, :o2, 1491064200
            tz.transition 2017, 9, :o3, 1506789000
            tz.transition 2018, 3, :o2, 1522513800
            tz.transition 2018, 10, :o3, 1538843400
            tz.transition 2019, 4, :o2, 1554568200
            tz.transition 2019, 10, :o3, 1570293000
            tz.transition 2020, 4, :o2, 1586017800
            tz.transition 2020, 10, :o3, 1601742600
            tz.transition 2021, 4, :o2, 1617467400
            tz.transition 2021, 10, :o3, 1633192200
            tz.transition 2022, 4, :o2, 1648917000
            tz.transition 2022, 10, :o3, 1664641800
            tz.transition 2023, 4, :o2, 1680366600
            tz.transition 2023, 9, :o3, 1696091400
            tz.transition 2024, 4, :o2, 1712421000
            tz.transition 2024, 10, :o3, 1728145800
            tz.transition 2025, 4, :o2, 1743870600
            tz.transition 2025, 10, :o3, 1759595400
            tz.transition 2026, 4, :o2, 1775320200
            tz.transition 2026, 10, :o3, 1791045000
            tz.transition 2027, 4, :o2, 1806769800
            tz.transition 2027, 10, :o3, 1822494600
            tz.transition 2028, 4, :o2, 1838219400
            tz.transition 2028, 9, :o3, 1853944200
            tz.transition 2029, 3, :o2, 1869669000
            tz.transition 2029, 10, :o3, 1885998600
            tz.transition 2030, 4, :o2, 1901723400
            tz.transition 2030, 10, :o3, 1917448200
            tz.transition 2031, 4, :o2, 1933173000
            tz.transition 2031, 10, :o3, 1948897800
            tz.transition 2032, 4, :o2, 1964622600
            tz.transition 2032, 10, :o3, 1980347400
            tz.transition 2033, 4, :o2, 1996072200
            tz.transition 2033, 10, :o3, 2011797000
            tz.transition 2034, 4, :o2, 2027521800
            tz.transition 2034, 9, :o3, 2043246600
            tz.transition 2035, 3, :o2, 2058971400
            tz.transition 2035, 10, :o3, 2075301000
            tz.transition 2036, 4, :o2, 2091025800
            tz.transition 2036, 10, :o3, 2106750600
            tz.transition 2037, 4, :o2, 2122475400
            tz.transition 2037, 10, :o3, 2138200200
            tz.transition 2038, 4, :o2, 2153925000, 39448275, 16
            tz.transition 2038, 10, :o3, 2169649800, 39451187, 16
            tz.transition 2039, 4, :o2, 2185374600, 39454099, 16
            tz.transition 2039, 10, :o3, 2201099400, 39457011, 16
            tz.transition 2040, 3, :o2, 2216824200, 39459923, 16
            tz.transition 2040, 10, :o3, 2233153800, 39462947, 16
            tz.transition 2041, 4, :o2, 2248878600, 39465859, 16
            tz.transition 2041, 10, :o3, 2264603400, 39468771, 16
            tz.transition 2042, 4, :o2, 2280328200, 39471683, 16
            tz.transition 2042, 10, :o3, 2296053000, 39474595, 16
            tz.transition 2043, 4, :o2, 2311777800, 39477507, 16
            tz.transition 2043, 10, :o3, 2327502600, 39480419, 16
            tz.transition 2044, 4, :o2, 2343227400, 39483331, 16
            tz.transition 2044, 10, :o3, 2358952200, 39486243, 16
            tz.transition 2045, 4, :o2, 2374677000, 39489155, 16
            tz.transition 2045, 9, :o3, 2390401800, 39492067, 16
            tz.transition 2046, 3, :o2, 2406126600, 39494979, 16
            tz.transition 2046, 10, :o3, 2422456200, 39498003, 16
            tz.transition 2047, 4, :o2, 2438181000, 39500915, 16
            tz.transition 2047, 10, :o3, 2453905800, 39503827, 16
            tz.transition 2048, 4, :o2, 2469630600, 39506739, 16
            tz.transition 2048, 10, :o3, 2485355400, 39509651, 16
            tz.transition 2049, 4, :o2, 2501080200, 39512563, 16
            tz.transition 2049, 10, :o3, 2516805000, 39515475, 16
            tz.transition 2050, 4, :o2, 2532529800, 39518387, 16
            tz.transition 2050, 10, :o3, 2548254600, 39521299, 16
            tz.transition 2051, 4, :o2, 2563979400, 39524211, 16
            tz.transition 2051, 9, :o3, 2579704200, 39527123, 16
            tz.transition 2052, 4, :o2, 2596033800, 39530147, 16
            tz.transition 2052, 10, :o3, 2611758600, 39533059, 16
            tz.transition 2053, 4, :o2, 2627483400, 39535971, 16
            tz.transition 2053, 10, :o3, 2643208200, 39538883, 16
            tz.transition 2054, 4, :o2, 2658933000, 39541795, 16
            tz.transition 2054, 10, :o3, 2674657800, 39544707, 16
            tz.transition 2055, 4, :o2, 2690382600, 39547619, 16
            tz.transition 2055, 10, :o3, 2706107400, 39550531, 16
            tz.transition 2056, 4, :o2, 2721832200, 39553443, 16
            tz.transition 2056, 9, :o3, 2737557000, 39556355, 16
            tz.transition 2057, 3, :o2, 2753281800, 39559267, 16
            tz.transition 2057, 10, :o3, 2769611400, 39562291, 16
            tz.transition 2058, 4, :o2, 2785336200, 39565203, 16
            tz.transition 2058, 10, :o3, 2801061000, 39568115, 16
            tz.transition 2059, 4, :o2, 2816785800, 39571027, 16
            tz.transition 2059, 10, :o3, 2832510600, 39573939, 16
            tz.transition 2060, 4, :o2, 2848235400, 39576851, 16
            tz.transition 2060, 10, :o3, 2863960200, 39579763, 16
            tz.transition 2061, 4, :o2, 2879685000, 39582675, 16
            tz.transition 2061, 10, :o3, 2895409800, 39585587, 16
            tz.transition 2062, 4, :o2, 2911134600, 39588499, 16
            tz.transition 2062, 9, :o3, 2926859400, 39591411, 16
            tz.transition 2063, 3, :o2, 2942584200, 39594323, 16
            tz.transition 2063, 10, :o3, 2958913800, 39597347, 16
            tz.transition 2064, 4, :o2, 2974638600, 39600259, 16
            tz.transition 2064, 10, :o3, 2990363400, 39603171, 16
            tz.transition 2065, 4, :o2, 3006088200, 39606083, 16
            tz.transition 2065, 10, :o3, 3021813000, 39608995, 16
            tz.transition 2066, 4, :o2, 3037537800, 39611907, 16
            tz.transition 2066, 10, :o3, 3053262600, 39614819, 16
            tz.transition 2067, 4, :o2, 3068987400, 39617731, 16
            tz.transition 2067, 10, :o3, 3084712200, 39620643, 16
            tz.transition 2068, 3, :o2, 3100437000, 39623555, 16
          end
        end
      end
    end
  end
end
