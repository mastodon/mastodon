# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Saipan
          include TimezoneDefinition
          
          linked_timezone 'Pacific/Saipan', 'Pacific/Guam'
        end
      end
    end
  end
end
