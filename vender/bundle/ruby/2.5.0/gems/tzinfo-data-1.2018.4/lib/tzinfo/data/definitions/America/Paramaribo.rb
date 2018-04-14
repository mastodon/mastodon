# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Paramaribo
          include TimezoneDefinition
          
          timezone 'America/Paramaribo' do |tz|
            tz.offset :o0, -13240, 0, :LMT
            tz.offset :o1, -13252, 0, :PMT
            tz.offset :o2, -13236, 0, :PMT
            tz.offset :o3, -12600, 0, :'-0330'
            tz.offset :o4, -10800, 0, :'-03'
            
            tz.transition 1911, 1, :o1, -1861906760, 5225121331, 2160
            tz.transition 1935, 1, :o2, -1104524348, 52440558913, 21600
            tz.transition 1945, 10, :o3, -765317964, 17508453503, 7200
            tz.transition 1984, 10, :o4, 465449400
          end
        end
      end
    end
  end
end
