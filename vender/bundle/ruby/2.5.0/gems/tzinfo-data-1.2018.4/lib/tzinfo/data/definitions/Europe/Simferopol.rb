# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Simferopol
          include TimezoneDefinition
          
          timezone 'Europe/Simferopol' do |tz|
            tz.offset :o0, 8184, 0, :LMT
            tz.offset :o1, 8160, 0, :SMT
            tz.offset :o2, 7200, 0, :EET
            tz.offset :o3, 10800, 0, :MSK
            tz.offset :o4, 3600, 3600, :CEST
            tz.offset :o5, 3600, 0, :CET
            tz.offset :o6, 10800, 3600, :MSD
            tz.offset :o7, 7200, 3600, :EEST
            tz.offset :o8, 14400, 0, :MSK
            
            tz.transition 1879, 12, :o1, -2840148984, 8667775459, 3600
            tz.transition 1924, 5, :o2, -1441160160, 436303333, 180
            tz.transition 1930, 6, :o3, -1247536800, 29113781, 12
            tz.transition 1941, 10, :o4, -888894000, 19442395, 8
            tz.transition 1942, 11, :o5, -857257200, 58335973, 24
            tz.transition 1943, 3, :o4, -844556400, 58339501, 24
            tz.transition 1943, 10, :o5, -828226800, 58344037, 24
            tz.transition 1944, 4, :o4, -812502000, 58348405, 24
            tz.transition 1944, 4, :o3, -811648800, 29174321, 12
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
            tz.transition 1990, 6, :o2, 646786800
            tz.transition 1992, 3, :o7, 701820000
            tz.transition 1992, 9, :o2, 717541200
            tz.transition 1993, 3, :o7, 733269600
            tz.transition 1993, 9, :o2, 748990800
            tz.transition 1994, 3, :o7, 764719200
            tz.transition 1994, 4, :o6, 767739600
            tz.transition 1994, 9, :o3, 780436800
            tz.transition 1995, 3, :o6, 796165200
            tz.transition 1995, 9, :o3, 811886400
            tz.transition 1996, 3, :o6, 828219600
            tz.transition 1996, 10, :o3, 846374400
            tz.transition 1997, 3, :o7, 859683600
            tz.transition 1997, 10, :o2, 877827600
            tz.transition 1998, 3, :o7, 891133200
            tz.transition 1998, 10, :o2, 909277200
            tz.transition 1999, 3, :o7, 922582800
            tz.transition 1999, 10, :o2, 941331600
            tz.transition 2000, 3, :o7, 954032400
            tz.transition 2000, 10, :o2, 972781200
            tz.transition 2001, 3, :o7, 985482000
            tz.transition 2001, 10, :o2, 1004230800
            tz.transition 2002, 3, :o7, 1017536400
            tz.transition 2002, 10, :o2, 1035680400
            tz.transition 2003, 3, :o7, 1048986000
            tz.transition 2003, 10, :o2, 1067130000
            tz.transition 2004, 3, :o7, 1080435600
            tz.transition 2004, 10, :o2, 1099184400
            tz.transition 2005, 3, :o7, 1111885200
            tz.transition 2005, 10, :o2, 1130634000
            tz.transition 2006, 3, :o7, 1143334800
            tz.transition 2006, 10, :o2, 1162083600
            tz.transition 2007, 3, :o7, 1174784400
            tz.transition 2007, 10, :o2, 1193533200
            tz.transition 2008, 3, :o7, 1206838800
            tz.transition 2008, 10, :o2, 1224982800
            tz.transition 2009, 3, :o7, 1238288400
            tz.transition 2009, 10, :o2, 1256432400
            tz.transition 2010, 3, :o7, 1269738000
            tz.transition 2010, 10, :o2, 1288486800
            tz.transition 2011, 3, :o7, 1301187600
            tz.transition 2011, 10, :o2, 1319936400
            tz.transition 2012, 3, :o7, 1332637200
            tz.transition 2012, 10, :o2, 1351386000
            tz.transition 2013, 3, :o7, 1364691600
            tz.transition 2013, 10, :o2, 1382835600
            tz.transition 2014, 3, :o8, 1396137600
            tz.transition 2014, 10, :o3, 1414274400
          end
        end
      end
    end
  end
end
