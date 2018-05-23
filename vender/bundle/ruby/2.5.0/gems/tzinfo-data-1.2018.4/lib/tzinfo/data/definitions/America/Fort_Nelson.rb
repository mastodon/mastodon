# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Fort_Nelson
          include TimezoneDefinition
          
          timezone 'America/Fort_Nelson' do |tz|
            tz.offset :o0, -29447, 0, :LMT
            tz.offset :o1, -28800, 0, :PST
            tz.offset :o2, -28800, 3600, :PDT
            tz.offset :o3, -28800, 3600, :PWT
            tz.offset :o4, -28800, 3600, :PPT
            tz.offset :o5, -25200, 0, :MST
            
            tz.transition 1884, 1, :o1, -2713880953, 208152879047, 86400
            tz.transition 1918, 4, :o2, -1632060000, 29060375, 12
            tz.transition 1918, 10, :o1, -1615129200, 19375151, 8
            tz.transition 1942, 2, :o3, -880207200, 29164799, 12
            tz.transition 1945, 8, :o4, -769395600, 58360379, 24
            tz.transition 1945, 9, :o1, -765385200, 19453831, 8
            tz.transition 1947, 4, :o2, -715788000, 29187635, 12
            tz.transition 1947, 9, :o1, -702486000, 19459655, 8
            tz.transition 1948, 4, :o2, -684338400, 29192003, 12
            tz.transition 1948, 9, :o1, -671036400, 19462567, 8
            tz.transition 1949, 4, :o2, -652888800, 29196371, 12
            tz.transition 1949, 9, :o1, -639586800, 19465479, 8
            tz.transition 1950, 4, :o2, -620834400, 29200823, 12
            tz.transition 1950, 9, :o1, -608137200, 19468391, 8
            tz.transition 1951, 4, :o2, -589384800, 29205191, 12
            tz.transition 1951, 9, :o1, -576082800, 19471359, 8
            tz.transition 1952, 4, :o2, -557935200, 29209559, 12
            tz.transition 1952, 9, :o1, -544633200, 19474271, 8
            tz.transition 1953, 4, :o2, -526485600, 29213927, 12
            tz.transition 1953, 9, :o1, -513183600, 19477183, 8
            tz.transition 1954, 4, :o2, -495036000, 29218295, 12
            tz.transition 1954, 9, :o1, -481734000, 19480095, 8
            tz.transition 1955, 4, :o2, -463586400, 29222663, 12
            tz.transition 1955, 9, :o1, -450284400, 19483007, 8
            tz.transition 1956, 4, :o2, -431532000, 29227115, 12
            tz.transition 1956, 9, :o1, -418230000, 19485975, 8
            tz.transition 1957, 4, :o2, -400082400, 29231483, 12
            tz.transition 1957, 9, :o1, -386780400, 19488887, 8
            tz.transition 1958, 4, :o2, -368632800, 29235851, 12
            tz.transition 1958, 9, :o1, -355330800, 19491799, 8
            tz.transition 1959, 4, :o2, -337183200, 29240219, 12
            tz.transition 1959, 9, :o1, -323881200, 19494711, 8
            tz.transition 1960, 4, :o2, -305733600, 29244587, 12
            tz.transition 1960, 9, :o1, -292431600, 19497623, 8
            tz.transition 1961, 4, :o2, -273679200, 29249039, 12
            tz.transition 1961, 9, :o1, -260982000, 19500535, 8
            tz.transition 1962, 4, :o2, -242229600, 29253407, 12
            tz.transition 1962, 10, :o1, -226508400, 19503727, 8
            tz.transition 1963, 4, :o2, -210780000, 29257775, 12
            tz.transition 1963, 10, :o1, -195058800, 19506639, 8
            tz.transition 1964, 4, :o2, -179330400, 29262143, 12
            tz.transition 1964, 10, :o1, -163609200, 19509551, 8
            tz.transition 1965, 4, :o2, -147880800, 29266511, 12
            tz.transition 1965, 10, :o1, -131554800, 19512519, 8
            tz.transition 1966, 4, :o2, -116431200, 29270879, 12
            tz.transition 1966, 10, :o1, -100105200, 19515431, 8
            tz.transition 1967, 4, :o2, -84376800, 29275331, 12
            tz.transition 1967, 10, :o1, -68655600, 19518343, 8
            tz.transition 1968, 4, :o2, -52927200, 29279699, 12
            tz.transition 1968, 10, :o1, -37206000, 19521255, 8
            tz.transition 1969, 4, :o2, -21477600, 29284067, 12
            tz.transition 1969, 10, :o1, -5756400, 19524167, 8
            tz.transition 1970, 4, :o2, 9972000
            tz.transition 1970, 10, :o1, 25693200
            tz.transition 1971, 4, :o2, 41421600
            tz.transition 1971, 10, :o1, 57747600
            tz.transition 1972, 4, :o2, 73476000
            tz.transition 1972, 10, :o1, 89197200
            tz.transition 1973, 4, :o2, 104925600
            tz.transition 1973, 10, :o1, 120646800
            tz.transition 1974, 4, :o2, 136375200
            tz.transition 1974, 10, :o1, 152096400
            tz.transition 1975, 4, :o2, 167824800
            tz.transition 1975, 10, :o1, 183546000
            tz.transition 1976, 4, :o2, 199274400
            tz.transition 1976, 10, :o1, 215600400
            tz.transition 1977, 4, :o2, 230724000
            tz.transition 1977, 10, :o1, 247050000
            tz.transition 1978, 4, :o2, 262778400
            tz.transition 1978, 10, :o1, 278499600
            tz.transition 1979, 4, :o2, 294228000
            tz.transition 1979, 10, :o1, 309949200
            tz.transition 1980, 4, :o2, 325677600
            tz.transition 1980, 10, :o1, 341398800
            tz.transition 1981, 4, :o2, 357127200
            tz.transition 1981, 10, :o1, 372848400
            tz.transition 1982, 4, :o2, 388576800
            tz.transition 1982, 10, :o1, 404902800
            tz.transition 1983, 4, :o2, 420026400
            tz.transition 1983, 10, :o1, 436352400
            tz.transition 1984, 4, :o2, 452080800
            tz.transition 1984, 10, :o1, 467802000
            tz.transition 1985, 4, :o2, 483530400
            tz.transition 1985, 10, :o1, 499251600
            tz.transition 1986, 4, :o2, 514980000
            tz.transition 1986, 10, :o1, 530701200
            tz.transition 1987, 4, :o2, 544615200
            tz.transition 1987, 10, :o1, 562150800
            tz.transition 1988, 4, :o2, 576064800
            tz.transition 1988, 10, :o1, 594205200
            tz.transition 1989, 4, :o2, 607514400
            tz.transition 1989, 10, :o1, 625654800
            tz.transition 1990, 4, :o2, 638964000
            tz.transition 1990, 10, :o1, 657104400
            tz.transition 1991, 4, :o2, 671018400
            tz.transition 1991, 10, :o1, 688554000
            tz.transition 1992, 4, :o2, 702468000
            tz.transition 1992, 10, :o1, 720003600
            tz.transition 1993, 4, :o2, 733917600
            tz.transition 1993, 10, :o1, 752058000
            tz.transition 1994, 4, :o2, 765367200
            tz.transition 1994, 10, :o1, 783507600
            tz.transition 1995, 4, :o2, 796816800
            tz.transition 1995, 10, :o1, 814957200
            tz.transition 1996, 4, :o2, 828871200
            tz.transition 1996, 10, :o1, 846406800
            tz.transition 1997, 4, :o2, 860320800
            tz.transition 1997, 10, :o1, 877856400
            tz.transition 1998, 4, :o2, 891770400
            tz.transition 1998, 10, :o1, 909306000
            tz.transition 1999, 4, :o2, 923220000
            tz.transition 1999, 10, :o1, 941360400
            tz.transition 2000, 4, :o2, 954669600
            tz.transition 2000, 10, :o1, 972810000
            tz.transition 2001, 4, :o2, 986119200
            tz.transition 2001, 10, :o1, 1004259600
            tz.transition 2002, 4, :o2, 1018173600
            tz.transition 2002, 10, :o1, 1035709200
            tz.transition 2003, 4, :o2, 1049623200
            tz.transition 2003, 10, :o1, 1067158800
            tz.transition 2004, 4, :o2, 1081072800
            tz.transition 2004, 10, :o1, 1099213200
            tz.transition 2005, 4, :o2, 1112522400
            tz.transition 2005, 10, :o1, 1130662800
            tz.transition 2006, 4, :o2, 1143972000
            tz.transition 2006, 10, :o1, 1162112400
            tz.transition 2007, 3, :o2, 1173607200
            tz.transition 2007, 11, :o1, 1194166800
            tz.transition 2008, 3, :o2, 1205056800
            tz.transition 2008, 11, :o1, 1225616400
            tz.transition 2009, 3, :o2, 1236506400
            tz.transition 2009, 11, :o1, 1257066000
            tz.transition 2010, 3, :o2, 1268560800
            tz.transition 2010, 11, :o1, 1289120400
            tz.transition 2011, 3, :o2, 1300010400
            tz.transition 2011, 11, :o1, 1320570000
            tz.transition 2012, 3, :o2, 1331460000
            tz.transition 2012, 11, :o1, 1352019600
            tz.transition 2013, 3, :o2, 1362909600
            tz.transition 2013, 11, :o1, 1383469200
            tz.transition 2014, 3, :o2, 1394359200
            tz.transition 2014, 11, :o1, 1414918800
            tz.transition 2015, 3, :o5, 1425808800
          end
        end
      end
    end
  end
end
