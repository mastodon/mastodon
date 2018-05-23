# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Shiprock
          include TimezoneDefinition
          
          linked_timezone 'America/Shiprock', 'America/Denver'
        end
      end
    end
  end
end
