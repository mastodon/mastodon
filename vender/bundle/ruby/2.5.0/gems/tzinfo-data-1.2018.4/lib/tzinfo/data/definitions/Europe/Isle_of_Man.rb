# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Isle_of_Man
          include TimezoneDefinition
          
          linked_timezone 'Europe/Isle_of_Man', 'Europe/London'
        end
      end
    end
  end
end
