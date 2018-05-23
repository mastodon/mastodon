# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Blanc__m__Sablon
          include TimezoneDefinition
          
          timezone 'America/Blanc-Sablon' do |tz|
            tz.offset :o0, -13708, 0, :LMT
            tz.offset :o1, -14400, 0, :AST
            tz.offset :o2, -14400, 3600, :ADT
            tz.offset :o3, -14400, 3600, :AWT
            tz.offset :o4, -14400, 3600, :APT
            
            tz.transition 1884, 1, :o1, -2713896692, 52038215827, 21600
            tz.transition 1918, 4, :o2, -1632074400, 9686791, 4
            tz.transition 1918, 10, :o1, -1615143600, 58125449, 24
            tz.transition 1942, 2, :o3, -880221600, 9721599, 4
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765399600, 58361489, 24
          end
        end
      end
    end
  end
end
