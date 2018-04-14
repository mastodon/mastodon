# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Windhoek
          include TimezoneDefinition
          
          timezone 'Africa/Windhoek' do |tz|
            tz.offset :o0, 4104, 0, :LMT
            tz.offset :o1, 5400, 0, :'+0130'
            tz.offset :o2, 7200, 0, :SAST
            tz.offset :o3, 7200, 3600, :SAST
            tz.offset :o4, 7200, 0, :CAT
            tz.offset :o5, 3600, 0, :WAT
            tz.offset :o6, 3600, 3600, :WAST
            
            tz.transition 1892, 2, :o1, -2458170504, 964854581, 400
            tz.transition 1903, 2, :o2, -2109288600, 38658791, 16
            tz.transition 1942, 9, :o3, -860976000, 4861245, 2
            tz.transition 1943, 3, :o2, -845254800, 58339307, 24
            tz.transition 1990, 3, :o4, 637970400
            tz.transition 1994, 3, :o5, 764200800
            tz.transition 1994, 9, :o6, 778640400
            tz.transition 1995, 4, :o5, 796780800
            tz.transition 1995, 9, :o6, 810090000
            tz.transition 1996, 4, :o5, 828835200
            tz.transition 1996, 9, :o6, 841539600
            tz.transition 1997, 4, :o5, 860284800
            tz.transition 1997, 9, :o6, 873594000
            tz.transition 1998, 4, :o5, 891734400
            tz.transition 1998, 9, :o6, 905043600
            tz.transition 1999, 4, :o5, 923184000
            tz.transition 1999, 9, :o6, 936493200
            tz.transition 2000, 4, :o5, 954633600
            tz.transition 2000, 9, :o6, 967942800
            tz.transition 2001, 4, :o5, 986083200
            tz.transition 2001, 9, :o6, 999392400
            tz.transition 2002, 4, :o5, 1018137600
            tz.transition 2002, 9, :o6, 1030842000
            tz.transition 2003, 4, :o5, 1049587200
            tz.transition 2003, 9, :o6, 1062896400
            tz.transition 2004, 4, :o5, 1081036800
            tz.transition 2004, 9, :o6, 1094346000
            tz.transition 2005, 4, :o5, 1112486400
            tz.transition 2005, 9, :o6, 1125795600
            tz.transition 2006, 4, :o5, 1143936000
            tz.transition 2006, 9, :o6, 1157245200
            tz.transition 2007, 4, :o5, 1175385600
            tz.transition 2007, 9, :o6, 1188694800
            tz.transition 2008, 4, :o5, 1207440000
            tz.transition 2008, 9, :o6, 1220749200
            tz.transition 2009, 4, :o5, 1238889600
            tz.transition 2009, 9, :o6, 1252198800
            tz.transition 2010, 4, :o5, 1270339200
            tz.transition 2010, 9, :o6, 1283648400
            tz.transition 2011, 4, :o5, 1301788800
            tz.transition 2011, 9, :o6, 1315098000
            tz.transition 2012, 4, :o5, 1333238400
            tz.transition 2012, 9, :o6, 1346547600
            tz.transition 2013, 4, :o5, 1365292800
            tz.transition 2013, 9, :o6, 1377997200
            tz.transition 2014, 4, :o5, 1396742400
            tz.transition 2014, 9, :o6, 1410051600
            tz.transition 2015, 4, :o5, 1428192000
            tz.transition 2015, 9, :o6, 1441501200
            tz.transition 2016, 4, :o5, 1459641600
            tz.transition 2016, 9, :o6, 1472950800
            tz.transition 2017, 4, :o5, 1491091200
            tz.transition 2017, 9, :o4, 1504400400
          end
        end
      end
    end
  end
end
