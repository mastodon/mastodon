# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__12
          include TimezoneDefinition
          
          timezone 'Etc/GMT+12' do |tz|
            tz.offset :o0, -43200, 0, :'-12'
            
          end
        end
      end
    end
  end
end
