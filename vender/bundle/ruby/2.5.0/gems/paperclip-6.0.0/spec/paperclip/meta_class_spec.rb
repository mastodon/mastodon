require 'spec_helper'

describe 'Metaclasses' do
  context "A meta-class of dummy" do
    if active_support_version >= "4.1" || ruby_version < "2.1"
      before do
        rebuild_model
        reset_class("Dummy")
      end

      it "is able to use Paperclip like a normal class" do
        @dummy = Dummy.new

        assert_nothing_raised do
          rebuild_meta_class_of(@dummy)
        end
      end

      it "works like any other instance" do
        @dummy = Dummy.new
        rebuild_meta_class_of(@dummy)

        assert_nothing_raised do
          @dummy.avatar = File.new(fixture_file("5k.png"), 'rb')
        end
        assert @dummy.save
      end
    end
  end
end
