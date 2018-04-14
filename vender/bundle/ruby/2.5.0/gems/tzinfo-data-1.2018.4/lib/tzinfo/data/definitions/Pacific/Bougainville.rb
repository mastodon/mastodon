# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Bougainville
          include TimezoneDefinition
          
          timezone 'Pacific/Bougainville' do |tz|
            tz.offset :o0, 37336, 0, :LMT
            tz.offset :o1, 35312, 0, :PMMT
            tz.offset :o2, 36000, 0, :'+10'
            tz.offset :o3, 32400, 0, :'+09'
            tz.offset :o4, 39600, 0, :'+11'
            
            tz.transition 1879, 12, :o1, -2840178136, 26003322733, 10800
            tz.transition 1894, 12, :o2, -2366790512, 13031248093, 5400
            tz.transition 1942, 6, :o3, -868010400, 29166493, 12
            tz.transition 1945, 8, :o2, -768906000, 19453505, 8
            tz.transition 2014, 12, :o4, 1419696000
          end
        end
      end
    end
  end
end
