# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Novosibirsk
          include TimezoneDefinition
          
          timezone 'Asia/Novosibirsk' do |tz|
            tz.offset :o0, 19900, 0, :LMT
            tz.offset :o1, 21600, 0, :'+06'
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 25200, 3600, :'+08'
            tz.offset :o4, 21600, 3600, :'+07'
            
            tz.transition 1919, 12, :o1, -1579476700, 2092872833, 864
            tz.transition 1930, 6, :o2, -1247551200, 9704593, 4
            tz.transition 1981, 3, :o3, 354906000
            tz.transition 1981, 9, :o2, 370713600
            tz.transition 1982, 3, :o3, 386442000
            tz.transition 1982, 9, :o2, 402249600
            tz.transition 1983, 3, :o3, 417978000
            tz.transition 1983, 9, :o2, 433785600
            tz.transition 1984, 3, :o3, 449600400
            tz.transition 1984, 9, :o2, 465332400
            tz.transition 1985, 3, :o3, 481057200
            tz.transition 1985, 9, :o2, 496782000
            tz.transition 1986, 3, :o3, 512506800
            tz.transition 1986, 9, :o2, 528231600
            tz.transition 1987, 3, :o3, 543956400
            tz.transition 1987, 9, :o2, 559681200
            tz.transition 1988, 3, :o3, 575406000
            tz.transition 1988, 9, :o2, 591130800
            tz.transition 1989, 3, :o3, 606855600
            tz.transition 1989, 9, :o2, 622580400
            tz.transition 1990, 3, :o3, 638305200
            tz.transition 1990, 9, :o2, 654634800
            tz.transition 1991, 3, :o4, 670359600
            tz.transition 1991, 9, :o1, 686088000
            tz.transition 1992, 1, :o2, 695764800
            tz.transition 1992, 3, :o3, 701809200
            tz.transition 1992, 9, :o2, 717534000
            tz.transition 1993, 3, :o3, 733258800
            tz.transition 1993, 5, :o4, 738086400
            tz.transition 1993, 9, :o1, 748987200
            tz.transition 1994, 3, :o4, 764712000
            tz.transition 1994, 9, :o1, 780436800
            tz.transition 1995, 3, :o4, 796161600
            tz.transition 1995, 9, :o1, 811886400
            tz.transition 1996, 3, :o4, 828216000
            tz.transition 1996, 10, :o1, 846360000
            tz.transition 1997, 3, :o4, 859665600
            tz.transition 1997, 10, :o1, 877809600
            tz.transition 1998, 3, :o4, 891115200
            tz.transition 1998, 10, :o1, 909259200
            tz.transition 1999, 3, :o4, 922564800
            tz.transition 1999, 10, :o1, 941313600
            tz.transition 2000, 3, :o4, 954014400
            tz.transition 2000, 10, :o1, 972763200
            tz.transition 2001, 3, :o4, 985464000
            tz.transition 2001, 10, :o1, 1004212800
            tz.transition 2002, 3, :o4, 1017518400
            tz.transition 2002, 10, :o1, 1035662400
            tz.transition 2003, 3, :o4, 1048968000
            tz.transition 2003, 10, :o1, 1067112000
            tz.transition 2004, 3, :o4, 1080417600
            tz.transition 2004, 10, :o1, 1099166400
            tz.transition 2005, 3, :o4, 1111867200
            tz.transition 2005, 10, :o1, 1130616000
            tz.transition 2006, 3, :o4, 1143316800
            tz.transition 2006, 10, :o1, 1162065600
            tz.transition 2007, 3, :o4, 1174766400
            tz.transition 2007, 10, :o1, 1193515200
            tz.transition 2008, 3, :o4, 1206820800
            tz.transition 2008, 10, :o1, 1224964800
            tz.transition 2009, 3, :o4, 1238270400
            tz.transition 2009, 10, :o1, 1256414400
            tz.transition 2010, 3, :o4, 1269720000
            tz.transition 2010, 10, :o1, 1288468800
            tz.transition 2011, 3, :o2, 1301169600
            tz.transition 2014, 10, :o1, 1414263600
            tz.transition 2016, 7, :o2, 1469304000
          end
        end
      end
    end
  end
end
