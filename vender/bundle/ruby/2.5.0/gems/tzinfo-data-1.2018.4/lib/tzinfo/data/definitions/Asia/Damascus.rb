# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Damascus
          include TimezoneDefinition
          
          timezone 'Asia/Damascus' do |tz|
            tz.offset :o0, 8712, 0, :LMT
            tz.offset :o1, 7200, 0, :EET
            tz.offset :o2, 7200, 3600, :EEST
            
            tz.transition 1919, 12, :o1, -1577931912, 2906789279, 1200
            tz.transition 1920, 4, :o2, -1568592000, 4844865, 2
            tz.transition 1920, 10, :o1, -1554080400, 58142411, 24
            tz.transition 1921, 4, :o2, -1537142400, 4845593, 2
            tz.transition 1921, 10, :o1, -1522630800, 58151147, 24
            tz.transition 1922, 4, :o2, -1505692800, 4846321, 2
            tz.transition 1922, 9, :o1, -1491181200, 58159883, 24
            tz.transition 1923, 4, :o2, -1474243200, 4847049, 2
            tz.transition 1923, 10, :o1, -1459126800, 58168787, 24
            tz.transition 1962, 4, :o2, -242265600, 4875567, 2
            tz.transition 1962, 9, :o1, -228877200, 58510523, 24
            tz.transition 1963, 5, :o2, -210556800, 4876301, 2
            tz.transition 1963, 9, :o1, -197427600, 58519259, 24
            tz.transition 1964, 5, :o2, -178934400, 4877033, 2
            tz.transition 1964, 9, :o1, -165718800, 58528067, 24
            tz.transition 1965, 5, :o2, -147398400, 4877763, 2
            tz.transition 1965, 9, :o1, -134269200, 58536803, 24
            tz.transition 1966, 4, :o2, -116467200, 4878479, 2
            tz.transition 1966, 9, :o1, -102646800, 58545587, 24
            tz.transition 1967, 5, :o2, -84326400, 4879223, 2
            tz.transition 1967, 9, :o1, -71110800, 58554347, 24
            tz.transition 1968, 5, :o2, -52704000, 4879955, 2
            tz.transition 1968, 9, :o1, -39488400, 58563131, 24
            tz.transition 1969, 5, :o2, -21168000, 4880685, 2
            tz.transition 1969, 9, :o1, -7952400, 58571891, 24
            tz.transition 1970, 5, :o2, 10368000
            tz.transition 1970, 9, :o1, 23583600
            tz.transition 1971, 5, :o2, 41904000
            tz.transition 1971, 9, :o1, 55119600
            tz.transition 1972, 5, :o2, 73526400
            tz.transition 1972, 9, :o1, 86742000
            tz.transition 1973, 5, :o2, 105062400
            tz.transition 1973, 9, :o1, 118278000
            tz.transition 1974, 5, :o2, 136598400
            tz.transition 1974, 9, :o1, 149814000
            tz.transition 1975, 5, :o2, 168134400
            tz.transition 1975, 9, :o1, 181350000
            tz.transition 1976, 5, :o2, 199756800
            tz.transition 1976, 9, :o1, 212972400
            tz.transition 1977, 5, :o2, 231292800
            tz.transition 1977, 8, :o1, 241916400
            tz.transition 1978, 5, :o2, 262828800
            tz.transition 1978, 8, :o1, 273452400
            tz.transition 1983, 4, :o2, 418694400
            tz.transition 1983, 9, :o1, 433810800
            tz.transition 1984, 4, :o2, 450316800
            tz.transition 1984, 9, :o1, 465433200
            tz.transition 1986, 2, :o2, 508896000
            tz.transition 1986, 10, :o1, 529196400
            tz.transition 1987, 3, :o2, 541555200
            tz.transition 1987, 10, :o1, 562633200
            tz.transition 1988, 3, :o2, 574387200
            tz.transition 1988, 10, :o1, 594255600
            tz.transition 1989, 3, :o2, 607305600
            tz.transition 1989, 9, :o1, 623199600
            tz.transition 1990, 4, :o2, 638928000
            tz.transition 1990, 9, :o1, 654649200
            tz.transition 1991, 3, :o2, 670456800
            tz.transition 1991, 9, :o1, 686264400
            tz.transition 1992, 4, :o2, 702684000
            tz.transition 1992, 9, :o1, 717886800
            tz.transition 1993, 3, :o2, 733096800
            tz.transition 1993, 9, :o1, 748904400
            tz.transition 1994, 3, :o2, 765151200
            tz.transition 1994, 9, :o1, 780958800
            tz.transition 1995, 3, :o2, 796687200
            tz.transition 1995, 9, :o1, 812494800
            tz.transition 1996, 3, :o2, 828309600
            tz.transition 1996, 9, :o1, 844117200
            tz.transition 1997, 3, :o2, 859759200
            tz.transition 1997, 9, :o1, 875653200
            tz.transition 1998, 3, :o2, 891208800
            tz.transition 1998, 9, :o1, 907189200
            tz.transition 1999, 3, :o2, 922917600
            tz.transition 1999, 9, :o1, 938725200
            tz.transition 2000, 3, :o2, 954540000
            tz.transition 2000, 9, :o1, 970347600
            tz.transition 2001, 3, :o2, 986076000
            tz.transition 2001, 9, :o1, 1001883600
            tz.transition 2002, 3, :o2, 1017612000
            tz.transition 2002, 9, :o1, 1033419600
            tz.transition 2003, 3, :o2, 1049148000
            tz.transition 2003, 9, :o1, 1064955600
            tz.transition 2004, 3, :o2, 1080770400
            tz.transition 2004, 9, :o1, 1096578000
            tz.transition 2005, 3, :o2, 1112306400
            tz.transition 2005, 9, :o1, 1128114000
            tz.transition 2006, 3, :o2, 1143842400
            tz.transition 2006, 9, :o1, 1158872400
            tz.transition 2007, 3, :o2, 1175205600
            tz.transition 2007, 11, :o1, 1193950800
            tz.transition 2008, 4, :o2, 1207260000
            tz.transition 2008, 10, :o1, 1225486800
            tz.transition 2009, 3, :o2, 1238104800
            tz.transition 2009, 10, :o1, 1256850000
            tz.transition 2010, 4, :o2, 1270159200
            tz.transition 2010, 10, :o1, 1288299600
            tz.transition 2011, 3, :o2, 1301608800
            tz.transition 2011, 10, :o1, 1319749200
            tz.transition 2012, 3, :o2, 1333058400
            tz.transition 2012, 10, :o1, 1351198800
            tz.transition 2013, 3, :o2, 1364508000
            tz.transition 2013, 10, :o1, 1382648400
            tz.transition 2014, 3, :o2, 1395957600
            tz.transition 2014, 10, :o1, 1414702800
            tz.transition 2015, 3, :o2, 1427407200
            tz.transition 2015, 10, :o1, 1446152400
            tz.transition 2016, 3, :o2, 1458856800
            tz.transition 2016, 10, :o1, 1477602000
            tz.transition 2017, 3, :o2, 1490911200
            tz.transition 2017, 10, :o1, 1509051600
            tz.transition 2018, 3, :o2, 1522360800
            tz.transition 2018, 10, :o1, 1540501200
            tz.transition 2019, 3, :o2, 1553810400
            tz.transition 2019, 10, :o1, 1571950800
            tz.transition 2020, 3, :o2, 1585260000
            tz.transition 2020, 10, :o1, 1604005200
            tz.transition 2021, 3, :o2, 1616709600
            tz.transition 2021, 10, :o1, 1635454800
            tz.transition 2022, 3, :o2, 1648159200
            tz.transition 2022, 10, :o1, 1666904400
            tz.transition 2023, 3, :o2, 1680213600
            tz.transition 2023, 10, :o1, 1698354000
            tz.transition 2024, 3, :o2, 1711663200
            tz.transition 2024, 10, :o1, 1729803600
            tz.transition 2025, 3, :o2, 1743112800
            tz.transition 2025, 10, :o1, 1761858000
            tz.transition 2026, 3, :o2, 1774562400
            tz.transition 2026, 10, :o1, 1793307600
            tz.transition 2027, 3, :o2, 1806012000
            tz.transition 2027, 10, :o1, 1824757200
            tz.transition 2028, 3, :o2, 1838066400
            tz.transition 2028, 10, :o1, 1856206800
            tz.transition 2029, 3, :o2, 1869516000
            tz.transition 2029, 10, :o1, 1887656400
            tz.transition 2030, 3, :o2, 1900965600
            tz.transition 2030, 10, :o1, 1919106000
            tz.transition 2031, 3, :o2, 1932415200
            tz.transition 2031, 10, :o1, 1951160400
            tz.transition 2032, 3, :o2, 1963864800
            tz.transition 2032, 10, :o1, 1982610000
            tz.transition 2033, 3, :o2, 1995314400
            tz.transition 2033, 10, :o1, 2014059600
            tz.transition 2034, 3, :o2, 2027368800
            tz.transition 2034, 10, :o1, 2045509200
            tz.transition 2035, 3, :o2, 2058818400
            tz.transition 2035, 10, :o1, 2076958800
            tz.transition 2036, 3, :o2, 2090268000
            tz.transition 2036, 10, :o1, 2109013200
            tz.transition 2037, 3, :o2, 2121717600
            tz.transition 2037, 10, :o1, 2140462800
            tz.transition 2038, 3, :o2, 2153167200, 29586101, 12
            tz.transition 2038, 10, :o1, 2171912400, 19725803, 8
            tz.transition 2039, 3, :o2, 2184616800, 29590469, 12
            tz.transition 2039, 10, :o1, 2203362000, 19728715, 8
            tz.transition 2040, 3, :o2, 2216671200, 29594921, 12
            tz.transition 2040, 10, :o1, 2234811600, 19731627, 8
            tz.transition 2041, 3, :o2, 2248120800, 29599289, 12
            tz.transition 2041, 10, :o1, 2266261200, 19734539, 8
            tz.transition 2042, 3, :o2, 2279570400, 29603657, 12
            tz.transition 2042, 10, :o1, 2298315600, 19737507, 8
            tz.transition 2043, 3, :o2, 2311020000, 29608025, 12
            tz.transition 2043, 10, :o1, 2329765200, 19740419, 8
            tz.transition 2044, 3, :o2, 2342469600, 29612393, 12
            tz.transition 2044, 10, :o1, 2361214800, 19743331, 8
            tz.transition 2045, 3, :o2, 2374524000, 29616845, 12
            tz.transition 2045, 10, :o1, 2392664400, 19746243, 8
            tz.transition 2046, 3, :o2, 2405973600, 29621213, 12
            tz.transition 2046, 10, :o1, 2424114000, 19749155, 8
            tz.transition 2047, 3, :o2, 2437423200, 29625581, 12
            tz.transition 2047, 10, :o1, 2455563600, 19752067, 8
            tz.transition 2048, 3, :o2, 2468872800, 29629949, 12
            tz.transition 2048, 10, :o1, 2487618000, 19755035, 8
            tz.transition 2049, 3, :o2, 2500322400, 29634317, 12
            tz.transition 2049, 10, :o1, 2519067600, 19757947, 8
            tz.transition 2050, 3, :o2, 2531772000, 29638685, 12
            tz.transition 2050, 10, :o1, 2550517200, 19760859, 8
            tz.transition 2051, 3, :o2, 2563826400, 29643137, 12
            tz.transition 2051, 10, :o1, 2581966800, 19763771, 8
            tz.transition 2052, 3, :o2, 2595276000, 29647505, 12
            tz.transition 2052, 10, :o1, 2613416400, 19766683, 8
            tz.transition 2053, 3, :o2, 2626725600, 29651873, 12
            tz.transition 2053, 10, :o1, 2645470800, 19769651, 8
            tz.transition 2054, 3, :o2, 2658175200, 29656241, 12
            tz.transition 2054, 10, :o1, 2676920400, 19772563, 8
            tz.transition 2055, 3, :o2, 2689624800, 29660609, 12
            tz.transition 2055, 10, :o1, 2708370000, 19775475, 8
            tz.transition 2056, 3, :o2, 2721679200, 29665061, 12
            tz.transition 2056, 10, :o1, 2739819600, 19778387, 8
            tz.transition 2057, 3, :o2, 2753128800, 29669429, 12
            tz.transition 2057, 10, :o1, 2771269200, 19781299, 8
            tz.transition 2058, 3, :o2, 2784578400, 29673797, 12
            tz.transition 2058, 10, :o1, 2802718800, 19784211, 8
            tz.transition 2059, 3, :o2, 2816028000, 29678165, 12
            tz.transition 2059, 10, :o1, 2834773200, 19787179, 8
            tz.transition 2060, 3, :o2, 2847477600, 29682533, 12
            tz.transition 2060, 10, :o1, 2866222800, 19790091, 8
            tz.transition 2061, 3, :o2, 2878927200, 29686901, 12
            tz.transition 2061, 10, :o1, 2897672400, 19793003, 8
            tz.transition 2062, 3, :o2, 2910981600, 29691353, 12
            tz.transition 2062, 10, :o1, 2929122000, 19795915, 8
            tz.transition 2063, 3, :o2, 2942431200, 29695721, 12
            tz.transition 2063, 10, :o1, 2960571600, 19798827, 8
            tz.transition 2064, 3, :o2, 2973880800, 29700089, 12
            tz.transition 2064, 10, :o1, 2992626000, 19801795, 8
            tz.transition 2065, 3, :o2, 3005330400, 29704457, 12
            tz.transition 2065, 10, :o1, 3024075600, 19804707, 8
            tz.transition 2066, 3, :o2, 3036780000, 29708825, 12
            tz.transition 2066, 10, :o1, 3055525200, 19807619, 8
            tz.transition 2067, 3, :o2, 3068229600, 29713193, 12
            tz.transition 2067, 10, :o1, 3086974800, 19810531, 8
            tz.transition 2068, 3, :o2, 3100284000, 29717645, 12
            tz.transition 2068, 10, :o1, 3118424400, 19813443, 8
          end
        end
      end
    end
  end
end
