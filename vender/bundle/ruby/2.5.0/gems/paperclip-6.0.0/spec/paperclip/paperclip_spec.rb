require 'spec_helper'

describe Paperclip do
  context ".run" do
    before do
      Paperclip.options[:log_command] = false
      Terrapin::CommandLine.expects(:new).with("convert", "stuff", {}).returns(stub(:run))
      @original_command_line_path = Terrapin::CommandLine.path
    end

    after do
      Paperclip.options[:log_command] = true
      Terrapin::CommandLine.path = @original_command_line_path
    end

    it "runs the command with Terrapin" do
      Paperclip.run("convert", "stuff")
    end

    it "saves Terrapin::CommandLine.path that set before" do
      Terrapin::CommandLine.path = "/opt/my_app/bin"
      Paperclip.run("convert", "stuff")
      expect(Terrapin::CommandLine.path).to match("/opt/my_app/bin")
    end

    it "does not duplicate Terrapin::CommandLine.path on multiple runs" do
      Terrapin::CommandLine.expects(:new).with("convert", "more_stuff", {}).returns(stub(:run))
      Terrapin::CommandLine.path = nil
      Paperclip.options[:command_path] = "/opt/my_app/bin"
      Paperclip.run("convert", "stuff")
      Paperclip.run("convert", "more_stuff")

      cmd_path = Paperclip.options[:command_path]
      assert_equal 1, Terrapin::CommandLine.path.scan(cmd_path).count
    end
  end

  it 'does not raise errors when doing a lot of running' do
    Paperclip.options[:command_path] = ["/usr/local/bin"] * 1024
    Terrapin::CommandLine.path = "/something/else"
    100.times do |x|
      Paperclip.run("echo", x.to_s)
    end
  end

  context "Calling Paperclip.log without options[:logger] set" do
    before do
      Paperclip.logger = nil
      Paperclip.options[:logger] = nil
    end

    after do
      Paperclip.options[:logger] = ActiveRecord::Base.logger
      Paperclip.logger = ActiveRecord::Base.logger
    end

    it "does not raise an error when log is called" do
      silence_stream(STDOUT) do
        Paperclip.log('something')
      end
    end
  end
  context "Calling Paperclip.run with a logger" do
    it "passes the defined logger if :log_command is set" do
      Paperclip.options[:log_command] = true
      Terrapin::CommandLine.expects(:new).with("convert", "stuff", logger: Paperclip.logger).returns(stub(:run))
      Paperclip.run("convert", "stuff")
    end
  end

  context "Paperclip.each_instance_with_attachment" do
    before do
      @file = File.new(fixture_file("5k.png"), 'rb')
      d1 = Dummy.create(avatar: @file)
      d2 = Dummy.create
      d3 = Dummy.create(avatar: @file)
      @expected = [d1, d3]
    end

    after { @file.close }

    it "yields every instance of a model that has an attachment" do
      actual = []
      Paperclip.each_instance_with_attachment("Dummy", "avatar") do |instance|
        actual << instance
      end
      expect(actual).to match_array @expected
    end
  end

  it "raises when sent #processor and the name of a class that doesn't exist" do
    assert_raises(LoadError){ Paperclip.processor(:boogey_man) }
  end

  it "returns a class when sent #processor and the name of a class under Paperclip" do
    assert_equal ::Paperclip::Thumbnail, Paperclip.processor(:thumbnail)
  end

  it "gets a class from a namespaced class name" do
    class ::One; class Two; end; end
    assert_equal ::One::Two, Paperclip.class_for("One::Two")
  end

  it "raises when class doesn't exist in specified namespace" do
    class ::Three; end
    class ::Four; end
    assert_raises NameError do
      Paperclip.class_for("Three::Four")
    end
  end

  context "An ActiveRecord model with an 'avatar' attachment" do
    before do
      rebuild_model path: "tmp/:class/omg/:style.:extension"
      @file = File.new(fixture_file("5k.png"), 'rb')
    end

    after { @file.close }

    it "does not error when trying to also create a 'blah' attachment" do
      assert_nothing_raised do
        Dummy.class_eval do
          has_attached_file :blah
        end
      end
    end

    context "with a subclass" do
      before do
        class ::SubDummy < Dummy; end
      end

      it "is able to use the attachment from the subclass" do
        assert_nothing_raised do
          @subdummy = SubDummy.create(avatar: @file)
        end
      end

      after do
        SubDummy.delete_all
        Object.send(:remove_const, "SubDummy") rescue nil
      end
    end

    it "has an avatar getter method" do
      assert Dummy.new.respond_to?(:avatar)
    end

    it "has an avatar setter method" do
      assert Dummy.new.respond_to?(:avatar=)
    end

    context "that is valid" do
      before do
        @dummy = Dummy.new
        @dummy.avatar = @file
      end

      it "is valid" do
        assert @dummy.valid?
      end
    end

    it "does not have Attachment in the ActiveRecord::Base namespace" do
      assert_raises(NameError) do
        ActiveRecord::Base::Attachment
      end
    end
  end

  context "configuring a custom processor" do
    before do
      @freedom_processor = Class.new do
        def make(file, options = {}, attachment = nil)
          file
        end
      end.new

      Paperclip.configure do |config|
        config.register_processor(:freedom, @freedom_processor)
      end
    end

    it "is able to find the custom processor" do
      assert_equal @freedom_processor, Paperclip.processor(:freedom)
    end

    after do
      Paperclip.clear_processors!
    end
  end
end
