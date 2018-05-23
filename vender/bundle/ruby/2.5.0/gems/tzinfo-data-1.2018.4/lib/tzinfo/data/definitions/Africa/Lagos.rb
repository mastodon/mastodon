# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Lagos
          include TimezoneDefinition
          
          timezone 'Africa/Lagos' do |tz|
            tz.offset :o0, 816, 0, :LMT
            tz.offset :o1, 3600, 0, :WAT
            
            tz.transition 1919, 8, :o1, -1588464816, 4359964483, 1800
          end
        end
      end
    end
  end
end
