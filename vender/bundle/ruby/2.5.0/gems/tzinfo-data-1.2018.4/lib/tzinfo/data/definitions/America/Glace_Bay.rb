# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Glace_Bay
          include TimezoneDefinition
          
          timezone 'America/Glace_Bay' do |tz|
            tz.offset :o0, -14388, 0, :LMT
            tz.offset :o1, -14400, 0, :AST
            tz.offset :o2, -14400, 3600, :ADT
            tz.offset :o3, -14400, 3600, :AWT
            tz.offset :o4, -14400, 3600, :APT
            
            tz.transition 1902, 6, :o1, -2131646412, 17394592799, 7200
            tz.transition 1918, 4, :o2, -1632074400, 9686791, 4
            tz.transition 1918, 10, :o1, -1615143600, 58125449, 24
            tz.transition 1942, 2, :o3, -880221600, 9721599, 4
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765399600, 58361489, 24
            tz.transition 1953, 4, :o2, -526500000, 9737975, 4
            tz.transition 1953, 9, :o1, -513198000, 58431545, 24
            tz.transition 1972, 4, :o2, 73461600
            tz.transition 1972, 10, :o1, 89182800
            tz.transition 1973, 4, :o2, 104911200
            tz.transition 1973, 10, :o1, 120632400
            tz.transition 1974, 4, :o2, 136360800
            tz.transition 1974, 10, :o1, 152082000
            tz.transition 1975, 4, :o2, 167810400
            tz.transition 1975, 10, :o1, 183531600
            tz.transition 1976, 4, :o2, 199260000
            tz.transition 1976, 10, :o1, 215586000
            tz.transition 1977, 4, :o2, 230709600
            tz.transition 1977, 10, :o1, 247035600
            tz.transition 1978, 4, :o2, 262764000
            tz.transition 1978, 10, :o1, 278485200
            tz.transition 1979, 4, :o2, 294213600
            tz.transition 1979, 10, :o1, 309934800
            tz.transition 1980, 4, :o2, 325663200
            tz.transition 1980, 10, :o1, 341384400
            tz.transition 1981, 4, :o2, 357112800
            tz.transition 1981, 10, :o1, 372834000
            tz.transition 1982, 4, :o2, 388562400
            tz.transition 1982, 10, :o1, 404888400
            tz.transition 1983, 4, :o2, 420012000
            tz.transition 1983, 10, :o1, 436338000
            tz.transition 1984, 4, :o2, 452066400
            tz.transition 1984, 10, :o1, 467787600
            tz.transition 1985, 4, :o2, 483516000
            tz.transition 1985, 10, :o1, 499237200
            tz.transition 1986, 4, :o2, 514965600
            tz.transition 1986, 10, :o1, 530686800
            tz.transition 1987, 4, :o2, 544600800
            tz.transition 1987, 10, :o1, 562136400
            tz.transition 1988, 4, :o2, 576050400
            tz.transition 1988, 10, :o1, 594190800
            tz.transition 1989, 4, :o2, 607500000
            tz.transition 1989, 10, :o1, 625640400
            tz.transition 1990, 4, :o2, 638949600
            tz.transition 1990, 10, :o1, 657090000
            tz.transition 1991, 4, :o2, 671004000
            tz.transition 1991, 10, :o1, 688539600
            tz.transition 1992, 4, :o2, 702453600
            tz.transition 1992, 10, :o1, 719989200
            tz.transition 1993, 4, :o2, 733903200
            tz.transition 1993, 10, :o1, 752043600
            tz.transition 1994, 4, :o2, 765352800
            tz.transition 1994, 10, :o1, 783493200
            tz.transition 1995, 4, :o2, 796802400
            tz.transition 1995, 10, :o1, 814942800
            tz.transition 1996, 4, :o2, 828856800
            tz.transition 1996, 10, :o1, 846392400
            tz.transition 1997, 4, :o2, 860306400
            tz.transition 1997, 10, :o1, 877842000
            tz.transition 1998, 4, :o2, 891756000
            tz.transition 1998, 10, :o1, 909291600
            tz.transition 1999, 4, :o2, 923205600
            tz.transition 1999, 10, :o1, 941346000
            tz.transition 2000, 4, :o2, 954655200
            tz.transition 2000, 10, :o1, 972795600
            tz.transition 2001, 4, :o2, 986104800
            tz.transition 2001, 10, :o1, 1004245200
            tz.transition 2002, 4, :o2, 1018159200
            tz.transition 2002, 10, :o1, 1035694800
            tz.transition 2003, 4, :o2, 1049608800
            tz.transition 2003, 10, :o1, 1067144400
            tz.transition 2004, 4, :o2, 1081058400
            tz.transition 2004, 10, :o1, 1099198800
            tz.transition 2005, 4, :o2, 1112508000
            tz.transition 2005, 10, :o1, 1130648400
            tz.transition 2006, 4, :o2, 1143957600
            tz.transition 2006, 10, :o1, 1162098000
            tz.transition 2007, 3, :o2, 1173592800
            tz.transition 2007, 11, :o1, 1194152400
            tz.transition 2008, 3, :o2, 1205042400
            tz.transition 2008, 11, :o1, 1225602000
            tz.transition 2009, 3, :o2, 1236492000
            tz.transition 2009, 11, :o1, 1257051600
            tz.transition 2010, 3, :o2, 1268546400
            tz.transition 2010, 11, :o1, 1289106000
            tz.transition 2011, 3, :o2, 1299996000
            tz.transition 2011, 11, :o1, 1320555600
            tz.transition 2012, 3, :o2, 1331445600
            tz.transition 2012, 11, :o1, 1352005200
            tz.transition 2013, 3, :o2, 1362895200
            tz.transition 2013, 11, :o1, 1383454800
            tz.transition 2014, 3, :o2, 1394344800
            tz.transition 2014, 11, :o1, 1414904400
            tz.transition 2015, 3, :o2, 1425794400
            tz.transition 2015, 11, :o1, 1446354000
            tz.transition 2016, 3, :o2, 1457848800
            tz.transition 2016, 11, :o1, 1478408400
            tz.transition 2017, 3, :o2, 1489298400
            tz.transition 2017, 11, :o1, 1509858000
            tz.transition 2018, 3, :o2, 1520748000
            tz.transition 2018, 11, :o1, 1541307600
            tz.transition 2019, 3, :o2, 1552197600
            tz.transition 2019, 11, :o1, 1572757200
            tz.transition 2020, 3, :o2, 1583647200
            tz.transition 2020, 11, :o1, 1604206800
            tz.transition 2021, 3, :o2, 1615701600
            tz.transition 2021, 11, :o1, 1636261200
            tz.transition 2022, 3, :o2, 1647151200
            tz.transition 2022, 11, :o1, 1667710800
            tz.transition 2023, 3, :o2, 1678600800
            tz.transition 2023, 11, :o1, 1699160400
            tz.transition 2024, 3, :o2, 1710050400
            tz.transition 2024, 11, :o1, 1730610000
            tz.transition 2025, 3, :o2, 1741500000
            tz.transition 2025, 11, :o1, 1762059600
            tz.transition 2026, 3, :o2, 1772949600
            tz.transition 2026, 11, :o1, 1793509200
            tz.transition 2027, 3, :o2, 1805004000
            tz.transition 2027, 11, :o1, 1825563600
            tz.transition 2028, 3, :o2, 1836453600
            tz.transition 2028, 11, :o1, 1857013200
            tz.transition 2029, 3, :o2, 1867903200
            tz.transition 2029, 11, :o1, 1888462800
            tz.transition 2030, 3, :o2, 1899352800
            tz.transition 2030, 11, :o1, 1919912400
            tz.transition 2031, 3, :o2, 1930802400
            tz.transition 2031, 11, :o1, 1951362000
            tz.transition 2032, 3, :o2, 1962856800
            tz.transition 2032, 11, :o1, 1983416400
            tz.transition 2033, 3, :o2, 1994306400
            tz.transition 2033, 11, :o1, 2014866000
            tz.transition 2034, 3, :o2, 2025756000
            tz.transition 2034, 11, :o1, 2046315600
            tz.transition 2035, 3, :o2, 2057205600
            tz.transition 2035, 11, :o1, 2077765200
            tz.transition 2036, 3, :o2, 2088655200
            tz.transition 2036, 11, :o1, 2109214800
            tz.transition 2037, 3, :o2, 2120104800
            tz.transition 2037, 11, :o1, 2140664400
            tz.transition 2038, 3, :o2, 2152159200, 9861987, 4
            tz.transition 2038, 11, :o1, 2172718800, 59177633, 24
            tz.transition 2039, 3, :o2, 2183608800, 9863443, 4
            tz.transition 2039, 11, :o1, 2204168400, 59186369, 24
            tz.transition 2040, 3, :o2, 2215058400, 9864899, 4
            tz.transition 2040, 11, :o1, 2235618000, 59195105, 24
            tz.transition 2041, 3, :o2, 2246508000, 9866355, 4
            tz.transition 2041, 11, :o1, 2267067600, 59203841, 24
            tz.transition 2042, 3, :o2, 2277957600, 9867811, 4
            tz.transition 2042, 11, :o1, 2298517200, 59212577, 24
            tz.transition 2043, 3, :o2, 2309407200, 9869267, 4
            tz.transition 2043, 11, :o1, 2329966800, 59221313, 24
            tz.transition 2044, 3, :o2, 2341461600, 9870751, 4
            tz.transition 2044, 11, :o1, 2362021200, 59230217, 24
            tz.transition 2045, 3, :o2, 2372911200, 9872207, 4
            tz.transition 2045, 11, :o1, 2393470800, 59238953, 24
            tz.transition 2046, 3, :o2, 2404360800, 9873663, 4
            tz.transition 2046, 11, :o1, 2424920400, 59247689, 24
            tz.transition 2047, 3, :o2, 2435810400, 9875119, 4
            tz.transition 2047, 11, :o1, 2456370000, 59256425, 24
            tz.transition 2048, 3, :o2, 2467260000, 9876575, 4
            tz.transition 2048, 11, :o1, 2487819600, 59265161, 24
            tz.transition 2049, 3, :o2, 2499314400, 9878059, 4
            tz.transition 2049, 11, :o1, 2519874000, 59274065, 24
            tz.transition 2050, 3, :o2, 2530764000, 9879515, 4
            tz.transition 2050, 11, :o1, 2551323600, 59282801, 24
            tz.transition 2051, 3, :o2, 2562213600, 9880971, 4
            tz.transition 2051, 11, :o1, 2582773200, 59291537, 24
            tz.transition 2052, 3, :o2, 2593663200, 9882427, 4
            tz.transition 2052, 11, :o1, 2614222800, 59300273, 24
            tz.transition 2053, 3, :o2, 2625112800, 9883883, 4
            tz.transition 2053, 11, :o1, 2645672400, 59309009, 24
            tz.transition 2054, 3, :o2, 2656562400, 9885339, 4
            tz.transition 2054, 11, :o1, 2677122000, 59317745, 24
            tz.transition 2055, 3, :o2, 2688616800, 9886823, 4
            tz.transition 2055, 11, :o1, 2709176400, 59326649, 24
            tz.transition 2056, 3, :o2, 2720066400, 9888279, 4
            tz.transition 2056, 11, :o1, 2740626000, 59335385, 24
            tz.transition 2057, 3, :o2, 2751516000, 9889735, 4
            tz.transition 2057, 11, :o1, 2772075600, 59344121, 24
            tz.transition 2058, 3, :o2, 2782965600, 9891191, 4
            tz.transition 2058, 11, :o1, 2803525200, 59352857, 24
            tz.transition 2059, 3, :o2, 2814415200, 9892647, 4
            tz.transition 2059, 11, :o1, 2834974800, 59361593, 24
            tz.transition 2060, 3, :o2, 2846469600, 9894131, 4
            tz.transition 2060, 11, :o1, 2867029200, 59370497, 24
            tz.transition 2061, 3, :o2, 2877919200, 9895587, 4
            tz.transition 2061, 11, :o1, 2898478800, 59379233, 24
            tz.transition 2062, 3, :o2, 2909368800, 9897043, 4
            tz.transition 2062, 11, :o1, 2929928400, 59387969, 24
            tz.transition 2063, 3, :o2, 2940818400, 9898499, 4
            tz.transition 2063, 11, :o1, 2961378000, 59396705, 24
            tz.transition 2064, 3, :o2, 2972268000, 9899955, 4
            tz.transition 2064, 11, :o1, 2992827600, 59405441, 24
            tz.transition 2065, 3, :o2, 3003717600, 9901411, 4
            tz.transition 2065, 11, :o1, 3024277200, 59414177, 24
            tz.transition 2066, 3, :o2, 3035772000, 9902895, 4
            tz.transition 2066, 11, :o1, 3056331600, 59423081, 24
            tz.transition 2067, 3, :o2, 3067221600, 9904351, 4
            tz.transition 2067, 11, :o1, 3087781200, 59431817, 24
            tz.transition 2068, 3, :o2, 3098671200, 9905807, 4
            tz.transition 2068, 11, :o1, 3119230800, 59440553, 24
          end
        end
      end
    end
  end
end
