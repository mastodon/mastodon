# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Accra
          include TimezoneDefinition
          
          timezone 'Africa/Accra' do |tz|
            tz.offset :o0, -52, 0, :LMT
            tz.offset :o1, 0, 0, :GMT
            tz.offset :o2, 0, 1200, :'+0020'
            
            tz.transition 1918, 1, :o1, -1640995148, 52306441213, 21600
            tz.transition 1920, 9, :o2, -1556841600, 4845137, 2
            tz.transition 1920, 12, :o1, -1546388400, 174433643, 72
            tz.transition 1921, 9, :o2, -1525305600, 4845867, 2
            tz.transition 1921, 12, :o1, -1514852400, 174459923, 72
            tz.transition 1922, 9, :o2, -1493769600, 4846597, 2
            tz.transition 1922, 12, :o1, -1483316400, 174486203, 72
            tz.transition 1923, 9, :o2, -1462233600, 4847327, 2
            tz.transition 1923, 12, :o1, -1451780400, 174512483, 72
            tz.transition 1924, 9, :o2, -1430611200, 4848059, 2
            tz.transition 1924, 12, :o1, -1420158000, 174538835, 72
            tz.transition 1925, 9, :o2, -1399075200, 4848789, 2
            tz.transition 1925, 12, :o1, -1388622000, 174565115, 72
            tz.transition 1926, 9, :o2, -1367539200, 4849519, 2
            tz.transition 1926, 12, :o1, -1357086000, 174591395, 72
            tz.transition 1927, 9, :o2, -1336003200, 4850249, 2
            tz.transition 1927, 12, :o1, -1325550000, 174617675, 72
            tz.transition 1928, 9, :o2, -1304380800, 4850981, 2
            tz.transition 1928, 12, :o1, -1293927600, 174644027, 72
            tz.transition 1929, 9, :o2, -1272844800, 4851711, 2
            tz.transition 1929, 12, :o1, -1262391600, 174670307, 72
            tz.transition 1930, 9, :o2, -1241308800, 4852441, 2
            tz.transition 1930, 12, :o1, -1230855600, 174696587, 72
            tz.transition 1931, 9, :o2, -1209772800, 4853171, 2
            tz.transition 1931, 12, :o1, -1199319600, 174722867, 72
            tz.transition 1932, 9, :o2, -1178150400, 4853903, 2
            tz.transition 1932, 12, :o1, -1167697200, 174749219, 72
            tz.transition 1933, 9, :o2, -1146614400, 4854633, 2
            tz.transition 1933, 12, :o1, -1136161200, 174775499, 72
            tz.transition 1934, 9, :o2, -1115078400, 4855363, 2
            tz.transition 1934, 12, :o1, -1104625200, 174801779, 72
            tz.transition 1935, 9, :o2, -1083542400, 4856093, 2
            tz.transition 1935, 12, :o1, -1073089200, 174828059, 72
            tz.transition 1936, 9, :o2, -1051920000, 4856825, 2
            tz.transition 1936, 12, :o1, -1041466800, 174854411, 72
            tz.transition 1937, 9, :o2, -1020384000, 4857555, 2
            tz.transition 1937, 12, :o1, -1009930800, 174880691, 72
            tz.transition 1938, 9, :o2, -988848000, 4858285, 2
            tz.transition 1938, 12, :o1, -978394800, 174906971, 72
            tz.transition 1939, 9, :o2, -957312000, 4859015, 2
            tz.transition 1939, 12, :o1, -946858800, 174933251, 72
            tz.transition 1940, 9, :o2, -925689600, 4859747, 2
            tz.transition 1940, 12, :o1, -915236400, 174959603, 72
            tz.transition 1941, 9, :o2, -894153600, 4860477, 2
            tz.transition 1941, 12, :o1, -883700400, 174985883, 72
            tz.transition 1942, 9, :o2, -862617600, 4861207, 2
            tz.transition 1942, 12, :o1, -852164400, 175012163, 72
          end
        end
      end
    end
  end
end
