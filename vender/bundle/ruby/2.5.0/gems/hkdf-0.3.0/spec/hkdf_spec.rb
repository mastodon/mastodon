require 'spec_helper'

describe HKDF do
  let(:source) { 'source' }
  subject(:hkdf) do
    HKDF.new(source)
  end

  describe 'initialize' do
    it 'accepts an IO or a string as a source' do
      output1 = HKDF.new(source).next_bytes(32)
      output2 = HKDF.new(StringIO.new(source)).next_bytes(32)
      expect(output1).to eq(output2)
    end

    it 'reads in an IO at a given read size' do
      io = StringIO.new(source)
      expect(io).to receive(:read).with(1)

      HKDF.new(io, :read_size => 1)
    end

    it 'reads in the whole IO' do
      hkdf1 = HKDF.new(source, :read_size => 1)
      hkdf2 = HKDF.new(source)

      expect(hkdf1.next_bytes(32)).to eq(hkdf2.next_bytes(32))
    end

    it 'defaults the algorithm to SHA-256' do
      expect(HKDF.new(source).algorithm).to eq('SHA256')
    end

    it 'takes an optional digest algorithm' do
      hkdf = HKDF.new('source', :algorithm => 'SHA1')
      expect(hkdf.algorithm).to eq('SHA1')
    end

    it 'defaults salt to all zeros of digest length' do
      salt = 0.chr * 32

      hkdf_salt = HKDF.new(source, :salt => salt)
      hkdf_nosalt = HKDF.new(source)
      expect(hkdf_salt.next_bytes(32)).to eq(hkdf_nosalt.next_bytes(32))
    end

    it 'sets salt to all zeros if empty' do
      hkdf_blanksalt = HKDF.new(source, :salt => '')
      hkdf_nosalt = HKDF.new(source)
      expect(hkdf_blanksalt.next_bytes(32)).to eq(hkdf_nosalt.next_bytes(32))
    end

    it 'defaults info to an empty string' do
      hkdf_info = HKDF.new(source, :info => '')
      hkdf_noinfo = HKDF.new(source)
      expect(hkdf_info.next_bytes(32)).to eq(hkdf_noinfo.next_bytes(32))
    end
  end

  describe 'max_length' do
    it 'is 255 times the digest length' do
      expect(hkdf.max_length).to eq(255 * 32)
    end
  end

  describe 'next_bytes' do
    it 'raises an error if requested size is > max_length' do
      expect do
        hkdf.next_bytes(hkdf.max_length + 1)
      end.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)

      expect do
        hkdf.next_bytes(hkdf.max_length)
      end.to_not raise_error
    end

    it 'raises an error if requested size + current position is > max_length' do
      expect do
        hkdf.next_bytes(32)
        hkdf.next_bytes(hkdf.max_length - 31)
      end.to raise_error(RangeError, /requested \d+ bytes, only \d+ available/)
    end

    it 'advances the stream position' do
      expect(hkdf.next_bytes(32)).not_to eq(hkdf.next_bytes(32))
    end

    test_vectors.each do |name, options|
      it "matches output from the '#{name}' test vector" do
        options[:algorithm] = options[:Hash]

        hkdf = HKDF.new(options[:IKM], options)
        expect(hkdf.next_bytes(options[:L].to_i)).to eq(options[:OKM])
      end
    end
  end

  describe 'next_hex_bytes' do
    it 'returns the next bytes as hex' do
      expect(hkdf.next_hex_bytes(20)).to eq('fb496612b8cb82cd2297770f83c72b377af16d7b')
    end
  end

  describe 'seek' do
    it 'sets the position anywhere in the stream' do
      hkdf.next_bytes(10)
      output = hkdf.next_bytes(32)
      hkdf.seek(10)
      expect(hkdf.next_bytes(32)).to eq(output)
    end

    it 'raises an error if requested to seek past end of stream' do
      expect { hkdf.seek(hkdf.max_length + 1) }.to raise_error(RangeError, /cannot seek past \d+/)
      expect { hkdf.seek(hkdf.max_length) }.to_not raise_error
    end
  end

  describe 'rewind' do
    it 'resets the stream position to the beginning' do
      output = hkdf.next_bytes(32)
      hkdf.rewind
      expect(hkdf.next_bytes(32)).to eq(output)
    end
  end

  describe 'inspect' do
    it 'returns minimal information' do
      hkdf = HKDF.new('secret', info: 'public')
      expect(hkdf.inspect).to match(/^#<HKDF:0x[\h]+ algorithm="SHA256" info="public">$/)
    end
  end
end
