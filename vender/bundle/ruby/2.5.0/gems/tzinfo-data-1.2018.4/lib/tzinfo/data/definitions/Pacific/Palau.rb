# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Palau
          include TimezoneDefinition
          
          timezone 'Pacific/Palau' do |tz|
            tz.offset :o0, 32276, 0, :LMT
            tz.offset :o1, 32400, 0, :'+09'
            
            tz.transition 1900, 12, :o1, -2177485076, 52172318731, 21600
          end
        end
      end
    end
  end
end
