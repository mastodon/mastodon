# Unit tests for IDN::Stringprep.
#
# Copyright (c) 2005-2006 Erik Abele. All rights reserved.
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

require 'test/unit'
require 'idn'

class Test_Stringprep < Test::Unit::TestCase
  include IDN

  # STRINGPREP test vectors: UTF-8 encoded strings and the corresponding
  # prepared form, according to the given profile.

  TESTCASES_STRINGPREP = {
    'A' => [ "Nameprep", "\xC5\x83\xCD\xBA", "\xC5\x84 \xCE\xB9" ],
    'B' => [ "Nodeprep", "\xE1\xBE\xB7", "\xE1\xBE\xB6\xCE\xB9" ],
    'C' => [ "Resourceprep", "foo@bar", "foo@bar" ],
    'D' => [ "ISCSIprep", "Example-Name", "example-name" ],
    'E' => [ "SASLprep", "Example\xC2\xA0Name", "Example Name" ]
  }

  # STRINGPREP_INVALID test vectors: invalid input strings and their
  # corresponding profile.

  TESTCASES_STRINGPREP_INVALID = {
    'A' => [ "Nodeprep", "toto@a/a" ]
  }

  # NFKC test vectors: UTF-8 encoded strings and the corresponding
  # normalized form, according to NFKC normalization mode.

  TESTCASES_NFKC = {
    'A' => [ "\xC2\xB5", "\xCE\xBC" ],
    'B' => [ "\xC2\xAA", "\x61" ]
  }

  def setup
  end

  def teardown
  end

  def test_with_profile_STRINGPREP
    TESTCASES_STRINGPREP.each do |key, val|
      rc = Stringprep.with_profile(val[1], val[0])
      assert_equal(val[2], rc, "TestCase #{key} failed")
    end
  end

  def test_with_profile_STRINGPREP_INVALID
    TESTCASES_STRINGPREP_INVALID.each do |key, val|
      assert_raise(Stringprep::StringprepError, "TestCase #{key} failed") do
        Stringprep.with_profile(val[0], val[1])
      end
    end
  end

  def test_nfkc_normalize_NFKC
    TESTCASES_NFKC.each do |key, val|
      rc = Stringprep.nfkc_normalize(val[0])
      assert_equal(val[1], rc, "TestCase #{key} failed")
    end
  end
end
