# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Enderbury
          include TimezoneDefinition
          
          timezone 'Pacific/Enderbury' do |tz|
            tz.offset :o0, -41060, 0, :LMT
            tz.offset :o1, -43200, 0, :'-12'
            tz.offset :o2, -39600, 0, :'-11'
            tz.offset :o3, 46800, 0, :'+13'
            
            tz.transition 1901, 1, :o1, -2177411740, 10434467413, 4320
            tz.transition 1979, 10, :o2, 307627200
            tz.transition 1994, 12, :o3, 788871600
          end
        end
      end
    end
  end
end
