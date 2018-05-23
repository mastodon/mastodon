# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT__p__4
          include TimezoneDefinition
          
          timezone 'Etc/GMT+4' do |tz|
            tz.offset :o0, -14400, 0, :'-04'
            
          end
        end
      end
    end
  end
end
