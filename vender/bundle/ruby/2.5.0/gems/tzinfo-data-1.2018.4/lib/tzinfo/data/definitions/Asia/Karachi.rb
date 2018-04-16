# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Karachi
          include TimezoneDefinition
          
          timezone 'Asia/Karachi' do |tz|
            tz.offset :o0, 16092, 0, :LMT
            tz.offset :o1, 19800, 0, :'+0530'
            tz.offset :o2, 19800, 3600, :'+0630'
            tz.offset :o3, 18000, 0, :'+05'
            tz.offset :o4, 18000, 0, :PKT
            tz.offset :o5, 18000, 3600, :PKST
            
            tz.transition 1906, 12, :o1, -1988166492, 1934061051, 800
            tz.transition 1942, 8, :o2, -862637400, 116668957, 48
            tz.transition 1945, 10, :o1, -764145000, 116723675, 48
            tz.transition 1951, 9, :o3, -576135000, 116828125, 48
            tz.transition 1971, 3, :o4, 38775600
            tz.transition 2002, 4, :o5, 1018119600
            tz.transition 2002, 10, :o4, 1033840800
            tz.transition 2008, 5, :o5, 1212260400
            tz.transition 2008, 10, :o4, 1225476000
            tz.transition 2009, 4, :o5, 1239735600
            tz.transition 2009, 10, :o4, 1257012000
          end
        end
      end
    end
  end
end
