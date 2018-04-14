# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Gambier
          include TimezoneDefinition
          
          timezone 'Pacific/Gambier' do |tz|
            tz.offset :o0, -32388, 0, :LMT
            tz.offset :o1, -32400, 0, :'-09'
            
            tz.transition 1912, 10, :o1, -1806678012, 17421673499, 7200
          end
        end
      end
    end
  end
end
