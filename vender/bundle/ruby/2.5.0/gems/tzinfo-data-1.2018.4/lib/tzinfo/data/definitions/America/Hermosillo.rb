# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Hermosillo
          include TimezoneDefinition
          
          timezone 'America/Hermosillo' do |tz|
            tz.offset :o0, -26632, 0, :LMT
            tz.offset :o1, -25200, 0, :MST
            tz.offset :o2, -21600, 0, :CST
            tz.offset :o3, -28800, 0, :PST
            tz.offset :o4, -25200, 3600, :MDT
            
            tz.transition 1922, 1, :o1, -1514739600, 58153339, 24
            tz.transition 1927, 6, :o2, -1343066400, 9700171, 4
            tz.transition 1930, 11, :o1, -1234807200, 9705183, 4
            tz.transition 1931, 5, :o2, -1220292000, 9705855, 4
            tz.transition 1931, 10, :o1, -1207159200, 9706463, 4
            tz.transition 1932, 4, :o2, -1191344400, 58243171, 24
            tz.transition 1942, 4, :o1, -873828000, 9721895, 4
            tz.transition 1949, 1, :o3, -661539600, 58390339, 24
            tz.transition 1970, 1, :o1, 28800
            tz.transition 1996, 4, :o4, 828867600
            tz.transition 1996, 10, :o1, 846403200
            tz.transition 1997, 4, :o4, 860317200
            tz.transition 1997, 10, :o1, 877852800
            tz.transition 1998, 4, :o4, 891766800
            tz.transition 1998, 10, :o1, 909302400
          end
        end
      end
    end
  end
end
