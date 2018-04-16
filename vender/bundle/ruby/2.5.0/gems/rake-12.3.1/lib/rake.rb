# frozen_string_literal: true
#--
# Copyright 2003-2010 by Jim Weirich (jim.weirich@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#++

module Rake; end

require "rake/version"

require "rbconfig"
require "fileutils"
require "singleton"
require "monitor"
require "optparse"
require "ostruct"

require "rake/ext/string"

require "rake/win32"

require "rake/linked_list"
require "rake/cpu_counter"
require "rake/scope"
require "rake/task_argument_error"
require "rake/rule_recursion_overflow_error"
require "rake/rake_module"
require "rake/trace_output"
require "rake/pseudo_status"
require "rake/task_arguments"
require "rake/invocation_chain"
require "rake/task"
require "rake/file_task"
require "rake/file_creation_task"
require "rake/multi_task"
require "rake/dsl_definition"
require "rake/file_utils_ext"
require "rake/file_list"
require "rake/default_loader"
require "rake/early_time"
require "rake/late_time"
require "rake/name_space"
require "rake/task_manager"
require "rake/application"
require "rake/backtrace"

$trace = false

# :stopdoc:
#
# Some top level Constants.

FileList = Rake::FileList
RakeFileUtils = Rake::FileUtilsExt
