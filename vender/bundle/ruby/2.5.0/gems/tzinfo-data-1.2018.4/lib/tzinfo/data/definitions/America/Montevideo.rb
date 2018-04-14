# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Montevideo
          include TimezoneDefinition
          
          timezone 'America/Montevideo' do |tz|
            tz.offset :o0, -13491, 0, :LMT
            tz.offset :o1, -13491, 0, :MMT
            tz.offset :o2, -14400, 0, :'-04'
            tz.offset :o3, -12600, 1800, :'-03'
            tz.offset :o4, -12600, 0, :'-0330'
            tz.offset :o5, -10800, 1800, :'-0230'
            tz.offset :o6, -10800, 0, :'-03'
            tz.offset :o7, -10800, 3600, :'-02'
            tz.offset :o8, -10800, 5400, :'-0130'
            
            tz.transition 1908, 6, :o1, -1942690509, 23213785499, 9600
            tz.transition 1920, 5, :o2, -1567455309, 23255478299, 9600
            tz.transition 1923, 10, :o3, -1459627200, 7271081, 3
            tz.transition 1924, 4, :o4, -1443819600, 19391013, 8
            tz.transition 1924, 10, :o3, -1428006600, 116354863, 48
            tz.transition 1925, 4, :o4, -1412283600, 19393933, 8
            tz.transition 1925, 10, :o3, -1396470600, 116372383, 48
            tz.transition 1926, 4, :o4, -1380747600, 19396853, 8
            tz.transition 1933, 10, :o3, -1141590600, 116513983, 48
            tz.transition 1934, 4, :o4, -1128286800, 19420229, 8
            tz.transition 1934, 10, :o3, -1110141000, 116531455, 48
            tz.transition 1935, 3, :o4, -1096837200, 19423141, 8
            tz.transition 1935, 10, :o3, -1078691400, 116548927, 48
            tz.transition 1936, 3, :o4, -1065387600, 19426053, 8
            tz.transition 1936, 10, :o3, -1047241800, 116566399, 48
            tz.transition 1937, 3, :o4, -1033938000, 19428965, 8
            tz.transition 1937, 10, :o3, -1015187400, 116584207, 48
            tz.transition 1938, 3, :o4, -1002488400, 19431877, 8
            tz.transition 1938, 10, :o3, -983737800, 116601679, 48
            tz.transition 1939, 3, :o4, -971038800, 19434789, 8
            tz.transition 1939, 10, :o3, -954707400, 116617807, 48
            tz.transition 1940, 3, :o4, -938984400, 19437757, 8
            tz.transition 1940, 10, :o3, -920838600, 116636623, 48
            tz.transition 1941, 3, :o4, -907534800, 19440669, 8
            tz.transition 1941, 8, :o3, -896819400, 116649967, 48
            tz.transition 1942, 12, :o5, -853621200, 19445661, 8
            tz.transition 1943, 3, :o6, -845847000, 116678285, 48
            tz.transition 1959, 5, :o5, -334789200, 19493701, 8
            tz.transition 1959, 11, :o6, -319671000, 116970605, 48
            tz.transition 1960, 1, :o7, -314226000, 19495605, 8
            tz.transition 1960, 3, :o6, -309996000, 29243995, 12
            tz.transition 1965, 4, :o7, -149720400, 19510837, 8
            tz.transition 1965, 9, :o6, -134604000, 29268355, 12
            tz.transition 1968, 5, :o5, -50446800, 19520029, 8
            tz.transition 1968, 12, :o6, -34205400, 117129197, 48
            tz.transition 1970, 4, :o7, 9860400
            tz.transition 1970, 6, :o6, 14176800
            tz.transition 1972, 4, :o7, 72846000
            tz.transition 1972, 7, :o6, 80100000
            tz.transition 1974, 1, :o8, 127278000
            tz.transition 1974, 3, :o5, 132111000
            tz.transition 1974, 9, :o6, 147234600
            tz.transition 1974, 12, :o7, 156913200
            tz.transition 1975, 3, :o6, 165376800
            tz.transition 1976, 12, :o7, 219812400
            tz.transition 1977, 3, :o6, 226461600
            tz.transition 1977, 12, :o7, 250052400
            tz.transition 1978, 3, :o6, 257911200
            tz.transition 1978, 12, :o7, 282711600
            tz.transition 1979, 3, :o6, 289360800
            tz.transition 1979, 4, :o7, 294202800
            tz.transition 1980, 3, :o6, 322020000
            tz.transition 1987, 12, :o7, 566449200
            tz.transition 1988, 2, :o6, 573012000
            tz.transition 1988, 12, :o7, 597812400
            tz.transition 1989, 3, :o6, 605066400
            tz.transition 1989, 10, :o7, 625633200
            tz.transition 1990, 2, :o6, 635911200
            tz.transition 1990, 10, :o7, 656478000
            tz.transition 1991, 3, :o6, 667965600
            tz.transition 1991, 10, :o7, 688532400
            tz.transition 1992, 3, :o6, 699415200
            tz.transition 1992, 10, :o7, 719377200
            tz.transition 1993, 2, :o6, 730864800
            tz.transition 2004, 9, :o7, 1095562800
            tz.transition 2005, 3, :o6, 1111896000
            tz.transition 2005, 10, :o7, 1128834000
            tz.transition 2006, 3, :o6, 1142136000
            tz.transition 2006, 10, :o7, 1159678800
            tz.transition 2007, 3, :o6, 1173585600
            tz.transition 2007, 10, :o7, 1191733200
            tz.transition 2008, 3, :o6, 1205035200
            tz.transition 2008, 10, :o7, 1223182800
            tz.transition 2009, 3, :o6, 1236484800
            tz.transition 2009, 10, :o7, 1254632400
            tz.transition 2010, 3, :o6, 1268539200
            tz.transition 2010, 10, :o7, 1286082000
            tz.transition 2011, 3, :o6, 1299988800
            tz.transition 2011, 10, :o7, 1317531600
            tz.transition 2012, 3, :o6, 1331438400
            tz.transition 2012, 10, :o7, 1349586000
            tz.transition 2013, 3, :o6, 1362888000
            tz.transition 2013, 10, :o7, 1381035600
            tz.transition 2014, 3, :o6, 1394337600
            tz.transition 2014, 10, :o7, 1412485200
            tz.transition 2015, 3, :o6, 1425787200
          end
        end
      end
    end
  end
end
