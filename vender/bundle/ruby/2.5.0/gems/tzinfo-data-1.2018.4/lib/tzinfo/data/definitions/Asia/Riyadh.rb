# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Riyadh
          include TimezoneDefinition
          
          timezone 'Asia/Riyadh' do |tz|
            tz.offset :o0, 11212, 0, :LMT
            tz.offset :o1, 10800, 0, :'+03'
            
            tz.transition 1947, 3, :o1, -719636812, 52536780797, 21600
          end
        end
      end
    end
  end
end
