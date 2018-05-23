# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Astrakhan
          include TimezoneDefinition
          
          timezone 'Europe/Astrakhan' do |tz|
            tz.offset :o0, 11532, 0, :LMT
            tz.offset :o1, 10800, 0, :'+03'
            tz.offset :o2, 14400, 0, :'+04'
            tz.offset :o3, 14400, 3600, :'+05'
            tz.offset :o4, 10800, 3600, :'+04'
            
            tz.transition 1924, 4, :o1, -1441249932, 17452125839, 7200
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
            tz.transition 1991, 3, :o2, 670374000
            tz.transition 1992, 3, :o4, 701820000
            tz.transition 1992, 9, :o1, 717548400
            tz.transition 1993, 3, :o4, 733273200
            tz.transition 1993, 9, :o1, 748998000
            tz.transition 1994, 3, :o4, 764722800
            tz.transition 1994, 9, :o1, 780447600
            tz.transition 1995, 3, :o4, 796172400
            tz.transition 1995, 9, :o1, 811897200
            tz.transition 1996, 3, :o4, 828226800
            tz.transition 1996, 10, :o1, 846370800
            tz.transition 1997, 3, :o4, 859676400
            tz.transition 1997, 10, :o1, 877820400
            tz.transition 1998, 3, :o4, 891126000
            tz.transition 1998, 10, :o1, 909270000
            tz.transition 1999, 3, :o4, 922575600
            tz.transition 1999, 10, :o1, 941324400
            tz.transition 2000, 3, :o4, 954025200
            tz.transition 2000, 10, :o1, 972774000
            tz.transition 2001, 3, :o4, 985474800
            tz.transition 2001, 10, :o1, 1004223600
            tz.transition 2002, 3, :o4, 1017529200
            tz.transition 2002, 10, :o1, 1035673200
            tz.transition 2003, 3, :o4, 1048978800
            tz.transition 2003, 10, :o1, 1067122800
            tz.transition 2004, 3, :o4, 1080428400
            tz.transition 2004, 10, :o1, 1099177200
            tz.transition 2005, 3, :o4, 1111878000
            tz.transition 2005, 10, :o1, 1130626800
            tz.transition 2006, 3, :o4, 1143327600
            tz.transition 2006, 10, :o1, 1162076400
            tz.transition 2007, 3, :o4, 1174777200
            tz.transition 2007, 10, :o1, 1193526000
            tz.transition 2008, 3, :o4, 1206831600
            tz.transition 2008, 10, :o1, 1224975600
            tz.transition 2009, 3, :o4, 1238281200
            tz.transition 2009, 10, :o1, 1256425200
            tz.transition 2010, 3, :o4, 1269730800
            tz.transition 2010, 10, :o1, 1288479600
            tz.transition 2011, 3, :o2, 1301180400
            tz.transition 2014, 10, :o1, 1414274400
            tz.transition 2016, 3, :o2, 1459033200
          end
        end
      end
    end
  end
end
