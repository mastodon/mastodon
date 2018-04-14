# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Santo_Domingo
          include TimezoneDefinition
          
          timezone 'America/Santo_Domingo' do |tz|
            tz.offset :o0, -16776, 0, :LMT
            tz.offset :o1, -16800, 0, :SDMT
            tz.offset :o2, -18000, 0, :EST
            tz.offset :o3, -18000, 3600, :EDT
            tz.offset :o4, -18000, 1800, :'-0430'
            tz.offset :o5, -14400, 0, :AST
            
            tz.transition 1890, 1, :o1, -2524504824, 2893642433, 1200
            tz.transition 1933, 4, :o2, -1159773600, 87377911, 36
            tz.transition 1966, 10, :o3, -100119600, 58546289, 24
            tz.transition 1967, 2, :o2, -89668800, 7318649, 3
            tz.transition 1969, 10, :o4, -5770800, 58572497, 24
            tz.transition 1970, 2, :o2, 4422600
            tz.transition 1970, 10, :o4, 25678800
            tz.transition 1971, 1, :o2, 33193800
            tz.transition 1971, 10, :o4, 57733200
            tz.transition 1972, 1, :o2, 64816200
            tz.transition 1972, 10, :o4, 89182800
            tz.transition 1973, 1, :o2, 96438600
            tz.transition 1973, 10, :o4, 120632400
            tz.transition 1974, 1, :o2, 127974600
            tz.transition 1974, 10, :o5, 152082000
            tz.transition 2000, 10, :o2, 972799200
            tz.transition 2000, 12, :o5, 975823200
          end
        end
      end
    end
  end
end
