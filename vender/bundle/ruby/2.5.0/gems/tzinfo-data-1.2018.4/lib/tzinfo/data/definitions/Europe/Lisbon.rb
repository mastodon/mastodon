# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Lisbon
          include TimezoneDefinition
          
          timezone 'Europe/Lisbon' do |tz|
            tz.offset :o0, -2205, 0, :LMT
            tz.offset :o1, 0, 0, :WET
            tz.offset :o2, 0, 3600, :WEST
            tz.offset :o3, 0, 7200, :WEMT
            tz.offset :o4, 3600, 0, :CET
            tz.offset :o5, 3600, 3600, :CEST
            
            tz.transition 1912, 1, :o1, -1830384000, 4838805, 2
            tz.transition 1916, 6, :o2, -1689555600, 58104779, 24
            tz.transition 1916, 11, :o1, -1677801600, 4842337, 2
            tz.transition 1917, 2, :o2, -1667437200, 58110923, 24
            tz.transition 1917, 10, :o1, -1647738000, 58116395, 24
            tz.transition 1918, 3, :o2, -1635814800, 58119707, 24
            tz.transition 1918, 10, :o1, -1616202000, 58125155, 24
            tz.transition 1919, 2, :o2, -1604365200, 58128443, 24
            tz.transition 1919, 10, :o1, -1584666000, 58133915, 24
            tz.transition 1920, 2, :o2, -1572742800, 58137227, 24
            tz.transition 1920, 10, :o1, -1553043600, 58142699, 24
            tz.transition 1921, 2, :o2, -1541206800, 58145987, 24
            tz.transition 1921, 10, :o1, -1521507600, 58151459, 24
            tz.transition 1924, 4, :o2, -1442451600, 58173419, 24
            tz.transition 1924, 10, :o1, -1426813200, 58177763, 24
            tz.transition 1926, 4, :o2, -1379293200, 58190963, 24
            tz.transition 1926, 10, :o1, -1364778000, 58194995, 24
            tz.transition 1927, 4, :o2, -1348448400, 58199531, 24
            tz.transition 1927, 10, :o1, -1333328400, 58203731, 24
            tz.transition 1928, 4, :o2, -1316394000, 58208435, 24
            tz.transition 1928, 10, :o1, -1301274000, 58212635, 24
            tz.transition 1929, 4, :o2, -1284339600, 58217339, 24
            tz.transition 1929, 10, :o1, -1269824400, 58221371, 24
            tz.transition 1931, 4, :o2, -1221440400, 58234811, 24
            tz.transition 1931, 10, :o1, -1206925200, 58238843, 24
            tz.transition 1932, 4, :o2, -1191200400, 58243211, 24
            tz.transition 1932, 10, :o1, -1175475600, 58247579, 24
            tz.transition 1934, 4, :o2, -1127696400, 58260851, 24
            tz.transition 1934, 10, :o1, -1111971600, 58265219, 24
            tz.transition 1935, 3, :o2, -1096851600, 58269419, 24
            tz.transition 1935, 10, :o1, -1080522000, 58273955, 24
            tz.transition 1936, 4, :o2, -1063587600, 58278659, 24
            tz.transition 1936, 10, :o1, -1049072400, 58282691, 24
            tz.transition 1937, 4, :o2, -1033347600, 58287059, 24
            tz.transition 1937, 10, :o1, -1017622800, 58291427, 24
            tz.transition 1938, 3, :o2, -1002502800, 58295627, 24
            tz.transition 1938, 10, :o1, -986173200, 58300163, 24
            tz.transition 1939, 4, :o2, -969238800, 58304867, 24
            tz.transition 1939, 11, :o1, -950490000, 58310075, 24
            tz.transition 1940, 2, :o2, -942022800, 58312427, 24
            tz.transition 1940, 10, :o1, -922669200, 58317803, 24
            tz.transition 1941, 4, :o2, -906944400, 58322171, 24
            tz.transition 1941, 10, :o1, -891133200, 58326563, 24
            tz.transition 1942, 3, :o2, -877309200, 58330403, 24
            tz.transition 1942, 4, :o3, -873684000, 29165705, 12
            tz.transition 1942, 8, :o2, -864007200, 29167049, 12
            tz.transition 1942, 10, :o1, -857955600, 58335779, 24
            tz.transition 1943, 3, :o2, -845859600, 58339139, 24
            tz.transition 1943, 4, :o3, -842839200, 29169989, 12
            tz.transition 1943, 8, :o2, -831348000, 29171585, 12
            tz.transition 1943, 10, :o1, -825901200, 58344683, 24
            tz.transition 1944, 3, :o2, -814410000, 58347875, 24
            tz.transition 1944, 4, :o3, -810784800, 29174441, 12
            tz.transition 1944, 8, :o2, -799898400, 29175953, 12
            tz.transition 1944, 10, :o1, -794451600, 58353419, 24
            tz.transition 1945, 3, :o2, -782960400, 58356611, 24
            tz.transition 1945, 4, :o3, -779335200, 29178809, 12
            tz.transition 1945, 8, :o2, -768448800, 29180321, 12
            tz.transition 1945, 10, :o1, -763002000, 58362155, 24
            tz.transition 1946, 4, :o2, -749091600, 58366019, 24
            tz.transition 1946, 10, :o1, -733366800, 58370387, 24
            tz.transition 1947, 4, :o2, -717631200, 29187379, 12
            tz.transition 1947, 10, :o1, -701906400, 29189563, 12
            tz.transition 1948, 4, :o2, -686181600, 29191747, 12
            tz.transition 1948, 10, :o1, -670456800, 29193931, 12
            tz.transition 1949, 4, :o2, -654732000, 29196115, 12
            tz.transition 1949, 10, :o1, -639007200, 29198299, 12
            tz.transition 1951, 4, :o2, -591832800, 29204851, 12
            tz.transition 1951, 10, :o1, -575503200, 29207119, 12
            tz.transition 1952, 4, :o2, -559778400, 29209303, 12
            tz.transition 1952, 10, :o1, -544053600, 29211487, 12
            tz.transition 1953, 4, :o2, -528328800, 29213671, 12
            tz.transition 1953, 10, :o1, -512604000, 29215855, 12
            tz.transition 1954, 4, :o2, -496879200, 29218039, 12
            tz.transition 1954, 10, :o1, -481154400, 29220223, 12
            tz.transition 1955, 4, :o2, -465429600, 29222407, 12
            tz.transition 1955, 10, :o1, -449704800, 29224591, 12
            tz.transition 1956, 4, :o2, -433980000, 29226775, 12
            tz.transition 1956, 10, :o1, -417650400, 29229043, 12
            tz.transition 1957, 4, :o2, -401925600, 29231227, 12
            tz.transition 1957, 10, :o1, -386200800, 29233411, 12
            tz.transition 1958, 4, :o2, -370476000, 29235595, 12
            tz.transition 1958, 10, :o1, -354751200, 29237779, 12
            tz.transition 1959, 4, :o2, -339026400, 29239963, 12
            tz.transition 1959, 10, :o1, -323301600, 29242147, 12
            tz.transition 1960, 4, :o2, -307576800, 29244331, 12
            tz.transition 1960, 10, :o1, -291852000, 29246515, 12
            tz.transition 1961, 4, :o2, -276127200, 29248699, 12
            tz.transition 1961, 10, :o1, -260402400, 29250883, 12
            tz.transition 1962, 4, :o2, -244677600, 29253067, 12
            tz.transition 1962, 10, :o1, -228348000, 29255335, 12
            tz.transition 1963, 4, :o2, -212623200, 29257519, 12
            tz.transition 1963, 10, :o1, -196898400, 29259703, 12
            tz.transition 1964, 4, :o2, -181173600, 29261887, 12
            tz.transition 1964, 10, :o1, -165448800, 29264071, 12
            tz.transition 1965, 4, :o2, -149724000, 29266255, 12
            tz.transition 1965, 10, :o1, -133999200, 29268439, 12
            tz.transition 1966, 4, :o4, -118274400, 29270623, 12
            tz.transition 1976, 9, :o1, 212544000
            tz.transition 1977, 3, :o2, 228268800
            tz.transition 1977, 9, :o1, 243993600
            tz.transition 1978, 4, :o2, 260323200
            tz.transition 1978, 10, :o1, 276048000
            tz.transition 1979, 4, :o2, 291772800
            tz.transition 1979, 9, :o1, 307501200
            tz.transition 1980, 3, :o2, 323222400
            tz.transition 1980, 9, :o1, 338950800
            tz.transition 1981, 3, :o2, 354675600
            tz.transition 1981, 9, :o1, 370400400
            tz.transition 1982, 3, :o2, 386125200
            tz.transition 1982, 9, :o1, 401850000
            tz.transition 1983, 3, :o2, 417578400
            tz.transition 1983, 9, :o1, 433299600
            tz.transition 1984, 3, :o2, 449024400
            tz.transition 1984, 9, :o1, 465354000
            tz.transition 1985, 3, :o2, 481078800
            tz.transition 1985, 9, :o1, 496803600
            tz.transition 1986, 3, :o2, 512528400
            tz.transition 1986, 9, :o1, 528253200
            tz.transition 1987, 3, :o2, 543978000
            tz.transition 1987, 9, :o1, 559702800
            tz.transition 1988, 3, :o2, 575427600
            tz.transition 1988, 9, :o1, 591152400
            tz.transition 1989, 3, :o2, 606877200
            tz.transition 1989, 9, :o1, 622602000
            tz.transition 1990, 3, :o2, 638326800
            tz.transition 1990, 9, :o1, 654656400
            tz.transition 1991, 3, :o2, 670381200
            tz.transition 1991, 9, :o1, 686106000
            tz.transition 1992, 3, :o2, 701830800
            tz.transition 1992, 9, :o4, 717555600
            tz.transition 1993, 3, :o5, 733280400
            tz.transition 1993, 9, :o4, 749005200
            tz.transition 1994, 3, :o5, 764730000
            tz.transition 1994, 9, :o4, 780454800
            tz.transition 1995, 3, :o5, 796179600
            tz.transition 1995, 9, :o4, 811904400
            tz.transition 1996, 3, :o2, 828234000
            tz.transition 1996, 10, :o1, 846378000
            tz.transition 1997, 3, :o2, 859683600
            tz.transition 1997, 10, :o1, 877827600
            tz.transition 1998, 3, :o2, 891133200
            tz.transition 1998, 10, :o1, 909277200
            tz.transition 1999, 3, :o2, 922582800
            tz.transition 1999, 10, :o1, 941331600
            tz.transition 2000, 3, :o2, 954032400
            tz.transition 2000, 10, :o1, 972781200
            tz.transition 2001, 3, :o2, 985482000
            tz.transition 2001, 10, :o1, 1004230800
            tz.transition 2002, 3, :o2, 1017536400
            tz.transition 2002, 10, :o1, 1035680400
            tz.transition 2003, 3, :o2, 1048986000
            tz.transition 2003, 10, :o1, 1067130000
            tz.transition 2004, 3, :o2, 1080435600
            tz.transition 2004, 10, :o1, 1099184400
            tz.transition 2005, 3, :o2, 1111885200
            tz.transition 2005, 10, :o1, 1130634000
            tz.transition 2006, 3, :o2, 1143334800
            tz.transition 2006, 10, :o1, 1162083600
            tz.transition 2007, 3, :o2, 1174784400
            tz.transition 2007, 10, :o1, 1193533200
            tz.transition 2008, 3, :o2, 1206838800
            tz.transition 2008, 10, :o1, 1224982800
            tz.transition 2009, 3, :o2, 1238288400
            tz.transition 2009, 10, :o1, 1256432400
            tz.transition 2010, 3, :o2, 1269738000
            tz.transition 2010, 10, :o1, 1288486800
            tz.transition 2011, 3, :o2, 1301187600
            tz.transition 2011, 10, :o1, 1319936400
            tz.transition 2012, 3, :o2, 1332637200
            tz.transition 2012, 10, :o1, 1351386000
            tz.transition 2013, 3, :o2, 1364691600
            tz.transition 2013, 10, :o1, 1382835600
            tz.transition 2014, 3, :o2, 1396141200
            tz.transition 2014, 10, :o1, 1414285200
            tz.transition 2015, 3, :o2, 1427590800
            tz.transition 2015, 10, :o1, 1445734800
            tz.transition 2016, 3, :o2, 1459040400
            tz.transition 2016, 10, :o1, 1477789200
            tz.transition 2017, 3, :o2, 1490490000
            tz.transition 2017, 10, :o1, 1509238800
            tz.transition 2018, 3, :o2, 1521939600
            tz.transition 2018, 10, :o1, 1540688400
            tz.transition 2019, 3, :o2, 1553994000
            tz.transition 2019, 10, :o1, 1572138000
            tz.transition 2020, 3, :o2, 1585443600
            tz.transition 2020, 10, :o1, 1603587600
            tz.transition 2021, 3, :o2, 1616893200
            tz.transition 2021, 10, :o1, 1635642000
            tz.transition 2022, 3, :o2, 1648342800
            tz.transition 2022, 10, :o1, 1667091600
            tz.transition 2023, 3, :o2, 1679792400
            tz.transition 2023, 10, :o1, 1698541200
            tz.transition 2024, 3, :o2, 1711846800
            tz.transition 2024, 10, :o1, 1729990800
            tz.transition 2025, 3, :o2, 1743296400
            tz.transition 2025, 10, :o1, 1761440400
            tz.transition 2026, 3, :o2, 1774746000
            tz.transition 2026, 10, :o1, 1792890000
            tz.transition 2027, 3, :o2, 1806195600
            tz.transition 2027, 10, :o1, 1824944400
            tz.transition 2028, 3, :o2, 1837645200
            tz.transition 2028, 10, :o1, 1856394000
            tz.transition 2029, 3, :o2, 1869094800
            tz.transition 2029, 10, :o1, 1887843600
            tz.transition 2030, 3, :o2, 1901149200
            tz.transition 2030, 10, :o1, 1919293200
            tz.transition 2031, 3, :o2, 1932598800
            tz.transition 2031, 10, :o1, 1950742800
            tz.transition 2032, 3, :o2, 1964048400
            tz.transition 2032, 10, :o1, 1982797200
            tz.transition 2033, 3, :o2, 1995498000
            tz.transition 2033, 10, :o1, 2014246800
            tz.transition 2034, 3, :o2, 2026947600
            tz.transition 2034, 10, :o1, 2045696400
            tz.transition 2035, 3, :o2, 2058397200
            tz.transition 2035, 10, :o1, 2077146000
            tz.transition 2036, 3, :o2, 2090451600
            tz.transition 2036, 10, :o1, 2108595600
            tz.transition 2037, 3, :o2, 2121901200
            tz.transition 2037, 10, :o1, 2140045200
            tz.transition 2038, 3, :o2, 2153350800, 59172253, 24
            tz.transition 2038, 10, :o1, 2172099600, 59177461, 24
            tz.transition 2039, 3, :o2, 2184800400, 59180989, 24
            tz.transition 2039, 10, :o1, 2203549200, 59186197, 24
            tz.transition 2040, 3, :o2, 2216250000, 59189725, 24
            tz.transition 2040, 10, :o1, 2234998800, 59194933, 24
            tz.transition 2041, 3, :o2, 2248304400, 59198629, 24
            tz.transition 2041, 10, :o1, 2266448400, 59203669, 24
            tz.transition 2042, 3, :o2, 2279754000, 59207365, 24
            tz.transition 2042, 10, :o1, 2297898000, 59212405, 24
            tz.transition 2043, 3, :o2, 2311203600, 59216101, 24
            tz.transition 2043, 10, :o1, 2329347600, 59221141, 24
            tz.transition 2044, 3, :o2, 2342653200, 59224837, 24
            tz.transition 2044, 10, :o1, 2361402000, 59230045, 24
            tz.transition 2045, 3, :o2, 2374102800, 59233573, 24
            tz.transition 2045, 10, :o1, 2392851600, 59238781, 24
            tz.transition 2046, 3, :o2, 2405552400, 59242309, 24
            tz.transition 2046, 10, :o1, 2424301200, 59247517, 24
            tz.transition 2047, 3, :o2, 2437606800, 59251213, 24
            tz.transition 2047, 10, :o1, 2455750800, 59256253, 24
            tz.transition 2048, 3, :o2, 2469056400, 59259949, 24
            tz.transition 2048, 10, :o1, 2487200400, 59264989, 24
            tz.transition 2049, 3, :o2, 2500506000, 59268685, 24
            tz.transition 2049, 10, :o1, 2519254800, 59273893, 24
            tz.transition 2050, 3, :o2, 2531955600, 59277421, 24
            tz.transition 2050, 10, :o1, 2550704400, 59282629, 24
            tz.transition 2051, 3, :o2, 2563405200, 59286157, 24
            tz.transition 2051, 10, :o1, 2582154000, 59291365, 24
            tz.transition 2052, 3, :o2, 2595459600, 59295061, 24
            tz.transition 2052, 10, :o1, 2613603600, 59300101, 24
            tz.transition 2053, 3, :o2, 2626909200, 59303797, 24
            tz.transition 2053, 10, :o1, 2645053200, 59308837, 24
            tz.transition 2054, 3, :o2, 2658358800, 59312533, 24
            tz.transition 2054, 10, :o1, 2676502800, 59317573, 24
            tz.transition 2055, 3, :o2, 2689808400, 59321269, 24
            tz.transition 2055, 10, :o1, 2708557200, 59326477, 24
            tz.transition 2056, 3, :o2, 2721258000, 59330005, 24
            tz.transition 2056, 10, :o1, 2740006800, 59335213, 24
            tz.transition 2057, 3, :o2, 2752707600, 59338741, 24
            tz.transition 2057, 10, :o1, 2771456400, 59343949, 24
            tz.transition 2058, 3, :o2, 2784762000, 59347645, 24
            tz.transition 2058, 10, :o1, 2802906000, 59352685, 24
            tz.transition 2059, 3, :o2, 2816211600, 59356381, 24
            tz.transition 2059, 10, :o1, 2834355600, 59361421, 24
            tz.transition 2060, 3, :o2, 2847661200, 59365117, 24
            tz.transition 2060, 10, :o1, 2866410000, 59370325, 24
            tz.transition 2061, 3, :o2, 2879110800, 59373853, 24
            tz.transition 2061, 10, :o1, 2897859600, 59379061, 24
            tz.transition 2062, 3, :o2, 2910560400, 59382589, 24
            tz.transition 2062, 10, :o1, 2929309200, 59387797, 24
            tz.transition 2063, 3, :o2, 2942010000, 59391325, 24
            tz.transition 2063, 10, :o1, 2960758800, 59396533, 24
            tz.transition 2064, 3, :o2, 2974064400, 59400229, 24
            tz.transition 2064, 10, :o1, 2992208400, 59405269, 24
            tz.transition 2065, 3, :o2, 3005514000, 59408965, 24
            tz.transition 2065, 10, :o1, 3023658000, 59414005, 24
            tz.transition 2066, 3, :o2, 3036963600, 59417701, 24
            tz.transition 2066, 10, :o1, 3055712400, 59422909, 24
            tz.transition 2067, 3, :o2, 3068413200, 59426437, 24
            tz.transition 2067, 10, :o1, 3087162000, 59431645, 24
            tz.transition 2068, 3, :o2, 3099862800, 59435173, 24
            tz.transition 2068, 10, :o1, 3118611600, 59440381, 24
          end
        end
      end
    end
  end
end
