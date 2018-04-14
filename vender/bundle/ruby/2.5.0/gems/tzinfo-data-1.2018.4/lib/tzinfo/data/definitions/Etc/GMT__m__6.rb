# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__m__6
          include TimezoneDefinition
          
          timezone 'Etc/GMT-6' do |tz|
            tz.offset :o0, 21600, 0, :'+06'
            
          end
        end
      end
    end
  end
end
