# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Colombo
          include TimezoneDefinition
          
          timezone 'Asia/Colombo' do |tz|
            tz.offset :o0, 19164, 0, :LMT
            tz.offset :o1, 19172, 0, :MMT
            tz.offset :o2, 19800, 0, :'+0530'
            tz.offset :o3, 19800, 1800, :'+06'
            tz.offset :o4, 19800, 3600, :'+0630'
            tz.offset :o5, 23400, 0, :'+0630'
            tz.offset :o6, 21600, 0, :'+06'
            
            tz.transition 1879, 12, :o1, -2840159964, 17335550003, 7200
            tz.transition 1905, 12, :o2, -2019705572, 52211763607, 21600
            tz.transition 1942, 1, :o3, -883287000, 116657485, 48
            tz.transition 1942, 8, :o4, -862639200, 9722413, 4
            tz.transition 1945, 10, :o2, -764051400, 38907909, 16
            tz.transition 1996, 5, :o5, 832962600
            tz.transition 1996, 10, :o6, 846266400
            tz.transition 2006, 4, :o2, 1145039400
          end
        end
      end
    end
  end
end
