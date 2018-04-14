# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Inuvik
          include TimezoneDefinition
          
          timezone 'America/Inuvik' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, -28800, 0, :PST
            tz.offset :o2, -28800, 7200, :PDDT
            tz.offset :o3, -25200, 0, :MST
            tz.offset :o4, -25200, 3600, :MDT
            
            tz.transition 1953, 1, :o1, -536457600, 4868757, 2
            tz.transition 1965, 4, :o2, -147888000, 14633255, 6
            tz.transition 1965, 10, :o1, -131558400, 14634389, 6
            tz.transition 1979, 4, :o3, 294228000
            tz.transition 1980, 4, :o4, 325674000
            tz.transition 1980, 10, :o3, 341395200
            tz.transition 1981, 4, :o4, 357123600
            tz.transition 1981, 10, :o3, 372844800
            tz.transition 1982, 4, :o4, 388573200
            tz.transition 1982, 10, :o3, 404899200
            tz.transition 1983, 4, :o4, 420022800
            tz.transition 1983, 10, :o3, 436348800
            tz.transition 1984, 4, :o4, 452077200
            tz.transition 1984, 10, :o3, 467798400
            tz.transition 1985, 4, :o4, 483526800
            tz.transition 1985, 10, :o3, 499248000
            tz.transition 1986, 4, :o4, 514976400
            tz.transition 1986, 10, :o3, 530697600
            tz.transition 1987, 4, :o4, 544611600
            tz.transition 1987, 10, :o3, 562147200
            tz.transition 1988, 4, :o4, 576061200
            tz.transition 1988, 10, :o3, 594201600
            tz.transition 1989, 4, :o4, 607510800
            tz.transition 1989, 10, :o3, 625651200
            tz.transition 1990, 4, :o4, 638960400
            tz.transition 1990, 10, :o3, 657100800
            tz.transition 1991, 4, :o4, 671014800
            tz.transition 1991, 10, :o3, 688550400
            tz.transition 1992, 4, :o4, 702464400
            tz.transition 1992, 10, :o3, 720000000
            tz.transition 1993, 4, :o4, 733914000
            tz.transition 1993, 10, :o3, 752054400
            tz.transition 1994, 4, :o4, 765363600
            tz.transition 1994, 10, :o3, 783504000
            tz.transition 1995, 4, :o4, 796813200
            tz.transition 1995, 10, :o3, 814953600
            tz.transition 1996, 4, :o4, 828867600
            tz.transition 1996, 10, :o3, 846403200
            tz.transition 1997, 4, :o4, 860317200
            tz.transition 1997, 10, :o3, 877852800
            tz.transition 1998, 4, :o4, 891766800
            tz.transition 1998, 10, :o3, 909302400
            tz.transition 1999, 4, :o4, 923216400
            tz.transition 1999, 10, :o3, 941356800
            tz.transition 2000, 4, :o4, 954666000
            tz.transition 2000, 10, :o3, 972806400
            tz.transition 2001, 4, :o4, 986115600
            tz.transition 2001, 10, :o3, 1004256000
            tz.transition 2002, 4, :o4, 1018170000
            tz.transition 2002, 10, :o3, 1035705600
            tz.transition 2003, 4, :o4, 1049619600
            tz.transition 2003, 10, :o3, 1067155200
            tz.transition 2004, 4, :o4, 1081069200
            tz.transition 2004, 10, :o3, 1099209600
            tz.transition 2005, 4, :o4, 1112518800
            tz.transition 2005, 10, :o3, 1130659200
            tz.transition 2006, 4, :o4, 1143968400
            tz.transition 2006, 10, :o3, 1162108800
            tz.transition 2007, 3, :o4, 1173603600
            tz.transition 2007, 11, :o3, 1194163200
            tz.transition 2008, 3, :o4, 1205053200
            tz.transition 2008, 11, :o3, 1225612800
            tz.transition 2009, 3, :o4, 1236502800
            tz.transition 2009, 11, :o3, 1257062400
            tz.transition 2010, 3, :o4, 1268557200
            tz.transition 2010, 11, :o3, 1289116800
            tz.transition 2011, 3, :o4, 1300006800
            tz.transition 2011, 11, :o3, 1320566400
            tz.transition 2012, 3, :o4, 1331456400
            tz.transition 2012, 11, :o3, 1352016000
            tz.transition 2013, 3, :o4, 1362906000
            tz.transition 2013, 11, :o3, 1383465600
            tz.transition 2014, 3, :o4, 1394355600
            tz.transition 2014, 11, :o3, 1414915200
            tz.transition 2015, 3, :o4, 1425805200
            tz.transition 2015, 11, :o3, 1446364800
            tz.transition 2016, 3, :o4, 1457859600
            tz.transition 2016, 11, :o3, 1478419200
            tz.transition 2017, 3, :o4, 1489309200
            tz.transition 2017, 11, :o3, 1509868800
            tz.transition 2018, 3, :o4, 1520758800
            tz.transition 2018, 11, :o3, 1541318400
            tz.transition 2019, 3, :o4, 1552208400
            tz.transition 2019, 11, :o3, 1572768000
            tz.transition 2020, 3, :o4, 1583658000
            tz.transition 2020, 11, :o3, 1604217600
            tz.transition 2021, 3, :o4, 1615712400
            tz.transition 2021, 11, :o3, 1636272000
            tz.transition 2022, 3, :o4, 1647162000
            tz.transition 2022, 11, :o3, 1667721600
            tz.transition 2023, 3, :o4, 1678611600
            tz.transition 2023, 11, :o3, 1699171200
            tz.transition 2024, 3, :o4, 1710061200
            tz.transition 2024, 11, :o3, 1730620800
            tz.transition 2025, 3, :o4, 1741510800
            tz.transition 2025, 11, :o3, 1762070400
            tz.transition 2026, 3, :o4, 1772960400
            tz.transition 2026, 11, :o3, 1793520000
            tz.transition 2027, 3, :o4, 1805014800
            tz.transition 2027, 11, :o3, 1825574400
            tz.transition 2028, 3, :o4, 1836464400
            tz.transition 2028, 11, :o3, 1857024000
            tz.transition 2029, 3, :o4, 1867914000
            tz.transition 2029, 11, :o3, 1888473600
            tz.transition 2030, 3, :o4, 1899363600
            tz.transition 2030, 11, :o3, 1919923200
            tz.transition 2031, 3, :o4, 1930813200
            tz.transition 2031, 11, :o3, 1951372800
            tz.transition 2032, 3, :o4, 1962867600
            tz.transition 2032, 11, :o3, 1983427200
            tz.transition 2033, 3, :o4, 1994317200
            tz.transition 2033, 11, :o3, 2014876800
            tz.transition 2034, 3, :o4, 2025766800
            tz.transition 2034, 11, :o3, 2046326400
            tz.transition 2035, 3, :o4, 2057216400
            tz.transition 2035, 11, :o3, 2077776000
            tz.transition 2036, 3, :o4, 2088666000
            tz.transition 2036, 11, :o3, 2109225600
            tz.transition 2037, 3, :o4, 2120115600
            tz.transition 2037, 11, :o3, 2140675200
            tz.transition 2038, 3, :o4, 2152170000, 19723975, 8
            tz.transition 2038, 11, :o3, 2172729600, 14794409, 6
            tz.transition 2039, 3, :o4, 2183619600, 19726887, 8
            tz.transition 2039, 11, :o3, 2204179200, 14796593, 6
            tz.transition 2040, 3, :o4, 2215069200, 19729799, 8
            tz.transition 2040, 11, :o3, 2235628800, 14798777, 6
            tz.transition 2041, 3, :o4, 2246518800, 19732711, 8
            tz.transition 2041, 11, :o3, 2267078400, 14800961, 6
            tz.transition 2042, 3, :o4, 2277968400, 19735623, 8
            tz.transition 2042, 11, :o3, 2298528000, 14803145, 6
            tz.transition 2043, 3, :o4, 2309418000, 19738535, 8
            tz.transition 2043, 11, :o3, 2329977600, 14805329, 6
            tz.transition 2044, 3, :o4, 2341472400, 19741503, 8
            tz.transition 2044, 11, :o3, 2362032000, 14807555, 6
            tz.transition 2045, 3, :o4, 2372922000, 19744415, 8
            tz.transition 2045, 11, :o3, 2393481600, 14809739, 6
            tz.transition 2046, 3, :o4, 2404371600, 19747327, 8
            tz.transition 2046, 11, :o3, 2424931200, 14811923, 6
            tz.transition 2047, 3, :o4, 2435821200, 19750239, 8
            tz.transition 2047, 11, :o3, 2456380800, 14814107, 6
            tz.transition 2048, 3, :o4, 2467270800, 19753151, 8
            tz.transition 2048, 11, :o3, 2487830400, 14816291, 6
            tz.transition 2049, 3, :o4, 2499325200, 19756119, 8
            tz.transition 2049, 11, :o3, 2519884800, 14818517, 6
            tz.transition 2050, 3, :o4, 2530774800, 19759031, 8
            tz.transition 2050, 11, :o3, 2551334400, 14820701, 6
            tz.transition 2051, 3, :o4, 2562224400, 19761943, 8
            tz.transition 2051, 11, :o3, 2582784000, 14822885, 6
            tz.transition 2052, 3, :o4, 2593674000, 19764855, 8
            tz.transition 2052, 11, :o3, 2614233600, 14825069, 6
            tz.transition 2053, 3, :o4, 2625123600, 19767767, 8
            tz.transition 2053, 11, :o3, 2645683200, 14827253, 6
            tz.transition 2054, 3, :o4, 2656573200, 19770679, 8
            tz.transition 2054, 11, :o3, 2677132800, 14829437, 6
            tz.transition 2055, 3, :o4, 2688627600, 19773647, 8
            tz.transition 2055, 11, :o3, 2709187200, 14831663, 6
            tz.transition 2056, 3, :o4, 2720077200, 19776559, 8
            tz.transition 2056, 11, :o3, 2740636800, 14833847, 6
            tz.transition 2057, 3, :o4, 2751526800, 19779471, 8
            tz.transition 2057, 11, :o3, 2772086400, 14836031, 6
            tz.transition 2058, 3, :o4, 2782976400, 19782383, 8
            tz.transition 2058, 11, :o3, 2803536000, 14838215, 6
            tz.transition 2059, 3, :o4, 2814426000, 19785295, 8
            tz.transition 2059, 11, :o3, 2834985600, 14840399, 6
            tz.transition 2060, 3, :o4, 2846480400, 19788263, 8
            tz.transition 2060, 11, :o3, 2867040000, 14842625, 6
            tz.transition 2061, 3, :o4, 2877930000, 19791175, 8
            tz.transition 2061, 11, :o3, 2898489600, 14844809, 6
            tz.transition 2062, 3, :o4, 2909379600, 19794087, 8
            tz.transition 2062, 11, :o3, 2929939200, 14846993, 6
            tz.transition 2063, 3, :o4, 2940829200, 19796999, 8
            tz.transition 2063, 11, :o3, 2961388800, 14849177, 6
            tz.transition 2064, 3, :o4, 2972278800, 19799911, 8
            tz.transition 2064, 11, :o3, 2992838400, 14851361, 6
            tz.transition 2065, 3, :o4, 3003728400, 19802823, 8
            tz.transition 2065, 11, :o3, 3024288000, 14853545, 6
            tz.transition 2066, 3, :o4, 3035782800, 19805791, 8
            tz.transition 2066, 11, :o3, 3056342400, 14855771, 6
            tz.transition 2067, 3, :o4, 3067232400, 19808703, 8
            tz.transition 2067, 11, :o3, 3087792000, 14857955, 6
            tz.transition 2068, 3, :o4, 3098682000, 19811615, 8
            tz.transition 2068, 11, :o3, 3119241600, 14860139, 6
          end
        end
      end
    end
  end
end
