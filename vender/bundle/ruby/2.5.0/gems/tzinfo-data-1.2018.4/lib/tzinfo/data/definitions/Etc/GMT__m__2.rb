# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__m__2
          include TimezoneDefinition
          
          timezone 'Etc/GMT-2' do |tz|
            tz.offset :o0, 7200, 0, :'+02'
            
          end
        end
      end
    end
  end
end
