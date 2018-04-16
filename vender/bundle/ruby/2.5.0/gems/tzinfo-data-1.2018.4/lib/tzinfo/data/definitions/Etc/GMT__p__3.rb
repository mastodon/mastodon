# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__3
          include TimezoneDefinition
          
          timezone 'Etc/GMT+3' do |tz|
            tz.offset :o0, -10800, 0, :'-03'
            
          end
        end
      end
    end
  end
end
