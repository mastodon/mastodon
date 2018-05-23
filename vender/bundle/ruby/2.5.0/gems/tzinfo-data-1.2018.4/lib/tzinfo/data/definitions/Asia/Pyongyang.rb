# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Pyongyang
          include TimezoneDefinition
          
          timezone 'Asia/Pyongyang' do |tz|
            tz.offset :o0, 30180, 0, :LMT
            tz.offset :o1, 30600, 0, :KST
            tz.offset :o2, 32400, 0, :JST
            tz.offset :o3, 32400, 0, :KST
            
            tz.transition 1908, 3, :o1, -1948782180, 3481966297, 1440
            tz.transition 1911, 12, :o2, -1830414600, 116131303, 48
            tz.transition 1945, 8, :o3, -768646800, 19453529, 8
            tz.transition 2015, 8, :o1, 1439564400
          end
        end
      end
    end
  end
end
