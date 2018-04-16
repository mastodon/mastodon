# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Tehran
          include TimezoneDefinition
          
          timezone 'Asia/Tehran' do |tz|
            tz.offset :o0, 12344, 0, :LMT
            tz.offset :o1, 12344, 0, :TMT
            tz.offset :o2, 12600, 0, :'+0330'
            tz.offset :o3, 14400, 0, :'+04'
            tz.offset :o4, 14400, 3600, :'+05'
            tz.offset :o5, 12600, 3600, :'+0430'
            
            tz.transition 1915, 12, :o1, -1704165944, 26145324257, 10800
            tz.transition 1945, 12, :o2, -757394744, 26263670657, 10800
            tz.transition 1977, 10, :o3, 247177800
            tz.transition 1978, 3, :o4, 259272000
            tz.transition 1978, 10, :o3, 277758000
            tz.transition 1978, 12, :o2, 283982400
            tz.transition 1979, 3, :o5, 290809800
            tz.transition 1979, 9, :o2, 306531000
            tz.transition 1980, 3, :o5, 322432200
            tz.transition 1980, 9, :o2, 338499000
            tz.transition 1991, 5, :o5, 673216200
            tz.transition 1991, 9, :o2, 685481400
            tz.transition 1992, 3, :o5, 701209800
            tz.transition 1992, 9, :o2, 717103800
            tz.transition 1993, 3, :o5, 732745800
            tz.transition 1993, 9, :o2, 748639800
            tz.transition 1994, 3, :o5, 764281800
            tz.transition 1994, 9, :o2, 780175800
            tz.transition 1995, 3, :o5, 795817800
            tz.transition 1995, 9, :o2, 811711800
            tz.transition 1996, 3, :o5, 827353800
            tz.transition 1996, 9, :o2, 843247800
            tz.transition 1997, 3, :o5, 858976200
            tz.transition 1997, 9, :o2, 874870200
            tz.transition 1998, 3, :o5, 890512200
            tz.transition 1998, 9, :o2, 906406200
            tz.transition 1999, 3, :o5, 922048200
            tz.transition 1999, 9, :o2, 937942200
            tz.transition 2000, 3, :o5, 953584200
            tz.transition 2000, 9, :o2, 969478200
            tz.transition 2001, 3, :o5, 985206600
            tz.transition 2001, 9, :o2, 1001100600
            tz.transition 2002, 3, :o5, 1016742600
            tz.transition 2002, 9, :o2, 1032636600
            tz.transition 2003, 3, :o5, 1048278600
            tz.transition 2003, 9, :o2, 1064172600
            tz.transition 2004, 3, :o5, 1079814600
            tz.transition 2004, 9, :o2, 1095708600
            tz.transition 2005, 3, :o5, 1111437000
            tz.transition 2005, 9, :o2, 1127331000
            tz.transition 2008, 3, :o5, 1206045000
            tz.transition 2008, 9, :o2, 1221939000
            tz.transition 2009, 3, :o5, 1237667400
            tz.transition 2009, 9, :o2, 1253561400
            tz.transition 2010, 3, :o5, 1269203400
            tz.transition 2010, 9, :o2, 1285097400
            tz.transition 2011, 3, :o5, 1300739400
            tz.transition 2011, 9, :o2, 1316633400
            tz.transition 2012, 3, :o5, 1332275400
            tz.transition 2012, 9, :o2, 1348169400
            tz.transition 2013, 3, :o5, 1363897800
            tz.transition 2013, 9, :o2, 1379791800
            tz.transition 2014, 3, :o5, 1395433800
            tz.transition 2014, 9, :o2, 1411327800
            tz.transition 2015, 3, :o5, 1426969800
            tz.transition 2015, 9, :o2, 1442863800
            tz.transition 2016, 3, :o5, 1458505800
            tz.transition 2016, 9, :o2, 1474399800
            tz.transition 2017, 3, :o5, 1490128200
            tz.transition 2017, 9, :o2, 1506022200
            tz.transition 2018, 3, :o5, 1521664200
            tz.transition 2018, 9, :o2, 1537558200
            tz.transition 2019, 3, :o5, 1553200200
            tz.transition 2019, 9, :o2, 1569094200
            tz.transition 2020, 3, :o5, 1584736200
            tz.transition 2020, 9, :o2, 1600630200
            tz.transition 2021, 3, :o5, 1616358600
            tz.transition 2021, 9, :o2, 1632252600
            tz.transition 2022, 3, :o5, 1647894600
            tz.transition 2022, 9, :o2, 1663788600
            tz.transition 2023, 3, :o5, 1679430600
            tz.transition 2023, 9, :o2, 1695324600
            tz.transition 2024, 3, :o5, 1710966600
            tz.transition 2024, 9, :o2, 1726860600
            tz.transition 2025, 3, :o5, 1742589000
            tz.transition 2025, 9, :o2, 1758483000
            tz.transition 2026, 3, :o5, 1774125000
            tz.transition 2026, 9, :o2, 1790019000
            tz.transition 2027, 3, :o5, 1805661000
            tz.transition 2027, 9, :o2, 1821555000
            tz.transition 2028, 3, :o5, 1837197000
            tz.transition 2028, 9, :o2, 1853091000
            tz.transition 2029, 3, :o5, 1868733000
            tz.transition 2029, 9, :o2, 1884627000
            tz.transition 2030, 3, :o5, 1900355400
            tz.transition 2030, 9, :o2, 1916249400
            tz.transition 2031, 3, :o5, 1931891400
            tz.transition 2031, 9, :o2, 1947785400
            tz.transition 2032, 3, :o5, 1963427400
            tz.transition 2032, 9, :o2, 1979321400
            tz.transition 2033, 3, :o5, 1994963400
            tz.transition 2033, 9, :o2, 2010857400
            tz.transition 2034, 3, :o5, 2026585800
            tz.transition 2034, 9, :o2, 2042479800
            tz.transition 2035, 3, :o5, 2058121800
            tz.transition 2035, 9, :o2, 2074015800
            tz.transition 2036, 3, :o5, 2089657800
            tz.transition 2036, 9, :o2, 2105551800
            tz.transition 2037, 3, :o5, 2121193800
            tz.transition 2037, 9, :o2, 2137087800
            tz.transition 2038, 3, :o5, 2152729800, 118344161, 48
            tz.transition 2038, 9, :o2, 2168623800, 39450997, 16
            tz.transition 2039, 3, :o5, 2184265800, 118361681, 48
            tz.transition 2039, 9, :o2, 2200159800, 39456837, 16
            tz.transition 2040, 3, :o5, 2215888200, 118379249, 48
            tz.transition 2040, 9, :o2, 2231782200, 39462693, 16
            tz.transition 2041, 3, :o5, 2247424200, 118396769, 48
            tz.transition 2041, 9, :o2, 2263318200, 39468533, 16
            tz.transition 2042, 3, :o5, 2278960200, 118414289, 48
            tz.transition 2042, 9, :o2, 2294854200, 39474373, 16
            tz.transition 2043, 3, :o5, 2310496200, 118431809, 48
            tz.transition 2043, 9, :o2, 2326390200, 39480213, 16
            tz.transition 2044, 3, :o5, 2342118600, 118449377, 48
            tz.transition 2044, 9, :o2, 2358012600, 39486069, 16
            tz.transition 2045, 3, :o5, 2373654600, 118466897, 48
            tz.transition 2045, 9, :o2, 2389548600, 39491909, 16
            tz.transition 2046, 3, :o5, 2405190600, 118484417, 48
            tz.transition 2046, 9, :o2, 2421084600, 39497749, 16
            tz.transition 2047, 3, :o5, 2436726600, 118501937, 48
            tz.transition 2047, 9, :o2, 2452620600, 39503589, 16
            tz.transition 2048, 3, :o5, 2468349000, 118519505, 48
            tz.transition 2048, 9, :o2, 2484243000, 39509445, 16
            tz.transition 2049, 3, :o5, 2499885000, 118537025, 48
            tz.transition 2049, 9, :o2, 2515779000, 39515285, 16
            tz.transition 2050, 3, :o5, 2531421000, 118554545, 48
            tz.transition 2050, 9, :o2, 2547315000, 39521125, 16
            tz.transition 2051, 3, :o5, 2562957000, 118572065, 48
            tz.transition 2051, 9, :o2, 2578851000, 39526965, 16
            tz.transition 2052, 3, :o5, 2594579400, 118589633, 48
            tz.transition 2052, 9, :o2, 2610473400, 39532821, 16
            tz.transition 2053, 3, :o5, 2626115400, 118607153, 48
            tz.transition 2053, 9, :o2, 2642009400, 39538661, 16
            tz.transition 2054, 3, :o5, 2657651400, 118624673, 48
            tz.transition 2054, 9, :o2, 2673545400, 39544501, 16
            tz.transition 2055, 3, :o5, 2689187400, 118642193, 48
            tz.transition 2055, 9, :o2, 2705081400, 39550341, 16
            tz.transition 2056, 3, :o5, 2720809800, 118659761, 48
            tz.transition 2056, 9, :o2, 2736703800, 39556197, 16
            tz.transition 2057, 3, :o5, 2752345800, 118677281, 48
            tz.transition 2057, 9, :o2, 2768239800, 39562037, 16
            tz.transition 2058, 3, :o5, 2783881800, 118694801, 48
            tz.transition 2058, 9, :o2, 2799775800, 39567877, 16
            tz.transition 2059, 3, :o5, 2815417800, 118712321, 48
            tz.transition 2059, 9, :o2, 2831311800, 39573717, 16
            tz.transition 2060, 3, :o5, 2847040200, 118729889, 48
            tz.transition 2060, 9, :o2, 2862934200, 39579573, 16
            tz.transition 2061, 3, :o5, 2878576200, 118747409, 48
            tz.transition 2061, 9, :o2, 2894470200, 39585413, 16
            tz.transition 2062, 3, :o5, 2910112200, 118764929, 48
            tz.transition 2062, 9, :o2, 2926006200, 39591253, 16
            tz.transition 2063, 3, :o5, 2941648200, 118782449, 48
            tz.transition 2063, 9, :o2, 2957542200, 39597093, 16
            tz.transition 2064, 3, :o5, 2973270600, 118800017, 48
            tz.transition 2064, 9, :o2, 2989164600, 39602949, 16
            tz.transition 2065, 3, :o5, 3004806600, 118817537, 48
            tz.transition 2065, 9, :o2, 3020700600, 39608789, 16
            tz.transition 2066, 3, :o5, 3036342600, 118835057, 48
            tz.transition 2066, 9, :o2, 3052236600, 39614629, 16
            tz.transition 2067, 3, :o5, 3067878600, 118852577, 48
            tz.transition 2067, 9, :o2, 3083772600, 39620469, 16
            tz.transition 2068, 3, :o5, 3099501000, 118870145, 48
            tz.transition 2068, 9, :o2, 3115395000, 39626325, 16
          end
        end
      end
    end
  end
end
