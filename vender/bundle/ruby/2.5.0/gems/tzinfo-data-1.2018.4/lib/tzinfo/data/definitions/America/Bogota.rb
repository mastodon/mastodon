# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Bogota
          include TimezoneDefinition
          
          timezone 'America/Bogota' do |tz|
            tz.offset :o0, -17776, 0, :LMT
            tz.offset :o1, -17776, 0, :BMT
            tz.offset :o2, -18000, 0, :'-05'
            tz.offset :o3, -18000, 3600, :'-04'
            
            tz.transition 1884, 3, :o1, -2707671824, 13009943011, 5400
            tz.transition 1914, 11, :o2, -1739041424, 13070482411, 5400
            tz.transition 1992, 5, :o3, 704869200
            tz.transition 1993, 4, :o2, 733896000
          end
        end
      end
    end
  end
end
