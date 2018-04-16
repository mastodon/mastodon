# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Bishkek
          include TimezoneDefinition
          
          timezone 'Asia/Bishkek' do |tz|
            tz.offset :o0, 17904, 0, :LMT
            tz.offset :o1, 18000, 0, :'+05'
            tz.offset :o2, 21600, 0, :'+06'
            tz.offset :o3, 21600, 3600, :'+07'
            tz.offset :o4, 18000, 3600, :'+06'
            
            tz.transition 1924, 5, :o1, -1441169904, 4363033127, 1800
            tz.transition 1930, 6, :o2, -1247547600, 58227559, 24
            tz.transition 1981, 3, :o3, 354909600
            tz.transition 1981, 9, :o2, 370717200
            tz.transition 1982, 3, :o3, 386445600
            tz.transition 1982, 9, :o2, 402253200
            tz.transition 1983, 3, :o3, 417981600
            tz.transition 1983, 9, :o2, 433789200
            tz.transition 1984, 3, :o3, 449604000
            tz.transition 1984, 9, :o2, 465336000
            tz.transition 1985, 3, :o3, 481060800
            tz.transition 1985, 9, :o2, 496785600
            tz.transition 1986, 3, :o3, 512510400
            tz.transition 1986, 9, :o2, 528235200
            tz.transition 1987, 3, :o3, 543960000
            tz.transition 1987, 9, :o2, 559684800
            tz.transition 1988, 3, :o3, 575409600
            tz.transition 1988, 9, :o2, 591134400
            tz.transition 1989, 3, :o3, 606859200
            tz.transition 1989, 9, :o2, 622584000
            tz.transition 1990, 3, :o3, 638308800
            tz.transition 1990, 9, :o2, 654638400
            tz.transition 1991, 3, :o4, 670363200
            tz.transition 1991, 8, :o1, 683582400
            tz.transition 1992, 4, :o4, 703018800
            tz.transition 1992, 9, :o1, 717530400
            tz.transition 1993, 4, :o4, 734468400
            tz.transition 1993, 9, :o1, 748980000
            tz.transition 1994, 4, :o4, 765918000
            tz.transition 1994, 9, :o1, 780429600
            tz.transition 1995, 4, :o4, 797367600
            tz.transition 1995, 9, :o1, 811879200
            tz.transition 1996, 4, :o4, 828817200
            tz.transition 1996, 9, :o1, 843933600
            tz.transition 1997, 3, :o4, 859671000
            tz.transition 1997, 10, :o1, 877811400
            tz.transition 1998, 3, :o4, 891120600
            tz.transition 1998, 10, :o1, 909261000
            tz.transition 1999, 3, :o4, 922570200
            tz.transition 1999, 10, :o1, 941315400
            tz.transition 2000, 3, :o4, 954019800
            tz.transition 2000, 10, :o1, 972765000
            tz.transition 2001, 3, :o4, 985469400
            tz.transition 2001, 10, :o1, 1004214600
            tz.transition 2002, 3, :o4, 1017523800
            tz.transition 2002, 10, :o1, 1035664200
            tz.transition 2003, 3, :o4, 1048973400
            tz.transition 2003, 10, :o1, 1067113800
            tz.transition 2004, 3, :o4, 1080423000
            tz.transition 2004, 10, :o1, 1099168200
            tz.transition 2005, 3, :o4, 1111872600
            tz.transition 2005, 8, :o2, 1123783200
          end
        end
      end
    end
  end
end
