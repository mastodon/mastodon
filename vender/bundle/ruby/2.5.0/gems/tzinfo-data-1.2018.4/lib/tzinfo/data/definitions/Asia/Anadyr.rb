# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Anadyr
          include TimezoneDefinition
          
          timezone 'Asia/Anadyr' do |tz|
            tz.offset :o0, 42596, 0, :LMT
            tz.offset :o1, 43200, 0, :'+12'
            tz.offset :o2, 46800, 0, :'+13'
            tz.offset :o3, 46800, 3600, :'+14'
            tz.offset :o4, 43200, 3600, :'+13'
            tz.offset :o5, 39600, 3600, :'+12'
            tz.offset :o6, 39600, 0, :'+11'
            
            tz.transition 1924, 5, :o1, -1441194596, 52356391351, 21600
            tz.transition 1930, 6, :o2, -1247572800, 2426148, 1
            tz.transition 1981, 3, :o3, 354884400
            tz.transition 1981, 9, :o2, 370692000
            tz.transition 1982, 3, :o4, 386420400
            tz.transition 1982, 9, :o1, 402231600
            tz.transition 1983, 3, :o4, 417960000
            tz.transition 1983, 9, :o1, 433767600
            tz.transition 1984, 3, :o4, 449582400
            tz.transition 1984, 9, :o1, 465314400
            tz.transition 1985, 3, :o4, 481039200
            tz.transition 1985, 9, :o1, 496764000
            tz.transition 1986, 3, :o4, 512488800
            tz.transition 1986, 9, :o1, 528213600
            tz.transition 1987, 3, :o4, 543938400
            tz.transition 1987, 9, :o1, 559663200
            tz.transition 1988, 3, :o4, 575388000
            tz.transition 1988, 9, :o1, 591112800
            tz.transition 1989, 3, :o4, 606837600
            tz.transition 1989, 9, :o1, 622562400
            tz.transition 1990, 3, :o4, 638287200
            tz.transition 1990, 9, :o1, 654616800
            tz.transition 1991, 3, :o5, 670341600
            tz.transition 1991, 9, :o6, 686070000
            tz.transition 1992, 1, :o1, 695746800
            tz.transition 1992, 3, :o4, 701791200
            tz.transition 1992, 9, :o1, 717516000
            tz.transition 1993, 3, :o4, 733240800
            tz.transition 1993, 9, :o1, 748965600
            tz.transition 1994, 3, :o4, 764690400
            tz.transition 1994, 9, :o1, 780415200
            tz.transition 1995, 3, :o4, 796140000
            tz.transition 1995, 9, :o1, 811864800
            tz.transition 1996, 3, :o4, 828194400
            tz.transition 1996, 10, :o1, 846338400
            tz.transition 1997, 3, :o4, 859644000
            tz.transition 1997, 10, :o1, 877788000
            tz.transition 1998, 3, :o4, 891093600
            tz.transition 1998, 10, :o1, 909237600
            tz.transition 1999, 3, :o4, 922543200
            tz.transition 1999, 10, :o1, 941292000
            tz.transition 2000, 3, :o4, 953992800
            tz.transition 2000, 10, :o1, 972741600
            tz.transition 2001, 3, :o4, 985442400
            tz.transition 2001, 10, :o1, 1004191200
            tz.transition 2002, 3, :o4, 1017496800
            tz.transition 2002, 10, :o1, 1035640800
            tz.transition 2003, 3, :o4, 1048946400
            tz.transition 2003, 10, :o1, 1067090400
            tz.transition 2004, 3, :o4, 1080396000
            tz.transition 2004, 10, :o1, 1099144800
            tz.transition 2005, 3, :o4, 1111845600
            tz.transition 2005, 10, :o1, 1130594400
            tz.transition 2006, 3, :o4, 1143295200
            tz.transition 2006, 10, :o1, 1162044000
            tz.transition 2007, 3, :o4, 1174744800
            tz.transition 2007, 10, :o1, 1193493600
            tz.transition 2008, 3, :o4, 1206799200
            tz.transition 2008, 10, :o1, 1224943200
            tz.transition 2009, 3, :o4, 1238248800
            tz.transition 2009, 10, :o1, 1256392800
            tz.transition 2010, 3, :o5, 1269698400
            tz.transition 2010, 10, :o6, 1288450800
            tz.transition 2011, 3, :o1, 1301151600
          end
        end
      end
    end
  end
end
