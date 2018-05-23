# Makefile configuration for LibIDN Ruby Bindings.
#
# Copyright (c) 2005 Erik Abele. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# Please see the file called LICENSE for further details.
#
# You may also obtain a copy of the License at
#
# * http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This software is OSI Certified Open Source Software.
# OSI Certified is a certification mark of the Open Source Initiative.

require 'mkmf'

@libs = ['idn']
@headers = ['idna.h', 'punycode.h', 'stringprep.h']

INFO_NOTE = <<EOL
  Please install the GNU IDN library or alternatively specify at least one
  of the following options if the library can only be found in a non-standard
  location:
    --with-idn-dir=/path/to/non/standard/location
        or
    --with-idn-lib=/path/to/non/standard/location/lib
    --with-idn-include=/path/to/non/standard/location/include
EOL

dir_config('idn')

@libs.each do |lib|
  unless have_library(lib)
    STDERR.puts "ERROR: could not find #{lib} library!\n" +
                "\n#{INFO_NOTE}\n"
    exit 1
  end
end

@headers.each do |header|
  unless have_header(header)
    STDERR.puts "ERROR: could not find #{header} header file!\n" +
                "\n#{INFO_NOTE}\n"
    exit 1
  end
end

$CFLAGS += ' -Wall' unless $CFLAGS.split.include? '-Wall'
create_makefile('idn')
