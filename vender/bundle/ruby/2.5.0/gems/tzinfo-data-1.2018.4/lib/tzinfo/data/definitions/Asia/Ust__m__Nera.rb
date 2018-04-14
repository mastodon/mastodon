# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Ust__m__Nera
          include TimezoneDefinition
          
          timezone 'Asia/Ust-Nera' do |tz|
            tz.offset :o0, 34374, 0, :LMT
            tz.offset :o1, 28800, 0, :'+08'
            tz.offset :o2, 32400, 0, :'+09'
            tz.offset :o3, 39600, 3600, :'+12'
            tz.offset :o4, 39600, 0, :'+11'
            tz.offset :o5, 36000, 3600, :'+11'
            tz.offset :o6, 36000, 0, :'+10'
            tz.offset :o7, 43200, 0, :'+12'
            
            tz.transition 1919, 12, :o1, -1579426374, 34881222271, 14400
            tz.transition 1930, 6, :o2, -1247558400, 14556889, 6
            tz.transition 1981, 3, :o3, 354898800
            tz.transition 1981, 9, :o4, 370699200
            tz.transition 1982, 3, :o3, 386427600
            tz.transition 1982, 9, :o4, 402235200
            tz.transition 1983, 3, :o3, 417963600
            tz.transition 1983, 9, :o4, 433771200
            tz.transition 1984, 3, :o3, 449586000
            tz.transition 1984, 9, :o4, 465318000
            tz.transition 1985, 3, :o3, 481042800
            tz.transition 1985, 9, :o4, 496767600
            tz.transition 1986, 3, :o3, 512492400
            tz.transition 1986, 9, :o4, 528217200
            tz.transition 1987, 3, :o3, 543942000
            tz.transition 1987, 9, :o4, 559666800
            tz.transition 1988, 3, :o3, 575391600
            tz.transition 1988, 9, :o4, 591116400
            tz.transition 1989, 3, :o3, 606841200
            tz.transition 1989, 9, :o4, 622566000
            tz.transition 1990, 3, :o3, 638290800
            tz.transition 1990, 9, :o4, 654620400
            tz.transition 1991, 3, :o5, 670345200
            tz.transition 1991, 9, :o6, 686073600
            tz.transition 1992, 1, :o4, 695750400
            tz.transition 1992, 3, :o3, 701794800
            tz.transition 1992, 9, :o4, 717519600
            tz.transition 1993, 3, :o3, 733244400
            tz.transition 1993, 9, :o4, 748969200
            tz.transition 1994, 3, :o3, 764694000
            tz.transition 1994, 9, :o4, 780418800
            tz.transition 1995, 3, :o3, 796143600
            tz.transition 1995, 9, :o4, 811868400
            tz.transition 1996, 3, :o3, 828198000
            tz.transition 1996, 10, :o4, 846342000
            tz.transition 1997, 3, :o3, 859647600
            tz.transition 1997, 10, :o4, 877791600
            tz.transition 1998, 3, :o3, 891097200
            tz.transition 1998, 10, :o4, 909241200
            tz.transition 1999, 3, :o3, 922546800
            tz.transition 1999, 10, :o4, 941295600
            tz.transition 2000, 3, :o3, 953996400
            tz.transition 2000, 10, :o4, 972745200
            tz.transition 2001, 3, :o3, 985446000
            tz.transition 2001, 10, :o4, 1004194800
            tz.transition 2002, 3, :o3, 1017500400
            tz.transition 2002, 10, :o4, 1035644400
            tz.transition 2003, 3, :o3, 1048950000
            tz.transition 2003, 10, :o4, 1067094000
            tz.transition 2004, 3, :o3, 1080399600
            tz.transition 2004, 10, :o4, 1099148400
            tz.transition 2005, 3, :o3, 1111849200
            tz.transition 2005, 10, :o4, 1130598000
            tz.transition 2006, 3, :o3, 1143298800
            tz.transition 2006, 10, :o4, 1162047600
            tz.transition 2007, 3, :o3, 1174748400
            tz.transition 2007, 10, :o4, 1193497200
            tz.transition 2008, 3, :o3, 1206802800
            tz.transition 2008, 10, :o4, 1224946800
            tz.transition 2009, 3, :o3, 1238252400
            tz.transition 2009, 10, :o4, 1256396400
            tz.transition 2010, 3, :o3, 1269702000
            tz.transition 2010, 10, :o4, 1288450800
            tz.transition 2011, 3, :o7, 1301151600
            tz.transition 2011, 9, :o4, 1315828800
            tz.transition 2014, 10, :o6, 1414249200
          end
        end
      end
    end
  end
end
