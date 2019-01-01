# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisallowedHashtagsValidator, type: :validator do
  describe '#validate' do
    before do
      allow_any_instance_of(described_class).to receive(:select_tags) { tags }
      described_class.new.validate(status)
    end

    let(:status) { double(errors: errors, local?: local, reblog?: reblog, text: '') }
    let(:errors) { double(add: nil) }

    context 'unless status.local? && !status.reblog?' do
      let(:local)  { false }
      let(:reblog) { true }

      it 'not calls errors.add' do
        expect(errors).not_to have_received(:add).with(:text, any_args)
      end
    end

    context 'status.local? && !status.reblog?' do
      let(:local)  { true }
      let(:reblog) { false }

      context 'tags.empty?' do
        let(:tags) { [] }

        it 'not calls errors.add' do
          expect(errors).not_to have_received(:add).with(:text, any_args)
        end
      end

      context '!tags.empty?' do
        let(:tags) { %w(a b c) }

        it 'calls errors.add' do
          expect(errors).to have_received(:add)
            .with(:text, I18n.t('statuses.disallowed_hashtags', tags: tags.join(', '), count: tags.size))
        end
      end
    end
  end
end
