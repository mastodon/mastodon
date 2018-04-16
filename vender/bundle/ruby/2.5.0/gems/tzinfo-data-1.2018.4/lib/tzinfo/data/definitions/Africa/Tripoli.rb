# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Africa
        module Tripoli
          include TimezoneDefinition
          
          timezone 'Africa/Tripoli' do |tz|
            tz.offset :o0, 3164, 0, :LMT
            tz.offset :o1, 3600, 0, :CET
            tz.offset :o2, 3600, 3600, :CEST
            tz.offset :o3, 7200, 0, :EET
            
            tz.transition 1919, 12, :o1, -1577926364, 52322208409, 21600
            tz.transition 1951, 10, :o2, -574902000, 58414405, 24
            tz.transition 1951, 12, :o1, -568087200, 29208149, 12
            tz.transition 1953, 10, :o2, -512175600, 58431829, 24
            tz.transition 1953, 12, :o1, -504928800, 29216921, 12
            tz.transition 1955, 9, :o2, -449888400, 58449131, 24
            tz.transition 1955, 12, :o1, -441856800, 29225681, 12
            tz.transition 1958, 12, :o3, -347158800, 58477667, 24
            tz.transition 1981, 12, :o1, 378684000
            tz.transition 1982, 3, :o2, 386463600
            tz.transition 1982, 9, :o1, 402271200
            tz.transition 1983, 3, :o2, 417999600
            tz.transition 1983, 9, :o1, 433807200
            tz.transition 1984, 3, :o2, 449622000
            tz.transition 1984, 9, :o1, 465429600
            tz.transition 1985, 4, :o2, 481590000
            tz.transition 1985, 9, :o1, 496965600
            tz.transition 1986, 4, :o2, 512953200
            tz.transition 1986, 10, :o1, 528674400
            tz.transition 1987, 3, :o2, 544230000
            tz.transition 1987, 9, :o1, 560037600
            tz.transition 1988, 3, :o2, 575852400
            tz.transition 1988, 9, :o1, 591660000
            tz.transition 1989, 3, :o2, 607388400
            tz.transition 1989, 9, :o1, 623196000
            tz.transition 1990, 5, :o3, 641775600
            tz.transition 1996, 9, :o1, 844034400
            tz.transition 1997, 4, :o2, 860108400
            tz.transition 1997, 10, :o3, 875916000
            tz.transition 2012, 11, :o1, 1352505600
            tz.transition 2013, 3, :o2, 1364515200
            tz.transition 2013, 10, :o3, 1382659200
          end
        end
      end
    end
  end
end
