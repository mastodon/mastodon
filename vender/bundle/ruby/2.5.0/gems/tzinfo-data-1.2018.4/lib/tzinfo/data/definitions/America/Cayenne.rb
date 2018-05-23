# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Cayenne
          include TimezoneDefinition
          
          timezone 'America/Cayenne' do |tz|
            tz.offset :o0, -12560, 0, :LMT
            tz.offset :o1, -14400, 0, :'-04'
            tz.offset :o2, -10800, 0, :'-03'
            
            tz.transition 1911, 7, :o1, -1846269040, 2612756137, 1080
            tz.transition 1967, 10, :o2, -71092800, 7319294, 3
          end
        end
      end
    end
  end
end
