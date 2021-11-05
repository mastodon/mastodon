require 'rails_helper'

RSpec.describe LinkDetailsExtractor do
  let(:original_url) { '' }
  let(:html) { '' }
  let(:html_charset) { nil }

  subject { described_class.new(original_url, html, html_charset) }

  describe '#canonical_url' do
    let(:original_url) { 'https://foo.com/article?bar=baz123' }

    context 'when canonical URL points to another host' do
      let(:html) { '<!doctype html><link rel="canonical" href="https://bar.com/different-article" />' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq original_url
      end
    end

    context 'when canonical URL points to the same host' do
      let(:html) { '<!doctype html><link rel="canonical" href="https://foo.com/article" />' }

      it 'ignores the canonical URLs' do
        expect(subject.canonical_url).to eq 'https://foo.com/article'
      end
    end
  end
end
