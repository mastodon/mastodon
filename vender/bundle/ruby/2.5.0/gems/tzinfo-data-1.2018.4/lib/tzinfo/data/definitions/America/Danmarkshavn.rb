# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module America
        module Danmarkshavn
          include TimezoneDefinition
          
          timezone 'America/Danmarkshavn' do |tz|
            tz.offset :o0, -4480, 0, :LMT
            tz.offset :o1, -10800, 0, :'-03'
            tz.offset :o2, -10800, 3600, :'-02'
            tz.offset :o3, 0, 0, :GMT
            
            tz.transition 1916, 7, :o1, -1686091520, 653689589, 270
            tz.transition 1980, 4, :o2, 323845200
            tz.transition 1980, 9, :o1, 338950800
            tz.transition 1981, 3, :o2, 354675600
            tz.transition 1981, 9, :o1, 370400400
            tz.transition 1982, 3, :o2, 386125200
            tz.transition 1982, 9, :o1, 401850000
            tz.transition 1983, 3, :o2, 417574800
            tz.transition 1983, 9, :o1, 433299600
            tz.transition 1984, 3, :o2, 449024400
            tz.transition 1984, 9, :o1, 465354000
            tz.transition 1985, 3, :o2, 481078800
            tz.transition 1985, 9, :o1, 496803600
            tz.transition 1986, 3, :o2, 512528400
            tz.transition 1986, 9, :o1, 528253200
            tz.transition 1987, 3, :o2, 543978000
            tz.transition 1987, 9, :o1, 559702800
            tz.transition 1988, 3, :o2, 575427600
            tz.transition 1988, 9, :o1, 591152400
            tz.transition 1989, 3, :o2, 606877200
            tz.transition 1989, 9, :o1, 622602000
            tz.transition 1990, 3, :o2, 638326800
            tz.transition 1990, 9, :o1, 654656400
            tz.transition 1991, 3, :o2, 670381200
            tz.transition 1991, 9, :o1, 686106000
            tz.transition 1992, 3, :o2, 701830800
            tz.transition 1992, 9, :o1, 717555600
            tz.transition 1993, 3, :o2, 733280400
            tz.transition 1993, 9, :o1, 749005200
            tz.transition 1994, 3, :o2, 764730000
            tz.transition 1994, 9, :o1, 780454800
            tz.transition 1995, 3, :o2, 796179600
            tz.transition 1995, 9, :o1, 811904400
            tz.transition 1996, 1, :o3, 820465200
          end
        end
      end
    end
  end
end
