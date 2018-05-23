# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Irkutsk
          include TimezoneDefinition
          
          timezone 'Asia/Irkutsk' do |tz|
            tz.offset :o0, 25025, 0, :LMT
            tz.offset :o1, 25025, 0, :IMT
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 28800, 0, :'+08'
            tz.offset :o4, 28800, 3600, :'+09'
            tz.offset :o5, 25200, 3600, :'+08'
            tz.offset :o6, 32400, 0, :'+09'
            
            tz.transition 1879, 12, :o1, -2840165825, 8321063767, 3456
            tz.transition 1920, 1, :o2, -1575874625, 8371635415, 3456
            tz.transition 1930, 6, :o3, -1247554800, 58227557, 24
            tz.transition 1981, 3, :o4, 354902400
            tz.transition 1981, 9, :o3, 370710000
            tz.transition 1982, 3, :o4, 386438400
            tz.transition 1982, 9, :o3, 402246000
            tz.transition 1983, 3, :o4, 417974400
            tz.transition 1983, 9, :o3, 433782000
            tz.transition 1984, 3, :o4, 449596800
            tz.transition 1984, 9, :o3, 465328800
            tz.transition 1985, 3, :o4, 481053600
            tz.transition 1985, 9, :o3, 496778400
            tz.transition 1986, 3, :o4, 512503200
            tz.transition 1986, 9, :o3, 528228000
            tz.transition 1987, 3, :o4, 543952800
            tz.transition 1987, 9, :o3, 559677600
            tz.transition 1988, 3, :o4, 575402400
            tz.transition 1988, 9, :o3, 591127200
            tz.transition 1989, 3, :o4, 606852000
            tz.transition 1989, 9, :o3, 622576800
            tz.transition 1990, 3, :o4, 638301600
            tz.transition 1990, 9, :o3, 654631200
            tz.transition 1991, 3, :o5, 670356000
            tz.transition 1991, 9, :o2, 686084400
            tz.transition 1992, 1, :o3, 695761200
            tz.transition 1992, 3, :o4, 701805600
            tz.transition 1992, 9, :o3, 717530400
            tz.transition 1993, 3, :o4, 733255200
            tz.transition 1993, 9, :o3, 748980000
            tz.transition 1994, 3, :o4, 764704800
            tz.transition 1994, 9, :o3, 780429600
            tz.transition 1995, 3, :o4, 796154400
            tz.transition 1995, 9, :o3, 811879200
            tz.transition 1996, 3, :o4, 828208800
            tz.transition 1996, 10, :o3, 846352800
            tz.transition 1997, 3, :o4, 859658400
            tz.transition 1997, 10, :o3, 877802400
            tz.transition 1998, 3, :o4, 891108000
            tz.transition 1998, 10, :o3, 909252000
            tz.transition 1999, 3, :o4, 922557600
            tz.transition 1999, 10, :o3, 941306400
            tz.transition 2000, 3, :o4, 954007200
            tz.transition 2000, 10, :o3, 972756000
            tz.transition 2001, 3, :o4, 985456800
            tz.transition 2001, 10, :o3, 1004205600
            tz.transition 2002, 3, :o4, 1017511200
            tz.transition 2002, 10, :o3, 1035655200
            tz.transition 2003, 3, :o4, 1048960800
            tz.transition 2003, 10, :o3, 1067104800
            tz.transition 2004, 3, :o4, 1080410400
            tz.transition 2004, 10, :o3, 1099159200
            tz.transition 2005, 3, :o4, 1111860000
            tz.transition 2005, 10, :o3, 1130608800
            tz.transition 2006, 3, :o4, 1143309600
            tz.transition 2006, 10, :o3, 1162058400
            tz.transition 2007, 3, :o4, 1174759200
            tz.transition 2007, 10, :o3, 1193508000
            tz.transition 2008, 3, :o4, 1206813600
            tz.transition 2008, 10, :o3, 1224957600
            tz.transition 2009, 3, :o4, 1238263200
            tz.transition 2009, 10, :o3, 1256407200
            tz.transition 2010, 3, :o4, 1269712800
            tz.transition 2010, 10, :o3, 1288461600
            tz.transition 2011, 3, :o6, 1301162400
            tz.transition 2014, 10, :o3, 1414256400
          end
        end
      end
    end
  end
end
