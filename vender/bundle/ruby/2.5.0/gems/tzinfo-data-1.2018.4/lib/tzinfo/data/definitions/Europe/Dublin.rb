# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Dublin
          include TimezoneDefinition
          
          timezone 'Europe/Dublin' do |tz|
            tz.offset :o0, -1500, 0, :LMT
            tz.offset :o1, -1521, 0, :DMT
            tz.offset :o2, -1521, 3600, :IST
            tz.offset :o3, 0, 0, :GMT
            tz.offset :o4, 0, 3600, :BST
            tz.offset :o5, 0, 3600, :IST
            tz.offset :o6, 3600, 0, :IST
            
            tz.transition 1880, 8, :o1, -2821649700, 693483701, 288
            tz.transition 1916, 5, :o2, -1691962479, 7747214723, 3200
            tz.transition 1916, 10, :o3, -1680471279, 7747640323, 3200
            tz.transition 1917, 4, :o4, -1664143200, 29055919, 12
            tz.transition 1917, 9, :o3, -1650146400, 29057863, 12
            tz.transition 1918, 3, :o4, -1633903200, 29060119, 12
            tz.transition 1918, 9, :o3, -1617487200, 29062399, 12
            tz.transition 1919, 3, :o4, -1601848800, 29064571, 12
            tz.transition 1919, 9, :o3, -1586037600, 29066767, 12
            tz.transition 1920, 3, :o4, -1570399200, 29068939, 12
            tz.transition 1920, 10, :o3, -1552168800, 29071471, 12
            tz.transition 1921, 4, :o4, -1538344800, 29073391, 12
            tz.transition 1921, 10, :o3, -1522533600, 29075587, 12
            tz.transition 1922, 3, :o5, -1507500000, 29077675, 12
            tz.transition 1922, 10, :o3, -1490565600, 29080027, 12
            tz.transition 1923, 4, :o5, -1473631200, 29082379, 12
            tz.transition 1923, 9, :o3, -1460930400, 29084143, 12
            tz.transition 1924, 4, :o5, -1442786400, 29086663, 12
            tz.transition 1924, 9, :o3, -1428876000, 29088595, 12
            tz.transition 1925, 4, :o5, -1410732000, 29091115, 12
            tz.transition 1925, 10, :o3, -1396216800, 29093131, 12
            tz.transition 1926, 4, :o5, -1379282400, 29095483, 12
            tz.transition 1926, 10, :o3, -1364767200, 29097499, 12
            tz.transition 1927, 4, :o5, -1348437600, 29099767, 12
            tz.transition 1927, 10, :o3, -1333317600, 29101867, 12
            tz.transition 1928, 4, :o5, -1315778400, 29104303, 12
            tz.transition 1928, 10, :o3, -1301263200, 29106319, 12
            tz.transition 1929, 4, :o5, -1284328800, 29108671, 12
            tz.transition 1929, 10, :o3, -1269813600, 29110687, 12
            tz.transition 1930, 4, :o5, -1253484000, 29112955, 12
            tz.transition 1930, 10, :o3, -1238364000, 29115055, 12
            tz.transition 1931, 4, :o5, -1221429600, 29117407, 12
            tz.transition 1931, 10, :o3, -1206914400, 29119423, 12
            tz.transition 1932, 4, :o5, -1189980000, 29121775, 12
            tz.transition 1932, 10, :o3, -1175464800, 29123791, 12
            tz.transition 1933, 4, :o5, -1159135200, 29126059, 12
            tz.transition 1933, 10, :o3, -1143410400, 29128243, 12
            tz.transition 1934, 4, :o5, -1126476000, 29130595, 12
            tz.transition 1934, 10, :o3, -1111960800, 29132611, 12
            tz.transition 1935, 4, :o5, -1095631200, 29134879, 12
            tz.transition 1935, 10, :o3, -1080511200, 29136979, 12
            tz.transition 1936, 4, :o5, -1063576800, 29139331, 12
            tz.transition 1936, 10, :o3, -1049061600, 29141347, 12
            tz.transition 1937, 4, :o5, -1032127200, 29143699, 12
            tz.transition 1937, 10, :o3, -1017612000, 29145715, 12
            tz.transition 1938, 4, :o5, -1001282400, 29147983, 12
            tz.transition 1938, 10, :o3, -986162400, 29150083, 12
            tz.transition 1939, 4, :o5, -969228000, 29152435, 12
            tz.transition 1939, 11, :o3, -950479200, 29155039, 12
            tz.transition 1940, 2, :o5, -942012000, 29156215, 12
            tz.transition 1946, 10, :o3, -733356000, 29185195, 12
            tz.transition 1947, 3, :o5, -719445600, 29187127, 12
            tz.transition 1947, 11, :o3, -699487200, 29189899, 12
            tz.transition 1948, 4, :o5, -684972000, 29191915, 12
            tz.transition 1948, 10, :o3, -668037600, 29194267, 12
            tz.transition 1949, 4, :o5, -654732000, 29196115, 12
            tz.transition 1949, 10, :o3, -636588000, 29198635, 12
            tz.transition 1950, 4, :o5, -622072800, 29200651, 12
            tz.transition 1950, 10, :o3, -605743200, 29202919, 12
            tz.transition 1951, 4, :o5, -590623200, 29205019, 12
            tz.transition 1951, 10, :o3, -574293600, 29207287, 12
            tz.transition 1952, 4, :o5, -558568800, 29209471, 12
            tz.transition 1952, 10, :o3, -542239200, 29211739, 12
            tz.transition 1953, 4, :o5, -527119200, 29213839, 12
            tz.transition 1953, 10, :o3, -512604000, 29215855, 12
            tz.transition 1954, 4, :o5, -496274400, 29218123, 12
            tz.transition 1954, 10, :o3, -481154400, 29220223, 12
            tz.transition 1955, 4, :o5, -464220000, 29222575, 12
            tz.transition 1955, 10, :o3, -449704800, 29224591, 12
            tz.transition 1956, 4, :o5, -432165600, 29227027, 12
            tz.transition 1956, 10, :o3, -417650400, 29229043, 12
            tz.transition 1957, 4, :o5, -401320800, 29231311, 12
            tz.transition 1957, 10, :o3, -386200800, 29233411, 12
            tz.transition 1958, 4, :o5, -369266400, 29235763, 12
            tz.transition 1958, 10, :o3, -354751200, 29237779, 12
            tz.transition 1959, 4, :o5, -337816800, 29240131, 12
            tz.transition 1959, 10, :o3, -323301600, 29242147, 12
            tz.transition 1960, 4, :o5, -306972000, 29244415, 12
            tz.transition 1960, 10, :o3, -291852000, 29246515, 12
            tz.transition 1961, 3, :o5, -276732000, 29248615, 12
            tz.transition 1961, 10, :o3, -257983200, 29251219, 12
            tz.transition 1962, 3, :o5, -245282400, 29252983, 12
            tz.transition 1962, 10, :o3, -226533600, 29255587, 12
            tz.transition 1963, 3, :o5, -213228000, 29257435, 12
            tz.transition 1963, 10, :o3, -195084000, 29259955, 12
            tz.transition 1964, 3, :o5, -182383200, 29261719, 12
            tz.transition 1964, 10, :o3, -163634400, 29264323, 12
            tz.transition 1965, 3, :o5, -150933600, 29266087, 12
            tz.transition 1965, 10, :o3, -132184800, 29268691, 12
            tz.transition 1966, 3, :o5, -119484000, 29270455, 12
            tz.transition 1966, 10, :o3, -100735200, 29273059, 12
            tz.transition 1967, 3, :o5, -88034400, 29274823, 12
            tz.transition 1967, 10, :o3, -68680800, 29277511, 12
            tz.transition 1968, 2, :o5, -59004000, 29278855, 12
            tz.transition 1968, 10, :o6, -37242000, 58563755, 24
            tz.transition 1971, 10, :o3, 57722400
            tz.transition 1972, 3, :o5, 69818400
            tz.transition 1972, 10, :o3, 89172000
            tz.transition 1973, 3, :o5, 101268000
            tz.transition 1973, 10, :o3, 120621600
            tz.transition 1974, 3, :o5, 132717600
            tz.transition 1974, 10, :o3, 152071200
            tz.transition 1975, 3, :o5, 164167200
            tz.transition 1975, 10, :o3, 183520800
            tz.transition 1976, 3, :o5, 196221600
            tz.transition 1976, 10, :o3, 214970400
            tz.transition 1977, 3, :o5, 227671200
            tz.transition 1977, 10, :o3, 246420000
            tz.transition 1978, 3, :o5, 259120800
            tz.transition 1978, 10, :o3, 278474400
            tz.transition 1979, 3, :o5, 290570400
            tz.transition 1979, 10, :o3, 309924000
            tz.transition 1980, 3, :o5, 322020000
            tz.transition 1980, 10, :o3, 341373600
            tz.transition 1981, 3, :o5, 354675600
            tz.transition 1981, 10, :o3, 372819600
            tz.transition 1982, 3, :o5, 386125200
            tz.transition 1982, 10, :o3, 404269200
            tz.transition 1983, 3, :o5, 417574800
            tz.transition 1983, 10, :o3, 435718800
            tz.transition 1984, 3, :o5, 449024400
            tz.transition 1984, 10, :o3, 467773200
            tz.transition 1985, 3, :o5, 481078800
            tz.transition 1985, 10, :o3, 499222800
            tz.transition 1986, 3, :o5, 512528400
            tz.transition 1986, 10, :o3, 530672400
            tz.transition 1987, 3, :o5, 543978000
            tz.transition 1987, 10, :o3, 562122000
            tz.transition 1988, 3, :o5, 575427600
            tz.transition 1988, 10, :o3, 593571600
            tz.transition 1989, 3, :o5, 606877200
            tz.transition 1989, 10, :o3, 625626000
            tz.transition 1990, 3, :o5, 638326800
            tz.transition 1990, 10, :o3, 657075600
            tz.transition 1991, 3, :o5, 670381200
            tz.transition 1991, 10, :o3, 688525200
            tz.transition 1992, 3, :o5, 701830800
            tz.transition 1992, 10, :o3, 719974800
            tz.transition 1993, 3, :o5, 733280400
            tz.transition 1993, 10, :o3, 751424400
            tz.transition 1994, 3, :o5, 764730000
            tz.transition 1994, 10, :o3, 782874000
            tz.transition 1995, 3, :o5, 796179600
            tz.transition 1995, 10, :o3, 814323600
            tz.transition 1996, 3, :o5, 828234000
            tz.transition 1996, 10, :o3, 846378000
            tz.transition 1997, 3, :o5, 859683600
            tz.transition 1997, 10, :o3, 877827600
            tz.transition 1998, 3, :o5, 891133200
            tz.transition 1998, 10, :o3, 909277200
            tz.transition 1999, 3, :o5, 922582800
            tz.transition 1999, 10, :o3, 941331600
            tz.transition 2000, 3, :o5, 954032400
            tz.transition 2000, 10, :o3, 972781200
            tz.transition 2001, 3, :o5, 985482000
            tz.transition 2001, 10, :o3, 1004230800
            tz.transition 2002, 3, :o5, 1017536400
            tz.transition 2002, 10, :o3, 1035680400
            tz.transition 2003, 3, :o5, 1048986000
            tz.transition 2003, 10, :o3, 1067130000
            tz.transition 2004, 3, :o5, 1080435600
            tz.transition 2004, 10, :o3, 1099184400
            tz.transition 2005, 3, :o5, 1111885200
            tz.transition 2005, 10, :o3, 1130634000
            tz.transition 2006, 3, :o5, 1143334800
            tz.transition 2006, 10, :o3, 1162083600
            tz.transition 2007, 3, :o5, 1174784400
            tz.transition 2007, 10, :o3, 1193533200
            tz.transition 2008, 3, :o5, 1206838800
            tz.transition 2008, 10, :o3, 1224982800
            tz.transition 2009, 3, :o5, 1238288400
            tz.transition 2009, 10, :o3, 1256432400
            tz.transition 2010, 3, :o5, 1269738000
            tz.transition 2010, 10, :o3, 1288486800
            tz.transition 2011, 3, :o5, 1301187600
            tz.transition 2011, 10, :o3, 1319936400
            tz.transition 2012, 3, :o5, 1332637200
            tz.transition 2012, 10, :o3, 1351386000
            tz.transition 2013, 3, :o5, 1364691600
            tz.transition 2013, 10, :o3, 1382835600
            tz.transition 2014, 3, :o5, 1396141200
            tz.transition 2014, 10, :o3, 1414285200
            tz.transition 2015, 3, :o5, 1427590800
            tz.transition 2015, 10, :o3, 1445734800
            tz.transition 2016, 3, :o5, 1459040400
            tz.transition 2016, 10, :o3, 1477789200
            tz.transition 2017, 3, :o5, 1490490000
            tz.transition 2017, 10, :o3, 1509238800
            tz.transition 2018, 3, :o5, 1521939600
            tz.transition 2018, 10, :o3, 1540688400
            tz.transition 2019, 3, :o5, 1553994000
            tz.transition 2019, 10, :o3, 1572138000
            tz.transition 2020, 3, :o5, 1585443600
            tz.transition 2020, 10, :o3, 1603587600
            tz.transition 2021, 3, :o5, 1616893200
            tz.transition 2021, 10, :o3, 1635642000
            tz.transition 2022, 3, :o5, 1648342800
            tz.transition 2022, 10, :o3, 1667091600
            tz.transition 2023, 3, :o5, 1679792400
            tz.transition 2023, 10, :o3, 1698541200
            tz.transition 2024, 3, :o5, 1711846800
            tz.transition 2024, 10, :o3, 1729990800
            tz.transition 2025, 3, :o5, 1743296400
            tz.transition 2025, 10, :o3, 1761440400
            tz.transition 2026, 3, :o5, 1774746000
            tz.transition 2026, 10, :o3, 1792890000
            tz.transition 2027, 3, :o5, 1806195600
            tz.transition 2027, 10, :o3, 1824944400
            tz.transition 2028, 3, :o5, 1837645200
            tz.transition 2028, 10, :o3, 1856394000
            tz.transition 2029, 3, :o5, 1869094800
            tz.transition 2029, 10, :o3, 1887843600
            tz.transition 2030, 3, :o5, 1901149200
            tz.transition 2030, 10, :o3, 1919293200
            tz.transition 2031, 3, :o5, 1932598800
            tz.transition 2031, 10, :o3, 1950742800
            tz.transition 2032, 3, :o5, 1964048400
            tz.transition 2032, 10, :o3, 1982797200
            tz.transition 2033, 3, :o5, 1995498000
            tz.transition 2033, 10, :o3, 2014246800
            tz.transition 2034, 3, :o5, 2026947600
            tz.transition 2034, 10, :o3, 2045696400
            tz.transition 2035, 3, :o5, 2058397200
            tz.transition 2035, 10, :o3, 2077146000
            tz.transition 2036, 3, :o5, 2090451600
            tz.transition 2036, 10, :o3, 2108595600
            tz.transition 2037, 3, :o5, 2121901200
            tz.transition 2037, 10, :o3, 2140045200
            tz.transition 2038, 3, :o5, 2153350800, 59172253, 24
            tz.transition 2038, 10, :o3, 2172099600, 59177461, 24
            tz.transition 2039, 3, :o5, 2184800400, 59180989, 24
            tz.transition 2039, 10, :o3, 2203549200, 59186197, 24
            tz.transition 2040, 3, :o5, 2216250000, 59189725, 24
            tz.transition 2040, 10, :o3, 2234998800, 59194933, 24
            tz.transition 2041, 3, :o5, 2248304400, 59198629, 24
            tz.transition 2041, 10, :o3, 2266448400, 59203669, 24
            tz.transition 2042, 3, :o5, 2279754000, 59207365, 24
            tz.transition 2042, 10, :o3, 2297898000, 59212405, 24
            tz.transition 2043, 3, :o5, 2311203600, 59216101, 24
            tz.transition 2043, 10, :o3, 2329347600, 59221141, 24
            tz.transition 2044, 3, :o5, 2342653200, 59224837, 24
            tz.transition 2044, 10, :o3, 2361402000, 59230045, 24
            tz.transition 2045, 3, :o5, 2374102800, 59233573, 24
            tz.transition 2045, 10, :o3, 2392851600, 59238781, 24
            tz.transition 2046, 3, :o5, 2405552400, 59242309, 24
            tz.transition 2046, 10, :o3, 2424301200, 59247517, 24
            tz.transition 2047, 3, :o5, 2437606800, 59251213, 24
            tz.transition 2047, 10, :o3, 2455750800, 59256253, 24
            tz.transition 2048, 3, :o5, 2469056400, 59259949, 24
            tz.transition 2048, 10, :o3, 2487200400, 59264989, 24
            tz.transition 2049, 3, :o5, 2500506000, 59268685, 24
            tz.transition 2049, 10, :o3, 2519254800, 59273893, 24
            tz.transition 2050, 3, :o5, 2531955600, 59277421, 24
            tz.transition 2050, 10, :o3, 2550704400, 59282629, 24
            tz.transition 2051, 3, :o5, 2563405200, 59286157, 24
            tz.transition 2051, 10, :o3, 2582154000, 59291365, 24
            tz.transition 2052, 3, :o5, 2595459600, 59295061, 24
            tz.transition 2052, 10, :o3, 2613603600, 59300101, 24
            tz.transition 2053, 3, :o5, 2626909200, 59303797, 24
            tz.transition 2053, 10, :o3, 2645053200, 59308837, 24
            tz.transition 2054, 3, :o5, 2658358800, 59312533, 24
            tz.transition 2054, 10, :o3, 2676502800, 59317573, 24
            tz.transition 2055, 3, :o5, 2689808400, 59321269, 24
            tz.transition 2055, 10, :o3, 2708557200, 59326477, 24
            tz.transition 2056, 3, :o5, 2721258000, 59330005, 24
            tz.transition 2056, 10, :o3, 2740006800, 59335213, 24
            tz.transition 2057, 3, :o5, 2752707600, 59338741, 24
            tz.transition 2057, 10, :o3, 2771456400, 59343949, 24
            tz.transition 2058, 3, :o5, 2784762000, 59347645, 24
            tz.transition 2058, 10, :o3, 2802906000, 59352685, 24
            tz.transition 2059, 3, :o5, 2816211600, 59356381, 24
            tz.transition 2059, 10, :o3, 2834355600, 59361421, 24
            tz.transition 2060, 3, :o5, 2847661200, 59365117, 24
            tz.transition 2060, 10, :o3, 2866410000, 59370325, 24
            tz.transition 2061, 3, :o5, 2879110800, 59373853, 24
            tz.transition 2061, 10, :o3, 2897859600, 59379061, 24
            tz.transition 2062, 3, :o5, 2910560400, 59382589, 24
            tz.transition 2062, 10, :o3, 2929309200, 59387797, 24
            tz.transition 2063, 3, :o5, 2942010000, 59391325, 24
            tz.transition 2063, 10, :o3, 2960758800, 59396533, 24
            tz.transition 2064, 3, :o5, 2974064400, 59400229, 24
            tz.transition 2064, 10, :o3, 2992208400, 59405269, 24
            tz.transition 2065, 3, :o5, 3005514000, 59408965, 24
            tz.transition 2065, 10, :o3, 3023658000, 59414005, 24
            tz.transition 2066, 3, :o5, 3036963600, 59417701, 24
            tz.transition 2066, 10, :o3, 3055712400, 59422909, 24
            tz.transition 2067, 3, :o5, 3068413200, 59426437, 24
            tz.transition 2067, 10, :o3, 3087162000, 59431645, 24
            tz.transition 2068, 3, :o5, 3099862800, 59435173, 24
            tz.transition 2068, 10, :o3, 3118611600, 59440381, 24
          end
        end
      end
    end
  end
end
