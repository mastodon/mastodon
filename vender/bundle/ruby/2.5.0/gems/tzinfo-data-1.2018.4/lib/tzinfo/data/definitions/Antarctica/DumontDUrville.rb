# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module DumontDUrville
          include TimezoneDefinition
          
          timezone 'Antarctica/DumontDUrville' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, 36000, 0, :'+10'
            
            tz.transition 1947, 1, :o1, -725846400, 4864373, 2
            tz.transition 1952, 1, :o0, -566992800, 29208301, 12
            tz.transition 1956, 11, :o1, -415497600, 4871557, 2
          end
        end
      end
    end
  end
end
