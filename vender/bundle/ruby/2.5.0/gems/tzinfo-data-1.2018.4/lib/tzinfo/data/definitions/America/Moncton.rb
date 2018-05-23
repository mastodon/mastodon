# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Moncton
          include TimezoneDefinition
          
          timezone 'America/Moncton' do |tz|
            tz.offset :o0, -15548, 0, :LMT
            tz.offset :o1, -18000, 0, :EST
            tz.offset :o2, -14400, 0, :AST
            tz.offset :o3, -14400, 3600, :ADT
            tz.offset :o4, -14400, 3600, :AWT
            tz.offset :o5, -14400, 3600, :APT
            
            tz.transition 1883, 12, :o1, -2715882052, 52037719487, 21600
            tz.transition 1902, 6, :o2, -2131642800, 57981977, 24
            tz.transition 1918, 4, :o3, -1632074400, 9686791, 4
            tz.transition 1918, 10, :o2, -1615143600, 58125449, 24
            tz.transition 1933, 6, :o3, -1153681200, 58253633, 24
            tz.transition 1933, 9, :o2, -1145822400, 7281977, 3
            tz.transition 1934, 6, :o3, -1122231600, 58262369, 24
            tz.transition 1934, 9, :o2, -1114372800, 7283069, 3
            tz.transition 1935, 6, :o3, -1090782000, 58271105, 24
            tz.transition 1935, 9, :o2, -1082923200, 7284161, 3
            tz.transition 1936, 6, :o3, -1059332400, 58279841, 24
            tz.transition 1936, 9, :o2, -1051473600, 7285253, 3
            tz.transition 1937, 6, :o3, -1027882800, 58288577, 24
            tz.transition 1937, 9, :o2, -1020024000, 7286345, 3
            tz.transition 1938, 6, :o3, -996433200, 58297313, 24
            tz.transition 1938, 9, :o2, -988574400, 7287437, 3
            tz.transition 1939, 5, :o3, -965674800, 58305857, 24
            tz.transition 1939, 9, :o2, -955396800, 7288589, 3
            tz.transition 1940, 5, :o3, -934743600, 58314449, 24
            tz.transition 1940, 9, :o2, -923947200, 7289681, 3
            tz.transition 1941, 5, :o3, -904503600, 58322849, 24
            tz.transition 1941, 9, :o2, -891892800, 7290794, 3
            tz.transition 1942, 2, :o4, -880221600, 9721599, 4
            tz.transition 1945, 8, :o5, -769395600, 58360379, 24
            tz.transition 1945, 9, :o2, -765399600, 58361489, 24
            tz.transition 1946, 4, :o3, -747252000, 9727755, 4
            tz.transition 1946, 9, :o2, -733950000, 58370225, 24
            tz.transition 1947, 4, :o3, -715802400, 9729211, 4
            tz.transition 1947, 9, :o2, -702500400, 58378961, 24
            tz.transition 1948, 4, :o3, -684352800, 9730667, 4
            tz.transition 1948, 9, :o2, -671050800, 58387697, 24
            tz.transition 1949, 4, :o3, -652903200, 9732123, 4
            tz.transition 1949, 9, :o2, -639601200, 58396433, 24
            tz.transition 1950, 4, :o3, -620848800, 9733607, 4
            tz.transition 1950, 9, :o2, -608151600, 58405169, 24
            tz.transition 1951, 4, :o3, -589399200, 9735063, 4
            tz.transition 1951, 9, :o2, -576097200, 58414073, 24
            tz.transition 1952, 4, :o3, -557949600, 9736519, 4
            tz.transition 1952, 9, :o2, -544647600, 58422809, 24
            tz.transition 1953, 4, :o3, -526500000, 9737975, 4
            tz.transition 1953, 9, :o2, -513198000, 58431545, 24
            tz.transition 1954, 4, :o3, -495050400, 9739431, 4
            tz.transition 1954, 9, :o2, -481748400, 58440281, 24
            tz.transition 1955, 4, :o3, -463600800, 9740887, 4
            tz.transition 1955, 9, :o2, -450298800, 58449017, 24
            tz.transition 1956, 4, :o3, -431546400, 9742371, 4
            tz.transition 1956, 9, :o2, -418244400, 58457921, 24
            tz.transition 1957, 4, :o3, -400096800, 9743827, 4
            tz.transition 1957, 10, :o2, -384375600, 58467329, 24
            tz.transition 1958, 4, :o3, -368647200, 9745283, 4
            tz.transition 1958, 10, :o2, -352926000, 58476065, 24
            tz.transition 1959, 4, :o3, -337197600, 9746739, 4
            tz.transition 1959, 10, :o2, -321476400, 58484801, 24
            tz.transition 1960, 4, :o3, -305748000, 9748195, 4
            tz.transition 1960, 10, :o2, -289422000, 58493705, 24
            tz.transition 1961, 4, :o3, -273693600, 9749679, 4
            tz.transition 1961, 10, :o2, -257972400, 58502441, 24
            tz.transition 1962, 4, :o3, -242244000, 9751135, 4
            tz.transition 1962, 10, :o2, -226522800, 58511177, 24
            tz.transition 1963, 4, :o3, -210794400, 9752591, 4
            tz.transition 1963, 10, :o2, -195073200, 58519913, 24
            tz.transition 1964, 4, :o3, -179344800, 9754047, 4
            tz.transition 1964, 10, :o2, -163623600, 58528649, 24
            tz.transition 1965, 4, :o3, -147895200, 9755503, 4
            tz.transition 1965, 10, :o2, -131569200, 58537553, 24
            tz.transition 1966, 4, :o3, -116445600, 9756959, 4
            tz.transition 1966, 10, :o2, -100119600, 58546289, 24
            tz.transition 1967, 4, :o3, -84391200, 9758443, 4
            tz.transition 1967, 10, :o2, -68670000, 58555025, 24
            tz.transition 1968, 4, :o3, -52941600, 9759899, 4
            tz.transition 1968, 10, :o2, -37220400, 58563761, 24
            tz.transition 1969, 4, :o3, -21492000, 9761355, 4
            tz.transition 1969, 10, :o2, -5770800, 58572497, 24
            tz.transition 1970, 4, :o3, 9957600
            tz.transition 1970, 10, :o2, 25678800
            tz.transition 1971, 4, :o3, 41407200
            tz.transition 1971, 10, :o2, 57733200
            tz.transition 1972, 4, :o3, 73461600
            tz.transition 1972, 10, :o2, 89182800
            tz.transition 1974, 4, :o3, 136360800
            tz.transition 1974, 10, :o2, 152082000
            tz.transition 1975, 4, :o3, 167810400
            tz.transition 1975, 10, :o2, 183531600
            tz.transition 1976, 4, :o3, 199260000
            tz.transition 1976, 10, :o2, 215586000
            tz.transition 1977, 4, :o3, 230709600
            tz.transition 1977, 10, :o2, 247035600
            tz.transition 1978, 4, :o3, 262764000
            tz.transition 1978, 10, :o2, 278485200
            tz.transition 1979, 4, :o3, 294213600
            tz.transition 1979, 10, :o2, 309934800
            tz.transition 1980, 4, :o3, 325663200
            tz.transition 1980, 10, :o2, 341384400
            tz.transition 1981, 4, :o3, 357112800
            tz.transition 1981, 10, :o2, 372834000
            tz.transition 1982, 4, :o3, 388562400
            tz.transition 1982, 10, :o2, 404888400
            tz.transition 1983, 4, :o3, 420012000
            tz.transition 1983, 10, :o2, 436338000
            tz.transition 1984, 4, :o3, 452066400
            tz.transition 1984, 10, :o2, 467787600
            tz.transition 1985, 4, :o3, 483516000
            tz.transition 1985, 10, :o2, 499237200
            tz.transition 1986, 4, :o3, 514965600
            tz.transition 1986, 10, :o2, 530686800
            tz.transition 1987, 4, :o3, 544600800
            tz.transition 1987, 10, :o2, 562136400
            tz.transition 1988, 4, :o3, 576050400
            tz.transition 1988, 10, :o2, 594190800
            tz.transition 1989, 4, :o3, 607500000
            tz.transition 1989, 10, :o2, 625640400
            tz.transition 1990, 4, :o3, 638949600
            tz.transition 1990, 10, :o2, 657090000
            tz.transition 1991, 4, :o3, 671004000
            tz.transition 1991, 10, :o2, 688539600
            tz.transition 1992, 4, :o3, 702453600
            tz.transition 1992, 10, :o2, 719989200
            tz.transition 1993, 4, :o3, 733896060
            tz.transition 1993, 10, :o2, 752036460
            tz.transition 1994, 4, :o3, 765345660
            tz.transition 1994, 10, :o2, 783486060
            tz.transition 1995, 4, :o3, 796795260
            tz.transition 1995, 10, :o2, 814935660
            tz.transition 1996, 4, :o3, 828849660
            tz.transition 1996, 10, :o2, 846385260
            tz.transition 1997, 4, :o3, 860299260
            tz.transition 1997, 10, :o2, 877834860
            tz.transition 1998, 4, :o3, 891748860
            tz.transition 1998, 10, :o2, 909284460
            tz.transition 1999, 4, :o3, 923198460
            tz.transition 1999, 10, :o2, 941338860
            tz.transition 2000, 4, :o3, 954648060
            tz.transition 2000, 10, :o2, 972788460
            tz.transition 2001, 4, :o3, 986097660
            tz.transition 2001, 10, :o2, 1004238060
            tz.transition 2002, 4, :o3, 1018152060
            tz.transition 2002, 10, :o2, 1035687660
            tz.transition 2003, 4, :o3, 1049601660
            tz.transition 2003, 10, :o2, 1067137260
            tz.transition 2004, 4, :o3, 1081051260
            tz.transition 2004, 10, :o2, 1099191660
            tz.transition 2005, 4, :o3, 1112500860
            tz.transition 2005, 10, :o2, 1130641260
            tz.transition 2006, 4, :o3, 1143950460
            tz.transition 2006, 10, :o2, 1162090860
            tz.transition 2007, 3, :o3, 1173592800
            tz.transition 2007, 11, :o2, 1194152400
            tz.transition 2008, 3, :o3, 1205042400
            tz.transition 2008, 11, :o2, 1225602000
            tz.transition 2009, 3, :o3, 1236492000
            tz.transition 2009, 11, :o2, 1257051600
            tz.transition 2010, 3, :o3, 1268546400
            tz.transition 2010, 11, :o2, 1289106000
            tz.transition 2011, 3, :o3, 1299996000
            tz.transition 2011, 11, :o2, 1320555600
            tz.transition 2012, 3, :o3, 1331445600
            tz.transition 2012, 11, :o2, 1352005200
            tz.transition 2013, 3, :o3, 1362895200
            tz.transition 2013, 11, :o2, 1383454800
            tz.transition 2014, 3, :o3, 1394344800
            tz.transition 2014, 11, :o2, 1414904400
            tz.transition 2015, 3, :o3, 1425794400
            tz.transition 2015, 11, :o2, 1446354000
            tz.transition 2016, 3, :o3, 1457848800
            tz.transition 2016, 11, :o2, 1478408400
            tz.transition 2017, 3, :o3, 1489298400
            tz.transition 2017, 11, :o2, 1509858000
            tz.transition 2018, 3, :o3, 1520748000
            tz.transition 2018, 11, :o2, 1541307600
            tz.transition 2019, 3, :o3, 1552197600
            tz.transition 2019, 11, :o2, 1572757200
            tz.transition 2020, 3, :o3, 1583647200
            tz.transition 2020, 11, :o2, 1604206800
            tz.transition 2021, 3, :o3, 1615701600
            tz.transition 2021, 11, :o2, 1636261200
            tz.transition 2022, 3, :o3, 1647151200
            tz.transition 2022, 11, :o2, 1667710800
            tz.transition 2023, 3, :o3, 1678600800
            tz.transition 2023, 11, :o2, 1699160400
            tz.transition 2024, 3, :o3, 1710050400
            tz.transition 2024, 11, :o2, 1730610000
            tz.transition 2025, 3, :o3, 1741500000
            tz.transition 2025, 11, :o2, 1762059600
            tz.transition 2026, 3, :o3, 1772949600
            tz.transition 2026, 11, :o2, 1793509200
            tz.transition 2027, 3, :o3, 1805004000
            tz.transition 2027, 11, :o2, 1825563600
            tz.transition 2028, 3, :o3, 1836453600
            tz.transition 2028, 11, :o2, 1857013200
            tz.transition 2029, 3, :o3, 1867903200
            tz.transition 2029, 11, :o2, 1888462800
            tz.transition 2030, 3, :o3, 1899352800
            tz.transition 2030, 11, :o2, 1919912400
            tz.transition 2031, 3, :o3, 1930802400
            tz.transition 2031, 11, :o2, 1951362000
            tz.transition 2032, 3, :o3, 1962856800
            tz.transition 2032, 11, :o2, 1983416400
            tz.transition 2033, 3, :o3, 1994306400
            tz.transition 2033, 11, :o2, 2014866000
            tz.transition 2034, 3, :o3, 2025756000
            tz.transition 2034, 11, :o2, 2046315600
            tz.transition 2035, 3, :o3, 2057205600
            tz.transition 2035, 11, :o2, 2077765200
            tz.transition 2036, 3, :o3, 2088655200
            tz.transition 2036, 11, :o2, 2109214800
            tz.transition 2037, 3, :o3, 2120104800
            tz.transition 2037, 11, :o2, 2140664400
            tz.transition 2038, 3, :o3, 2152159200, 9861987, 4
            tz.transition 2038, 11, :o2, 2172718800, 59177633, 24
            tz.transition 2039, 3, :o3, 2183608800, 9863443, 4
            tz.transition 2039, 11, :o2, 2204168400, 59186369, 24
            tz.transition 2040, 3, :o3, 2215058400, 9864899, 4
            tz.transition 2040, 11, :o2, 2235618000, 59195105, 24
            tz.transition 2041, 3, :o3, 2246508000, 9866355, 4
            tz.transition 2041, 11, :o2, 2267067600, 59203841, 24
            tz.transition 2042, 3, :o3, 2277957600, 9867811, 4
            tz.transition 2042, 11, :o2, 2298517200, 59212577, 24
            tz.transition 2043, 3, :o3, 2309407200, 9869267, 4
            tz.transition 2043, 11, :o2, 2329966800, 59221313, 24
            tz.transition 2044, 3, :o3, 2341461600, 9870751, 4
            tz.transition 2044, 11, :o2, 2362021200, 59230217, 24
            tz.transition 2045, 3, :o3, 2372911200, 9872207, 4
            tz.transition 2045, 11, :o2, 2393470800, 59238953, 24
            tz.transition 2046, 3, :o3, 2404360800, 9873663, 4
            tz.transition 2046, 11, :o2, 2424920400, 59247689, 24
            tz.transition 2047, 3, :o3, 2435810400, 9875119, 4
            tz.transition 2047, 11, :o2, 2456370000, 59256425, 24
            tz.transition 2048, 3, :o3, 2467260000, 9876575, 4
            tz.transition 2048, 11, :o2, 2487819600, 59265161, 24
            tz.transition 2049, 3, :o3, 2499314400, 9878059, 4
            tz.transition 2049, 11, :o2, 2519874000, 59274065, 24
            tz.transition 2050, 3, :o3, 2530764000, 9879515, 4
            tz.transition 2050, 11, :o2, 2551323600, 59282801, 24
            tz.transition 2051, 3, :o3, 2562213600, 9880971, 4
            tz.transition 2051, 11, :o2, 2582773200, 59291537, 24
            tz.transition 2052, 3, :o3, 2593663200, 9882427, 4
            tz.transition 2052, 11, :o2, 2614222800, 59300273, 24
            tz.transition 2053, 3, :o3, 2625112800, 9883883, 4
            tz.transition 2053, 11, :o2, 2645672400, 59309009, 24
            tz.transition 2054, 3, :o3, 2656562400, 9885339, 4
            tz.transition 2054, 11, :o2, 2677122000, 59317745, 24
            tz.transition 2055, 3, :o3, 2688616800, 9886823, 4
            tz.transition 2055, 11, :o2, 2709176400, 59326649, 24
            tz.transition 2056, 3, :o3, 2720066400, 9888279, 4
            tz.transition 2056, 11, :o2, 2740626000, 59335385, 24
            tz.transition 2057, 3, :o3, 2751516000, 9889735, 4
            tz.transition 2057, 11, :o2, 2772075600, 59344121, 24
            tz.transition 2058, 3, :o3, 2782965600, 9891191, 4
            tz.transition 2058, 11, :o2, 2803525200, 59352857, 24
            tz.transition 2059, 3, :o3, 2814415200, 9892647, 4
            tz.transition 2059, 11, :o2, 2834974800, 59361593, 24
            tz.transition 2060, 3, :o3, 2846469600, 9894131, 4
            tz.transition 2060, 11, :o2, 2867029200, 59370497, 24
            tz.transition 2061, 3, :o3, 2877919200, 9895587, 4
            tz.transition 2061, 11, :o2, 2898478800, 59379233, 24
            tz.transition 2062, 3, :o3, 2909368800, 9897043, 4
            tz.transition 2062, 11, :o2, 2929928400, 59387969, 24
            tz.transition 2063, 3, :o3, 2940818400, 9898499, 4
            tz.transition 2063, 11, :o2, 2961378000, 59396705, 24
            tz.transition 2064, 3, :o3, 2972268000, 9899955, 4
            tz.transition 2064, 11, :o2, 2992827600, 59405441, 24
            tz.transition 2065, 3, :o3, 3003717600, 9901411, 4
            tz.transition 2065, 11, :o2, 3024277200, 59414177, 24
            tz.transition 2066, 3, :o3, 3035772000, 9902895, 4
            tz.transition 2066, 11, :o2, 3056331600, 59423081, 24
            tz.transition 2067, 3, :o3, 3067221600, 9904351, 4
            tz.transition 2067, 11, :o2, 3087781200, 59431817, 24
            tz.transition 2068, 3, :o3, 3098671200, 9905807, 4
            tz.transition 2068, 11, :o2, 3119230800, 59440553, 24
          end
        end
      end
    end
  end
end
