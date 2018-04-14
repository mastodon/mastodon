# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Kolkata
          include TimezoneDefinition
          
          timezone 'Asia/Kolkata' do |tz|
            tz.offset :o0, 21208, 0, :LMT
            tz.offset :o1, 21200, 0, :HMT
            tz.offset :o2, 19270, 0, :MMT
            tz.offset :o3, 19800, 0, :IST
            tz.offset :o4, 19800, 3600, :'+0630'
            
            tz.transition 1854, 6, :o1, -3645237208, 25902690349, 10800
            tz.transition 1869, 12, :o2, -3155694800, 519277663, 216
            tz.transition 1905, 12, :o3, -2019705670, 20884705433, 8640
            tz.transition 1941, 9, :o4, -891581400, 116652877, 48
            tz.transition 1942, 5, :o3, -872058600, 116663723, 48
            tz.transition 1942, 8, :o4, -862637400, 116668957, 48
            tz.transition 1945, 10, :o3, -764145000, 116723675, 48
          end
        end
      end
    end
  end
end
