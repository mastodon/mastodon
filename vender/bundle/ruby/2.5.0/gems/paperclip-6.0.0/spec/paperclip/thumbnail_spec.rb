require 'spec_helper'

describe Paperclip::Thumbnail do
  context "An image" do
    before do
      @file = File.new(fixture_file("5k.png"), 'rb')
    end

    after { @file.close }

    [["600x600>", "434x66"],
     ["400x400>", "400x61"],
     ["32x32<", "434x66"],
     [nil, "434x66"]
    ].each do |args|
      context "being thumbnailed with a geometry of #{args[0]}" do
        before do
          @thumb = Paperclip::Thumbnail.new(@file, geometry: args[0])
        end

        it "starts with dimensions of 434x66" do
          cmd = %Q[identify -format "%wx%h" "#{@file.path}"]
          assert_equal "434x66", `#{cmd}`.chomp
        end

        it "reports the correct target geometry" do
          assert_equal args[0].to_s, @thumb.target_geometry.to_s
        end

        context "when made" do
          before do
            @thumb_result = @thumb.make
          end

          it "is the size we expect it to be" do
            cmd = %Q[identify -format "%wx%h" "#{@thumb_result.path}"]
            assert_equal args[1], `#{cmd}`.chomp
          end
        end
      end
    end

    context "being thumbnailed at 100x50 with cropping" do
      before do
        @thumb = Paperclip::Thumbnail.new(@file, geometry: "100x50#")
      end

      it "lets us know when a command isn't found versus a processing error" do
        old_path = ENV['PATH']
        begin
          Terrapin::CommandLine.path = ''
          Paperclip.options[:command_path] = ''
          ENV['PATH'] = ''
          assert_raises(Paperclip::Errors::CommandNotFoundError) do
            silence_stream(STDERR) do
              @thumb.make
            end
          end
        ensure
          ENV['PATH'] = old_path
        end
      end

      it "reports its correct current and target geometries" do
        assert_equal "100x50#", @thumb.target_geometry.to_s
        assert_equal "434x66", @thumb.current_geometry.to_s
      end

      it "reports its correct format" do
        assert_nil @thumb.format
      end

      it "has whiny turned on by default" do
        assert @thumb.whiny
      end

      it "has convert_options set to nil by default" do
        assert_equal nil, @thumb.convert_options
      end

      it "has source_file_options set to nil by default" do
        assert_equal nil, @thumb.source_file_options
      end

      it "sends the right command to convert when sent #make" do
        @thumb.expects(:convert).with do |*arg|
          arg[0] == ':source -auto-orient -resize "x50" -crop "100x50+114+0" +repage :dest' &&
          arg[1][:source] == "#{File.expand_path(@thumb.file.path)}[0]"
        end
        @thumb.make
      end

      it "creates the thumbnail when sent #make" do
        dst = @thumb.make
        assert_match /100x50/, `identify "#{dst.path}"`
      end
    end

    it 'crops a EXIF-rotated image properly' do
      file = File.new(fixture_file('rotated.jpg'))
      thumb = Paperclip::Thumbnail.new(file, geometry: "50x50#")

      output_file = thumb.make

      command = Terrapin::CommandLine.new("identify", "-format %wx%h :file")
      assert_equal "50x50", command.run(file: output_file.path).strip
    end

    context "being thumbnailed with source file options set" do
      before do
        @thumb = Paperclip::Thumbnail.new(@file,
                                          geometry: "100x50#",
                                          source_file_options: "-strip")
      end

      it "has source_file_options value set" do
        assert_equal ["-strip"], @thumb.source_file_options
      end

      it "sends the right command to convert when sent #make" do
        @thumb.expects(:convert).with do |*arg|
          arg[0] == '-strip :source -auto-orient -resize "x50" -crop "100x50+114+0" +repage :dest' &&
          arg[1][:source] == "#{File.expand_path(@thumb.file.path)}[0]"
        end
        @thumb.make
      end

      it "creates the thumbnail when sent #make" do
        dst = @thumb.make
        assert_match /100x50/, `identify "#{dst.path}"`
      end

      context "redefined to have bad source_file_options setting" do
        before do
          @thumb = Paperclip::Thumbnail.new(@file,
                                            geometry: "100x50#",
                                            source_file_options: "-this-aint-no-option")
        end

        it "errors when trying to create the thumbnail" do
          assert_raises(Paperclip::Error) do
            silence_stream(STDERR) do
              @thumb.make
            end
          end
        end
      end
    end

    context "being thumbnailed with convert options set" do
      before do
        @thumb = Paperclip::Thumbnail.new(@file,
                                          geometry: "100x50#",
                                          convert_options: "-strip -depth 8")
      end

      it "has convert_options value set" do
        assert_equal %w"-strip -depth 8", @thumb.convert_options
      end

      it "sends the right command to convert when sent #make" do
        @thumb.expects(:convert).with do |*arg|
          arg[0] == ':source -auto-orient -resize "x50" -crop "100x50+114+0" +repage -strip -depth 8 :dest' &&
          arg[1][:source] == "#{File.expand_path(@thumb.file.path)}[0]"
        end
        @thumb.make
      end

      it "creates the thumbnail when sent #make" do
        dst = @thumb.make
        assert_match /100x50/, `identify "#{dst.path}"`
      end

      context "redefined to have bad convert_options setting" do
        before do
          @thumb = Paperclip::Thumbnail.new(@file,
                                            geometry: "100x50#",
                                            convert_options: "-this-aint-no-option")
        end

        it "errors when trying to create the thumbnail" do
          assert_raises(Paperclip::Error) do
            silence_stream(STDERR) do
              @thumb.make
            end
          end
        end

        it "lets us know when a command isn't found versus a processing error" do
          old_path = ENV['PATH']
          begin
            Terrapin::CommandLine.path = ''
            Paperclip.options[:command_path] = ''
            ENV['PATH'] = ''
            assert_raises(Paperclip::Errors::CommandNotFoundError) do
              silence_stream(STDERR) do
                @thumb.make
              end
            end
          ensure
            ENV['PATH'] = old_path
          end
        end
      end
    end

    context "being thumbnailed with a blank geometry string" do
      before do
        @thumb = Paperclip::Thumbnail.new(@file,
                                          geometry: "",
                                          convert_options: "-gravity center -crop \"300x300+0-0\"")
      end

      it "does not get resized by default" do
        assert !@thumb.transformation_command.include?("-resize")
      end
    end

    context "being thumbnailed with default animated option (true)" do
      it "calls identify to check for animated images when sent #make" do
        thumb = Paperclip::Thumbnail.new(@file, geometry: "100x50#")
        thumb.expects(:identify).at_least_once.with do |*arg|
          arg[0] == '-format %m :file' &&
          arg[1][:file] == "#{File.expand_path(thumb.file.path)}[0]"
        end
        thumb.make
      end
    end

    context "passing a custom file geometry parser" do
      after do
        Object.send(:remove_const, :GeoParser) if Object.const_defined?(:GeoParser)
      end

      it "produces the appropriate transformation_command" do
        GeoParser = Class.new do
          def self.from_file(file)
            new
          end

          def transformation_to(target, should_crop)
            ["SCALE", "CROP"]
          end
        end

        thumb = Paperclip::Thumbnail.new(@file, geometry: '50x50', file_geometry_parser: ::GeoParser)

        transformation_command = thumb.transformation_command

        assert transformation_command.include?('-crop'),
          %{expected #{transformation_command.inspect} to include '-crop'}
        assert transformation_command.include?('"CROP"'),
          %{expected #{transformation_command.inspect} to include '"CROP"'}
        assert transformation_command.include?('-resize'),
          %{expected #{transformation_command.inspect} to include '-resize'}
        assert transformation_command.include?('"SCALE"'),
          %{expected #{transformation_command.inspect} to include '"SCALE"'}
      end
    end

    context "passing a custom geometry string parser" do
      after do
        Object.send(:remove_const, :GeoParser) if Object.const_defined?(:GeoParser)
      end

      it "produces the appropriate transformation_command" do
        GeoParser = Class.new do
          def self.parse(s)
            new
          end

          def to_s
            "151x167"
          end
        end

        thumb = Paperclip::Thumbnail.new(@file, geometry: '50x50', string_geometry_parser: ::GeoParser)

        transformation_command = thumb.transformation_command

        assert transformation_command.include?('"151x167"'),
          %{expected #{transformation_command.inspect} to include '151x167'}
      end
    end
  end

  context "A multipage PDF" do
    before do
      @file = File.new(fixture_file("twopage.pdf"), 'rb')
    end

    after { @file.close }

    it "starts with two pages with dimensions 612x792" do
      cmd = %Q[identify -format "%wx%h" "#{@file.path}"]
      assert_equal "612x792"*2, `#{cmd}`.chomp
    end

    context "being thumbnailed at 100x100 with cropping" do
      before do
        @thumb = Paperclip::Thumbnail.new(@file, geometry: "100x100#", format: :png)
      end

      it "reports its correct current and target geometries" do
        assert_equal "100x100#", @thumb.target_geometry.to_s
        assert_equal "612x792", @thumb.current_geometry.to_s
      end

      it "reports its correct format" do
        assert_equal :png, @thumb.format
      end

      it "creates the thumbnail when sent #make" do
        dst = @thumb.make
        assert_match /100x100/, `identify "#{dst.path}"`
      end
    end
  end

  context "An animated gif" do
    before do
      @file = File.new(fixture_file("animated.gif"), 'rb')
    end

    after { @file.close }

    it "starts with 12 frames with size 100x100" do
      cmd = %Q[identify -format "%wx%h" "#{@file.path}"]
      assert_equal "100x100"*12, `#{cmd}`.chomp
    end

    context "with static output" do
      before do
       @thumb = Paperclip::Thumbnail.new(@file, geometry: "50x50", format: :jpg)
      end

      it "creates the single frame thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h" "#{dst.path}"]
        assert_equal "50x50", `#{cmd}`.chomp
      end
    end

    context "with animated output format" do
      before do
       @thumb = Paperclip::Thumbnail.new(@file, geometry: "50x50", format: :gif)
      end

      it "creates the 12 frames thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h," "#{dst.path}"]
        frames = `#{cmd}`.chomp.split(',')
        assert_equal 12, frames.size
        assert_frame_dimensions (45..50), frames
      end

      it "uses the -coalesce option" do
        assert_equal @thumb.transformation_command.first, "-coalesce"
      end

      it "uses the -layers 'optimize' option" do
        assert_equal @thumb.transformation_command.last, '-layers "optimize"'
      end
    end

    context "with omitted output format" do
      before do
       @thumb = Paperclip::Thumbnail.new(@file, geometry: "50x50")
      end

      it "creates the 12 frames thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h," "#{dst.path}"]
        frames = `#{cmd}`.chomp.split(',')
        assert_equal 12, frames.size
        assert_frame_dimensions (45..50), frames
      end

      it "uses the -coalesce option" do
        assert_equal @thumb.transformation_command.first, "-coalesce"
      end

      it "uses the -layers 'optimize' option" do
        assert_equal @thumb.transformation_command.last, '-layers "optimize"'
      end
    end

    context "with unidentified source format" do
      before do
        @unidentified_file = File.new(fixture_file("animated.unknown"), 'rb')
        @thumb = Paperclip::Thumbnail.new(@file, geometry: "60x60")
      end

      it "creates the 12 frames thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h," "#{dst.path}"]
        frames = `#{cmd}`.chomp.split(',')
        assert_equal 12, frames.size
        assert_frame_dimensions (55..60), frames
      end

      it "uses the -coalesce option" do
        assert_equal @thumb.transformation_command.first, "-coalesce"
      end

      it "uses the -layers 'optimize' option" do
        assert_equal @thumb.transformation_command.last, '-layers "optimize"'
      end
    end

    context "with no source format" do
      before do
        @unidentified_file = File.new(fixture_file("animated"), 'rb')
        @thumb = Paperclip::Thumbnail.new(@file, geometry: "70x70")
      end

      it "creates the 12 frames thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h," "#{dst.path}"]
        frames = `#{cmd}`.chomp.split(',')
        assert_equal 12, frames.size
        assert_frame_dimensions (60..70), frames
      end

      it "uses the -coalesce option" do
        assert_equal @thumb.transformation_command.first, "-coalesce"
      end

      it "uses the -layers 'optimize' option" do
        assert_equal @thumb.transformation_command.last, '-layers "optimize"'
      end
    end

    context "with animated option set to false" do
      before do
       @thumb = Paperclip::Thumbnail.new(@file, geometry: "50x50", animated: false)
      end

      it "outputs the gif format" do
        dst = @thumb.make
        cmd = %Q[identify "#{dst.path}"]
        assert_match /GIF/, `#{cmd}`.chomp
      end

      it "creates the single frame thumbnail when sent #make" do
        dst = @thumb.make
        cmd = %Q[identify -format "%wx%h" "#{dst.path}"]
        assert_equal "50x50", `#{cmd}`.chomp
      end
    end

    context "with a specified frame_index" do
      before do
        @thumb = Paperclip::Thumbnail.new(
          @file,
          geometry: "50x50",
          frame_index: 5,
          format: :jpg,
        )
      end

      it "creates the thumbnail from the frame index when sent #make" do
        @thumb.make
        assert_equal 5, @thumb.frame_index
      end
    end

    context "with a specified frame_index out of bounds" do
      before do
        @thumb = Paperclip::Thumbnail.new(
          @file,
          geometry: "50x50",
          frame_index: 20,
          format: :jpg,
        )
      end

      it "errors when trying to create the thumbnail" do
        assert_raises(Paperclip::Error) do
          silence_stream(STDERR) do
            @thumb.make
          end
        end
      end
    end
  end

  context "with a really long file name" do
    before do
      tempfile = Tempfile.new("f")
      tempfile_additional_chars = tempfile.path.split("/")[-1].length + 15
      image_file = File.new(fixture_file("5k.png"), "rb")
      @file = Tempfile.new("f" * (255 - tempfile_additional_chars))
      @file.write(image_file.read)
      @file.rewind
    end

    it "does not throw Errno::ENAMETOOLONG" do
      thumb = Paperclip::Thumbnail.new(@file, geometry: "50x50", format: :gif)
      expect { thumb.make }.to_not raise_error
    end
  end
end
