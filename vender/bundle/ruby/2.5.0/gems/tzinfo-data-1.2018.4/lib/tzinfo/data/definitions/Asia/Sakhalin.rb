# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Sakhalin
          include TimezoneDefinition
          
          timezone 'Asia/Sakhalin' do |tz|
            tz.offset :o0, 34248, 0, :LMT
            tz.offset :o1, 32400, 0, :'+09'
            tz.offset :o2, 39600, 0, :'+11'
            tz.offset :o3, 39600, 3600, :'+12'
            tz.offset :o4, 36000, 3600, :'+11'
            tz.offset :o5, 36000, 0, :'+10'
            
            tz.transition 1905, 8, :o1, -2031039048, 8701488373, 3600
            tz.transition 1945, 8, :o2, -768560400, 19453537, 8
            tz.transition 1981, 3, :o3, 354891600
            tz.transition 1981, 9, :o2, 370699200
            tz.transition 1982, 3, :o3, 386427600
            tz.transition 1982, 9, :o2, 402235200
            tz.transition 1983, 3, :o3, 417963600
            tz.transition 1983, 9, :o2, 433771200
            tz.transition 1984, 3, :o3, 449586000
            tz.transition 1984, 9, :o2, 465318000
            tz.transition 1985, 3, :o3, 481042800
            tz.transition 1985, 9, :o2, 496767600
            tz.transition 1986, 3, :o3, 512492400
            tz.transition 1986, 9, :o2, 528217200
            tz.transition 1987, 3, :o3, 543942000
            tz.transition 1987, 9, :o2, 559666800
            tz.transition 1988, 3, :o3, 575391600
            tz.transition 1988, 9, :o2, 591116400
            tz.transition 1989, 3, :o3, 606841200
            tz.transition 1989, 9, :o2, 622566000
            tz.transition 1990, 3, :o3, 638290800
            tz.transition 1990, 9, :o2, 654620400
            tz.transition 1991, 3, :o4, 670345200
            tz.transition 1991, 9, :o5, 686073600
            tz.transition 1992, 1, :o2, 695750400
            tz.transition 1992, 3, :o3, 701794800
            tz.transition 1992, 9, :o2, 717519600
            tz.transition 1993, 3, :o3, 733244400
            tz.transition 1993, 9, :o2, 748969200
            tz.transition 1994, 3, :o3, 764694000
            tz.transition 1994, 9, :o2, 780418800
            tz.transition 1995, 3, :o3, 796143600
            tz.transition 1995, 9, :o2, 811868400
            tz.transition 1996, 3, :o3, 828198000
            tz.transition 1996, 10, :o2, 846342000
            tz.transition 1997, 3, :o4, 859647600
            tz.transition 1997, 10, :o5, 877795200
            tz.transition 1998, 3, :o4, 891100800
            tz.transition 1998, 10, :o5, 909244800
            tz.transition 1999, 3, :o4, 922550400
            tz.transition 1999, 10, :o5, 941299200
            tz.transition 2000, 3, :o4, 954000000
            tz.transition 2000, 10, :o5, 972748800
            tz.transition 2001, 3, :o4, 985449600
            tz.transition 2001, 10, :o5, 1004198400
            tz.transition 2002, 3, :o4, 1017504000
            tz.transition 2002, 10, :o5, 1035648000
            tz.transition 2003, 3, :o4, 1048953600
            tz.transition 2003, 10, :o5, 1067097600
            tz.transition 2004, 3, :o4, 1080403200
            tz.transition 2004, 10, :o5, 1099152000
            tz.transition 2005, 3, :o4, 1111852800
            tz.transition 2005, 10, :o5, 1130601600
            tz.transition 2006, 3, :o4, 1143302400
            tz.transition 2006, 10, :o5, 1162051200
            tz.transition 2007, 3, :o4, 1174752000
            tz.transition 2007, 10, :o5, 1193500800
            tz.transition 2008, 3, :o4, 1206806400
            tz.transition 2008, 10, :o5, 1224950400
            tz.transition 2009, 3, :o4, 1238256000
            tz.transition 2009, 10, :o5, 1256400000
            tz.transition 2010, 3, :o4, 1269705600
            tz.transition 2010, 10, :o5, 1288454400
            tz.transition 2011, 3, :o2, 1301155200
            tz.transition 2014, 10, :o5, 1414249200
            tz.transition 2016, 3, :o2, 1459008000
          end
        end
      end
    end
  end
end
