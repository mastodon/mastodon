# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT0
          include TimezoneDefinition
          
          linked_timezone 'Etc/GMT0', 'Etc/GMT'
        end
      end
    end
  end
end
