# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__10
          include TimezoneDefinition
          
          timezone 'Etc/GMT+10' do |tz|
            tz.offset :o0, -36000, 0, :'-10'
            
          end
        end
      end
    end
  end
end
