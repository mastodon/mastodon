# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Samara
          include TimezoneDefinition
          
          timezone 'Europe/Samara' do |tz|
            tz.offset :o0, 12020, 0, :LMT
            tz.offset :o1, 10800, 0, :'+03'
            tz.offset :o2, 14400, 0, :'+04'
            tz.offset :o3, 14400, 3600, :'+05'
            tz.offset :o4, 10800, 3600, :'+04'
            tz.offset :o5, 7200, 3600, :'+03'
            
            tz.transition 1919, 7, :o1, -1593820800, 4844281, 2
            tz.transition 1930, 6, :o2, -1247540400, 19409187, 8
            tz.transition 1981, 3, :o3, 354916800
            tz.transition 1981, 9, :o2, 370724400
            tz.transition 1982, 3, :o3, 386452800
            tz.transition 1982, 9, :o2, 402260400
            tz.transition 1983, 3, :o3, 417988800
            tz.transition 1983, 9, :o2, 433796400
            tz.transition 1984, 3, :o3, 449611200
            tz.transition 1984, 9, :o2, 465343200
            tz.transition 1985, 3, :o3, 481068000
            tz.transition 1985, 9, :o2, 496792800
            tz.transition 1986, 3, :o3, 512517600
            tz.transition 1986, 9, :o2, 528242400
            tz.transition 1987, 3, :o3, 543967200
            tz.transition 1987, 9, :o2, 559692000
            tz.transition 1988, 3, :o3, 575416800
            tz.transition 1988, 9, :o2, 591141600
            tz.transition 1989, 3, :o4, 606866400
            tz.transition 1989, 9, :o1, 622594800
            tz.transition 1990, 3, :o4, 638319600
            tz.transition 1990, 9, :o1, 654649200
            tz.transition 1991, 3, :o5, 670374000
            tz.transition 1991, 9, :o1, 686102400
            tz.transition 1991, 10, :o2, 687916800
            tz.transition 1992, 3, :o3, 701820000
            tz.transition 1992, 9, :o2, 717544800
            tz.transition 1993, 3, :o3, 733269600
            tz.transition 1993, 9, :o2, 748994400
            tz.transition 1994, 3, :o3, 764719200
            tz.transition 1994, 9, :o2, 780444000
            tz.transition 1995, 3, :o3, 796168800
            tz.transition 1995, 9, :o2, 811893600
            tz.transition 1996, 3, :o3, 828223200
            tz.transition 1996, 10, :o2, 846367200
            tz.transition 1997, 3, :o3, 859672800
            tz.transition 1997, 10, :o2, 877816800
            tz.transition 1998, 3, :o3, 891122400
            tz.transition 1998, 10, :o2, 909266400
            tz.transition 1999, 3, :o3, 922572000
            tz.transition 1999, 10, :o2, 941320800
            tz.transition 2000, 3, :o3, 954021600
            tz.transition 2000, 10, :o2, 972770400
            tz.transition 2001, 3, :o3, 985471200
            tz.transition 2001, 10, :o2, 1004220000
            tz.transition 2002, 3, :o3, 1017525600
            tz.transition 2002, 10, :o2, 1035669600
            tz.transition 2003, 3, :o3, 1048975200
            tz.transition 2003, 10, :o2, 1067119200
            tz.transition 2004, 3, :o3, 1080424800
            tz.transition 2004, 10, :o2, 1099173600
            tz.transition 2005, 3, :o3, 1111874400
            tz.transition 2005, 10, :o2, 1130623200
            tz.transition 2006, 3, :o3, 1143324000
            tz.transition 2006, 10, :o2, 1162072800
            tz.transition 2007, 3, :o3, 1174773600
            tz.transition 2007, 10, :o2, 1193522400
            tz.transition 2008, 3, :o3, 1206828000
            tz.transition 2008, 10, :o2, 1224972000
            tz.transition 2009, 3, :o3, 1238277600
            tz.transition 2009, 10, :o2, 1256421600
            tz.transition 2010, 3, :o4, 1269727200
            tz.transition 2010, 10, :o1, 1288479600
            tz.transition 2011, 3, :o2, 1301180400
          end
        end
      end
    end
  end
end
