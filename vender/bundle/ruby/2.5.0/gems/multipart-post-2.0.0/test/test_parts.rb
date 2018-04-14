#--
# Copyright (c) 2007-2012 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'test/unit'

require 'parts'
require 'stringio'
require 'composite_io'
require 'tempfile'


MULTIBYTE = File.dirname(__FILE__)+'/multibyte.txt'
TEMP_FILE = "temp.txt"

module AssertPartLength
  def assert_part_length(part)
    bytes = part.to_io.read
    bytesize = bytes.respond_to?(:bytesize) ? bytes.bytesize : bytes.length
    assert_equal bytesize, part.length
  end
end

class PartTest < Test::Unit::TestCase
  def setup
    @string_with_content_type = Class.new(String) do
      def content_type; 'application/data'; end
    end
  end

  def test_file_with_upload_io
    assert Parts::Part.file?(UploadIO.new(__FILE__, "text/plain"))
  end

  def test_file_with_modified_string
    assert !Parts::Part.file?(@string_with_content_type.new("Hello"))
  end

  def test_new_with_modified_string
    assert_kind_of Parts::ParamPart,
      Parts::Part.new("boundary", "multibyte", @string_with_content_type.new("Hello"))
  end
end

class FilePartTest < Test::Unit::TestCase
  include AssertPartLength

  def setup
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    io =  UploadIO.new(TEMP_FILE, "text/plain")
    @part = Parts::FilePart.new("boundary", "afile", io)
  end

  def teardown
    File.delete(TEMP_FILE) rescue nil
  end

  def test_correct_length
    assert_part_length @part
  end

  def test_multibyte_file_length
    assert_part_length Parts::FilePart.new("boundary", "multibyte", UploadIO.new(MULTIBYTE, "text/plain"))
  end

  def test_multibyte_filename
    name = File.read(MULTIBYTE, 300)
    file = Tempfile.new(name.respond_to?(:force_encoding) ? name.force_encoding("UTF-8") : name)
    assert_part_length Parts::FilePart.new("boundary", "multibyte", UploadIO.new(file, "text/plain"))
    file.close
  end
end

class ParamPartTest < Test::Unit::TestCase
  include AssertPartLength

  def setup
    @part = Parts::ParamPart.new("boundary", "multibyte", File.read(MULTIBYTE))
  end

  def test_correct_length
    assert_part_length @part
  end
end
