# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Madrid
          include TimezoneDefinition
          
          timezone 'Europe/Madrid' do |tz|
            tz.offset :o0, -884, 0, :LMT
            tz.offset :o1, 0, 0, :WET
            tz.offset :o2, 0, 3600, :WEST
            tz.offset :o3, 0, 7200, :WEMT
            tz.offset :o4, 3600, 0, :CET
            tz.offset :o5, 3600, 3600, :CEST
            
            tz.transition 1901, 1, :o1, -2177452800, 4830771, 2
            tz.transition 1918, 4, :o2, -1631926800, 58120787, 24
            tz.transition 1918, 10, :o1, -1616889600, 4843747, 2
            tz.transition 1919, 4, :o2, -1601168400, 58129331, 24
            tz.transition 1919, 10, :o1, -1585353600, 4844477, 2
            tz.transition 1924, 4, :o2, -1442451600, 58173419, 24
            tz.transition 1924, 10, :o1, -1427673600, 4848127, 2
            tz.transition 1926, 4, :o2, -1379293200, 58190963, 24
            tz.transition 1926, 10, :o1, -1364774400, 4849583, 2
            tz.transition 1927, 4, :o2, -1348448400, 58199531, 24
            tz.transition 1927, 10, :o1, -1333324800, 4850311, 2
            tz.transition 1928, 4, :o2, -1316390400, 4850703, 2
            tz.transition 1928, 10, :o1, -1301270400, 4851053, 2
            tz.transition 1929, 4, :o2, -1284339600, 58217339, 24
            tz.transition 1929, 10, :o1, -1269820800, 4851781, 2
            tz.transition 1937, 6, :o2, -1026954000, 58288835, 24
            tz.transition 1937, 10, :o1, -1017619200, 4857619, 2
            tz.transition 1938, 4, :o2, -1001898000, 58295795, 24
            tz.transition 1938, 4, :o3, -999482400, 29148233, 12
            tz.transition 1938, 10, :o2, -986090400, 29150093, 12
            tz.transition 1939, 10, :o1, -954115200, 4859089, 2
            tz.transition 1940, 3, :o4, -940208400, 58312931, 24
            tz.transition 1942, 5, :o5, -873079200, 29165789, 12
            tz.transition 1942, 8, :o4, -862621200, 58334483, 24
            tz.transition 1943, 4, :o5, -842839200, 29169989, 12
            tz.transition 1943, 10, :o4, -828320400, 58344011, 24
            tz.transition 1944, 4, :o5, -811389600, 29174357, 12
            tz.transition 1944, 9, :o4, -796870800, 58352747, 24
            tz.transition 1945, 4, :o5, -779940000, 29178725, 12
            tz.transition 1945, 9, :o4, -765421200, 58361483, 24
            tz.transition 1946, 4, :o5, -748490400, 29183093, 12
            tz.transition 1946, 9, :o4, -733971600, 58370219, 24
            tz.transition 1949, 4, :o5, -652327200, 29196449, 12
            tz.transition 1949, 10, :o4, -639018000, 58396595, 24
            tz.transition 1974, 4, :o5, 135122400
            tz.transition 1974, 10, :o4, 150246000
            tz.transition 1975, 4, :o5, 166572000
            tz.transition 1975, 10, :o4, 181695600
            tz.transition 1976, 3, :o5, 196812000
            tz.transition 1976, 9, :o4, 212540400
            tz.transition 1977, 4, :o5, 228866400
            tz.transition 1977, 9, :o4, 243990000
            tz.transition 1978, 4, :o5, 260326800
            tz.transition 1978, 10, :o4, 276051600
            tz.transition 1979, 4, :o5, 291776400
            tz.transition 1979, 9, :o4, 307501200
            tz.transition 1980, 4, :o5, 323830800
            tz.transition 1980, 9, :o4, 338950800
            tz.transition 1981, 3, :o5, 354675600
            tz.transition 1981, 9, :o4, 370400400
            tz.transition 1982, 3, :o5, 386125200
            tz.transition 1982, 9, :o4, 401850000
            tz.transition 1983, 3, :o5, 417574800
            tz.transition 1983, 9, :o4, 433299600
            tz.transition 1984, 3, :o5, 449024400
            tz.transition 1984, 9, :o4, 465354000
            tz.transition 1985, 3, :o5, 481078800
            tz.transition 1985, 9, :o4, 496803600
            tz.transition 1986, 3, :o5, 512528400
            tz.transition 1986, 9, :o4, 528253200
            tz.transition 1987, 3, :o5, 543978000
            tz.transition 1987, 9, :o4, 559702800
            tz.transition 1988, 3, :o5, 575427600
            tz.transition 1988, 9, :o4, 591152400
            tz.transition 1989, 3, :o5, 606877200
            tz.transition 1989, 9, :o4, 622602000
            tz.transition 1990, 3, :o5, 638326800
            tz.transition 1990, 9, :o4, 654656400
            tz.transition 1991, 3, :o5, 670381200
            tz.transition 1991, 9, :o4, 686106000
            tz.transition 1992, 3, :o5, 701830800
            tz.transition 1992, 9, :o4, 717555600
            tz.transition 1993, 3, :o5, 733280400
            tz.transition 1993, 9, :o4, 749005200
            tz.transition 1994, 3, :o5, 764730000
            tz.transition 1994, 9, :o4, 780454800
            tz.transition 1995, 3, :o5, 796179600
            tz.transition 1995, 9, :o4, 811904400
            tz.transition 1996, 3, :o5, 828234000
            tz.transition 1996, 10, :o4, 846378000
            tz.transition 1997, 3, :o5, 859683600
            tz.transition 1997, 10, :o4, 877827600
            tz.transition 1998, 3, :o5, 891133200
            tz.transition 1998, 10, :o4, 909277200
            tz.transition 1999, 3, :o5, 922582800
            tz.transition 1999, 10, :o4, 941331600
            tz.transition 2000, 3, :o5, 954032400
            tz.transition 2000, 10, :o4, 972781200
            tz.transition 2001, 3, :o5, 985482000
            tz.transition 2001, 10, :o4, 1004230800
            tz.transition 2002, 3, :o5, 1017536400
            tz.transition 2002, 10, :o4, 1035680400
            tz.transition 2003, 3, :o5, 1048986000
            tz.transition 2003, 10, :o4, 1067130000
            tz.transition 2004, 3, :o5, 1080435600
            tz.transition 2004, 10, :o4, 1099184400
            tz.transition 2005, 3, :o5, 1111885200
            tz.transition 2005, 10, :o4, 1130634000
            tz.transition 2006, 3, :o5, 1143334800
            tz.transition 2006, 10, :o4, 1162083600
            tz.transition 2007, 3, :o5, 1174784400
            tz.transition 2007, 10, :o4, 1193533200
            tz.transition 2008, 3, :o5, 1206838800
            tz.transition 2008, 10, :o4, 1224982800
            tz.transition 2009, 3, :o5, 1238288400
            tz.transition 2009, 10, :o4, 1256432400
            tz.transition 2010, 3, :o5, 1269738000
            tz.transition 2010, 10, :o4, 1288486800
            tz.transition 2011, 3, :o5, 1301187600
            tz.transition 2011, 10, :o4, 1319936400
            tz.transition 2012, 3, :o5, 1332637200
            tz.transition 2012, 10, :o4, 1351386000
            tz.transition 2013, 3, :o5, 1364691600
            tz.transition 2013, 10, :o4, 1382835600
            tz.transition 2014, 3, :o5, 1396141200
            tz.transition 2014, 10, :o4, 1414285200
            tz.transition 2015, 3, :o5, 1427590800
            tz.transition 2015, 10, :o4, 1445734800
            tz.transition 2016, 3, :o5, 1459040400
            tz.transition 2016, 10, :o4, 1477789200
            tz.transition 2017, 3, :o5, 1490490000
            tz.transition 2017, 10, :o4, 1509238800
            tz.transition 2018, 3, :o5, 1521939600
            tz.transition 2018, 10, :o4, 1540688400
            tz.transition 2019, 3, :o5, 1553994000
            tz.transition 2019, 10, :o4, 1572138000
            tz.transition 2020, 3, :o5, 1585443600
            tz.transition 2020, 10, :o4, 1603587600
            tz.transition 2021, 3, :o5, 1616893200
            tz.transition 2021, 10, :o4, 1635642000
            tz.transition 2022, 3, :o5, 1648342800
            tz.transition 2022, 10, :o4, 1667091600
            tz.transition 2023, 3, :o5, 1679792400
            tz.transition 2023, 10, :o4, 1698541200
            tz.transition 2024, 3, :o5, 1711846800
            tz.transition 2024, 10, :o4, 1729990800
            tz.transition 2025, 3, :o5, 1743296400
            tz.transition 2025, 10, :o4, 1761440400
            tz.transition 2026, 3, :o5, 1774746000
            tz.transition 2026, 10, :o4, 1792890000
            tz.transition 2027, 3, :o5, 1806195600
            tz.transition 2027, 10, :o4, 1824944400
            tz.transition 2028, 3, :o5, 1837645200
            tz.transition 2028, 10, :o4, 1856394000
            tz.transition 2029, 3, :o5, 1869094800
            tz.transition 2029, 10, :o4, 1887843600
            tz.transition 2030, 3, :o5, 1901149200
            tz.transition 2030, 10, :o4, 1919293200
            tz.transition 2031, 3, :o5, 1932598800
            tz.transition 2031, 10, :o4, 1950742800
            tz.transition 2032, 3, :o5, 1964048400
            tz.transition 2032, 10, :o4, 1982797200
            tz.transition 2033, 3, :o5, 1995498000
            tz.transition 2033, 10, :o4, 2014246800
            tz.transition 2034, 3, :o5, 2026947600
            tz.transition 2034, 10, :o4, 2045696400
            tz.transition 2035, 3, :o5, 2058397200
            tz.transition 2035, 10, :o4, 2077146000
            tz.transition 2036, 3, :o5, 2090451600
            tz.transition 2036, 10, :o4, 2108595600
            tz.transition 2037, 3, :o5, 2121901200
            tz.transition 2037, 10, :o4, 2140045200
            tz.transition 2038, 3, :o5, 2153350800, 59172253, 24
            tz.transition 2038, 10, :o4, 2172099600, 59177461, 24
            tz.transition 2039, 3, :o5, 2184800400, 59180989, 24
            tz.transition 2039, 10, :o4, 2203549200, 59186197, 24
            tz.transition 2040, 3, :o5, 2216250000, 59189725, 24
            tz.transition 2040, 10, :o4, 2234998800, 59194933, 24
            tz.transition 2041, 3, :o5, 2248304400, 59198629, 24
            tz.transition 2041, 10, :o4, 2266448400, 59203669, 24
            tz.transition 2042, 3, :o5, 2279754000, 59207365, 24
            tz.transition 2042, 10, :o4, 2297898000, 59212405, 24
            tz.transition 2043, 3, :o5, 2311203600, 59216101, 24
            tz.transition 2043, 10, :o4, 2329347600, 59221141, 24
            tz.transition 2044, 3, :o5, 2342653200, 59224837, 24
            tz.transition 2044, 10, :o4, 2361402000, 59230045, 24
            tz.transition 2045, 3, :o5, 2374102800, 59233573, 24
            tz.transition 2045, 10, :o4, 2392851600, 59238781, 24
            tz.transition 2046, 3, :o5, 2405552400, 59242309, 24
            tz.transition 2046, 10, :o4, 2424301200, 59247517, 24
            tz.transition 2047, 3, :o5, 2437606800, 59251213, 24
            tz.transition 2047, 10, :o4, 2455750800, 59256253, 24
            tz.transition 2048, 3, :o5, 2469056400, 59259949, 24
            tz.transition 2048, 10, :o4, 2487200400, 59264989, 24
            tz.transition 2049, 3, :o5, 2500506000, 59268685, 24
            tz.transition 2049, 10, :o4, 2519254800, 59273893, 24
            tz.transition 2050, 3, :o5, 2531955600, 59277421, 24
            tz.transition 2050, 10, :o4, 2550704400, 59282629, 24
            tz.transition 2051, 3, :o5, 2563405200, 59286157, 24
            tz.transition 2051, 10, :o4, 2582154000, 59291365, 24
            tz.transition 2052, 3, :o5, 2595459600, 59295061, 24
            tz.transition 2052, 10, :o4, 2613603600, 59300101, 24
            tz.transition 2053, 3, :o5, 2626909200, 59303797, 24
            tz.transition 2053, 10, :o4, 2645053200, 59308837, 24
            tz.transition 2054, 3, :o5, 2658358800, 59312533, 24
            tz.transition 2054, 10, :o4, 2676502800, 59317573, 24
            tz.transition 2055, 3, :o5, 2689808400, 59321269, 24
            tz.transition 2055, 10, :o4, 2708557200, 59326477, 24
            tz.transition 2056, 3, :o5, 2721258000, 59330005, 24
            tz.transition 2056, 10, :o4, 2740006800, 59335213, 24
            tz.transition 2057, 3, :o5, 2752707600, 59338741, 24
            tz.transition 2057, 10, :o4, 2771456400, 59343949, 24
            tz.transition 2058, 3, :o5, 2784762000, 59347645, 24
            tz.transition 2058, 10, :o4, 2802906000, 59352685, 24
            tz.transition 2059, 3, :o5, 2816211600, 59356381, 24
            tz.transition 2059, 10, :o4, 2834355600, 59361421, 24
            tz.transition 2060, 3, :o5, 2847661200, 59365117, 24
            tz.transition 2060, 10, :o4, 2866410000, 59370325, 24
            tz.transition 2061, 3, :o5, 2879110800, 59373853, 24
            tz.transition 2061, 10, :o4, 2897859600, 59379061, 24
            tz.transition 2062, 3, :o5, 2910560400, 59382589, 24
            tz.transition 2062, 10, :o4, 2929309200, 59387797, 24
            tz.transition 2063, 3, :o5, 2942010000, 59391325, 24
            tz.transition 2063, 10, :o4, 2960758800, 59396533, 24
            tz.transition 2064, 3, :o5, 2974064400, 59400229, 24
            tz.transition 2064, 10, :o4, 2992208400, 59405269, 24
            tz.transition 2065, 3, :o5, 3005514000, 59408965, 24
            tz.transition 2065, 10, :o4, 3023658000, 59414005, 24
            tz.transition 2066, 3, :o5, 3036963600, 59417701, 24
            tz.transition 2066, 10, :o4, 3055712400, 59422909, 24
            tz.transition 2067, 3, :o5, 3068413200, 59426437, 24
            tz.transition 2067, 10, :o4, 3087162000, 59431645, 24
            tz.transition 2068, 3, :o5, 3099862800, 59435173, 24
            tz.transition 2068, 10, :o4, 3118611600, 59440381, 24
          end
        end
      end
    end
  end
end
