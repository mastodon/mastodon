# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Beirut
          include TimezoneDefinition
          
          timezone 'Asia/Beirut' do |tz|
            tz.offset :o0, 8520, 0, :LMT
            tz.offset :o1, 7200, 0, :EET
            tz.offset :o2, 7200, 3600, :EEST
            
            tz.transition 1879, 12, :o1, -2840149320, 1733555089, 720
            tz.transition 1920, 3, :o2, -1570413600, 29068937, 12
            tz.transition 1920, 10, :o1, -1552186800, 19380979, 8
            tz.transition 1921, 4, :o2, -1538359200, 29073389, 12
            tz.transition 1921, 10, :o1, -1522551600, 19383723, 8
            tz.transition 1922, 3, :o2, -1507514400, 29077673, 12
            tz.transition 1922, 10, :o1, -1490583600, 19386683, 8
            tz.transition 1923, 4, :o2, -1473645600, 29082377, 12
            tz.transition 1923, 9, :o1, -1460948400, 19389427, 8
            tz.transition 1957, 4, :o2, -399866400, 29231513, 12
            tz.transition 1957, 9, :o1, -386650800, 19488899, 8
            tz.transition 1958, 4, :o2, -368330400, 29235893, 12
            tz.transition 1958, 9, :o1, -355114800, 19491819, 8
            tz.transition 1959, 4, :o2, -336794400, 29240273, 12
            tz.transition 1959, 9, :o1, -323578800, 19494739, 8
            tz.transition 1960, 4, :o2, -305172000, 29244665, 12
            tz.transition 1960, 9, :o1, -291956400, 19497667, 8
            tz.transition 1961, 4, :o2, -273636000, 29249045, 12
            tz.transition 1961, 9, :o1, -260420400, 19500587, 8
            tz.transition 1972, 6, :o2, 78012000
            tz.transition 1972, 9, :o1, 86734800
            tz.transition 1973, 4, :o2, 105055200
            tz.transition 1973, 9, :o1, 118270800
            tz.transition 1974, 4, :o2, 136591200
            tz.transition 1974, 9, :o1, 149806800
            tz.transition 1975, 4, :o2, 168127200
            tz.transition 1975, 9, :o1, 181342800
            tz.transition 1976, 4, :o2, 199749600
            tz.transition 1976, 9, :o1, 212965200
            tz.transition 1977, 4, :o2, 231285600
            tz.transition 1977, 9, :o1, 244501200
            tz.transition 1978, 4, :o2, 262735200
            tz.transition 1978, 9, :o1, 275950800
            tz.transition 1984, 4, :o2, 452210400
            tz.transition 1984, 10, :o1, 466722000
            tz.transition 1985, 4, :o2, 483746400
            tz.transition 1985, 10, :o1, 498258000
            tz.transition 1986, 4, :o2, 515282400
            tz.transition 1986, 10, :o1, 529794000
            tz.transition 1987, 4, :o2, 546818400
            tz.transition 1987, 10, :o1, 561330000
            tz.transition 1988, 5, :o2, 581119200
            tz.transition 1988, 10, :o1, 592952400
            tz.transition 1989, 5, :o2, 610754400
            tz.transition 1989, 10, :o1, 624488400
            tz.transition 1990, 4, :o2, 641512800
            tz.transition 1990, 10, :o1, 656024400
            tz.transition 1991, 4, :o2, 673048800
            tz.transition 1991, 10, :o1, 687560400
            tz.transition 1992, 4, :o2, 704671200
            tz.transition 1992, 10, :o1, 718146000
            tz.transition 1993, 3, :o2, 733269600
            tz.transition 1993, 9, :o1, 748990800
            tz.transition 1994, 3, :o2, 764719200
            tz.transition 1994, 9, :o1, 780440400
            tz.transition 1995, 3, :o2, 796168800
            tz.transition 1995, 9, :o1, 811890000
            tz.transition 1996, 3, :o2, 828223200
            tz.transition 1996, 9, :o1, 843944400
            tz.transition 1997, 3, :o2, 859672800
            tz.transition 1997, 9, :o1, 875394000
            tz.transition 1998, 3, :o2, 891122400
            tz.transition 1998, 9, :o1, 906843600
            tz.transition 1999, 3, :o2, 922572000
            tz.transition 1999, 10, :o1, 941317200
            tz.transition 2000, 3, :o2, 954021600
            tz.transition 2000, 10, :o1, 972766800
            tz.transition 2001, 3, :o2, 985471200
            tz.transition 2001, 10, :o1, 1004216400
            tz.transition 2002, 3, :o2, 1017525600
            tz.transition 2002, 10, :o1, 1035666000
            tz.transition 2003, 3, :o2, 1048975200
            tz.transition 2003, 10, :o1, 1067115600
            tz.transition 2004, 3, :o2, 1080424800
            tz.transition 2004, 10, :o1, 1099170000
            tz.transition 2005, 3, :o2, 1111874400
            tz.transition 2005, 10, :o1, 1130619600
            tz.transition 2006, 3, :o2, 1143324000
            tz.transition 2006, 10, :o1, 1162069200
            tz.transition 2007, 3, :o2, 1174773600
            tz.transition 2007, 10, :o1, 1193518800
            tz.transition 2008, 3, :o2, 1206828000
            tz.transition 2008, 10, :o1, 1224968400
            tz.transition 2009, 3, :o2, 1238277600
            tz.transition 2009, 10, :o1, 1256418000
            tz.transition 2010, 3, :o2, 1269727200
            tz.transition 2010, 10, :o1, 1288472400
            tz.transition 2011, 3, :o2, 1301176800
            tz.transition 2011, 10, :o1, 1319922000
            tz.transition 2012, 3, :o2, 1332626400
            tz.transition 2012, 10, :o1, 1351371600
            tz.transition 2013, 3, :o2, 1364680800
            tz.transition 2013, 10, :o1, 1382821200
            tz.transition 2014, 3, :o2, 1396130400
            tz.transition 2014, 10, :o1, 1414270800
            tz.transition 2015, 3, :o2, 1427580000
            tz.transition 2015, 10, :o1, 1445720400
            tz.transition 2016, 3, :o2, 1459029600
            tz.transition 2016, 10, :o1, 1477774800
            tz.transition 2017, 3, :o2, 1490479200
            tz.transition 2017, 10, :o1, 1509224400
            tz.transition 2018, 3, :o2, 1521928800
            tz.transition 2018, 10, :o1, 1540674000
            tz.transition 2019, 3, :o2, 1553983200
            tz.transition 2019, 10, :o1, 1572123600
            tz.transition 2020, 3, :o2, 1585432800
            tz.transition 2020, 10, :o1, 1603573200
            tz.transition 2021, 3, :o2, 1616882400
            tz.transition 2021, 10, :o1, 1635627600
            tz.transition 2022, 3, :o2, 1648332000
            tz.transition 2022, 10, :o1, 1667077200
            tz.transition 2023, 3, :o2, 1679781600
            tz.transition 2023, 10, :o1, 1698526800
            tz.transition 2024, 3, :o2, 1711836000
            tz.transition 2024, 10, :o1, 1729976400
            tz.transition 2025, 3, :o2, 1743285600
            tz.transition 2025, 10, :o1, 1761426000
            tz.transition 2026, 3, :o2, 1774735200
            tz.transition 2026, 10, :o1, 1792875600
            tz.transition 2027, 3, :o2, 1806184800
            tz.transition 2027, 10, :o1, 1824930000
            tz.transition 2028, 3, :o2, 1837634400
            tz.transition 2028, 10, :o1, 1856379600
            tz.transition 2029, 3, :o2, 1869084000
            tz.transition 2029, 10, :o1, 1887829200
            tz.transition 2030, 3, :o2, 1901138400
            tz.transition 2030, 10, :o1, 1919278800
            tz.transition 2031, 3, :o2, 1932588000
            tz.transition 2031, 10, :o1, 1950728400
            tz.transition 2032, 3, :o2, 1964037600
            tz.transition 2032, 10, :o1, 1982782800
            tz.transition 2033, 3, :o2, 1995487200
            tz.transition 2033, 10, :o1, 2014232400
            tz.transition 2034, 3, :o2, 2026936800
            tz.transition 2034, 10, :o1, 2045682000
            tz.transition 2035, 3, :o2, 2058386400
            tz.transition 2035, 10, :o1, 2077131600
            tz.transition 2036, 3, :o2, 2090440800
            tz.transition 2036, 10, :o1, 2108581200
            tz.transition 2037, 3, :o2, 2121890400
            tz.transition 2037, 10, :o1, 2140030800
            tz.transition 2038, 3, :o2, 2153340000, 29586125, 12
            tz.transition 2038, 10, :o1, 2172085200, 19725819, 8
            tz.transition 2039, 3, :o2, 2184789600, 29590493, 12
            tz.transition 2039, 10, :o1, 2203534800, 19728731, 8
            tz.transition 2040, 3, :o2, 2216239200, 29594861, 12
            tz.transition 2040, 10, :o1, 2234984400, 19731643, 8
            tz.transition 2041, 3, :o2, 2248293600, 29599313, 12
            tz.transition 2041, 10, :o1, 2266434000, 19734555, 8
            tz.transition 2042, 3, :o2, 2279743200, 29603681, 12
            tz.transition 2042, 10, :o1, 2297883600, 19737467, 8
            tz.transition 2043, 3, :o2, 2311192800, 29608049, 12
            tz.transition 2043, 10, :o1, 2329333200, 19740379, 8
            tz.transition 2044, 3, :o2, 2342642400, 29612417, 12
            tz.transition 2044, 10, :o1, 2361387600, 19743347, 8
            tz.transition 2045, 3, :o2, 2374092000, 29616785, 12
            tz.transition 2045, 10, :o1, 2392837200, 19746259, 8
            tz.transition 2046, 3, :o2, 2405541600, 29621153, 12
            tz.transition 2046, 10, :o1, 2424286800, 19749171, 8
            tz.transition 2047, 3, :o2, 2437596000, 29625605, 12
            tz.transition 2047, 10, :o1, 2455736400, 19752083, 8
            tz.transition 2048, 3, :o2, 2469045600, 29629973, 12
            tz.transition 2048, 10, :o1, 2487186000, 19754995, 8
            tz.transition 2049, 3, :o2, 2500495200, 29634341, 12
            tz.transition 2049, 10, :o1, 2519240400, 19757963, 8
            tz.transition 2050, 3, :o2, 2531944800, 29638709, 12
            tz.transition 2050, 10, :o1, 2550690000, 19760875, 8
            tz.transition 2051, 3, :o2, 2563394400, 29643077, 12
            tz.transition 2051, 10, :o1, 2582139600, 19763787, 8
            tz.transition 2052, 3, :o2, 2595448800, 29647529, 12
            tz.transition 2052, 10, :o1, 2613589200, 19766699, 8
            tz.transition 2053, 3, :o2, 2626898400, 29651897, 12
            tz.transition 2053, 10, :o1, 2645038800, 19769611, 8
            tz.transition 2054, 3, :o2, 2658348000, 29656265, 12
            tz.transition 2054, 10, :o1, 2676488400, 19772523, 8
            tz.transition 2055, 3, :o2, 2689797600, 29660633, 12
            tz.transition 2055, 10, :o1, 2708542800, 19775491, 8
            tz.transition 2056, 3, :o2, 2721247200, 29665001, 12
            tz.transition 2056, 10, :o1, 2739992400, 19778403, 8
            tz.transition 2057, 3, :o2, 2752696800, 29669369, 12
            tz.transition 2057, 10, :o1, 2771442000, 19781315, 8
            tz.transition 2058, 3, :o2, 2784751200, 29673821, 12
            tz.transition 2058, 10, :o1, 2802891600, 19784227, 8
            tz.transition 2059, 3, :o2, 2816200800, 29678189, 12
            tz.transition 2059, 10, :o1, 2834341200, 19787139, 8
            tz.transition 2060, 3, :o2, 2847650400, 29682557, 12
            tz.transition 2060, 10, :o1, 2866395600, 19790107, 8
            tz.transition 2061, 3, :o2, 2879100000, 29686925, 12
            tz.transition 2061, 10, :o1, 2897845200, 19793019, 8
            tz.transition 2062, 3, :o2, 2910549600, 29691293, 12
            tz.transition 2062, 10, :o1, 2929294800, 19795931, 8
            tz.transition 2063, 3, :o2, 2941999200, 29695661, 12
            tz.transition 2063, 10, :o1, 2960744400, 19798843, 8
            tz.transition 2064, 3, :o2, 2974053600, 29700113, 12
            tz.transition 2064, 10, :o1, 2992194000, 19801755, 8
            tz.transition 2065, 3, :o2, 3005503200, 29704481, 12
            tz.transition 2065, 10, :o1, 3023643600, 19804667, 8
            tz.transition 2066, 3, :o2, 3036952800, 29708849, 12
            tz.transition 2066, 10, :o1, 3055698000, 19807635, 8
            tz.transition 2067, 3, :o2, 3068402400, 29713217, 12
            tz.transition 2067, 10, :o1, 3087147600, 19810547, 8
            tz.transition 2068, 3, :o2, 3099852000, 29717585, 12
            tz.transition 2068, 10, :o1, 3118597200, 19813459, 8
          end
        end
      end
    end
  end
end
