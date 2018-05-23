# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Argentina
          module Catamarca
            include TimezoneDefinition
            
            timezone 'America/Argentina/Catamarca' do |tz|
              tz.offset :o0, -15788, 0, :LMT
              tz.offset :o1, -15408, 0, :CMT
              tz.offset :o2, -14400, 0, :'-04'
              tz.offset :o3, -14400, 3600, :'-03'
              tz.offset :o4, -10800, 0, :'-03'
              tz.offset :o5, -10800, 3600, :'-02'
              
              tz.transition 1894, 10, :o1, -2372096212, 52123665947, 21600
              tz.transition 1920, 5, :o2, -1567453392, 1453467407, 600
              tz.transition 1930, 12, :o3, -1233432000, 7278935, 3
              tz.transition 1931, 4, :o2, -1222981200, 19411461, 8
              tz.transition 1931, 10, :o3, -1205956800, 7279889, 3
              tz.transition 1932, 3, :o2, -1194037200, 19414141, 8
              tz.transition 1932, 11, :o3, -1172865600, 7281038, 3
              tz.transition 1933, 3, :o2, -1162501200, 19417061, 8
              tz.transition 1933, 11, :o3, -1141329600, 7282133, 3
              tz.transition 1934, 3, :o2, -1130965200, 19419981, 8
              tz.transition 1934, 11, :o3, -1109793600, 7283228, 3
              tz.transition 1935, 3, :o2, -1099429200, 19422901, 8
              tz.transition 1935, 11, :o3, -1078257600, 7284323, 3
              tz.transition 1936, 3, :o2, -1067806800, 19425829, 8
              tz.transition 1936, 11, :o3, -1046635200, 7285421, 3
              tz.transition 1937, 3, :o2, -1036270800, 19428749, 8
              tz.transition 1937, 11, :o3, -1015099200, 7286516, 3
              tz.transition 1938, 3, :o2, -1004734800, 19431669, 8
              tz.transition 1938, 11, :o3, -983563200, 7287611, 3
              tz.transition 1939, 3, :o2, -973198800, 19434589, 8
              tz.transition 1939, 11, :o3, -952027200, 7288706, 3
              tz.transition 1940, 3, :o2, -941576400, 19437517, 8
              tz.transition 1940, 7, :o3, -931032000, 7289435, 3
              tz.transition 1941, 6, :o2, -900882000, 19441285, 8
              tz.transition 1941, 10, :o3, -890337600, 7290848, 3
              tz.transition 1943, 8, :o2, -833749200, 19447501, 8
              tz.transition 1943, 10, :o3, -827265600, 7293038, 3
              tz.transition 1946, 3, :o2, -752274000, 19455045, 8
              tz.transition 1946, 10, :o3, -733780800, 7296284, 3
              tz.transition 1963, 10, :o2, -197326800, 19506429, 8
              tz.transition 1963, 12, :o3, -190843200, 7315136, 3
              tz.transition 1964, 3, :o2, -184194000, 19507645, 8
              tz.transition 1964, 10, :o3, -164491200, 7316051, 3
              tz.transition 1965, 3, :o2, -152658000, 19510565, 8
              tz.transition 1965, 10, :o3, -132955200, 7317146, 3
              tz.transition 1966, 3, :o2, -121122000, 19513485, 8
              tz.transition 1966, 10, :o3, -101419200, 7318241, 3
              tz.transition 1967, 4, :o2, -86821200, 19516661, 8
              tz.transition 1967, 10, :o3, -71092800, 7319294, 3
              tz.transition 1968, 4, :o2, -54766800, 19519629, 8
              tz.transition 1968, 10, :o3, -39038400, 7320407, 3
              tz.transition 1969, 4, :o2, -23317200, 19522541, 8
              tz.transition 1969, 10, :o4, -7588800, 7321499, 3
              tz.transition 1974, 1, :o5, 128142000
              tz.transition 1974, 5, :o4, 136605600
              tz.transition 1988, 12, :o5, 596948400
              tz.transition 1989, 3, :o4, 605066400
              tz.transition 1989, 10, :o5, 624423600
              tz.transition 1990, 3, :o4, 636516000
              tz.transition 1990, 10, :o5, 656478000
              tz.transition 1991, 3, :o2, 667965600
              tz.transition 1991, 10, :o5, 687931200
              tz.transition 1992, 3, :o4, 699415200
              tz.transition 1992, 10, :o5, 719377200
              tz.transition 1993, 3, :o4, 731469600
              tz.transition 1999, 10, :o3, 938919600
              tz.transition 2000, 3, :o4, 952052400
              tz.transition 2004, 6, :o2, 1086058800
              tz.transition 2004, 6, :o4, 1087704000
              tz.transition 2007, 12, :o5, 1198983600
              tz.transition 2008, 3, :o4, 1205632800
            end
          end
        end
      end
    end
  end
end
