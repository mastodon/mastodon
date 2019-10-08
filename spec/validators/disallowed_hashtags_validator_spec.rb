# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisallowedHashtagsValidator, type: :validator do
  let(:disallowed_tags) { [] }

  describe '#validate' do
    before do
      disallowed_tags.each { |name| Fabricate(:tag, name: name, usable: false) }
      described_class.new.validate(status)
    end

    let(:status) { double(errors: errors, local?: local, reblog?: reblog, text: disallowed_tags.map { |x| '#' + x }.join(' ')) }
    let(:errors) { double(add: nil) }

    context 'for a remote reblog' do
      let(:local)  { false }
      let(:reblog) { true }

      it 'does not add errors' do
        expect(errors).not_to have_received(:add).with(:text, any_args)
      end
    end

    context 'for a local original status' do
      let(:local)  { true }
      let(:reblog) { false }

      context 'when does not contain any disallowed hashtags' do
        let(:disallowed_tags) { [] }

        it 'does not add errors' do
          expect(errors).not_to have_received(:add).with(:text, any_args)
        end
      end

      context 'when contains disallowed hashtags' do
        let(:disallowed_tags) { %w(a b c) }

        it 'adds an error' do
          expect(errors).to have_received(:add)
            .with(:text, I18n.t('statuses.disallowed_hashtags', tags: disallowed_tags.join(', '), count: disallowed_tags.size))
        end
      end
    end
  end
end
