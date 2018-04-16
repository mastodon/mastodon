# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__7
          include TimezoneDefinition
          
          timezone 'Etc/GMT+7' do |tz|
            tz.offset :o0, -25200, 0, :'-07'
            
          end
        end
      end
    end
  end
end
