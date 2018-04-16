# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Rarotonga
          include TimezoneDefinition
          
          timezone 'Pacific/Rarotonga' do |tz|
            tz.offset :o0, -38344, 0, :LMT
            tz.offset :o1, -37800, 0, :'-1030'
            tz.offset :o2, -36000, 1800, :'-0930'
            tz.offset :o3, -36000, 0, :'-10'
            
            tz.transition 1901, 1, :o1, -2177414456, 26086168193, 10800
            tz.transition 1978, 11, :o2, 279714600
            tz.transition 1979, 3, :o3, 289387800
            tz.transition 1979, 10, :o2, 309952800
            tz.transition 1980, 3, :o3, 320837400
            tz.transition 1980, 10, :o2, 341402400
            tz.transition 1981, 3, :o3, 352287000
            tz.transition 1981, 10, :o2, 372852000
            tz.transition 1982, 3, :o3, 384341400
            tz.transition 1982, 10, :o2, 404906400
            tz.transition 1983, 3, :o3, 415791000
            tz.transition 1983, 10, :o2, 436356000
            tz.transition 1984, 3, :o3, 447240600
            tz.transition 1984, 10, :o2, 467805600
            tz.transition 1985, 3, :o3, 478690200
            tz.transition 1985, 10, :o2, 499255200
            tz.transition 1986, 3, :o3, 510139800
            tz.transition 1986, 10, :o2, 530704800
            tz.transition 1987, 3, :o3, 541589400
            tz.transition 1987, 10, :o2, 562154400
            tz.transition 1988, 3, :o3, 573643800
            tz.transition 1988, 10, :o2, 594208800
            tz.transition 1989, 3, :o3, 605093400
            tz.transition 1989, 10, :o2, 625658400
            tz.transition 1990, 3, :o3, 636543000
            tz.transition 1990, 10, :o2, 657108000
            tz.transition 1991, 3, :o3, 667992600
          end
        end
      end
    end
  end
end
