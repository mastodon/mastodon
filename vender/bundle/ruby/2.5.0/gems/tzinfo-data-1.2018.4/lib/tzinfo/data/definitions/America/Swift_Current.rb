# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Swift_Current
          include TimezoneDefinition
          
          timezone 'America/Swift_Current' do |tz|
            tz.offset :o0, -25880, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -25200, 3600, :MDT
            tz.offset :o3, -25200, 3600, :MWT
            tz.offset :o4, -25200, 3600, :MPT
            tz.offset :o5, -21600, 0, :CST
            
            tz.transition 1905, 9, :o1, -2030201320, 5220913967, 2160
            tz.transition 1918, 4, :o2, -1632063600, 19373583, 8
            tz.transition 1918, 10, :o1, -1615132800, 14531363, 6
            tz.transition 1942, 2, :o3, -880210800, 19443199, 8
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765388800, 14590373, 6
            tz.transition 1946, 4, :o2, -747241200, 19455511, 8
            tz.transition 1946, 10, :o1, -732729600, 14592641, 6
            tz.transition 1947, 4, :o2, -715791600, 19458423, 8
            tz.transition 1947, 9, :o1, -702489600, 14594741, 6
            tz.transition 1948, 4, :o2, -684342000, 19461335, 8
            tz.transition 1948, 9, :o1, -671040000, 14596925, 6
            tz.transition 1949, 4, :o2, -652892400, 19464247, 8
            tz.transition 1949, 9, :o1, -639590400, 14599109, 6
            tz.transition 1957, 4, :o2, -400086000, 19487655, 8
            tz.transition 1957, 10, :o1, -384364800, 14616833, 6
            tz.transition 1959, 4, :o2, -337186800, 19493479, 8
            tz.transition 1959, 10, :o1, -321465600, 14621201, 6
            tz.transition 1960, 4, :o2, -305737200, 19496391, 8
            tz.transition 1960, 9, :o1, -292435200, 14623217, 6
            tz.transition 1961, 4, :o2, -273682800, 19499359, 8
            tz.transition 1961, 9, :o1, -260985600, 14625401, 6
            tz.transition 1972, 4, :o5, 73472400
          end
        end
      end
    end
  end
end
