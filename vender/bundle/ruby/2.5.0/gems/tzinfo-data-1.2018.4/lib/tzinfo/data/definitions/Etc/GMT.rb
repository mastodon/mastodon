# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Etc
        module GMT
          include TimezoneDefinition
          
          timezone 'Etc/GMT' do |tz|
            tz.offset :o0, 0, 0, :GMT
            
          end
        end
      end
    end
  end
end
