# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Apia
          include TimezoneDefinition
          
          timezone 'Pacific/Apia' do |tz|
            tz.offset :o0, 45184, 0, :LMT
            tz.offset :o1, -41216, 0, :LMT
            tz.offset :o2, -41400, 0, :'-1130'
            tz.offset :o3, -39600, 0, :'-11'
            tz.offset :o4, -39600, 3600, :'-10'
            tz.offset :o5, 46800, 3600, :'+14'
            tz.offset :o6, 46800, 0, :'+13'
            
            tz.transition 1892, 7, :o1, -2445424384, 3256583369, 1350
            tz.transition 1911, 1, :o2, -1861878784, 3265701269, 1350
            tz.transition 1950, 1, :o3, -631110600, 116797583, 48
            tz.transition 2010, 9, :o4, 1285498800
            tz.transition 2011, 4, :o3, 1301752800
            tz.transition 2011, 9, :o4, 1316872800
            tz.transition 2011, 12, :o5, 1325239200
            tz.transition 2012, 3, :o6, 1333202400
            tz.transition 2012, 9, :o5, 1348927200
            tz.transition 2013, 4, :o6, 1365256800
            tz.transition 2013, 9, :o5, 1380376800
            tz.transition 2014, 4, :o6, 1396706400
            tz.transition 2014, 9, :o5, 1411826400
            tz.transition 2015, 4, :o6, 1428156000
            tz.transition 2015, 9, :o5, 1443276000
            tz.transition 2016, 4, :o6, 1459605600
            tz.transition 2016, 9, :o5, 1474725600
            tz.transition 2017, 4, :o6, 1491055200
            tz.transition 2017, 9, :o5, 1506175200
            tz.transition 2018, 3, :o6, 1522504800
            tz.transition 2018, 9, :o5, 1538229600
            tz.transition 2019, 4, :o6, 1554559200
            tz.transition 2019, 9, :o5, 1569679200
            tz.transition 2020, 4, :o6, 1586008800
            tz.transition 2020, 9, :o5, 1601128800
            tz.transition 2021, 4, :o6, 1617458400
            tz.transition 2021, 9, :o5, 1632578400
            tz.transition 2022, 4, :o6, 1648908000
            tz.transition 2022, 9, :o5, 1664028000
            tz.transition 2023, 4, :o6, 1680357600
            tz.transition 2023, 9, :o5, 1695477600
            tz.transition 2024, 4, :o6, 1712412000
            tz.transition 2024, 9, :o5, 1727532000
            tz.transition 2025, 4, :o6, 1743861600
            tz.transition 2025, 9, :o5, 1758981600
            tz.transition 2026, 4, :o6, 1775311200
            tz.transition 2026, 9, :o5, 1790431200
            tz.transition 2027, 4, :o6, 1806760800
            tz.transition 2027, 9, :o5, 1821880800
            tz.transition 2028, 4, :o6, 1838210400
            tz.transition 2028, 9, :o5, 1853330400
            tz.transition 2029, 3, :o6, 1869660000
            tz.transition 2029, 9, :o5, 1885384800
            tz.transition 2030, 4, :o6, 1901714400
            tz.transition 2030, 9, :o5, 1916834400
            tz.transition 2031, 4, :o6, 1933164000
            tz.transition 2031, 9, :o5, 1948284000
            tz.transition 2032, 4, :o6, 1964613600
            tz.transition 2032, 9, :o5, 1979733600
            tz.transition 2033, 4, :o6, 1996063200
            tz.transition 2033, 9, :o5, 2011183200
            tz.transition 2034, 4, :o6, 2027512800
            tz.transition 2034, 9, :o5, 2042632800
            tz.transition 2035, 3, :o6, 2058962400
            tz.transition 2035, 9, :o5, 2074687200
            tz.transition 2036, 4, :o6, 2091016800
            tz.transition 2036, 9, :o5, 2106136800
            tz.transition 2037, 4, :o6, 2122466400
            tz.transition 2037, 9, :o5, 2137586400
            tz.transition 2038, 4, :o6, 2153916000, 29586205, 12
            tz.transition 2038, 9, :o5, 2169036000, 29588305, 12
            tz.transition 2039, 4, :o6, 2185365600, 29590573, 12
            tz.transition 2039, 9, :o5, 2200485600, 29592673, 12
            tz.transition 2040, 3, :o6, 2216815200, 29594941, 12
            tz.transition 2040, 9, :o5, 2232540000, 29597125, 12
            tz.transition 2041, 4, :o6, 2248869600, 29599393, 12
            tz.transition 2041, 9, :o5, 2263989600, 29601493, 12
            tz.transition 2042, 4, :o6, 2280319200, 29603761, 12
            tz.transition 2042, 9, :o5, 2295439200, 29605861, 12
            tz.transition 2043, 4, :o6, 2311768800, 29608129, 12
            tz.transition 2043, 9, :o5, 2326888800, 29610229, 12
            tz.transition 2044, 4, :o6, 2343218400, 29612497, 12
            tz.transition 2044, 9, :o5, 2358338400, 29614597, 12
            tz.transition 2045, 4, :o6, 2374668000, 29616865, 12
            tz.transition 2045, 9, :o5, 2389788000, 29618965, 12
            tz.transition 2046, 3, :o6, 2406117600, 29621233, 12
            tz.transition 2046, 9, :o5, 2421842400, 29623417, 12
            tz.transition 2047, 4, :o6, 2438172000, 29625685, 12
            tz.transition 2047, 9, :o5, 2453292000, 29627785, 12
            tz.transition 2048, 4, :o6, 2469621600, 29630053, 12
            tz.transition 2048, 9, :o5, 2484741600, 29632153, 12
            tz.transition 2049, 4, :o6, 2501071200, 29634421, 12
            tz.transition 2049, 9, :o5, 2516191200, 29636521, 12
            tz.transition 2050, 4, :o6, 2532520800, 29638789, 12
            tz.transition 2050, 9, :o5, 2547640800, 29640889, 12
            tz.transition 2051, 4, :o6, 2563970400, 29643157, 12
            tz.transition 2051, 9, :o5, 2579090400, 29645257, 12
            tz.transition 2052, 4, :o6, 2596024800, 29647609, 12
            tz.transition 2052, 9, :o5, 2611144800, 29649709, 12
            tz.transition 2053, 4, :o6, 2627474400, 29651977, 12
            tz.transition 2053, 9, :o5, 2642594400, 29654077, 12
            tz.transition 2054, 4, :o6, 2658924000, 29656345, 12
            tz.transition 2054, 9, :o5, 2674044000, 29658445, 12
            tz.transition 2055, 4, :o6, 2690373600, 29660713, 12
            tz.transition 2055, 9, :o5, 2705493600, 29662813, 12
            tz.transition 2056, 4, :o6, 2721823200, 29665081, 12
            tz.transition 2056, 9, :o5, 2736943200, 29667181, 12
            tz.transition 2057, 3, :o6, 2753272800, 29669449, 12
            tz.transition 2057, 9, :o5, 2768997600, 29671633, 12
            tz.transition 2058, 4, :o6, 2785327200, 29673901, 12
            tz.transition 2058, 9, :o5, 2800447200, 29676001, 12
            tz.transition 2059, 4, :o6, 2816776800, 29678269, 12
            tz.transition 2059, 9, :o5, 2831896800, 29680369, 12
            tz.transition 2060, 4, :o6, 2848226400, 29682637, 12
            tz.transition 2060, 9, :o5, 2863346400, 29684737, 12
            tz.transition 2061, 4, :o6, 2879676000, 29687005, 12
            tz.transition 2061, 9, :o5, 2894796000, 29689105, 12
            tz.transition 2062, 4, :o6, 2911125600, 29691373, 12
            tz.transition 2062, 9, :o5, 2926245600, 29693473, 12
            tz.transition 2063, 3, :o6, 2942575200, 29695741, 12
            tz.transition 2063, 9, :o5, 2958300000, 29697925, 12
            tz.transition 2064, 4, :o6, 2974629600, 29700193, 12
            tz.transition 2064, 9, :o5, 2989749600, 29702293, 12
            tz.transition 2065, 4, :o6, 3006079200, 29704561, 12
            tz.transition 2065, 9, :o5, 3021199200, 29706661, 12
            tz.transition 2066, 4, :o6, 3037528800, 29708929, 12
            tz.transition 2066, 9, :o5, 3052648800, 29711029, 12
            tz.transition 2067, 4, :o6, 3068978400, 29713297, 12
            tz.transition 2067, 9, :o5, 3084098400, 29715397, 12
            tz.transition 2068, 3, :o6, 3100428000, 29717665, 12
          end
        end
      end
    end
  end
end
