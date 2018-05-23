# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Port_Moresby
          include TimezoneDefinition
          
          timezone 'Pacific/Port_Moresby' do |tz|
            tz.offset :o0, 35320, 0, :LMT
            tz.offset :o1, 35312, 0, :PMMT
            tz.offset :o2, 36000, 0, :'+10'
            
            tz.transition 1879, 12, :o1, -2840176120, 5200664597, 2160
            tz.transition 1894, 12, :o2, -2366790512, 13031248093, 5400
          end
        end
      end
    end
  end
end
