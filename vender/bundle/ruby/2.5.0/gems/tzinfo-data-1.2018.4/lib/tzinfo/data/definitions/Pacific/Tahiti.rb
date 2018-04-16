# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Tahiti
          include TimezoneDefinition
          
          timezone 'Pacific/Tahiti' do |tz|
            tz.offset :o0, -35896, 0, :LMT
            tz.offset :o1, -36000, 0, :'-10'
            
            tz.transition 1912, 10, :o1, -1806674504, 26132510687, 10800
          end
        end
      end
    end
  end
end
