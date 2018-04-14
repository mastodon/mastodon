# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Kathmandu
          include TimezoneDefinition
          
          timezone 'Asia/Kathmandu' do |tz|
            tz.offset :o0, 20476, 0, :LMT
            tz.offset :o1, 19800, 0, :'+0530'
            tz.offset :o2, 20700, 0, :'+0545'
            
            tz.transition 1919, 12, :o1, -1577943676, 52322204081, 21600
            tz.transition 1985, 12, :o2, 504901800
          end
        end
      end
    end
  end
end
