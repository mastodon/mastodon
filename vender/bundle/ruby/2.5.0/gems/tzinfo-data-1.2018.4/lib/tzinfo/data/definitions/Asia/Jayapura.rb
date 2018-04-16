# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Jayapura
          include TimezoneDefinition
          
          timezone 'Asia/Jayapura' do |tz|
            tz.offset :o0, 33768, 0, :LMT
            tz.offset :o1, 32400, 0, :'+09'
            tz.offset :o2, 34200, 0, :'+0930'
            tz.offset :o3, 32400, 0, :WIT
            
            tz.transition 1932, 10, :o1, -1172913768, 2912414531, 1200
            tz.transition 1944, 8, :o2, -799491600, 19450673, 8
            tz.transition 1963, 12, :o3, -189423000, 117042965, 48
          end
        end
      end
    end
  end
end
