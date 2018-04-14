# File including an implementation of CLD3 module. Some documentations are
# extracted from ext/cld3/ext/src/nnet_language_identifier.h.
#
# Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

require "ffi"
require "rbconfig"

# Module providing an interface for Compact Language Detector v3 (CLD3)
module CLD3
  # Class for detecting the language of a document.
  class NNetLanguageIdentifier
    # Min number of bytes needed to make a prediction if the construcotr is
    # called without the corresponding parameter.
    # This is Numeric object.
    MIN_NUM_BYTES_TO_CONSIDER = 140

    # Max number of bytes needed to make a prediction if the construcotr is
    # called without the corresponding parameter.
    # This is Numeric object.
    MAX_NUM_BYTES_TO_CONSIDER = 700

    # Max number of input bytes to process.
    # This is Numeric object.
    MAX_NUM_INPUT_BYTES_TO_CONSIDER = 10000

    # Predictions with probability greater than or equal to this threshold are
    # marked as reliable. This threshold was optimized on a set of text segments
    # extracted from wikipedia, and results in an overall precision, recall,
    # and f1 equal to 0.9760, 0.9624, and 0.9692, respectively.
    # This is Numeric object.
    RELIABILITY_THRESHOLD = 0.7

    # Reliability threshold for the languages hr and bs.
    # This is Numeric object.
    RELIABILITY_HR_BS_THRESHOLD = 0.5

    # Information about a predicted language.
    # This is an instance of Struct with the following members:
    #
    # [language]    This is symbol or nil.
    #
    # [probability] Language probability. This is Numeric object.
    #
    # [reliable?]   Whether the prediction is reliable. This is true or false.
    #
    # [proportion]  Proportion of bytes associated with the language. If
    #               #find_language is called, this variable is set to 1.
    #               This is Numeric object.
    Result = Struct.new("Result", :language, :probability, :reliable?, :proportion)

    # The arguments are two String objects.
    def initialize(minNumBytes = MIN_NUM_BYTES_TO_CONSIDER, maxNumBytes = MAX_NUM_BYTES_TO_CONSIDER)
      @cc = CLD3::Unstable::NNetLanguageIdentifier::Pointer.new(CLD3::Unstable.new_NNetLanguageIdentifier(minNumBytes, maxNumBytes))
    end

    # Finds the most likely language for the given text, along with additional
    # information (e.g., probability). The prediction is based on the first N
    # bytes where N is the minumum between the number of interchange valid UTF8
    # bytes and +max_num_bytes_+. If N is less than +min_num_bytes_+ long, then
    # this function returns nil as language.
    # The argument is a String object.
    # The returned value of this function is an instance of Result.
    def find_language(text)
      text_utf8 = text.encode(Encoding::UTF_8)
      pointer = FFI::MemoryPointer.new(:char, text_utf8.bytesize)
      pointer.put_bytes(0, text_utf8)

      cc_result = CLD3::Unstable.NNetLanguageIdentifier_find_language(@cc, pointer, text_utf8.bytesize)
      language = cc_result[:language_data].read_bytes(cc_result[:language_size])

      Result.new(
          language == "und" ? nil : language.to_sym,
          cc_result[:probability],
          cc_result[:reliable?],
          cc_result[:proportion])
    end
  end

  # Encapsulates the TaskContext specifying only the parameters for the model.
  # The model weights are loaded statically.
  module TaskContextParams
    # This is an frozen Array object containing symbols.
    LANGUAGE_NAMES = [
      :eo, :co, :eu, :ta, :de, :mt, :ps, :te, :su, :uz, :'zh-Latn', :ne,
      :nl, :sw, :sq, :hmn, :ja, :no, :mn, :so, :ko, :kk, :sl, :ig,
      :mr, :th, :zu, :ml, :hr, :bs, :lo, :sd, :cy, :hy, :uk, :pt,
      :lv, :iw, :cs, :vi, :jv, :be, :km, :mk, :tr, :fy, :am, :zh,
      :da, :sv, :fi, :ht, :af, :la, :id, :fil, :sm, :ca, :el, :ka,
      :sr, :it, :sk, :ru, :'ru-Latn', :bg, :ny, :fa, :haw, :gl, :et,
      :ms, :gd, :'bg-Latn', :ha, :is, :ur, :mi, :hi, :bn, :'hi-Latn', :fr,
      :yi, :hu, :xh, :my, :tg, :ro, :ar, :lb, :'el-Latn', :st, :ceb,
      :kn, :az, :si, :ky, :mg, :en, :gu, :es, :pl, :'ja-Latn', :ga, :lt,
      :sn, :yo, :pa, :ku,
    ].freeze
  end

  # :nodoc: all
  # Do NOT use this module from outside.
  module Unstable
    extend FFI::Library

    ffi_lib File.join(File.expand_path(File.dirname(__FILE__)), "..", "ext", "cld3", "libcld3." + RbConfig::CONFIG["DLEXT"])

    module NNetLanguageIdentifier
      class Pointer < FFI::AutoPointer
        def self.release(pointer)
          CLD3::Unstable.delete_NNetLanguageIdentifier(pointer)
        end
      end

      class Result < FFI::Struct
        layout :language_data, :pointer, :language_size, :size_t, :probability, :float, :proportion, :float, :reliable?, :bool
      end
    end

    attach_function :delete_NNetLanguageIdentifier, [ :pointer ], :void

    attach_function :new_NNetLanguageIdentifier, [ :int, :int ], :pointer

    attach_function :NNetLanguageIdentifier_find_language,
        [ :pointer, :buffer_in, :size_t ], NNetLanguageIdentifier::Result.by_value
  end
end
