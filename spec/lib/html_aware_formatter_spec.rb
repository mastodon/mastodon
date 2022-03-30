require 'rails_helper'

RSpec.describe HtmlAwareFormatter do
  describe '#to_s' do
    subject { described_class.new(text, local).to_s }

    context 'when local' do
      let(:local) { true }
      let(:text) { 'Foo bar' }

      it 'returns formatted text' do
        is_expected.to eq '<p>Foo bar</p>'
      end
    end

    context 'when remote' do
      let(:local) { false }

      context 'given plain text' do
        let(:text) { 'Beep boop' }

        it 'keeps the plain text' do
          is_expected.to include 'Beep boop'
        end
      end

      context 'given text containing script tags' do
        let(:text) { '<script>alert("Hello")</script>' }

        it 'strips the scripts' do
          is_expected.to_not include '<script>alert("Hello")</script>'
        end
      end

      context 'given text containing malicious classes' do
        let(:text) { '<span class="mention  status__content__spoiler-link">Show more</span>' }

        it 'strips the malicious classes' do
          is_expected.to_not include 'status__content__spoiler-link'
        end
      end
    end
  end
end
