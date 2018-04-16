# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module US
        module Pacific
          include TimezoneDefinition
          
          linked_timezone 'US/Pacific', 'America/Los_Angeles'
        end
      end
    end
  end
end
