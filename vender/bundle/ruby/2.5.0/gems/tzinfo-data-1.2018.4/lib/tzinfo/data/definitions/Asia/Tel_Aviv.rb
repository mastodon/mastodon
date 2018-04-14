# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Tel_Aviv
          include TimezoneDefinition
          
          linked_timezone 'Asia/Tel_Aviv', 'Asia/Jerusalem'
        end
      end
    end
  end
end
