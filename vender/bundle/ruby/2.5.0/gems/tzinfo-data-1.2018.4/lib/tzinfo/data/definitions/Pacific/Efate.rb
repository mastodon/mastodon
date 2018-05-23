# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Efate
          include TimezoneDefinition
          
          timezone 'Pacific/Efate' do |tz|
            tz.offset :o0, 40396, 0, :LMT
            tz.offset :o1, 39600, 0, :'+11'
            tz.offset :o2, 39600, 3600, :'+12'
            
            tz.transition 1912, 1, :o1, -1829387596, 52259343101, 21600
            tz.transition 1983, 9, :o2, 433256400
            tz.transition 1984, 3, :o1, 448977600
            tz.transition 1984, 10, :o2, 467298000
            tz.transition 1985, 3, :o1, 480427200
            tz.transition 1985, 9, :o2, 496760400
            tz.transition 1986, 3, :o1, 511876800
            tz.transition 1986, 9, :o2, 528210000
            tz.transition 1987, 3, :o1, 543931200
            tz.transition 1987, 9, :o2, 559659600
            tz.transition 1988, 3, :o1, 575380800
            tz.transition 1988, 9, :o2, 591109200
            tz.transition 1989, 3, :o1, 606830400
            tz.transition 1989, 9, :o2, 622558800
            tz.transition 1990, 3, :o1, 638280000
            tz.transition 1990, 9, :o2, 654008400
            tz.transition 1991, 3, :o1, 669729600
            tz.transition 1991, 9, :o2, 686062800
            tz.transition 1992, 1, :o1, 696340800
            tz.transition 1992, 10, :o2, 719931600
            tz.transition 1993, 1, :o1, 727790400
          end
        end
      end
    end
  end
end
