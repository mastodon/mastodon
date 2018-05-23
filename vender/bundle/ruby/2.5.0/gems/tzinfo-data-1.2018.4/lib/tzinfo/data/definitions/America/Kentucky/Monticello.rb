# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Kentucky
          module Monticello
            include TimezoneDefinition
            
            timezone 'America/Kentucky/Monticello' do |tz|
              tz.offset :o0, -20364, 0, :LMT
              tz.offset :o1, -21600, 0, :CST
              tz.offset :o2, -21600, 3600, :CDT
              tz.offset :o3, -21600, 3600, :CWT
              tz.offset :o4, -21600, 3600, :CPT
              tz.offset :o5, -18000, 0, :EST
              tz.offset :o6, -18000, 3600, :EDT
              
              tz.transition 1883, 11, :o1, -2717647200, 9636533, 4
              tz.transition 1918, 3, :o2, -1633276800, 14530103, 6
              tz.transition 1918, 10, :o1, -1615136400, 58125451, 24
              tz.transition 1919, 3, :o2, -1601827200, 14532287, 6
              tz.transition 1919, 10, :o1, -1583686800, 58134187, 24
              tz.transition 1942, 2, :o3, -880214400, 14582399, 6
              tz.transition 1945, 8, :o4, -769395600, 58360379, 24
              tz.transition 1945, 9, :o1, -765392400, 58361491, 24
              tz.transition 1968, 4, :o2, -52934400, 14639849, 6
              tz.transition 1968, 10, :o1, -37213200, 58563763, 24
              tz.transition 1969, 4, :o2, -21484800, 14642033, 6
              tz.transition 1969, 10, :o1, -5763600, 58572499, 24
              tz.transition 1970, 4, :o2, 9964800
              tz.transition 1970, 10, :o1, 25686000
              tz.transition 1971, 4, :o2, 41414400
              tz.transition 1971, 10, :o1, 57740400
              tz.transition 1972, 4, :o2, 73468800
              tz.transition 1972, 10, :o1, 89190000
              tz.transition 1973, 4, :o2, 104918400
              tz.transition 1973, 10, :o1, 120639600
              tz.transition 1974, 1, :o2, 126691200
              tz.transition 1974, 10, :o1, 152089200
              tz.transition 1975, 2, :o2, 162374400
              tz.transition 1975, 10, :o1, 183538800
              tz.transition 1976, 4, :o2, 199267200
              tz.transition 1976, 10, :o1, 215593200
              tz.transition 1977, 4, :o2, 230716800
              tz.transition 1977, 10, :o1, 247042800
              tz.transition 1978, 4, :o2, 262771200
              tz.transition 1978, 10, :o1, 278492400
              tz.transition 1979, 4, :o2, 294220800
              tz.transition 1979, 10, :o1, 309942000
              tz.transition 1980, 4, :o2, 325670400
              tz.transition 1980, 10, :o1, 341391600
              tz.transition 1981, 4, :o2, 357120000
              tz.transition 1981, 10, :o1, 372841200
              tz.transition 1982, 4, :o2, 388569600
              tz.transition 1982, 10, :o1, 404895600
              tz.transition 1983, 4, :o2, 420019200
              tz.transition 1983, 10, :o1, 436345200
              tz.transition 1984, 4, :o2, 452073600
              tz.transition 1984, 10, :o1, 467794800
              tz.transition 1985, 4, :o2, 483523200
              tz.transition 1985, 10, :o1, 499244400
              tz.transition 1986, 4, :o2, 514972800
              tz.transition 1986, 10, :o1, 530694000
              tz.transition 1987, 4, :o2, 544608000
              tz.transition 1987, 10, :o1, 562143600
              tz.transition 1988, 4, :o2, 576057600
              tz.transition 1988, 10, :o1, 594198000
              tz.transition 1989, 4, :o2, 607507200
              tz.transition 1989, 10, :o1, 625647600
              tz.transition 1990, 4, :o2, 638956800
              tz.transition 1990, 10, :o1, 657097200
              tz.transition 1991, 4, :o2, 671011200
              tz.transition 1991, 10, :o1, 688546800
              tz.transition 1992, 4, :o2, 702460800
              tz.transition 1992, 10, :o1, 719996400
              tz.transition 1993, 4, :o2, 733910400
              tz.transition 1993, 10, :o1, 752050800
              tz.transition 1994, 4, :o2, 765360000
              tz.transition 1994, 10, :o1, 783500400
              tz.transition 1995, 4, :o2, 796809600
              tz.transition 1995, 10, :o1, 814950000
              tz.transition 1996, 4, :o2, 828864000
              tz.transition 1996, 10, :o1, 846399600
              tz.transition 1997, 4, :o2, 860313600
              tz.transition 1997, 10, :o1, 877849200
              tz.transition 1998, 4, :o2, 891763200
              tz.transition 1998, 10, :o1, 909298800
              tz.transition 1999, 4, :o2, 923212800
              tz.transition 1999, 10, :o1, 941353200
              tz.transition 2000, 4, :o2, 954662400
              tz.transition 2000, 10, :o5, 972802800
              tz.transition 2001, 4, :o6, 986108400
              tz.transition 2001, 10, :o5, 1004248800
              tz.transition 2002, 4, :o6, 1018162800
              tz.transition 2002, 10, :o5, 1035698400
              tz.transition 2003, 4, :o6, 1049612400
              tz.transition 2003, 10, :o5, 1067148000
              tz.transition 2004, 4, :o6, 1081062000
              tz.transition 2004, 10, :o5, 1099202400
              tz.transition 2005, 4, :o6, 1112511600
              tz.transition 2005, 10, :o5, 1130652000
              tz.transition 2006, 4, :o6, 1143961200
              tz.transition 2006, 10, :o5, 1162101600
              tz.transition 2007, 3, :o6, 1173596400
              tz.transition 2007, 11, :o5, 1194156000
              tz.transition 2008, 3, :o6, 1205046000
              tz.transition 2008, 11, :o5, 1225605600
              tz.transition 2009, 3, :o6, 1236495600
              tz.transition 2009, 11, :o5, 1257055200
              tz.transition 2010, 3, :o6, 1268550000
              tz.transition 2010, 11, :o5, 1289109600
              tz.transition 2011, 3, :o6, 1299999600
              tz.transition 2011, 11, :o5, 1320559200
              tz.transition 2012, 3, :o6, 1331449200
              tz.transition 2012, 11, :o5, 1352008800
              tz.transition 2013, 3, :o6, 1362898800
              tz.transition 2013, 11, :o5, 1383458400
              tz.transition 2014, 3, :o6, 1394348400
              tz.transition 2014, 11, :o5, 1414908000
              tz.transition 2015, 3, :o6, 1425798000
              tz.transition 2015, 11, :o5, 1446357600
              tz.transition 2016, 3, :o6, 1457852400
              tz.transition 2016, 11, :o5, 1478412000
              tz.transition 2017, 3, :o6, 1489302000
              tz.transition 2017, 11, :o5, 1509861600
              tz.transition 2018, 3, :o6, 1520751600
              tz.transition 2018, 11, :o5, 1541311200
              tz.transition 2019, 3, :o6, 1552201200
              tz.transition 2019, 11, :o5, 1572760800
              tz.transition 2020, 3, :o6, 1583650800
              tz.transition 2020, 11, :o5, 1604210400
              tz.transition 2021, 3, :o6, 1615705200
              tz.transition 2021, 11, :o5, 1636264800
              tz.transition 2022, 3, :o6, 1647154800
              tz.transition 2022, 11, :o5, 1667714400
              tz.transition 2023, 3, :o6, 1678604400
              tz.transition 2023, 11, :o5, 1699164000
              tz.transition 2024, 3, :o6, 1710054000
              tz.transition 2024, 11, :o5, 1730613600
              tz.transition 2025, 3, :o6, 1741503600
              tz.transition 2025, 11, :o5, 1762063200
              tz.transition 2026, 3, :o6, 1772953200
              tz.transition 2026, 11, :o5, 1793512800
              tz.transition 2027, 3, :o6, 1805007600
              tz.transition 2027, 11, :o5, 1825567200
              tz.transition 2028, 3, :o6, 1836457200
              tz.transition 2028, 11, :o5, 1857016800
              tz.transition 2029, 3, :o6, 1867906800
              tz.transition 2029, 11, :o5, 1888466400
              tz.transition 2030, 3, :o6, 1899356400
              tz.transition 2030, 11, :o5, 1919916000
              tz.transition 2031, 3, :o6, 1930806000
              tz.transition 2031, 11, :o5, 1951365600
              tz.transition 2032, 3, :o6, 1962860400
              tz.transition 2032, 11, :o5, 1983420000
              tz.transition 2033, 3, :o6, 1994310000
              tz.transition 2033, 11, :o5, 2014869600
              tz.transition 2034, 3, :o6, 2025759600
              tz.transition 2034, 11, :o5, 2046319200
              tz.transition 2035, 3, :o6, 2057209200
              tz.transition 2035, 11, :o5, 2077768800
              tz.transition 2036, 3, :o6, 2088658800
              tz.transition 2036, 11, :o5, 2109218400
              tz.transition 2037, 3, :o6, 2120108400
              tz.transition 2037, 11, :o5, 2140668000
              tz.transition 2038, 3, :o6, 2152162800, 59171923, 24
              tz.transition 2038, 11, :o5, 2172722400, 9862939, 4
              tz.transition 2039, 3, :o6, 2183612400, 59180659, 24
              tz.transition 2039, 11, :o5, 2204172000, 9864395, 4
              tz.transition 2040, 3, :o6, 2215062000, 59189395, 24
              tz.transition 2040, 11, :o5, 2235621600, 9865851, 4
              tz.transition 2041, 3, :o6, 2246511600, 59198131, 24
              tz.transition 2041, 11, :o5, 2267071200, 9867307, 4
              tz.transition 2042, 3, :o6, 2277961200, 59206867, 24
              tz.transition 2042, 11, :o5, 2298520800, 9868763, 4
              tz.transition 2043, 3, :o6, 2309410800, 59215603, 24
              tz.transition 2043, 11, :o5, 2329970400, 9870219, 4
              tz.transition 2044, 3, :o6, 2341465200, 59224507, 24
              tz.transition 2044, 11, :o5, 2362024800, 9871703, 4
              tz.transition 2045, 3, :o6, 2372914800, 59233243, 24
              tz.transition 2045, 11, :o5, 2393474400, 9873159, 4
              tz.transition 2046, 3, :o6, 2404364400, 59241979, 24
              tz.transition 2046, 11, :o5, 2424924000, 9874615, 4
              tz.transition 2047, 3, :o6, 2435814000, 59250715, 24
              tz.transition 2047, 11, :o5, 2456373600, 9876071, 4
              tz.transition 2048, 3, :o6, 2467263600, 59259451, 24
              tz.transition 2048, 11, :o5, 2487823200, 9877527, 4
              tz.transition 2049, 3, :o6, 2499318000, 59268355, 24
              tz.transition 2049, 11, :o5, 2519877600, 9879011, 4
              tz.transition 2050, 3, :o6, 2530767600, 59277091, 24
              tz.transition 2050, 11, :o5, 2551327200, 9880467, 4
              tz.transition 2051, 3, :o6, 2562217200, 59285827, 24
              tz.transition 2051, 11, :o5, 2582776800, 9881923, 4
              tz.transition 2052, 3, :o6, 2593666800, 59294563, 24
              tz.transition 2052, 11, :o5, 2614226400, 9883379, 4
              tz.transition 2053, 3, :o6, 2625116400, 59303299, 24
              tz.transition 2053, 11, :o5, 2645676000, 9884835, 4
              tz.transition 2054, 3, :o6, 2656566000, 59312035, 24
              tz.transition 2054, 11, :o5, 2677125600, 9886291, 4
              tz.transition 2055, 3, :o6, 2688620400, 59320939, 24
              tz.transition 2055, 11, :o5, 2709180000, 9887775, 4
              tz.transition 2056, 3, :o6, 2720070000, 59329675, 24
              tz.transition 2056, 11, :o5, 2740629600, 9889231, 4
              tz.transition 2057, 3, :o6, 2751519600, 59338411, 24
              tz.transition 2057, 11, :o5, 2772079200, 9890687, 4
              tz.transition 2058, 3, :o6, 2782969200, 59347147, 24
              tz.transition 2058, 11, :o5, 2803528800, 9892143, 4
              tz.transition 2059, 3, :o6, 2814418800, 59355883, 24
              tz.transition 2059, 11, :o5, 2834978400, 9893599, 4
              tz.transition 2060, 3, :o6, 2846473200, 59364787, 24
              tz.transition 2060, 11, :o5, 2867032800, 9895083, 4
              tz.transition 2061, 3, :o6, 2877922800, 59373523, 24
              tz.transition 2061, 11, :o5, 2898482400, 9896539, 4
              tz.transition 2062, 3, :o6, 2909372400, 59382259, 24
              tz.transition 2062, 11, :o5, 2929932000, 9897995, 4
              tz.transition 2063, 3, :o6, 2940822000, 59390995, 24
              tz.transition 2063, 11, :o5, 2961381600, 9899451, 4
              tz.transition 2064, 3, :o6, 2972271600, 59399731, 24
              tz.transition 2064, 11, :o5, 2992831200, 9900907, 4
              tz.transition 2065, 3, :o6, 3003721200, 59408467, 24
              tz.transition 2065, 11, :o5, 3024280800, 9902363, 4
              tz.transition 2066, 3, :o6, 3035775600, 59417371, 24
              tz.transition 2066, 11, :o5, 3056335200, 9903847, 4
              tz.transition 2067, 3, :o6, 3067225200, 59426107, 24
              tz.transition 2067, 11, :o5, 3087784800, 9905303, 4
              tz.transition 2068, 3, :o6, 3098674800, 59434843, 24
              tz.transition 2068, 11, :o5, 3119234400, 9906759, 4
            end
          end
        end
      end
    end
  end
end
