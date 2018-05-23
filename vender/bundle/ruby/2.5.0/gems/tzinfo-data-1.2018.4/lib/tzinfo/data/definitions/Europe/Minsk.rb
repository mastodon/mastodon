# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Minsk
          include TimezoneDefinition
          
          timezone 'Europe/Minsk' do |tz|
            tz.offset :o0, 6616, 0, :LMT
            tz.offset :o1, 6600, 0, :MMT
            tz.offset :o2, 7200, 0, :EET
            tz.offset :o3, 10800, 0, :MSK
            tz.offset :o4, 3600, 3600, :CEST
            tz.offset :o5, 3600, 0, :CET
            tz.offset :o6, 10800, 3600, :MSD
            tz.offset :o7, 7200, 3600, :EEST
            tz.offset :o8, 10800, 0, :'+03'
            
            tz.transition 1879, 12, :o1, -2840147416, 26003326573, 10800
            tz.transition 1924, 5, :o2, -1441158600, 349042669, 144
            tz.transition 1930, 6, :o3, -1247536800, 29113781, 12
            tz.transition 1941, 6, :o4, -899780400, 19441387, 8
            tz.transition 1942, 11, :o5, -857257200, 58335973, 24
            tz.transition 1943, 3, :o4, -844556400, 58339501, 24
            tz.transition 1943, 10, :o5, -828226800, 58344037, 24
            tz.transition 1944, 4, :o4, -812502000, 58348405, 24
            tz.transition 1944, 7, :o3, -804650400, 29175293, 12
            tz.transition 1981, 3, :o6, 354920400
            tz.transition 1981, 9, :o3, 370728000
            tz.transition 1982, 3, :o6, 386456400
            tz.transition 1982, 9, :o3, 402264000
            tz.transition 1983, 3, :o6, 417992400
            tz.transition 1983, 9, :o3, 433800000
            tz.transition 1984, 3, :o6, 449614800
            tz.transition 1984, 9, :o3, 465346800
            tz.transition 1985, 3, :o6, 481071600
            tz.transition 1985, 9, :o3, 496796400
            tz.transition 1986, 3, :o6, 512521200
            tz.transition 1986, 9, :o3, 528246000
            tz.transition 1987, 3, :o6, 543970800
            tz.transition 1987, 9, :o3, 559695600
            tz.transition 1988, 3, :o6, 575420400
            tz.transition 1988, 9, :o3, 591145200
            tz.transition 1989, 3, :o6, 606870000
            tz.transition 1989, 9, :o3, 622594800
            tz.transition 1991, 3, :o7, 670374000
            tz.transition 1991, 9, :o2, 686102400
            tz.transition 1992, 3, :o7, 701827200
            tz.transition 1992, 9, :o2, 717552000
            tz.transition 1993, 3, :o7, 733276800
            tz.transition 1993, 9, :o2, 749001600
            tz.transition 1994, 3, :o7, 764726400
            tz.transition 1994, 9, :o2, 780451200
            tz.transition 1995, 3, :o7, 796176000
            tz.transition 1995, 9, :o2, 811900800
            tz.transition 1996, 3, :o7, 828230400
            tz.transition 1996, 10, :o2, 846374400
            tz.transition 1997, 3, :o7, 859680000
            tz.transition 1997, 10, :o2, 877824000
            tz.transition 1998, 3, :o7, 891129600
            tz.transition 1998, 10, :o2, 909273600
            tz.transition 1999, 3, :o7, 922579200
            tz.transition 1999, 10, :o2, 941328000
            tz.transition 2000, 3, :o7, 954028800
            tz.transition 2000, 10, :o2, 972777600
            tz.transition 2001, 3, :o7, 985478400
            tz.transition 2001, 10, :o2, 1004227200
            tz.transition 2002, 3, :o7, 1017532800
            tz.transition 2002, 10, :o2, 1035676800
            tz.transition 2003, 3, :o7, 1048982400
            tz.transition 2003, 10, :o2, 1067126400
            tz.transition 2004, 3, :o7, 1080432000
            tz.transition 2004, 10, :o2, 1099180800
            tz.transition 2005, 3, :o7, 1111881600
            tz.transition 2005, 10, :o2, 1130630400
            tz.transition 2006, 3, :o7, 1143331200
            tz.transition 2006, 10, :o2, 1162080000
            tz.transition 2007, 3, :o7, 1174780800
            tz.transition 2007, 10, :o2, 1193529600
            tz.transition 2008, 3, :o7, 1206835200
            tz.transition 2008, 10, :o2, 1224979200
            tz.transition 2009, 3, :o7, 1238284800
            tz.transition 2009, 10, :o2, 1256428800
            tz.transition 2010, 3, :o7, 1269734400
            tz.transition 2010, 10, :o2, 1288483200
            tz.transition 2011, 3, :o8, 1301184000
          end
        end
      end
    end
  end
end
