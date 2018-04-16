# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Riga
          include TimezoneDefinition
          
          timezone 'Europe/Riga' do |tz|
            tz.offset :o0, 5794, 0, :LMT
            tz.offset :o1, 5794, 0, :RMT
            tz.offset :o2, 5794, 3600, :LST
            tz.offset :o3, 7200, 0, :EET
            tz.offset :o4, 10800, 0, :MSK
            tz.offset :o5, 3600, 3600, :CEST
            tz.offset :o6, 3600, 0, :CET
            tz.offset :o7, 10800, 3600, :MSD
            tz.offset :o8, 7200, 3600, :EEST
            
            tz.transition 1879, 12, :o1, -2840146594, 104013306703, 43200
            tz.transition 1918, 4, :o2, -1632008194, 104617375903, 43200
            tz.transition 1918, 9, :o1, -1618702594, 104624028703, 43200
            tz.transition 1919, 4, :o2, -1601681794, 104632539103, 43200
            tz.transition 1919, 5, :o1, -1597275394, 104634742303, 43200
            tz.transition 1926, 5, :o3, -1377308194, 104744725903, 43200
            tz.transition 1940, 8, :o4, -928029600, 29158157, 12
            tz.transition 1941, 6, :o5, -899521200, 19441411, 8
            tz.transition 1942, 11, :o6, -857257200, 58335973, 24
            tz.transition 1943, 3, :o5, -844556400, 58339501, 24
            tz.transition 1943, 10, :o6, -828226800, 58344037, 24
            tz.transition 1944, 4, :o5, -812502000, 58348405, 24
            tz.transition 1944, 10, :o6, -796777200, 58352773, 24
            tz.transition 1944, 10, :o4, -795834000, 58353035, 24
            tz.transition 1981, 3, :o7, 354920400
            tz.transition 1981, 9, :o4, 370728000
            tz.transition 1982, 3, :o7, 386456400
            tz.transition 1982, 9, :o4, 402264000
            tz.transition 1983, 3, :o7, 417992400
            tz.transition 1983, 9, :o4, 433800000
            tz.transition 1984, 3, :o7, 449614800
            tz.transition 1984, 9, :o4, 465346800
            tz.transition 1985, 3, :o7, 481071600
            tz.transition 1985, 9, :o4, 496796400
            tz.transition 1986, 3, :o7, 512521200
            tz.transition 1986, 9, :o4, 528246000
            tz.transition 1987, 3, :o7, 543970800
            tz.transition 1987, 9, :o4, 559695600
            tz.transition 1988, 3, :o7, 575420400
            tz.transition 1988, 9, :o4, 591145200
            tz.transition 1989, 3, :o8, 606870000
            tz.transition 1989, 9, :o3, 622598400
            tz.transition 1990, 3, :o8, 638323200
            tz.transition 1990, 9, :o3, 654652800
            tz.transition 1991, 3, :o8, 670377600
            tz.transition 1991, 9, :o3, 686102400
            tz.transition 1992, 3, :o8, 701827200
            tz.transition 1992, 9, :o3, 717552000
            tz.transition 1993, 3, :o8, 733276800
            tz.transition 1993, 9, :o3, 749001600
            tz.transition 1994, 3, :o8, 764726400
            tz.transition 1994, 9, :o3, 780451200
            tz.transition 1995, 3, :o8, 796176000
            tz.transition 1995, 9, :o3, 811900800
            tz.transition 1996, 3, :o8, 828230400
            tz.transition 1996, 9, :o3, 843955200
            tz.transition 1997, 3, :o8, 859683600
            tz.transition 1997, 10, :o3, 877827600
            tz.transition 1998, 3, :o8, 891133200
            tz.transition 1998, 10, :o3, 909277200
            tz.transition 1999, 3, :o8, 922582800
            tz.transition 1999, 10, :o3, 941331600
            tz.transition 2001, 3, :o8, 985482000
            tz.transition 2001, 10, :o3, 1004230800
            tz.transition 2002, 3, :o8, 1017536400
            tz.transition 2002, 10, :o3, 1035680400
            tz.transition 2003, 3, :o8, 1048986000
            tz.transition 2003, 10, :o3, 1067130000
            tz.transition 2004, 3, :o8, 1080435600
            tz.transition 2004, 10, :o3, 1099184400
            tz.transition 2005, 3, :o8, 1111885200
            tz.transition 2005, 10, :o3, 1130634000
            tz.transition 2006, 3, :o8, 1143334800
            tz.transition 2006, 10, :o3, 1162083600
            tz.transition 2007, 3, :o8, 1174784400
            tz.transition 2007, 10, :o3, 1193533200
            tz.transition 2008, 3, :o8, 1206838800
            tz.transition 2008, 10, :o3, 1224982800
            tz.transition 2009, 3, :o8, 1238288400
            tz.transition 2009, 10, :o3, 1256432400
            tz.transition 2010, 3, :o8, 1269738000
            tz.transition 2010, 10, :o3, 1288486800
            tz.transition 2011, 3, :o8, 1301187600
            tz.transition 2011, 10, :o3, 1319936400
            tz.transition 2012, 3, :o8, 1332637200
            tz.transition 2012, 10, :o3, 1351386000
            tz.transition 2013, 3, :o8, 1364691600
            tz.transition 2013, 10, :o3, 1382835600
            tz.transition 2014, 3, :o8, 1396141200
            tz.transition 2014, 10, :o3, 1414285200
            tz.transition 2015, 3, :o8, 1427590800
            tz.transition 2015, 10, :o3, 1445734800
            tz.transition 2016, 3, :o8, 1459040400
            tz.transition 2016, 10, :o3, 1477789200
            tz.transition 2017, 3, :o8, 1490490000
            tz.transition 2017, 10, :o3, 1509238800
            tz.transition 2018, 3, :o8, 1521939600
            tz.transition 2018, 10, :o3, 1540688400
            tz.transition 2019, 3, :o8, 1553994000
            tz.transition 2019, 10, :o3, 1572138000
            tz.transition 2020, 3, :o8, 1585443600
            tz.transition 2020, 10, :o3, 1603587600
            tz.transition 2021, 3, :o8, 1616893200
            tz.transition 2021, 10, :o3, 1635642000
            tz.transition 2022, 3, :o8, 1648342800
            tz.transition 2022, 10, :o3, 1667091600
            tz.transition 2023, 3, :o8, 1679792400
            tz.transition 2023, 10, :o3, 1698541200
            tz.transition 2024, 3, :o8, 1711846800
            tz.transition 2024, 10, :o3, 1729990800
            tz.transition 2025, 3, :o8, 1743296400
            tz.transition 2025, 10, :o3, 1761440400
            tz.transition 2026, 3, :o8, 1774746000
            tz.transition 2026, 10, :o3, 1792890000
            tz.transition 2027, 3, :o8, 1806195600
            tz.transition 2027, 10, :o3, 1824944400
            tz.transition 2028, 3, :o8, 1837645200
            tz.transition 2028, 10, :o3, 1856394000
            tz.transition 2029, 3, :o8, 1869094800
            tz.transition 2029, 10, :o3, 1887843600
            tz.transition 2030, 3, :o8, 1901149200
            tz.transition 2030, 10, :o3, 1919293200
            tz.transition 2031, 3, :o8, 1932598800
            tz.transition 2031, 10, :o3, 1950742800
            tz.transition 2032, 3, :o8, 1964048400
            tz.transition 2032, 10, :o3, 1982797200
            tz.transition 2033, 3, :o8, 1995498000
            tz.transition 2033, 10, :o3, 2014246800
            tz.transition 2034, 3, :o8, 2026947600
            tz.transition 2034, 10, :o3, 2045696400
            tz.transition 2035, 3, :o8, 2058397200
            tz.transition 2035, 10, :o3, 2077146000
            tz.transition 2036, 3, :o8, 2090451600
            tz.transition 2036, 10, :o3, 2108595600
            tz.transition 2037, 3, :o8, 2121901200
            tz.transition 2037, 10, :o3, 2140045200
            tz.transition 2038, 3, :o8, 2153350800, 59172253, 24
            tz.transition 2038, 10, :o3, 2172099600, 59177461, 24
            tz.transition 2039, 3, :o8, 2184800400, 59180989, 24
            tz.transition 2039, 10, :o3, 2203549200, 59186197, 24
            tz.transition 2040, 3, :o8, 2216250000, 59189725, 24
            tz.transition 2040, 10, :o3, 2234998800, 59194933, 24
            tz.transition 2041, 3, :o8, 2248304400, 59198629, 24
            tz.transition 2041, 10, :o3, 2266448400, 59203669, 24
            tz.transition 2042, 3, :o8, 2279754000, 59207365, 24
            tz.transition 2042, 10, :o3, 2297898000, 59212405, 24
            tz.transition 2043, 3, :o8, 2311203600, 59216101, 24
            tz.transition 2043, 10, :o3, 2329347600, 59221141, 24
            tz.transition 2044, 3, :o8, 2342653200, 59224837, 24
            tz.transition 2044, 10, :o3, 2361402000, 59230045, 24
            tz.transition 2045, 3, :o8, 2374102800, 59233573, 24
            tz.transition 2045, 10, :o3, 2392851600, 59238781, 24
            tz.transition 2046, 3, :o8, 2405552400, 59242309, 24
            tz.transition 2046, 10, :o3, 2424301200, 59247517, 24
            tz.transition 2047, 3, :o8, 2437606800, 59251213, 24
            tz.transition 2047, 10, :o3, 2455750800, 59256253, 24
            tz.transition 2048, 3, :o8, 2469056400, 59259949, 24
            tz.transition 2048, 10, :o3, 2487200400, 59264989, 24
            tz.transition 2049, 3, :o8, 2500506000, 59268685, 24
            tz.transition 2049, 10, :o3, 2519254800, 59273893, 24
            tz.transition 2050, 3, :o8, 2531955600, 59277421, 24
            tz.transition 2050, 10, :o3, 2550704400, 59282629, 24
            tz.transition 2051, 3, :o8, 2563405200, 59286157, 24
            tz.transition 2051, 10, :o3, 2582154000, 59291365, 24
            tz.transition 2052, 3, :o8, 2595459600, 59295061, 24
            tz.transition 2052, 10, :o3, 2613603600, 59300101, 24
            tz.transition 2053, 3, :o8, 2626909200, 59303797, 24
            tz.transition 2053, 10, :o3, 2645053200, 59308837, 24
            tz.transition 2054, 3, :o8, 2658358800, 59312533, 24
            tz.transition 2054, 10, :o3, 2676502800, 59317573, 24
            tz.transition 2055, 3, :o8, 2689808400, 59321269, 24
            tz.transition 2055, 10, :o3, 2708557200, 59326477, 24
            tz.transition 2056, 3, :o8, 2721258000, 59330005, 24
            tz.transition 2056, 10, :o3, 2740006800, 59335213, 24
            tz.transition 2057, 3, :o8, 2752707600, 59338741, 24
            tz.transition 2057, 10, :o3, 2771456400, 59343949, 24
            tz.transition 2058, 3, :o8, 2784762000, 59347645, 24
            tz.transition 2058, 10, :o3, 2802906000, 59352685, 24
            tz.transition 2059, 3, :o8, 2816211600, 59356381, 24
            tz.transition 2059, 10, :o3, 2834355600, 59361421, 24
            tz.transition 2060, 3, :o8, 2847661200, 59365117, 24
            tz.transition 2060, 10, :o3, 2866410000, 59370325, 24
            tz.transition 2061, 3, :o8, 2879110800, 59373853, 24
            tz.transition 2061, 10, :o3, 2897859600, 59379061, 24
            tz.transition 2062, 3, :o8, 2910560400, 59382589, 24
            tz.transition 2062, 10, :o3, 2929309200, 59387797, 24
            tz.transition 2063, 3, :o8, 2942010000, 59391325, 24
            tz.transition 2063, 10, :o3, 2960758800, 59396533, 24
            tz.transition 2064, 3, :o8, 2974064400, 59400229, 24
            tz.transition 2064, 10, :o3, 2992208400, 59405269, 24
            tz.transition 2065, 3, :o8, 3005514000, 59408965, 24
            tz.transition 2065, 10, :o3, 3023658000, 59414005, 24
            tz.transition 2066, 3, :o8, 3036963600, 59417701, 24
            tz.transition 2066, 10, :o3, 3055712400, 59422909, 24
            tz.transition 2067, 3, :o8, 3068413200, 59426437, 24
            tz.transition 2067, 10, :o3, 3087162000, 59431645, 24
            tz.transition 2068, 3, :o8, 3099862800, 59435173, 24
            tz.transition 2068, 10, :o3, 3118611600, 59440381, 24
          end
        end
      end
    end
  end
end
