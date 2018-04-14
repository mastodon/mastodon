# coding: utf-8
require 'spec_helper'

describe ChunkyPNG::Datastream do

  describe '.from_io'do
    it "should raise an error when loading a file with a bad signature" do
      filename = resource_file('damaged_signature.png')
      expect { ChunkyPNG::Datastream.from_file(filename) }.to raise_error(ChunkyPNG::SignatureMismatch)
    end

    it "should raise an error if the CRC of a chunk is incorrect" do
      filename = resource_file('damaged_chunk.png')
      expect { ChunkyPNG::Datastream.from_file(filename) }.to raise_error(ChunkyPNG::CRCMismatch)
    end

    it "should raise an error for a stream that is too short" do
      stream = StringIO.new
      expect { ChunkyPNG::Datastream.from_io(stream) }.to raise_error(ChunkyPNG::SignatureMismatch)
    end

    it "should read a stream with trailing data without failing" do
      filename = resource_file('trailing_bytes_after_iend_chunk.png')
      image = ChunkyPNG::Datastream.from_file(filename)
      expect(image).to be_instance_of(ChunkyPNG::Datastream)
    end
  end

  describe '#metadata' do
    it "should load uncompressed tXTt chunks correctly" do
      filename = resource_file('text_chunk.png')
      ds = ChunkyPNG::Datastream.from_file(filename)
      expect(ds.metadata['Title']).to  eql 'My amazing icon!'
      expect(ds.metadata['Author']).to eql "Willem van Bergen"
    end

    it "should load compressed zTXt chunks correctly" do
      filename = resource_file('ztxt_chunk.png')
      ds = ChunkyPNG::Datastream.from_file(filename)
      expect(ds.metadata['Title']).to eql 'PngSuite'
      expect(ds.metadata['Copyright']).to eql "Copyright Willem van Schaik, Singapore 1995-96"
    end
  end

  describe '#physical_chunk' do
    it 'should read and write pHYs chunks correctly' do
      filename = resource_file('clock.png')
      ds = ChunkyPNG::Datastream.from_file(filename)
      expect(ds.physical_chunk.unit).to eql :meters
      expect(ds.physical_chunk.dpix.round).to eql 72
      expect(ds.physical_chunk.dpiy.round).to eql 72
      ds = ChunkyPNG::Datastream.from_blob(ds.to_blob)
      expect(ds.physical_chunk).not_to be_nil
    end

    it 'should raise ChunkyPNG::UnitsUnknown if we request dpi but the units are unknown' do
      physical_chunk = ChunkyPNG::Chunk::Physical.new(2835, 2835, :unknown)
      expect{physical_chunk.dpix}.to raise_error(ChunkyPNG::UnitsUnknown)
      expect{physical_chunk.dpiy}.to raise_error(ChunkyPNG::UnitsUnknown)
    end
  end

  describe '#iTXt_chunk' do
    it 'should read iTXt chunks correctly' do
      filename = resource_file('itxt_chunk.png')
      ds = ChunkyPNG::Datastream.from_file(filename)
      int_text_chunks = ds.chunks.select { |chunk| chunk.is_a?(ChunkyPNG::Chunk::InternationalText) }
      expect(int_text_chunks.length).to eq(2)

      coach_uk = int_text_chunks.find { |chunk| chunk.language_tag == 'en-gb' }
      coach_us = int_text_chunks.find { |chunk| chunk.language_tag == 'en-us' }
      expect(coach_uk).to_not be_nil
      expect(coach_us).to_not be_nil

      expect(coach_uk.keyword).to eq('coach')
      expect(coach_uk.text).to eq('bus with of higher standard of comfort, usually chartered or used for longer journeys')
      expect(coach_uk.translated_keyword).to eq('bus')
      expect(coach_uk.compressed).to eq(ChunkyPNG::UNCOMPRESSED_CONTENT)
      expect(coach_uk.compression).to eq(ChunkyPNG::COMPRESSION_DEFAULT)

      expect(coach_us.keyword).to eq('coach')
      expect(coach_us.text).to eq('US extracurricular sports teacher at a school (UK: PE teacher) lowest class on a passenger aircraft (UK: economy)')
      expect(coach_us.translated_keyword).to eq('trainer')
      expect(coach_us.compressed).to eq(ChunkyPNG::COMPRESSED_CONTENT)
      expect(coach_us.compression).to eq(ChunkyPNG::COMPRESSION_DEFAULT)
    end

    it 'should write iTXt chunks correctly' do
      expected_hex = %w(0000 001d 6954 5874 436f 6d6d 656e 7400 0000 0000 4372 6561 7465 6420 7769 7468 2047 494d 5064 2e65 07).join('')
      stream = StringIO.new
      itext = ChunkyPNG::Chunk::InternationalText.new('Comment', 'Created with GIMP')
      itext.write(stream)
      generated_hex = stream.string.unpack('H*').join('')

      expect(generated_hex).to eq(expected_hex)
    end

    it 'should handle incorrect UTF-8 encoding in iTXt chunks' do
      incorrect_text_encoding = [0, 0, 0, 14, 105, 84, 88, 116, 67, 111, 109, 109, 101, 110, 116, 0, 0, 0, 0, 0, 195, 40, 17, 87, 97, 213].pack('C*')
      incorrect_translated_keyword_encoding = [0, 0, 0, 19, 105, 84, 88, 116, 67, 111, 109, 109, 101, 110, 116, 0, 0, 0, 0, 226, 130, 40, 0, 116, 101, 115, 116, 228, 53, 113, 182].pack('C*')

      expect { ChunkyPNG::Chunk.read(StringIO.new(incorrect_text_encoding)) }.to raise_error(ChunkyPNG::InvalidUTF8)
      expect { ChunkyPNG::Chunk.read(StringIO.new(incorrect_translated_keyword_encoding)) }.to raise_error(ChunkyPNG::InvalidUTF8)
    end

    it 'should handle UTF-8 in iTXt compressed chunks correctly' do
      parsed = serialized_chunk(ChunkyPNG::Chunk::InternationalText.new('Comment', '✨', '', '💩', ChunkyPNG::COMPRESSED_CONTENT))

      expect(parsed.text).to eq('✨')
      expect(parsed.text.encoding).to eq(Encoding::UTF_8)

      expect(parsed.translated_keyword).to eq('💩')
      expect(parsed.translated_keyword.encoding).to eq(Encoding::UTF_8)
    end

    it 'should handle UTF-8 in iTXt chunks correctly' do
      parsed = serialized_chunk(ChunkyPNG::Chunk::InternationalText.new('Comment', '✨', '', '💩'))

      expect(parsed.text).to eq('✨')
      expect(parsed.text.encoding).to eq(Encoding::UTF_8)
      
      expect(parsed.translated_keyword).to eq('💩')      
      expect(parsed.translated_keyword.encoding).to eq(Encoding::UTF_8)
    end

    it 'should transform non UTF-8 iTXt fields to UTF-8 on write' do
      parsed = serialized_chunk(ChunkyPNG::Chunk::InternationalText.new('Comment', '®'.encode('Windows-1252'), '', 'ƒ'.encode('Windows-1252')))

      expect(parsed.text).to eq('®')
      expect(parsed.text.encoding).to eq(Encoding::UTF_8)

      expect(parsed.translated_keyword).to eq('ƒ')
      expect(parsed.translated_keyword.encoding).to eq(Encoding::UTF_8)
    end
  end
end
