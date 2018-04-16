# coding: utf-8

require 'minitest/autorun'
require 'rack'
require 'rack/multipart'
require 'rack/multipart/parser'
require 'rack/utils'
require 'rack/mock'

describe Rack::Multipart do
  def multipart_fixture(name, boundary = "AaB03x")
    file = multipart_file(name)
    data = File.open(file, 'rb') { |io| io.read }

    type = %(multipart/form-data; boundary=#{boundary})
    length = data.bytesize

    { "CONTENT_TYPE" => type,
      "CONTENT_LENGTH" => length.to_s,
      :input => StringIO.new(data) }
  end

  def multipart_file(name)
    File.join(File.dirname(__FILE__), "multipart", name.to_s)
  end

  it "return nil if content type is not multipart" do
    env = Rack::MockRequest.env_for("/",
            "CONTENT_TYPE" => 'application/x-www-form-urlencoded')
    Rack::Multipart.parse_multipart(env).must_be_nil
  end

  it "parse multipart content when content type present but filename is not" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:content_type_and_no_filename))
    params = Rack::Multipart.parse_multipart(env)
    params["text"].must_equal "contents"
  end

  it "set US_ASCII encoding based on charset" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:content_type_and_no_filename))
    params = Rack::Multipart.parse_multipart(env)
    params["text"].encoding.must_equal Encoding::US_ASCII

    # I'm not 100% sure if making the param name encoding match the
    # Content-Type charset is the right thing to do.  We should revisit this.
    params.keys.each do |key|
      key.encoding.must_equal Encoding::US_ASCII
    end
  end

  it "set BINARY encoding on things without content type" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:none))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].encoding.must_equal Encoding::UTF_8
  end

  it "set UTF8 encoding on names of things without content type" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:none))
    params = Rack::Multipart.parse_multipart(env)
    params.keys.each do |key|
      key.encoding.must_equal Encoding::UTF_8
    end
  end

  it "default text to UTF8" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:text))
    params = Rack::Multipart.parse_multipart(env)
    params['submit-name'].encoding.must_equal Encoding::UTF_8
    params['submit-name-with-content'].encoding.must_equal Encoding::UTF_8
    params.keys.each do |key|
      key.encoding.must_equal Encoding::UTF_8
    end
  end

  it "handles quoted encodings" do
    # See #905
    env = Rack::MockRequest.env_for("/", multipart_fixture(:unity3d_wwwform))
    params = Rack::Multipart.parse_multipart(env)
    params['user_sid'].encoding.must_equal Encoding::UTF_8
  end

  it "raise RangeError if the key space is exhausted" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:content_type_and_no_filename))

    old, Rack::Utils.key_space_limit = Rack::Utils.key_space_limit, 1
    begin
      lambda { Rack::Multipart.parse_multipart(env) }.must_raise(RangeError)
    ensure
      Rack::Utils.key_space_limit = old
    end
  end

  it "parse multipart form webkit style" do
    env = Rack::MockRequest.env_for '/', multipart_fixture(:webkit)
    env['CONTENT_TYPE'] = "multipart/form-data; boundary=----WebKitFormBoundaryWLHCs9qmcJJoyjKR"
    params = Rack::Multipart.parse_multipart(env)
    params['profile']['bio'].must_include 'hello'
    params['profile'].keys.must_include 'public_email'
  end

  it "reject insanely long boundaries" do
    # using a pipe since a tempfile can use up too much space
    rd, wr = IO.pipe

    # we only call rewind once at start, so make sure it succeeds
    # and doesn't hit ESPIPE
    def rd.rewind; end
    wr.sync = true

    # mock out length to make this pipe look like a Tempfile
    def rd.length
      1024 * 1024 * 8
    end

    # write to a pipe in a background thread, this will write a lot
    # unless Rack (properly) shuts down the read end
    thr = Thread.new do
      begin
        wr.write("--AaB03x")

        # make the initial boundary a few gigs long
        longer = "0123456789" * 1024 * 1024
        (1024 * 1024).times { wr.write(longer) }

        wr.write("\r\n")
        wr.write('Content-Disposition: form-data; name="a"; filename="a.txt"')
        wr.write("\r\n")
        wr.write("Content-Type: text/plain\r\n")
        wr.write("\r\na")
        wr.write("--AaB03x--\r\n")
        wr.close
      rescue => err # this is EPIPE if Rack shuts us down
        err
      end
    end

    fixture = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => rd.length.to_s,
      :input => rd,
    }

    env = Rack::MockRequest.env_for '/', fixture
    lambda {
      Rack::Multipart.parse_multipart(env)
    }.must_raise EOFError
    rd.close

    err = thr.value
    err.must_be_instance_of Errno::EPIPE
    wr.close
  end

  it 'raises an EOF error on content-length mistmatch' do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:empty))
    env['rack.input'] = StringIO.new
    assert_raises(EOFError) do
      Rack::Multipart.parse_multipart(env)
    end
  end

  it "parse multipart upload with text file" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:text))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["submit-name-with-content"].must_equal "Berry"
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "accept the params hash class to use for multipart parsing" do
    c = Class.new(Rack::QueryParser::Params) do
      def initialize(*)
        super
        @params = Hash.new{|h,k| h[k.to_s] if k.is_a?(Symbol)}
      end
    end
    query_parser = Rack::QueryParser.new c, 65536, 100
    env = Rack::MockRequest.env_for("/", multipart_fixture(:text))
    params = Rack::Multipart.parse_multipart(env, query_parser)
    params[:files][:type].must_equal "text/plain"
  end

  it "preserve extension in the created tempfile" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:text))
    params = Rack::Multipart.parse_multipart(env)
    File.extname(params["files"][:tempfile].path).must_equal ".txt"
  end

  it "parse multipart upload with text file with no name field" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_and_no_name))
    params = Rack::Multipart.parse_multipart(env)
    params["file1.txt"][:type].must_equal "text/plain"
    params["file1.txt"][:filename].must_equal "file1.txt"
    params["file1.txt"][:head].must_equal "Content-Disposition: form-data; " +
      "filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["file1.txt"][:name].must_equal "file1.txt"
    params["file1.txt"][:tempfile].read.must_equal "contents"
  end

  it "parse multipart upload file using custom tempfile class" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:text))
    my_tempfile = ""
    env['rack.multipart.tempfile_factory'] = lambda { |filename, content_type| my_tempfile }
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:tempfile].object_id.must_equal my_tempfile.object_id
    my_tempfile.must_equal "contents"
  end

  it "parse multipart upload with nested parameters" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:nested))
    params = Rack::Multipart.parse_multipart(env)
    params["foo"]["submit-name"].must_equal "Larry"
    params["foo"]["files"][:type].must_equal "text/plain"
    params["foo"]["files"][:filename].must_equal "file1.txt"
    params["foo"]["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"foo[files]\"; filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["foo"]["files"][:name].must_equal "foo[files]"
    params["foo"]["files"][:tempfile].read.must_equal "contents"
  end

  it "parse multipart upload with binary file" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:binary))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"

    params["files"][:type].must_equal "image/png"
    params["files"][:filename].must_equal "rack-logo.png"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"rack-logo.png\"\r\n" +
      "Content-Type: image/png\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.length.must_equal 26473
  end

  it "parse multipart upload with empty file" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:empty))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal ""
  end

  it "parse multipart upload with filename with semicolons" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:semicolon))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "fi;le1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"fi;le1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse multipart upload with quoted boundary" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:quoted, %("AaB:03x")))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["submit-name-with-content"].must_equal "Berry"
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse multipart upload with filename with invalid characters" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:invalid_character))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_match(/invalid/)
    head = "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"invalid\xC3.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    head = head.force_encoding(Encoding::ASCII_8BIT)
    params["files"][:head].must_equal head
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse multipart form with an encoded word filename" do
    env = Rack::MockRequest.env_for '/', multipart_fixture(:filename_with_encoded_words)
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:filename].must_equal "файл"
  end

  it "parse multipart form with a single quote in the filename" do
    env = Rack::MockRequest.env_for '/', multipart_fixture(:filename_with_single_quote)
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:filename].must_equal "bob's flowers.jpg"
  end

  it "parse multipart form with a null byte in the filename" do
    env = Rack::MockRequest.env_for '/', multipart_fixture(:filename_with_null_byte)
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:filename].must_equal "flowers.exe\u0000.jpg"
  end

  it "not include file params if no file was selected" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:none))
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["files"].must_be_nil
    params.keys.wont_include "files"
  end

  it "parse multipart/mixed" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:mixed_files))
    params = Rack::Multipart.parse_multipart(env)
    params["foo"].must_equal "bar"
    params["files"].must_be_instance_of String
    params["files"].size.must_equal 252
  end

  it "parse IE multipart upload and clean up filename" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:ie))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; " +
      'filename="C:\Documents and Settings\Administrator\Desktop\file1.txt"' +
      "\r\nContent-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename and modification param" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_and_modification_param))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "image/jpeg"
    params["files"][:filename].must_equal "genome.jpeg"
    params["files"][:head].must_equal "Content-Type: image/jpeg\r\n" +
      "Content-Disposition: attachment; " +
      "name=\"files\"; " +
      "filename=genome.jpeg; " +
      "modification-date=\"Wed, 12 Feb 1997 16:29:51 -0500\";\r\n" +
      "Content-Description: a complete map of the human genome\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename with escaped quotes" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_escaped_quotes))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "application/octet-stream"
    params["files"][:filename].must_equal "escape \"quotes"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; " +
      "filename=\"escape \\\"quotes\"\r\n" +
      "Content-Type: application/octet-stream\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename with percent escaped quotes" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_percent_escaped_quotes))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "application/octet-stream"
    params["files"][:filename].must_equal "escape \"quotes"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; " +
      "filename=\"escape %22quotes\"\r\n" +
      "Content-Type: application/octet-stream\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename with unescaped quotes" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_unescaped_quotes))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "application/octet-stream"
    params["files"][:filename].must_equal "escape \"quotes"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; " +
      "filename=\"escape \"quotes\"\r\n" +
      "Content-Type: application/octet-stream\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename with escaped quotes and modification param" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_escaped_quotes_and_modification_param))
    params = Rack::Multipart.parse_multipart(env)
    params["files"][:type].must_equal "image/jpeg"
    params["files"][:filename].must_equal "\"human\" genome.jpeg"
    params["files"][:head].must_equal "Content-Type: image/jpeg\r\n" +
      "Content-Disposition: attachment; " +
      "name=\"files\"; " +
      "filename=\"\"human\" genome.jpeg\"; " +
      "modification-date=\"Wed, 12 Feb 1997 16:29:51 -0500\";\r\n" +
      "Content-Description: a complete map of the human genome\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "parse filename with unescaped percentage characters" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_unescaped_percentages, "----WebKitFormBoundary2NHc7OhsgU68l3Al"))
    params = Rack::Multipart.parse_multipart(env)
    files = params["document"]["attachment"]
    files[:type].must_equal "image/jpeg"
    files[:filename].must_equal "100% of a photo.jpeg"
    files[:head].must_equal <<-MULTIPART
Content-Disposition: form-data; name="document[attachment]"; filename="100% of a photo.jpeg"\r
Content-Type: image/jpeg\r
    MULTIPART

    files[:name].must_equal "document[attachment]"
    files[:tempfile].read.must_equal "contents"
  end

  it "parse filename with unescaped percentage characters that look like partial hex escapes" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_unescaped_percentages2, "----WebKitFormBoundary2NHc7OhsgU68l3Al"))
    params = Rack::Multipart.parse_multipart(env)
    files = params["document"]["attachment"]
    files[:type].must_equal "image/jpeg"
    files[:filename].must_equal "100%a"
    files[:head].must_equal <<-MULTIPART
Content-Disposition: form-data; name="document[attachment]"; filename="100%a"\r
Content-Type: image/jpeg\r
    MULTIPART

    files[:name].must_equal "document[attachment]"
    files[:tempfile].read.must_equal "contents"
  end

  it "parse filename with unescaped percentage characters that look like partial hex escapes" do
    env = Rack::MockRequest.env_for("/", multipart_fixture(:filename_with_unescaped_percentages3, "----WebKitFormBoundary2NHc7OhsgU68l3Al"))
    params = Rack::Multipart.parse_multipart(env)
    files = params["document"]["attachment"]
    files[:type].must_equal "image/jpeg"
    files[:filename].must_equal "100%"
    files[:head].must_equal <<-MULTIPART
Content-Disposition: form-data; name="document[attachment]"; filename="100%"\r
Content-Type: image/jpeg\r
    MULTIPART

    files[:name].must_equal "document[attachment]"
    files[:tempfile].read.must_equal "contents"
  end

  it "rewinds input after parsing upload" do
    options = multipart_fixture(:text)
    input = options[:input]
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["files"][:filename].must_equal "file1.txt"
    input.read.length.must_equal 307
  end

  it "builds multipart body" do
    files = Rack::Multipart::UploadedFile.new(multipart_file("file1.txt"))
    data  = Rack::Multipart.build_multipart("submit-name" => "Larry", "files" => files)

    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "builds nested multipart body" do
    files = Rack::Multipart::UploadedFile.new(multipart_file("file1.txt"))
    data  = Rack::Multipart.build_multipart("people" => [{"submit-name" => "Larry", "files" => files}])

    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)
    params["people"][0]["submit-name"].must_equal "Larry"
    params["people"][0]["files"][:filename].must_equal "file1.txt"
    params["people"][0]["files"][:tempfile].read.must_equal "contents"
  end

  it "can parse fields that end at the end of the buffer" do
    input = File.read(multipart_file("bad_robots"))

    req = Rack::Request.new Rack::MockRequest.env_for("/",
                      "CONTENT_TYPE" => "multipart/form-data, boundary=1yy3laWhgX31qpiHinh67wJXqKalukEUTvqTzmon",
                      "CONTENT_LENGTH" => input.size,
                      :input => input)

    req.POST['file.path'].must_equal "/var/tmp/uploads/4/0001728414"
    req.POST['addresses'].wont_equal nil
  end

  it "builds complete params with the chunk size of 16384 slicing exactly on boundary" do
    begin
      previous_limit = Rack::Utils.multipart_part_limit
      Rack::Utils.multipart_part_limit = 256

      data = File.open(multipart_file("fail_16384_nofile"), 'rb') { |f| f.read }.gsub(/\n/, "\r\n")
      options = {
        "CONTENT_TYPE" => "multipart/form-data; boundary=----WebKitFormBoundaryWsY0GnpbI5U7ztzo",
        "CONTENT_LENGTH" => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for("/", options)
      params = Rack::Multipart.parse_multipart(env)

      params.wont_equal nil
      params.keys.must_include "AAAAAAAAAAAAAAAAAAA"
      params["AAAAAAAAAAAAAAAAAAA"].keys.must_include "PLAPLAPLA_MEMMEMMEMM_ATTRATTRER"
      params["AAAAAAAAAAAAAAAAAAA"]["PLAPLAPLA_MEMMEMMEMM_ATTRATTRER"].keys.must_include "new"
      params["AAAAAAAAAAAAAAAAAAA"]["PLAPLAPLA_MEMMEMMEMM_ATTRATTRER"]["new"].keys.must_include "-2"
      params["AAAAAAAAAAAAAAAAAAA"]["PLAPLAPLA_MEMMEMMEMM_ATTRATTRER"]["new"]["-2"].keys.must_include "ba_unit_id"
      params["AAAAAAAAAAAAAAAAAAA"]["PLAPLAPLA_MEMMEMMEMM_ATTRATTRER"]["new"]["-2"]["ba_unit_id"].must_equal "1017"
    ensure
      Rack::Utils.multipart_part_limit = previous_limit
    end
  end

  it "not reach a multi-part limit" do
    begin
      previous_limit = Rack::Utils.multipart_part_limit
      Rack::Utils.multipart_part_limit = 4

      env = Rack::MockRequest.env_for '/', multipart_fixture(:three_files_three_fields)
      params = Rack::Multipart.parse_multipart(env)
      params['reply'].must_equal 'yes'
      params['to'].must_equal 'people'
      params['from'].must_equal 'others'
    ensure
      Rack::Utils.multipart_part_limit = previous_limit
    end
  end

  it "reach a multipart limit" do
    begin
      previous_limit = Rack::Utils.multipart_part_limit
      Rack::Utils.multipart_part_limit = 3

      env = Rack::MockRequest.env_for '/', multipart_fixture(:three_files_three_fields)
      lambda { Rack::Multipart.parse_multipart(env) }.must_raise Rack::Multipart::MultipartPartLimitError
    ensure
      Rack::Utils.multipart_part_limit = previous_limit
    end
  end

  it "return nil if no UploadedFiles were used" do
    data = Rack::Multipart.build_multipart("people" => [{"submit-name" => "Larry", "files" => "contents"}])
    data.must_be_nil
  end

  it "raise ArgumentError if params is not a Hash" do
    lambda {
      Rack::Multipart.build_multipart("foo=bar")
    }.must_raise(ArgumentError).message.must_equal "value must be a Hash"
  end

  it "can parse fields with a content type" do
    data = <<-EOF
--1yy3laWhgX31qpiHinh67wJXqKalukEUTvqTzmon\r
Content-Disposition: form-data; name="description"\r
Content-Type: text/plain"\r
\r
Very very blue\r
--1yy3laWhgX31qpiHinh67wJXqKalukEUTvqTzmon--\r
EOF
    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=1yy3laWhgX31qpiHinh67wJXqKalukEUTvqTzmon",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)

    params.must_equal "description"=>"Very very blue"
  end

  it "parse multipart upload with no content-length header" do
    env = Rack::MockRequest.env_for '/', multipart_fixture(:webkit)
    env['CONTENT_TYPE'] = "multipart/form-data; boundary=----WebKitFormBoundaryWLHCs9qmcJJoyjKR"
    env.delete 'CONTENT_LENGTH'
    params = Rack::Multipart.parse_multipart(env)
    params['profile']['bio'].must_include 'hello'
  end

  it "parse very long unquoted multipart file names" do
    data = <<-EOF
--AaB03x\r
Content-Type: text/plain\r
Content-Disposition: attachment; name=file; filename=#{'long' * 100}\r
\r
contents\r
--AaB03x--\r
    EOF

    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)

    params["file"][:filename].must_equal 'long' * 100
  end

  it "parse unquoted parameter values at end of line" do
    data = <<-EOF
--AaB03x\r
Content-Type: text/plain\r
Content-Disposition: attachment; name=inline\r
\r
true\r
--AaB03x--\r
    EOF

    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)
    params["inline"].must_equal 'true'
  end

  it "parse quoted chars in name parameter" do
    data = <<-EOF
--AaB03x\r
Content-Type: text/plain\r
Content-Disposition: attachment; name="quoted\\\\chars\\"in\rname"\r
\r
true\r
--AaB03x--\r
    EOF

    options = {
      "CONTENT_TYPE" => "multipart/form-data; boundary=AaB03x",
      "CONTENT_LENGTH" => data.length.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)
    params["quoted\\chars\"in\rname"].must_equal 'true'
  end

  it "support mixed case metadata" do
    file = multipart_file(:text)
    data = File.open(file, 'rb') { |io| io.read }

    type = "Multipart/Form-Data; Boundary=AaB03x"
    length = data.bytesize

    e = { "CONTENT_TYPE" => type,
      "CONTENT_LENGTH" => length.to_s,
      :input => StringIO.new(data) }

    env = Rack::MockRequest.env_for("/", e)
    params = Rack::Multipart.parse_multipart(env)
    params["submit-name"].must_equal "Larry"
    params["submit-name-with-content"].must_equal "Berry"
    params["files"][:type].must_equal "text/plain"
    params["files"][:filename].must_equal "file1.txt"
    params["files"][:head].must_equal "Content-Disposition: form-data; " +
      "name=\"files\"; filename=\"file1.txt\"\r\n" +
      "Content-Type: text/plain\r\n"
    params["files"][:name].must_equal "files"
    params["files"][:tempfile].read.must_equal "contents"
  end

  it "fallback to content-type for name" do
    rack_logo = File.read(multipart_file("rack-logo.png"))

    data = <<-EOF
--AaB03x\r
Content-Type: text/plain\r
\r
some text\r
--AaB03x\r
\r
\r
some more text (I didn't specify Content-Type)\r
--AaB03x\r
Content-Type: image/png\r
\r
#{rack_logo}\r
--AaB03x--\r
    EOF

    options = {
      "CONTENT_TYPE" => "multipart/related; boundary=AaB03x",
      "CONTENT_LENGTH" => data.bytesize.to_s,
      :input => StringIO.new(data)
    }
    env = Rack::MockRequest.env_for("/", options)
    params = Rack::Multipart.parse_multipart(env)

    params["text/plain"].must_equal ["some text", "some more text (I didn't specify Content-Type)"]
    params["image/png"].length.must_equal 1

    f = Tempfile.new("rack-logo")
    f.write(params["image/png"][0])
    f.length.must_equal 26473
  end
end
