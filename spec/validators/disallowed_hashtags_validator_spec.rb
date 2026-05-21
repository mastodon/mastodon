# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisallowedHashtagsValidator do
  subject { Fabricate.build :status }

  let(:tag_string) { 'ok #a #b #c then' }

  context 'when local' do
    before { subject.local = true }

    context 'when reblog? is true' do
      before { subject.reblog = Fabricate(:status) }

      it { is_expected.to allow_values(nil, tag_string).for(:text) }
    end

    context 'when reblog? is false' do
      context 'when text does not contain unusable tags' do
        it { is_expected.to allow_values('text', tag_string).for(:text) }
      end

      context 'when text contains unusable tags' do
        before { Fabricate :tag, name: 'a', usable: false }

        it { is_expected.to_not allow_values(tag_string).for(:text).with_message(disallow_message) }

        def disallow_message
          I18n.t('statuses.disallowed_hashtags', tags: 'a', count: 1)
        end
      end
    end
  end

  context 'when remote' do
    before { subject.local = false }

    context 'when reblog? is true' do
      before { subject.reblog = Fabricate(:status) }

      it { is_expected.to allow_values(nil, tag_string).for(:text) }
    end

    context 'when reblog? is false' do
      it { is_expected.to allow_values('text', tag_string).for(:text) }
    end
  end
end
