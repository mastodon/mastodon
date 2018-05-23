# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module Rothera
          include TimezoneDefinition
          
          timezone 'Antarctica/Rothera' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, -10800, 0, :'-03'
            
            tz.transition 1976, 12, :o1, 218246400
          end
        end
      end
    end
  end
end
