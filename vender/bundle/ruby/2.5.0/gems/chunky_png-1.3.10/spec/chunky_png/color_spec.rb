require 'spec_helper'

describe 'ChunyPNG.Color' do
  it 'should interpret 4 arguments as RGBA values' do
    expect(ChunkyPNG::Color(1, 2, 3, 4)).to eql ChunkyPNG::Color.rgba(1, 2, 3, 4)
  end

  it 'should interpret 3 arguments as RGBA values' do
    expect(ChunkyPNG::Color(1, 2, 3)).to eql ChunkyPNG::Color.rgb(1, 2, 3)
  end

  it 'should interpret 2 arguments as a color to parse and an opacity value' do
    expect(ChunkyPNG::Color('0x0a649664', 0xaa)).to eql 0x0a6496aa
    expect(ChunkyPNG::Color('spring green @ 0.6666', 0xff)).to eql 0x00ff7fff
  end

  it 'should interpret 1 argument as a color to parse' do
    expect(ChunkyPNG::Color).to receive(:parse).with('0x0a649664')
    ChunkyPNG::Color('0x0a649664')
  end
end

describe ChunkyPNG::Color do
  include ChunkyPNG::Color

  before(:each) do
    @white             = 0xffffffff
    @black             = 0x000000ff
    @opaque            = 0x0a6496ff
    @non_opaque        = 0x0a649664
    @fully_transparent = 0x0a649600
    @red               = 0xff0000ff
    @green             = 0x00ff00ff
    @blue              = 0x0000ffff
  end

  describe '#parse' do
    it 'should interpret a hex string correctly' do
      expect(parse('0x0a649664')).to eql ChunkyPNG::Color.from_hex('#0a649664')
    end

    it 'should interpret a color name correctly' do
      expect(parse(:spring_green)).to eql 0x00ff7fff
      expect(parse('spring green')).to eql 0x00ff7fff
      expect(parse('spring green @ 0.6666')).to eql 0x00ff7faa
    end

    it 'should return numbers as is' do
      expect(parse('12345')).to eql 12345
      expect(parse(12345)).to eql 12345
    end
  end

  describe '#pixel_bytesize' do
    it 'should return the normal amount of bytes with a bit depth of 8' do
      expect(pixel_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 8)).to eql 3
    end

    it 'should return a multiple of the normal amount of bytes with a bit depth greater than 8' do
      expect(pixel_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 16)).to eql 6
      expect(pixel_bytesize(ChunkyPNG::COLOR_TRUECOLOR_ALPHA, 16)).to eql 8
      expect(pixel_bytesize(ChunkyPNG::COLOR_GRAYSCALE_ALPHA, 16)).to eql 4
    end

    it 'should return 1 with a bit depth lower than 0' do
      expect(pixel_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 4)).to eql 1
      expect(pixel_bytesize(ChunkyPNG::COLOR_INDEXED, 2)).to eql 1
      expect(pixel_bytesize(ChunkyPNG::COLOR_GRAYSCALE_ALPHA, 1)).to eql 1
    end
  end

  describe '#pass_bytesize' do
    it 'should calculate a pass size correctly' do
      expect(pass_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 8, 10, 10)).to eql 310
    end

    it 'should return 0 if one of the dimensions is zero' do
      expect(pass_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 8, 0, 10)).to eql 0
      expect(pass_bytesize(ChunkyPNG::COLOR_TRUECOLOR, 8, 10, 0)).to eql 0
    end
  end

  describe '#rgba' do
    it 'should represent pixels as the correct number' do
      expect(rgba(255, 255, 255, 255)).to eql @white
      expect(rgba(  0,   0,   0, 255)).to eql @black
      expect(rgba( 10, 100, 150, 255)).to eql @opaque
      expect(rgba( 10, 100, 150, 100)).to eql @non_opaque
      expect(rgba( 10, 100, 150,   0)).to eql @fully_transparent
    end
  end

  describe '#from_hex' do
    it 'should load colors correctly from hex notation' do
      expect(from_hex('0a649664')).to   eql @non_opaque
      expect(from_hex('#0a649664')).to  eql @non_opaque
      expect(from_hex('0x0a649664')).to eql @non_opaque
      expect(from_hex('0a6496')).to     eql @opaque
      expect(from_hex('#0a6496')).to    eql @opaque
      expect(from_hex('0x0a6496')).to   eql @opaque
      expect(from_hex('abc')).to        eql 0xaabbccff
      expect(from_hex('#abc')).to       eql 0xaabbccff
      expect(from_hex('0xabc')).to      eql 0xaabbccff
    end

    it 'should allow setting opacity explicitly' do
      expect(from_hex('0x0a6496', 0x64)).to eql @non_opaque
      expect(from_hex('#0a6496', 0x64)).to  eql @non_opaque
      expect(from_hex('0xabc', 0xdd)).to    eql 0xaabbccdd
      expect(from_hex('#abc', 0xdd)).to     eql 0xaabbccdd
    end
  end

  describe '#from_hsv' do
    it 'should load colors correctly from an HSV triple' do
      # At 0 brightness, should be @black independent of hue or sat
      expect(from_hsv(0, 0, 0)).to        eql @black
      expect(from_hsv(100, 1, 0)).to      eql @black
      expect(from_hsv(100, 0.5, 0)).to    eql @black

      # At brightness 1 and sat 0, should be @white regardless of hue
      expect(from_hsv(0, 0, 1)).to        eql @white
      expect(from_hsv(100, 0, 1)).to      eql @white

      # Converting the "pure" colors should work
      expect(from_hsv(0, 1, 1)).to        eql @red
      expect(from_hsv(120, 1, 1)).to      eql @green
      expect(from_hsv(240, 1, 1)).to      eql @blue

      # And, finally, one random color
      expect(from_hsv(120, 0.5, 0.80)).to eql 0x66cc66ff

      # Hue 0 and hue 360 should be equivalent
      expect(from_hsv(0, 0.5, 0.5)).to eql from_hsv(360, 0.5, 0.5)
      expect(from_hsv(0, 0.5, 0.5)).to eql from_hsv(360.0, 0.5, 0.5)
    end

    it 'should optionally accept a fourth param for alpha' do
      expect(from_hsv(0, 1, 1, 255)).to   eql @red
      expect(from_hsv(120, 1, 1, 255)).to eql @green
      expect(from_hsv(240, 1, 1, 255)).to eql @blue
      expect(from_hsv(0, 1, 1, 0)).to     eql 0xff000000 # transparent red
      expect(from_hsv(120, 1, 1, 0)).to   eql 0x00ff0000 # transparent green
      expect(from_hsv(240, 1, 1, 0)).to   eql 0x0000ff00 # transparent blue
    end
  end

  describe '#from_hsl' do
    it 'should load colors correctly from an HSL triple' do
      # At 0 lightness, should always be black
      expect(from_hsl(0, 0, 0)).to         eql @black
      expect(from_hsl(100, 0, 0)).to       eql @black
      expect(from_hsl(54, 0.5, 0)).to      eql @black

      # At 1 lightness, should always be white
      expect(from_hsl(0, 0, 1)).to         eql @white
      expect(from_hsl(0, 0.5, 1)).to       eql @white
      expect(from_hsl(110, 0, 1)).to       eql @white

      # 'Pure' colors should work
      expect(from_hsl(0, 1, 0.5)).to       eql @red
      expect(from_hsl(120, 1, 0.5)).to     eql @green
      expect(from_hsl(240, 1, 0.5)).to     eql @blue

      # Random colors
      from_hsl(87.27, 0.5, 0.5686)     == 0x96c85aff
      from_hsl(271.83, 0.5399, 0.4176) == 0x6e31a4ff
      from_hsl(63.6, 0.5984, 0.4882)   == 0xbec732ff

      # Hue 0 and hue 360 should be equivalent
      expect(from_hsl(0, 0.5, 0.5)).to eql from_hsl(360, 0.5, 0.5)
      expect(from_hsl(0, 0.5, 0.5)).to eql from_hsl(360.0, 0.5, 0.5)
    end

    it 'should optionally accept a fourth param for alpha' do
      expect(from_hsl(0, 1, 0.5, 255)).to   eql @red
      expect(from_hsl(120, 1, 0.5, 255)).to eql @green
      expect(from_hsl(240, 1, 0.5, 255)).to eql @blue
      expect(from_hsl(0, 1, 0.5, 0)).to     eql 0xff000000 # transparent red
      expect(from_hsl(120, 1, 0.5, 0)).to   eql 0x00ff0000 # transparent green
      expect(from_hsl(240, 1, 0.5, 0)).to   eql 0x0000ff00 # transparent blue
    end
  end

  describe '#html_color' do
    it 'should find the correct color value' do
      expect(html_color(:springgreen)).to   eql 0x00ff7fff
      expect(html_color(:spring_green)).to  eql 0x00ff7fff
      expect(html_color('springgreen')).to  eql 0x00ff7fff
      expect(html_color('spring green')).to eql 0x00ff7fff
      expect(html_color('SpringGreen')).to  eql 0x00ff7fff
      expect(html_color('SPRING_GREEN')).to eql 0x00ff7fff
    end

    it 'should set the opacity level explicitly' do
      expect(html_color(:springgreen, 0xff)).to eql 0x00ff7fff
      expect(html_color(:springgreen, 0xaa)).to eql 0x00ff7faa
      expect(html_color(:springgreen, 0x00)).to eql 0x00ff7f00
    end

    it 'should set opacity levels from the color name' do
      expect(html_color('Spring green @ 1.0')).to   eql 0x00ff7fff
      expect(html_color('Spring green @ 0.666')).to eql 0x00ff7faa
      expect(html_color('Spring green @ 0.0')).to   eql 0x00ff7f00
    end

    it 'should raise for an unkown color name' do
      expect { html_color(:nonsense) }.to raise_error(ArgumentError)
    end
  end

  describe '#opaque?' do
    it 'should correctly check for opaqueness' do
      expect(opaque?(@white)).to eql true
      expect(opaque?(@black)).to eql true
      expect(opaque?(@opaque)).to eql true
      expect(opaque?(@non_opaque)).to eql false
      expect(opaque?(@fully_transparent)).to eql false
    end
  end

  describe 'extraction of separate color channels' do
    it 'should extract components from a color correctly' do
      expect(r(@opaque)).to eql 10
      expect(g(@opaque)).to eql 100
      expect(b(@opaque)).to eql 150
      expect(a(@opaque)).to eql 255
    end
  end

  describe '#grayscale_teint' do
    it 'should calculate the correct grayscale teint' do
      expect(grayscale_teint(@opaque)).to     eql 79
      expect(grayscale_teint(@non_opaque)).to eql 79
    end
  end

  describe '#to_grayscale' do
    it 'should use the grayscale teint for r, g and b' do
      gs = to_grayscale(@non_opaque)
      expect(r(gs)).to eql grayscale_teint(@non_opaque)
      expect(g(gs)).to eql grayscale_teint(@non_opaque)
      expect(b(gs)).to eql grayscale_teint(@non_opaque)
    end

    it 'should preserve the alpha channel' do
      expect(a(to_grayscale(@non_opaque))).to eql a(@non_opaque)
      expect(a(to_grayscale(@opaque))).to eql ChunkyPNG::Color::MAX
    end
  end

  describe '#to_hex' do
    it 'should represent colors correcly using hex notation' do
      expect(to_hex(@white)).to eql '#ffffffff'
      expect(to_hex(@black)).to eql '#000000ff'
      expect(to_hex(@opaque)).to eql '#0a6496ff'
      expect(to_hex(@non_opaque)).to eql '#0a649664'
      expect(to_hex(@fully_transparent)).to eql '#0a649600'
    end

    it 'should represent colors correcly using hex notation without alpha channel' do
      expect(to_hex(@white, false)).to eql '#ffffff'
      expect(to_hex(@black, false)).to eql '#000000'
      expect(to_hex(@opaque, false)).to eql '#0a6496'
      expect(to_hex(@non_opaque, false)).to eql '#0a6496'
      expect(to_hex(@fully_transparent, false)).to eql '#0a6496'
    end
  end

  describe '#to_hsv' do
    it 'should return a [hue, saturation, value] array' do
      expect(to_hsv(@white)).to     eql [0,   0.0, 1.0]
      expect(to_hsv(@black)).to     eql [0,   0.0, 0.0]
      expect(to_hsv(@red)).to       eql [0,   1.0, 1.0]
      expect(to_hsv(@blue)).to      eql [240, 1.0, 1.0]
      expect(to_hsv(@green)).to     eql [120, 1.0, 1.0]
      expect(to_hsv(0x805440ff)[0]).to be_within(1).of(19)
      expect(to_hsv(0x805440ff)[1]).to be_within(0.01).of(0.5)
      expect(to_hsv(0x805440ff)[2]).to be_within(0.01).of(0.5)
    end

    it 'should optionally include the alpha channel' do
      expect(to_hsv(@white, true)).to                eql [0,   0.0, 1.0, 255]
      expect(to_hsv(@red, true)).to                  eql [0,   1.0, 1.0, 255]
      expect(to_hsv(@blue, true)).to                 eql [240, 1.0, 1.0, 255]
      expect(to_hsv(@green, true)).to                eql [120, 1.0, 1.0, 255]
      expect(to_hsv(@opaque, true)[3]).to            eql 255
      expect(to_hsv(@fully_transparent, true)[3]).to eql 0
    end
  end

  describe '#to_hsl' do
    it 'should return a [hue, saturation, lightness] array' do
      expect(to_hsl(@white)).to eql [0,   0.0, 1.0]
      expect(to_hsl(@black)).to eql [0,   0.0, 0.0]
      expect(to_hsl(@red)).to   eql [0,   1.0, 0.5]
      expect(to_hsl(@blue)).to  eql [240, 1.0, 0.5]
      expect(to_hsl(@green)).to eql [120, 1.0, 0.5]
    end

    it 'should optionally include the alpha channel in the returned array' do
      expect(to_hsl(@white, true)).to          eql [0,   0.0, 1.0, 255]
      expect(to_hsl(@black, true)).to          eql [0,   0.0, 0.0, 255]
      expect(to_hsl(@red, true)).to            eql [0,   1.0, 0.5, 255]
      expect(to_hsl(@blue, true)).to           eql [240, 1.0, 0.5, 255]
      expect(to_hsl(@green, true)).to          eql [120, 1.0, 0.5, 255]
      expect(to_hsl(@opaque, true)[3]).to      eql 255
      expect(to_hsl(@fully_transparent, true)[3]).to eql 0
    end
  end

  describe 'conversion to other formats' do
    it 'should convert the individual color values back correctly' do
      expect(to_truecolor_bytes(@opaque)).to eql [10, 100, 150]
      expect(to_truecolor_alpha_bytes(@non_opaque)).to eql [10, 100, 150, 100]
    end
  end

  describe '#compose' do

    it 'should use the foregorund color as is when the background color is fully transparent' do
      expect(compose(@non_opaque, @fully_transparent)).to eql @non_opaque
    end

    it 'should use the foregorund color as is when an opaque color is given as foreground color' do
      expect(compose(@opaque, @white)).to eql @opaque
    end

    it 'should use the background color as is when a fully transparent pixel is given as foreground color' do
      expect(compose(@fully_transparent, @white)).to eql @white
    end

    it 'should compose pixels correctly with both algorithms' do
      expect(compose_quick(@non_opaque, @white)).to   eql 0x9fc2d6ff
      expect(compose_precise(@non_opaque, @white)).to eql 0x9fc2d6ff
    end
  end

  describe '#decompose_alpha' do
    it 'should decompose the alpha channel correctly' do
      expect(decompose_alpha(0x9fc2d6ff, @opaque, @white)).to eql 0x00000064
    end

    it 'should return fully transparent if the background channel matches the resulting color' do
      expect(decompose_alpha(0xabcdefff, 0xff000000, 0xabcdefff)).to eql 0x00
    end

    it 'should return fully opaque if the background channel matches the mask color' do
      expect(decompose_alpha(0xff000000, 0xabcdefff, 0xabcdefff)).to eql 0xff
    end

    it 'should return fully opaque if the resulting color matches the mask color' do
      expect(decompose_alpha(0xabcdefff, 0xabcdefff, 0xffffffff)).to eql 255
    end
  end

  describe '#blend' do
    it 'should blend colors correctly' do
      expect(blend(@opaque, @black)).to eql 0x05324bff
    end

    it 'should not matter what color is used as foreground, and what as background' do
      expect(blend(@opaque, @black)).to eql blend(@black, @opaque)
    end
  end

  describe '#euclidean_distance_rgba' do
    subject { euclidean_distance_rgba(color_a, color_b) }

    context 'with white and black' do
      let(:color_a) { @white }
      let(:color_b) { @black }

      it { should == Math.sqrt(195_075) } # sqrt(255^2 * 3)
    end

    context 'with black and white' do
      let(:color_a) { @black }
      let(:color_b) { @white }

      it { should == Math.sqrt(195_075) } # sqrt(255^2 * 3)
    end

    context 'with the same colors' do
      let(:color_a) { @white }
      let(:color_b) { @white }

      it { should == 0 }
    end
  end
end
