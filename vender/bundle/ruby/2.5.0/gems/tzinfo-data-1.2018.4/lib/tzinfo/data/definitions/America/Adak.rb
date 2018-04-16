# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Adak
          include TimezoneDefinition
          
          timezone 'America/Adak' do |tz|
            tz.offset :o0, 44002, 0, :LMT
            tz.offset :o1, -42398, 0, :LMT
            tz.offset :o2, -39600, 0, :NST
            tz.offset :o3, -39600, 3600, :NWT
            tz.offset :o4, -39600, 3600, :NPT
            tz.offset :o5, -39600, 0, :BST
            tz.offset :o6, -39600, 3600, :BDT
            tz.offset :o7, -36000, 0, :AHST
            tz.offset :o8, -36000, 0, :HST
            tz.offset :o9, -36000, 3600, :HDT
            
            tz.transition 1867, 10, :o1, -3225223727, 207641536273, 86400
            tz.transition 1900, 8, :o2, -2188944802, 104338907599, 43200
            tz.transition 1942, 2, :o3, -880196400, 58329601, 24
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o2, -765374400, 2431729, 1
            tz.transition 1967, 4, :o5, -86878800, 58549967, 24
            tz.transition 1969, 4, :o6, -21466800, 58568137, 24
            tz.transition 1969, 10, :o5, -5745600, 2440521, 1
            tz.transition 1970, 4, :o6, 9982800
            tz.transition 1970, 10, :o5, 25704000
            tz.transition 1971, 4, :o6, 41432400
            tz.transition 1971, 10, :o5, 57758400
            tz.transition 1972, 4, :o6, 73486800
            tz.transition 1972, 10, :o5, 89208000
            tz.transition 1973, 4, :o6, 104936400
            tz.transition 1973, 10, :o5, 120657600
            tz.transition 1974, 1, :o6, 126709200
            tz.transition 1974, 10, :o5, 152107200
            tz.transition 1975, 2, :o6, 162392400
            tz.transition 1975, 10, :o5, 183556800
            tz.transition 1976, 4, :o6, 199285200
            tz.transition 1976, 10, :o5, 215611200
            tz.transition 1977, 4, :o6, 230734800
            tz.transition 1977, 10, :o5, 247060800
            tz.transition 1978, 4, :o6, 262789200
            tz.transition 1978, 10, :o5, 278510400
            tz.transition 1979, 4, :o6, 294238800
            tz.transition 1979, 10, :o5, 309960000
            tz.transition 1980, 4, :o6, 325688400
            tz.transition 1980, 10, :o5, 341409600
            tz.transition 1981, 4, :o6, 357138000
            tz.transition 1981, 10, :o5, 372859200
            tz.transition 1982, 4, :o6, 388587600
            tz.transition 1982, 10, :o5, 404913600
            tz.transition 1983, 4, :o6, 420037200
            tz.transition 1983, 10, :o7, 436363200
            tz.transition 1983, 11, :o8, 439034400
            tz.transition 1984, 4, :o9, 452088000
            tz.transition 1984, 10, :o8, 467809200
            tz.transition 1985, 4, :o9, 483537600
            tz.transition 1985, 10, :o8, 499258800
            tz.transition 1986, 4, :o9, 514987200
            tz.transition 1986, 10, :o8, 530708400
            tz.transition 1987, 4, :o9, 544622400
            tz.transition 1987, 10, :o8, 562158000
            tz.transition 1988, 4, :o9, 576072000
            tz.transition 1988, 10, :o8, 594212400
            tz.transition 1989, 4, :o9, 607521600
            tz.transition 1989, 10, :o8, 625662000
            tz.transition 1990, 4, :o9, 638971200
            tz.transition 1990, 10, :o8, 657111600
            tz.transition 1991, 4, :o9, 671025600
            tz.transition 1991, 10, :o8, 688561200
            tz.transition 1992, 4, :o9, 702475200
            tz.transition 1992, 10, :o8, 720010800
            tz.transition 1993, 4, :o9, 733924800
            tz.transition 1993, 10, :o8, 752065200
            tz.transition 1994, 4, :o9, 765374400
            tz.transition 1994, 10, :o8, 783514800
            tz.transition 1995, 4, :o9, 796824000
            tz.transition 1995, 10, :o8, 814964400
            tz.transition 1996, 4, :o9, 828878400
            tz.transition 1996, 10, :o8, 846414000
            tz.transition 1997, 4, :o9, 860328000
            tz.transition 1997, 10, :o8, 877863600
            tz.transition 1998, 4, :o9, 891777600
            tz.transition 1998, 10, :o8, 909313200
            tz.transition 1999, 4, :o9, 923227200
            tz.transition 1999, 10, :o8, 941367600
            tz.transition 2000, 4, :o9, 954676800
            tz.transition 2000, 10, :o8, 972817200
            tz.transition 2001, 4, :o9, 986126400
            tz.transition 2001, 10, :o8, 1004266800
            tz.transition 2002, 4, :o9, 1018180800
            tz.transition 2002, 10, :o8, 1035716400
            tz.transition 2003, 4, :o9, 1049630400
            tz.transition 2003, 10, :o8, 1067166000
            tz.transition 2004, 4, :o9, 1081080000
            tz.transition 2004, 10, :o8, 1099220400
            tz.transition 2005, 4, :o9, 1112529600
            tz.transition 2005, 10, :o8, 1130670000
            tz.transition 2006, 4, :o9, 1143979200
            tz.transition 2006, 10, :o8, 1162119600
            tz.transition 2007, 3, :o9, 1173614400
            tz.transition 2007, 11, :o8, 1194174000
            tz.transition 2008, 3, :o9, 1205064000
            tz.transition 2008, 11, :o8, 1225623600
            tz.transition 2009, 3, :o9, 1236513600
            tz.transition 2009, 11, :o8, 1257073200
            tz.transition 2010, 3, :o9, 1268568000
            tz.transition 2010, 11, :o8, 1289127600
            tz.transition 2011, 3, :o9, 1300017600
            tz.transition 2011, 11, :o8, 1320577200
            tz.transition 2012, 3, :o9, 1331467200
            tz.transition 2012, 11, :o8, 1352026800
            tz.transition 2013, 3, :o9, 1362916800
            tz.transition 2013, 11, :o8, 1383476400
            tz.transition 2014, 3, :o9, 1394366400
            tz.transition 2014, 11, :o8, 1414926000
            tz.transition 2015, 3, :o9, 1425816000
            tz.transition 2015, 11, :o8, 1446375600
            tz.transition 2016, 3, :o9, 1457870400
            tz.transition 2016, 11, :o8, 1478430000
            tz.transition 2017, 3, :o9, 1489320000
            tz.transition 2017, 11, :o8, 1509879600
            tz.transition 2018, 3, :o9, 1520769600
            tz.transition 2018, 11, :o8, 1541329200
            tz.transition 2019, 3, :o9, 1552219200
            tz.transition 2019, 11, :o8, 1572778800
            tz.transition 2020, 3, :o9, 1583668800
            tz.transition 2020, 11, :o8, 1604228400
            tz.transition 2021, 3, :o9, 1615723200
            tz.transition 2021, 11, :o8, 1636282800
            tz.transition 2022, 3, :o9, 1647172800
            tz.transition 2022, 11, :o8, 1667732400
            tz.transition 2023, 3, :o9, 1678622400
            tz.transition 2023, 11, :o8, 1699182000
            tz.transition 2024, 3, :o9, 1710072000
            tz.transition 2024, 11, :o8, 1730631600
            tz.transition 2025, 3, :o9, 1741521600
            tz.transition 2025, 11, :o8, 1762081200
            tz.transition 2026, 3, :o9, 1772971200
            tz.transition 2026, 11, :o8, 1793530800
            tz.transition 2027, 3, :o9, 1805025600
            tz.transition 2027, 11, :o8, 1825585200
            tz.transition 2028, 3, :o9, 1836475200
            tz.transition 2028, 11, :o8, 1857034800
            tz.transition 2029, 3, :o9, 1867924800
            tz.transition 2029, 11, :o8, 1888484400
            tz.transition 2030, 3, :o9, 1899374400
            tz.transition 2030, 11, :o8, 1919934000
            tz.transition 2031, 3, :o9, 1930824000
            tz.transition 2031, 11, :o8, 1951383600
            tz.transition 2032, 3, :o9, 1962878400
            tz.transition 2032, 11, :o8, 1983438000
            tz.transition 2033, 3, :o9, 1994328000
            tz.transition 2033, 11, :o8, 2014887600
            tz.transition 2034, 3, :o9, 2025777600
            tz.transition 2034, 11, :o8, 2046337200
            tz.transition 2035, 3, :o9, 2057227200
            tz.transition 2035, 11, :o8, 2077786800
            tz.transition 2036, 3, :o9, 2088676800
            tz.transition 2036, 11, :o8, 2109236400
            tz.transition 2037, 3, :o9, 2120126400
            tz.transition 2037, 11, :o8, 2140686000
            tz.transition 2038, 3, :o9, 2152180800, 2465497, 1
            tz.transition 2038, 11, :o8, 2172740400, 59177639, 24
            tz.transition 2039, 3, :o9, 2183630400, 2465861, 1
            tz.transition 2039, 11, :o8, 2204190000, 59186375, 24
            tz.transition 2040, 3, :o9, 2215080000, 2466225, 1
            tz.transition 2040, 11, :o8, 2235639600, 59195111, 24
            tz.transition 2041, 3, :o9, 2246529600, 2466589, 1
            tz.transition 2041, 11, :o8, 2267089200, 59203847, 24
            tz.transition 2042, 3, :o9, 2277979200, 2466953, 1
            tz.transition 2042, 11, :o8, 2298538800, 59212583, 24
            tz.transition 2043, 3, :o9, 2309428800, 2467317, 1
            tz.transition 2043, 11, :o8, 2329988400, 59221319, 24
            tz.transition 2044, 3, :o9, 2341483200, 2467688, 1
            tz.transition 2044, 11, :o8, 2362042800, 59230223, 24
            tz.transition 2045, 3, :o9, 2372932800, 2468052, 1
            tz.transition 2045, 11, :o8, 2393492400, 59238959, 24
            tz.transition 2046, 3, :o9, 2404382400, 2468416, 1
            tz.transition 2046, 11, :o8, 2424942000, 59247695, 24
            tz.transition 2047, 3, :o9, 2435832000, 2468780, 1
            tz.transition 2047, 11, :o8, 2456391600, 59256431, 24
            tz.transition 2048, 3, :o9, 2467281600, 2469144, 1
            tz.transition 2048, 11, :o8, 2487841200, 59265167, 24
            tz.transition 2049, 3, :o9, 2499336000, 2469515, 1
            tz.transition 2049, 11, :o8, 2519895600, 59274071, 24
            tz.transition 2050, 3, :o9, 2530785600, 2469879, 1
            tz.transition 2050, 11, :o8, 2551345200, 59282807, 24
            tz.transition 2051, 3, :o9, 2562235200, 2470243, 1
            tz.transition 2051, 11, :o8, 2582794800, 59291543, 24
            tz.transition 2052, 3, :o9, 2593684800, 2470607, 1
            tz.transition 2052, 11, :o8, 2614244400, 59300279, 24
            tz.transition 2053, 3, :o9, 2625134400, 2470971, 1
            tz.transition 2053, 11, :o8, 2645694000, 59309015, 24
            tz.transition 2054, 3, :o9, 2656584000, 2471335, 1
            tz.transition 2054, 11, :o8, 2677143600, 59317751, 24
            tz.transition 2055, 3, :o9, 2688638400, 2471706, 1
            tz.transition 2055, 11, :o8, 2709198000, 59326655, 24
            tz.transition 2056, 3, :o9, 2720088000, 2472070, 1
            tz.transition 2056, 11, :o8, 2740647600, 59335391, 24
            tz.transition 2057, 3, :o9, 2751537600, 2472434, 1
            tz.transition 2057, 11, :o8, 2772097200, 59344127, 24
            tz.transition 2058, 3, :o9, 2782987200, 2472798, 1
            tz.transition 2058, 11, :o8, 2803546800, 59352863, 24
            tz.transition 2059, 3, :o9, 2814436800, 2473162, 1
            tz.transition 2059, 11, :o8, 2834996400, 59361599, 24
            tz.transition 2060, 3, :o9, 2846491200, 2473533, 1
            tz.transition 2060, 11, :o8, 2867050800, 59370503, 24
            tz.transition 2061, 3, :o9, 2877940800, 2473897, 1
            tz.transition 2061, 11, :o8, 2898500400, 59379239, 24
            tz.transition 2062, 3, :o9, 2909390400, 2474261, 1
            tz.transition 2062, 11, :o8, 2929950000, 59387975, 24
            tz.transition 2063, 3, :o9, 2940840000, 2474625, 1
            tz.transition 2063, 11, :o8, 2961399600, 59396711, 24
            tz.transition 2064, 3, :o9, 2972289600, 2474989, 1
            tz.transition 2064, 11, :o8, 2992849200, 59405447, 24
            tz.transition 2065, 3, :o9, 3003739200, 2475353, 1
            tz.transition 2065, 11, :o8, 3024298800, 59414183, 24
            tz.transition 2066, 3, :o9, 3035793600, 2475724, 1
            tz.transition 2066, 11, :o8, 3056353200, 59423087, 24
            tz.transition 2067, 3, :o9, 3067243200, 2476088, 1
            tz.transition 2067, 11, :o8, 3087802800, 59431823, 24
            tz.transition 2068, 3, :o9, 3098692800, 2476452, 1
            tz.transition 2068, 11, :o8, 3119252400, 59440559, 24
          end
        end
      end
    end
  end
end
