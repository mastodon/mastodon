# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Fiji
          include TimezoneDefinition
          
          timezone 'Pacific/Fiji' do |tz|
            tz.offset :o0, 42944, 0, :LMT
            tz.offset :o1, 43200, 0, :'+12'
            tz.offset :o2, 43200, 3600, :'+13'
            
            tz.transition 1915, 10, :o1, -1709985344, 1634037302, 675
            tz.transition 1998, 10, :o2, 909842400
            tz.transition 1999, 2, :o1, 920124000
            tz.transition 1999, 11, :o2, 941896800
            tz.transition 2000, 2, :o1, 951573600
            tz.transition 2009, 11, :o2, 1259416800
            tz.transition 2010, 3, :o1, 1269698400
            tz.transition 2010, 10, :o2, 1287842400
            tz.transition 2011, 3, :o1, 1299333600
            tz.transition 2011, 10, :o2, 1319292000
            tz.transition 2012, 1, :o1, 1327154400
            tz.transition 2012, 10, :o2, 1350741600
            tz.transition 2013, 1, :o1, 1358604000
            tz.transition 2013, 10, :o2, 1382796000
            tz.transition 2014, 1, :o1, 1390050000
            tz.transition 2014, 11, :o2, 1414850400
            tz.transition 2015, 1, :o1, 1421503200
            tz.transition 2015, 10, :o2, 1446300000
            tz.transition 2016, 1, :o1, 1452952800
            tz.transition 2016, 11, :o2, 1478354400
            tz.transition 2017, 1, :o1, 1484402400
            tz.transition 2017, 11, :o2, 1509804000
            tz.transition 2018, 1, :o1, 1515852000
            tz.transition 2018, 11, :o2, 1541253600
            tz.transition 2019, 1, :o1, 1547906400
            tz.transition 2019, 11, :o2, 1572703200
            tz.transition 2020, 1, :o1, 1579356000
            tz.transition 2020, 10, :o2, 1604152800
            tz.transition 2021, 1, :o1, 1610805600
            tz.transition 2021, 11, :o2, 1636207200
            tz.transition 2022, 1, :o1, 1642255200
            tz.transition 2022, 11, :o2, 1667656800
            tz.transition 2023, 1, :o1, 1673704800
            tz.transition 2023, 11, :o2, 1699106400
            tz.transition 2024, 1, :o1, 1705154400
            tz.transition 2024, 11, :o2, 1730556000
            tz.transition 2025, 1, :o1, 1737208800
            tz.transition 2025, 11, :o2, 1762005600
            tz.transition 2026, 1, :o1, 1768658400
            tz.transition 2026, 10, :o2, 1793455200
            tz.transition 2027, 1, :o1, 1800108000
            tz.transition 2027, 11, :o2, 1825509600
            tz.transition 2028, 1, :o1, 1831557600
            tz.transition 2028, 11, :o2, 1856959200
            tz.transition 2029, 1, :o1, 1863007200
            tz.transition 2029, 11, :o2, 1888408800
            tz.transition 2030, 1, :o1, 1895061600
            tz.transition 2030, 11, :o2, 1919858400
            tz.transition 2031, 1, :o1, 1926511200
            tz.transition 2031, 11, :o2, 1951308000
            tz.transition 2032, 1, :o1, 1957960800
            tz.transition 2032, 11, :o2, 1983362400
            tz.transition 2033, 1, :o1, 1989410400
            tz.transition 2033, 11, :o2, 2014812000
            tz.transition 2034, 1, :o1, 2020860000
            tz.transition 2034, 11, :o2, 2046261600
            tz.transition 2035, 1, :o1, 2052309600
            tz.transition 2035, 11, :o2, 2077711200
            tz.transition 2036, 1, :o1, 2084364000
            tz.transition 2036, 11, :o2, 2109160800
            tz.transition 2037, 1, :o1, 2115813600
            tz.transition 2037, 10, :o2, 2140610400
            tz.transition 2038, 1, :o1, 2147263200
            tz.transition 2038, 11, :o2, 2172664800, 29588809, 12
            tz.transition 2039, 1, :o1, 2178712800, 29589649, 12
            tz.transition 2039, 11, :o2, 2204114400, 29593177, 12
            tz.transition 2040, 1, :o1, 2210162400, 29594017, 12
            tz.transition 2040, 11, :o2, 2235564000, 29597545, 12
            tz.transition 2041, 1, :o1, 2242216800, 29598469, 12
            tz.transition 2041, 11, :o2, 2267013600, 29601913, 12
            tz.transition 2042, 1, :o1, 2273666400, 29602837, 12
            tz.transition 2042, 11, :o2, 2298463200, 29606281, 12
            tz.transition 2043, 1, :o1, 2305116000, 29607205, 12
            tz.transition 2043, 10, :o2, 2329912800, 29610649, 12
            tz.transition 2044, 1, :o1, 2336565600, 29611573, 12
            tz.transition 2044, 11, :o2, 2361967200, 29615101, 12
            tz.transition 2045, 1, :o1, 2368015200, 29615941, 12
            tz.transition 2045, 11, :o2, 2393416800, 29619469, 12
            tz.transition 2046, 1, :o1, 2399464800, 29620309, 12
            tz.transition 2046, 11, :o2, 2424866400, 29623837, 12
            tz.transition 2047, 1, :o1, 2431519200, 29624761, 12
            tz.transition 2047, 11, :o2, 2456316000, 29628205, 12
            tz.transition 2048, 1, :o1, 2462968800, 29629129, 12
            tz.transition 2048, 10, :o2, 2487765600, 29632573, 12
            tz.transition 2049, 1, :o1, 2494418400, 29633497, 12
            tz.transition 2049, 11, :o2, 2519820000, 29637025, 12
            tz.transition 2050, 1, :o1, 2525868000, 29637865, 12
            tz.transition 2050, 11, :o2, 2551269600, 29641393, 12
            tz.transition 2051, 1, :o1, 2557317600, 29642233, 12
            tz.transition 2051, 11, :o2, 2582719200, 29645761, 12
            tz.transition 2052, 1, :o1, 2588767200, 29646601, 12
            tz.transition 2052, 11, :o2, 2614168800, 29650129, 12
            tz.transition 2053, 1, :o1, 2620821600, 29651053, 12
            tz.transition 2053, 11, :o2, 2645618400, 29654497, 12
            tz.transition 2054, 1, :o1, 2652271200, 29655421, 12
            tz.transition 2054, 10, :o2, 2677068000, 29658865, 12
            tz.transition 2055, 1, :o1, 2683720800, 29659789, 12
            tz.transition 2055, 11, :o2, 2709122400, 29663317, 12
            tz.transition 2056, 1, :o1, 2715170400, 29664157, 12
            tz.transition 2056, 11, :o2, 2740572000, 29667685, 12
            tz.transition 2057, 1, :o1, 2746620000, 29668525, 12
            tz.transition 2057, 11, :o2, 2772021600, 29672053, 12
            tz.transition 2058, 1, :o1, 2778674400, 29672977, 12
            tz.transition 2058, 11, :o2, 2803471200, 29676421, 12
            tz.transition 2059, 1, :o1, 2810124000, 29677345, 12
            tz.transition 2059, 11, :o2, 2834920800, 29680789, 12
            tz.transition 2060, 1, :o1, 2841573600, 29681713, 12
            tz.transition 2060, 11, :o2, 2866975200, 29685241, 12
            tz.transition 2061, 1, :o1, 2873023200, 29686081, 12
            tz.transition 2061, 11, :o2, 2898424800, 29689609, 12
            tz.transition 2062, 1, :o1, 2904472800, 29690449, 12
            tz.transition 2062, 11, :o2, 2929874400, 29693977, 12
            tz.transition 2063, 1, :o1, 2935922400, 29694817, 12
            tz.transition 2063, 11, :o2, 2961324000, 29698345, 12
            tz.transition 2064, 1, :o1, 2967976800, 29699269, 12
            tz.transition 2064, 11, :o2, 2992773600, 29702713, 12
            tz.transition 2065, 1, :o1, 2999426400, 29703637, 12
            tz.transition 2065, 10, :o2, 3024223200, 29707081, 12
            tz.transition 2066, 1, :o1, 3030876000, 29708005, 12
            tz.transition 2066, 11, :o2, 3056277600, 29711533, 12
            tz.transition 2067, 1, :o1, 3062325600, 29712373, 12
            tz.transition 2067, 11, :o2, 3087727200, 29715901, 12
            tz.transition 2068, 1, :o1, 3093775200, 29716741, 12
          end
        end
      end
    end
  end
end
