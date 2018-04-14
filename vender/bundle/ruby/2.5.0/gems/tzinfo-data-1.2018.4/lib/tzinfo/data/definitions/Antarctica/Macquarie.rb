# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module Macquarie
          include TimezoneDefinition
          
          timezone 'Antarctica/Macquarie' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, 36000, 0, :AEST
            tz.offset :o2, 36000, 3600, :AEDT
            tz.offset :o3, 39600, 0, :'+11'
            
            tz.transition 1899, 11, :o1, -2214259200, 4829919, 2
            tz.transition 1916, 9, :o2, -1680508800, 14526823, 6
            tz.transition 1917, 3, :o1, -1665392400, 19370497, 8
            tz.transition 1919, 3, :o0, -1601719200, 29064589, 12
            tz.transition 1948, 3, :o1, -687052800, 4865271, 2
            tz.transition 1967, 9, :o2, -71136000, 14638585, 6
            tz.transition 1968, 3, :o1, -55411200, 14639677, 6
            tz.transition 1968, 10, :o2, -37267200, 14640937, 6
            tz.transition 1969, 3, :o1, -25776000, 14641735, 6
            tz.transition 1969, 10, :o2, -5817600, 14643121, 6
            tz.transition 1970, 3, :o1, 5673600
            tz.transition 1970, 10, :o2, 25632000
            tz.transition 1971, 3, :o1, 37728000
            tz.transition 1971, 10, :o2, 57686400
            tz.transition 1972, 2, :o1, 67968000
            tz.transition 1972, 10, :o2, 89136000
            tz.transition 1973, 3, :o1, 100022400
            tz.transition 1973, 10, :o2, 120585600
            tz.transition 1974, 3, :o1, 131472000
            tz.transition 1974, 10, :o2, 152035200
            tz.transition 1975, 3, :o1, 162921600
            tz.transition 1975, 10, :o2, 183484800
            tz.transition 1976, 3, :o1, 194976000
            tz.transition 1976, 10, :o2, 215539200
            tz.transition 1977, 3, :o1, 226425600
            tz.transition 1977, 10, :o2, 246988800
            tz.transition 1978, 3, :o1, 257875200
            tz.transition 1978, 10, :o2, 278438400
            tz.transition 1979, 3, :o1, 289324800
            tz.transition 1979, 10, :o2, 309888000
            tz.transition 1980, 3, :o1, 320774400
            tz.transition 1980, 10, :o2, 341337600
            tz.transition 1981, 2, :o1, 352224000
            tz.transition 1981, 10, :o2, 372787200
            tz.transition 1982, 3, :o1, 386092800
            tz.transition 1982, 10, :o2, 404841600
            tz.transition 1983, 3, :o1, 417542400
            tz.transition 1983, 10, :o2, 436291200
            tz.transition 1984, 3, :o1, 447177600
            tz.transition 1984, 10, :o2, 467740800
            tz.transition 1985, 3, :o1, 478627200
            tz.transition 1985, 10, :o2, 499190400
            tz.transition 1986, 3, :o1, 510076800
            tz.transition 1986, 10, :o2, 530035200
            tz.transition 1987, 3, :o1, 542736000
            tz.transition 1987, 10, :o2, 562089600
            tz.transition 1988, 3, :o1, 574790400
            tz.transition 1988, 10, :o2, 594144000
            tz.transition 1989, 3, :o1, 606240000
            tz.transition 1989, 10, :o2, 625593600
            tz.transition 1990, 3, :o1, 637689600
            tz.transition 1990, 10, :o2, 657043200
            tz.transition 1991, 3, :o1, 670348800
            tz.transition 1991, 10, :o2, 686678400
            tz.transition 1992, 3, :o1, 701798400
            tz.transition 1992, 10, :o2, 718128000
            tz.transition 1993, 3, :o1, 733248000
            tz.transition 1993, 10, :o2, 749577600
            tz.transition 1994, 3, :o1, 764697600
            tz.transition 1994, 10, :o2, 781027200
            tz.transition 1995, 3, :o1, 796147200
            tz.transition 1995, 9, :o2, 812476800
            tz.transition 1996, 3, :o1, 828201600
            tz.transition 1996, 10, :o2, 844531200
            tz.transition 1997, 3, :o1, 859651200
            tz.transition 1997, 10, :o2, 875980800
            tz.transition 1998, 3, :o1, 891100800
            tz.transition 1998, 10, :o2, 907430400
            tz.transition 1999, 3, :o1, 922550400
            tz.transition 1999, 10, :o2, 938880000
            tz.transition 2000, 3, :o1, 954000000
            tz.transition 2000, 8, :o2, 967305600
            tz.transition 2001, 3, :o1, 985449600
            tz.transition 2001, 10, :o2, 1002384000
            tz.transition 2002, 3, :o1, 1017504000
            tz.transition 2002, 10, :o2, 1033833600
            tz.transition 2003, 3, :o1, 1048953600
            tz.transition 2003, 10, :o2, 1065283200
            tz.transition 2004, 3, :o1, 1080403200
            tz.transition 2004, 10, :o2, 1096732800
            tz.transition 2005, 3, :o1, 1111852800
            tz.transition 2005, 10, :o2, 1128182400
            tz.transition 2006, 4, :o1, 1143907200
            tz.transition 2006, 9, :o2, 1159632000
            tz.transition 2007, 3, :o1, 1174752000
            tz.transition 2007, 10, :o2, 1191686400
            tz.transition 2008, 4, :o1, 1207411200
            tz.transition 2008, 10, :o2, 1223136000
            tz.transition 2009, 4, :o1, 1238860800
            tz.transition 2009, 10, :o2, 1254585600
            tz.transition 2010, 4, :o3, 1270310400
          end
        end
      end
    end
  end
end
