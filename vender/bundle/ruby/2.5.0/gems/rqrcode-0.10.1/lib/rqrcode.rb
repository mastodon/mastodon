#!/usr/bin/env ruby

#--
# Copyright 2008 by Duncan Robertson (duncan@whomwah.com).
# All rights reserved.

# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#++

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "rqrcode/core_ext"
require "rqrcode/qrcode"
require 'rqrcode/export/png'
require 'rqrcode/export/svg'
require 'rqrcode/export/html'
require 'rqrcode/export/ansi'
