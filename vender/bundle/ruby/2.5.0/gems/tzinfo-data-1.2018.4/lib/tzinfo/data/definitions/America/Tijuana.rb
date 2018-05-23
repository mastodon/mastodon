# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Tijuana
          include TimezoneDefinition
          
          timezone 'America/Tijuana' do |tz|
            tz.offset :o0, -28084, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -28800, 0, :PST
            tz.offset :o3, -28800, 3600, :PDT
            tz.offset :o4, -28800, 3600, :PWT
            tz.offset :o5, -28800, 3600, :PPT
            
            tz.transition 1922, 1, :o1, -1514736000, 14538335, 6
            tz.transition 1924, 1, :o2, -1451667600, 58170859, 24
            tz.transition 1927, 6, :o1, -1343062800, 58201027, 24
            tz.transition 1930, 11, :o2, -1234803600, 58231099, 24
            tz.transition 1931, 4, :o3, -1222963200, 14558597, 6
            tz.transition 1931, 9, :o2, -1207242000, 58238755, 24
            tz.transition 1942, 4, :o4, -873820800, 14582843, 6
            tz.transition 1945, 8, :o5, -769395600, 58360379, 24
            tz.transition 1945, 11, :o2, -761677200, 58362523, 24
            tz.transition 1948, 4, :o3, -686073600, 14595881, 6
            tz.transition 1949, 1, :o2, -661539600, 58390339, 24
            tz.transition 1954, 4, :o3, -495039600, 19478863, 8
            tz.transition 1954, 9, :o2, -481734000, 19480095, 8
            tz.transition 1955, 4, :o3, -463590000, 19481775, 8
            tz.transition 1955, 9, :o2, -450284400, 19483007, 8
            tz.transition 1956, 4, :o3, -431535600, 19484743, 8
            tz.transition 1956, 9, :o2, -418230000, 19485975, 8
            tz.transition 1957, 4, :o3, -400086000, 19487655, 8
            tz.transition 1957, 9, :o2, -386780400, 19488887, 8
            tz.transition 1958, 4, :o3, -368636400, 19490567, 8
            tz.transition 1958, 9, :o2, -355330800, 19491799, 8
            tz.transition 1959, 4, :o3, -337186800, 19493479, 8
            tz.transition 1959, 9, :o2, -323881200, 19494711, 8
            tz.transition 1960, 4, :o3, -305737200, 19496391, 8
            tz.transition 1960, 9, :o2, -292431600, 19497623, 8
            tz.transition 1976, 4, :o3, 199274400
            tz.transition 1976, 10, :o2, 215600400
            tz.transition 1977, 4, :o3, 230724000
            tz.transition 1977, 10, :o2, 247050000
            tz.transition 1978, 4, :o3, 262778400
            tz.transition 1978, 10, :o2, 278499600
            tz.transition 1979, 4, :o3, 294228000
            tz.transition 1979, 10, :o2, 309949200
            tz.transition 1980, 4, :o3, 325677600
            tz.transition 1980, 10, :o2, 341398800
            tz.transition 1981, 4, :o3, 357127200
            tz.transition 1981, 10, :o2, 372848400
            tz.transition 1982, 4, :o3, 388576800
            tz.transition 1982, 10, :o2, 404902800
            tz.transition 1983, 4, :o3, 420026400
            tz.transition 1983, 10, :o2, 436352400
            tz.transition 1984, 4, :o3, 452080800
            tz.transition 1984, 10, :o2, 467802000
            tz.transition 1985, 4, :o3, 483530400
            tz.transition 1985, 10, :o2, 499251600
            tz.transition 1986, 4, :o3, 514980000
            tz.transition 1986, 10, :o2, 530701200
            tz.transition 1987, 4, :o3, 544615200
            tz.transition 1987, 10, :o2, 562150800
            tz.transition 1988, 4, :o3, 576064800
            tz.transition 1988, 10, :o2, 594205200
            tz.transition 1989, 4, :o3, 607514400
            tz.transition 1989, 10, :o2, 625654800
            tz.transition 1990, 4, :o3, 638964000
            tz.transition 1990, 10, :o2, 657104400
            tz.transition 1991, 4, :o3, 671018400
            tz.transition 1991, 10, :o2, 688554000
            tz.transition 1992, 4, :o3, 702468000
            tz.transition 1992, 10, :o2, 720003600
            tz.transition 1993, 4, :o3, 733917600
            tz.transition 1993, 10, :o2, 752058000
            tz.transition 1994, 4, :o3, 765367200
            tz.transition 1994, 10, :o2, 783507600
            tz.transition 1995, 4, :o3, 796816800
            tz.transition 1995, 10, :o2, 814957200
            tz.transition 1996, 4, :o3, 828871200
            tz.transition 1996, 10, :o2, 846406800
            tz.transition 1997, 4, :o3, 860320800
            tz.transition 1997, 10, :o2, 877856400
            tz.transition 1998, 4, :o3, 891770400
            tz.transition 1998, 10, :o2, 909306000
            tz.transition 1999, 4, :o3, 923220000
            tz.transition 1999, 10, :o2, 941360400
            tz.transition 2000, 4, :o3, 954669600
            tz.transition 2000, 10, :o2, 972810000
            tz.transition 2001, 4, :o3, 986119200
            tz.transition 2001, 10, :o2, 1004259600
            tz.transition 2002, 4, :o3, 1018173600
            tz.transition 2002, 10, :o2, 1035709200
            tz.transition 2003, 4, :o3, 1049623200
            tz.transition 2003, 10, :o2, 1067158800
            tz.transition 2004, 4, :o3, 1081072800
            tz.transition 2004, 10, :o2, 1099213200
            tz.transition 2005, 4, :o3, 1112522400
            tz.transition 2005, 10, :o2, 1130662800
            tz.transition 2006, 4, :o3, 1143972000
            tz.transition 2006, 10, :o2, 1162112400
            tz.transition 2007, 4, :o3, 1175421600
            tz.transition 2007, 10, :o2, 1193562000
            tz.transition 2008, 4, :o3, 1207476000
            tz.transition 2008, 10, :o2, 1225011600
            tz.transition 2009, 4, :o3, 1238925600
            tz.transition 2009, 10, :o2, 1256461200
            tz.transition 2010, 3, :o3, 1268560800
            tz.transition 2010, 11, :o2, 1289120400
            tz.transition 2011, 3, :o3, 1300010400
            tz.transition 2011, 11, :o2, 1320570000
            tz.transition 2012, 3, :o3, 1331460000
            tz.transition 2012, 11, :o2, 1352019600
            tz.transition 2013, 3, :o3, 1362909600
            tz.transition 2013, 11, :o2, 1383469200
            tz.transition 2014, 3, :o3, 1394359200
            tz.transition 2014, 11, :o2, 1414918800
            tz.transition 2015, 3, :o3, 1425808800
            tz.transition 2015, 11, :o2, 1446368400
            tz.transition 2016, 3, :o3, 1457863200
            tz.transition 2016, 11, :o2, 1478422800
            tz.transition 2017, 3, :o3, 1489312800
            tz.transition 2017, 11, :o2, 1509872400
            tz.transition 2018, 3, :o3, 1520762400
            tz.transition 2018, 11, :o2, 1541322000
            tz.transition 2019, 3, :o3, 1552212000
            tz.transition 2019, 11, :o2, 1572771600
            tz.transition 2020, 3, :o3, 1583661600
            tz.transition 2020, 11, :o2, 1604221200
            tz.transition 2021, 3, :o3, 1615716000
            tz.transition 2021, 11, :o2, 1636275600
            tz.transition 2022, 3, :o3, 1647165600
            tz.transition 2022, 11, :o2, 1667725200
            tz.transition 2023, 3, :o3, 1678615200
            tz.transition 2023, 11, :o2, 1699174800
            tz.transition 2024, 3, :o3, 1710064800
            tz.transition 2024, 11, :o2, 1730624400
            tz.transition 2025, 3, :o3, 1741514400
            tz.transition 2025, 11, :o2, 1762074000
            tz.transition 2026, 3, :o3, 1772964000
            tz.transition 2026, 11, :o2, 1793523600
            tz.transition 2027, 3, :o3, 1805018400
            tz.transition 2027, 11, :o2, 1825578000
            tz.transition 2028, 3, :o3, 1836468000
            tz.transition 2028, 11, :o2, 1857027600
            tz.transition 2029, 3, :o3, 1867917600
            tz.transition 2029, 11, :o2, 1888477200
            tz.transition 2030, 3, :o3, 1899367200
            tz.transition 2030, 11, :o2, 1919926800
            tz.transition 2031, 3, :o3, 1930816800
            tz.transition 2031, 11, :o2, 1951376400
            tz.transition 2032, 3, :o3, 1962871200
            tz.transition 2032, 11, :o2, 1983430800
            tz.transition 2033, 3, :o3, 1994320800
            tz.transition 2033, 11, :o2, 2014880400
            tz.transition 2034, 3, :o3, 2025770400
            tz.transition 2034, 11, :o2, 2046330000
            tz.transition 2035, 3, :o3, 2057220000
            tz.transition 2035, 11, :o2, 2077779600
            tz.transition 2036, 3, :o3, 2088669600
            tz.transition 2036, 11, :o2, 2109229200
            tz.transition 2037, 3, :o3, 2120119200
            tz.transition 2037, 11, :o2, 2140678800
            tz.transition 2038, 3, :o3, 2152173600, 29585963, 12
            tz.transition 2038, 11, :o2, 2172733200, 19725879, 8
            tz.transition 2039, 3, :o3, 2183623200, 29590331, 12
            tz.transition 2039, 11, :o2, 2204182800, 19728791, 8
            tz.transition 2040, 3, :o3, 2215072800, 29594699, 12
            tz.transition 2040, 11, :o2, 2235632400, 19731703, 8
            tz.transition 2041, 3, :o3, 2246522400, 29599067, 12
            tz.transition 2041, 11, :o2, 2267082000, 19734615, 8
            tz.transition 2042, 3, :o3, 2277972000, 29603435, 12
            tz.transition 2042, 11, :o2, 2298531600, 19737527, 8
            tz.transition 2043, 3, :o3, 2309421600, 29607803, 12
            tz.transition 2043, 11, :o2, 2329981200, 19740439, 8
            tz.transition 2044, 3, :o3, 2341476000, 29612255, 12
            tz.transition 2044, 11, :o2, 2362035600, 19743407, 8
            tz.transition 2045, 3, :o3, 2372925600, 29616623, 12
            tz.transition 2045, 11, :o2, 2393485200, 19746319, 8
            tz.transition 2046, 3, :o3, 2404375200, 29620991, 12
            tz.transition 2046, 11, :o2, 2424934800, 19749231, 8
            tz.transition 2047, 3, :o3, 2435824800, 29625359, 12
            tz.transition 2047, 11, :o2, 2456384400, 19752143, 8
            tz.transition 2048, 3, :o3, 2467274400, 29629727, 12
            tz.transition 2048, 11, :o2, 2487834000, 19755055, 8
            tz.transition 2049, 3, :o3, 2499328800, 29634179, 12
            tz.transition 2049, 11, :o2, 2519888400, 19758023, 8
            tz.transition 2050, 3, :o3, 2530778400, 29638547, 12
            tz.transition 2050, 11, :o2, 2551338000, 19760935, 8
            tz.transition 2051, 3, :o3, 2562228000, 29642915, 12
            tz.transition 2051, 11, :o2, 2582787600, 19763847, 8
            tz.transition 2052, 3, :o3, 2593677600, 29647283, 12
            tz.transition 2052, 11, :o2, 2614237200, 19766759, 8
            tz.transition 2053, 3, :o3, 2625127200, 29651651, 12
            tz.transition 2053, 11, :o2, 2645686800, 19769671, 8
            tz.transition 2054, 3, :o3, 2656576800, 29656019, 12
            tz.transition 2054, 11, :o2, 2677136400, 19772583, 8
            tz.transition 2055, 3, :o3, 2688631200, 29660471, 12
            tz.transition 2055, 11, :o2, 2709190800, 19775551, 8
            tz.transition 2056, 3, :o3, 2720080800, 29664839, 12
            tz.transition 2056, 11, :o2, 2740640400, 19778463, 8
            tz.transition 2057, 3, :o3, 2751530400, 29669207, 12
            tz.transition 2057, 11, :o2, 2772090000, 19781375, 8
            tz.transition 2058, 3, :o3, 2782980000, 29673575, 12
            tz.transition 2058, 11, :o2, 2803539600, 19784287, 8
            tz.transition 2059, 3, :o3, 2814429600, 29677943, 12
            tz.transition 2059, 11, :o2, 2834989200, 19787199, 8
            tz.transition 2060, 3, :o3, 2846484000, 29682395, 12
            tz.transition 2060, 11, :o2, 2867043600, 19790167, 8
            tz.transition 2061, 3, :o3, 2877933600, 29686763, 12
            tz.transition 2061, 11, :o2, 2898493200, 19793079, 8
            tz.transition 2062, 3, :o3, 2909383200, 29691131, 12
            tz.transition 2062, 11, :o2, 2929942800, 19795991, 8
            tz.transition 2063, 3, :o3, 2940832800, 29695499, 12
            tz.transition 2063, 11, :o2, 2961392400, 19798903, 8
            tz.transition 2064, 3, :o3, 2972282400, 29699867, 12
            tz.transition 2064, 11, :o2, 2992842000, 19801815, 8
            tz.transition 2065, 3, :o3, 3003732000, 29704235, 12
            tz.transition 2065, 11, :o2, 3024291600, 19804727, 8
            tz.transition 2066, 3, :o3, 3035786400, 29708687, 12
            tz.transition 2066, 11, :o2, 3056346000, 19807695, 8
            tz.transition 2067, 3, :o3, 3067236000, 29713055, 12
            tz.transition 2067, 11, :o2, 3087795600, 19810607, 8
            tz.transition 2068, 3, :o3, 3098685600, 29717423, 12
            tz.transition 2068, 11, :o2, 3119245200, 19813519, 8
          end
        end
      end
    end
  end
end
