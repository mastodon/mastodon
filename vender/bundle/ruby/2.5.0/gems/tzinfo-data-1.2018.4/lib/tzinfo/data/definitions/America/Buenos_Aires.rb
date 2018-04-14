# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Buenos_Aires
          include TimezoneDefinition
          
          linked_timezone 'America/Buenos_Aires', 'America/Argentina/Buenos_Aires'
        end
      end
    end
  end
end
