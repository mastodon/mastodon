# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__m__14
          include TimezoneDefinition
          
          timezone 'Etc/GMT-14' do |tz|
            tz.offset :o0, 50400, 0, :'+14'
            
          end
        end
      end
    end
  end
end
