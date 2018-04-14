# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module McMurdo
          include TimezoneDefinition
          
          linked_timezone 'Antarctica/McMurdo', 'Pacific/Auckland'
        end
      end
    end
  end
end
