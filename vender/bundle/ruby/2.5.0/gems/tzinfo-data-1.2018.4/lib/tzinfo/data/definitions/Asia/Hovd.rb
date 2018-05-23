# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Hovd
          include TimezoneDefinition
          
          timezone 'Asia/Hovd' do |tz|
            tz.offset :o0, 21996, 0, :LMT
            tz.offset :o1, 21600, 0, :'+06'
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 25200, 3600, :'+08'
            
            tz.transition 1905, 7, :o1, -2032927596, 5800939789, 2400
            tz.transition 1977, 12, :o2, 252439200
            tz.transition 1983, 3, :o3, 417978000
            tz.transition 1983, 9, :o2, 433785600
            tz.transition 1984, 3, :o3, 449600400
            tz.transition 1984, 9, :o2, 465321600
            tz.transition 1985, 3, :o3, 481050000
            tz.transition 1985, 9, :o2, 496771200
            tz.transition 1986, 3, :o3, 512499600
            tz.transition 1986, 9, :o2, 528220800
            tz.transition 1987, 3, :o3, 543949200
            tz.transition 1987, 9, :o2, 559670400
            tz.transition 1988, 3, :o3, 575398800
            tz.transition 1988, 9, :o2, 591120000
            tz.transition 1989, 3, :o3, 606848400
            tz.transition 1989, 9, :o2, 622569600
            tz.transition 1990, 3, :o3, 638298000
            tz.transition 1990, 9, :o2, 654624000
            tz.transition 1991, 3, :o3, 670352400
            tz.transition 1991, 9, :o2, 686073600
            tz.transition 1992, 3, :o3, 701802000
            tz.transition 1992, 9, :o2, 717523200
            tz.transition 1993, 3, :o3, 733251600
            tz.transition 1993, 9, :o2, 748972800
            tz.transition 1994, 3, :o3, 764701200
            tz.transition 1994, 9, :o2, 780422400
            tz.transition 1995, 3, :o3, 796150800
            tz.transition 1995, 9, :o2, 811872000
            tz.transition 1996, 3, :o3, 828205200
            tz.transition 1996, 9, :o2, 843926400
            tz.transition 1997, 3, :o3, 859654800
            tz.transition 1997, 9, :o2, 875376000
            tz.transition 1998, 3, :o3, 891104400
            tz.transition 1998, 9, :o2, 906825600
            tz.transition 2001, 4, :o3, 988398000
            tz.transition 2001, 9, :o2, 1001700000
            tz.transition 2002, 3, :o3, 1017428400
            tz.transition 2002, 9, :o2, 1033149600
            tz.transition 2003, 3, :o3, 1048878000
            tz.transition 2003, 9, :o2, 1064599200
            tz.transition 2004, 3, :o3, 1080327600
            tz.transition 2004, 9, :o2, 1096048800
            tz.transition 2005, 3, :o3, 1111777200
            tz.transition 2005, 9, :o2, 1127498400
            tz.transition 2006, 3, :o3, 1143226800
            tz.transition 2006, 9, :o2, 1159552800
            tz.transition 2015, 3, :o3, 1427482800
            tz.transition 2015, 9, :o2, 1443196800
            tz.transition 2016, 3, :o3, 1458932400
            tz.transition 2016, 9, :o2, 1474646400
          end
        end
      end
    end
  end
end
