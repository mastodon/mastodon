# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module Darwin
          include TimezoneDefinition
          
          timezone 'Australia/Darwin' do |tz|
            tz.offset :o0, 31400, 0, :LMT
            tz.offset :o1, 32400, 0, :ACST
            tz.offset :o2, 34200, 0, :ACST
            tz.offset :o3, 34200, 3600, :ACDT
            
            tz.transition 1895, 1, :o1, -2364108200, 1042513259, 432
            tz.transition 1899, 4, :o2, -2230189200, 19318201, 8
            tz.transition 1916, 12, :o3, -1672565340, 3486569911, 1440
            tz.transition 1917, 3, :o2, -1665390600, 116222983, 48
            tz.transition 1941, 12, :o3, -883639800, 38885763, 16
            tz.transition 1942, 3, :o2, -876126600, 116661463, 48
            tz.transition 1942, 9, :o3, -860398200, 38890067, 16
            tz.transition 1943, 3, :o2, -844677000, 116678935, 48
            tz.transition 1943, 10, :o3, -828343800, 38896003, 16
            tz.transition 1944, 3, :o2, -813227400, 116696407, 48
          end
        end
      end
    end
  end
end
