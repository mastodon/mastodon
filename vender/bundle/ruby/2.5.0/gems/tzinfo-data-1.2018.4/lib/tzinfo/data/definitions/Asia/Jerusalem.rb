# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Jerusalem
          include TimezoneDefinition
          
          timezone 'Asia/Jerusalem' do |tz|
            tz.offset :o0, 8454, 0, :LMT
            tz.offset :o1, 8440, 0, :JMT
            tz.offset :o2, 7200, 0, :IST
            tz.offset :o3, 7200, 3600, :IDT
            tz.offset :o4, 7200, 7200, :IDDT
            
            tz.transition 1879, 12, :o1, -2840149254, 34671101791, 14400
            tz.transition 1917, 12, :o2, -1641003640, 5230643909, 2160
            tz.transition 1940, 5, :o3, -933645600, 29157377, 12
            tz.transition 1942, 10, :o2, -857358000, 19445315, 8
            tz.transition 1943, 4, :o3, -844300800, 4861631, 2
            tz.transition 1943, 10, :o2, -825822000, 19448235, 8
            tz.transition 1944, 3, :o3, -812685600, 29174177, 12
            tz.transition 1944, 10, :o2, -794199600, 19451163, 8
            tz.transition 1945, 4, :o3, -779853600, 29178737, 12
            tz.transition 1945, 10, :o2, -762656400, 58362251, 24
            tz.transition 1946, 4, :o3, -748310400, 4863853, 2
            tz.transition 1946, 10, :o2, -731127600, 19457003, 8
            tz.transition 1948, 5, :o4, -681962400, 29192333, 12
            tz.transition 1948, 8, :o3, -673243200, 7298386, 3
            tz.transition 1948, 10, :o2, -667962000, 58388555, 24
            tz.transition 1949, 4, :o3, -652327200, 29196449, 12
            tz.transition 1949, 10, :o2, -636426000, 58397315, 24
            tz.transition 1950, 4, :o3, -622087200, 29200649, 12
            tz.transition 1950, 9, :o2, -608947200, 4867079, 2
            tz.transition 1951, 3, :o3, -591847200, 29204849, 12
            tz.transition 1951, 11, :o2, -572486400, 4867923, 2
            tz.transition 1952, 4, :o3, -558576000, 4868245, 2
            tz.transition 1952, 10, :o2, -542851200, 4868609, 2
            tz.transition 1953, 4, :o3, -527731200, 4868959, 2
            tz.transition 1953, 9, :o2, -514425600, 4869267, 2
            tz.transition 1954, 6, :o3, -490845600, 29218877, 12
            tz.transition 1954, 9, :o2, -482986800, 19479979, 8
            tz.transition 1955, 6, :o3, -459475200, 4870539, 2
            tz.transition 1955, 9, :o2, -451537200, 19482891, 8
            tz.transition 1956, 6, :o3, -428551200, 29227529, 12
            tz.transition 1956, 9, :o2, -418262400, 4871493, 2
            tz.transition 1957, 4, :o3, -400032000, 4871915, 2
            tz.transition 1957, 9, :o2, -387428400, 19488827, 8
            tz.transition 1974, 7, :o3, 142380000
            tz.transition 1974, 10, :o2, 150843600
            tz.transition 1975, 4, :o3, 167176800
            tz.transition 1975, 8, :o2, 178664400
            tz.transition 1985, 4, :o3, 482277600
            tz.transition 1985, 9, :o2, 495579600
            tz.transition 1986, 5, :o3, 516751200
            tz.transition 1986, 9, :o2, 526424400
            tz.transition 1987, 4, :o3, 545436000
            tz.transition 1987, 9, :o2, 558478800
            tz.transition 1988, 4, :o3, 576626400
            tz.transition 1988, 9, :o2, 589323600
            tz.transition 1989, 4, :o3, 609890400
            tz.transition 1989, 9, :o2, 620773200
            tz.transition 1990, 3, :o3, 638316000
            tz.transition 1990, 8, :o2, 651618000
            tz.transition 1991, 3, :o3, 669765600
            tz.transition 1991, 8, :o2, 683672400
            tz.transition 1992, 3, :o3, 701820000
            tz.transition 1992, 9, :o2, 715726800
            tz.transition 1993, 4, :o3, 733701600
            tz.transition 1993, 9, :o2, 747176400
            tz.transition 1994, 3, :o3, 765151200
            tz.transition 1994, 8, :o2, 778021200
            tz.transition 1995, 3, :o3, 796600800
            tz.transition 1995, 9, :o2, 810075600
            tz.transition 1996, 3, :o3, 826840800
            tz.transition 1996, 9, :o2, 842821200
            tz.transition 1997, 3, :o3, 858895200
            tz.transition 1997, 9, :o2, 874184400
            tz.transition 1998, 3, :o3, 890344800
            tz.transition 1998, 9, :o2, 905029200
            tz.transition 1999, 4, :o3, 923011200
            tz.transition 1999, 9, :o2, 936313200
            tz.transition 2000, 4, :o3, 955670400
            tz.transition 2000, 10, :o2, 970783200
            tz.transition 2001, 4, :o3, 986770800
            tz.transition 2001, 9, :o2, 1001282400
            tz.transition 2002, 3, :o3, 1017356400
            tz.transition 2002, 10, :o2, 1033941600
            tz.transition 2003, 3, :o3, 1048806000
            tz.transition 2003, 10, :o2, 1065132000
            tz.transition 2004, 4, :o3, 1081292400
            tz.transition 2004, 9, :o2, 1095804000
            tz.transition 2005, 4, :o3, 1112313600
            tz.transition 2005, 10, :o2, 1128812400
            tz.transition 2006, 3, :o3, 1143763200
            tz.transition 2006, 9, :o2, 1159657200
            tz.transition 2007, 3, :o3, 1175212800
            tz.transition 2007, 9, :o2, 1189897200
            tz.transition 2008, 3, :o3, 1206662400
            tz.transition 2008, 10, :o2, 1223161200
            tz.transition 2009, 3, :o3, 1238112000
            tz.transition 2009, 9, :o2, 1254006000
            tz.transition 2010, 3, :o3, 1269561600
            tz.transition 2010, 9, :o2, 1284246000
            tz.transition 2011, 4, :o3, 1301616000
            tz.transition 2011, 10, :o2, 1317510000
            tz.transition 2012, 3, :o3, 1333065600
            tz.transition 2012, 9, :o2, 1348354800
            tz.transition 2013, 3, :o3, 1364515200
            tz.transition 2013, 10, :o2, 1382828400
            tz.transition 2014, 3, :o3, 1395964800
            tz.transition 2014, 10, :o2, 1414278000
            tz.transition 2015, 3, :o3, 1427414400
            tz.transition 2015, 10, :o2, 1445727600
            tz.transition 2016, 3, :o3, 1458864000
            tz.transition 2016, 10, :o2, 1477782000
            tz.transition 2017, 3, :o3, 1490313600
            tz.transition 2017, 10, :o2, 1509231600
            tz.transition 2018, 3, :o3, 1521763200
            tz.transition 2018, 10, :o2, 1540681200
            tz.transition 2019, 3, :o3, 1553817600
            tz.transition 2019, 10, :o2, 1572130800
            tz.transition 2020, 3, :o3, 1585267200
            tz.transition 2020, 10, :o2, 1603580400
            tz.transition 2021, 3, :o3, 1616716800
            tz.transition 2021, 10, :o2, 1635634800
            tz.transition 2022, 3, :o3, 1648166400
            tz.transition 2022, 10, :o2, 1667084400
            tz.transition 2023, 3, :o3, 1679616000
            tz.transition 2023, 10, :o2, 1698534000
            tz.transition 2024, 3, :o3, 1711670400
            tz.transition 2024, 10, :o2, 1729983600
            tz.transition 2025, 3, :o3, 1743120000
            tz.transition 2025, 10, :o2, 1761433200
            tz.transition 2026, 3, :o3, 1774569600
            tz.transition 2026, 10, :o2, 1792882800
            tz.transition 2027, 3, :o3, 1806019200
            tz.transition 2027, 10, :o2, 1824937200
            tz.transition 2028, 3, :o3, 1837468800
            tz.transition 2028, 10, :o2, 1856386800
            tz.transition 2029, 3, :o3, 1868918400
            tz.transition 2029, 10, :o2, 1887836400
            tz.transition 2030, 3, :o3, 1900972800
            tz.transition 2030, 10, :o2, 1919286000
            tz.transition 2031, 3, :o3, 1932422400
            tz.transition 2031, 10, :o2, 1950735600
            tz.transition 2032, 3, :o3, 1963872000
            tz.transition 2032, 10, :o2, 1982790000
            tz.transition 2033, 3, :o3, 1995321600
            tz.transition 2033, 10, :o2, 2014239600
            tz.transition 2034, 3, :o3, 2026771200
            tz.transition 2034, 10, :o2, 2045689200
            tz.transition 2035, 3, :o3, 2058220800
            tz.transition 2035, 10, :o2, 2077138800
            tz.transition 2036, 3, :o3, 2090275200
            tz.transition 2036, 10, :o2, 2108588400
            tz.transition 2037, 3, :o3, 2121724800
            tz.transition 2037, 10, :o2, 2140038000
            tz.transition 2038, 3, :o3, 2153174400, 4931017, 2
            tz.transition 2038, 10, :o2, 2172092400, 59177459, 24
            tz.transition 2039, 3, :o3, 2184624000, 4931745, 2
            tz.transition 2039, 10, :o2, 2203542000, 59186195, 24
            tz.transition 2040, 3, :o3, 2216073600, 4932473, 2
            tz.transition 2040, 10, :o2, 2234991600, 59194931, 24
            tz.transition 2041, 3, :o3, 2248128000, 4933215, 2
            tz.transition 2041, 10, :o2, 2266441200, 59203667, 24
            tz.transition 2042, 3, :o3, 2279577600, 4933943, 2
            tz.transition 2042, 10, :o2, 2297890800, 59212403, 24
            tz.transition 2043, 3, :o3, 2311027200, 4934671, 2
            tz.transition 2043, 10, :o2, 2329340400, 59221139, 24
            tz.transition 2044, 3, :o3, 2342476800, 4935399, 2
            tz.transition 2044, 10, :o2, 2361394800, 59230043, 24
            tz.transition 2045, 3, :o3, 2373926400, 4936127, 2
            tz.transition 2045, 10, :o2, 2392844400, 59238779, 24
            tz.transition 2046, 3, :o3, 2405376000, 4936855, 2
            tz.transition 2046, 10, :o2, 2424294000, 59247515, 24
            tz.transition 2047, 3, :o3, 2437430400, 4937597, 2
            tz.transition 2047, 10, :o2, 2455743600, 59256251, 24
            tz.transition 2048, 3, :o3, 2468880000, 4938325, 2
            tz.transition 2048, 10, :o2, 2487193200, 59264987, 24
            tz.transition 2049, 3, :o3, 2500329600, 4939053, 2
            tz.transition 2049, 10, :o2, 2519247600, 59273891, 24
            tz.transition 2050, 3, :o3, 2531779200, 4939781, 2
            tz.transition 2050, 10, :o2, 2550697200, 59282627, 24
            tz.transition 2051, 3, :o3, 2563228800, 4940509, 2
            tz.transition 2051, 10, :o2, 2582146800, 59291363, 24
            tz.transition 2052, 3, :o3, 2595283200, 4941251, 2
            tz.transition 2052, 10, :o2, 2613596400, 59300099, 24
            tz.transition 2053, 3, :o3, 2626732800, 4941979, 2
            tz.transition 2053, 10, :o2, 2645046000, 59308835, 24
            tz.transition 2054, 3, :o3, 2658182400, 4942707, 2
            tz.transition 2054, 10, :o2, 2676495600, 59317571, 24
            tz.transition 2055, 3, :o3, 2689632000, 4943435, 2
            tz.transition 2055, 10, :o2, 2708550000, 59326475, 24
            tz.transition 2056, 3, :o3, 2721081600, 4944163, 2
            tz.transition 2056, 10, :o2, 2739999600, 59335211, 24
            tz.transition 2057, 3, :o3, 2752531200, 4944891, 2
            tz.transition 2057, 10, :o2, 2771449200, 59343947, 24
            tz.transition 2058, 3, :o3, 2784585600, 4945633, 2
            tz.transition 2058, 10, :o2, 2802898800, 59352683, 24
            tz.transition 2059, 3, :o3, 2816035200, 4946361, 2
            tz.transition 2059, 10, :o2, 2834348400, 59361419, 24
            tz.transition 2060, 3, :o3, 2847484800, 4947089, 2
            tz.transition 2060, 10, :o2, 2866402800, 59370323, 24
            tz.transition 2061, 3, :o3, 2878934400, 4947817, 2
            tz.transition 2061, 10, :o2, 2897852400, 59379059, 24
            tz.transition 2062, 3, :o3, 2910384000, 4948545, 2
            tz.transition 2062, 10, :o2, 2929302000, 59387795, 24
            tz.transition 2063, 3, :o3, 2941833600, 4949273, 2
            tz.transition 2063, 10, :o2, 2960751600, 59396531, 24
            tz.transition 2064, 3, :o3, 2973888000, 4950015, 2
            tz.transition 2064, 10, :o2, 2992201200, 59405267, 24
            tz.transition 2065, 3, :o3, 3005337600, 4950743, 2
            tz.transition 2065, 10, :o2, 3023650800, 59414003, 24
            tz.transition 2066, 3, :o3, 3036787200, 4951471, 2
            tz.transition 2066, 10, :o2, 3055705200, 59422907, 24
            tz.transition 2067, 3, :o3, 3068236800, 4952199, 2
            tz.transition 2067, 10, :o2, 3087154800, 59431643, 24
            tz.transition 2068, 3, :o3, 3099686400, 4952927, 2
            tz.transition 2068, 10, :o2, 3118604400, 59440379, 24
          end
        end
      end
    end
  end
end
