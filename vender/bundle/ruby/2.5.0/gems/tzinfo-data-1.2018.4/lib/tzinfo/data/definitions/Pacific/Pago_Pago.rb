# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Pacific
        module Pago_Pago
          include TimezoneDefinition
          
          timezone 'Pacific/Pago_Pago' do |tz|
            tz.offset :o0, 45432, 0, :LMT
            tz.offset :o1, -40968, 0, :LMT
            tz.offset :o2, -39600, 0, :SST
            
            tz.transition 1892, 7, :o1, -2445424632, 2894740769, 1200
            tz.transition 1911, 1, :o2, -1861879032, 2902845569, 1200
          end
        end
      end
    end
  end
end
