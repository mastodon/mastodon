# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Yangon
          include TimezoneDefinition
          
          timezone 'Asia/Yangon' do |tz|
            tz.offset :o0, 23087, 0, :LMT
            tz.offset :o1, 23087, 0, :RMT
            tz.offset :o2, 23400, 0, :'+0630'
            tz.offset :o3, 32400, 0, :'+09'
            
            tz.transition 1879, 12, :o1, -2840163887, 208026596113, 86400
            tz.transition 1919, 12, :o2, -1577946287, 209288813713, 86400
            tz.transition 1942, 4, :o3, -873268200, 116663051, 48
            tz.transition 1945, 5, :o2, -778410000, 19452625, 8
          end
        end
      end
    end
  end
end
