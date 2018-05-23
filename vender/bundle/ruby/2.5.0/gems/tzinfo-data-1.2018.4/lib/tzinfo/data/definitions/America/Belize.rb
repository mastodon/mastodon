# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Belize
          include TimezoneDefinition
          
          timezone 'America/Belize' do |tz|
            tz.offset :o0, -21168, 0, :LMT
            tz.offset :o1, -21600, 0, :CST
            tz.offset :o2, -21600, 1800, :'-0530'
            tz.offset :o3, -21600, 3600, :CDT
            
            tz.transition 1912, 4, :o1, -1822500432, 483898749, 200
            tz.transition 1918, 10, :o2, -1616954400, 9687491, 4
            tz.transition 1919, 2, :o1, -1606069800, 116255939, 48
            tz.transition 1919, 10, :o2, -1585504800, 9688947, 4
            tz.transition 1920, 2, :o1, -1574015400, 116273747, 48
            tz.transition 1920, 10, :o2, -1554055200, 9690403, 4
            tz.transition 1921, 2, :o1, -1542565800, 116291219, 48
            tz.transition 1921, 10, :o2, -1522605600, 9691859, 4
            tz.transition 1922, 2, :o1, -1511116200, 116308691, 48
            tz.transition 1922, 10, :o2, -1490551200, 9693343, 4
            tz.transition 1923, 2, :o1, -1479666600, 116326163, 48
            tz.transition 1923, 10, :o2, -1459101600, 9694799, 4
            tz.transition 1924, 2, :o1, -1448217000, 116343635, 48
            tz.transition 1924, 10, :o2, -1427652000, 9696255, 4
            tz.transition 1925, 2, :o1, -1416162600, 116361443, 48
            tz.transition 1925, 10, :o2, -1396202400, 9697711, 4
            tz.transition 1926, 2, :o1, -1384713000, 116378915, 48
            tz.transition 1926, 10, :o2, -1364752800, 9699167, 4
            tz.transition 1927, 2, :o1, -1353263400, 116396387, 48
            tz.transition 1927, 10, :o2, -1333303200, 9700623, 4
            tz.transition 1928, 2, :o1, -1321813800, 116413859, 48
            tz.transition 1928, 10, :o2, -1301248800, 9702107, 4
            tz.transition 1929, 2, :o1, -1290364200, 116431331, 48
            tz.transition 1929, 10, :o2, -1269799200, 9703563, 4
            tz.transition 1930, 2, :o1, -1258914600, 116448803, 48
            tz.transition 1930, 10, :o2, -1238349600, 9705019, 4
            tz.transition 1931, 2, :o1, -1226860200, 116466611, 48
            tz.transition 1931, 10, :o2, -1206900000, 9706475, 4
            tz.transition 1932, 2, :o1, -1195410600, 116484083, 48
            tz.transition 1932, 10, :o2, -1175450400, 9707931, 4
            tz.transition 1933, 2, :o1, -1163961000, 116501555, 48
            tz.transition 1933, 10, :o2, -1143396000, 9709415, 4
            tz.transition 1934, 2, :o1, -1132511400, 116519027, 48
            tz.transition 1934, 10, :o2, -1111946400, 9710871, 4
            tz.transition 1935, 2, :o1, -1101061800, 116536499, 48
            tz.transition 1935, 10, :o2, -1080496800, 9712327, 4
            tz.transition 1936, 2, :o1, -1069612200, 116553971, 48
            tz.transition 1936, 10, :o2, -1049047200, 9713783, 4
            tz.transition 1937, 2, :o1, -1037557800, 116571779, 48
            tz.transition 1937, 10, :o2, -1017597600, 9715239, 4
            tz.transition 1938, 2, :o1, -1006108200, 116589251, 48
            tz.transition 1938, 10, :o2, -986148000, 9716695, 4
            tz.transition 1939, 2, :o1, -974658600, 116606723, 48
            tz.transition 1939, 10, :o2, -954093600, 9718179, 4
            tz.transition 1940, 2, :o1, -943209000, 116624195, 48
            tz.transition 1940, 10, :o2, -922644000, 9719635, 4
            tz.transition 1941, 2, :o1, -911759400, 116641667, 48
            tz.transition 1941, 10, :o2, -891194400, 9721091, 4
            tz.transition 1942, 2, :o1, -879705000, 116659475, 48
            tz.transition 1942, 10, :o2, -859744800, 9722547, 4
            tz.transition 1943, 2, :o1, -848255400, 116676947, 48
            tz.transition 1973, 12, :o3, 123919200
            tz.transition 1974, 2, :o1, 129618000
            tz.transition 1982, 12, :o3, 409039200
            tz.transition 1983, 2, :o1, 413874000
          end
        end
      end
    end
  end
end
