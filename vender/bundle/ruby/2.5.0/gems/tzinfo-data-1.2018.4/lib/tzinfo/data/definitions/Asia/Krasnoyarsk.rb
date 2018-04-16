# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Asia
        module Krasnoyarsk
          include TimezoneDefinition
          
          timezone 'Asia/Krasnoyarsk' do |tz|
            tz.offset :o0, 22286, 0, :LMT
            tz.offset :o1, 21600, 0, :'+06'
            tz.offset :o2, 25200, 0, :'+07'
            tz.offset :o3, 25200, 3600, :'+08'
            tz.offset :o4, 21600, 3600, :'+07'
            tz.offset :o5, 28800, 0, :'+08'
            
            tz.transition 1920, 1, :o1, -1577513486, 104644623257, 43200
            tz.transition 1930, 6, :o2, -1247551200, 9704593, 4
            tz.transition 1981, 3, :o3, 354906000
            tz.transition 1981, 9, :o2, 370713600
            tz.transition 1982, 3, :o3, 386442000
            tz.transition 1982, 9, :o2, 402249600
            tz.transition 1983, 3, :o3, 417978000
            tz.transition 1983, 9, :o2, 433785600
            tz.transition 1984, 3, :o3, 449600400
            tz.transition 1984, 9, :o2, 465332400
            tz.transition 1985, 3, :o3, 481057200
            tz.transition 1985, 9, :o2, 496782000
            tz.transition 1986, 3, :o3, 512506800
            tz.transition 1986, 9, :o2, 528231600
            tz.transition 1987, 3, :o3, 543956400
            tz.transition 1987, 9, :o2, 559681200
            tz.transition 1988, 3, :o3, 575406000
            tz.transition 1988, 9, :o2, 591130800
            tz.transition 1989, 3, :o3, 606855600
            tz.transition 1989, 9, :o2, 622580400
            tz.transition 1990, 3, :o3, 638305200
            tz.transition 1990, 9, :o2, 654634800
            tz.transition 1991, 3, :o4, 670359600
            tz.transition 1991, 9, :o1, 686088000
            tz.transition 1992, 1, :o2, 695764800
            tz.transition 1992, 3, :o3, 701809200
            tz.transition 1992, 9, :o2, 717534000
            tz.transition 1993, 3, :o3, 733258800
            tz.transition 1993, 9, :o2, 748983600
            tz.transition 1994, 3, :o3, 764708400
            tz.transition 1994, 9, :o2, 780433200
            tz.transition 1995, 3, :o3, 796158000
            tz.transition 1995, 9, :o2, 811882800
            tz.transition 1996, 3, :o3, 828212400
            tz.transition 1996, 10, :o2, 846356400
            tz.transition 1997, 3, :o3, 859662000
            tz.transition 1997, 10, :o2, 877806000
            tz.transition 1998, 3, :o3, 891111600
            tz.transition 1998, 10, :o2, 909255600
            tz.transition 1999, 3, :o3, 922561200
            tz.transition 1999, 10, :o2, 941310000
            tz.transition 2000, 3, :o3, 954010800
            tz.transition 2000, 10, :o2, 972759600
            tz.transition 2001, 3, :o3, 985460400
            tz.transition 2001, 10, :o2, 1004209200
            tz.transition 2002, 3, :o3, 1017514800
            tz.transition 2002, 10, :o2, 1035658800
            tz.transition 2003, 3, :o3, 1048964400
            tz.transition 2003, 10, :o2, 1067108400
            tz.transition 2004, 3, :o3, 1080414000
            tz.transition 2004, 10, :o2, 1099162800
            tz.transition 2005, 3, :o3, 1111863600
            tz.transition 2005, 10, :o2, 1130612400
            tz.transition 2006, 3, :o3, 1143313200
            tz.transition 2006, 10, :o2, 1162062000
            tz.transition 2007, 3, :o3, 1174762800
            tz.transition 2007, 10, :o2, 1193511600
            tz.transition 2008, 3, :o3, 1206817200
            tz.transition 2008, 10, :o2, 1224961200
            tz.transition 2009, 3, :o3, 1238266800
            tz.transition 2009, 10, :o2, 1256410800
            tz.transition 2010, 3, :o3, 1269716400
            tz.transition 2010, 10, :o2, 1288465200
            tz.transition 2011, 3, :o5, 1301166000
            tz.transition 2014, 10, :o2, 1414260000
          end
        end
      end
    end
  end
end
