# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomEmojiFilter do
  describe '#results' do
    let!(:custom_emoji_0) { Fabricate(:custom_emoji, domain: 'a') }
    let!(:custom_emoji_1) { Fabricate(:custom_emoji, domain: 'b') }
    let!(:custom_emoji_2) { Fabricate(:custom_emoji, domain: nil, shortcode: 'hoge') }

    subject { described_class.new(params).results }

    context 'params have values' do
      context 'local' do
        let(:params) { { local: true } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_kind_of(ActiveRecord::Relation)
          expect(subject).to match_array([custom_emoji_2])
        end
      end

      context 'remote' do
        let(:params) { { remote: true } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_kind_of(ActiveRecord::Relation)
          expect(subject).to match_array([custom_emoji_0, custom_emoji_1])
        end
      end

      context 'by_domain' do
        let(:params) { { by_domain: 'a' } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_kind_of(ActiveRecord::Relation)
          expect(subject).to match_array([custom_emoji_0])
        end
      end

      context 'shortcode' do
        let(:params) { { shortcode: 'hoge' } }

        it 'returns ActiveRecord::Relation' do
          expect(subject).to be_kind_of(ActiveRecord::Relation)
          expect(subject).to match_array([custom_emoji_2])
        end
      end

      context 'else' do
        let(:params) { { else: 'else' } }

        it 'raises RuntimeError' do
          expect do
            subject
          end.to raise_error(RuntimeError, /Unknown filter: else/)
        end
      end
    end

    context 'params without value' do
      let(:params) { { hoge: nil } }

      it 'returns ActiveRecord::Relation' do
        expect(subject).to be_kind_of(ActiveRecord::Relation)
        expect(subject).to match_array([custom_emoji_0, custom_emoji_1, custom_emoji_2])
      end
    end
  end
end
