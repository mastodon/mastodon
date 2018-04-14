# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Australia
        module South
          include TimezoneDefinition
          
          linked_timezone 'Australia/South', 'Australia/Adelaide'
        end
      end
    end
  end
end
