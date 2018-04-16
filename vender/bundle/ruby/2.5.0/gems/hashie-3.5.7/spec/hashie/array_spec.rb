require 'spec_helper'

describe Array do
  with_minimum_ruby('2.3.0') do
    describe '#dig' do
      let(:array) { Hashie::Array.new([:a, :b, :c]) }

      it 'works with a string index' do
        expect(array.dig('0')).to eq(:a)
      end

      it 'works with a numeric index' do
        expect(array.dig(1)).to eq(:b)
      end

      context 'when array is empty' do
        let(:array) { Hashie::Array.new([]) }

        it 'works with a first numeric and next string index' do
          expect(array.dig(0, 'hello')).to eq(nil)
        end

        it 'throws an error with first string and next numeric index' do
          expect { array.dig('hello', 0) }.to raise_error(TypeError)
        end
      end
    end
  end
end
