# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Vladivostok
          include TimezoneDefinition
          
          timezone 'Asia/Vladivostok' do |tz|
            tz.offset :o0, 31651, 0, :LMT
            tz.offset :o1, 32400, 0, :'+09'
            tz.offset :o2, 36000, 0, :'+10'
            tz.offset :o3, 36000, 3600, :'+11'
            tz.offset :o4, 32400, 3600, :'+10'
            tz.offset :o5, 39600, 0, :'+11'
            
            tz.transition 1922, 11, :o1, -1487321251, 209379438749, 86400
            tz.transition 1930, 6, :o2, -1247562000, 19409185, 8
            tz.transition 1981, 3, :o3, 354895200
            tz.transition 1981, 9, :o2, 370702800
            tz.transition 1982, 3, :o3, 386431200
            tz.transition 1982, 9, :o2, 402238800
            tz.transition 1983, 3, :o3, 417967200
            tz.transition 1983, 9, :o2, 433774800
            tz.transition 1984, 3, :o3, 449589600
            tz.transition 1984, 9, :o2, 465321600
            tz.transition 1985, 3, :o3, 481046400
            tz.transition 1985, 9, :o2, 496771200
            tz.transition 1986, 3, :o3, 512496000
            tz.transition 1986, 9, :o2, 528220800
            tz.transition 1987, 3, :o3, 543945600
            tz.transition 1987, 9, :o2, 559670400
            tz.transition 1988, 3, :o3, 575395200
            tz.transition 1988, 9, :o2, 591120000
            tz.transition 1989, 3, :o3, 606844800
            tz.transition 1989, 9, :o2, 622569600
            tz.transition 1990, 3, :o3, 638294400
            tz.transition 1990, 9, :o2, 654624000
            tz.transition 1991, 3, :o4, 670348800
            tz.transition 1991, 9, :o1, 686077200
            tz.transition 1992, 1, :o2, 695754000
            tz.transition 1992, 3, :o3, 701798400
            tz.transition 1992, 9, :o2, 717523200
            tz.transition 1993, 3, :o3, 733248000
            tz.transition 1993, 9, :o2, 748972800
            tz.transition 1994, 3, :o3, 764697600
            tz.transition 1994, 9, :o2, 780422400
            tz.transition 1995, 3, :o3, 796147200
            tz.transition 1995, 9, :o2, 811872000
            tz.transition 1996, 3, :o3, 828201600
            tz.transition 1996, 10, :o2, 846345600
            tz.transition 1997, 3, :o3, 859651200
            tz.transition 1997, 10, :o2, 877795200
            tz.transition 1998, 3, :o3, 891100800
            tz.transition 1998, 10, :o2, 909244800
            tz.transition 1999, 3, :o3, 922550400
            tz.transition 1999, 10, :o2, 941299200
            tz.transition 2000, 3, :o3, 954000000
            tz.transition 2000, 10, :o2, 972748800
            tz.transition 2001, 3, :o3, 985449600
            tz.transition 2001, 10, :o2, 1004198400
            tz.transition 2002, 3, :o3, 1017504000
            tz.transition 2002, 10, :o2, 1035648000
            tz.transition 2003, 3, :o3, 1048953600
            tz.transition 2003, 10, :o2, 1067097600
            tz.transition 2004, 3, :o3, 1080403200
            tz.transition 2004, 10, :o2, 1099152000
            tz.transition 2005, 3, :o3, 1111852800
            tz.transition 2005, 10, :o2, 1130601600
            tz.transition 2006, 3, :o3, 1143302400
            tz.transition 2006, 10, :o2, 1162051200
            tz.transition 2007, 3, :o3, 1174752000
            tz.transition 2007, 10, :o2, 1193500800
            tz.transition 2008, 3, :o3, 1206806400
            tz.transition 2008, 10, :o2, 1224950400
            tz.transition 2009, 3, :o3, 1238256000
            tz.transition 2009, 10, :o2, 1256400000
            tz.transition 2010, 3, :o3, 1269705600
            tz.transition 2010, 10, :o2, 1288454400
            tz.transition 2011, 3, :o5, 1301155200
            tz.transition 2014, 10, :o2, 1414249200
          end
        end
      end
    end
  end
end
