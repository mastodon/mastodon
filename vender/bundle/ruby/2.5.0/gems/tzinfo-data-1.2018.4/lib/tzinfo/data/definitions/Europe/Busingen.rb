# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Busingen
          include TimezoneDefinition
          
          linked_timezone 'Europe/Busingen', 'Europe/Zurich'
        end
      end
    end
  end
end
