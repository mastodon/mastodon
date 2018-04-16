# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Johnston
          include TimezoneDefinition
          
          linked_timezone 'Pacific/Johnston', 'Pacific/Honolulu'
        end
      end
    end
  end
end
