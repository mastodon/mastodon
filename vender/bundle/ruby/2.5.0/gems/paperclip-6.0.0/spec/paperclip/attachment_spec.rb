# encoding: utf-8
require 'spec_helper'

describe Paperclip::Attachment do

  it "is not present when file not set" do
    rebuild_class
    dummy = Dummy.new
    expect(dummy.avatar).to be_blank
    expect(dummy.avatar).to_not be_present
  end

  it "is present when the file is set" do
    rebuild_class
    dummy = Dummy.new
    dummy.avatar = File.new(fixture_file("50x50.png"), "rb")
    expect(dummy.avatar).to_not be_blank
    expect(dummy.avatar).to be_present
  end

  it "processes :original style first" do
    file = File.new(fixture_file("50x50.png"), 'rb')
    rebuild_class styles: { small: '100x>', original: '42x42#' }
    dummy = Dummy.new
    dummy.avatar = file
    dummy.save

    # :small avatar should be 42px wide (processed original), not 50px (preprocessed original)
    expect(`identify -format "%w" "#{dummy.avatar.path(:small)}"`.strip).to eq "42"

    file.close
  end

  it "does not delete styles that don't get reprocessed" do
    file = File.new(fixture_file("50x50.png"), 'rb')
    rebuild_class styles: {
      small: "100x>",
      large: "500x>",
      original: "42x42#"
    }

    dummy = Dummy.new
    dummy.avatar = file
    dummy.save

    expect(dummy.avatar.path(:small)).to exist
    expect(dummy.avatar.path(:large)).to exist
    expect(dummy.avatar.path(:original)).to exist

    dummy.avatar.reprocess!(:small)

    expect(dummy.avatar.path(:small)).to exist
    expect(dummy.avatar.path(:large)).to exist
    expect(dummy.avatar.path(:original)).to exist
  end

  context "having a not empty hash as a default option" do
    before do
      @old_default_options = Paperclip::Attachment.default_options.dup
      @new_default_options = { convert_options: { all: "-background white" } }
      Paperclip::Attachment.default_options.merge!(@new_default_options)
    end

    after do
      Paperclip::Attachment.default_options.merge!(@old_default_options)
    end

    it "deep merges when it is overridden" do
      new_options = { convert_options: { thumb: "-thumbnailize" } }
      attachment = Paperclip::Attachment.new(:name, :instance, new_options)

      expect(Paperclip::Attachment.default_options.deep_merge(new_options)).to eq attachment.instance_variable_get("@options")
    end
  end

  it "handles a boolean second argument to #url" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(
      :name,
      FakeModel.new,
      url_generator: mock_url_generator_builder
      )

    attachment.url(:style_name, true)
    expect(mock_url_generator_builder.has_generated_url_with_options?(timestamp: true, escape: true)).to eq true

    attachment.url(:style_name, false)
    expect(mock_url_generator_builder.has_generated_url_with_options?(timestamp: false, escape: true)).to eq true
  end

  it "passes the style and options through to the URL generator on #url" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(
      :name,
      FakeModel.new,
      url_generator: mock_url_generator_builder
      )

    attachment.url(:style_name, options: :values)
    expect(mock_url_generator_builder.has_generated_url_with_options?(options: :values)).to eq true
  end

  it "passes default options through when #url is given one argument" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           use_timestamp: true)

    attachment.url(:style_name)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true, timestamp: true)
  end

  it "passes default style and options through when #url is given no arguments" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           default_style: 'default style',
                                           url_generator: mock_url_generator_builder,
                                           use_timestamp: true)

    attachment.url
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true, timestamp: true)
    assert mock_url_generator_builder.has_generated_url_with_style_name?('default style')
  end

  it "passes the option timestamp: true if :use_timestamp is true and :timestamp is not passed" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           use_timestamp: true)

    attachment.url(:style_name)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true, timestamp: true)
  end

  it "passes the option timestamp: false if :use_timestamp is false and :timestamp is not passed" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           use_timestamp: false)

    attachment.url(:style_name)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true, timestamp: false)
  end

  it "does not change the :timestamp if :timestamp is passed" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           use_timestamp: false)

    attachment.url(:style_name, timestamp: true)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true, timestamp: true)
  end

  it "renders JSON as default style" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           default_style: 'default style',
                                           url_generator: mock_url_generator_builder)

    attachment.as_json
    assert mock_url_generator_builder.has_generated_url_with_style_name?('default style')
  end

  it "passes the option escape: true if :escape_url is true and :escape is not passed" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           escape_url: true)

    attachment.url(:style_name)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: true)
  end

  it "passes the option escape: false if :escape_url is false and :escape is not passed" do
    mock_url_generator_builder = MockUrlGeneratorBuilder.new
    attachment = Paperclip::Attachment.new(:name,
                                           FakeModel.new,
                                           url_generator: mock_url_generator_builder,
                                           escape_url: false)

    attachment.url(:style_name)
    assert mock_url_generator_builder.has_generated_url_with_options?(escape: false)
  end

  it "returns the path based on the url by default" do
    @attachment = attachment url: "/:class/:id/:basename"
    @model = @attachment.instance
    @model.id = 1234
    @model.avatar_file_name = "fake.jpg"
    assert_equal "#{Rails.root}/public/fake_models/1234/fake", @attachment.path
  end

  it "defaults to a path that scales" do
    avatar_attachment = attachment
    model = avatar_attachment.instance
    model.id = 1234
    model.avatar_file_name = "fake.jpg"
    expected_path = "#{Rails.root}/public/system/fake_models/avatars/000/001/234/original/fake.jpg"
    assert_equal expected_path, avatar_attachment.path
  end

  it "renders JSON as the URL to the attachment" do
    avatar_attachment = attachment
    model = avatar_attachment.instance
    model.id = 1234
    model.avatar_file_name = "fake.jpg"
    assert_equal attachment.url, attachment.as_json
  end

  it "renders JSON from the model when requested by :methods" do
    rebuild_model
    dummy = Dummy.new
    dummy.id = 1234
    dummy.avatar_file_name = "fake.jpg"
    dummy.stubs(:new_record?).returns(false)
    expected_string = '{"avatar":"/system/dummies/avatars/000/001/234/original/fake.jpg"}'
    # active_model pre-3.2 checks only by calling any? on it, thus it doesn't work if it is empty
    assert_equal expected_string, dummy.to_json(only: [:dummy_key_for_old_active_model], methods: [:avatar])
  end

  context "Attachment default_options" do
    before do
      rebuild_model
      @old_default_options = Paperclip::Attachment.default_options.dup
      @new_default_options = @old_default_options.merge({
        path: "argle/bargle",
        url: "fooferon",
        default_url: "not here.png"
      })
    end

    after do
      Paperclip::Attachment.default_options.merge! @old_default_options
    end

    it "is overrideable" do
      Paperclip::Attachment.default_options.merge!(@new_default_options)
      @new_default_options.keys.each do |key|
        assert_equal @new_default_options[key],
                     Paperclip::Attachment.default_options[key]
      end
    end

    context "without an Attachment" do
      before do
        rebuild_model default_url: "default.url"
        @dummy = Dummy.new
      end

      it "returns false when asked exists?" do
        assert !@dummy.avatar.exists?
      end

      it "#url returns the default_url" do
        expect(@dummy.avatar.url).to eq "default.url"
      end
    end

    context "on an Attachment" do
      before do
        @dummy = Dummy.new
        @attachment = @dummy.avatar
      end

      Paperclip::Attachment.default_options.keys.each do |key|
        it "is the default_options for #{key}" do
          assert_equal @old_default_options[key],
                       @attachment.instance_variable_get("@options")[key],
                       key.to_s
        end
      end

      context "when redefined" do
        before do
          Paperclip::Attachment.default_options.merge!(@new_default_options)
          @dummy = Dummy.new
          @attachment = @dummy.avatar
        end

        Paperclip::Attachment.default_options.keys.each do |key|
          it "is the new default_options for #{key}" do
            assert_equal @new_default_options[key],
                         @attachment.instance_variable_get("@options")[key],
                         key.to_s
          end
        end
      end
    end
  end

  context "An attachment with similarly named interpolations" do
    before do
      rebuild_model path: ":id.omg/:id-bbq/:idwhat/:id_partition.wtf"
      @dummy = Dummy.new
      @dummy.stubs(:id).returns(1024)
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
    end

    after { @file.close }

    it "makes sure that they are interpolated correctly" do
      assert_equal "1024.omg/1024-bbq/1024what/000/001/024.wtf", @dummy.avatar.path
    end
  end

  context "An attachment with :timestamp interpolations" do
    before do
      @file = StringIO.new("...")
      @zone = 'UTC'
      Time.stubs(:zone).returns(@zone)
      @zone_default = 'Eastern Time (US & Canada)'
      Time.stubs(:zone_default).returns(@zone_default)
    end

    context "using default time zone" do
      before do
        rebuild_model path: ":timestamp", use_default_time_zone: true
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      it "returns a time in the default zone" do
        assert_equal @dummy.avatar_updated_at.in_time_zone(@zone_default).to_s, @dummy.avatar.path
      end
    end

    context "using per-thread time zone" do
      before do
        rebuild_model path: ":timestamp", use_default_time_zone: false
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      it "returns a time in the per-thread zone" do
        assert_equal @dummy.avatar_updated_at.in_time_zone(@zone).to_s, @dummy.avatar.path
      end
    end
  end

  context "An attachment with :hash interpolations" do
    before do
      @file = File.open(fixture_file("5k.png"))
    end

    after do
      @file.close
    end

    it "raises if no secret is provided" do
      rebuild_model path: ":hash"
      @attachment = Dummy.new.avatar
      @attachment.assign @file

      assert_raises ArgumentError do
        @attachment.path
      end
    end

    context "when secret is set" do
      before do
        rebuild_model path: ":hash",
          hash_secret: "w00t",
          hash_data: ":class/:attachment/:style/:filename"
        @attachment = Dummy.new.avatar
        @attachment.assign @file
      end

      it "results in the correct interpolation" do
        assert_equal "dummies/avatars/original/5k.png",
          @attachment.send(:interpolate, @attachment.options[:hash_data])
        assert_equal "dummies/avatars/thumb/5k.png",
          @attachment.send(:interpolate, @attachment.options[:hash_data], :thumb)
      end

      it "results in a correct hash" do
        assert_equal "0a59e9142bba11576de1d353d8747b1acad5ad34", @attachment.path
        assert_equal "b39a062c1e62e85a6c785ed00cf3bebf5f850e2b", @attachment.path(:thumb)
      end
    end
  end

  context "An attachment with a :rails_env interpolation" do
    before do
      @rails_env = "blah"
      @id = 1024
      rebuild_model path: ":rails_env/:id.png"
      @dummy = Dummy.new
      @dummy.stubs(:id).returns(@id)
      @file = StringIO.new(".")
      @dummy.avatar = @file
      Rails.stubs(:env).returns(@rails_env)
    end

    it "returns the proper path" do
      assert_equal "#{@rails_env}/#{@id}.png", @dummy.avatar.path
    end
  end

  context "An attachment with a default style and an extension interpolation" do
    before do
      rebuild_model path: ":basename.:extension",
        styles: { default: ["100x100", :jpg] },
        default_style: :default
      @attachment = Dummy.new.avatar
      @file = File.open(fixture_file("5k.png"))
      @file.stubs(:original_filename).returns("file.png")
    end
    it "returns the right extension for the path" do
      @attachment.assign(@file)
      assert_equal "file.jpg", @attachment.path
    end
  end

  context "An attachment with :convert_options" do
    before do
      rebuild_model styles: {
                      thumb: "100x100",
                      large: "400x400"
                    },
                    convert_options: {
                      all: "-do_stuff",
                      thumb: "-thumbnailize"
                    }
      @dummy = Dummy.new
      @dummy.avatar
    end

    it "reports the correct options when sent #extra_options_for(:thumb)" do
      assert_equal "-thumbnailize -do_stuff", @dummy.avatar.send(:extra_options_for, :thumb), @dummy.avatar.convert_options.inspect
    end

    it "reports the correct options when sent #extra_options_for(:large)" do
      assert_equal "-do_stuff", @dummy.avatar.send(:extra_options_for, :large)
    end
  end

  context "An attachment with :source_file_options" do
    before do
      rebuild_model styles: {
                      thumb: "100x100",
                      large: "400x400"
                    },
                    source_file_options: {
                      all: "-density 400",
                      thumb: "-depth 8"
                    }
      @dummy = Dummy.new
      @dummy.avatar
    end

    it "reports the correct options when sent #extra_source_file_options_for(:thumb)" do
      assert_equal "-depth 8 -density 400", @dummy.avatar.send(:extra_source_file_options_for, :thumb), @dummy.avatar.source_file_options.inspect
    end

    it "reports the correct options when sent #extra_source_file_options_for(:large)" do
      assert_equal "-density 400", @dummy.avatar.send(:extra_source_file_options_for, :large)
    end
  end

  context "An attachment with :only_process" do
    before do
      rebuild_model styles: {
                      thumb: "100x100",
                      large: "400x400"
                    },
                    only_process: [:thumb]
      @file = StringIO.new("...")
      @attachment = Dummy.new.avatar
    end

    it "only processes the provided style" do
      @attachment.expects(:post_process).with(:thumb)
      @attachment.expects(:post_process).with(:large).never
      @attachment.assign(@file)
    end
  end

  context "An attachment with :only_process that is a proc" do
    before do
      rebuild_model styles: {
                      thumb: "100x100",
                      large: "400x400"
                    },
                    only_process: lambda { |attachment| [:thumb] }

      @file = StringIO.new("...")
      @attachment = Dummy.new.avatar
    end

    it "only processes the provided style" do
      @attachment.expects(:post_process).with(:thumb)
      @attachment.expects(:post_process).with(:large).never
      @attachment.assign(@file)
      @attachment.save
    end
  end

  context "An attachment with :convert_options that is a proc" do
    before do
      rebuild_model styles: {
                      thumb: "100x100",
                      large: "400x400"
                    },
                    convert_options: {
                      all: lambda{|i| i.all },
                      thumb: lambda{|i| i.thumb }
                    }
      Dummy.class_eval do
        def all;   "-all";   end
        def thumb; "-thumb"; end
      end
      @dummy = Dummy.new
      @dummy.avatar
    end

    it "reports the correct options when sent #extra_options_for(:thumb)" do
      assert_equal "-thumb -all", @dummy.avatar.send(:extra_options_for, :thumb), @dummy.avatar.convert_options.inspect
    end

    it "reports the correct options when sent #extra_options_for(:large)" do
      assert_equal "-all", @dummy.avatar.send(:extra_options_for, :large)
    end
  end

  context "An attachment with :path that is a proc" do
    before do
      rebuild_model path: lambda{ |attachment| "path/#{attachment.instance.other}.:extension" }

      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummyA = Dummy.new(other: 'a')
      @dummyA.avatar = @file
      @dummyB = Dummy.new(other: 'b')
      @dummyB.avatar = @file
    end

    after { @file.close }

    it "returns correct path" do
      assert_equal "path/a.png", @dummyA.avatar.path
      assert_equal "path/b.png", @dummyB.avatar.path
    end
  end

  context "An attachment with :styles that is a proc" do
    before do
      rebuild_model styles: lambda{ |attachment| {thumb: "50x50#", large: "400x400"} }

      @attachment = Dummy.new.avatar
    end

    it "has the correct geometry" do
      assert_equal "50x50#", @attachment.styles[:thumb][:geometry]
    end
  end

  context "An attachment with conditional :styles that is a proc" do
    before do
      rebuild_model styles: lambda{ |attachment| attachment.instance.other == 'a' ? {thumb: "50x50#"} : {large: "400x400"} }

      @dummy = Dummy.new(other: 'a')
    end

    it "has the correct styles for the assigned instance values" do
      assert_equal "50x50#", @dummy.avatar.styles[:thumb][:geometry]
      assert_nil @dummy.avatar.styles[:large]

      @dummy.other = 'b'

      assert_equal "400x400", @dummy.avatar.styles[:large][:geometry]
      assert_nil @dummy.avatar.styles[:thumb]
    end
  end

  geometry_specs = [
    [ lambda{|z| "50x50#" }, :png ],
    lambda{|z| "50x50#" },
    { geometry: lambda{|z| "50x50#" } }
  ]
  geometry_specs.each do |geometry_spec|
    context "An attachment geometry like #{geometry_spec}" do
      before do
        rebuild_model styles: { normal: geometry_spec }
        @attachment = Dummy.new.avatar
      end

      context "when assigned" do
        before do
          @file = StringIO.new(".")
          @attachment.assign(@file)
        end

        it "has the correct geometry" do
          assert_equal "50x50#", @attachment.styles[:normal][:geometry]
        end
      end
    end
  end

  context "An attachment with both 'normal' and hash-style styles" do
    before do
      rebuild_model styles: {
                      normal: ["50x50#", :png],
                      hash: { geometry: "50x50#", format: :png }
                    }
      @dummy = Dummy.new
      @attachment = @dummy.avatar
    end

    [:processors, :whiny, :convert_options, :geometry, :format].each do |field|
      it "has the same #{field} field" do
        assert_equal @attachment.styles[:normal][field], @attachment.styles[:hash][field]
      end
    end
  end

  context "An attachment with :processors that is a proc" do
    before do
      class Paperclip::Test < Paperclip::Processor; end
      @file = StringIO.new("...")
      Paperclip::Test.stubs(:make).returns(@file)

      rebuild_model styles: { normal: '' }, processors: lambda { |a| [ :test ] }
      @attachment = Dummy.new.avatar
    end

    context "when assigned" do
      before do
        @attachment.assign(StringIO.new("."))
      end

      it "has the correct processors" do
        assert_equal [ :test ], @attachment.styles[:normal][:processors]
      end
    end
  end

  context "An attachment with erroring processor" do
    before do
      rebuild_model processor: [:thumbnail], styles: { small: '' }, whiny_thumbnails: true
      @dummy = Dummy.new
      @file = StringIO.new("...")
      @file.stubs(:to_tempfile).returns(@file)
    end

    context "when error is meaningful for the end user" do
      before do
        Paperclip::Thumbnail.expects(:make).raises(
          Paperclip::Errors::NotIdentifiedByImageMagickError,
          "cannot be processed."
        )
      end

      it "correctly forwards processing error message to the instance" do
        @dummy.avatar = @file
        @dummy.valid?
        assert_contains(
          @dummy.errors.full_messages,
          "Avatar cannot be processed."
        )
      end
    end

    context "when error is intended for the developer" do
      before do
        Paperclip::Thumbnail.expects(:make).raises(
          Paperclip::Errors::CommandNotFoundError
        )
      end

      it "propagates the error" do
        assert_raises(Paperclip::Errors::CommandNotFoundError) do
          @dummy.avatar = @file
        end
      end
    end
  end

  context "An attachment with multiple processors" do
    before do
      class Paperclip::Test < Paperclip::Processor; end
      @style_params = { once: {one: 1, two: 2} }
      rebuild_model processors: [:thumbnail, :test], styles: @style_params
      @dummy = Dummy.new
      @file = StringIO.new("...")
      @file.stubs(:close)
      Paperclip::Test.stubs(:make).returns(@file)
      Paperclip::Thumbnail.stubs(:make).returns(@file)
    end

    context "when assigned" do
      it "calls #make on all specified processors" do
        @dummy.avatar = @file

        expect(Paperclip::Thumbnail).to have_received(:make)
        expect(Paperclip::Test).to have_received(:make)
      end

      it "calls #make with the right parameters passed as second argument" do
        expected_params = @style_params[:once].merge({
          style: :once,
          processors: [:thumbnail, :test],
          whiny: true,
          convert_options: "",
          source_file_options: ""
        })

        @dummy.avatar = @file

        expect(Paperclip::Thumbnail).to have_received(:make).with(anything, expected_params, anything)
      end

      it "calls #make with attachment passed as third argument" do
        @dummy.avatar = @file

        expect(Paperclip::Test).to have_received(:make).with(anything, anything, @dummy.avatar)
      end

      it "calls #make and unlinks intermediary files afterward" do
        @dummy.avatar.expects(:unlink_files).with([@file, @file])

        @dummy.avatar = @file
      end
    end
  end

  context "An attachment with a processor that returns original file" do
    before do
      class Paperclip::Test < Paperclip::Processor
        def make; @file; end
      end
      rebuild_model processors: [:test], styles: { once: "100x100" }
      @file = StringIO.new("...")
      @file.stubs(:close)
      @dummy = Dummy.new
    end

    context "when assigned" do
      it "#calls #make and doesn't unlink the original file" do
        @dummy.avatar.expects(:unlink_files).with([])

        @dummy.avatar = @file
      end
    end
  end

  it "includes the filesystem module when loading the filesystem storage" do
    rebuild_model storage: :filesystem
    @dummy = Dummy.new
    assert @dummy.avatar.is_a?(Paperclip::Storage::Filesystem)
  end

  it "includes the filesystem module even if capitalization is wrong" do
    rebuild_model storage: :FileSystem
    @dummy = Dummy.new
    assert @dummy.avatar.is_a?(Paperclip::Storage::Filesystem)

    rebuild_model storage: :Filesystem
    @dummy = Dummy.new
    assert @dummy.avatar.is_a?(Paperclip::Storage::Filesystem)
  end

  it "converts underscored storage name to camelcase" do
    rebuild_model storage: :not_here
    @dummy = Dummy.new
    exception = assert_raises(Paperclip::Errors::StorageMethodNotFound, /NotHere/) do
      @dummy.avatar
    end
  end

  it "raises an error if you try to include a storage module that doesn't exist" do
    rebuild_model storage: :not_here
    @dummy = Dummy.new
    assert_raises(Paperclip::Errors::StorageMethodNotFound) do
      @dummy.avatar
    end
  end

  context "An attachment with styles but no processors defined" do
    before do
      rebuild_model processors: [], styles: {something: '1'}
      @dummy = Dummy.new
      @file = StringIO.new("...")
    end
    it "raises when assigned to" do
      assert_raises(RuntimeError){ @dummy.avatar = @file }
    end
  end

  context "An attachment without styles and with no processors defined" do
    before do
      rebuild_model processors: [], styles: {}
      @dummy = Dummy.new
      @file = StringIO.new("...")
    end
    it "does not raise when assigned to" do
      @dummy.avatar = @file
    end
  end

  context "Assigning an attachment with post_process hooks" do
    before do
      rebuild_class styles: { something: "100x100#" }
      Dummy.class_eval do
        before_avatar_post_process :do_before_avatar
        after_avatar_post_process :do_after_avatar
        before_post_process :do_before_all
        after_post_process :do_after_all
        def do_before_avatar; end
        def do_after_avatar; end
        def do_before_all; end
        def do_after_all; end
      end
      @file  = StringIO.new(".")
      @file.stubs(:to_tempfile).returns(@file)
      @dummy = Dummy.new
      Paperclip::Thumbnail.stubs(:make).returns(@file)
      @attachment = @dummy.avatar
    end

    it "calls the defined callbacks when assigned" do
      @dummy.expects(:do_before_avatar).with()
      @dummy.expects(:do_after_avatar).with()
      @dummy.expects(:do_before_all).with()
      @dummy.expects(:do_after_all).with()
      Paperclip::Thumbnail.expects(:make).returns(@file)
      @dummy.avatar = @file
    end

    it "does not cancel the processing if a before_post_process returns nil" do
      @dummy.expects(:do_before_avatar).with().returns(nil)
      @dummy.expects(:do_after_avatar).with()
      @dummy.expects(:do_before_all).with().returns(nil)
      @dummy.expects(:do_after_all).with()
      Paperclip::Thumbnail.expects(:make).returns(@file)
      @dummy.avatar = @file
    end

    it "cancels the processing if a before_post_process returns false" do
      @dummy.expects(:do_before_avatar).never
      @dummy.expects(:do_after_avatar).never
      @dummy.expects(:do_before_all).with().returns(false)
      @dummy.expects(:do_after_all)
      Paperclip::Thumbnail.expects(:make).never
      @dummy.avatar = @file
    end

    it "cancels the processing if a before_avatar_post_process returns false" do
      @dummy.expects(:do_before_avatar).with().returns(false)
      @dummy.expects(:do_after_avatar)
      @dummy.expects(:do_before_all).with().returns(true)
      @dummy.expects(:do_after_all)
      Paperclip::Thumbnail.expects(:make).never
      @dummy.avatar = @file
    end
  end

  context "Assigning an attachment" do
    before do
      rebuild_model styles: { something: "100x100#" }
      @file = File.new(fixture_file("5k.png"), "rb")
      @dummy = Dummy.new
      @dummy.avatar = @file
    end

    it "strips whitespace from original_filename field" do
      assert_equal "5k.png", @dummy.avatar.original_filename
    end

    it "strips whitespace from content_type field" do
      assert_equal "image/png", @dummy.avatar.instance.avatar_content_type
    end
  end

  context "Assigning an attachment" do
    before do
      rebuild_model styles: { something: "100x100#" }
      @file = File.new(fixture_file("5k.png"), "rb")
      @dummy = Dummy.new
      @dummy.avatar = @file
    end

    it "makes sure the content_type is a string" do
      assert_equal "image/png", @dummy.avatar.instance.avatar_content_type
    end
  end

  context "Attachment with strange letters" do
    before do
      rebuild_model
      @file = File.new(fixture_file("5k.png"), "rb")
      @file.stubs(:original_filename).returns("sheep_say_bæ.png")
      @dummy = Dummy.new
      @dummy.avatar = @file
    end

    it "does not remove strange letters" do
      assert_equal "sheep_say_bæ.png", @dummy.avatar.original_filename
    end
  end

  context "Attachment with reserved filename" do
    before do
      rebuild_model
      @file = Tempfile.new(["filename","png"])
    end

    after do
      @file.unlink
    end

    context "with default configuration" do
      "&$+,/:;=?@<>[]{}|\^~%# ".split(//).each do |character|
        context "with character #{character}" do

          context "at beginning of filename" do
            before do
              @file.stubs(:original_filename).returns("#{character}filename.png")
              @dummy = Dummy.new
              @dummy.avatar = @file
            end

            it "converts special character into underscore" do
              assert_equal "_filename.png", @dummy.avatar.original_filename
            end
          end

          context "at end of filename" do
            before do
              @file.stubs(:original_filename).returns("filename.png#{character}")
              @dummy = Dummy.new
              @dummy.avatar = @file
            end

            it "converts special character into underscore" do
              assert_equal "filename.png_", @dummy.avatar.original_filename
            end
          end

          context "in the middle of filename" do
            before do
              @file.stubs(:original_filename).returns("file#{character}name.png")
              @dummy = Dummy.new
              @dummy.avatar = @file
            end

            it "converts special character into underscore" do
              assert_equal "file_name.png", @dummy.avatar.original_filename
            end
          end

        end
      end
    end

    context "with specified regexp replacement" do
      before do
        @old_defaults = Paperclip::Attachment.default_options.dup
      end

      after do
        Paperclip::Attachment.default_options.merge! @old_defaults
      end

      context 'as another regexp' do
        before do
          Paperclip::Attachment.default_options.merge! restricted_characters: /o/

          @file.stubs(:original_filename).returns("goood.png")
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        it "matches and converts that character" do
          assert_equal "g___d.png", @dummy.avatar.original_filename
        end
      end

      context 'as nil' do
        before do
          Paperclip::Attachment.default_options.merge! restricted_characters: nil

          @file.stubs(:original_filename).returns("goood.png")
          @dummy = Dummy.new
          @dummy.avatar = @file
        end

        it "ignores and returns the original file name" do
          assert_equal "goood.png", @dummy.avatar.original_filename
        end
      end
    end

    context 'with specified cleaner' do
      before do
        @old_defaults = Paperclip::Attachment.default_options.dup
      end

      after do
        Paperclip::Attachment.default_options.merge! @old_defaults
      end

      it 'calls the given proc and take the result as cleaned filename' do
        Paperclip::Attachment.default_options[:filename_cleaner] = lambda do |str|
          "from_proc_#{str}"
        end

        @file.stubs(:original_filename).returns("goood.png")
        @dummy = Dummy.new
        @dummy.avatar = @file
        assert_equal "from_proc_goood.png", @dummy.avatar.original_filename
      end

      it 'calls the given object and take the result as the cleaned filename' do
        class MyCleaner
          def call(filename)
            "foo"
          end
        end
        Paperclip::Attachment.default_options[:filename_cleaner] = MyCleaner.new

        @file.stubs(:original_filename).returns("goood.png")
        @dummy = Dummy.new
        @dummy.avatar = @file
        assert_equal "foo", @dummy.avatar.original_filename
      end
    end
  end

  context "Attachment with uppercase extension and a default style" do
    before do
      @old_defaults = Paperclip::Attachment.default_options.dup
      Paperclip::Attachment.default_options.merge!({
        path: ":rails_root/:attachment/:class/:style/:id/:basename.:extension"
      })
      FileUtils.rm_rf("tmp")
      rebuild_model styles: { large: ["400x400", :jpg],
                             medium: ["100x100", :jpg],
                             small: ["32x32#", :jpg]},
                    default_style: :small
      @instance = Dummy.new
      @instance.stubs(:id).returns 123
      @file = File.new(fixture_file("uppercase.PNG"), 'rb')

      @attachment = @instance.avatar

      now = Time.now
      Time.stubs(:now).returns(now)
      @attachment.assign(@file)
      @attachment.save
    end

    after do
      @file.close
      Paperclip::Attachment.default_options.merge!(@old_defaults)
    end

    it "has matching to_s and url methods" do
      assert_equal @attachment.to_s, @attachment.url
      assert_equal @attachment.to_s(:small), @attachment.url(:small)
    end

    it "has matching expiring_url and url methods when using the filesystem storage" do
      assert_equal @attachment.expiring_url, @attachment.url
    end
  end

  context "An attachment" do
    before do
      @old_defaults = Paperclip::Attachment.default_options.dup
      Paperclip::Attachment.default_options.merge!({
        path: ":rails_root/:attachment/:class/:style/:id/:basename.:extension"
      })
      FileUtils.rm_rf("tmp")
      rebuild_model
      @instance = Dummy.new
      @instance.stubs(:id).returns 123
      # @attachment = Paperclip::Attachment.new(:avatar, @instance)
      @attachment = @instance.avatar
      @file = File.new(fixture_file("5k.png"), 'rb')
    end

    after do
      @file.close
      Paperclip::Attachment.default_options.merge!(@old_defaults)
    end

    it "raises if there are not the correct columns when you try to assign" do
      @other_attachment = Paperclip::Attachment.new(:not_here, @instance)
      assert_raises(Paperclip::Error) do
        @other_attachment.assign(@file)
      end
    end

    it 'clears out the previous assignment when assigned nil' do
      @attachment.assign(@file)
      @attachment.queued_for_write[:original]
      @attachment.assign(nil)
      assert_nil @attachment.queued_for_write[:original]
    end

    it 'does not do anything when it is assigned an empty string' do
      @attachment.assign(@file)
      original_file = @attachment.queued_for_write[:original]
      @attachment.assign("")
      assert_equal original_file, @attachment.queued_for_write[:original]
    end

    it "returns nil as path when no file assigned" do
      assert_equal nil, @attachment.path
      assert_equal nil, @attachment.path(:blah)
    end

    context "with a file assigned but not saved yet" do
      it "clears out any attached files" do
        @attachment.assign(@file)
        assert @attachment.queued_for_write.present?
        @attachment.clear
        assert @attachment.queued_for_write.blank?
      end
    end

    context "with a file assigned in the database" do
      before do
        @attachment.stubs(:instance_read).with(:file_name).returns("5k.png")
        @attachment.stubs(:instance_read).with(:content_type).returns("image/png")
        @attachment.stubs(:instance_read).with(:file_size).returns(12345)
        dtnow = DateTime.now
        @now = Time.now
        Time.stubs(:now).returns(@now)
        @attachment.stubs(:instance_read).with(:updated_at).returns(dtnow)
      end

      it "returns the proper path when filename has a single .'s" do
        assert_equal File.expand_path("tmp/avatars/dummies/original/#{@instance.id}/5k.png"), File.expand_path(@attachment.path)
      end

      it "returns the proper path when filename has multiple .'s" do
        @attachment.stubs(:instance_read).with(:file_name).returns("5k.old.png")
        assert_equal File.expand_path("tmp/avatars/dummies/original/#{@instance.id}/5k.old.png"), File.expand_path(@attachment.path)
      end

      context "when expecting three styles" do
        before do
          rebuild_class styles: {
            large: ["400x400", :png],
            medium: ["100x100", :gif],
            small: ["32x32#", :jpg]
          }
          @instance = Dummy.new
          @instance.stubs(:id).returns 123
          @file = File.new(fixture_file("5k.png"), 'rb')
          @attachment = @instance.avatar
        end

        context "and assigned a file" do
          before do
            now = Time.now
            Time.stubs(:now).returns(now)
            @attachment.assign(@file)
          end

          it "is dirty" do
            assert @attachment.dirty?
          end

          context "and saved" do
            before do
              @attachment.save
            end

            it "commits the files to disk" do
              [:large, :medium, :small].each do |style|
                expect(@attachment.path(style)).to exist
              end
            end

            it "saves the files as the right formats and sizes" do
              [[:large, 400, 61, "PNG"],
               [:medium, 100, 15, "GIF"],
               [:small, 32, 32, "JPEG"]].each do |style|
                cmd = %Q[identify -format "%w %h %b %m" "#{@attachment.path(style.first)}"]
                out = `#{cmd}`
                width, height, _size, format = out.split(" ")
                assert_equal style[1].to_s, width.to_s
                assert_equal style[2].to_s, height.to_s
                assert_equal style[3].to_s, format.to_s
              end
            end

            context "and trying to delete" do
              before do
                @existing_names = @attachment.styles.keys.collect do |style|
                  @attachment.path(style)
                end
              end

              it "deletes the files after assigning nil" do
                @attachment.expects(:instance_write).with(:file_name, nil)
                @attachment.expects(:instance_write).with(:content_type, nil)
                @attachment.expects(:instance_write).with(:file_size, nil)
                @attachment.expects(:instance_write).with(:fingerprint, nil)
                @attachment.expects(:instance_write).with(:updated_at, nil)
                @attachment.assign nil
                @attachment.save
                @existing_names.each{|f| assert_file_not_exists(f) }
              end

              it "deletes the files when you call #clear and #save" do
                @attachment.expects(:instance_write).with(:file_name, nil)
                @attachment.expects(:instance_write).with(:content_type, nil)
                @attachment.expects(:instance_write).with(:file_size, nil)
                @attachment.expects(:instance_write).with(:fingerprint, nil)
                @attachment.expects(:instance_write).with(:updated_at, nil)
                @attachment.clear
                @attachment.save
                @existing_names.each{|f| assert_file_not_exists(f) }
              end

              it "deletes the files when you call #delete" do
                @attachment.expects(:instance_write).with(:file_name, nil)
                @attachment.expects(:instance_write).with(:content_type, nil)
                @attachment.expects(:instance_write).with(:file_size, nil)
                @attachment.expects(:instance_write).with(:fingerprint, nil)
                @attachment.expects(:instance_write).with(:updated_at, nil)
                @attachment.destroy
                @existing_names.each{|f| assert_file_not_exists(f) }
              end

              context "when keeping old files" do
                before do
                  @attachment.options[:keep_old_files] = true
                end

                it "keeps the files after assigning nil" do
                  @attachment.expects(:instance_write).with(:file_name, nil)
                  @attachment.expects(:instance_write).with(:content_type, nil)
                  @attachment.expects(:instance_write).with(:file_size, nil)
                  @attachment.expects(:instance_write).with(:fingerprint, nil)
                  @attachment.expects(:instance_write).with(:updated_at, nil)
                  @attachment.assign nil
                  @attachment.save
                  @existing_names.each{|f| assert_file_exists(f) }
                end

                it "keeps the files when you call #clear and #save" do
                  @attachment.expects(:instance_write).with(:file_name, nil)
                  @attachment.expects(:instance_write).with(:content_type, nil)
                  @attachment.expects(:instance_write).with(:file_size, nil)
                  @attachment.expects(:instance_write).with(:fingerprint, nil)
                  @attachment.expects(:instance_write).with(:updated_at, nil)
                  @attachment.clear
                  @attachment.save
                  @existing_names.each{|f| assert_file_exists(f) }
                end

                it "keeps the files when you call #delete" do
                  @attachment.expects(:instance_write).with(:file_name, nil)
                  @attachment.expects(:instance_write).with(:content_type, nil)
                  @attachment.expects(:instance_write).with(:file_size, nil)
                  @attachment.expects(:instance_write).with(:fingerprint, nil)
                  @attachment.expects(:instance_write).with(:updated_at, nil)
                  @attachment.destroy
                  @existing_names.each{|f| assert_file_exists(f) }
                end
              end
            end
          end
        end
      end
    end

    context "when trying a nonexistant storage type" do
      before do
        rebuild_model storage: :not_here
      end

      it "is not able to find the module" do
        assert_raises(Paperclip::Errors::StorageMethodNotFound){ Dummy.new.avatar }
      end
    end
  end

  context "An attachment with only a avatar_file_name column" do
    before do
      ActiveRecord::Base.connection.create_table :dummies, force: true do |table|
        table.column :avatar_file_name, :string
      end
      rebuild_class
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
    end

    after { @file.close }

    it "does not error when assigned an attachment" do
      assert_nothing_raised { @dummy.avatar = @file }
    end

    it "does not return the time when sent #avatar_updated_at" do
      @dummy.avatar = @file
      assert_nil @dummy.avatar.updated_at
    end

    it "returns the right value when sent #avatar_file_size" do
      @dummy.avatar = @file
      assert_equal File.size(@file), @dummy.avatar.size
    end

    context "and avatar_created_at column" do
      before do
        ActiveRecord::Base.connection.add_column :dummies, :avatar_created_at, :timestamp
        rebuild_class
        @dummy = Dummy.new
      end

      it "does not error when assigned an attachment" do
        assert_nothing_raised { @dummy.avatar = @file }
      end

      it "returns the creation time when sent #avatar_created_at" do
        now = Time.now
        Time.stubs(:now).returns(now)
        @dummy.avatar = @file
        assert_equal now.to_i, @dummy.avatar.created_at
      end

      it "returns the creation time when sent #avatar_created_at and the entry has been updated" do
        creation = 2.hours.ago
        now = Time.now
        Time.stubs(:now).returns(creation)
        @dummy.avatar = @file
        Time.stubs(:now).returns(now)
        @dummy.avatar = @file
        assert_equal creation.to_i, @dummy.avatar.created_at
        assert_not_equal now.to_i, @dummy.avatar.created_at
      end

      it "sets changed? to true on attachment assignment" do
        @dummy.avatar = @file
        @dummy.save!
        @dummy.avatar = @file
        assert @dummy.changed?
      end
    end

    context "and avatar_updated_at column" do
      before do
        ActiveRecord::Base.connection.add_column :dummies, :avatar_updated_at, :timestamp
        rebuild_class
        @dummy = Dummy.new
      end

      it "does not error when assigned an attachment" do
        assert_nothing_raised { @dummy.avatar = @file }
      end

      it "returns the right value when sent #avatar_updated_at" do
        now = Time.now
        Time.stubs(:now).returns(now)
        @dummy.avatar = @file
        assert_equal now.to_i, @dummy.avatar.updated_at
      end
    end

    it "does not calculate fingerprint" do
      Digest::MD5.stubs(:file)
      @dummy.avatar = @file
      expect(Digest::MD5).to have_received(:file).never
    end

    it "does not assign fingerprint" do
      @dummy.avatar = @file
      assert_nil @dummy.avatar.fingerprint
    end

    context "and avatar_content_type column" do
      before do
        ActiveRecord::Base.connection.add_column :dummies, :avatar_content_type, :string
        rebuild_class
        @dummy = Dummy.new
      end

      it "does not error when assigned an attachment" do
        assert_nothing_raised { @dummy.avatar = @file }
      end

      it "returns the right value when sent #avatar_content_type" do
        @dummy.avatar = @file
        assert_equal "image/png", @dummy.avatar.content_type
      end
    end

    context "and avatar_file_size column" do
      before do
        ActiveRecord::Base.connection.add_column :dummies, :avatar_file_size, :integer
        rebuild_class
        @dummy = Dummy.new
      end

      it "does not error when assigned an attachment" do
        assert_nothing_raised { @dummy.avatar = @file }
      end

      it "returns the right value when sent #avatar_file_size" do
        @dummy.avatar = @file
        assert_equal File.size(@file), @dummy.avatar.size
      end

      it "returns the right value when saved, reloaded, and sent #avatar_file_size" do
        @dummy.avatar = @file
        @dummy.save
        @dummy = Dummy.find(@dummy.id)
        assert_equal File.size(@file), @dummy.avatar.size
      end
    end

    context "and avatar_fingerprint column" do
      before do
        ActiveRecord::Base.connection.add_column :dummies, :avatar_fingerprint, :string
        rebuild_class
        @dummy = Dummy.new
      end

      it "does not error when assigned an attachment" do
        assert_nothing_raised { @dummy.avatar = @file }
      end

      context "with explicitly set digest" do
        before do
          rebuild_class adapter_options: { hash_digest: Digest::SHA256 }
          @dummy = Dummy.new
        end

        it "returns the right value when sent #avatar_fingerprint" do
          @dummy.avatar = @file
          assert_equal "734016d801a497f5579cdd4ef2ae1d020088c1db754dc434482d76dd5486520a",
                       @dummy.avatar_fingerprint
        end

        it "returns the right value when saved, reloaded, and sent #avatar_fingerprint" do
          @dummy.avatar = @file
          @dummy.save
          @dummy = Dummy.find(@dummy.id)
          assert_equal "734016d801a497f5579cdd4ef2ae1d020088c1db754dc434482d76dd5486520a",
                       @dummy.avatar_fingerprint
        end
      end

      context "with the default digest" do
        before do
          rebuild_class # MD5 is the default
          @dummy = Dummy.new
        end

        it "returns the right value when sent #avatar_fingerprint" do
          @dummy.avatar = @file
          assert_equal "aec488126c3b33c08a10c3fa303acf27",
                       @dummy.avatar_fingerprint
        end

        it "returns the right value when saved, reloaded, and sent #avatar_fingerprint" do
          @dummy.avatar = @file
          @dummy.save
          @dummy = Dummy.find(@dummy.id)
          assert_equal "aec488126c3b33c08a10c3fa303acf27",
                       @dummy.avatar_fingerprint
        end
      end
    end
  end

  context "an attachment with delete_file option set to false" do
    before do
      rebuild_model preserve_files: true
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
      @dummy.save!
      @attachment = @dummy.avatar
      @path = @attachment.path
    end

    after { @file.close }

    it "does not delete the files from storage when attachment is destroyed" do
      @attachment.destroy
      assert_file_exists(@path)
    end

    it "clears out attachment data when attachment is destroyed" do
      @attachment.destroy
      assert !@attachment.exists?
      assert_nil @dummy.avatar_file_name
    end

    it "does not delete the file when model is destroyed" do
      @dummy.destroy
      assert_file_exists(@path)
    end
  end

  context "An attached file" do
    before do
      rebuild_model
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
      @dummy.save!
      @attachment = @dummy.avatar
      @path = @attachment.path
    end

    after { @file.close }

    it "is not deleted when the model fails to destroy" do
      @dummy.stubs(:destroy).raises(Exception)

      assert_raises Exception do
        @dummy.destroy
      end

      assert_file_exists(@path)
    end

    it "is deleted when the model is destroyed" do
      @dummy.destroy
      assert_file_not_exists(@path)
    end

    it "is not deleted when transaction rollbacks after model is destroyed" do
      ActiveRecord::Base.transaction do
        @dummy.destroy
        raise ActiveRecord::Rollback
      end

      assert_file_exists(@path)
    end
  end
end
