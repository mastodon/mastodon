# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Chile
        module Continental
          include TimezoneDefinition
          
          linked_timezone 'Chile/Continental', 'America/Santiago'
        end
      end
    end
  end
end
