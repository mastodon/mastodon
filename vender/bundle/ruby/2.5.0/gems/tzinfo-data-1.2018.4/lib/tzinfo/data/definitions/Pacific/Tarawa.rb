# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Tarawa
          include TimezoneDefinition
          
          timezone 'Pacific/Tarawa' do |tz|
            tz.offset :o0, 41524, 0, :LMT
            tz.offset :o1, 43200, 0, :'+12'
            
            tz.transition 1900, 12, :o1, -2177494324, 52172316419, 21600
          end
        end
      end
    end
  end
end
