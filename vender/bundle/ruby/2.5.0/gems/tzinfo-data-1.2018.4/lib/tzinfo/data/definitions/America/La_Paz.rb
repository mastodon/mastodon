# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module La_Paz
          include TimezoneDefinition
          
          timezone 'America/La_Paz' do |tz|
            tz.offset :o0, -16356, 0, :LMT
            tz.offset :o1, -16356, 0, :CMT
            tz.offset :o2, -16356, 3600, :BST
            tz.offset :o3, -14400, 0, :'-04'
            
            tz.transition 1890, 1, :o1, -2524505244, 17361854563, 7200
            tz.transition 1931, 10, :o2, -1205954844, 17471733763, 7200
            tz.transition 1932, 3, :o3, -1192307244, 17472871063, 7200
          end
        end
      end
    end
  end
end
