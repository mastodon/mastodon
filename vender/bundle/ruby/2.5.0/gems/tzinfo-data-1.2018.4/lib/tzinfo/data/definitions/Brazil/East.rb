# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Brazil
        module East
          include TimezoneDefinition
          
          linked_timezone 'Brazil/East', 'America/Sao_Paulo'
        end
      end
    end
  end
end
