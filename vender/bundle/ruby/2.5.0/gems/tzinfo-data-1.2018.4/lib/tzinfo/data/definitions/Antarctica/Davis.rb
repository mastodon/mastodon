# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Antarctica
        module Davis
          include TimezoneDefinition
          
          timezone 'Antarctica/Davis' do |tz|
            tz.offset :o0, 0, 0, :'-00'
            tz.offset :o1, 25200, 0, :'+07'
            tz.offset :o2, 18000, 0, :'+05'
            
            tz.transition 1957, 1, :o1, -409190400, 4871703, 2
            tz.transition 1964, 10, :o0, -163062000, 58528805, 24
            tz.transition 1969, 2, :o1, -28857600, 4880507, 2
            tz.transition 2009, 10, :o2, 1255806000
            tz.transition 2010, 3, :o1, 1268251200
            tz.transition 2011, 10, :o2, 1319742000
            tz.transition 2012, 2, :o1, 1329854400
          end
        end
      end
    end
  end
end
