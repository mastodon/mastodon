# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Curacao
          include TimezoneDefinition
          
          timezone 'America/Curacao' do |tz|
            tz.offset :o0, -16547, 0, :LMT
            tz.offset :o1, -16200, 0, :'-0430'
            tz.offset :o2, -14400, 0, :AST
            
            tz.transition 1912, 2, :o1, -1826738653, 209040021347, 86400
            tz.transition 1965, 1, :o2, -157750200, 39020187, 16
          end
        end
      end
    end
  end
end
