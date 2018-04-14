# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module St_Johns
          include TimezoneDefinition
          
          timezone 'America/St_Johns' do |tz|
            tz.offset :o0, -12652, 0, :LMT
            tz.offset :o1, -12652, 0, :NST
            tz.offset :o2, -12652, 3600, :NDT
            tz.offset :o3, -12600, 0, :NST
            tz.offset :o4, -12600, 3600, :NDT
            tz.offset :o5, -12600, 3600, :NWT
            tz.offset :o6, -12600, 3600, :NPT
            tz.offset :o7, -12600, 7200, :NDDT
            
            tz.transition 1884, 1, :o1, -2713897748, 52038215563, 21600
            tz.transition 1917, 4, :o2, -1664130548, 52300657363, 21600
            tz.transition 1917, 9, :o1, -1650137348, 52304155663, 21600
            tz.transition 1918, 4, :o2, -1632076148, 52308670963, 21600
            tz.transition 1918, 10, :o1, -1615145348, 52312903663, 21600
            tz.transition 1919, 5, :o2, -1598650148, 52317027463, 21600
            tz.transition 1919, 8, :o1, -1590100148, 52319164963, 21600
            tz.transition 1920, 5, :o2, -1567286948, 52324868263, 21600
            tz.transition 1920, 11, :o1, -1551565748, 52328798563, 21600
            tz.transition 1921, 5, :o2, -1535837348, 52332730663, 21600
            tz.transition 1921, 10, :o1, -1520116148, 52336660963, 21600
            tz.transition 1922, 5, :o2, -1503782948, 52340744263, 21600
            tz.transition 1922, 10, :o1, -1488666548, 52344523363, 21600
            tz.transition 1923, 5, :o2, -1472333348, 52348606663, 21600
            tz.transition 1923, 10, :o1, -1457216948, 52352385763, 21600
            tz.transition 1924, 5, :o2, -1440883748, 52356469063, 21600
            tz.transition 1924, 10, :o1, -1425767348, 52360248163, 21600
            tz.transition 1925, 5, :o2, -1409434148, 52364331463, 21600
            tz.transition 1925, 10, :o1, -1394317748, 52368110563, 21600
            tz.transition 1926, 5, :o2, -1377984548, 52372193863, 21600
            tz.transition 1926, 11, :o1, -1362263348, 52376124163, 21600
            tz.transition 1927, 5, :o2, -1346534948, 52380056263, 21600
            tz.transition 1927, 10, :o1, -1330813748, 52383986563, 21600
            tz.transition 1928, 5, :o2, -1314480548, 52388069863, 21600
            tz.transition 1928, 10, :o1, -1299364148, 52391848963, 21600
            tz.transition 1929, 5, :o2, -1283030948, 52395932263, 21600
            tz.transition 1929, 10, :o1, -1267914548, 52399711363, 21600
            tz.transition 1930, 5, :o2, -1251581348, 52403794663, 21600
            tz.transition 1930, 10, :o1, -1236464948, 52407573763, 21600
            tz.transition 1931, 5, :o2, -1220131748, 52411657063, 21600
            tz.transition 1931, 10, :o1, -1205015348, 52415436163, 21600
            tz.transition 1932, 5, :o2, -1188682148, 52419519463, 21600
            tz.transition 1932, 10, :o1, -1172960948, 52423449763, 21600
            tz.transition 1933, 5, :o2, -1156627748, 52427533063, 21600
            tz.transition 1933, 10, :o1, -1141511348, 52431312163, 21600
            tz.transition 1934, 5, :o2, -1125178148, 52435395463, 21600
            tz.transition 1934, 10, :o1, -1110061748, 52439174563, 21600
            tz.transition 1935, 3, :o3, -1096921748, 52442459563, 21600
            tz.transition 1935, 5, :o4, -1093728600, 116540573, 48
            tz.transition 1935, 10, :o3, -1078612200, 38849657, 16
            tz.transition 1936, 5, :o4, -1061670600, 116558383, 48
            tz.transition 1936, 10, :o3, -1048973400, 116565437, 48
            tz.transition 1937, 5, :o4, -1030221000, 116575855, 48
            tz.transition 1937, 10, :o3, -1017523800, 116582909, 48
            tz.transition 1938, 5, :o4, -998771400, 116593327, 48
            tz.transition 1938, 10, :o3, -986074200, 116600381, 48
            tz.transition 1939, 5, :o4, -966717000, 116611135, 48
            tz.transition 1939, 10, :o3, -954624600, 116617853, 48
            tz.transition 1940, 5, :o4, -935267400, 116628607, 48
            tz.transition 1940, 10, :o3, -922570200, 116635661, 48
            tz.transition 1941, 5, :o4, -903817800, 116646079, 48
            tz.transition 1941, 10, :o3, -891120600, 116653133, 48
            tz.transition 1942, 5, :o5, -872368200, 116663551, 48
            tz.transition 1945, 8, :o6, -769395600, 58360379, 24
            tz.transition 1945, 9, :o3, -765401400, 38907659, 16
            tz.transition 1946, 5, :o4, -746044200, 116733731, 48
            tz.transition 1946, 10, :o3, -733347000, 38913595, 16
            tz.transition 1947, 5, :o4, -714594600, 116751203, 48
            tz.transition 1947, 10, :o3, -701897400, 38919419, 16
            tz.transition 1948, 5, :o4, -683145000, 116768675, 48
            tz.transition 1948, 10, :o3, -670447800, 38925243, 16
            tz.transition 1949, 5, :o4, -651695400, 116786147, 48
            tz.transition 1949, 10, :o3, -638998200, 38931067, 16
            tz.transition 1950, 5, :o4, -619641000, 116803955, 48
            tz.transition 1950, 10, :o3, -606943800, 38937003, 16
            tz.transition 1951, 4, :o4, -589401000, 116820755, 48
            tz.transition 1951, 9, :o3, -576099000, 38942715, 16
            tz.transition 1952, 4, :o4, -557951400, 116838227, 48
            tz.transition 1952, 9, :o3, -544649400, 38948539, 16
            tz.transition 1953, 4, :o4, -526501800, 116855699, 48
            tz.transition 1953, 9, :o3, -513199800, 38954363, 16
            tz.transition 1954, 4, :o4, -495052200, 116873171, 48
            tz.transition 1954, 9, :o3, -481750200, 38960187, 16
            tz.transition 1955, 4, :o4, -463602600, 116890643, 48
            tz.transition 1955, 9, :o3, -450300600, 38966011, 16
            tz.transition 1956, 4, :o4, -431548200, 116908451, 48
            tz.transition 1956, 9, :o3, -418246200, 38971947, 16
            tz.transition 1957, 4, :o4, -400098600, 116925923, 48
            tz.transition 1957, 9, :o3, -386796600, 38977771, 16
            tz.transition 1958, 4, :o4, -368649000, 116943395, 48
            tz.transition 1958, 9, :o3, -355347000, 38983595, 16
            tz.transition 1959, 4, :o4, -337199400, 116960867, 48
            tz.transition 1959, 9, :o3, -323897400, 38989419, 16
            tz.transition 1960, 4, :o4, -305749800, 116978339, 48
            tz.transition 1960, 10, :o3, -289423800, 38995803, 16
            tz.transition 1961, 4, :o4, -273695400, 116996147, 48
            tz.transition 1961, 10, :o3, -257974200, 39001627, 16
            tz.transition 1962, 4, :o4, -242245800, 117013619, 48
            tz.transition 1962, 10, :o3, -226524600, 39007451, 16
            tz.transition 1963, 4, :o4, -210796200, 117031091, 48
            tz.transition 1963, 10, :o3, -195075000, 39013275, 16
            tz.transition 1964, 4, :o4, -179346600, 117048563, 48
            tz.transition 1964, 10, :o3, -163625400, 39019099, 16
            tz.transition 1965, 4, :o4, -147897000, 117066035, 48
            tz.transition 1965, 10, :o3, -131571000, 39025035, 16
            tz.transition 1966, 4, :o4, -116447400, 117083507, 48
            tz.transition 1966, 10, :o3, -100121400, 39030859, 16
            tz.transition 1967, 4, :o4, -84393000, 117101315, 48
            tz.transition 1967, 10, :o3, -68671800, 39036683, 16
            tz.transition 1968, 4, :o4, -52943400, 117118787, 48
            tz.transition 1968, 10, :o3, -37222200, 39042507, 16
            tz.transition 1969, 4, :o4, -21493800, 117136259, 48
            tz.transition 1969, 10, :o3, -5772600, 39048331, 16
            tz.transition 1970, 4, :o4, 9955800
            tz.transition 1970, 10, :o3, 25677000
            tz.transition 1971, 4, :o4, 41405400
            tz.transition 1971, 10, :o3, 57731400
            tz.transition 1972, 4, :o4, 73459800
            tz.transition 1972, 10, :o3, 89181000
            tz.transition 1973, 4, :o4, 104909400
            tz.transition 1973, 10, :o3, 120630600
            tz.transition 1974, 4, :o4, 136359000
            tz.transition 1974, 10, :o3, 152080200
            tz.transition 1975, 4, :o4, 167808600
            tz.transition 1975, 10, :o3, 183529800
            tz.transition 1976, 4, :o4, 199258200
            tz.transition 1976, 10, :o3, 215584200
            tz.transition 1977, 4, :o4, 230707800
            tz.transition 1977, 10, :o3, 247033800
            tz.transition 1978, 4, :o4, 262762200
            tz.transition 1978, 10, :o3, 278483400
            tz.transition 1979, 4, :o4, 294211800
            tz.transition 1979, 10, :o3, 309933000
            tz.transition 1980, 4, :o4, 325661400
            tz.transition 1980, 10, :o3, 341382600
            tz.transition 1981, 4, :o4, 357111000
            tz.transition 1981, 10, :o3, 372832200
            tz.transition 1982, 4, :o4, 388560600
            tz.transition 1982, 10, :o3, 404886600
            tz.transition 1983, 4, :o4, 420010200
            tz.transition 1983, 10, :o3, 436336200
            tz.transition 1984, 4, :o4, 452064600
            tz.transition 1984, 10, :o3, 467785800
            tz.transition 1985, 4, :o4, 483514200
            tz.transition 1985, 10, :o3, 499235400
            tz.transition 1986, 4, :o4, 514963800
            tz.transition 1986, 10, :o3, 530685000
            tz.transition 1987, 4, :o4, 544591860
            tz.transition 1987, 10, :o3, 562127460
            tz.transition 1988, 4, :o7, 576041460
            tz.transition 1988, 10, :o3, 594178260
            tz.transition 1989, 4, :o4, 607491060
            tz.transition 1989, 10, :o3, 625631460
            tz.transition 1990, 4, :o4, 638940660
            tz.transition 1990, 10, :o3, 657081060
            tz.transition 1991, 4, :o4, 670995060
            tz.transition 1991, 10, :o3, 688530660
            tz.transition 1992, 4, :o4, 702444660
            tz.transition 1992, 10, :o3, 719980260
            tz.transition 1993, 4, :o4, 733894260
            tz.transition 1993, 10, :o3, 752034660
            tz.transition 1994, 4, :o4, 765343860
            tz.transition 1994, 10, :o3, 783484260
            tz.transition 1995, 4, :o4, 796793460
            tz.transition 1995, 10, :o3, 814933860
            tz.transition 1996, 4, :o4, 828847860
            tz.transition 1996, 10, :o3, 846383460
            tz.transition 1997, 4, :o4, 860297460
            tz.transition 1997, 10, :o3, 877833060
            tz.transition 1998, 4, :o4, 891747060
            tz.transition 1998, 10, :o3, 909282660
            tz.transition 1999, 4, :o4, 923196660
            tz.transition 1999, 10, :o3, 941337060
            tz.transition 2000, 4, :o4, 954646260
            tz.transition 2000, 10, :o3, 972786660
            tz.transition 2001, 4, :o4, 986095860
            tz.transition 2001, 10, :o3, 1004236260
            tz.transition 2002, 4, :o4, 1018150260
            tz.transition 2002, 10, :o3, 1035685860
            tz.transition 2003, 4, :o4, 1049599860
            tz.transition 2003, 10, :o3, 1067135460
            tz.transition 2004, 4, :o4, 1081049460
            tz.transition 2004, 10, :o3, 1099189860
            tz.transition 2005, 4, :o4, 1112499060
            tz.transition 2005, 10, :o3, 1130639460
            tz.transition 2006, 4, :o4, 1143948660
            tz.transition 2006, 10, :o3, 1162089060
            tz.transition 2007, 3, :o4, 1173583860
            tz.transition 2007, 11, :o3, 1194143460
            tz.transition 2008, 3, :o4, 1205033460
            tz.transition 2008, 11, :o3, 1225593060
            tz.transition 2009, 3, :o4, 1236483060
            tz.transition 2009, 11, :o3, 1257042660
            tz.transition 2010, 3, :o4, 1268537460
            tz.transition 2010, 11, :o3, 1289097060
            tz.transition 2011, 3, :o4, 1299987060
            tz.transition 2011, 11, :o3, 1320553800
            tz.transition 2012, 3, :o4, 1331443800
            tz.transition 2012, 11, :o3, 1352003400
            tz.transition 2013, 3, :o4, 1362893400
            tz.transition 2013, 11, :o3, 1383453000
            tz.transition 2014, 3, :o4, 1394343000
            tz.transition 2014, 11, :o3, 1414902600
            tz.transition 2015, 3, :o4, 1425792600
            tz.transition 2015, 11, :o3, 1446352200
            tz.transition 2016, 3, :o4, 1457847000
            tz.transition 2016, 11, :o3, 1478406600
            tz.transition 2017, 3, :o4, 1489296600
            tz.transition 2017, 11, :o3, 1509856200
            tz.transition 2018, 3, :o4, 1520746200
            tz.transition 2018, 11, :o3, 1541305800
            tz.transition 2019, 3, :o4, 1552195800
            tz.transition 2019, 11, :o3, 1572755400
            tz.transition 2020, 3, :o4, 1583645400
            tz.transition 2020, 11, :o3, 1604205000
            tz.transition 2021, 3, :o4, 1615699800
            tz.transition 2021, 11, :o3, 1636259400
            tz.transition 2022, 3, :o4, 1647149400
            tz.transition 2022, 11, :o3, 1667709000
            tz.transition 2023, 3, :o4, 1678599000
            tz.transition 2023, 11, :o3, 1699158600
            tz.transition 2024, 3, :o4, 1710048600
            tz.transition 2024, 11, :o3, 1730608200
            tz.transition 2025, 3, :o4, 1741498200
            tz.transition 2025, 11, :o3, 1762057800
            tz.transition 2026, 3, :o4, 1772947800
            tz.transition 2026, 11, :o3, 1793507400
            tz.transition 2027, 3, :o4, 1805002200
            tz.transition 2027, 11, :o3, 1825561800
            tz.transition 2028, 3, :o4, 1836451800
            tz.transition 2028, 11, :o3, 1857011400
            tz.transition 2029, 3, :o4, 1867901400
            tz.transition 2029, 11, :o3, 1888461000
            tz.transition 2030, 3, :o4, 1899351000
            tz.transition 2030, 11, :o3, 1919910600
            tz.transition 2031, 3, :o4, 1930800600
            tz.transition 2031, 11, :o3, 1951360200
            tz.transition 2032, 3, :o4, 1962855000
            tz.transition 2032, 11, :o3, 1983414600
            tz.transition 2033, 3, :o4, 1994304600
            tz.transition 2033, 11, :o3, 2014864200
            tz.transition 2034, 3, :o4, 2025754200
            tz.transition 2034, 11, :o3, 2046313800
            tz.transition 2035, 3, :o4, 2057203800
            tz.transition 2035, 11, :o3, 2077763400
            tz.transition 2036, 3, :o4, 2088653400
            tz.transition 2036, 11, :o3, 2109213000
            tz.transition 2037, 3, :o4, 2120103000
            tz.transition 2037, 11, :o3, 2140662600
            tz.transition 2038, 3, :o4, 2152157400, 118343843, 48
            tz.transition 2038, 11, :o3, 2172717000, 39451755, 16
            tz.transition 2039, 3, :o4, 2183607000, 118361315, 48
            tz.transition 2039, 11, :o3, 2204166600, 39457579, 16
            tz.transition 2040, 3, :o4, 2215056600, 118378787, 48
            tz.transition 2040, 11, :o3, 2235616200, 39463403, 16
            tz.transition 2041, 3, :o4, 2246506200, 118396259, 48
            tz.transition 2041, 11, :o3, 2267065800, 39469227, 16
            tz.transition 2042, 3, :o4, 2277955800, 118413731, 48
            tz.transition 2042, 11, :o3, 2298515400, 39475051, 16
            tz.transition 2043, 3, :o4, 2309405400, 118431203, 48
            tz.transition 2043, 11, :o3, 2329965000, 39480875, 16
            tz.transition 2044, 3, :o4, 2341459800, 118449011, 48
            tz.transition 2044, 11, :o3, 2362019400, 39486811, 16
            tz.transition 2045, 3, :o4, 2372909400, 118466483, 48
            tz.transition 2045, 11, :o3, 2393469000, 39492635, 16
            tz.transition 2046, 3, :o4, 2404359000, 118483955, 48
            tz.transition 2046, 11, :o3, 2424918600, 39498459, 16
            tz.transition 2047, 3, :o4, 2435808600, 118501427, 48
            tz.transition 2047, 11, :o3, 2456368200, 39504283, 16
            tz.transition 2048, 3, :o4, 2467258200, 118518899, 48
            tz.transition 2048, 11, :o3, 2487817800, 39510107, 16
            tz.transition 2049, 3, :o4, 2499312600, 118536707, 48
            tz.transition 2049, 11, :o3, 2519872200, 39516043, 16
            tz.transition 2050, 3, :o4, 2530762200, 118554179, 48
            tz.transition 2050, 11, :o3, 2551321800, 39521867, 16
            tz.transition 2051, 3, :o4, 2562211800, 118571651, 48
            tz.transition 2051, 11, :o3, 2582771400, 39527691, 16
            tz.transition 2052, 3, :o4, 2593661400, 118589123, 48
            tz.transition 2052, 11, :o3, 2614221000, 39533515, 16
            tz.transition 2053, 3, :o4, 2625111000, 118606595, 48
            tz.transition 2053, 11, :o3, 2645670600, 39539339, 16
            tz.transition 2054, 3, :o4, 2656560600, 118624067, 48
            tz.transition 2054, 11, :o3, 2677120200, 39545163, 16
            tz.transition 2055, 3, :o4, 2688615000, 118641875, 48
            tz.transition 2055, 11, :o3, 2709174600, 39551099, 16
            tz.transition 2056, 3, :o4, 2720064600, 118659347, 48
            tz.transition 2056, 11, :o3, 2740624200, 39556923, 16
            tz.transition 2057, 3, :o4, 2751514200, 118676819, 48
            tz.transition 2057, 11, :o3, 2772073800, 39562747, 16
            tz.transition 2058, 3, :o4, 2782963800, 118694291, 48
            tz.transition 2058, 11, :o3, 2803523400, 39568571, 16
            tz.transition 2059, 3, :o4, 2814413400, 118711763, 48
            tz.transition 2059, 11, :o3, 2834973000, 39574395, 16
            tz.transition 2060, 3, :o4, 2846467800, 118729571, 48
            tz.transition 2060, 11, :o3, 2867027400, 39580331, 16
            tz.transition 2061, 3, :o4, 2877917400, 118747043, 48
            tz.transition 2061, 11, :o3, 2898477000, 39586155, 16
            tz.transition 2062, 3, :o4, 2909367000, 118764515, 48
            tz.transition 2062, 11, :o3, 2929926600, 39591979, 16
            tz.transition 2063, 3, :o4, 2940816600, 118781987, 48
            tz.transition 2063, 11, :o3, 2961376200, 39597803, 16
            tz.transition 2064, 3, :o4, 2972266200, 118799459, 48
            tz.transition 2064, 11, :o3, 2992825800, 39603627, 16
            tz.transition 2065, 3, :o4, 3003715800, 118816931, 48
            tz.transition 2065, 11, :o3, 3024275400, 39609451, 16
            tz.transition 2066, 3, :o4, 3035770200, 118834739, 48
            tz.transition 2066, 11, :o3, 3056329800, 39615387, 16
            tz.transition 2067, 3, :o4, 3067219800, 118852211, 48
            tz.transition 2067, 11, :o3, 3087779400, 39621211, 16
            tz.transition 2068, 3, :o4, 3098669400, 118869683, 48
            tz.transition 2068, 11, :o3, 3119229000, 39627035, 16
          end
        end
      end
    end
  end
end
