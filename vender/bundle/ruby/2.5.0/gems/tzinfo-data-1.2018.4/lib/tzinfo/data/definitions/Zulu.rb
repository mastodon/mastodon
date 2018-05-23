# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Zulu
        include TimezoneDefinition
        
        linked_timezone 'Zulu', 'Etc/UTC'
      end
    end
  end
end
