# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Kabul
          include TimezoneDefinition
          
          timezone 'Asia/Kabul' do |tz|
            tz.offset :o0, 16608, 0, :LMT
            tz.offset :o1, 14400, 0, :'+04'
            tz.offset :o2, 16200, 0, :'+0430'
            
            tz.transition 1889, 12, :o1, -2524538208, 2170231477, 900
            tz.transition 1944, 12, :o2, -788932800, 7294369, 3
          end
        end
      end
    end
  end
end
