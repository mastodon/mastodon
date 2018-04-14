# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Amsterdam
          include TimezoneDefinition
          
          timezone 'Europe/Amsterdam' do |tz|
            tz.offset :o0, 1172, 0, :LMT
            tz.offset :o1, 1172, 0, :AMT
            tz.offset :o2, 1172, 3600, :NST
            tz.offset :o3, 1200, 3600, :'+0120'
            tz.offset :o4, 1200, 0, :'+0020'
            tz.offset :o5, 3600, 3600, :CEST
            tz.offset :o6, 3600, 0, :CET
            
            tz.transition 1834, 12, :o1, -4260212372, 51651636907, 21600
            tz.transition 1916, 4, :o2, -1693700372, 52293264907, 21600
            tz.transition 1916, 9, :o1, -1680484772, 52296568807, 21600
            tz.transition 1917, 4, :o2, -1663453172, 52300826707, 21600
            tz.transition 1917, 9, :o1, -1650147572, 52304153107, 21600
            tz.transition 1918, 4, :o2, -1633213172, 52308386707, 21600
            tz.transition 1918, 9, :o1, -1617488372, 52312317907, 21600
            tz.transition 1919, 4, :o2, -1601158772, 52316400307, 21600
            tz.transition 1919, 9, :o1, -1586038772, 52320180307, 21600
            tz.transition 1920, 4, :o2, -1569709172, 52324262707, 21600
            tz.transition 1920, 9, :o1, -1554589172, 52328042707, 21600
            tz.transition 1921, 4, :o2, -1538259572, 52332125107, 21600
            tz.transition 1921, 9, :o1, -1523139572, 52335905107, 21600
            tz.transition 1922, 3, :o2, -1507501172, 52339814707, 21600
            tz.transition 1922, 10, :o1, -1490566772, 52344048307, 21600
            tz.transition 1923, 6, :o2, -1470176372, 52349145907, 21600
            tz.transition 1923, 10, :o1, -1459117172, 52351910707, 21600
            tz.transition 1924, 3, :o2, -1443997172, 52355690707, 21600
            tz.transition 1924, 10, :o1, -1427667572, 52359773107, 21600
            tz.transition 1925, 6, :o2, -1406672372, 52365021907, 21600
            tz.transition 1925, 10, :o1, -1396217972, 52367635507, 21600
            tz.transition 1926, 5, :o2, -1376950772, 52372452307, 21600
            tz.transition 1926, 10, :o1, -1364768372, 52375497907, 21600
            tz.transition 1927, 5, :o2, -1345414772, 52380336307, 21600
            tz.transition 1927, 10, :o1, -1333318772, 52383360307, 21600
            tz.transition 1928, 5, :o2, -1313792372, 52388241907, 21600
            tz.transition 1928, 10, :o1, -1301264372, 52391373907, 21600
            tz.transition 1929, 5, :o2, -1282256372, 52396125907, 21600
            tz.transition 1929, 10, :o1, -1269814772, 52399236307, 21600
            tz.transition 1930, 5, :o2, -1250720372, 52404009907, 21600
            tz.transition 1930, 10, :o1, -1238365172, 52407098707, 21600
            tz.transition 1931, 5, :o2, -1219184372, 52411893907, 21600
            tz.transition 1931, 10, :o1, -1206915572, 52414961107, 21600
            tz.transition 1932, 5, :o2, -1186957172, 52419950707, 21600
            tz.transition 1932, 10, :o1, -1175465972, 52422823507, 21600
            tz.transition 1933, 5, :o2, -1156025972, 52427683507, 21600
            tz.transition 1933, 10, :o1, -1143411572, 52430837107, 21600
            tz.transition 1934, 5, :o2, -1124489972, 52435567507, 21600
            tz.transition 1934, 10, :o1, -1111961972, 52438699507, 21600
            tz.transition 1935, 5, :o2, -1092953972, 52443451507, 21600
            tz.transition 1935, 10, :o1, -1080512372, 52446561907, 21600
            tz.transition 1936, 5, :o2, -1061331572, 52451357107, 21600
            tz.transition 1936, 10, :o1, -1049062772, 52454424307, 21600
            tz.transition 1937, 5, :o2, -1029190772, 52459392307, 21600
            tz.transition 1937, 6, :o3, -1025745572, 52460253607, 21600
            tz.transition 1937, 10, :o4, -1017613200, 174874289, 72
            tz.transition 1938, 5, :o3, -998259600, 174890417, 72
            tz.transition 1938, 10, :o4, -986163600, 174900497, 72
            tz.transition 1939, 5, :o3, -966723600, 174916697, 72
            tz.transition 1939, 10, :o4, -954109200, 174927209, 72
            tz.transition 1940, 5, :o5, -935022000, 174943115, 72
            tz.transition 1942, 11, :o6, -857257200, 58335973, 24
            tz.transition 1943, 3, :o5, -844556400, 58339501, 24
            tz.transition 1943, 10, :o6, -828226800, 58344037, 24
            tz.transition 1944, 4, :o5, -812502000, 58348405, 24
            tz.transition 1944, 10, :o6, -796777200, 58352773, 24
            tz.transition 1945, 4, :o5, -781052400, 58357141, 24
            tz.transition 1945, 9, :o6, -766623600, 58361149, 24
            tz.transition 1977, 4, :o5, 228877200
            tz.transition 1977, 9, :o6, 243997200
            tz.transition 1978, 4, :o5, 260326800
            tz.transition 1978, 10, :o6, 276051600
            tz.transition 1979, 4, :o5, 291776400
            tz.transition 1979, 9, :o6, 307501200
            tz.transition 1980, 4, :o5, 323830800
            tz.transition 1980, 9, :o6, 338950800
            tz.transition 1981, 3, :o5, 354675600
            tz.transition 1981, 9, :o6, 370400400
            tz.transition 1982, 3, :o5, 386125200
            tz.transition 1982, 9, :o6, 401850000
            tz.transition 1983, 3, :o5, 417574800
            tz.transition 1983, 9, :o6, 433299600
            tz.transition 1984, 3, :o5, 449024400
            tz.transition 1984, 9, :o6, 465354000
            tz.transition 1985, 3, :o5, 481078800
            tz.transition 1985, 9, :o6, 496803600
            tz.transition 1986, 3, :o5, 512528400
            tz.transition 1986, 9, :o6, 528253200
            tz.transition 1987, 3, :o5, 543978000
            tz.transition 1987, 9, :o6, 559702800
            tz.transition 1988, 3, :o5, 575427600
            tz.transition 1988, 9, :o6, 591152400
            tz.transition 1989, 3, :o5, 606877200
            tz.transition 1989, 9, :o6, 622602000
            tz.transition 1990, 3, :o5, 638326800
            tz.transition 1990, 9, :o6, 654656400
            tz.transition 1991, 3, :o5, 670381200
            tz.transition 1991, 9, :o6, 686106000
            tz.transition 1992, 3, :o5, 701830800
            tz.transition 1992, 9, :o6, 717555600
            tz.transition 1993, 3, :o5, 733280400
            tz.transition 1993, 9, :o6, 749005200
            tz.transition 1994, 3, :o5, 764730000
            tz.transition 1994, 9, :o6, 780454800
            tz.transition 1995, 3, :o5, 796179600
            tz.transition 1995, 9, :o6, 811904400
            tz.transition 1996, 3, :o5, 828234000
            tz.transition 1996, 10, :o6, 846378000
            tz.transition 1997, 3, :o5, 859683600
            tz.transition 1997, 10, :o6, 877827600
            tz.transition 1998, 3, :o5, 891133200
            tz.transition 1998, 10, :o6, 909277200
            tz.transition 1999, 3, :o5, 922582800
            tz.transition 1999, 10, :o6, 941331600
            tz.transition 2000, 3, :o5, 954032400
            tz.transition 2000, 10, :o6, 972781200
            tz.transition 2001, 3, :o5, 985482000
            tz.transition 2001, 10, :o6, 1004230800
            tz.transition 2002, 3, :o5, 1017536400
            tz.transition 2002, 10, :o6, 1035680400
            tz.transition 2003, 3, :o5, 1048986000
            tz.transition 2003, 10, :o6, 1067130000
            tz.transition 2004, 3, :o5, 1080435600
            tz.transition 2004, 10, :o6, 1099184400
            tz.transition 2005, 3, :o5, 1111885200
            tz.transition 2005, 10, :o6, 1130634000
            tz.transition 2006, 3, :o5, 1143334800
            tz.transition 2006, 10, :o6, 1162083600
            tz.transition 2007, 3, :o5, 1174784400
            tz.transition 2007, 10, :o6, 1193533200
            tz.transition 2008, 3, :o5, 1206838800
            tz.transition 2008, 10, :o6, 1224982800
            tz.transition 2009, 3, :o5, 1238288400
            tz.transition 2009, 10, :o6, 1256432400
            tz.transition 2010, 3, :o5, 1269738000
            tz.transition 2010, 10, :o6, 1288486800
            tz.transition 2011, 3, :o5, 1301187600
            tz.transition 2011, 10, :o6, 1319936400
            tz.transition 2012, 3, :o5, 1332637200
            tz.transition 2012, 10, :o6, 1351386000
            tz.transition 2013, 3, :o5, 1364691600
            tz.transition 2013, 10, :o6, 1382835600
            tz.transition 2014, 3, :o5, 1396141200
            tz.transition 2014, 10, :o6, 1414285200
            tz.transition 2015, 3, :o5, 1427590800
            tz.transition 2015, 10, :o6, 1445734800
            tz.transition 2016, 3, :o5, 1459040400
            tz.transition 2016, 10, :o6, 1477789200
            tz.transition 2017, 3, :o5, 1490490000
            tz.transition 2017, 10, :o6, 1509238800
            tz.transition 2018, 3, :o5, 1521939600
            tz.transition 2018, 10, :o6, 1540688400
            tz.transition 2019, 3, :o5, 1553994000
            tz.transition 2019, 10, :o6, 1572138000
            tz.transition 2020, 3, :o5, 1585443600
            tz.transition 2020, 10, :o6, 1603587600
            tz.transition 2021, 3, :o5, 1616893200
            tz.transition 2021, 10, :o6, 1635642000
            tz.transition 2022, 3, :o5, 1648342800
            tz.transition 2022, 10, :o6, 1667091600
            tz.transition 2023, 3, :o5, 1679792400
            tz.transition 2023, 10, :o6, 1698541200
            tz.transition 2024, 3, :o5, 1711846800
            tz.transition 2024, 10, :o6, 1729990800
            tz.transition 2025, 3, :o5, 1743296400
            tz.transition 2025, 10, :o6, 1761440400
            tz.transition 2026, 3, :o5, 1774746000
            tz.transition 2026, 10, :o6, 1792890000
            tz.transition 2027, 3, :o5, 1806195600
            tz.transition 2027, 10, :o6, 1824944400
            tz.transition 2028, 3, :o5, 1837645200
            tz.transition 2028, 10, :o6, 1856394000
            tz.transition 2029, 3, :o5, 1869094800
            tz.transition 2029, 10, :o6, 1887843600
            tz.transition 2030, 3, :o5, 1901149200
            tz.transition 2030, 10, :o6, 1919293200
            tz.transition 2031, 3, :o5, 1932598800
            tz.transition 2031, 10, :o6, 1950742800
            tz.transition 2032, 3, :o5, 1964048400
            tz.transition 2032, 10, :o6, 1982797200
            tz.transition 2033, 3, :o5, 1995498000
            tz.transition 2033, 10, :o6, 2014246800
            tz.transition 2034, 3, :o5, 2026947600
            tz.transition 2034, 10, :o6, 2045696400
            tz.transition 2035, 3, :o5, 2058397200
            tz.transition 2035, 10, :o6, 2077146000
            tz.transition 2036, 3, :o5, 2090451600
            tz.transition 2036, 10, :o6, 2108595600
            tz.transition 2037, 3, :o5, 2121901200
            tz.transition 2037, 10, :o6, 2140045200
            tz.transition 2038, 3, :o5, 2153350800, 59172253, 24
            tz.transition 2038, 10, :o6, 2172099600, 59177461, 24
            tz.transition 2039, 3, :o5, 2184800400, 59180989, 24
            tz.transition 2039, 10, :o6, 2203549200, 59186197, 24
            tz.transition 2040, 3, :o5, 2216250000, 59189725, 24
            tz.transition 2040, 10, :o6, 2234998800, 59194933, 24
            tz.transition 2041, 3, :o5, 2248304400, 59198629, 24
            tz.transition 2041, 10, :o6, 2266448400, 59203669, 24
            tz.transition 2042, 3, :o5, 2279754000, 59207365, 24
            tz.transition 2042, 10, :o6, 2297898000, 59212405, 24
            tz.transition 2043, 3, :o5, 2311203600, 59216101, 24
            tz.transition 2043, 10, :o6, 2329347600, 59221141, 24
            tz.transition 2044, 3, :o5, 2342653200, 59224837, 24
            tz.transition 2044, 10, :o6, 2361402000, 59230045, 24
            tz.transition 2045, 3, :o5, 2374102800, 59233573, 24
            tz.transition 2045, 10, :o6, 2392851600, 59238781, 24
            tz.transition 2046, 3, :o5, 2405552400, 59242309, 24
            tz.transition 2046, 10, :o6, 2424301200, 59247517, 24
            tz.transition 2047, 3, :o5, 2437606800, 59251213, 24
            tz.transition 2047, 10, :o6, 2455750800, 59256253, 24
            tz.transition 2048, 3, :o5, 2469056400, 59259949, 24
            tz.transition 2048, 10, :o6, 2487200400, 59264989, 24
            tz.transition 2049, 3, :o5, 2500506000, 59268685, 24
            tz.transition 2049, 10, :o6, 2519254800, 59273893, 24
            tz.transition 2050, 3, :o5, 2531955600, 59277421, 24
            tz.transition 2050, 10, :o6, 2550704400, 59282629, 24
            tz.transition 2051, 3, :o5, 2563405200, 59286157, 24
            tz.transition 2051, 10, :o6, 2582154000, 59291365, 24
            tz.transition 2052, 3, :o5, 2595459600, 59295061, 24
            tz.transition 2052, 10, :o6, 2613603600, 59300101, 24
            tz.transition 2053, 3, :o5, 2626909200, 59303797, 24
            tz.transition 2053, 10, :o6, 2645053200, 59308837, 24
            tz.transition 2054, 3, :o5, 2658358800, 59312533, 24
            tz.transition 2054, 10, :o6, 2676502800, 59317573, 24
            tz.transition 2055, 3, :o5, 2689808400, 59321269, 24
            tz.transition 2055, 10, :o6, 2708557200, 59326477, 24
            tz.transition 2056, 3, :o5, 2721258000, 59330005, 24
            tz.transition 2056, 10, :o6, 2740006800, 59335213, 24
            tz.transition 2057, 3, :o5, 2752707600, 59338741, 24
            tz.transition 2057, 10, :o6, 2771456400, 59343949, 24
            tz.transition 2058, 3, :o5, 2784762000, 59347645, 24
            tz.transition 2058, 10, :o6, 2802906000, 59352685, 24
            tz.transition 2059, 3, :o5, 2816211600, 59356381, 24
            tz.transition 2059, 10, :o6, 2834355600, 59361421, 24
            tz.transition 2060, 3, :o5, 2847661200, 59365117, 24
            tz.transition 2060, 10, :o6, 2866410000, 59370325, 24
            tz.transition 2061, 3, :o5, 2879110800, 59373853, 24
            tz.transition 2061, 10, :o6, 2897859600, 59379061, 24
            tz.transition 2062, 3, :o5, 2910560400, 59382589, 24
            tz.transition 2062, 10, :o6, 2929309200, 59387797, 24
            tz.transition 2063, 3, :o5, 2942010000, 59391325, 24
            tz.transition 2063, 10, :o6, 2960758800, 59396533, 24
            tz.transition 2064, 3, :o5, 2974064400, 59400229, 24
            tz.transition 2064, 10, :o6, 2992208400, 59405269, 24
            tz.transition 2065, 3, :o5, 3005514000, 59408965, 24
            tz.transition 2065, 10, :o6, 3023658000, 59414005, 24
            tz.transition 2066, 3, :o5, 3036963600, 59417701, 24
            tz.transition 2066, 10, :o6, 3055712400, 59422909, 24
            tz.transition 2067, 3, :o5, 3068413200, 59426437, 24
            tz.transition 2067, 10, :o6, 3087162000, 59431645, 24
            tz.transition 2068, 3, :o5, 3099862800, 59435173, 24
            tz.transition 2068, 10, :o6, 3118611600, 59440381, 24
          end
        end
      end
    end
  end
end
