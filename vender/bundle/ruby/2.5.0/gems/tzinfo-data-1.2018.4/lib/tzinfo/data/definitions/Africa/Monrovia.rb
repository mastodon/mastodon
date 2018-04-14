# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Monrovia
          include TimezoneDefinition
          
          timezone 'Africa/Monrovia' do |tz|
            tz.offset :o0, -2588, 0, :LMT
            tz.offset :o1, -2588, 0, :MMT
            tz.offset :o2, -2670, 0, :MMT
            tz.offset :o3, 0, 0, :GMT
            
            tz.transition 1882, 1, :o1, -2776979812, 52022445047, 21600
            tz.transition 1919, 3, :o2, -1604359012, 52315600247, 21600
            tz.transition 1972, 1, :o3, 63593070
          end
        end
      end
    end
  end
end
