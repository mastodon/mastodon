# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Pangnirtung
          include TimezoneDefinition
          
          timezone 'America/Pangnirtung' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, -14400, 0, :AST
            tz.offset :o2, -14400, 3600, :AWT
            tz.offset :o3, -14400, 3600, :APT
            tz.offset :o4, -14400, 7200, :ADDT
            tz.offset :o5, -14400, 3600, :ADT
            tz.offset :o6, -18000, 3600, :EDT
            tz.offset :o7, -18000, 0, :EST
            tz.offset :o8, -21600, 0, :CST
            tz.offset :o9, -21600, 3600, :CDT
            
            tz.transition 1921, 1, :o1, -1546300800, 4845381, 2
            tz.transition 1942, 2, :o2, -880221600, 9721599, 4
            tz.transition 1945, 8, :o3, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765399600, 58361489, 24
            tz.transition 1965, 4, :o4, -147902400, 7316627, 3
            tz.transition 1965, 10, :o1, -131572800, 7317194, 3
            tz.transition 1980, 4, :o5, 325663200
            tz.transition 1980, 10, :o1, 341384400
            tz.transition 1981, 4, :o5, 357112800
            tz.transition 1981, 10, :o1, 372834000
            tz.transition 1982, 4, :o5, 388562400
            tz.transition 1982, 10, :o1, 404888400
            tz.transition 1983, 4, :o5, 420012000
            tz.transition 1983, 10, :o1, 436338000
            tz.transition 1984, 4, :o5, 452066400
            tz.transition 1984, 10, :o1, 467787600
            tz.transition 1985, 4, :o5, 483516000
            tz.transition 1985, 10, :o1, 499237200
            tz.transition 1986, 4, :o5, 514965600
            tz.transition 1986, 10, :o1, 530686800
            tz.transition 1987, 4, :o5, 544600800
            tz.transition 1987, 10, :o1, 562136400
            tz.transition 1988, 4, :o5, 576050400
            tz.transition 1988, 10, :o1, 594190800
            tz.transition 1989, 4, :o5, 607500000
            tz.transition 1989, 10, :o1, 625640400
            tz.transition 1990, 4, :o5, 638949600
            tz.transition 1990, 10, :o1, 657090000
            tz.transition 1991, 4, :o5, 671004000
            tz.transition 1991, 10, :o1, 688539600
            tz.transition 1992, 4, :o5, 702453600
            tz.transition 1992, 10, :o1, 719989200
            tz.transition 1993, 4, :o5, 733903200
            tz.transition 1993, 10, :o1, 752043600
            tz.transition 1994, 4, :o5, 765352800
            tz.transition 1994, 10, :o1, 783493200
            tz.transition 1995, 4, :o6, 796802400
            tz.transition 1995, 10, :o7, 814946400
            tz.transition 1996, 4, :o6, 828860400
            tz.transition 1996, 10, :o7, 846396000
            tz.transition 1997, 4, :o6, 860310000
            tz.transition 1997, 10, :o7, 877845600
            tz.transition 1998, 4, :o6, 891759600
            tz.transition 1998, 10, :o7, 909295200
            tz.transition 1999, 4, :o6, 923209200
            tz.transition 1999, 10, :o8, 941349600
            tz.transition 2000, 4, :o9, 954662400
            tz.transition 2000, 10, :o7, 972802800
            tz.transition 2001, 4, :o6, 986108400
            tz.transition 2001, 10, :o7, 1004248800
            tz.transition 2002, 4, :o6, 1018162800
            tz.transition 2002, 10, :o7, 1035698400
            tz.transition 2003, 4, :o6, 1049612400
            tz.transition 2003, 10, :o7, 1067148000
            tz.transition 2004, 4, :o6, 1081062000
            tz.transition 2004, 10, :o7, 1099202400
            tz.transition 2005, 4, :o6, 1112511600
            tz.transition 2005, 10, :o7, 1130652000
            tz.transition 2006, 4, :o6, 1143961200
            tz.transition 2006, 10, :o7, 1162101600
            tz.transition 2007, 3, :o6, 1173596400
            tz.transition 2007, 11, :o7, 1194156000
            tz.transition 2008, 3, :o6, 1205046000
            tz.transition 2008, 11, :o7, 1225605600
            tz.transition 2009, 3, :o6, 1236495600
            tz.transition 2009, 11, :o7, 1257055200
            tz.transition 2010, 3, :o6, 1268550000
            tz.transition 2010, 11, :o7, 1289109600
            tz.transition 2011, 3, :o6, 1299999600
            tz.transition 2011, 11, :o7, 1320559200
            tz.transition 2012, 3, :o6, 1331449200
            tz.transition 2012, 11, :o7, 1352008800
            tz.transition 2013, 3, :o6, 1362898800
            tz.transition 2013, 11, :o7, 1383458400
            tz.transition 2014, 3, :o6, 1394348400
            tz.transition 2014, 11, :o7, 1414908000
            tz.transition 2015, 3, :o6, 1425798000
            tz.transition 2015, 11, :o7, 1446357600
            tz.transition 2016, 3, :o6, 1457852400
            tz.transition 2016, 11, :o7, 1478412000
            tz.transition 2017, 3, :o6, 1489302000
            tz.transition 2017, 11, :o7, 1509861600
            tz.transition 2018, 3, :o6, 1520751600
            tz.transition 2018, 11, :o7, 1541311200
            tz.transition 2019, 3, :o6, 1552201200
            tz.transition 2019, 11, :o7, 1572760800
            tz.transition 2020, 3, :o6, 1583650800
            tz.transition 2020, 11, :o7, 1604210400
            tz.transition 2021, 3, :o6, 1615705200
            tz.transition 2021, 11, :o7, 1636264800
            tz.transition 2022, 3, :o6, 1647154800
            tz.transition 2022, 11, :o7, 1667714400
            tz.transition 2023, 3, :o6, 1678604400
            tz.transition 2023, 11, :o7, 1699164000
            tz.transition 2024, 3, :o6, 1710054000
            tz.transition 2024, 11, :o7, 1730613600
            tz.transition 2025, 3, :o6, 1741503600
            tz.transition 2025, 11, :o7, 1762063200
            tz.transition 2026, 3, :o6, 1772953200
            tz.transition 2026, 11, :o7, 1793512800
            tz.transition 2027, 3, :o6, 1805007600
            tz.transition 2027, 11, :o7, 1825567200
            tz.transition 2028, 3, :o6, 1836457200
            tz.transition 2028, 11, :o7, 1857016800
            tz.transition 2029, 3, :o6, 1867906800
            tz.transition 2029, 11, :o7, 1888466400
            tz.transition 2030, 3, :o6, 1899356400
            tz.transition 2030, 11, :o7, 1919916000
            tz.transition 2031, 3, :o6, 1930806000
            tz.transition 2031, 11, :o7, 1951365600
            tz.transition 2032, 3, :o6, 1962860400
            tz.transition 2032, 11, :o7, 1983420000
            tz.transition 2033, 3, :o6, 1994310000
            tz.transition 2033, 11, :o7, 2014869600
            tz.transition 2034, 3, :o6, 2025759600
            tz.transition 2034, 11, :o7, 2046319200
            tz.transition 2035, 3, :o6, 2057209200
            tz.transition 2035, 11, :o7, 2077768800
            tz.transition 2036, 3, :o6, 2088658800
            tz.transition 2036, 11, :o7, 2109218400
            tz.transition 2037, 3, :o6, 2120108400
            tz.transition 2037, 11, :o7, 2140668000
            tz.transition 2038, 3, :o6, 2152162800, 59171923, 24
            tz.transition 2038, 11, :o7, 2172722400, 9862939, 4
            tz.transition 2039, 3, :o6, 2183612400, 59180659, 24
            tz.transition 2039, 11, :o7, 2204172000, 9864395, 4
            tz.transition 2040, 3, :o6, 2215062000, 59189395, 24
            tz.transition 2040, 11, :o7, 2235621600, 9865851, 4
            tz.transition 2041, 3, :o6, 2246511600, 59198131, 24
            tz.transition 2041, 11, :o7, 2267071200, 9867307, 4
            tz.transition 2042, 3, :o6, 2277961200, 59206867, 24
            tz.transition 2042, 11, :o7, 2298520800, 9868763, 4
            tz.transition 2043, 3, :o6, 2309410800, 59215603, 24
            tz.transition 2043, 11, :o7, 2329970400, 9870219, 4
            tz.transition 2044, 3, :o6, 2341465200, 59224507, 24
            tz.transition 2044, 11, :o7, 2362024800, 9871703, 4
            tz.transition 2045, 3, :o6, 2372914800, 59233243, 24
            tz.transition 2045, 11, :o7, 2393474400, 9873159, 4
            tz.transition 2046, 3, :o6, 2404364400, 59241979, 24
            tz.transition 2046, 11, :o7, 2424924000, 9874615, 4
            tz.transition 2047, 3, :o6, 2435814000, 59250715, 24
            tz.transition 2047, 11, :o7, 2456373600, 9876071, 4
            tz.transition 2048, 3, :o6, 2467263600, 59259451, 24
            tz.transition 2048, 11, :o7, 2487823200, 9877527, 4
            tz.transition 2049, 3, :o6, 2499318000, 59268355, 24
            tz.transition 2049, 11, :o7, 2519877600, 9879011, 4
            tz.transition 2050, 3, :o6, 2530767600, 59277091, 24
            tz.transition 2050, 11, :o7, 2551327200, 9880467, 4
            tz.transition 2051, 3, :o6, 2562217200, 59285827, 24
            tz.transition 2051, 11, :o7, 2582776800, 9881923, 4
            tz.transition 2052, 3, :o6, 2593666800, 59294563, 24
            tz.transition 2052, 11, :o7, 2614226400, 9883379, 4
            tz.transition 2053, 3, :o6, 2625116400, 59303299, 24
            tz.transition 2053, 11, :o7, 2645676000, 9884835, 4
            tz.transition 2054, 3, :o6, 2656566000, 59312035, 24
            tz.transition 2054, 11, :o7, 2677125600, 9886291, 4
            tz.transition 2055, 3, :o6, 2688620400, 59320939, 24
            tz.transition 2055, 11, :o7, 2709180000, 9887775, 4
            tz.transition 2056, 3, :o6, 2720070000, 59329675, 24
            tz.transition 2056, 11, :o7, 2740629600, 9889231, 4
            tz.transition 2057, 3, :o6, 2751519600, 59338411, 24
            tz.transition 2057, 11, :o7, 2772079200, 9890687, 4
            tz.transition 2058, 3, :o6, 2782969200, 59347147, 24
            tz.transition 2058, 11, :o7, 2803528800, 9892143, 4
            tz.transition 2059, 3, :o6, 2814418800, 59355883, 24
            tz.transition 2059, 11, :o7, 2834978400, 9893599, 4
            tz.transition 2060, 3, :o6, 2846473200, 59364787, 24
            tz.transition 2060, 11, :o7, 2867032800, 9895083, 4
            tz.transition 2061, 3, :o6, 2877922800, 59373523, 24
            tz.transition 2061, 11, :o7, 2898482400, 9896539, 4
            tz.transition 2062, 3, :o6, 2909372400, 59382259, 24
            tz.transition 2062, 11, :o7, 2929932000, 9897995, 4
            tz.transition 2063, 3, :o6, 2940822000, 59390995, 24
            tz.transition 2063, 11, :o7, 2961381600, 9899451, 4
            tz.transition 2064, 3, :o6, 2972271600, 59399731, 24
            tz.transition 2064, 11, :o7, 2992831200, 9900907, 4
            tz.transition 2065, 3, :o6, 3003721200, 59408467, 24
            tz.transition 2065, 11, :o7, 3024280800, 9902363, 4
            tz.transition 2066, 3, :o6, 3035775600, 59417371, 24
            tz.transition 2066, 11, :o7, 3056335200, 9903847, 4
            tz.transition 2067, 3, :o6, 3067225200, 59426107, 24
            tz.transition 2067, 11, :o7, 3087784800, 9905303, 4
            tz.transition 2068, 3, :o6, 3098674800, 59434843, 24
            tz.transition 2068, 11, :o7, 3119234400, 9906759, 4
          end
        end
      end
    end
  end
end
