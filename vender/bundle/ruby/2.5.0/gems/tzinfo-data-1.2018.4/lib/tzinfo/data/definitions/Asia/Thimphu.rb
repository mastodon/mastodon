# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Thimphu
          include TimezoneDefinition
          
          timezone 'Asia/Thimphu' do |tz|
            tz.offset :o0, 21516, 0, :LMT
            tz.offset :o1, 19800, 0, :'+0530'
            tz.offset :o2, 21600, 0, :'+06'
            
            tz.transition 1947, 8, :o1, -706341516, 17513368207, 7200
            tz.transition 1987, 9, :o2, 560025000
          end
        end
      end
    end
  end
end
