# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Honolulu
          include TimezoneDefinition
          
          timezone 'Pacific/Honolulu' do |tz|
            tz.offset :o0, -37886, 0, :LMT
            tz.offset :o1, -37800, 0, :HST
            tz.offset :o2, -37800, 3600, :HDT
            tz.offset :o3, -36000, 0, :HST
            
            tz.transition 1896, 1, :o1, -2334101314, 104266329343, 43200
            tz.transition 1933, 4, :o2, -1157283000, 116505265, 48
            tz.transition 1933, 5, :o1, -1155436200, 116506291, 48
            tz.transition 1942, 2, :o2, -880198200, 116659201, 48
            tz.transition 1945, 9, :o1, -765376200, 116722991, 48
            tz.transition 1947, 6, :o3, -712150200, 116752561, 48
          end
        end
      end
    end
  end
end
