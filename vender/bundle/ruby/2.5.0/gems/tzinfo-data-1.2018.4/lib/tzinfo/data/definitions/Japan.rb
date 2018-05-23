# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Japan
        include TimezoneDefinition
        
        linked_timezone 'Japan', 'Asia/Tokyo'
      end
    end
  end
end
