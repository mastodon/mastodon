# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Cancun
          include TimezoneDefinition
          
          timezone 'America/Cancun' do |tz|
            tz.offset :o0, -20824, 0, :LMT
            tz.offset :o1, -21600, 0, :CST
            tz.offset :o2, -18000, 0, :EST
            tz.offset :o3, -18000, 3600, :EDT
            tz.offset :o4, -21600, 3600, :CDT
            
            tz.transition 1922, 1, :o1, -1514743200, 9692223, 4
            tz.transition 1981, 12, :o2, 377935200
            tz.transition 1996, 4, :o3, 828860400
            tz.transition 1996, 10, :o2, 846396000
            tz.transition 1997, 4, :o3, 860310000
            tz.transition 1997, 10, :o2, 877845600
            tz.transition 1998, 4, :o3, 891759600
            tz.transition 1998, 8, :o4, 902037600
            tz.transition 1998, 10, :o1, 909298800
            tz.transition 1999, 4, :o4, 923212800
            tz.transition 1999, 10, :o1, 941353200
            tz.transition 2000, 4, :o4, 954662400
            tz.transition 2000, 10, :o1, 972802800
            tz.transition 2001, 5, :o4, 989136000
            tz.transition 2001, 9, :o1, 1001833200
            tz.transition 2002, 4, :o4, 1018166400
            tz.transition 2002, 10, :o1, 1035702000
            tz.transition 2003, 4, :o4, 1049616000
            tz.transition 2003, 10, :o1, 1067151600
            tz.transition 2004, 4, :o4, 1081065600
            tz.transition 2004, 10, :o1, 1099206000
            tz.transition 2005, 4, :o4, 1112515200
            tz.transition 2005, 10, :o1, 1130655600
            tz.transition 2006, 4, :o4, 1143964800
            tz.transition 2006, 10, :o1, 1162105200
            tz.transition 2007, 4, :o4, 1175414400
            tz.transition 2007, 10, :o1, 1193554800
            tz.transition 2008, 4, :o4, 1207468800
            tz.transition 2008, 10, :o1, 1225004400
            tz.transition 2009, 4, :o4, 1238918400
            tz.transition 2009, 10, :o1, 1256454000
            tz.transition 2010, 4, :o4, 1270368000
            tz.transition 2010, 10, :o1, 1288508400
            tz.transition 2011, 4, :o4, 1301817600
            tz.transition 2011, 10, :o1, 1319958000
            tz.transition 2012, 4, :o4, 1333267200
            tz.transition 2012, 10, :o1, 1351407600
            tz.transition 2013, 4, :o4, 1365321600
            tz.transition 2013, 10, :o1, 1382857200
            tz.transition 2014, 4, :o4, 1396771200
            tz.transition 2014, 10, :o1, 1414306800
            tz.transition 2015, 2, :o2, 1422777600
          end
        end
      end
    end
  end
end
