# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Factory
        include TimezoneDefinition
        
        timezone 'Factory' do |tz|
          tz.offset :o0, 0, 0, :'-00'
          
        end
      end
    end
  end
end
