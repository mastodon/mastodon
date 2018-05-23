# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Auckland
          include TimezoneDefinition
          
          timezone 'Pacific/Auckland' do |tz|
            tz.offset :o0, 41944, 0, :LMT
            tz.offset :o1, 41400, 0, :NZMT
            tz.offset :o2, 41400, 3600, :NZST
            tz.offset :o3, 41400, 1800, :NZST
            tz.offset :o4, 43200, 0, :NZST
            tz.offset :o5, 43200, 3600, :NZDT
            
            tz.transition 1868, 11, :o1, -3192435544, 25959290557, 10800
            tz.transition 1927, 11, :o2, -1330335000, 116409125, 48
            tz.transition 1928, 3, :o1, -1320057000, 38804945, 16
            tz.transition 1928, 10, :o3, -1300699800, 116425589, 48
            tz.transition 1929, 3, :o1, -1287396000, 29108245, 12
            tz.transition 1929, 10, :o3, -1269250200, 116443061, 48
            tz.transition 1930, 3, :o1, -1255946400, 29112613, 12
            tz.transition 1930, 10, :o3, -1237800600, 116460533, 48
            tz.transition 1931, 3, :o1, -1224496800, 29116981, 12
            tz.transition 1931, 10, :o3, -1206351000, 116478005, 48
            tz.transition 1932, 3, :o1, -1192442400, 29121433, 12
            tz.transition 1932, 10, :o3, -1174901400, 116495477, 48
            tz.transition 1933, 3, :o1, -1160992800, 29125801, 12
            tz.transition 1933, 10, :o3, -1143451800, 116512949, 48
            tz.transition 1934, 4, :o1, -1125914400, 29130673, 12
            tz.transition 1934, 9, :o3, -1112607000, 116530085, 48
            tz.transition 1935, 4, :o1, -1094464800, 29135041, 12
            tz.transition 1935, 9, :o3, -1081157400, 116547557, 48
            tz.transition 1936, 4, :o1, -1063015200, 29139409, 12
            tz.transition 1936, 9, :o3, -1049707800, 116565029, 48
            tz.transition 1937, 4, :o1, -1031565600, 29143777, 12
            tz.transition 1937, 9, :o3, -1018258200, 116582501, 48
            tz.transition 1938, 4, :o1, -1000116000, 29148145, 12
            tz.transition 1938, 9, :o3, -986808600, 116599973, 48
            tz.transition 1939, 4, :o1, -968061600, 29152597, 12
            tz.transition 1939, 9, :o3, -955359000, 116617445, 48
            tz.transition 1940, 4, :o1, -936612000, 29156965, 12
            tz.transition 1940, 9, :o3, -923304600, 116635253, 48
            tz.transition 1945, 12, :o4, -757425600, 2431821, 1
            tz.transition 1974, 11, :o5, 152632800
            tz.transition 1975, 2, :o4, 162309600
            tz.transition 1975, 10, :o5, 183477600
            tz.transition 1976, 3, :o4, 194968800
            tz.transition 1976, 10, :o5, 215532000
            tz.transition 1977, 3, :o4, 226418400
            tz.transition 1977, 10, :o5, 246981600
            tz.transition 1978, 3, :o4, 257868000
            tz.transition 1978, 10, :o5, 278431200
            tz.transition 1979, 3, :o4, 289317600
            tz.transition 1979, 10, :o5, 309880800
            tz.transition 1980, 3, :o4, 320767200
            tz.transition 1980, 10, :o5, 341330400
            tz.transition 1981, 2, :o4, 352216800
            tz.transition 1981, 10, :o5, 372780000
            tz.transition 1982, 3, :o4, 384271200
            tz.transition 1982, 10, :o5, 404834400
            tz.transition 1983, 3, :o4, 415720800
            tz.transition 1983, 10, :o5, 436284000
            tz.transition 1984, 3, :o4, 447170400
            tz.transition 1984, 10, :o5, 467733600
            tz.transition 1985, 3, :o4, 478620000
            tz.transition 1985, 10, :o5, 499183200
            tz.transition 1986, 3, :o4, 510069600
            tz.transition 1986, 10, :o5, 530632800
            tz.transition 1987, 2, :o4, 541519200
            tz.transition 1987, 10, :o5, 562082400
            tz.transition 1988, 3, :o4, 573573600
            tz.transition 1988, 10, :o5, 594136800
            tz.transition 1989, 3, :o4, 605023200
            tz.transition 1989, 10, :o5, 623772000
            tz.transition 1990, 3, :o4, 637682400
            tz.transition 1990, 10, :o5, 655221600
            tz.transition 1991, 3, :o4, 669132000
            tz.transition 1991, 10, :o5, 686671200
            tz.transition 1992, 3, :o4, 700581600
            tz.transition 1992, 10, :o5, 718120800
            tz.transition 1993, 3, :o4, 732636000
            tz.transition 1993, 10, :o5, 749570400
            tz.transition 1994, 3, :o4, 764085600
            tz.transition 1994, 10, :o5, 781020000
            tz.transition 1995, 3, :o4, 795535200
            tz.transition 1995, 9, :o5, 812469600
            tz.transition 1996, 3, :o4, 826984800
            tz.transition 1996, 10, :o5, 844524000
            tz.transition 1997, 3, :o4, 858434400
            tz.transition 1997, 10, :o5, 875973600
            tz.transition 1998, 3, :o4, 889884000
            tz.transition 1998, 10, :o5, 907423200
            tz.transition 1999, 3, :o4, 921938400
            tz.transition 1999, 10, :o5, 938872800
            tz.transition 2000, 3, :o4, 953388000
            tz.transition 2000, 9, :o5, 970322400
            tz.transition 2001, 3, :o4, 984837600
            tz.transition 2001, 10, :o5, 1002376800
            tz.transition 2002, 3, :o4, 1016287200
            tz.transition 2002, 10, :o5, 1033826400
            tz.transition 2003, 3, :o4, 1047736800
            tz.transition 2003, 10, :o5, 1065276000
            tz.transition 2004, 3, :o4, 1079791200
            tz.transition 2004, 10, :o5, 1096725600
            tz.transition 2005, 3, :o4, 1111240800
            tz.transition 2005, 10, :o5, 1128175200
            tz.transition 2006, 3, :o4, 1142690400
            tz.transition 2006, 9, :o5, 1159624800
            tz.transition 2007, 3, :o4, 1174140000
            tz.transition 2007, 9, :o5, 1191074400
            tz.transition 2008, 4, :o4, 1207404000
            tz.transition 2008, 9, :o5, 1222524000
            tz.transition 2009, 4, :o4, 1238853600
            tz.transition 2009, 9, :o5, 1253973600
            tz.transition 2010, 4, :o4, 1270303200
            tz.transition 2010, 9, :o5, 1285423200
            tz.transition 2011, 4, :o4, 1301752800
            tz.transition 2011, 9, :o5, 1316872800
            tz.transition 2012, 3, :o4, 1333202400
            tz.transition 2012, 9, :o5, 1348927200
            tz.transition 2013, 4, :o4, 1365256800
            tz.transition 2013, 9, :o5, 1380376800
            tz.transition 2014, 4, :o4, 1396706400
            tz.transition 2014, 9, :o5, 1411826400
            tz.transition 2015, 4, :o4, 1428156000
            tz.transition 2015, 9, :o5, 1443276000
            tz.transition 2016, 4, :o4, 1459605600
            tz.transition 2016, 9, :o5, 1474725600
            tz.transition 2017, 4, :o4, 1491055200
            tz.transition 2017, 9, :o5, 1506175200
            tz.transition 2018, 3, :o4, 1522504800
            tz.transition 2018, 9, :o5, 1538229600
            tz.transition 2019, 4, :o4, 1554559200
            tz.transition 2019, 9, :o5, 1569679200
            tz.transition 2020, 4, :o4, 1586008800
            tz.transition 2020, 9, :o5, 1601128800
            tz.transition 2021, 4, :o4, 1617458400
            tz.transition 2021, 9, :o5, 1632578400
            tz.transition 2022, 4, :o4, 1648908000
            tz.transition 2022, 9, :o5, 1664028000
            tz.transition 2023, 4, :o4, 1680357600
            tz.transition 2023, 9, :o5, 1695477600
            tz.transition 2024, 4, :o4, 1712412000
            tz.transition 2024, 9, :o5, 1727532000
            tz.transition 2025, 4, :o4, 1743861600
            tz.transition 2025, 9, :o5, 1758981600
            tz.transition 2026, 4, :o4, 1775311200
            tz.transition 2026, 9, :o5, 1790431200
            tz.transition 2027, 4, :o4, 1806760800
            tz.transition 2027, 9, :o5, 1821880800
            tz.transition 2028, 4, :o4, 1838210400
            tz.transition 2028, 9, :o5, 1853330400
            tz.transition 2029, 3, :o4, 1869660000
            tz.transition 2029, 9, :o5, 1885384800
            tz.transition 2030, 4, :o4, 1901714400
            tz.transition 2030, 9, :o5, 1916834400
            tz.transition 2031, 4, :o4, 1933164000
            tz.transition 2031, 9, :o5, 1948284000
            tz.transition 2032, 4, :o4, 1964613600
            tz.transition 2032, 9, :o5, 1979733600
            tz.transition 2033, 4, :o4, 1996063200
            tz.transition 2033, 9, :o5, 2011183200
            tz.transition 2034, 4, :o4, 2027512800
            tz.transition 2034, 9, :o5, 2042632800
            tz.transition 2035, 3, :o4, 2058962400
            tz.transition 2035, 9, :o5, 2074687200
            tz.transition 2036, 4, :o4, 2091016800
            tz.transition 2036, 9, :o5, 2106136800
            tz.transition 2037, 4, :o4, 2122466400
            tz.transition 2037, 9, :o5, 2137586400
            tz.transition 2038, 4, :o4, 2153916000, 29586205, 12
            tz.transition 2038, 9, :o5, 2169036000, 29588305, 12
            tz.transition 2039, 4, :o4, 2185365600, 29590573, 12
            tz.transition 2039, 9, :o5, 2200485600, 29592673, 12
            tz.transition 2040, 3, :o4, 2216815200, 29594941, 12
            tz.transition 2040, 9, :o5, 2232540000, 29597125, 12
            tz.transition 2041, 4, :o4, 2248869600, 29599393, 12
            tz.transition 2041, 9, :o5, 2263989600, 29601493, 12
            tz.transition 2042, 4, :o4, 2280319200, 29603761, 12
            tz.transition 2042, 9, :o5, 2295439200, 29605861, 12
            tz.transition 2043, 4, :o4, 2311768800, 29608129, 12
            tz.transition 2043, 9, :o5, 2326888800, 29610229, 12
            tz.transition 2044, 4, :o4, 2343218400, 29612497, 12
            tz.transition 2044, 9, :o5, 2358338400, 29614597, 12
            tz.transition 2045, 4, :o4, 2374668000, 29616865, 12
            tz.transition 2045, 9, :o5, 2389788000, 29618965, 12
            tz.transition 2046, 3, :o4, 2406117600, 29621233, 12
            tz.transition 2046, 9, :o5, 2421842400, 29623417, 12
            tz.transition 2047, 4, :o4, 2438172000, 29625685, 12
            tz.transition 2047, 9, :o5, 2453292000, 29627785, 12
            tz.transition 2048, 4, :o4, 2469621600, 29630053, 12
            tz.transition 2048, 9, :o5, 2484741600, 29632153, 12
            tz.transition 2049, 4, :o4, 2501071200, 29634421, 12
            tz.transition 2049, 9, :o5, 2516191200, 29636521, 12
            tz.transition 2050, 4, :o4, 2532520800, 29638789, 12
            tz.transition 2050, 9, :o5, 2547640800, 29640889, 12
            tz.transition 2051, 4, :o4, 2563970400, 29643157, 12
            tz.transition 2051, 9, :o5, 2579090400, 29645257, 12
            tz.transition 2052, 4, :o4, 2596024800, 29647609, 12
            tz.transition 2052, 9, :o5, 2611144800, 29649709, 12
            tz.transition 2053, 4, :o4, 2627474400, 29651977, 12
            tz.transition 2053, 9, :o5, 2642594400, 29654077, 12
            tz.transition 2054, 4, :o4, 2658924000, 29656345, 12
            tz.transition 2054, 9, :o5, 2674044000, 29658445, 12
            tz.transition 2055, 4, :o4, 2690373600, 29660713, 12
            tz.transition 2055, 9, :o5, 2705493600, 29662813, 12
            tz.transition 2056, 4, :o4, 2721823200, 29665081, 12
            tz.transition 2056, 9, :o5, 2736943200, 29667181, 12
            tz.transition 2057, 3, :o4, 2753272800, 29669449, 12
            tz.transition 2057, 9, :o5, 2768997600, 29671633, 12
            tz.transition 2058, 4, :o4, 2785327200, 29673901, 12
            tz.transition 2058, 9, :o5, 2800447200, 29676001, 12
            tz.transition 2059, 4, :o4, 2816776800, 29678269, 12
            tz.transition 2059, 9, :o5, 2831896800, 29680369, 12
            tz.transition 2060, 4, :o4, 2848226400, 29682637, 12
            tz.transition 2060, 9, :o5, 2863346400, 29684737, 12
            tz.transition 2061, 4, :o4, 2879676000, 29687005, 12
            tz.transition 2061, 9, :o5, 2894796000, 29689105, 12
            tz.transition 2062, 4, :o4, 2911125600, 29691373, 12
            tz.transition 2062, 9, :o5, 2926245600, 29693473, 12
            tz.transition 2063, 3, :o4, 2942575200, 29695741, 12
            tz.transition 2063, 9, :o5, 2958300000, 29697925, 12
            tz.transition 2064, 4, :o4, 2974629600, 29700193, 12
            tz.transition 2064, 9, :o5, 2989749600, 29702293, 12
            tz.transition 2065, 4, :o4, 3006079200, 29704561, 12
            tz.transition 2065, 9, :o5, 3021199200, 29706661, 12
            tz.transition 2066, 4, :o4, 3037528800, 29708929, 12
            tz.transition 2066, 9, :o5, 3052648800, 29711029, 12
            tz.transition 2067, 4, :o4, 3068978400, 29713297, 12
            tz.transition 2067, 9, :o5, 3084098400, 29715397, 12
            tz.transition 2068, 3, :o4, 3100428000, 29717665, 12
          end
        end
      end
    end
  end
end
