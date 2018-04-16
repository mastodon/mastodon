# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Havana
          include TimezoneDefinition
          
          timezone 'America/Havana' do |tz|
            tz.offset :o0, -19768, 0, :LMT
            tz.offset :o1, -19776, 0, :HMT
            tz.offset :o2, -18000, 0, :CST
            tz.offset :o3, -18000, 3600, :CDT
            
            tz.transition 1890, 1, :o1, -2524501832, 26042782271, 10800
            tz.transition 1925, 7, :o2, -1402813824, 1090958053, 450
            tz.transition 1928, 6, :o3, -1311534000, 58209785, 24
            tz.transition 1928, 10, :o2, -1300996800, 7276589, 3
            tz.transition 1940, 6, :o3, -933534000, 58314785, 24
            tz.transition 1940, 9, :o2, -925675200, 7289621, 3
            tz.transition 1941, 6, :o3, -902084400, 58323521, 24
            tz.transition 1941, 9, :o2, -893620800, 7290734, 3
            tz.transition 1942, 6, :o3, -870030000, 58332425, 24
            tz.transition 1942, 9, :o2, -862171200, 7291826, 3
            tz.transition 1945, 6, :o3, -775681200, 58358633, 24
            tz.transition 1945, 9, :o2, -767822400, 7295102, 3
            tz.transition 1946, 6, :o3, -744231600, 58367369, 24
            tz.transition 1946, 9, :o2, -736372800, 7296194, 3
            tz.transition 1965, 6, :o3, -144702000, 58533905, 24
            tz.transition 1965, 9, :o2, -134251200, 7317101, 3
            tz.transition 1966, 5, :o3, -113425200, 58542593, 24
            tz.transition 1966, 10, :o2, -102542400, 7318202, 3
            tz.transition 1967, 4, :o3, -86295600, 58550129, 24
            tz.transition 1967, 9, :o2, -72907200, 7319231, 3
            tz.transition 1968, 4, :o3, -54154800, 58559057, 24
            tz.transition 1968, 9, :o2, -41457600, 7320323, 3
            tz.transition 1969, 4, :o3, -21495600, 58568129, 24
            tz.transition 1969, 10, :o2, -5774400, 7321562, 3
            tz.transition 1970, 4, :o3, 9954000
            tz.transition 1970, 10, :o2, 25675200
            tz.transition 1971, 4, :o3, 41403600
            tz.transition 1971, 10, :o2, 57729600
            tz.transition 1972, 4, :o3, 73458000
            tz.transition 1972, 10, :o2, 87364800
            tz.transition 1973, 4, :o3, 104907600
            tz.transition 1973, 10, :o2, 118900800
            tz.transition 1974, 4, :o3, 136357200
            tz.transition 1974, 10, :o2, 150436800
            tz.transition 1975, 4, :o3, 167806800
            tz.transition 1975, 10, :o2, 183528000
            tz.transition 1976, 4, :o3, 199256400
            tz.transition 1976, 10, :o2, 215582400
            tz.transition 1977, 4, :o3, 230706000
            tz.transition 1977, 10, :o2, 247032000
            tz.transition 1978, 5, :o3, 263365200
            tz.transition 1978, 10, :o2, 276667200
            tz.transition 1979, 3, :o3, 290581200
            tz.transition 1979, 10, :o2, 308721600
            tz.transition 1980, 3, :o3, 322030800
            tz.transition 1980, 10, :o2, 340171200
            tz.transition 1981, 5, :o3, 358318800
            tz.transition 1981, 10, :o2, 371620800
            tz.transition 1982, 5, :o3, 389768400
            tz.transition 1982, 10, :o2, 403070400
            tz.transition 1983, 5, :o3, 421218000
            tz.transition 1983, 10, :o2, 434520000
            tz.transition 1984, 5, :o3, 452667600
            tz.transition 1984, 10, :o2, 466574400
            tz.transition 1985, 5, :o3, 484117200
            tz.transition 1985, 10, :o2, 498024000
            tz.transition 1986, 3, :o3, 511333200
            tz.transition 1986, 10, :o2, 529473600
            tz.transition 1987, 3, :o3, 542782800
            tz.transition 1987, 10, :o2, 560923200
            tz.transition 1988, 3, :o3, 574837200
            tz.transition 1988, 10, :o2, 592372800
            tz.transition 1989, 3, :o3, 606286800
            tz.transition 1989, 10, :o2, 623822400
            tz.transition 1990, 4, :o3, 638946000
            tz.transition 1990, 10, :o2, 655876800
            tz.transition 1991, 4, :o3, 671000400
            tz.transition 1991, 10, :o2, 687330000
            tz.transition 1992, 4, :o3, 702450000
            tz.transition 1992, 10, :o2, 718779600
            tz.transition 1993, 4, :o3, 733899600
            tz.transition 1993, 10, :o2, 750229200
            tz.transition 1994, 4, :o3, 765349200
            tz.transition 1994, 10, :o2, 781678800
            tz.transition 1995, 4, :o3, 796798800
            tz.transition 1995, 10, :o2, 813128400
            tz.transition 1996, 4, :o3, 828853200
            tz.transition 1996, 10, :o2, 844578000
            tz.transition 1997, 4, :o3, 860302800
            tz.transition 1997, 10, :o2, 876632400
            tz.transition 1998, 3, :o3, 891147600
            tz.transition 1998, 10, :o2, 909291600
            tz.transition 1999, 3, :o3, 922597200
            tz.transition 1999, 10, :o2, 941346000
            tz.transition 2000, 4, :o3, 954651600
            tz.transition 2000, 10, :o2, 972795600
            tz.transition 2001, 4, :o3, 986101200
            tz.transition 2001, 10, :o2, 1004245200
            tz.transition 2002, 4, :o3, 1018155600
            tz.transition 2002, 10, :o2, 1035694800
            tz.transition 2003, 4, :o3, 1049605200
            tz.transition 2003, 10, :o2, 1067144400
            tz.transition 2004, 3, :o3, 1080450000
            tz.transition 2006, 10, :o2, 1162098000
            tz.transition 2007, 3, :o3, 1173589200
            tz.transition 2007, 10, :o2, 1193547600
            tz.transition 2008, 3, :o3, 1205643600
            tz.transition 2008, 10, :o2, 1224997200
            tz.transition 2009, 3, :o3, 1236488400
            tz.transition 2009, 10, :o2, 1256446800
            tz.transition 2010, 3, :o3, 1268542800
            tz.transition 2010, 10, :o2, 1288501200
            tz.transition 2011, 3, :o3, 1300597200
            tz.transition 2011, 11, :o2, 1321160400
            tz.transition 2012, 4, :o3, 1333256400
            tz.transition 2012, 11, :o2, 1352005200
            tz.transition 2013, 3, :o3, 1362891600
            tz.transition 2013, 11, :o2, 1383454800
            tz.transition 2014, 3, :o3, 1394341200
            tz.transition 2014, 11, :o2, 1414904400
            tz.transition 2015, 3, :o3, 1425790800
            tz.transition 2015, 11, :o2, 1446354000
            tz.transition 2016, 3, :o3, 1457845200
            tz.transition 2016, 11, :o2, 1478408400
            tz.transition 2017, 3, :o3, 1489294800
            tz.transition 2017, 11, :o2, 1509858000
            tz.transition 2018, 3, :o3, 1520744400
            tz.transition 2018, 11, :o2, 1541307600
            tz.transition 2019, 3, :o3, 1552194000
            tz.transition 2019, 11, :o2, 1572757200
            tz.transition 2020, 3, :o3, 1583643600
            tz.transition 2020, 11, :o2, 1604206800
            tz.transition 2021, 3, :o3, 1615698000
            tz.transition 2021, 11, :o2, 1636261200
            tz.transition 2022, 3, :o3, 1647147600
            tz.transition 2022, 11, :o2, 1667710800
            tz.transition 2023, 3, :o3, 1678597200
            tz.transition 2023, 11, :o2, 1699160400
            tz.transition 2024, 3, :o3, 1710046800
            tz.transition 2024, 11, :o2, 1730610000
            tz.transition 2025, 3, :o3, 1741496400
            tz.transition 2025, 11, :o2, 1762059600
            tz.transition 2026, 3, :o3, 1772946000
            tz.transition 2026, 11, :o2, 1793509200
            tz.transition 2027, 3, :o3, 1805000400
            tz.transition 2027, 11, :o2, 1825563600
            tz.transition 2028, 3, :o3, 1836450000
            tz.transition 2028, 11, :o2, 1857013200
            tz.transition 2029, 3, :o3, 1867899600
            tz.transition 2029, 11, :o2, 1888462800
            tz.transition 2030, 3, :o3, 1899349200
            tz.transition 2030, 11, :o2, 1919912400
            tz.transition 2031, 3, :o3, 1930798800
            tz.transition 2031, 11, :o2, 1951362000
            tz.transition 2032, 3, :o3, 1962853200
            tz.transition 2032, 11, :o2, 1983416400
            tz.transition 2033, 3, :o3, 1994302800
            tz.transition 2033, 11, :o2, 2014866000
            tz.transition 2034, 3, :o3, 2025752400
            tz.transition 2034, 11, :o2, 2046315600
            tz.transition 2035, 3, :o3, 2057202000
            tz.transition 2035, 11, :o2, 2077765200
            tz.transition 2036, 3, :o3, 2088651600
            tz.transition 2036, 11, :o2, 2109214800
            tz.transition 2037, 3, :o3, 2120101200
            tz.transition 2037, 11, :o2, 2140664400
            tz.transition 2038, 3, :o3, 2152155600, 59171921, 24
            tz.transition 2038, 11, :o2, 2172718800, 59177633, 24
            tz.transition 2039, 3, :o3, 2183605200, 59180657, 24
            tz.transition 2039, 11, :o2, 2204168400, 59186369, 24
            tz.transition 2040, 3, :o3, 2215054800, 59189393, 24
            tz.transition 2040, 11, :o2, 2235618000, 59195105, 24
            tz.transition 2041, 3, :o3, 2246504400, 59198129, 24
            tz.transition 2041, 11, :o2, 2267067600, 59203841, 24
            tz.transition 2042, 3, :o3, 2277954000, 59206865, 24
            tz.transition 2042, 11, :o2, 2298517200, 59212577, 24
            tz.transition 2043, 3, :o3, 2309403600, 59215601, 24
            tz.transition 2043, 11, :o2, 2329966800, 59221313, 24
            tz.transition 2044, 3, :o3, 2341458000, 59224505, 24
            tz.transition 2044, 11, :o2, 2362021200, 59230217, 24
            tz.transition 2045, 3, :o3, 2372907600, 59233241, 24
            tz.transition 2045, 11, :o2, 2393470800, 59238953, 24
            tz.transition 2046, 3, :o3, 2404357200, 59241977, 24
            tz.transition 2046, 11, :o2, 2424920400, 59247689, 24
            tz.transition 2047, 3, :o3, 2435806800, 59250713, 24
            tz.transition 2047, 11, :o2, 2456370000, 59256425, 24
            tz.transition 2048, 3, :o3, 2467256400, 59259449, 24
            tz.transition 2048, 11, :o2, 2487819600, 59265161, 24
            tz.transition 2049, 3, :o3, 2499310800, 59268353, 24
            tz.transition 2049, 11, :o2, 2519874000, 59274065, 24
            tz.transition 2050, 3, :o3, 2530760400, 59277089, 24
            tz.transition 2050, 11, :o2, 2551323600, 59282801, 24
            tz.transition 2051, 3, :o3, 2562210000, 59285825, 24
            tz.transition 2051, 11, :o2, 2582773200, 59291537, 24
            tz.transition 2052, 3, :o3, 2593659600, 59294561, 24
            tz.transition 2052, 11, :o2, 2614222800, 59300273, 24
            tz.transition 2053, 3, :o3, 2625109200, 59303297, 24
            tz.transition 2053, 11, :o2, 2645672400, 59309009, 24
            tz.transition 2054, 3, :o3, 2656558800, 59312033, 24
            tz.transition 2054, 11, :o2, 2677122000, 59317745, 24
            tz.transition 2055, 3, :o3, 2688613200, 59320937, 24
            tz.transition 2055, 11, :o2, 2709176400, 59326649, 24
            tz.transition 2056, 3, :o3, 2720062800, 59329673, 24
            tz.transition 2056, 11, :o2, 2740626000, 59335385, 24
            tz.transition 2057, 3, :o3, 2751512400, 59338409, 24
            tz.transition 2057, 11, :o2, 2772075600, 59344121, 24
            tz.transition 2058, 3, :o3, 2782962000, 59347145, 24
            tz.transition 2058, 11, :o2, 2803525200, 59352857, 24
            tz.transition 2059, 3, :o3, 2814411600, 59355881, 24
            tz.transition 2059, 11, :o2, 2834974800, 59361593, 24
            tz.transition 2060, 3, :o3, 2846466000, 59364785, 24
            tz.transition 2060, 11, :o2, 2867029200, 59370497, 24
            tz.transition 2061, 3, :o3, 2877915600, 59373521, 24
            tz.transition 2061, 11, :o2, 2898478800, 59379233, 24
            tz.transition 2062, 3, :o3, 2909365200, 59382257, 24
            tz.transition 2062, 11, :o2, 2929928400, 59387969, 24
            tz.transition 2063, 3, :o3, 2940814800, 59390993, 24
            tz.transition 2063, 11, :o2, 2961378000, 59396705, 24
            tz.transition 2064, 3, :o3, 2972264400, 59399729, 24
            tz.transition 2064, 11, :o2, 2992827600, 59405441, 24
            tz.transition 2065, 3, :o3, 3003714000, 59408465, 24
            tz.transition 2065, 11, :o2, 3024277200, 59414177, 24
            tz.transition 2066, 3, :o3, 3035768400, 59417369, 24
            tz.transition 2066, 11, :o2, 3056331600, 59423081, 24
            tz.transition 2067, 3, :o3, 3067218000, 59426105, 24
            tz.transition 2067, 11, :o2, 3087781200, 59431817, 24
            tz.transition 2068, 3, :o3, 3098667600, 59434841, 24
            tz.transition 2068, 11, :o2, 3119230800, 59440553, 24
          end
        end
      end
    end
  end
end
