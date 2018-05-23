# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Ho_Chi_Minh
          include TimezoneDefinition
          
          timezone 'Asia/Ho_Chi_Minh' do |tz|
            tz.offset :o0, 25600, 0, :LMT
            tz.offset :o1, 25590, 0, :PLMT
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 28800, 0, :'+08'
            tz.offset :o4, 32400, 0, :'+09'
            
            tz.transition 1906, 6, :o1, -2004073600, 130539179, 54
            tz.transition 1911, 4, :o2, -1851577590, 6967172747, 2880
            tz.transition 1942, 12, :o3, -852105600, 14584351, 6
            tz.transition 1945, 3, :o4, -782643600, 19452233, 8
            tz.transition 1945, 9, :o2, -767869200, 19453601, 8
            tz.transition 1947, 3, :o3, -718095600, 58374629, 24
            tz.transition 1955, 6, :o2, -457776000, 14611735, 6
            tz.transition 1959, 12, :o3, -315648000, 14621605, 6
            tz.transition 1975, 6, :o2, 171820800
          end
        end
      end
    end
  end
end
