# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Chuuk
          include TimezoneDefinition
          
          timezone 'Pacific/Chuuk' do |tz|
            tz.offset :o0, 36428, 0, :LMT
            tz.offset :o1, 36000, 0, :'+10'
            
            tz.transition 1900, 12, :o1, -2177489228, 52172317693, 21600
          end
        end
      end
    end
  end
end
