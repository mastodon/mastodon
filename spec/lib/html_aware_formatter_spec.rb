# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HtmlAwareFormatter do
  describe '#to_s' do
    subject { described_class.new(text, local).to_s }

    context 'when local' do
      let(:local) { true }
      let(:text) { 'Foo bar' }

      it 'returns formatted text' do
        expect(subject).to eq '<p>Foo bar</p>'
      end
    end

    context 'when remote' do
      let(:local) { false }

      context 'when given plain text' do
        let(:text) { 'Beep boop' }

        it 'keeps the plain text' do
          expect(subject).to include 'Beep boop'
        end
      end

      context 'when given text containing script tags' do
        let(:text) { '<script>alert("Hello")</script>' }

        it 'strips the scripts' do
          expect(subject).to_not include '<script>alert("Hello")</script>'
        end
      end

      context 'when given text containing malicious classes' do
        let(:text) { '<span class="mention  status__content__spoiler-link">Show more</span>' }

        it 'strips the malicious classes' do
          expect(subject).to_not include 'status__content__spoiler-link'
        end
      end

      context 'when given text containing ruby tags for east-asian languages' do
        let(:text) { '<ruby>明日 <rp>(</rp><rt>Ashita</rt><rp>)</rp></ruby>' }

        it 'keeps the ruby tags' do
          expect(subject).to eq '<ruby>明日 <rp>(</rp><rt>Ashita</rt><rp>)</rp></ruby>'
        end
      end
    end
  end
end
