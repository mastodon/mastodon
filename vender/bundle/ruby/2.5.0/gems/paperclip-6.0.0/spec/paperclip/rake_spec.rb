require 'spec_helper'
require 'rake'
load './lib/tasks/paperclip.rake'

describe Rake do
  context "calling `rake paperclip:refresh:thumbnails`" do
    before do
      rebuild_model
      Paperclip::Task.stubs(:obtain_class).returns('Dummy')
      @bogus_instance = Dummy.new
      @bogus_instance.id = 'some_id'
      @bogus_instance.avatar.stubs(:reprocess!)
      @valid_instance = Dummy.new
      @valid_instance.avatar.stubs(:reprocess!)
      Paperclip::Task.stubs(:log_error)
      Paperclip.stubs(:each_instance_with_attachment).multiple_yields @bogus_instance, @valid_instance
    end
    context "when there is an exception in reprocess!" do
      before do
        @bogus_instance.avatar.stubs(:reprocess!).raises
      end

      it "catches the exception" do
        assert_nothing_raised do
          ::Rake::Task['paperclip:refresh:thumbnails'].execute
        end
      end

      it "continues to the next instance" do
        @valid_instance.avatar.expects(:reprocess!)
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the exception" do
        exception_msg = 'Some Exception'
        @bogus_instance.avatar.stubs(:reprocess!).raises(exception_msg)
        Paperclip::Task.expects(:log_error).with do |str|
          str.match exception_msg
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the class name" do
        Paperclip::Task.expects(:log_error).with do |str|
          str.match 'Dummy'
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the instance ID" do
        Paperclip::Task.expects(:log_error).with do |str|
          str.match "ID #{@bogus_instance.id}"
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end
    end

    context "when there is an error in reprocess!" do
      before do
        @errors = mock('errors')
        @errors.stubs(:full_messages).returns([''])
        @errors.stubs(:blank?).returns(false)
        @bogus_instance.stubs(:errors).returns(@errors)
      end

      it "continues to the next instance" do
        @valid_instance.avatar.expects(:reprocess!)
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the error" do
        error_msg = 'Some Error'
        @errors.stubs(:full_messages).returns([error_msg])
        Paperclip::Task.expects(:log_error).with do |str|
          str.match error_msg
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the class name" do
        Paperclip::Task.expects(:log_error).with do |str|
          str.match 'Dummy'
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end

      it "prints the instance ID" do
        Paperclip::Task.expects(:log_error).with do |str|
          str.match "ID #{@bogus_instance.id}"
        end
        ::Rake::Task['paperclip:refresh:thumbnails'].execute
      end
    end
  end

  context "Paperclip::Task.log_error method" do
    it "prints its argument to STDERR" do
      msg = 'Some Message'
      $stderr.expects(:puts).with(msg)
      Paperclip::Task.log_error(msg)
    end
  end
end
