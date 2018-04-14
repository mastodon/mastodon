require "spec_helper"
require "aws-sdk-s3"

describe Paperclip::Storage::S3 do
  before do
    Aws.config[:stub_responses] = true
  end

  def aws2_add_region
    { s3_region: 'us-east-1' }
  end

  context "Parsing S3 credentials" do
    before do
      @proxy_settings = {host: "127.0.0.1", port: 8888, user: "foo", password: "bar"}
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        http_proxy: @proxy_settings,
        s3_credentials: {not: :important}
      @dummy = Dummy.new
      @avatar = @dummy.avatar
    end

    it "gets the correct credentials when RAILS_ENV is production" do
      rails_env("production") do
        assert_equal({key: "12345"},
                     @avatar.parse_credentials('production' => {key: '12345'},
                                               development: {key: "54321"}))
      end
    end

    it "gets the correct credentials when RAILS_ENV is development" do
      rails_env("development") do
        assert_equal({key: "54321"},
                     @avatar.parse_credentials('production' => {key: '12345'},
                                               development: {key: "54321"}))
      end
    end

    it "returns the argument if the key does not exist" do
      rails_env("not really an env") do
        assert_equal({test: "12345"}, @avatar.parse_credentials(test: "12345"))
      end
    end

    it "supports HTTP proxy settings" do
      rails_env("development") do
        assert_equal(true, @avatar.using_http_proxy?)
        assert_equal(@proxy_settings[:host], @avatar.http_proxy_host)
        assert_equal(@proxy_settings[:port], @avatar.http_proxy_port)
        assert_equal(@proxy_settings[:user], @avatar.http_proxy_user)
        assert_equal(@proxy_settings[:password], @avatar.http_proxy_password)
      end
    end

  end

  context ":bucket option via :s3_credentials" do

    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {bucket: 'testing'}
      @dummy = Dummy.new
    end

    it "populates #bucket_name" do
      assert_equal @dummy.avatar.bucket_name, 'testing'
    end

  end

  context ":bucket option" do

    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing", s3_credentials: {}
      @dummy = Dummy.new
    end

    it "populates #bucket_name" do
      assert_equal @dummy.avatar.bucket_name, 'testing'
    end

  end

  context "missing :bucket option" do

    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        http_proxy: @proxy_settings,
        s3_credentials: {not: :important}

      @dummy = Dummy.new
      @dummy.avatar = stringy_file

    end

    it "raises an argument error" do
      expect { @dummy.save }.to raise_error(ArgumentError, /missing required :bucket option/)
    end

  end

  context "" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        url: ":s3_path_url"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an S3 path" do
      assert_match %r{^//s3.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end

    it "uses the correct bucket" do
      assert_equal "bucket", @dummy.avatar.s3_bucket.name
    end

    it "uses the correct key" do
      assert_equal "avatars/data", @dummy.avatar.s3_object.key
    end
  end

  context "s3_protocol" do
    ["http", :http, ""].each do |protocol|
      context "as #{protocol.inspect}" do
        before do
          rebuild_model (aws2_add_region).merge storage: :s3,
            s3_protocol: protocol
          @dummy = Dummy.new
        end

        it "returns the s3_protocol in string" do
          assert_equal protocol.to_s, @dummy.avatar.s3_protocol
        end
      end
    end
  end

  context "s3_protocol: 'https'" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        s3_protocol: 'https',
        bucket: "bucket",
        path: ":attachment/:basename:dotextension"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an S3 path" do
      assert_match %r{^https://s3.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "s3_protocol: ''" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        s3_protocol: '',
        bucket: "bucket",
        path: ":attachment/:basename:dotextension"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a protocol-relative URL" do
      assert_match %r{^//s3.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "s3_protocol: :https" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        s3_protocol: :https,
        bucket: "bucket",
        path: ":attachment/:basename:dotextension"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an S3 path" do
      assert_match %r{^https://s3.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "s3_protocol: ''" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        s3_protocol: '',
        bucket: "bucket",
        path: ":attachment/:basename:dotextension"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an S3 path" do
      assert_match %r{^//s3.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "An attachment that uses S3 for storage and has the style in the path" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        styles: {
          thumb: "80x80>"
        },
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        }

        @dummy = Dummy.new
        @dummy.avatar = stringy_file
        @avatar = @dummy.avatar
    end

    it "uses an S3 object based on the correct path for the default style" do
      assert_equal("avatars/original/data", @dummy.avatar.s3_object.key)
    end

    it "uses an S3 object based on the correct path for the custom style" do
      assert_equal("avatars/thumb/data", @dummy.avatar.s3_object(:thumb).key)
    end
  end

  # the s3_host_name will be defined by the s3_region
  context "s3_host_name" do
    before do
      rebuild_model storage: :s3,
        s3_credentials: {},
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        s3_host_name: "s3-ap-northeast-1.amazonaws.com",
        s3_region: "ap-northeast-1"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an :s3_host_name path" do
      assert_match %r{^//s3-ap-northeast-1.amazonaws.com/bucket/avatars/data[^\.]}, @dummy.avatar.url
    end

    it "uses the S3 bucket with the correct host name" do
      assert_equal "s3.ap-northeast-1.amazonaws.com",
        @dummy.avatar.s3_bucket.client.config.endpoint.host
    end
  end

  context "dynamic s3_host_name" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        s3_host_name: lambda {|a| a.instance.value }
      @dummy = Dummy.new
      class << @dummy
        attr_accessor :value
      end
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "uses s3_host_name as a proc if available" do
      @dummy.value = "s3.something.com"
      assert_equal "//s3.something.com/bucket/avatars/data", @dummy.avatar.url(:original, timestamp: false)
    end
  end

  context "use_accelerate_endpoint" do
    context "defaults to false" do
      before do
        rebuild_model(
          storage: :s3,
          s3_credentials: {},
          bucket: "bucket",
          path: ":attachment/:basename:dotextension",
          s3_host_name: "s3-ap-northeast-1.amazonaws.com",
          s3_region: "ap-northeast-1",
        )
        @dummy = Dummy.new
        @dummy.avatar = stringy_file
        @dummy.stubs(:new_record?).returns(false)
      end

      it "returns a url based on an :s3_host_name path" do
        assert_match %r{^//s3-ap-northeast-1.amazonaws.com/bucket/avatars/data[^\.]},
          @dummy.avatar.url
      end

      it "uses the S3 client with the use_accelerate_endpoint config is false" do
        expect(@dummy.avatar.s3_bucket.client.config.use_accelerate_endpoint).to be(false)
      end
    end

    context "set to true" do
      before do
        rebuild_model(
          storage: :s3,
          s3_credentials: {},
          bucket: "bucket",
          path: ":attachment/:basename:dotextension",
          s3_host_name: "s3-accelerate.amazonaws.com",
          s3_region: "ap-northeast-1",
          use_accelerate_endpoint: true,
        )
        @dummy = Dummy.new
        @dummy.avatar = stringy_file
        @dummy.stubs(:new_record?).returns(false)
      end

      it "returns a url based on an :s3_host_name path" do
        assert_match %r{^//s3-accelerate.amazonaws.com/bucket/avatars/data[^\.]},
          @dummy.avatar.url
      end

      it "uses the S3 client with the use_accelerate_endpoint config is true" do
        expect(@dummy.avatar.s3_bucket.client.config.use_accelerate_endpoint).to be(true)
      end
    end
  end

  context "An attachment that uses S3 for storage and has styles that return different file types" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        styles: { large: ['500x500#', :jpg] },
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        }

        File.open(fixture_file('5k.png'), 'rb') do |file|
          @dummy = Dummy.new
          @dummy.avatar = file
          @dummy.stubs(:new_record?).returns(false)
        end
    end

    it "returns a url containing the correct original file mime type" do
      assert_match /.+\/5k.png/, @dummy.avatar.url
    end

    it 'uses the correct key for the original file mime type' do
      assert_match /.+\/5k.png/, @dummy.avatar.s3_object.key
    end

    it "returns a url containing the correct processed file mime type" do
      assert_match /.+\/5k.jpg/, @dummy.avatar.url(:large)
    end

    it "uses the correct key for the processed file mime type" do
      assert_match /.+\/5k.jpg/, @dummy.avatar.s3_object(:large).key
    end
  end

  context "An attachment that uses S3 for storage and has a proc for styles" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        styles: lambda { |attachment| attachment.instance.counter
          {thumbnail: { geometry: "50x50#",
                        s3_headers: {'Cache-Control' => 'max-age=31557600'}} }},
        bucket: "bucket",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        }

        @file = File.new(fixture_file('5k.png'), 'rb')

        Dummy.class_eval do
          def counter
            @counter ||= 0
            @counter += 1
            @counter
          end
        end

        @dummy = Dummy.new
        @dummy.avatar = @file

        object = stub
        @dummy.avatar.stubs(:s3_object).with(:original).returns(object)
        @dummy.avatar.stubs(:s3_object).with(:thumbnail).returns(object)

        object.expects(:upload_file)
          .with(anything, content_type: 'image/png',
                acl: :"public-read")
        object.expects(:upload_file)
          .with(anything, content_type: 'image/png',
                acl: :"public-read",
                cache_control: 'max-age=31557600')
        @dummy.save
    end

    after { @file.close }

    it "succeeds" do
      assert_equal @dummy.counter, 7
    end
  end

  context "An attachment that uses S3 for storage and has styles" do
    before do
      rebuild_model(
        (aws2_add_region).merge(
          storage: :s3,
          styles: { thumb: ["90x90#", :jpg] },
          bucket: "bucket",
          s3_credentials: {
            "access_key_id" => "12345",
            "secret_access_key" => "54321" }
        )
      )

      @file = File.new(fixture_file("5k.png"), "rb")
      @dummy = Dummy.new
      @dummy.avatar = @file
      @dummy.save
    end

    context "reprocess" do
      before do
        @object = stub
        @dummy.avatar.stubs(:s3_object).with(:original).returns(@object)
        @dummy.avatar.stubs(:s3_object).with(:thumb).returns(@object)
        @object.stubs(:get).yields(@file.read)
        @object.stubs(:exists?).returns(true)
      end

      it "uploads original" do
        @object.expects(:upload_file).with(
          anything,
          content_type: "image/png",
          acl: :"public-read").returns(true)
        @object.expects(:upload_file).with(
          anything,
          content_type: "image/jpeg",
          acl: :"public-read").returns(true)
        @dummy.avatar.reprocess!
      end

      it "doesn't upload original" do
        @object.expects(:upload_file).with(
          anything,
          content_type: "image/jpeg",
          acl: :"public-read").returns(true)
        @dummy.avatar.reprocess!(:thumb)
      end
    end

    after { @file.close }
  end

  context "An attachment that uses S3 for storage and has spaces in file name" do
    before do
      rebuild_model(
        (aws2_add_region).merge storage: :s3,
        styles: { large: ["500x500#", :jpg] },
        bucket: "bucket",
        s3_credentials: { "access_key_id" => "12345",
                          "secret_access_key" => "54321" }
        )

      File.open(fixture_file("spaced file.png"), "rb") do |file|
        @dummy = Dummy.new
        @dummy.avatar = file
        @dummy.stubs(:new_record?).returns(false)
      end
    end

    it "returns a replaced version for path" do
      assert_match /.+\/spaced_file\.png/, @dummy.avatar.path
    end

    it "returns a replaced version for url" do
      assert_match /.+\/spaced_file\.png/, @dummy.avatar.url
    end
  end

  context "An attachment that uses S3 for storage and has a question mark in file name" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        styles: { large: ['500x500#', :jpg] },
        bucket: "bucket",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        }

      stringio = stringy_file
      class << stringio
        def original_filename
          "question?mark.png"
        end
      end
      file = Paperclip.io_adapters.for(stringio, hash_digest: Digest::MD5)
      @dummy = Dummy.new
      @dummy.avatar = file
      @dummy.save
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a replaced version for path" do
      assert_match /.+\/question_mark\.png/, @dummy.avatar.path
    end

    it "returns a replaced version for url" do
      assert_match /.+\/question_mark\.png/, @dummy.avatar.url
    end
  end

  context "" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        url: ":s3_domain_url"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on an S3 subdomain" do
      assert_match %r{^//bucket.s3.amazonaws.com/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "" do
    before do
      rebuild_model(
        (aws2_add_region).merge storage: :s3,
        s3_credentials: {
          production: { bucket: "prod_bucket" },
          development: { bucket: "dev_bucket" }
        },
        bucket: "bucket",
        s3_host_alias: "something.something.com",
        path: ":attachment/:basename:dotextension",
        url: ":s3_alias_url"
        )
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on the host_alias" do
      assert_match %r{^//something.something.com/avatars/data[^\.]}, @dummy.avatar.url
    end
  end

  context "generating a url with a prefixed host alias" do
    before do
      rebuild_model(
        aws2_add_region.merge(
          storage: :s3,
          s3_credentials: {
            production: { bucket: "prod_bucket" },
            development: { bucket: "dev_bucket" },
          },
          bucket: "bucket",
          s3_host_alias: "something.something.com",
          s3_prefixes_in_alias: 2,
          path: "prefix1/prefix2/:attachment/:basename:dotextension",
          url: ":s3_alias_url",
        )
      )
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url with the prefixes removed" do
      assert_match %r{^//something.something.com/avatars/data[^\.]},
                   @dummy.avatar.url
    end
  end

  context "generating a url with a proc as the host alias" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: { bucket: "prod_bucket" },
        s3_host_alias: Proc.new{|atch| "cdn#{atch.instance.counter % 4}.example.com"},
        path: ":attachment/:basename:dotextension",
        url: ":s3_alias_url"
      Dummy.class_eval do
        def counter
          @counter ||= 0
          @counter += 1
          @counter
        end
      end
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a url based on the host_alias" do
      assert_match %r{^//cdn1.example.com/avatars/data[^\.]}, @dummy.avatar.url
      assert_match %r{^//cdn2.example.com/avatars/data[^\.]}, @dummy.avatar.url
    end

    it "still returns the bucket name" do
      assert_equal "prod_bucket", @dummy.avatar.bucket_name
    end

  end

  context "" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {},
        bucket: "bucket",
        path: ":attachment/:basename:dotextension",
        url: ":asset_host"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      @dummy.stubs(:new_record?).returns(false)
    end

    it "returns a relative URL for Rails to calculate assets host" do
      assert_match %r{^avatars/data[^\.]}, @dummy.avatar.url
    end

  end

  context "Generating a secure url with an expiration" do
    before do
      @build_model_with_options = lambda {|options|
        base_options = {
          storage: :s3,
          s3_credentials: {
            production: { bucket: "prod_bucket" },
            development: { bucket: "dev_bucket" }
          },
          s3_host_alias: "something.something.com",
          s3_permissions: "private",
          path: ":attachment/:basename:dotextension",
          url: ":s3_alias_url"
        }

        rebuild_model (aws2_add_region).merge base_options.merge(options)
      }
    end

    it "uses default options" do
      @build_model_with_options[{}]

      rails_env("production") do
        @dummy = Dummy.new
        @dummy.avatar = stringy_file

        object = stub
        @dummy.avatar.stubs(:s3_object).returns(object)

        object.expects(:presigned_url).with(:get, expires_in: 3600)
        @dummy.avatar.expiring_url
      end
    end

    it "allows overriding s3_url_options" do
      @build_model_with_options[s3_url_options: { response_content_disposition: "inline" }]

      rails_env("production") do
        @dummy = Dummy.new
        @dummy.avatar = stringy_file

        object = stub
        @dummy.avatar.stubs(:s3_object).returns(object)
        object.expects(:presigned_url)
          .with(:get, expires_in: 3600,
                response_content_disposition: "inline")
        @dummy.avatar.expiring_url
      end
    end

    it "allows overriding s3_object options with a proc" do
      @build_model_with_options[s3_url_options: lambda {|attachment| { response_content_type: attachment.avatar_content_type } }]

      rails_env("production") do
        @dummy = Dummy.new

        @file = stringy_file
        @file.stubs(:original_filename).returns("5k.png\n\n")
        Paperclip.stubs(:run).returns('image/png')
        @file.stubs(:content_type).returns("image/png\n\n")
        @file.stubs(:to_tempfile).returns(@file)

        @dummy.avatar = @file

        object = stub
        @dummy.avatar.stubs(:s3_object).returns(object)
        object.expects(:presigned_url)
          .with(:get, expires_in: 3600, response_content_type: "image/png")
        @dummy.avatar.expiring_url
      end
    end
  end

  context "#expiring_url" do
    before { @dummy = Dummy.new }

    context "with no attachment" do
      before { assert(!@dummy.avatar.exists?) }

      it "returns the default URL" do
        assert_equal(@dummy.avatar.url, @dummy.avatar.expiring_url)
      end

      it 'generates a url for a style when a file does not exist' do
        assert_equal(@dummy.avatar.url(:thumb), @dummy.avatar.expiring_url(3600, :thumb))
      end
    end

    it "generates the same url when using Times and Integer offsets" do
      assert_equal @dummy.avatar.expiring_url(1234), @dummy.avatar.expiring_url(Time.now + 1234)
    end
  end

  context "Generating a url with an expiration for each style" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {
          production: { bucket: "prod_bucket" },
          development: { bucket: "dev_bucket" }
        },
        s3_permissions: :private,
        s3_host_alias: "something.something.com",
        path: ":attachment/:style/:basename:dotextension",
        url: ":s3_alias_url"

      rails_env("production") do
        @dummy = Dummy.new
        @dummy.avatar = stringy_file
      end
    end

    it "generates a url for the thumb" do
      object = stub
      @dummy.avatar.stubs(:s3_object).with(:thumb).returns(object)
      object.expects(:presigned_url).with(:get, expires_in: 1800)
      @dummy.avatar.expiring_url(1800, :thumb)
    end

    it "generates a url for the default style" do
      object = stub
      @dummy.avatar.stubs(:s3_object).with(:original).returns(object)
      object.expects(:presigned_url).with(:get, expires_in: 1800)
      @dummy.avatar.expiring_url(1800)
    end
  end

  context "Parsing S3 credentials with a bucket in them" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        s3_credentials: {
          production: { bucket: "prod_bucket" },
          development: { bucket: "dev_bucket" }
        }
      @dummy = Dummy.new
    end

    it "gets the right bucket in production" do
      rails_env("production") do
        assert_equal "prod_bucket", @dummy.avatar.bucket_name
        assert_equal "prod_bucket", @dummy.avatar.s3_bucket.name
      end
    end

    it "gets the right bucket in development" do
      rails_env("development") do
        assert_equal "dev_bucket", @dummy.avatar.bucket_name
        assert_equal "dev_bucket", @dummy.avatar.s3_bucket.name
      end
    end
  end

  # the bucket.name is determined by the :s3_region
  context "Parsing S3 credentials with a s3_host_name in them" do
    before do
      rebuild_model storage: :s3,
        bucket: 'testing',
        s3_credentials: {
        production: {
          s3_region: "world-end",
          s3_host_name: "s3-world-end.amazonaws.com" },
        development: {
          s3_region: "ap-northeast-1",
          s3_host_name: "s3-ap-northeast-1.amazonaws.com" },
        test: {
          s3_region: "" }
        }
      @dummy = Dummy.new
    end

    it "gets the right s3_host_name in production" do
      rails_env("production") do
        assert_match %r{^s3-world-end.amazonaws.com}, @dummy.avatar.s3_host_name
        assert_match %r{^s3.world-end.amazonaws.com},
          @dummy.avatar.s3_bucket.client.config.endpoint.host
      end
    end

    it "gets the right s3_host_name in development" do
      rails_env("development") do
        assert_match %r{^s3.ap-northeast-1.amazonaws.com},
          @dummy.avatar.s3_host_name
        assert_match %r{^s3.ap-northeast-1.amazonaws.com},
          @dummy.avatar.s3_bucket.client.config.endpoint.host
      end
    end

    it "gets the right s3_host_name if the key does not exist" do
      rails_env("test") do
        assert_match %r{^s3.amazonaws.com}, @dummy.avatar.s3_host_name
        assert_raises(Aws::Errors::MissingRegionError) do
          @dummy.avatar.s3_bucket.client.config.endpoint.host
        end
      end
    end
  end

  context "An attachment with S3 storage" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          access_key_id: "12345",
          secret_access_key: "54321"
        }
    end

    it "is extended by the S3 module" do
      assert Dummy.new.avatar.is_a?(Paperclip::Storage::S3)
    end

    it "won't be extended by the Filesystem module" do
      assert ! Dummy.new.avatar.is_a?(Paperclip::Storage::Filesystem)
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
        @dummy.stubs(:new_record?).returns(false)
      end

      after { @file.close }

      it "does not get a bucket to get a URL" do
        @dummy.avatar.expects(:s3).never
        @dummy.avatar.expects(:s3_bucket).never
        assert_match %r{^//s3\.amazonaws\.com/testing/avatars/original/5k\.png}, @dummy.avatar.url
      end

      it "is rewound after flush_writes" do
        @dummy.avatar.instance_eval "def after_flush_writes; end"
        @dummy.avatar.stubs(:s3_object).returns(stub(upload_file: true))
        files = @dummy.avatar.queued_for_write.values.each(&:read)
        @dummy.save
        assert files.none?(&:eof?), "Expect all the files to be rewound."
      end

      it "is removed after after_flush_writes" do
        @dummy.avatar.stubs(:s3_object).returns(stub(upload_file: true))
        paths = @dummy.avatar.queued_for_write.values.map(&:path)
        @dummy.save
        assert paths.none?{ |path| File.exist?(path) },
          "Expect all the files to be deleted."
      end

      it "will retry to save again but back off on SlowDown" do
        @dummy.avatar.stubs(:sleep)
        Aws::S3::Object.any_instance.stubs(:upload_file).
          raises(Aws::S3::Errors::SlowDown.new(stub,
                                               stub(status: 503, body: "")))
        expect {@dummy.save}.to raise_error(Aws::S3::Errors::SlowDown)
        expect(@dummy.avatar).to have_received(:sleep).with(1)
        expect(@dummy.avatar).to have_received(:sleep).with(2)
        expect(@dummy.avatar).to have_received(:sleep).with(4)
        expect(@dummy.avatar).to have_received(:sleep).with(8)
        expect(@dummy.avatar).to have_received(:sleep).with(16)
      end

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)
          object.expects(:upload_file)
            .with(anything, content_type: 'image/png', acl: :"public-read")
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end

      context "and saved without a bucket" do
        before do
          Aws::S3::Bucket.any_instance.expects(:create)
          Aws::S3::Object.any_instance.stubs(:upload_file).
            raises(Aws::S3::Errors::NoSuchBucket
                    .new(stub,
                         stub(status: 404, body: "<foo/>"))).then.returns(nil)
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end

      context "and remove" do
        before do
          Aws::S3::Object.any_instance.stubs(:exists?).returns(true)
          Aws::S3::Object.any_instance.stubs(:delete)
          @dummy.destroy
        end

        it "succeeds" do
          assert true
        end
      end

      context 'that the file were missing' do
        before do
          Aws::S3::Object.any_instance.stubs(:exists?)
            .raises(Aws::S3::Errors::ServiceError.new("rspec stub raises",
                                                      "object exists?"))
        end

        it 'returns false on exists?' do
          assert !@dummy.avatar.exists?
        end
      end
    end
  end

  context "An attachment with S3 storage and bucket defined as a Proc" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: lambda { |attachment| "bucket_#{attachment.instance.other}" },
        s3_credentials: {not: :important}
    end

    it "gets the right bucket name" do
      assert "bucket_a", Dummy.new(other: 'a').avatar.bucket_name
      assert "bucket_a", Dummy.new(other: 'a').avatar.s3_bucket.name
      assert "bucket_b", Dummy.new(other: 'b').avatar.bucket_name
      assert "bucket_b", Dummy.new(other: 'b').avatar.s3_bucket.name
    end
  end

  context "An attachment with S3 storage and S3 credentials defined as a Proc" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: {not: :important},
        s3_credentials: lambda { |attachment|
          Hash['access_key_id' => "access#{attachment.instance.other}", 'secret_access_key' => "secret#{attachment.instance.other}"]
        }
    end

    it "gets the right credentials" do
      assert "access1234", Dummy.new(other: '1234').avatar.s3_credentials[:access_key_id]
      assert "secret1234", Dummy.new(other: '1234').avatar.s3_credentials[:secret_access_key]
    end
  end

  context "An attachment with S3 storage and S3 credentials with a :credential_provider" do
    before do
      class DummyCredentialProvider; end

      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        s3_credentials: {
          credentials: DummyCredentialProvider.new
        }
      @dummy = Dummy.new
    end

    it "sets the credential-provider" do
      expect(@dummy.avatar.s3_bucket.client.config.credentials).to be_a DummyCredentialProvider
    end
  end

  context "An attachment with S3 storage and S3 credentials in an unsupported manor" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing", s3_credentials: ["unsupported"]
      @dummy = Dummy.new
    end

    it "does not accept the credentials" do
      assert_raises(ArgumentError) do
        @dummy.avatar.s3_credentials
      end
    end
  end

  context "An attachment with S3 storage and S3 credentials not supplied" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3, bucket: "testing"
      @dummy = Dummy.new
    end

    it "does not parse any credentials" do
      assert_equal({}, @dummy.avatar.s3_credentials)
    end
  end

  context "An attachment with S3 storage and specific s3 headers set" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_headers: {'Cache-Control' => 'max-age=31557600'}
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)

          object.expects(:upload_file)
            .with(anything,
                  content_type: 'image/png',
                  acl: :"public-read",
                  cache_control: 'max-age=31557600')
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "An attachment with S3 storage and metadata set using header names" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_headers: {'x-amz-meta-color' => 'red'}
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)

          object.expects(:upload_file)
            .with(anything,
                  content_type: 'image/png',
                  acl: :"public-read",
                  metadata: { "color" => "red" })
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "An attachment with S3 storage and metadata set using the :s3_metadata option" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_metadata: { "color" => "red" }
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)

          object.expects(:upload_file)
            .with(anything,
                  content_type: 'image/png',
                  acl: :"public-read",
                  metadata: { "color" => "red" })
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "An attachment with S3 storage and storage class set" do
    context "using the header name" do
      before do
        rebuild_model (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          s3_credentials: {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          s3_headers: { "x-amz-storage-class" => "reduced_redundancy" }
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            @dummy.avatar.stubs(:s3_object).returns(object)

            object.expects(:upload_file)
              .with(anything,
                    content_type: 'image/png',
                    acl: :"public-read",
                    storage_class: "reduced_redundancy")
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end

    context "using per style hash" do
      before do
        rebuild_model (aws2_add_region).merge :storage => :s3,
          :bucket => "testing",
          :path => ":attachment/:style/:basename.:extension",
          :styles => {
            :thumb => "80x80>"
          },
          :s3_credentials => {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          :s3_storage_class => {
            :thumb => :reduced_redundancy
          }
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            [:thumb, :original].each do |style|
              @dummy.avatar.stubs(:s3_object).with(style).returns(object)

              expected_options = {
                :content_type => "image/png",
                acl: :"public-read"
              }
              expected_options.merge!(:storage_class => :reduced_redundancy) if style == :thumb

              object.expects(:upload_file)
                .with(anything, expected_options)
            end
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end

    context "using global hash option" do
      before do
        rebuild_model (aws2_add_region).merge :storage => :s3,
          :bucket => "testing",
          :path => ":attachment/:style/:basename.:extension",
          :styles => {
            :thumb => "80x80>"
          },
          :s3_credentials => {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          :s3_storage_class => :reduced_redundancy
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            [:thumb, :original].each do |style|
              @dummy.avatar.stubs(:s3_object).with(style).returns(object)

              object.expects(:upload_file)
                .with(anything, :content_type => "image/png",
                      acl: :"public-read",
                      :storage_class => :reduced_redundancy)
            end
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end
  end

  context "Can disable AES256 encryption multiple ways" do
    [nil, false, ''].each do |tech|
      before do
        rebuild_model(
          (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          s3_credentials: {
            'access_key_id'          => "12345",
            'secret_access_key'      => "54321"},
            s3_server_side_encryption: tech)
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            @dummy.avatar.stubs(:s3_object).returns(object)

            object.expects(:upload_file)
              .with(anything, :content_type => "image/png", acl: :"public-read")
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end
  end

  context "An attachment with S3 storage and using AES256 encryption" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_server_side_encryption: "AES256"
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)

          object.expects(:upload_file)
            .with(anything, content_type: "image/png",
                  acl: :"public-read",
                  server_side_encryption: "AES256")
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "An attachment with S3 storage and storage class set using the :storage_class option" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_storage_class: :reduced_redundancy
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          object = stub
          @dummy.avatar.stubs(:s3_object).returns(object)

          object.expects(:upload_file)
            .with(anything,
                  content_type: "image/png",
                  acl: :"public-read",
                  storage_class: :reduced_redundancy)
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "with S3 credentials supplied as Pathname" do
    before do
      ENV['S3_KEY']    = 'pathname_key'
      ENV['S3_BUCKET'] = 'pathname_bucket'
      ENV['S3_SECRET'] = 'pathname_secret'

      rails_env('test') do
        rebuild_model (aws2_add_region).merge storage: :s3,
          s3_credentials: Pathname.new(fixture_file('s3.yml'))

        Dummy.delete_all
        @dummy = Dummy.new
      end
    end

    it "parses the credentials" do
      assert_equal 'pathname_bucket', @dummy.avatar.bucket_name

      assert_equal 'pathname_key',
         @dummy.avatar.s3_bucket.client.config.access_key_id

      assert_equal 'pathname_secret',
         @dummy.avatar.s3_bucket.client.config.secret_access_key
    end
  end

  context "with S3 credentials in a YAML file" do
    before do
      ENV['S3_KEY']    = 'env_key'
      ENV['S3_BUCKET'] = 'env_bucket'
      ENV['S3_SECRET'] = 'env_secret'

      rails_env('test') do
        rebuild_model (aws2_add_region).merge storage: :s3,
          s3_credentials: File.new(fixture_file('s3.yml'))

        Dummy.delete_all

        @dummy = Dummy.new
      end
    end

    it "runs the file through ERB" do
      assert_equal 'env_bucket', @dummy.avatar.bucket_name

      assert_equal 'env_key',
          @dummy.avatar.s3_bucket.client.config.access_key_id

      assert_equal 'env_secret',
          @dummy.avatar.s3_bucket.client.config.secret_access_key
    end
  end

  context "S3 Permissions" do
    context "defaults to :public_read" do
      before do
        rebuild_model (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          s3_credentials: {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          }
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            @dummy.avatar.stubs(:s3_object).returns(object)

            object.expects(:upload_file)
              .with(anything, content_type: "image/png", acl: :"public-read")
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end

    context "string permissions set" do
      before do
        rebuild_model (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          s3_credentials: {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          s3_permissions: :private
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            object = stub
            @dummy.avatar.stubs(:s3_object).returns(object)

            object.expects(:upload_file)
              .with(anything, content_type: "image/png", acl: :private)
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end

    context "hash permissions set" do
      before do
        rebuild_model (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          styles: {
            thumb: "80x80>"
          },
          s3_credentials: {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          s3_permissions: {
            original: :private,
            thumb: :public_read
          }
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        after { @file.close }

        context "and saved" do
          before do
            [:thumb, :original].each do |style|
              object = stub
              @dummy.avatar.stubs(:s3_object).with(style).returns(object)

              object.expects(:upload_file)
                .with(anything,
                      content_type: "image/png",
                      acl: style == :thumb ? :public_read : :private)
            end
            @dummy.save
          end

          it "succeeds" do
            assert true
          end
        end
      end
    end

    context "proc permission set" do
      before do
        rebuild_model(
          (aws2_add_region).merge storage: :s3,
          bucket: "testing",
          path: ":attachment/:style/:basename:dotextension",
          styles: {
            thumb: "80x80>"
          },
          s3_credentials: {
            'access_key_id' => "12345",
            'secret_access_key' => "54321"
          },
          s3_permissions: lambda {|attachment, style|
            attachment.instance.private_attachment? && style.to_sym != :thumb ? :private : :"public-read"
          }
        )
      end
    end
  end

  context "An attachment with S3 storage and metadata set using a proc as headers" do
    before do
      rebuild_model(
        (aws2_add_region).merge storage: :s3,
        bucket: "testing",
        path: ":attachment/:style/:basename:dotextension",
        styles: {
          thumb: "80x80>"
        },
        s3_credentials: {
          'access_key_id' => "12345",
          'secret_access_key' => "54321"
        },
        s3_headers: lambda {|attachment|
          {'Content-Disposition' => "attachment; filename=\"#{attachment.name}\""}
        }
      )
    end

    context "when assigned" do
      before do
        @file = File.new(fixture_file('5k.png'), 'rb')
        @dummy = Dummy.new
        @dummy.stubs(name: 'Custom Avatar Name.png')
        @dummy.avatar = @file
      end

      after { @file.close }

      context "and saved" do
        before do
          [:thumb, :original].each do |style|
            object = stub
            @dummy.avatar.stubs(:s3_object).with(style).returns(object)

            object.expects(:upload_file)
              .with(anything,
                    content_type: "image/png",
                    acl: :"public-read",
                    content_disposition: 'attachment; filename="Custom Avatar Name.png"')
          end
          @dummy.save
        end

        it "succeeds" do
          assert true
        end
      end
    end
  end

  context "path is a proc" do
    before do
      rebuild_model (aws2_add_region).merge storage: :s3,
        path: ->(attachment) { attachment.instance.attachment_path }

      @dummy = Dummy.new
      @dummy.class_eval do
        def attachment_path
          '/some/dynamic/path'
        end
      end
      @dummy.avatar = stringy_file
    end

    it "returns a correct path" do
      assert_match '/some/dynamic/path', @dummy.avatar.path
    end
  end

  private

  def rails_env(env)
    stored_env, Rails.env = Rails.env, env
    begin
      yield
    ensure
      Rails.env = stored_env
    end
  end
end
