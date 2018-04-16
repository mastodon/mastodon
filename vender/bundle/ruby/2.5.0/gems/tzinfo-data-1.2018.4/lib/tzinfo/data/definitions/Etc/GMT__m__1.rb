# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__m__1
          include TimezoneDefinition
          
          timezone 'Etc/GMT-1' do |tz|
            tz.offset :o0, 3600, 0, :'+01'
            
          end
        end
      end
    end
  end
end
