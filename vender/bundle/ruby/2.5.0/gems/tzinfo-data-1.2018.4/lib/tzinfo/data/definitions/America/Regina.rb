# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Regina
          include TimezoneDefinition
          
          timezone 'America/Regina' do |tz|
            tz.offset :o0, -25116, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -25200, 3600, :MDT
            tz.offset :o3, -25200, 3600, :MWT
            tz.offset :o4, -25200, 3600, :MPT
            tz.offset :o5, -21600, 0, :CST
            
            tz.transition 1905, 9, :o1, -2030202084, 17403046493, 7200
            tz.transition 1918, 4, :o2, -1632063600, 19373583, 8
            tz.transition 1918, 10, :o1, -1615132800, 14531363, 6
            tz.transition 1930, 5, :o2, -1251651600, 58226419, 24
            tz.transition 1930, 10, :o1, -1238349600, 9705019, 4
            tz.transition 1931, 5, :o2, -1220202000, 58235155, 24
            tz.transition 1931, 10, :o1, -1206900000, 9706475, 4
            tz.transition 1932, 5, :o2, -1188752400, 58243891, 24
            tz.transition 1932, 10, :o1, -1175450400, 9707931, 4
            tz.transition 1933, 5, :o2, -1156698000, 58252795, 24
            tz.transition 1933, 10, :o1, -1144000800, 9709387, 4
            tz.transition 1934, 5, :o2, -1125248400, 58261531, 24
            tz.transition 1934, 10, :o1, -1111946400, 9710871, 4
            tz.transition 1937, 4, :o2, -1032714000, 58287235, 24
            tz.transition 1937, 10, :o1, -1016992800, 9715267, 4
            tz.transition 1938, 4, :o2, -1001264400, 58295971, 24
            tz.transition 1938, 10, :o1, -986148000, 9716695, 4
            tz.transition 1939, 4, :o2, -969814800, 58304707, 24
            tz.transition 1939, 10, :o1, -954093600, 9718179, 4
            tz.transition 1940, 4, :o2, -937760400, 58313611, 24
            tz.transition 1940, 10, :o1, -922039200, 9719663, 4
            tz.transition 1941, 4, :o2, -906310800, 58322347, 24
            tz.transition 1941, 10, :o1, -890589600, 9721119, 4
            tz.transition 1942, 2, :o3, -880210800, 19443199, 8
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765388800, 14590373, 6
            tz.transition 1946, 4, :o2, -748450800, 19455399, 8
            tz.transition 1946, 10, :o1, -732729600, 14592641, 6
            tz.transition 1947, 4, :o2, -715791600, 19458423, 8
            tz.transition 1947, 9, :o1, -702489600, 14594741, 6
            tz.transition 1948, 4, :o2, -684342000, 19461335, 8
            tz.transition 1948, 9, :o1, -671040000, 14596925, 6
            tz.transition 1949, 4, :o2, -652892400, 19464247, 8
            tz.transition 1949, 9, :o1, -639590400, 14599109, 6
            tz.transition 1950, 4, :o2, -620838000, 19467215, 8
            tz.transition 1950, 9, :o1, -608140800, 14601293, 6
            tz.transition 1951, 4, :o2, -589388400, 19470127, 8
            tz.transition 1951, 9, :o1, -576086400, 14603519, 6
            tz.transition 1952, 4, :o2, -557938800, 19473039, 8
            tz.transition 1952, 9, :o1, -544636800, 14605703, 6
            tz.transition 1953, 4, :o2, -526489200, 19475951, 8
            tz.transition 1953, 9, :o1, -513187200, 14607887, 6
            tz.transition 1954, 4, :o2, -495039600, 19478863, 8
            tz.transition 1954, 9, :o1, -481737600, 14610071, 6
            tz.transition 1955, 4, :o2, -463590000, 19481775, 8
            tz.transition 1955, 9, :o1, -450288000, 14612255, 6
            tz.transition 1956, 4, :o2, -431535600, 19484743, 8
            tz.transition 1956, 9, :o1, -418233600, 14614481, 6
            tz.transition 1957, 4, :o2, -400086000, 19487655, 8
            tz.transition 1957, 9, :o1, -386784000, 14616665, 6
            tz.transition 1959, 4, :o2, -337186800, 19493479, 8
            tz.transition 1959, 10, :o1, -321465600, 14621201, 6
            tz.transition 1960, 4, :o5, -305737200, 19496391, 8
          end
        end
      end
    end
  end
end
