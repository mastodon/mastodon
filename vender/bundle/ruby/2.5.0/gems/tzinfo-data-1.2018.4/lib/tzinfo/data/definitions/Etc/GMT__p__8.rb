# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__8
          include TimezoneDefinition
          
          timezone 'Etc/GMT+8' do |tz|
            tz.offset :o0, -28800, 0, :'-08'
            
          end
        end
      end
    end
  end
end
