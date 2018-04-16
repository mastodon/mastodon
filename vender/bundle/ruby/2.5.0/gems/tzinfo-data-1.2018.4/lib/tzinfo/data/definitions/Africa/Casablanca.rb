# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Casablanca
          include TimezoneDefinition
          
          timezone 'Africa/Casablanca' do |tz|
            tz.offset :o0, -1820, 0, :LMT
            tz.offset :o1, 0, 0, :WET
            tz.offset :o2, 0, 3600, :WEST
            tz.offset :o3, 3600, 0, :CET
            
            tz.transition 1913, 10, :o1, -1773012580, 10454687371, 4320
            tz.transition 1939, 9, :o2, -956361600, 4859037, 2
            tz.transition 1939, 11, :o1, -950490000, 58310075, 24
            tz.transition 1940, 2, :o2, -942019200, 4859369, 2
            tz.transition 1945, 11, :o1, -761187600, 58362659, 24
            tz.transition 1950, 6, :o2, -617241600, 4866887, 2
            tz.transition 1950, 10, :o1, -605149200, 58406003, 24
            tz.transition 1967, 6, :o2, -81432000, 2439645, 1
            tz.transition 1967, 9, :o1, -71110800, 58554347, 24
            tz.transition 1974, 6, :o2, 141264000
            tz.transition 1974, 8, :o1, 147222000
            tz.transition 1976, 5, :o2, 199756800
            tz.transition 1976, 7, :o1, 207702000
            tz.transition 1977, 5, :o2, 231292800
            tz.transition 1977, 9, :o1, 244249200
            tz.transition 1978, 6, :o2, 265507200
            tz.transition 1978, 8, :o1, 271033200
            tz.transition 1984, 3, :o3, 448243200
            tz.transition 1985, 12, :o1, 504918000
            tz.transition 2008, 6, :o2, 1212278400
            tz.transition 2008, 8, :o1, 1220223600
            tz.transition 2009, 6, :o2, 1243814400
            tz.transition 2009, 8, :o1, 1250809200
            tz.transition 2010, 5, :o2, 1272758400
            tz.transition 2010, 8, :o1, 1281222000
            tz.transition 2011, 4, :o2, 1301788800
            tz.transition 2011, 7, :o1, 1312066800
            tz.transition 2012, 4, :o2, 1335664800
            tz.transition 2012, 7, :o1, 1342749600
            tz.transition 2012, 8, :o2, 1345428000
            tz.transition 2012, 9, :o1, 1348970400
            tz.transition 2013, 4, :o2, 1367114400
            tz.transition 2013, 7, :o1, 1373162400
            tz.transition 2013, 8, :o2, 1376100000
            tz.transition 2013, 10, :o1, 1382839200
            tz.transition 2014, 3, :o2, 1396144800
            tz.transition 2014, 6, :o1, 1403920800
            tz.transition 2014, 8, :o2, 1406944800
            tz.transition 2014, 10, :o1, 1414288800
            tz.transition 2015, 3, :o2, 1427594400
            tz.transition 2015, 6, :o1, 1434247200
            tz.transition 2015, 7, :o2, 1437271200
            tz.transition 2015, 10, :o1, 1445738400
            tz.transition 2016, 3, :o2, 1459044000
            tz.transition 2016, 6, :o1, 1465092000
            tz.transition 2016, 7, :o2, 1468116000
            tz.transition 2016, 10, :o1, 1477792800
            tz.transition 2017, 3, :o2, 1490493600
            tz.transition 2017, 5, :o1, 1495332000
            tz.transition 2017, 7, :o2, 1498960800
            tz.transition 2017, 10, :o1, 1509242400
            tz.transition 2018, 3, :o2, 1521943200
            tz.transition 2018, 5, :o1, 1526176800
            tz.transition 2018, 6, :o2, 1529200800
            tz.transition 2018, 10, :o1, 1540692000
            tz.transition 2019, 3, :o2, 1553997600
            tz.transition 2019, 5, :o1, 1557021600
            tz.transition 2019, 6, :o2, 1560045600
            tz.transition 2019, 10, :o1, 1572141600
            tz.transition 2020, 3, :o2, 1585447200
            tz.transition 2020, 4, :o1, 1587261600
            tz.transition 2020, 5, :o2, 1590285600
            tz.transition 2020, 10, :o1, 1603591200
            tz.transition 2021, 3, :o2, 1616896800
            tz.transition 2021, 4, :o1, 1618106400
            tz.transition 2021, 5, :o2, 1621130400
            tz.transition 2021, 10, :o1, 1635645600
            tz.transition 2022, 5, :o2, 1651975200
            tz.transition 2022, 10, :o1, 1667095200
            tz.transition 2023, 4, :o2, 1682215200
            tz.transition 2023, 10, :o1, 1698544800
            tz.transition 2024, 4, :o2, 1713060000
            tz.transition 2024, 10, :o1, 1729994400
            tz.transition 2025, 4, :o2, 1743904800
            tz.transition 2025, 10, :o1, 1761444000
            tz.transition 2026, 3, :o2, 1774749600
            tz.transition 2026, 10, :o1, 1792893600
            tz.transition 2027, 3, :o2, 1806199200
            tz.transition 2027, 10, :o1, 1824948000
            tz.transition 2028, 3, :o2, 1837648800
            tz.transition 2028, 10, :o1, 1856397600
            tz.transition 2029, 3, :o2, 1869098400
            tz.transition 2029, 10, :o1, 1887847200
            tz.transition 2030, 3, :o2, 1901152800
            tz.transition 2030, 10, :o1, 1919296800
            tz.transition 2031, 3, :o2, 1932602400
            tz.transition 2031, 10, :o1, 1950746400
            tz.transition 2032, 3, :o2, 1964052000
            tz.transition 2032, 10, :o1, 1982800800
            tz.transition 2033, 3, :o2, 1995501600
            tz.transition 2033, 10, :o1, 2014250400
            tz.transition 2034, 3, :o2, 2026951200
            tz.transition 2034, 10, :o1, 2045700000
            tz.transition 2035, 3, :o2, 2058400800
            tz.transition 2035, 10, :o1, 2077149600
            tz.transition 2036, 3, :o2, 2090455200
            tz.transition 2036, 10, :o1, 2107994400
            tz.transition 2037, 3, :o2, 2121904800
            tz.transition 2037, 10, :o1, 2138234400
            tz.transition 2038, 3, :o2, 2153354400, 29586127, 12
            tz.transition 2038, 10, :o1, 2172103200, 29588731, 12
            tz.transition 2039, 3, :o2, 2184804000, 29590495, 12
            tz.transition 2039, 10, :o1, 2203552800, 29593099, 12
            tz.transition 2040, 3, :o2, 2216253600, 29594863, 12
            tz.transition 2040, 10, :o1, 2235002400, 29597467, 12
            tz.transition 2041, 3, :o2, 2248308000, 29599315, 12
            tz.transition 2041, 10, :o1, 2266452000, 29601835, 12
            tz.transition 2042, 3, :o2, 2279757600, 29603683, 12
            tz.transition 2042, 10, :o1, 2297901600, 29606203, 12
            tz.transition 2043, 3, :o2, 2311207200, 29608051, 12
            tz.transition 2043, 10, :o1, 2329351200, 29610571, 12
            tz.transition 2044, 3, :o2, 2342656800, 29612419, 12
            tz.transition 2044, 10, :o1, 2361405600, 29615023, 12
            tz.transition 2045, 3, :o2, 2374106400, 29616787, 12
            tz.transition 2045, 10, :o1, 2392855200, 29619391, 12
            tz.transition 2046, 3, :o2, 2405556000, 29621155, 12
            tz.transition 2046, 10, :o1, 2424304800, 29623759, 12
            tz.transition 2047, 3, :o2, 2437610400, 29625607, 12
            tz.transition 2047, 10, :o1, 2455754400, 29628127, 12
            tz.transition 2048, 3, :o2, 2469060000, 29629975, 12
            tz.transition 2048, 10, :o1, 2487204000, 29632495, 12
            tz.transition 2049, 3, :o2, 2500509600, 29634343, 12
            tz.transition 2049, 10, :o1, 2519258400, 29636947, 12
            tz.transition 2050, 3, :o2, 2531959200, 29638711, 12
            tz.transition 2050, 10, :o1, 2550708000, 29641315, 12
            tz.transition 2051, 3, :o2, 2563408800, 29643079, 12
            tz.transition 2051, 10, :o1, 2582157600, 29645683, 12
            tz.transition 2052, 3, :o2, 2595463200, 29647531, 12
            tz.transition 2052, 10, :o1, 2613607200, 29650051, 12
            tz.transition 2053, 3, :o2, 2626912800, 29651899, 12
            tz.transition 2053, 10, :o1, 2645056800, 29654419, 12
            tz.transition 2054, 3, :o2, 2658362400, 29656267, 12
            tz.transition 2054, 10, :o1, 2676506400, 29658787, 12
            tz.transition 2055, 3, :o2, 2689812000, 29660635, 12
            tz.transition 2055, 10, :o1, 2708560800, 29663239, 12
            tz.transition 2056, 3, :o2, 2721261600, 29665003, 12
            tz.transition 2056, 10, :o1, 2740010400, 29667607, 12
            tz.transition 2057, 3, :o2, 2752711200, 29669371, 12
            tz.transition 2057, 10, :o1, 2771460000, 29671975, 12
            tz.transition 2058, 3, :o2, 2784765600, 29673823, 12
            tz.transition 2058, 10, :o1, 2802909600, 29676343, 12
            tz.transition 2059, 3, :o2, 2816215200, 29678191, 12
            tz.transition 2059, 10, :o1, 2834359200, 29680711, 12
            tz.transition 2060, 3, :o2, 2847664800, 29682559, 12
            tz.transition 2060, 10, :o1, 2866413600, 29685163, 12
            tz.transition 2061, 3, :o2, 2879114400, 29686927, 12
            tz.transition 2061, 10, :o1, 2897863200, 29689531, 12
            tz.transition 2062, 3, :o2, 2910564000, 29691295, 12
            tz.transition 2062, 10, :o1, 2929312800, 29693899, 12
            tz.transition 2063, 3, :o2, 2942013600, 29695663, 12
            tz.transition 2063, 10, :o1, 2960762400, 29698267, 12
            tz.transition 2064, 3, :o2, 2974068000, 29700115, 12
            tz.transition 2064, 10, :o1, 2992212000, 29702635, 12
            tz.transition 2065, 3, :o2, 3005517600, 29704483, 12
            tz.transition 2065, 10, :o1, 3023661600, 29707003, 12
            tz.transition 2066, 3, :o2, 3036967200, 29708851, 12
            tz.transition 2066, 10, :o1, 3055716000, 29711455, 12
            tz.transition 2067, 3, :o2, 3068416800, 29713219, 12
            tz.transition 2067, 10, :o1, 3087165600, 29715823, 12
            tz.transition 2068, 3, :o2, 3099866400, 29717587, 12
            tz.transition 2068, 10, :o1, 3118615200, 29720191, 12
          end
        end
      end
    end
  end
end
