# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module HST
        include TimezoneDefinition
        
        timezone 'HST' do |tz|
          tz.offset :o0, -36000, 0, :HST
          
        end
      end
    end
  end
end
