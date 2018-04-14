# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module Lord_Howe
          include TimezoneDefinition
          
          timezone 'Australia/Lord_Howe' do |tz|
            tz.offset :o0, 38180, 0, :LMT
            tz.offset :o1, 36000, 0, :AEST
            tz.offset :o2, 37800, 0, :'+1030'
            tz.offset :o3, 37800, 3600, :'+1130'
            tz.offset :o4, 37800, 1800, :'+11'
            
            tz.transition 1895, 1, :o1, -2364114980, 10425132251, 4320
            tz.transition 1981, 2, :o2, 352216800
            tz.transition 1981, 10, :o3, 372785400
            tz.transition 1982, 3, :o2, 384273000
            tz.transition 1982, 10, :o3, 404839800
            tz.transition 1983, 3, :o2, 415722600
            tz.transition 1983, 10, :o3, 436289400
            tz.transition 1984, 3, :o2, 447172200
            tz.transition 1984, 10, :o3, 467739000
            tz.transition 1985, 3, :o2, 478621800
            tz.transition 1985, 10, :o4, 499188600
            tz.transition 1986, 3, :o2, 511282800
            tz.transition 1986, 10, :o4, 530033400
            tz.transition 1987, 3, :o2, 542732400
            tz.transition 1987, 10, :o4, 562087800
            tz.transition 1988, 3, :o2, 574786800
            tz.transition 1988, 10, :o4, 594142200
            tz.transition 1989, 3, :o2, 606236400
            tz.transition 1989, 10, :o4, 625591800
            tz.transition 1990, 3, :o2, 636476400
            tz.transition 1990, 10, :o4, 657041400
            tz.transition 1991, 3, :o2, 667926000
            tz.transition 1991, 10, :o4, 688491000
            tz.transition 1992, 2, :o2, 699375600
            tz.transition 1992, 10, :o4, 719940600
            tz.transition 1993, 3, :o2, 731430000
            tz.transition 1993, 10, :o4, 751995000
            tz.transition 1994, 3, :o2, 762879600
            tz.transition 1994, 10, :o4, 783444600
            tz.transition 1995, 3, :o2, 794329200
            tz.transition 1995, 10, :o4, 814894200
            tz.transition 1996, 3, :o2, 828198000
            tz.transition 1996, 10, :o4, 846343800
            tz.transition 1997, 3, :o2, 859647600
            tz.transition 1997, 10, :o4, 877793400
            tz.transition 1998, 3, :o2, 891097200
            tz.transition 1998, 10, :o4, 909243000
            tz.transition 1999, 3, :o2, 922546800
            tz.transition 1999, 10, :o4, 941297400
            tz.transition 2000, 3, :o2, 953996400
            tz.transition 2000, 8, :o4, 967303800
            tz.transition 2001, 3, :o2, 985446000
            tz.transition 2001, 10, :o4, 1004196600
            tz.transition 2002, 3, :o2, 1017500400
            tz.transition 2002, 10, :o4, 1035646200
            tz.transition 2003, 3, :o2, 1048950000
            tz.transition 2003, 10, :o4, 1067095800
            tz.transition 2004, 3, :o2, 1080399600
            tz.transition 2004, 10, :o4, 1099150200
            tz.transition 2005, 3, :o2, 1111849200
            tz.transition 2005, 10, :o4, 1130599800
            tz.transition 2006, 4, :o2, 1143903600
            tz.transition 2006, 10, :o4, 1162049400
            tz.transition 2007, 3, :o2, 1174748400
            tz.transition 2007, 10, :o4, 1193499000
            tz.transition 2008, 4, :o2, 1207407600
            tz.transition 2008, 10, :o4, 1223134200
            tz.transition 2009, 4, :o2, 1238857200
            tz.transition 2009, 10, :o4, 1254583800
            tz.transition 2010, 4, :o2, 1270306800
            tz.transition 2010, 10, :o4, 1286033400
            tz.transition 2011, 4, :o2, 1301756400
            tz.transition 2011, 10, :o4, 1317483000
            tz.transition 2012, 3, :o2, 1333206000
            tz.transition 2012, 10, :o4, 1349537400
            tz.transition 2013, 4, :o2, 1365260400
            tz.transition 2013, 10, :o4, 1380987000
            tz.transition 2014, 4, :o2, 1396710000
            tz.transition 2014, 10, :o4, 1412436600
            tz.transition 2015, 4, :o2, 1428159600
            tz.transition 2015, 10, :o4, 1443886200
            tz.transition 2016, 4, :o2, 1459609200
            tz.transition 2016, 10, :o4, 1475335800
            tz.transition 2017, 4, :o2, 1491058800
            tz.transition 2017, 9, :o4, 1506785400
            tz.transition 2018, 3, :o2, 1522508400
            tz.transition 2018, 10, :o4, 1538839800
            tz.transition 2019, 4, :o2, 1554562800
            tz.transition 2019, 10, :o4, 1570289400
            tz.transition 2020, 4, :o2, 1586012400
            tz.transition 2020, 10, :o4, 1601739000
            tz.transition 2021, 4, :o2, 1617462000
            tz.transition 2021, 10, :o4, 1633188600
            tz.transition 2022, 4, :o2, 1648911600
            tz.transition 2022, 10, :o4, 1664638200
            tz.transition 2023, 4, :o2, 1680361200
            tz.transition 2023, 9, :o4, 1696087800
            tz.transition 2024, 4, :o2, 1712415600
            tz.transition 2024, 10, :o4, 1728142200
            tz.transition 2025, 4, :o2, 1743865200
            tz.transition 2025, 10, :o4, 1759591800
            tz.transition 2026, 4, :o2, 1775314800
            tz.transition 2026, 10, :o4, 1791041400
            tz.transition 2027, 4, :o2, 1806764400
            tz.transition 2027, 10, :o4, 1822491000
            tz.transition 2028, 4, :o2, 1838214000
            tz.transition 2028, 9, :o4, 1853940600
            tz.transition 2029, 3, :o2, 1869663600
            tz.transition 2029, 10, :o4, 1885995000
            tz.transition 2030, 4, :o2, 1901718000
            tz.transition 2030, 10, :o4, 1917444600
            tz.transition 2031, 4, :o2, 1933167600
            tz.transition 2031, 10, :o4, 1948894200
            tz.transition 2032, 4, :o2, 1964617200
            tz.transition 2032, 10, :o4, 1980343800
            tz.transition 2033, 4, :o2, 1996066800
            tz.transition 2033, 10, :o4, 2011793400
            tz.transition 2034, 4, :o2, 2027516400
            tz.transition 2034, 9, :o4, 2043243000
            tz.transition 2035, 3, :o2, 2058966000
            tz.transition 2035, 10, :o4, 2075297400
            tz.transition 2036, 4, :o2, 2091020400
            tz.transition 2036, 10, :o4, 2106747000
            tz.transition 2037, 4, :o2, 2122470000
            tz.transition 2037, 10, :o4, 2138196600
            tz.transition 2038, 4, :o2, 2153919600, 19724137, 8
            tz.transition 2038, 10, :o4, 2169646200, 118353559, 48
            tz.transition 2039, 4, :o2, 2185369200, 19727049, 8
            tz.transition 2039, 10, :o4, 2201095800, 118371031, 48
            tz.transition 2040, 3, :o2, 2216818800, 19729961, 8
            tz.transition 2040, 10, :o4, 2233150200, 118388839, 48
            tz.transition 2041, 4, :o2, 2248873200, 19732929, 8
            tz.transition 2041, 10, :o4, 2264599800, 118406311, 48
            tz.transition 2042, 4, :o2, 2280322800, 19735841, 8
            tz.transition 2042, 10, :o4, 2296049400, 118423783, 48
            tz.transition 2043, 4, :o2, 2311772400, 19738753, 8
            tz.transition 2043, 10, :o4, 2327499000, 118441255, 48
            tz.transition 2044, 4, :o2, 2343222000, 19741665, 8
            tz.transition 2044, 10, :o4, 2358948600, 118458727, 48
            tz.transition 2045, 4, :o2, 2374671600, 19744577, 8
            tz.transition 2045, 9, :o4, 2390398200, 118476199, 48
            tz.transition 2046, 3, :o2, 2406121200, 19747489, 8
            tz.transition 2046, 10, :o4, 2422452600, 118494007, 48
            tz.transition 2047, 4, :o2, 2438175600, 19750457, 8
            tz.transition 2047, 10, :o4, 2453902200, 118511479, 48
            tz.transition 2048, 4, :o2, 2469625200, 19753369, 8
            tz.transition 2048, 10, :o4, 2485351800, 118528951, 48
            tz.transition 2049, 4, :o2, 2501074800, 19756281, 8
            tz.transition 2049, 10, :o4, 2516801400, 118546423, 48
            tz.transition 2050, 4, :o2, 2532524400, 19759193, 8
            tz.transition 2050, 10, :o4, 2548251000, 118563895, 48
            tz.transition 2051, 4, :o2, 2563974000, 19762105, 8
            tz.transition 2051, 9, :o4, 2579700600, 118581367, 48
            tz.transition 2052, 4, :o2, 2596028400, 19765073, 8
            tz.transition 2052, 10, :o4, 2611755000, 118599175, 48
            tz.transition 2053, 4, :o2, 2627478000, 19767985, 8
            tz.transition 2053, 10, :o4, 2643204600, 118616647, 48
            tz.transition 2054, 4, :o2, 2658927600, 19770897, 8
            tz.transition 2054, 10, :o4, 2674654200, 118634119, 48
            tz.transition 2055, 4, :o2, 2690377200, 19773809, 8
            tz.transition 2055, 10, :o4, 2706103800, 118651591, 48
            tz.transition 2056, 4, :o2, 2721826800, 19776721, 8
            tz.transition 2056, 9, :o4, 2737553400, 118669063, 48
            tz.transition 2057, 3, :o2, 2753276400, 19779633, 8
            tz.transition 2057, 10, :o4, 2769607800, 118686871, 48
            tz.transition 2058, 4, :o2, 2785330800, 19782601, 8
            tz.transition 2058, 10, :o4, 2801057400, 118704343, 48
            tz.transition 2059, 4, :o2, 2816780400, 19785513, 8
            tz.transition 2059, 10, :o4, 2832507000, 118721815, 48
            tz.transition 2060, 4, :o2, 2848230000, 19788425, 8
            tz.transition 2060, 10, :o4, 2863956600, 118739287, 48
            tz.transition 2061, 4, :o2, 2879679600, 19791337, 8
            tz.transition 2061, 10, :o4, 2895406200, 118756759, 48
            tz.transition 2062, 4, :o2, 2911129200, 19794249, 8
            tz.transition 2062, 9, :o4, 2926855800, 118774231, 48
            tz.transition 2063, 3, :o2, 2942578800, 19797161, 8
            tz.transition 2063, 10, :o4, 2958910200, 118792039, 48
            tz.transition 2064, 4, :o2, 2974633200, 19800129, 8
            tz.transition 2064, 10, :o4, 2990359800, 118809511, 48
            tz.transition 2065, 4, :o2, 3006082800, 19803041, 8
            tz.transition 2065, 10, :o4, 3021809400, 118826983, 48
            tz.transition 2066, 4, :o2, 3037532400, 19805953, 8
            tz.transition 2066, 10, :o4, 3053259000, 118844455, 48
            tz.transition 2067, 4, :o2, 3068982000, 19808865, 8
            tz.transition 2067, 10, :o4, 3084708600, 118861927, 48
            tz.transition 2068, 3, :o2, 3100431600, 19811777, 8
          end
        end
      end
    end
  end
end
