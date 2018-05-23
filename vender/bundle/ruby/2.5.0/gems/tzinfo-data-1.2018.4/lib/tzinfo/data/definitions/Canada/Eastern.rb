# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Canada
        module Eastern
          include TimezoneDefinition
          
          linked_timezone 'Canada/Eastern', 'America/Toronto'
        end
      end
    end
  end
end
