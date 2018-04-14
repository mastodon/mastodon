# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Los_Angeles
          include TimezoneDefinition
          
          timezone 'America/Los_Angeles' do |tz|
            tz.offset :o0, -28378, 0, :LMT
            tz.offset :o1, -28800, 0, :PST
            tz.offset :o2, -28800, 3600, :PDT
            tz.offset :o3, -28800, 3600, :PWT
            tz.offset :o4, -28800, 3600, :PPT
            
            tz.transition 1883, 11, :o1, -2717640000, 7227400, 3
            tz.transition 1918, 3, :o2, -1633269600, 29060207, 12
            tz.transition 1918, 10, :o1, -1615129200, 19375151, 8
            tz.transition 1919, 3, :o2, -1601820000, 29064575, 12
            tz.transition 1919, 10, :o1, -1583679600, 19378063, 8
            tz.transition 1942, 2, :o3, -880207200, 29164799, 12
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765385200, 19453831, 8
            tz.transition 1948, 3, :o2, -687967140, 3502979881, 1440
            tz.transition 1949, 1, :o1, -662655600, 19463343, 8
            tz.transition 1950, 4, :o2, -620838000, 19467215, 8
            tz.transition 1950, 9, :o1, -608137200, 19468391, 8
            tz.transition 1951, 4, :o2, -589388400, 19470127, 8
            tz.transition 1951, 9, :o1, -576082800, 19471359, 8
            tz.transition 1952, 4, :o2, -557938800, 19473039, 8
            tz.transition 1952, 9, :o1, -544633200, 19474271, 8
            tz.transition 1953, 4, :o2, -526489200, 19475951, 8
            tz.transition 1953, 9, :o1, -513183600, 19477183, 8
            tz.transition 1954, 4, :o2, -495039600, 19478863, 8
            tz.transition 1954, 9, :o1, -481734000, 19480095, 8
            tz.transition 1955, 4, :o2, -463590000, 19481775, 8
            tz.transition 1955, 9, :o1, -450284400, 19483007, 8
            tz.transition 1956, 4, :o2, -431535600, 19484743, 8
            tz.transition 1956, 9, :o1, -418230000, 19485975, 8
            tz.transition 1957, 4, :o2, -400086000, 19487655, 8
            tz.transition 1957, 9, :o1, -386780400, 19488887, 8
            tz.transition 1958, 4, :o2, -368636400, 19490567, 8
            tz.transition 1958, 9, :o1, -355330800, 19491799, 8
            tz.transition 1959, 4, :o2, -337186800, 19493479, 8
            tz.transition 1959, 9, :o1, -323881200, 19494711, 8
            tz.transition 1960, 4, :o2, -305737200, 19496391, 8
            tz.transition 1960, 9, :o1, -292431600, 19497623, 8
            tz.transition 1961, 4, :o2, -273682800, 19499359, 8
            tz.transition 1961, 9, :o1, -260982000, 19500535, 8
            tz.transition 1962, 4, :o2, -242233200, 19502271, 8
            tz.transition 1962, 10, :o1, -226508400, 19503727, 8
            tz.transition 1963, 4, :o2, -210783600, 19505183, 8
            tz.transition 1963, 10, :o1, -195058800, 19506639, 8
            tz.transition 1964, 4, :o2, -179334000, 19508095, 8
            tz.transition 1964, 10, :o1, -163609200, 19509551, 8
            tz.transition 1965, 4, :o2, -147884400, 19511007, 8
            tz.transition 1965, 10, :o1, -131554800, 19512519, 8
            tz.transition 1966, 4, :o2, -116434800, 19513919, 8
            tz.transition 1966, 10, :o1, -100105200, 19515431, 8
            tz.transition 1967, 4, :o2, -84376800, 29275331, 12
            tz.transition 1967, 10, :o1, -68655600, 19518343, 8
            tz.transition 1968, 4, :o2, -52927200, 29279699, 12
            tz.transition 1968, 10, :o1, -37206000, 19521255, 8
            tz.transition 1969, 4, :o2, -21477600, 29284067, 12
            tz.transition 1969, 10, :o1, -5756400, 19524167, 8
            tz.transition 1970, 4, :o2, 9972000
            tz.transition 1970, 10, :o1, 25693200
            tz.transition 1971, 4, :o2, 41421600
            tz.transition 1971, 10, :o1, 57747600
            tz.transition 1972, 4, :o2, 73476000
            tz.transition 1972, 10, :o1, 89197200
            tz.transition 1973, 4, :o2, 104925600
            tz.transition 1973, 10, :o1, 120646800
            tz.transition 1974, 1, :o2, 126698400
            tz.transition 1974, 10, :o1, 152096400
            tz.transition 1975, 2, :o2, 162381600
            tz.transition 1975, 10, :o1, 183546000
            tz.transition 1976, 4, :o2, 199274400
            tz.transition 1976, 10, :o1, 215600400
            tz.transition 1977, 4, :o2, 230724000
            tz.transition 1977, 10, :o1, 247050000
            tz.transition 1978, 4, :o2, 262778400
            tz.transition 1978, 10, :o1, 278499600
            tz.transition 1979, 4, :o2, 294228000
            tz.transition 1979, 10, :o1, 309949200
            tz.transition 1980, 4, :o2, 325677600
            tz.transition 1980, 10, :o1, 341398800
            tz.transition 1981, 4, :o2, 357127200
            tz.transition 1981, 10, :o1, 372848400
            tz.transition 1982, 4, :o2, 388576800
            tz.transition 1982, 10, :o1, 404902800
            tz.transition 1983, 4, :o2, 420026400
            tz.transition 1983, 10, :o1, 436352400
            tz.transition 1984, 4, :o2, 452080800
            tz.transition 1984, 10, :o1, 467802000
            tz.transition 1985, 4, :o2, 483530400
            tz.transition 1985, 10, :o1, 499251600
            tz.transition 1986, 4, :o2, 514980000
            tz.transition 1986, 10, :o1, 530701200
            tz.transition 1987, 4, :o2, 544615200
            tz.transition 1987, 10, :o1, 562150800
            tz.transition 1988, 4, :o2, 576064800
            tz.transition 1988, 10, :o1, 594205200
            tz.transition 1989, 4, :o2, 607514400
            tz.transition 1989, 10, :o1, 625654800
            tz.transition 1990, 4, :o2, 638964000
            tz.transition 1990, 10, :o1, 657104400
            tz.transition 1991, 4, :o2, 671018400
            tz.transition 1991, 10, :o1, 688554000
            tz.transition 1992, 4, :o2, 702468000
            tz.transition 1992, 10, :o1, 720003600
            tz.transition 1993, 4, :o2, 733917600
            tz.transition 1993, 10, :o1, 752058000
            tz.transition 1994, 4, :o2, 765367200
            tz.transition 1994, 10, :o1, 783507600
            tz.transition 1995, 4, :o2, 796816800
            tz.transition 1995, 10, :o1, 814957200
            tz.transition 1996, 4, :o2, 828871200
            tz.transition 1996, 10, :o1, 846406800
            tz.transition 1997, 4, :o2, 860320800
            tz.transition 1997, 10, :o1, 877856400
            tz.transition 1998, 4, :o2, 891770400
            tz.transition 1998, 10, :o1, 909306000
            tz.transition 1999, 4, :o2, 923220000
            tz.transition 1999, 10, :o1, 941360400
            tz.transition 2000, 4, :o2, 954669600
            tz.transition 2000, 10, :o1, 972810000
            tz.transition 2001, 4, :o2, 986119200
            tz.transition 2001, 10, :o1, 1004259600
            tz.transition 2002, 4, :o2, 1018173600
            tz.transition 2002, 10, :o1, 1035709200
            tz.transition 2003, 4, :o2, 1049623200
            tz.transition 2003, 10, :o1, 1067158800
            tz.transition 2004, 4, :o2, 1081072800
            tz.transition 2004, 10, :o1, 1099213200
            tz.transition 2005, 4, :o2, 1112522400
            tz.transition 2005, 10, :o1, 1130662800
            tz.transition 2006, 4, :o2, 1143972000
            tz.transition 2006, 10, :o1, 1162112400
            tz.transition 2007, 3, :o2, 1173607200
            tz.transition 2007, 11, :o1, 1194166800
            tz.transition 2008, 3, :o2, 1205056800
            tz.transition 2008, 11, :o1, 1225616400
            tz.transition 2009, 3, :o2, 1236506400
            tz.transition 2009, 11, :o1, 1257066000
            tz.transition 2010, 3, :o2, 1268560800
            tz.transition 2010, 11, :o1, 1289120400
            tz.transition 2011, 3, :o2, 1300010400
            tz.transition 2011, 11, :o1, 1320570000
            tz.transition 2012, 3, :o2, 1331460000
            tz.transition 2012, 11, :o1, 1352019600
            tz.transition 2013, 3, :o2, 1362909600
            tz.transition 2013, 11, :o1, 1383469200
            tz.transition 2014, 3, :o2, 1394359200
            tz.transition 2014, 11, :o1, 1414918800
            tz.transition 2015, 3, :o2, 1425808800
            tz.transition 2015, 11, :o1, 1446368400
            tz.transition 2016, 3, :o2, 1457863200
            tz.transition 2016, 11, :o1, 1478422800
            tz.transition 2017, 3, :o2, 1489312800
            tz.transition 2017, 11, :o1, 1509872400
            tz.transition 2018, 3, :o2, 1520762400
            tz.transition 2018, 11, :o1, 1541322000
            tz.transition 2019, 3, :o2, 1552212000
            tz.transition 2019, 11, :o1, 1572771600
            tz.transition 2020, 3, :o2, 1583661600
            tz.transition 2020, 11, :o1, 1604221200
            tz.transition 2021, 3, :o2, 1615716000
            tz.transition 2021, 11, :o1, 1636275600
            tz.transition 2022, 3, :o2, 1647165600
            tz.transition 2022, 11, :o1, 1667725200
            tz.transition 2023, 3, :o2, 1678615200
            tz.transition 2023, 11, :o1, 1699174800
            tz.transition 2024, 3, :o2, 1710064800
            tz.transition 2024, 11, :o1, 1730624400
            tz.transition 2025, 3, :o2, 1741514400
            tz.transition 2025, 11, :o1, 1762074000
            tz.transition 2026, 3, :o2, 1772964000
            tz.transition 2026, 11, :o1, 1793523600
            tz.transition 2027, 3, :o2, 1805018400
            tz.transition 2027, 11, :o1, 1825578000
            tz.transition 2028, 3, :o2, 1836468000
            tz.transition 2028, 11, :o1, 1857027600
            tz.transition 2029, 3, :o2, 1867917600
            tz.transition 2029, 11, :o1, 1888477200
            tz.transition 2030, 3, :o2, 1899367200
            tz.transition 2030, 11, :o1, 1919926800
            tz.transition 2031, 3, :o2, 1930816800
            tz.transition 2031, 11, :o1, 1951376400
            tz.transition 2032, 3, :o2, 1962871200
            tz.transition 2032, 11, :o1, 1983430800
            tz.transition 2033, 3, :o2, 1994320800
            tz.transition 2033, 11, :o1, 2014880400
            tz.transition 2034, 3, :o2, 2025770400
            tz.transition 2034, 11, :o1, 2046330000
            tz.transition 2035, 3, :o2, 2057220000
            tz.transition 2035, 11, :o1, 2077779600
            tz.transition 2036, 3, :o2, 2088669600
            tz.transition 2036, 11, :o1, 2109229200
            tz.transition 2037, 3, :o2, 2120119200
            tz.transition 2037, 11, :o1, 2140678800
            tz.transition 2038, 3, :o2, 2152173600, 29585963, 12
            tz.transition 2038, 11, :o1, 2172733200, 19725879, 8
            tz.transition 2039, 3, :o2, 2183623200, 29590331, 12
            tz.transition 2039, 11, :o1, 2204182800, 19728791, 8
            tz.transition 2040, 3, :o2, 2215072800, 29594699, 12
            tz.transition 2040, 11, :o1, 2235632400, 19731703, 8
            tz.transition 2041, 3, :o2, 2246522400, 29599067, 12
            tz.transition 2041, 11, :o1, 2267082000, 19734615, 8
            tz.transition 2042, 3, :o2, 2277972000, 29603435, 12
            tz.transition 2042, 11, :o1, 2298531600, 19737527, 8
            tz.transition 2043, 3, :o2, 2309421600, 29607803, 12
            tz.transition 2043, 11, :o1, 2329981200, 19740439, 8
            tz.transition 2044, 3, :o2, 2341476000, 29612255, 12
            tz.transition 2044, 11, :o1, 2362035600, 19743407, 8
            tz.transition 2045, 3, :o2, 2372925600, 29616623, 12
            tz.transition 2045, 11, :o1, 2393485200, 19746319, 8
            tz.transition 2046, 3, :o2, 2404375200, 29620991, 12
            tz.transition 2046, 11, :o1, 2424934800, 19749231, 8
            tz.transition 2047, 3, :o2, 2435824800, 29625359, 12
            tz.transition 2047, 11, :o1, 2456384400, 19752143, 8
            tz.transition 2048, 3, :o2, 2467274400, 29629727, 12
            tz.transition 2048, 11, :o1, 2487834000, 19755055, 8
            tz.transition 2049, 3, :o2, 2499328800, 29634179, 12
            tz.transition 2049, 11, :o1, 2519888400, 19758023, 8
            tz.transition 2050, 3, :o2, 2530778400, 29638547, 12
            tz.transition 2050, 11, :o1, 2551338000, 19760935, 8
            tz.transition 2051, 3, :o2, 2562228000, 29642915, 12
            tz.transition 2051, 11, :o1, 2582787600, 19763847, 8
            tz.transition 2052, 3, :o2, 2593677600, 29647283, 12
            tz.transition 2052, 11, :o1, 2614237200, 19766759, 8
            tz.transition 2053, 3, :o2, 2625127200, 29651651, 12
            tz.transition 2053, 11, :o1, 2645686800, 19769671, 8
            tz.transition 2054, 3, :o2, 2656576800, 29656019, 12
            tz.transition 2054, 11, :o1, 2677136400, 19772583, 8
            tz.transition 2055, 3, :o2, 2688631200, 29660471, 12
            tz.transition 2055, 11, :o1, 2709190800, 19775551, 8
            tz.transition 2056, 3, :o2, 2720080800, 29664839, 12
            tz.transition 2056, 11, :o1, 2740640400, 19778463, 8
            tz.transition 2057, 3, :o2, 2751530400, 29669207, 12
            tz.transition 2057, 11, :o1, 2772090000, 19781375, 8
            tz.transition 2058, 3, :o2, 2782980000, 29673575, 12
            tz.transition 2058, 11, :o1, 2803539600, 19784287, 8
            tz.transition 2059, 3, :o2, 2814429600, 29677943, 12
            tz.transition 2059, 11, :o1, 2834989200, 19787199, 8
            tz.transition 2060, 3, :o2, 2846484000, 29682395, 12
            tz.transition 2060, 11, :o1, 2867043600, 19790167, 8
            tz.transition 2061, 3, :o2, 2877933600, 29686763, 12
            tz.transition 2061, 11, :o1, 2898493200, 19793079, 8
            tz.transition 2062, 3, :o2, 2909383200, 29691131, 12
            tz.transition 2062, 11, :o1, 2929942800, 19795991, 8
            tz.transition 2063, 3, :o2, 2940832800, 29695499, 12
            tz.transition 2063, 11, :o1, 2961392400, 19798903, 8
            tz.transition 2064, 3, :o2, 2972282400, 29699867, 12
            tz.transition 2064, 11, :o1, 2992842000, 19801815, 8
            tz.transition 2065, 3, :o2, 3003732000, 29704235, 12
            tz.transition 2065, 11, :o1, 3024291600, 19804727, 8
            tz.transition 2066, 3, :o2, 3035786400, 29708687, 12
            tz.transition 2066, 11, :o1, 3056346000, 19807695, 8
            tz.transition 2067, 3, :o2, 3067236000, 29713055, 12
            tz.transition 2067, 11, :o1, 3087795600, 19810607, 8
            tz.transition 2068, 3, :o2, 3098685600, 29717423, 12
            tz.transition 2068, 11, :o1, 3119245200, 19813519, 8
          end
        end
      end
    end
  end
end
