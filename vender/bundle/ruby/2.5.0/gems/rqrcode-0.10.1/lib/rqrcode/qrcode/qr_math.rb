#!/usr/bin/env ruby

#--
# Copyright 2004 by Duncan Robertson (duncan@whomwah.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

module RQRCode #:nodoc:

  class QRMath

    module_eval { 
      exp_table = Array.new(256)
      log_table = Array.new(256)

      ( 0...8 ).each do |i|
        exp_table[i] = 1 << i
      end

      ( 8...256 ).each do |i|
        exp_table[i] = exp_table[i - 4] \
          ^ exp_table[i - 5] \
          ^ exp_table[i - 6] \
          ^ exp_table[i - 8]
      end

      ( 0...255 ).each do |i|
        log_table[exp_table[i] ] = i
      end

      EXP_TABLE = exp_table 
      LOG_TABLE = log_table 
    }

    class << self

      def glog(n)
        raise QRCodeRunTimeError, "glog(#{n})" if ( n < 1 )
        LOG_TABLE[n]
      end


      def gexp(n)
        while n < 0
          n = n + 255
        end

        while n >= 256
          n = n - 255
        end

        EXP_TABLE[n]
      end

    end

  end

end
