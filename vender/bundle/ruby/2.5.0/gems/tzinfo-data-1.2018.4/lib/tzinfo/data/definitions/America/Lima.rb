# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Lima
          include TimezoneDefinition
          
          timezone 'America/Lima' do |tz|
            tz.offset :o0, -18492, 0, :LMT
            tz.offset :o1, -18516, 0, :LMT
            tz.offset :o2, -18000, 0, :'-05'
            tz.offset :o3, -18000, 3600, :'-04'
            
            tz.transition 1890, 1, :o1, -2524503108, 17361854741, 7200
            tz.transition 1908, 7, :o2, -1938538284, 17410685143, 7200
            tz.transition 1938, 1, :o3, -1009825200, 58293593, 24
            tz.transition 1938, 4, :o2, -1002052800, 7286969, 3
            tz.transition 1938, 9, :o3, -986756400, 58300001, 24
            tz.transition 1939, 3, :o2, -971035200, 7288046, 3
            tz.transition 1939, 9, :o3, -955306800, 58308737, 24
            tz.transition 1940, 3, :o2, -939585600, 7289138, 3
            tz.transition 1986, 1, :o3, 504939600
            tz.transition 1986, 4, :o2, 512712000
            tz.transition 1987, 1, :o3, 536475600
            tz.transition 1987, 4, :o2, 544248000
            tz.transition 1990, 1, :o3, 631170000
            tz.transition 1990, 4, :o2, 638942400
            tz.transition 1994, 1, :o3, 757400400
            tz.transition 1994, 4, :o2, 765172800
          end
        end
      end
    end
  end
end
