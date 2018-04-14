# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module Currie
          include TimezoneDefinition
          
          timezone 'Australia/Currie' do |tz|
            tz.offset :o0, 34528, 0, :LMT
            tz.offset :o1, 36000, 0, :AEST
            tz.offset :o2, 36000, 3600, :AEDT
            
            tz.transition 1895, 8, :o1, -2345794528, 6516280171, 2700
            tz.transition 1916, 9, :o2, -1680508800, 14526823, 6
            tz.transition 1917, 3, :o1, -1665392400, 19370497, 8
            tz.transition 1941, 12, :o2, -883641600, 14582161, 6
            tz.transition 1942, 3, :o1, -876128400, 19443577, 8
            tz.transition 1942, 9, :o2, -860400000, 14583775, 6
            tz.transition 1943, 3, :o1, -844678800, 19446489, 8
            tz.transition 1943, 10, :o2, -828345600, 14586001, 6
            tz.transition 1944, 3, :o1, -813229200, 19449401, 8
            tz.transition 1971, 10, :o2, 57686400
            tz.transition 1972, 2, :o1, 67968000
            tz.transition 1972, 10, :o2, 89136000
            tz.transition 1973, 3, :o1, 100022400
            tz.transition 1973, 10, :o2, 120585600
            tz.transition 1974, 3, :o1, 131472000
            tz.transition 1974, 10, :o2, 152035200
            tz.transition 1975, 3, :o1, 162921600
            tz.transition 1975, 10, :o2, 183484800
            tz.transition 1976, 3, :o1, 194976000
            tz.transition 1976, 10, :o2, 215539200
            tz.transition 1977, 3, :o1, 226425600
            tz.transition 1977, 10, :o2, 246988800
            tz.transition 1978, 3, :o1, 257875200
            tz.transition 1978, 10, :o2, 278438400
            tz.transition 1979, 3, :o1, 289324800
            tz.transition 1979, 10, :o2, 309888000
            tz.transition 1980, 3, :o1, 320774400
            tz.transition 1980, 10, :o2, 341337600
            tz.transition 1981, 2, :o1, 352224000
            tz.transition 1981, 10, :o2, 372787200
            tz.transition 1982, 3, :o1, 386092800
            tz.transition 1982, 10, :o2, 404841600
            tz.transition 1983, 3, :o1, 417542400
            tz.transition 1983, 10, :o2, 436291200
            tz.transition 1984, 3, :o1, 447177600
            tz.transition 1984, 10, :o2, 467740800
            tz.transition 1985, 3, :o1, 478627200
            tz.transition 1985, 10, :o2, 499190400
            tz.transition 1986, 3, :o1, 510076800
            tz.transition 1986, 10, :o2, 530035200
            tz.transition 1987, 3, :o1, 542736000
            tz.transition 1987, 10, :o2, 562089600
            tz.transition 1988, 3, :o1, 574790400
            tz.transition 1988, 10, :o2, 594144000
            tz.transition 1989, 3, :o1, 606240000
            tz.transition 1989, 10, :o2, 625593600
            tz.transition 1990, 3, :o1, 637689600
            tz.transition 1990, 10, :o2, 657043200
            tz.transition 1991, 3, :o1, 670348800
            tz.transition 1991, 10, :o2, 686678400
            tz.transition 1992, 3, :o1, 701798400
            tz.transition 1992, 10, :o2, 718128000
            tz.transition 1993, 3, :o1, 733248000
            tz.transition 1993, 10, :o2, 749577600
            tz.transition 1994, 3, :o1, 764697600
            tz.transition 1994, 10, :o2, 781027200
            tz.transition 1995, 3, :o1, 796147200
            tz.transition 1995, 9, :o2, 812476800
            tz.transition 1996, 3, :o1, 828201600
            tz.transition 1996, 10, :o2, 844531200
            tz.transition 1997, 3, :o1, 859651200
            tz.transition 1997, 10, :o2, 875980800
            tz.transition 1998, 3, :o1, 891100800
            tz.transition 1998, 10, :o2, 907430400
            tz.transition 1999, 3, :o1, 922550400
            tz.transition 1999, 10, :o2, 938880000
            tz.transition 2000, 3, :o1, 954000000
            tz.transition 2000, 8, :o2, 967305600
            tz.transition 2001, 3, :o1, 985449600
            tz.transition 2001, 10, :o2, 1002384000
            tz.transition 2002, 3, :o1, 1017504000
            tz.transition 2002, 10, :o2, 1033833600
            tz.transition 2003, 3, :o1, 1048953600
            tz.transition 2003, 10, :o2, 1065283200
            tz.transition 2004, 3, :o1, 1080403200
            tz.transition 2004, 10, :o2, 1096732800
            tz.transition 2005, 3, :o1, 1111852800
            tz.transition 2005, 10, :o2, 1128182400
            tz.transition 2006, 4, :o1, 1143907200
            tz.transition 2006, 9, :o2, 1159632000
            tz.transition 2007, 3, :o1, 1174752000
            tz.transition 2007, 10, :o2, 1191686400
            tz.transition 2008, 4, :o1, 1207411200
            tz.transition 2008, 10, :o2, 1223136000
            tz.transition 2009, 4, :o1, 1238860800
            tz.transition 2009, 10, :o2, 1254585600
            tz.transition 2010, 4, :o1, 1270310400
            tz.transition 2010, 10, :o2, 1286035200
            tz.transition 2011, 4, :o1, 1301760000
            tz.transition 2011, 10, :o2, 1317484800
            tz.transition 2012, 3, :o1, 1333209600
            tz.transition 2012, 10, :o2, 1349539200
            tz.transition 2013, 4, :o1, 1365264000
            tz.transition 2013, 10, :o2, 1380988800
            tz.transition 2014, 4, :o1, 1396713600
            tz.transition 2014, 10, :o2, 1412438400
            tz.transition 2015, 4, :o1, 1428163200
            tz.transition 2015, 10, :o2, 1443888000
            tz.transition 2016, 4, :o1, 1459612800
            tz.transition 2016, 10, :o2, 1475337600
            tz.transition 2017, 4, :o1, 1491062400
            tz.transition 2017, 9, :o2, 1506787200
            tz.transition 2018, 3, :o1, 1522512000
            tz.transition 2018, 10, :o2, 1538841600
            tz.transition 2019, 4, :o1, 1554566400
            tz.transition 2019, 10, :o2, 1570291200
            tz.transition 2020, 4, :o1, 1586016000
            tz.transition 2020, 10, :o2, 1601740800
            tz.transition 2021, 4, :o1, 1617465600
            tz.transition 2021, 10, :o2, 1633190400
            tz.transition 2022, 4, :o1, 1648915200
            tz.transition 2022, 10, :o2, 1664640000
            tz.transition 2023, 4, :o1, 1680364800
            tz.transition 2023, 9, :o2, 1696089600
            tz.transition 2024, 4, :o1, 1712419200
            tz.transition 2024, 10, :o2, 1728144000
            tz.transition 2025, 4, :o1, 1743868800
            tz.transition 2025, 10, :o2, 1759593600
            tz.transition 2026, 4, :o1, 1775318400
            tz.transition 2026, 10, :o2, 1791043200
            tz.transition 2027, 4, :o1, 1806768000
            tz.transition 2027, 10, :o2, 1822492800
            tz.transition 2028, 4, :o1, 1838217600
            tz.transition 2028, 9, :o2, 1853942400
            tz.transition 2029, 3, :o1, 1869667200
            tz.transition 2029, 10, :o2, 1885996800
            tz.transition 2030, 4, :o1, 1901721600
            tz.transition 2030, 10, :o2, 1917446400
            tz.transition 2031, 4, :o1, 1933171200
            tz.transition 2031, 10, :o2, 1948896000
            tz.transition 2032, 4, :o1, 1964620800
            tz.transition 2032, 10, :o2, 1980345600
            tz.transition 2033, 4, :o1, 1996070400
            tz.transition 2033, 10, :o2, 2011795200
            tz.transition 2034, 4, :o1, 2027520000
            tz.transition 2034, 9, :o2, 2043244800
            tz.transition 2035, 3, :o1, 2058969600
            tz.transition 2035, 10, :o2, 2075299200
            tz.transition 2036, 4, :o1, 2091024000
            tz.transition 2036, 10, :o2, 2106748800
            tz.transition 2037, 4, :o1, 2122473600
            tz.transition 2037, 10, :o2, 2138198400
            tz.transition 2038, 4, :o1, 2153923200, 14793103, 6
            tz.transition 2038, 10, :o2, 2169648000, 14794195, 6
            tz.transition 2039, 4, :o1, 2185372800, 14795287, 6
            tz.transition 2039, 10, :o2, 2201097600, 14796379, 6
            tz.transition 2040, 3, :o1, 2216822400, 14797471, 6
            tz.transition 2040, 10, :o2, 2233152000, 14798605, 6
            tz.transition 2041, 4, :o1, 2248876800, 14799697, 6
            tz.transition 2041, 10, :o2, 2264601600, 14800789, 6
            tz.transition 2042, 4, :o1, 2280326400, 14801881, 6
            tz.transition 2042, 10, :o2, 2296051200, 14802973, 6
            tz.transition 2043, 4, :o1, 2311776000, 14804065, 6
            tz.transition 2043, 10, :o2, 2327500800, 14805157, 6
            tz.transition 2044, 4, :o1, 2343225600, 14806249, 6
            tz.transition 2044, 10, :o2, 2358950400, 14807341, 6
            tz.transition 2045, 4, :o1, 2374675200, 14808433, 6
            tz.transition 2045, 9, :o2, 2390400000, 14809525, 6
            tz.transition 2046, 3, :o1, 2406124800, 14810617, 6
            tz.transition 2046, 10, :o2, 2422454400, 14811751, 6
            tz.transition 2047, 4, :o1, 2438179200, 14812843, 6
            tz.transition 2047, 10, :o2, 2453904000, 14813935, 6
            tz.transition 2048, 4, :o1, 2469628800, 14815027, 6
            tz.transition 2048, 10, :o2, 2485353600, 14816119, 6
            tz.transition 2049, 4, :o1, 2501078400, 14817211, 6
            tz.transition 2049, 10, :o2, 2516803200, 14818303, 6
            tz.transition 2050, 4, :o1, 2532528000, 14819395, 6
            tz.transition 2050, 10, :o2, 2548252800, 14820487, 6
            tz.transition 2051, 4, :o1, 2563977600, 14821579, 6
            tz.transition 2051, 9, :o2, 2579702400, 14822671, 6
            tz.transition 2052, 4, :o1, 2596032000, 14823805, 6
            tz.transition 2052, 10, :o2, 2611756800, 14824897, 6
            tz.transition 2053, 4, :o1, 2627481600, 14825989, 6
            tz.transition 2053, 10, :o2, 2643206400, 14827081, 6
            tz.transition 2054, 4, :o1, 2658931200, 14828173, 6
            tz.transition 2054, 10, :o2, 2674656000, 14829265, 6
            tz.transition 2055, 4, :o1, 2690380800, 14830357, 6
            tz.transition 2055, 10, :o2, 2706105600, 14831449, 6
            tz.transition 2056, 4, :o1, 2721830400, 14832541, 6
            tz.transition 2056, 9, :o2, 2737555200, 14833633, 6
            tz.transition 2057, 3, :o1, 2753280000, 14834725, 6
            tz.transition 2057, 10, :o2, 2769609600, 14835859, 6
            tz.transition 2058, 4, :o1, 2785334400, 14836951, 6
            tz.transition 2058, 10, :o2, 2801059200, 14838043, 6
            tz.transition 2059, 4, :o1, 2816784000, 14839135, 6
            tz.transition 2059, 10, :o2, 2832508800, 14840227, 6
            tz.transition 2060, 4, :o1, 2848233600, 14841319, 6
            tz.transition 2060, 10, :o2, 2863958400, 14842411, 6
            tz.transition 2061, 4, :o1, 2879683200, 14843503, 6
            tz.transition 2061, 10, :o2, 2895408000, 14844595, 6
            tz.transition 2062, 4, :o1, 2911132800, 14845687, 6
            tz.transition 2062, 9, :o2, 2926857600, 14846779, 6
            tz.transition 2063, 3, :o1, 2942582400, 14847871, 6
            tz.transition 2063, 10, :o2, 2958912000, 14849005, 6
            tz.transition 2064, 4, :o1, 2974636800, 14850097, 6
            tz.transition 2064, 10, :o2, 2990361600, 14851189, 6
            tz.transition 2065, 4, :o1, 3006086400, 14852281, 6
            tz.transition 2065, 10, :o2, 3021811200, 14853373, 6
            tz.transition 2066, 4, :o1, 3037536000, 14854465, 6
            tz.transition 2066, 10, :o2, 3053260800, 14855557, 6
            tz.transition 2067, 4, :o1, 3068985600, 14856649, 6
            tz.transition 2067, 10, :o2, 3084710400, 14857741, 6
            tz.transition 2068, 3, :o1, 3100435200, 14858833, 6
          end
        end
      end
    end
  end
end
