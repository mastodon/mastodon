# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Martinique
          include TimezoneDefinition
          
          timezone 'America/Martinique' do |tz|
            tz.offset :o0, -14660, 0, :LMT
            tz.offset :o1, -14660, 0, :FFMT
            tz.offset :o2, -14400, 0, :AST
            tz.offset :o3, -14400, 3600, :ADT
            
            tz.transition 1890, 1, :o1, -2524506940, 10417112653, 4320
            tz.transition 1911, 5, :o2, -1851537340, 10450761133, 4320
            tz.transition 1980, 4, :o3, 323841600
            tz.transition 1980, 9, :o2, 338958000
          end
        end
      end
    end
  end
end
