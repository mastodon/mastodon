# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Kamchatka
          include TimezoneDefinition
          
          timezone 'Asia/Kamchatka' do |tz|
            tz.offset :o0, 38076, 0, :LMT
            tz.offset :o1, 39600, 0, :'+11'
            tz.offset :o2, 43200, 0, :'+12'
            tz.offset :o3, 43200, 3600, :'+13'
            tz.offset :o4, 39600, 3600, :'+12'
            
            tz.transition 1922, 11, :o1, -1487759676, 17448250027, 7200
            tz.transition 1930, 6, :o2, -1247569200, 58227553, 24
            tz.transition 1981, 3, :o3, 354888000
            tz.transition 1981, 9, :o2, 370695600
            tz.transition 1982, 3, :o3, 386424000
            tz.transition 1982, 9, :o2, 402231600
            tz.transition 1983, 3, :o3, 417960000
            tz.transition 1983, 9, :o2, 433767600
            tz.transition 1984, 3, :o3, 449582400
            tz.transition 1984, 9, :o2, 465314400
            tz.transition 1985, 3, :o3, 481039200
            tz.transition 1985, 9, :o2, 496764000
            tz.transition 1986, 3, :o3, 512488800
            tz.transition 1986, 9, :o2, 528213600
            tz.transition 1987, 3, :o3, 543938400
            tz.transition 1987, 9, :o2, 559663200
            tz.transition 1988, 3, :o3, 575388000
            tz.transition 1988, 9, :o2, 591112800
            tz.transition 1989, 3, :o3, 606837600
            tz.transition 1989, 9, :o2, 622562400
            tz.transition 1990, 3, :o3, 638287200
            tz.transition 1990, 9, :o2, 654616800
            tz.transition 1991, 3, :o4, 670341600
            tz.transition 1991, 9, :o1, 686070000
            tz.transition 1992, 1, :o2, 695746800
            tz.transition 1992, 3, :o3, 701791200
            tz.transition 1992, 9, :o2, 717516000
            tz.transition 1993, 3, :o3, 733240800
            tz.transition 1993, 9, :o2, 748965600
            tz.transition 1994, 3, :o3, 764690400
            tz.transition 1994, 9, :o2, 780415200
            tz.transition 1995, 3, :o3, 796140000
            tz.transition 1995, 9, :o2, 811864800
            tz.transition 1996, 3, :o3, 828194400
            tz.transition 1996, 10, :o2, 846338400
            tz.transition 1997, 3, :o3, 859644000
            tz.transition 1997, 10, :o2, 877788000
            tz.transition 1998, 3, :o3, 891093600
            tz.transition 1998, 10, :o2, 909237600
            tz.transition 1999, 3, :o3, 922543200
            tz.transition 1999, 10, :o2, 941292000
            tz.transition 2000, 3, :o3, 953992800
            tz.transition 2000, 10, :o2, 972741600
            tz.transition 2001, 3, :o3, 985442400
            tz.transition 2001, 10, :o2, 1004191200
            tz.transition 2002, 3, :o3, 1017496800
            tz.transition 2002, 10, :o2, 1035640800
            tz.transition 2003, 3, :o3, 1048946400
            tz.transition 2003, 10, :o2, 1067090400
            tz.transition 2004, 3, :o3, 1080396000
            tz.transition 2004, 10, :o2, 1099144800
            tz.transition 2005, 3, :o3, 1111845600
            tz.transition 2005, 10, :o2, 1130594400
            tz.transition 2006, 3, :o3, 1143295200
            tz.transition 2006, 10, :o2, 1162044000
            tz.transition 2007, 3, :o3, 1174744800
            tz.transition 2007, 10, :o2, 1193493600
            tz.transition 2008, 3, :o3, 1206799200
            tz.transition 2008, 10, :o2, 1224943200
            tz.transition 2009, 3, :o3, 1238248800
            tz.transition 2009, 10, :o2, 1256392800
            tz.transition 2010, 3, :o4, 1269698400
            tz.transition 2010, 10, :o1, 1288450800
            tz.transition 2011, 3, :o2, 1301151600
          end
        end
      end
    end
  end
end
