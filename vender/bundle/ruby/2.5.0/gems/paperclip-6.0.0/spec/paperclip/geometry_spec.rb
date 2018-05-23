require 'spec_helper'

describe Paperclip::Geometry do
  context "Paperclip::Geometry" do
    it "correctly reports its given dimensions" do
      assert @geo = Paperclip::Geometry.new(1024, 768)
      assert_equal 1024, @geo.width
      assert_equal 768, @geo.height
    end

    it "sets height to 0 if height dimension is missing" do
      assert @geo = Paperclip::Geometry.new(1024)
      assert_equal 1024, @geo.width
      assert_equal 0, @geo.height
    end

    it "sets width to 0 if width dimension is missing" do
      assert @geo = Paperclip::Geometry.new(nil, 768)
      assert_equal 0, @geo.width
      assert_equal 768, @geo.height
    end

    it "is generated from a WxH-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800x600")
      assert_equal 800, @geo.width
      assert_equal 600, @geo.height
    end

    it "is generated from a xH-formatted string" do
      assert @geo = Paperclip::Geometry.parse("x600")
      assert_equal 0, @geo.width
      assert_equal 600, @geo.height
    end

    it "is generated from a Wx-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800x")
      assert_equal 800, @geo.width
      assert_equal 0, @geo.height
    end

    it "is generated from a W-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800")
      assert_equal 800, @geo.width
      assert_equal 0, @geo.height
    end

    it "ensures the modifier is nil if not present" do
      assert @geo = Paperclip::Geometry.parse("123x456")
      assert_nil @geo.modifier
    end

    it "recognizes an EXIF orientation and not rotate with auto_orient if not necessary" do
      geo = Paperclip::Geometry.new(width: 1024, height: 768, orientation: 1)
      assert geo
      assert_equal 1024, geo.width
      assert_equal 768, geo.height

      geo.auto_orient

      assert_equal 1024, geo.width
      assert_equal 768, geo.height
    end

    it "recognizes an EXIF orientation and rotate with auto_orient if necessary" do
      geo = Paperclip::Geometry.new(width: 1024, height: 768, orientation: 6)
      assert geo
      assert_equal 1024, geo.width
      assert_equal 768, geo.height

      geo.auto_orient

      assert_equal 768, geo.width
      assert_equal 1024, geo.height
    end

    it "treats x and X the same in geometries" do
      @lower = Paperclip::Geometry.parse("123x456")
      @upper = Paperclip::Geometry.parse("123X456")
      assert_equal 123, @lower.width
      assert_equal 123, @upper.width
      assert_equal 456, @lower.height
      assert_equal 456, @upper.height
    end

    ['>', '<', '#', '@', '@>', '>@', '%', '^', '!', nil].each do |mod|
      it "ensures the modifier #{description} is preserved" do
        assert @geo = Paperclip::Geometry.parse("123x456#{mod}")
        assert_equal mod, @geo.modifier
        assert_equal "123x456#{mod}", @geo.to_s
      end

      it "ensures the modifier #{description} is preserved with no height" do
        assert @geo = Paperclip::Geometry.parse("123x#{mod}")
        assert_equal mod, @geo.modifier
        assert_equal "123#{mod}", @geo.to_s
      end
    end

    it "makes sure the modifier gets passed during transformation_to" do
      assert @src = Paperclip::Geometry.parse("123x456")
      assert @dst = Paperclip::Geometry.parse("123x456>")
      assert_equal ["123x456>", nil], @src.transformation_to(@dst)
    end

    it "generates correct ImageMagick formatting string for W-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800")
      assert_equal "800", @geo.to_s
    end

    it "generates correct ImageMagick formatting string for Wx-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800x")
      assert_equal "800", @geo.to_s
    end

    it "generates correct ImageMagick formatting string for xH-formatted string" do
      assert @geo = Paperclip::Geometry.parse("x600")
      assert_equal "x600", @geo.to_s
    end

    it "generates correct ImageMagick formatting string for WxH-formatted string" do
      assert @geo = Paperclip::Geometry.parse("800x600")
      assert_equal "800x600", @geo.to_s
    end

    it "is generated from a file" do
      file = fixture_file("5k.png")
      file = File.new(file, 'rb')
      assert_nothing_raised{ @geo = Paperclip::Geometry.from_file(file) }
      assert_equal 66, @geo.height
      assert_equal 434, @geo.width
    end

    it "is generated from a file path" do
      file = fixture_file("5k.png")
      assert_nothing_raised{ @geo = Paperclip::Geometry.from_file(file) }
      assert_equal 66, @geo.height
      assert_equal 434, @geo.width
    end

    it 'calculates an EXIF-rotated image dimensions from a path' do
      file = fixture_file("rotated.jpg")
      assert_nothing_raised{ @geo = Paperclip::Geometry.from_file(file) }
      @geo.auto_orient
      assert_equal 300, @geo.height
      assert_equal 200, @geo.width
    end

    it "does not generate from a bad file" do
      file = "/home/This File Does Not Exist.omg"
      expect { @geo = Paperclip::Geometry.from_file(file) }.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
    end

    it "does not generate from a blank filename" do
      file = ""
      expect { @geo = Paperclip::Geometry.from_file(file) }.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
    end

    it "does not generate from a nil file" do
      file = nil
      expect { @geo = Paperclip::Geometry.from_file(file) }.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
    end

    it "does not generate from a file with no path" do
      file = mock("file", path: "")
      file.stubs(:respond_to?).with(:path).returns(true)
      expect { @geo = Paperclip::Geometry.from_file(file) }.to raise_error(Paperclip::Errors::NotIdentifiedByImageMagickError)
    end

    it "lets us know when a command isn't found versus a processing error" do
      old_path = ENV['PATH']
      begin
        ENV['PATH'] = ''
        assert_raises(Paperclip::Errors::CommandNotFoundError) do
          file = fixture_file("5k.png")
          @geo = Paperclip::Geometry.from_file(file)
        end
      ensure
        ENV['PATH'] = old_path
      end
    end

    [['vertical',   900,  1440, true,  false, false, 1440, 900, 0.625],
     ['horizontal', 1024, 768,  false, true,  false, 1024, 768, 1.3333],
     ['square',     100,  100,  false, false, true,  100,  100, 1]].each do |args|
      context "performing calculations on a #{args[0]} viewport" do
        before do
          @geo = Paperclip::Geometry.new(args[1], args[2])
        end

        it "is #{args[3] ? "" : "not"} vertical" do
          assert_equal args[3], @geo.vertical?
        end

        it "is #{args[4] ? "" : "not"} horizontal" do
          assert_equal args[4], @geo.horizontal?
        end

        it "is #{args[5] ? "" : "not"} square" do
          assert_equal args[5], @geo.square?
        end

        it "reports that #{args[6]} is the larger dimension" do
          assert_equal args[6], @geo.larger
        end

        it "reports that #{args[7]} is the smaller dimension" do
          assert_equal args[7], @geo.smaller
        end

        it "has an aspect ratio of #{args[8]}" do
          expect(@geo.aspect).to be_within(0.0001).of(args[8])
        end
      end
    end

    [[ [1000, 100], [64, 64],  "x64", "64x64+288+0" ],
     [ [100, 1000], [50, 950], "x950", "50x950+22+0" ],
     [ [100, 1000], [50, 25],  "50x", "50x25+0+237" ]]. each do |args|
      context "of #{args[0].inspect} and given a Geometry #{args[1].inspect} and sent transform_to" do
        before do
          @geo = Paperclip::Geometry.new(*args[0])
          @dst = Paperclip::Geometry.new(*args[1])
          @scale, @crop = @geo.transformation_to @dst, true
        end

        it "is able to return the correct scaling transformation geometry #{args[2]}" do
          assert_equal args[2], @scale
        end

        it "is able to return the correct crop transformation geometry #{args[3]}" do
          assert_equal args[3], @crop
        end
      end
    end

    [['256x256', {'150x150!' => [150, 150], '150x150#' => [150, 150], '150x150>' => [150, 150], '150x150<' => [256, 256], '150x150' => [150, 150]}],
     ['256x256', {'512x512!' => [512, 512], '512x512#' => [512, 512], '512x512>' => [256, 256], '512x512<' => [512, 512], '512x512' => [512, 512]}],
     ['600x400', {'512x512!' => [512, 512], '512x512#' => [512, 512], '512x512>' => [512, 341], '512x512<' => [600, 400], '512x512' => [512, 341]}]].each do |original_size, options|
      options.each_pair do |size, dimensions|
        context "#{original_size} resize_to #{size}" do
          before do
            @source = Paperclip::Geometry.parse original_size
            @new_geometry = @source.resize_to size
          end
          it "has #{dimensions.first} width" do
            assert_equal dimensions.first, @new_geometry.width
          end
          it "has #{dimensions.last} height" do
            assert_equal dimensions.last, @new_geometry.height
          end
        end
      end
    end
  end
end
