# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Ndjamena
          include TimezoneDefinition
          
          timezone 'Africa/Ndjamena' do |tz|
            tz.offset :o0, 3612, 0, :LMT
            tz.offset :o1, 3600, 0, :WAT
            tz.offset :o2, 3600, 3600, :WAST
            
            tz.transition 1911, 12, :o1, -1830387612, 17419697699, 7200
            tz.transition 1979, 10, :o2, 308703600
            tz.transition 1980, 3, :o1, 321314400
          end
        end
      end
    end
  end
end
