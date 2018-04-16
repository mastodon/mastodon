# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Tunis
          include TimezoneDefinition
          
          timezone 'Africa/Tunis' do |tz|
            tz.offset :o0, 2444, 0, :LMT
            tz.offset :o1, 561, 0, :PMT
            tz.offset :o2, 3600, 0, :CET
            tz.offset :o3, 3600, 3600, :CEST
            
            tz.transition 1881, 5, :o1, -2797202444, 52017389389, 21600
            tz.transition 1911, 3, :o2, -1855958961, 69670267013, 28800
            tz.transition 1939, 4, :o3, -969242400, 29152433, 12
            tz.transition 1939, 11, :o2, -950493600, 29155037, 12
            tz.transition 1940, 2, :o3, -941940000, 29156225, 12
            tz.transition 1941, 10, :o2, -891136800, 29163281, 12
            tz.transition 1942, 3, :o3, -877827600, 58330259, 24
            tz.transition 1942, 11, :o2, -857257200, 58335973, 24
            tz.transition 1943, 3, :o3, -844556400, 58339501, 24
            tz.transition 1943, 4, :o2, -842918400, 4861663, 2
            tz.transition 1943, 4, :o3, -842223600, 58340149, 24
            tz.transition 1943, 10, :o2, -828230400, 4862003, 2
            tz.transition 1944, 4, :o3, -812502000, 58348405, 24
            tz.transition 1944, 10, :o2, -796269600, 29176457, 12
            tz.transition 1945, 4, :o3, -781052400, 58357141, 24
            tz.transition 1945, 9, :o2, -766634400, 29180573, 12
            tz.transition 1977, 4, :o3, 231202800
            tz.transition 1977, 9, :o2, 243903600
            tz.transition 1978, 4, :o3, 262825200
            tz.transition 1978, 9, :o2, 276044400
            tz.transition 1988, 5, :o3, 581122800
            tz.transition 1988, 9, :o2, 591145200
            tz.transition 1989, 3, :o3, 606870000
            tz.transition 1989, 9, :o2, 622594800
            tz.transition 1990, 4, :o3, 641516400
            tz.transition 1990, 9, :o2, 654649200
            tz.transition 2005, 4, :o3, 1114902000
            tz.transition 2005, 9, :o2, 1128038400
            tz.transition 2006, 3, :o3, 1143334800
            tz.transition 2006, 10, :o2, 1162083600
            tz.transition 2007, 3, :o3, 1174784400
            tz.transition 2007, 10, :o2, 1193533200
            tz.transition 2008, 3, :o3, 1206838800
            tz.transition 2008, 10, :o2, 1224982800
          end
        end
      end
    end
  end
end
