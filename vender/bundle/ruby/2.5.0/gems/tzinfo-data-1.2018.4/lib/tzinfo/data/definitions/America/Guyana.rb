# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Guyana
          include TimezoneDefinition
          
          timezone 'America/Guyana' do |tz|
            tz.offset :o0, -13960, 0, :LMT
            tz.offset :o1, -13500, 0, :'-0345'
            tz.offset :o2, -10800, 0, :'-03'
            tz.offset :o3, -14400, 0, :'-04'
            
            tz.transition 1915, 3, :o1, -1730578040, 5228404549, 2160
            tz.transition 1975, 7, :o2, 176010300
            tz.transition 1991, 1, :o3, 662698800
          end
        end
      end
    end
  end
end
