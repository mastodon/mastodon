# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Choibalsan
          include TimezoneDefinition
          
          timezone 'Asia/Choibalsan' do |tz|
            tz.offset :o0, 27480, 0, :LMT
            tz.offset :o1, 25200, 0, :'+07'
            tz.offset :o2, 28800, 0, :'+08'
            tz.offset :o3, 32400, 3600, :'+10'
            tz.offset :o4, 32400, 0, :'+09'
            tz.offset :o5, 28800, 3600, :'+09'
            
            tz.transition 1905, 7, :o1, -2032933080, 1740281891, 720
            tz.transition 1977, 12, :o2, 252435600
            tz.transition 1983, 3, :o3, 417974400
            tz.transition 1983, 9, :o4, 433778400
            tz.transition 1984, 3, :o3, 449593200
            tz.transition 1984, 9, :o4, 465314400
            tz.transition 1985, 3, :o3, 481042800
            tz.transition 1985, 9, :o4, 496764000
            tz.transition 1986, 3, :o3, 512492400
            tz.transition 1986, 9, :o4, 528213600
            tz.transition 1987, 3, :o3, 543942000
            tz.transition 1987, 9, :o4, 559663200
            tz.transition 1988, 3, :o3, 575391600
            tz.transition 1988, 9, :o4, 591112800
            tz.transition 1989, 3, :o3, 606841200
            tz.transition 1989, 9, :o4, 622562400
            tz.transition 1990, 3, :o3, 638290800
            tz.transition 1990, 9, :o4, 654616800
            tz.transition 1991, 3, :o3, 670345200
            tz.transition 1991, 9, :o4, 686066400
            tz.transition 1992, 3, :o3, 701794800
            tz.transition 1992, 9, :o4, 717516000
            tz.transition 1993, 3, :o3, 733244400
            tz.transition 1993, 9, :o4, 748965600
            tz.transition 1994, 3, :o3, 764694000
            tz.transition 1994, 9, :o4, 780415200
            tz.transition 1995, 3, :o3, 796143600
            tz.transition 1995, 9, :o4, 811864800
            tz.transition 1996, 3, :o3, 828198000
            tz.transition 1996, 9, :o4, 843919200
            tz.transition 1997, 3, :o3, 859647600
            tz.transition 1997, 9, :o4, 875368800
            tz.transition 1998, 3, :o3, 891097200
            tz.transition 1998, 9, :o4, 906818400
            tz.transition 2001, 4, :o3, 988390800
            tz.transition 2001, 9, :o4, 1001692800
            tz.transition 2002, 3, :o3, 1017421200
            tz.transition 2002, 9, :o4, 1033142400
            tz.transition 2003, 3, :o3, 1048870800
            tz.transition 2003, 9, :o4, 1064592000
            tz.transition 2004, 3, :o3, 1080320400
            tz.transition 2004, 9, :o4, 1096041600
            tz.transition 2005, 3, :o3, 1111770000
            tz.transition 2005, 9, :o4, 1127491200
            tz.transition 2006, 3, :o3, 1143219600
            tz.transition 2006, 9, :o4, 1159545600
            tz.transition 2008, 3, :o2, 1206889200
            tz.transition 2015, 3, :o5, 1427479200
            tz.transition 2015, 9, :o2, 1443193200
            tz.transition 2016, 3, :o5, 1458928800
            tz.transition 2016, 9, :o2, 1474642800
          end
        end
      end
    end
  end
end
