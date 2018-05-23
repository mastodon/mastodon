# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module MST
        include TimezoneDefinition
        
        timezone 'MST' do |tz|
          tz.offset :o0, -25200, 0, :MST
          
        end
      end
    end
  end
end
