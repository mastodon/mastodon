# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Mazatlan
          include TimezoneDefinition
          
          timezone 'America/Mazatlan' do |tz|
            tz.offset :o0, -25540, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -21600, 0, :CST
            tz.offset :o3, -28800, 0, :PST
            tz.offset :o4, -25200, 3600, :MDT
            
            tz.transition 1922, 1, :o1, -1514739600, 58153339, 24
            tz.transition 1927, 6, :o2, -1343066400, 9700171, 4
            tz.transition 1930, 11, :o1, -1234807200, 9705183, 4
            tz.transition 1931, 5, :o2, -1220292000, 9705855, 4
            tz.transition 1931, 10, :o1, -1207159200, 9706463, 4
            tz.transition 1932, 4, :o2, -1191344400, 58243171, 24
            tz.transition 1942, 4, :o1, -873828000, 9721895, 4
            tz.transition 1949, 1, :o3, -661539600, 58390339, 24
            tz.transition 1970, 1, :o1, 28800
            tz.transition 1996, 4, :o4, 828867600
            tz.transition 1996, 10, :o1, 846403200
            tz.transition 1997, 4, :o4, 860317200
            tz.transition 1997, 10, :o1, 877852800
            tz.transition 1998, 4, :o4, 891766800
            tz.transition 1998, 10, :o1, 909302400
            tz.transition 1999, 4, :o4, 923216400
            tz.transition 1999, 10, :o1, 941356800
            tz.transition 2000, 4, :o4, 954666000
            tz.transition 2000, 10, :o1, 972806400
            tz.transition 2001, 5, :o4, 989139600
            tz.transition 2001, 9, :o1, 1001836800
            tz.transition 2002, 4, :o4, 1018170000
            tz.transition 2002, 10, :o1, 1035705600
            tz.transition 2003, 4, :o4, 1049619600
            tz.transition 2003, 10, :o1, 1067155200
            tz.transition 2004, 4, :o4, 1081069200
            tz.transition 2004, 10, :o1, 1099209600
            tz.transition 2005, 4, :o4, 1112518800
            tz.transition 2005, 10, :o1, 1130659200
            tz.transition 2006, 4, :o4, 1143968400
            tz.transition 2006, 10, :o1, 1162108800
            tz.transition 2007, 4, :o4, 1175418000
            tz.transition 2007, 10, :o1, 1193558400
            tz.transition 2008, 4, :o4, 1207472400
            tz.transition 2008, 10, :o1, 1225008000
            tz.transition 2009, 4, :o4, 1238922000
            tz.transition 2009, 10, :o1, 1256457600
            tz.transition 2010, 4, :o4, 1270371600
            tz.transition 2010, 10, :o1, 1288512000
            tz.transition 2011, 4, :o4, 1301821200
            tz.transition 2011, 10, :o1, 1319961600
            tz.transition 2012, 4, :o4, 1333270800
            tz.transition 2012, 10, :o1, 1351411200
            tz.transition 2013, 4, :o4, 1365325200
            tz.transition 2013, 10, :o1, 1382860800
            tz.transition 2014, 4, :o4, 1396774800
            tz.transition 2014, 10, :o1, 1414310400
            tz.transition 2015, 4, :o4, 1428224400
            tz.transition 2015, 10, :o1, 1445760000
            tz.transition 2016, 4, :o4, 1459674000
            tz.transition 2016, 10, :o1, 1477814400
            tz.transition 2017, 4, :o4, 1491123600
            tz.transition 2017, 10, :o1, 1509264000
            tz.transition 2018, 4, :o4, 1522573200
            tz.transition 2018, 10, :o1, 1540713600
            tz.transition 2019, 4, :o4, 1554627600
            tz.transition 2019, 10, :o1, 1572163200
            tz.transition 2020, 4, :o4, 1586077200
            tz.transition 2020, 10, :o1, 1603612800
            tz.transition 2021, 4, :o4, 1617526800
            tz.transition 2021, 10, :o1, 1635667200
            tz.transition 2022, 4, :o4, 1648976400
            tz.transition 2022, 10, :o1, 1667116800
            tz.transition 2023, 4, :o4, 1680426000
            tz.transition 2023, 10, :o1, 1698566400
            tz.transition 2024, 4, :o4, 1712480400
            tz.transition 2024, 10, :o1, 1730016000
            tz.transition 2025, 4, :o4, 1743930000
            tz.transition 2025, 10, :o1, 1761465600
            tz.transition 2026, 4, :o4, 1775379600
            tz.transition 2026, 10, :o1, 1792915200
            tz.transition 2027, 4, :o4, 1806829200
            tz.transition 2027, 10, :o1, 1824969600
            tz.transition 2028, 4, :o4, 1838278800
            tz.transition 2028, 10, :o1, 1856419200
            tz.transition 2029, 4, :o4, 1869728400
            tz.transition 2029, 10, :o1, 1887868800
            tz.transition 2030, 4, :o4, 1901782800
            tz.transition 2030, 10, :o1, 1919318400
            tz.transition 2031, 4, :o4, 1933232400
            tz.transition 2031, 10, :o1, 1950768000
            tz.transition 2032, 4, :o4, 1964682000
            tz.transition 2032, 10, :o1, 1982822400
            tz.transition 2033, 4, :o4, 1996131600
            tz.transition 2033, 10, :o1, 2014272000
            tz.transition 2034, 4, :o4, 2027581200
            tz.transition 2034, 10, :o1, 2045721600
            tz.transition 2035, 4, :o4, 2059030800
            tz.transition 2035, 10, :o1, 2077171200
            tz.transition 2036, 4, :o4, 2091085200
            tz.transition 2036, 10, :o1, 2108620800
            tz.transition 2037, 4, :o4, 2122534800
            tz.transition 2037, 10, :o1, 2140070400
            tz.transition 2038, 4, :o4, 2153984400, 19724143, 8
            tz.transition 2038, 10, :o1, 2172124800, 14794367, 6
            tz.transition 2039, 4, :o4, 2185434000, 19727055, 8
            tz.transition 2039, 10, :o1, 2203574400, 14796551, 6
            tz.transition 2040, 4, :o4, 2216883600, 19729967, 8
            tz.transition 2040, 10, :o1, 2235024000, 14798735, 6
            tz.transition 2041, 4, :o4, 2248938000, 19732935, 8
            tz.transition 2041, 10, :o1, 2266473600, 14800919, 6
            tz.transition 2042, 4, :o4, 2280387600, 19735847, 8
            tz.transition 2042, 10, :o1, 2297923200, 14803103, 6
            tz.transition 2043, 4, :o4, 2311837200, 19738759, 8
            tz.transition 2043, 10, :o1, 2329372800, 14805287, 6
            tz.transition 2044, 4, :o4, 2343286800, 19741671, 8
            tz.transition 2044, 10, :o1, 2361427200, 14807513, 6
            tz.transition 2045, 4, :o4, 2374736400, 19744583, 8
            tz.transition 2045, 10, :o1, 2392876800, 14809697, 6
            tz.transition 2046, 4, :o4, 2406186000, 19747495, 8
            tz.transition 2046, 10, :o1, 2424326400, 14811881, 6
            tz.transition 2047, 4, :o4, 2438240400, 19750463, 8
            tz.transition 2047, 10, :o1, 2455776000, 14814065, 6
            tz.transition 2048, 4, :o4, 2469690000, 19753375, 8
            tz.transition 2048, 10, :o1, 2487225600, 14816249, 6
            tz.transition 2049, 4, :o4, 2501139600, 19756287, 8
            tz.transition 2049, 10, :o1, 2519280000, 14818475, 6
            tz.transition 2050, 4, :o4, 2532589200, 19759199, 8
            tz.transition 2050, 10, :o1, 2550729600, 14820659, 6
            tz.transition 2051, 4, :o4, 2564038800, 19762111, 8
            tz.transition 2051, 10, :o1, 2582179200, 14822843, 6
            tz.transition 2052, 4, :o4, 2596093200, 19765079, 8
            tz.transition 2052, 10, :o1, 2613628800, 14825027, 6
            tz.transition 2053, 4, :o4, 2627542800, 19767991, 8
            tz.transition 2053, 10, :o1, 2645078400, 14827211, 6
            tz.transition 2054, 4, :o4, 2658992400, 19770903, 8
            tz.transition 2054, 10, :o1, 2676528000, 14829395, 6
            tz.transition 2055, 4, :o4, 2690442000, 19773815, 8
            tz.transition 2055, 10, :o1, 2708582400, 14831621, 6
            tz.transition 2056, 4, :o4, 2721891600, 19776727, 8
            tz.transition 2056, 10, :o1, 2740032000, 14833805, 6
            tz.transition 2057, 4, :o4, 2753341200, 19779639, 8
            tz.transition 2057, 10, :o1, 2771481600, 14835989, 6
            tz.transition 2058, 4, :o4, 2785395600, 19782607, 8
            tz.transition 2058, 10, :o1, 2802931200, 14838173, 6
            tz.transition 2059, 4, :o4, 2816845200, 19785519, 8
            tz.transition 2059, 10, :o1, 2834380800, 14840357, 6
            tz.transition 2060, 4, :o4, 2848294800, 19788431, 8
            tz.transition 2060, 10, :o1, 2866435200, 14842583, 6
            tz.transition 2061, 4, :o4, 2879744400, 19791343, 8
            tz.transition 2061, 10, :o1, 2897884800, 14844767, 6
            tz.transition 2062, 4, :o4, 2911194000, 19794255, 8
            tz.transition 2062, 10, :o1, 2929334400, 14846951, 6
            tz.transition 2063, 4, :o4, 2942643600, 19797167, 8
            tz.transition 2063, 10, :o1, 2960784000, 14849135, 6
            tz.transition 2064, 4, :o4, 2974698000, 19800135, 8
            tz.transition 2064, 10, :o1, 2992233600, 14851319, 6
            tz.transition 2065, 4, :o4, 3006147600, 19803047, 8
            tz.transition 2065, 10, :o1, 3023683200, 14853503, 6
            tz.transition 2066, 4, :o4, 3037597200, 19805959, 8
            tz.transition 2066, 10, :o1, 3055737600, 14855729, 6
            tz.transition 2067, 4, :o4, 3069046800, 19808871, 8
            tz.transition 2067, 10, :o1, 3087187200, 14857913, 6
            tz.transition 2068, 4, :o4, 3100496400, 19811783, 8
            tz.transition 2068, 10, :o1, 3118636800, 14860097, 6
          end
        end
      end
    end
  end
end
