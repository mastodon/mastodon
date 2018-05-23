require 'spec_helper'

describe Paperclip::Storage::Filesystem do
  context "Filesystem" do
    context "normal file" do
      before do
        rebuild_model styles: { thumbnail: "25x25#" }
        @dummy = Dummy.create!

        @file = File.open(fixture_file('5k.png'))
        @dummy.avatar = @file
      end

      after { @file.close }

      it "allows file assignment" do
        assert @dummy.save
      end

      it "stores the original" do
        @dummy.save
        assert_file_exists(@dummy.avatar.path)
      end

      it "stores the thumbnail" do
        @dummy.save
        assert_file_exists(@dummy.avatar.path(:thumbnail))
      end

      it "is rewinded after flush_writes" do
        @dummy.avatar.instance_eval "def after_flush_writes; end"

        files = @dummy.avatar.queued_for_write.values
        @dummy.save
        assert files.none?(&:eof?), "Expect all the files to be rewinded."
      end

      it "is removed after after_flush_writes" do
        paths = @dummy.avatar.queued_for_write.values.map(&:path)
        @dummy.save
        assert paths.none?{ |path| File.exist?(path) },
          "Expect all the files to be deleted."
      end

      it 'copies the file to a known location with copy_to_local_file' do
        tempfile = Tempfile.new("known_location")
        @dummy.avatar.copy_to_local_file(:original, tempfile.path)
        tempfile.rewind
        assert_equal @file.read, tempfile.read
        tempfile.close
      end
    end

    context "with file that has space in file name" do
      before do
        rebuild_model styles: { thumbnail: "25x25#" }
        @dummy = Dummy.create!

        @file = File.open(fixture_file('spaced file.png'))
        @dummy.avatar = @file
        @dummy.save
      end

      after { @file.close }

      it "stores the file" do
        assert_file_exists(@dummy.avatar.path)
      end

      it "returns a replaced version for path" do
        assert_match /.+\/spaced_file\.png/, @dummy.avatar.path
      end

      it "returns a replaced version for url" do
        assert_match /.+\/spaced_file\.png/, @dummy.avatar.url
      end
    end
  end
end
