# encoding: utf-8
require 'spec_helper'
require 'open-uri'

describe 'Paperclip' do
  context "Many models at once" do
    before do
      rebuild_model
      @file = File.new(fixture_file("5k.png"), 'rb')
      # Deals with `Too many open files` error
      Dummy.import 100.times.map { Dummy.new avatar: @file }
      Dummy.import 100.times.map { Dummy.new avatar: @file }
      Dummy.import 100.times.map { Dummy.new avatar: @file }
    end

    after { @file.close }

    it "does not exceed the open file limit" do
       assert_nothing_raised do
         Dummy.all.each { |dummy| dummy.avatar }
       end
    end
  end

  context "An attachment" do
    before do
      rebuild_model styles: { thumb: "50x50#" }
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
      assert @dummy.save
    end

    after { @file.close }

    it "creates its thumbnails properly" do
      assert_match(/\b50x50\b/, `identify "#{@dummy.avatar.path(:thumb)}"`)
    end

    context 'reprocessing with unreadable original' do
      before { File.chmod(0000, @dummy.avatar.path) }

      it "does not raise an error" do
        assert_nothing_raised do
          silence_stream(STDERR) do
            @dummy.avatar.reprocess!
          end
        end
      end

      it "returns false" do
        silence_stream(STDERR) do
          assert !@dummy.avatar.reprocess!
        end
      end

      after { File.chmod(0644, @dummy.avatar.path) }
    end

    context "redefining its attachment styles" do
      before do
        Dummy.class_eval do
          has_attached_file :avatar, styles: { thumb: "150x25#", dynamic: lambda { |a| '50x50#' } }
        end
        @d2 = Dummy.find(@dummy.id)
        @original_timestamp = @d2.avatar_updated_at
        @d2.avatar.reprocess!
        @d2.save
      end

      it "creates its thumbnails properly" do
        assert_match(/\b150x25\b/, `identify "#{@dummy.avatar.path(:thumb)}"`)
        assert_match(/\b50x50\b/, `identify "#{@dummy.avatar.path(:dynamic)}"`)
      end

      it "changes the timestamp" do
        assert_not_equal @original_timestamp, @d2.avatar_updated_at
      end
    end
  end

  context "Attachment" do
    before do
      @thumb_path = "tmp/public/system/dummies/avatars/000/000/001/thumb/5k.png"
      File.delete(@thumb_path) if File.exist?(@thumb_path)
      rebuild_model styles: { thumb: "50x50#" }
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')

    end

    after { @file.close }

    it "does not create the thumbnails upon saving when post-processing is disabled" do
      @dummy.avatar.post_processing = false
      @dummy.avatar = @file
      assert @dummy.save
      assert_file_not_exists @thumb_path
    end

    it "creates the thumbnails upon saving when post_processing is enabled" do
      @dummy.avatar.post_processing = true
      @dummy.avatar = @file
      assert @dummy.save
      assert_file_exists @thumb_path
    end
  end

  context "Attachment with no generated thumbnails" do
    before do
      @thumb_small_path = "tmp/public/system/dummies/avatars/000/000/001/thumb_small/5k.png"
      @thumb_large_path = "tmp/public/system/dummies/avatars/000/000/001/thumb_large/5k.png"
      File.delete(@thumb_small_path) if File.exist?(@thumb_small_path)
      File.delete(@thumb_large_path) if File.exist?(@thumb_large_path)
      rebuild_model styles: { thumb_small: "50x50#", thumb_large: "60x60#" }
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')

      @dummy.avatar.post_processing = false
      @dummy.avatar = @file
      assert @dummy.save
      @dummy.avatar.post_processing = true
    end

    after { @file.close }

    it "allows us to create all thumbnails in one go" do
      assert_file_not_exists(@thumb_small_path)
      assert_file_not_exists(@thumb_large_path)

      @dummy.avatar.reprocess!

      assert_file_exists(@thumb_small_path)
      assert_file_exists(@thumb_large_path)
    end

    it "allows us to selectively create each thumbnail" do
      assert_file_not_exists(@thumb_small_path)
      assert_file_not_exists(@thumb_large_path)

      @dummy.avatar.reprocess! :thumb_small
      assert_file_exists(@thumb_small_path)
      assert_file_not_exists(@thumb_large_path)

      @dummy.avatar.reprocess! :thumb_large
      assert_file_exists(@thumb_large_path)
    end
  end

  context "A model that modifies its original" do
    before do
      rebuild_model styles: { original: "2x2#" }
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
    end

    it "reports the file size of the processed file and not the original" do
      assert_not_equal File.size(@file.path), @dummy.avatar.size
    end

    after { @file.close }
  end

  context "A model with attachments scoped under an id" do
    before do
      rebuild_model styles: { large: "100x100",
                                 medium: "50x50" },
                    path: ":rails_root/tmp/:id/:attachments/:style.:extension"
      @dummy = Dummy.new
      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy.avatar = @file
    end

    after { @file.close }

    context "when saved" do
      before do
        @dummy.save
        @saved_path = @dummy.avatar.path(:large)
      end

      it "has a large file in the right place" do
        assert_file_exists(@dummy.avatar.path(:large))
      end

      context "and deleted" do
        before do
          @dummy.avatar.clear
          @dummy.save
        end

        it "does not have a large file in the right place anymore" do
          assert_file_not_exists(@saved_path)
        end

        it "does not have its next two parent directories" do
          assert_file_not_exists(File.dirname(@saved_path))
          assert_file_not_exists(File.dirname(File.dirname(@saved_path)))
        end
      end

      context 'and deleted where the delete fails' do
        it "does not die if an unexpected SystemCallError happens" do
          FileUtils.stubs(:rmdir).raises(Errno::EPIPE)
          assert_nothing_raised do
            @dummy.avatar.clear
            @dummy.save
          end
        end
      end
    end
  end

  [000,002,022].each do |umask|
    context "when the umask is #{umask}" do
      before do
        rebuild_model
        @dummy = Dummy.new
        @file  = File.new(fixture_file("5k.png"), 'rb')
        @umask = File.umask(umask)
      end

      after do
        File.umask @umask
        @file.close
      end

      it "respects the current umask" do
        @dummy.avatar = @file
        @dummy.save
        assert_equal 0666&~umask, 0666&File.stat(@dummy.avatar.path).mode
      end
    end
  end

  [0666,0664,0640].each do |perms|
    context "when the perms are #{perms}" do
      before do
        rebuild_model override_file_permissions: perms
        @dummy = Dummy.new
        @file  = File.new(fixture_file("5k.png"), 'rb')
      end

      after do
        @file.close
      end

      it "respects the current perms" do
        @dummy.avatar = @file
        @dummy.save
        assert_equal perms, File.stat(@dummy.avatar.path).mode & 0777
      end
    end
  end

  it "skips chmod operation, when override_file_permissions is set to false (e.g. useful when using CIFS mounts)" do
    FileUtils.expects(:chmod).never

    rebuild_model override_file_permissions: false
    dummy = Dummy.create!
    dummy.avatar = @file
    dummy.save
  end

  context "A model with a filesystem attachment" do
    before do
      rebuild_model styles: { large: "300x300>",
                                 medium: "100x100",
                                 thumb: ["32x32#", :gif] },
                    default_style: :medium,
                    url: "/:attachment/:class/:style/:id/:basename.:extension",
                    path: ":rails_root/tmp/:attachment/:class/:style/:id/:basename.:extension"
      @dummy     = Dummy.new
      @file      = File.new(fixture_file("5k.png"), 'rb')
      @bad_file  = File.new(fixture_file("bad.png"), 'rb')

      assert @dummy.avatar = @file
      assert @dummy.valid?, @dummy.errors.full_messages.join(", ")
      assert @dummy.save
    end

    after { [@file, @bad_file].each(&:close) }

    it "writes and delete its files" do
      [["434x66", :original],
       ["300x46", :large],
       ["100x15", :medium],
       ["32x32", :thumb]].each do |geo, style|
        cmd = %Q[identify -format "%wx%h" "#{@dummy.avatar.path(style)}"]
        assert_equal geo, `#{cmd}`.chomp, cmd
      end

      saved_paths = [:thumb, :medium, :large, :original].collect{|s| @dummy.avatar.path(s) }

      @d2 = Dummy.find(@dummy.id)
      assert_equal "100x15", `identify -format "%wx%h" "#{@d2.avatar.path}"`.chomp
      assert_equal "434x66", `identify -format "%wx%h" "#{@d2.avatar.path(:original)}"`.chomp
      assert_equal "300x46", `identify -format "%wx%h" "#{@d2.avatar.path(:large)}"`.chomp
      assert_equal "100x15", `identify -format "%wx%h" "#{@d2.avatar.path(:medium)}"`.chomp
      assert_equal "32x32",  `identify -format "%wx%h" "#{@d2.avatar.path(:thumb)}"`.chomp

      assert @dummy.valid?
      assert @dummy.save

      saved_paths.each do |p|
        assert_file_exists(p)
      end

      @dummy.avatar.clear
      assert_nil @dummy.avatar_file_name
      assert @dummy.valid?
      assert @dummy.save

      saved_paths.each do |p|
        assert_file_not_exists(p)
      end

      @d2 = Dummy.find(@dummy.id)
      assert_nil @d2.avatar_file_name
    end

    it "works exactly the same when new as when reloaded" do
      @d2 = Dummy.find(@dummy.id)

      assert_equal @dummy.avatar_file_name, @d2.avatar_file_name
      [:thumb, :medium, :large, :original].each do |style|
        assert_equal @dummy.avatar.path(style), @d2.avatar.path(style)
      end

      saved_paths = [:thumb, :medium, :large, :original].collect{|s| @dummy.avatar.path(s) }

      @d2.avatar.clear
      assert @d2.save

      saved_paths.each do |p|
        assert_file_not_exists(p)
      end
    end

    it "does not abide things that don't have adapters" do
      assert_raises(Paperclip::AdapterRegistry::NoHandlerError) do
        @dummy.avatar = "not a file"
      end
    end

    it "is not ok with bad files" do
      @dummy.avatar = @bad_file
      assert ! @dummy.valid?
    end

    it "knows the difference between good files, bad files, and not files when validating" do
      Dummy.validates_attachment_presence :avatar
      @d2 = Dummy.find(@dummy.id)
      @d2.avatar = @file
      assert  @d2.valid?, @d2.errors.full_messages.inspect
      @d2.avatar = @bad_file
      assert ! @d2.valid?
    end

    it "is able to reload without saving and not have the file disappear" do
      @dummy.avatar = @file
      assert @dummy.save, @dummy.errors.full_messages.inspect
      @dummy.avatar.clear
      assert_nil @dummy.avatar_file_name
      @dummy.reload
      assert_equal "5k.png", @dummy.avatar_file_name
    end

    context "that is assigned its file from another Paperclip attachment" do
      before do
        @dummy2 = Dummy.new
        @file2 = File.new(fixture_file("12k.png"), 'rb')
        assert @dummy2.avatar = @file2
        @dummy2.save
      end

      after { @file2.close }

      it "works when assigned a file" do
        assert_not_equal `identify -format "%wx%h" "#{@dummy.avatar.path(:original)}"`,
          `identify -format "%wx%h" "#{@dummy2.avatar.path(:original)}"`

        assert @dummy.avatar = @dummy2.avatar
        @dummy.save
        assert_equal @dummy.avatar_file_name, @dummy2.avatar_file_name
        assert_equal `identify -format "%wx%h" "#{@dummy.avatar.path(:original)}"`,
          `identify -format "%wx%h" "#{@dummy2.avatar.path(:original)}"`
      end
    end

  end

  context "A model with an attachments association and a Paperclip attachment" do
    before do
      Dummy.class_eval do
        has_many :attachments, class_name: 'Dummy'
      end

      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy = Dummy.new
      @dummy.avatar = @file
    end

    after { @file.close }

    it "does not error when saving" do
      @dummy.save!
    end
  end

  context "A model with an attachment with hash in file name" do
    before do
      @settings = { styles: { thumb: "50x50#" },
        path: ":rails_root/public/system/:attachment/:id_partition/:style/:hash.:extension",
        url: "/system/:attachment/:id_partition/:style/:hash.:extension",
        hash_secret: "somesecret" }

      rebuild_model @settings

      @file = File.new(fixture_file("5k.png"), 'rb')
      @dummy = Dummy.create! avatar: @file
    end

    after do
      @file.close
    end

    it "is accessible" do
      assert_file_exists(@dummy.avatar.path(:original))
      assert_file_exists(@dummy.avatar.path(:thumb))
    end

    context "when new style is added" do
      before do
        @dummy.avatar.options[:styles][:mini] = "25x25#"
        @dummy.avatar.instance_variable_set :@normalized_styles, nil
        Time.stubs(now: Time.now + 10)
        @dummy.avatar.reprocess!
        @dummy.reload
      end

      it "makes all the styles accessible" do
        assert_file_exists(@dummy.avatar.path(:original))
        assert_file_exists(@dummy.avatar.path(:thumb))
        assert_file_exists(@dummy.avatar.path(:mini))
      end
    end
  end

  if ENV['S3_BUCKET']
    def s3_files_for attachment
      [:thumb, :medium, :large, :original].inject({}) do |files, style|
        data = `curl "#{attachment.url(style)}" 2>/dev/null`.chomp
        t = Tempfile.new("paperclip-test")
        t.binmode
        t.write(data)
        t.rewind
        files[style] = t
        files
      end
    end

    def s3_headers_for attachment, style
      `curl --head "#{attachment.url(style)}" 2>/dev/null`.split("\n").inject({}) do |h,head|
        split_head = head.chomp.split(/\s*:\s*/, 2)
        h[split_head.first.downcase] = split_head.last unless split_head.empty?
        h
      end
    end

    context "A model with an S3 attachment" do
      before do
        rebuild_model(
          styles: {
            large: "300x300>",
            medium: "100x100",
            thumb: ["32x32#", :gif],
            custom: {
              geometry: "32x32#",
              s3_headers: { 'Cache-Control' => 'max-age=31557600' },
              s3_metadata: { 'foo' => 'bar'}
            }
          },
          storage: :s3,
          s3_credentials: File.new(fixture_file('s3.yml')),
          s3_options: { logger: Paperclip.logger },
          default_style: :medium,
          bucket: ENV['S3_BUCKET'],
          path: ":class/:attachment/:id/:style/:basename.:extension"
        )

        @dummy     = Dummy.new
        @file      = File.new(fixture_file('5k.png'), 'rb')
        @bad_file  = File.new(fixture_file('bad.png'), 'rb')

        @dummy.avatar = @file
        @dummy.valid?
        @dummy.save!

        @files_on_s3 = s3_files_for(@dummy.avatar)
      end

      after do
        @file.close
        @bad_file.close
        @files_on_s3.values.each(&:close) if @files_on_s3
      end

      context 'assigning itself to a new model' do
        before do
          @d2 = Dummy.new
          @d2.avatar = @dummy.avatar
          @d2.save
        end

        it "has the same name as the old file" do
          assert_equal @d2.avatar.original_filename, @dummy.avatar.original_filename
        end
      end

      it "has the same contents as the original" do
        assert_equal @file.read, @files_on_s3[:original].read
      end

      it "writes and delete its files" do
        [["434x66", :original],
         ["300x46", :large],
         ["100x15", :medium],
         ["32x32", :thumb]].each do |geo, style|
          cmd = %Q[identify -format "%wx%h" "#{@files_on_s3[style].path}"]
          assert_equal geo, `#{cmd}`.chomp, cmd
        end

        @d2 = Dummy.find(@dummy.id)
        @d2_files = s3_files_for @d2.avatar
        [["434x66", :original],
         ["300x46", :large],
         ["100x15", :medium],
         ["32x32", :thumb]].each do |geo, style|
          cmd = %Q[identify -format "%wx%h" "#{@d2_files[style].path}"]
          assert_equal geo, `#{cmd}`.chomp, cmd
        end

        @dummy.avatar.clear
        assert_nil @dummy.avatar_file_name
        assert @dummy.valid?
        assert @dummy.save

        [:thumb, :medium, :large, :original].each do |style|
          assert ! @dummy.avatar.exists?(style)
        end

        @d2 = Dummy.find(@dummy.id)
        assert_nil @d2.avatar_file_name
      end

      it "works exactly the same when new as when reloaded" do
        @d2 = Dummy.find(@dummy.id)

        assert_equal @dummy.avatar_file_name, @d2.avatar_file_name

        [:thumb, :medium, :large, :original].each do |style|
          begin
            first_file = open(@dummy.avatar.url(style))
            second_file = open(@dummy.avatar.url(style))
            assert_equal first_file.read, second_file.read
          ensure
            first_file.close if first_file
            second_file.close if second_file
          end
        end

        @d2.avatar.clear
        assert @d2.save

        [:thumb, :medium, :large, :original].each do |style|
          assert ! @dummy.avatar.exists?(style)
        end
      end

      it "knows the difference between good files, bad files, and nil" do
        @dummy.avatar = @bad_file
        assert ! @dummy.valid?
        @dummy.avatar = nil
        assert @dummy.valid?

        Dummy.validates_attachment_presence :avatar
        @d2 = Dummy.find(@dummy.id)
        @d2.avatar = @file
        assert   @d2.valid?
        @d2.avatar = @bad_file
        assert ! @d2.valid?
        @d2.avatar = nil
        assert ! @d2.valid?
      end

      it "is able to reload without saving and not have the file disappear" do
        @dummy.avatar = @file
        assert @dummy.save
        @dummy.avatar = nil
        assert_nil @dummy.avatar_file_name
        @dummy.reload
        assert_equal "5k.png", @dummy.avatar_file_name
      end

      it "has the right content type" do
        headers = s3_headers_for(@dummy.avatar, :original)
        assert_equal 'image/png', headers['content-type']
      end

      it "has the right style-specific headers" do
        headers = s3_headers_for(@dummy.avatar, :custom)
        assert_equal 'max-age=31557600', headers['cache-control']
      end

      it "has the right style-specific metadata" do
        headers = s3_headers_for(@dummy.avatar, :custom)
        assert_equal 'bar', headers['x-amz-meta-foo']
      end

      context "with non-english character in the file name" do
        before do
          @file.stubs(:original_filename).returns("クリップ.png")
          @dummy.avatar = @file
        end

        it "does not raise any error" do
          @dummy.save!
        end
      end
    end
  end

  context "Copying attachments between models" do
    before do
      rebuild_model
      @file = File.new(fixture_file("5k.png"), 'rb')
    end

    after { @file.close }

    it "succeeds when original attachment is a file" do
      original = Dummy.new
      original.avatar = @file
      assert original.save

      copy = Dummy.new
      copy.avatar = original.avatar
      assert copy.save

      assert copy.avatar.present?
    end

    it "succeeds when original attachment is empty" do
      original = Dummy.create!

      copy = Dummy.new
      copy.avatar = @file
      assert copy.save
      assert copy.avatar.present?

      copy.avatar = original.avatar
      assert copy.save
      assert !copy.avatar.present?
    end
  end
end
