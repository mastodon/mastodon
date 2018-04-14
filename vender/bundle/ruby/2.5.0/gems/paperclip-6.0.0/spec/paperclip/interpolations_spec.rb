require 'spec_helper'

describe Paperclip::Interpolations do
  it "returns all methods but the infrastructure when sent #all" do
    methods = Paperclip::Interpolations.all
    assert ! methods.include?(:[])
    assert ! methods.include?(:[]=)
    assert ! methods.include?(:all)
    methods.each do |m|
      assert Paperclip::Interpolations.respond_to?(m)
    end
  end

  it "returns the Rails.root" do
    assert_equal Rails.root, Paperclip::Interpolations.rails_root(:attachment, :style)
  end

  it "returns the Rails.env" do
    assert_equal Rails.env, Paperclip::Interpolations.rails_env(:attachment, :style)
  end

  it "returns the class of the Interpolations module when called with no params" do
    assert_equal Module, Paperclip::Interpolations.class
  end

  it "returns the class of the instance" do
    class Thing ; end
    attachment = mock
    attachment.expects(:instance).returns(attachment)
    attachment.expects(:class).returns(Thing)
    assert_equal "things", Paperclip::Interpolations.class(attachment, :style)
  end

  it "returns the basename of the file" do
    attachment = mock
    attachment.expects(:original_filename).returns("one.jpg").times(1)
    assert_equal "one", Paperclip::Interpolations.basename(attachment, :style)
  end

  it "returns the extension of the file" do
    attachment = mock
    attachment.expects(:original_filename).returns("one.jpg")
    attachment.expects(:styles).returns({})
    assert_equal "jpg", Paperclip::Interpolations.extension(attachment, :style)
  end

  it "returns the extension of the file as the format if defined in the style" do
    attachment = mock
    attachment.expects(:original_filename).never
    attachment.expects(:styles).twice.returns({style: {format: "png"}})

    [:style, 'style'].each do |style|
      assert_equal "png", Paperclip::Interpolations.extension(attachment, style)
    end
  end

  it "returns the extension of the file based on the content type" do
    attachment = mock
    attachment.expects(:content_type).returns('image/png')
    attachment.expects(:styles).returns({})
    interpolations = Paperclip::Interpolations
    interpolations.expects(:extension).returns('random')
    assert_equal "png", interpolations.content_type_extension(attachment, :style)
  end

  it "returns the original extension of the file if it matches a content type extension" do
    attachment = mock
    attachment.expects(:content_type).returns('image/jpeg')
    attachment.expects(:styles).returns({})
    interpolations = Paperclip::Interpolations
    interpolations.expects(:extension).returns('jpe')
    assert_equal "jpe", interpolations.content_type_extension(attachment, :style)
  end

  it "returns the extension of the file with a dot" do
    attachment = mock
    attachment.expects(:original_filename).returns("one.jpg")
    attachment.expects(:styles).returns({})
    assert_equal ".jpg", Paperclip::Interpolations.dotextension(attachment, :style)
  end

  it "returns the extension of the file without a dot if the extension is empty" do
    attachment = mock
    attachment.expects(:original_filename).returns("one")
    attachment.expects(:styles).returns({})
    assert_equal "", Paperclip::Interpolations.dotextension(attachment, :style)
  end

  it "returns the latter half of the content type of the extension if no match found" do
    attachment = mock
    attachment.expects(:content_type).at_least_once().returns('not/found')
    attachment.expects(:styles).returns({})
    interpolations = Paperclip::Interpolations
    interpolations.expects(:extension).returns('random')
    assert_equal "found", interpolations.content_type_extension(attachment, :style)
  end

  it "returns the format if defined in the style, ignoring the content type" do
    attachment = mock
    attachment.expects(:content_type).returns('image/jpeg')
    attachment.expects(:styles).returns({style: {format: "png"}})
    interpolations = Paperclip::Interpolations
    interpolations.expects(:extension).returns('random')
    assert_equal "png", interpolations.content_type_extension(attachment, :style)
  end

  it "is able to handle numeric style names" do
    attachment = mock(
      styles: {:"4" => {format: :expected_extension}}
    )
    assert_equal :expected_extension, Paperclip::Interpolations.extension(attachment, 4)
  end

  it "returns the #to_param of the attachment" do
    attachment = mock
    attachment.expects(:to_param).returns("23-awesome")
    attachment.expects(:instance).returns(attachment)
    assert_equal "23-awesome", Paperclip::Interpolations.param(attachment, :style)
  end

  it "returns the id of the attachment" do
    attachment = mock
    attachment.expects(:id).returns(23)
    attachment.expects(:instance).returns(attachment)
    assert_equal 23, Paperclip::Interpolations.id(attachment, :style)
  end

  it "returns nil for attachments to new records" do
    attachment = mock
    attachment.expects(:id).returns(nil)
    attachment.expects(:instance).returns(attachment)
    assert_nil Paperclip::Interpolations.id(attachment, :style)
  end

  it "returns the partitioned id of the attachment when the id is an integer" do
    attachment = mock
    attachment.expects(:id).returns(23)
    attachment.expects(:instance).returns(attachment)
    assert_equal "000/000/023", Paperclip::Interpolations.id_partition(attachment, :style)
  end

  it "returns the partitioned id of the attachment when the id is a string" do
    attachment = mock
    attachment.expects(:id).returns("32fnj23oio2f")
    attachment.expects(:instance).returns(attachment)
    assert_equal "32f/nj2/3oi", Paperclip::Interpolations.id_partition(attachment, :style)
  end

  it "returns nil for the partitioned id of an attachment to a new record (when the id is nil)" do
    attachment = mock
    attachment.expects(:id).returns(nil)
    attachment.expects(:instance).returns(attachment)
    assert_nil Paperclip::Interpolations.id_partition(attachment, :style)
  end

  it "returns the name of the attachment" do
    attachment = mock
    attachment.expects(:name).returns("file")
    assert_equal "files", Paperclip::Interpolations.attachment(attachment, :style)
  end

  it "returns the style" do
    assert_equal :style, Paperclip::Interpolations.style(:attachment, :style)
  end

  it "returns the default style" do
    attachment = mock
    attachment.expects(:default_style).returns(:default_style)
    assert_equal :default_style, Paperclip::Interpolations.style(attachment, nil)
  end

  it "reinterpolates :url" do
    attachment = mock
    attachment.expects(:url).with(:style, timestamp: false, escape: false).returns("1234")
    assert_equal "1234", Paperclip::Interpolations.url(attachment, :style)
  end

  it "raises if infinite loop detcted reinterpolating :url" do
    attachment = Object.new
    class << attachment
      def url(*args)
        Paperclip::Interpolations.url(self, :style)
      end
    end
    assert_raises(Paperclip::Errors::InfiniteInterpolationError){ Paperclip::Interpolations.url(attachment, :style) }
  end

  it "returns the filename as basename.extension" do
    attachment = mock
    attachment.expects(:styles).returns({})
    attachment.expects(:original_filename).returns("one.jpg").times(2)
    assert_equal "one.jpg", Paperclip::Interpolations.filename(attachment, :style)
  end

  it "returns the filename as basename.extension when format supplied" do
    attachment = mock
    attachment.expects(:styles).returns({style: {format: :png}})
    attachment.expects(:original_filename).returns("one.jpg").times(1)
    assert_equal "one.png", Paperclip::Interpolations.filename(attachment, :style)
  end

  it "returns the filename as basename when extension is blank" do
    attachment = mock
    attachment.stubs(:styles).returns({})
    attachment.stubs(:original_filename).returns("one")
    assert_equal "one", Paperclip::Interpolations.filename(attachment, :style)
  end
  
  it "returns the basename when the extension contains regexp special characters" do
    attachment = mock
    attachment.stubs(:styles).returns({})
    attachment.stubs(:original_filename).returns("one.ab)")
    assert_equal "one", Paperclip::Interpolations.basename(attachment, :style)
  end

  it "returns the timestamp" do
    now = Time.now
    zone = 'UTC'
    attachment = mock
    attachment.expects(:instance_read).with(:updated_at).returns(now)
    attachment.expects(:time_zone).returns(zone)
    assert_equal now.in_time_zone(zone).to_s, Paperclip::Interpolations.timestamp(attachment, :style)
  end

  it "returns updated_at" do
    attachment = mock
    seconds_since_epoch = 1234567890
    attachment.expects(:updated_at).returns(seconds_since_epoch)
    assert_equal seconds_since_epoch, Paperclip::Interpolations.updated_at(attachment, :style)
  end

  it "returns attachment's hash when passing both arguments" do
    attachment = mock
    fake_hash = "a_wicked_secure_hash"
    attachment.expects(:hash_key).returns(fake_hash)
    assert_equal fake_hash, Paperclip::Interpolations.hash(attachment, :style)
  end

  it "returns Object#hash when passing no argument" do
    attachment = mock
    fake_hash = "a_wicked_secure_hash"
    attachment.expects(:hash_key).never.returns(fake_hash)
    assert_not_equal fake_hash, Paperclip::Interpolations.hash
  end

  it "calls all expected interpolations with the given arguments" do
    Paperclip::Interpolations.expects(:id).with(:attachment, :style).returns(1234)
    Paperclip::Interpolations.expects(:attachment).with(:attachment, :style).returns("attachments")
    Paperclip::Interpolations.expects(:notreal).never
    value = Paperclip::Interpolations.interpolate(":notreal/:id/:attachment", :attachment, :style)
    assert_equal ":notreal/1234/attachments", value
  end

  it "handles question marks" do
    Paperclip.interpolates :foo? do
      "bar"
    end
    Paperclip::Interpolations.expects(:fool).never
    value = Paperclip::Interpolations.interpolate(":fo/:foo?")
    assert_equal ":fo/bar", value
  end
end
