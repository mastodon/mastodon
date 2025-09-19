# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusDescriptionPresenter do
  describe '#description' do
    subject { described_class.new(status).description }

    context 'when status has blank text' do
      let(:status) { Fabricate.build :status, text: '' }

      it { is_expected.to be_blank }
    end

    context 'when status has text' do
      let(:status) { Fabricate.build :status, text: 'Hello there' }

      it { is_expected.to eq('Hello there') }
    end

    context 'when status has spoilers' do
      let(:status) { Fabricate.build :status, text: 'Hello there', spoiler_text: 'SPOILERS!!!' }

      it { is_expected.to eq(I18n.t('statuses.content_warning', warning: 'SPOILERS!!!')) }
    end

    context 'when status has media attachments' do
      let(:status) { Fabricate.build :status, text: 'Hello there' }

      before do
        Fabricate :media_attachment, status:, type: :video
        Fabricate.times 2, :media_attachment, status:, type: :audio
        Fabricate :media_attachment, status:, type: :image
      end

      it { is_expected.to eq("Attached: 1 image · 1 video · 2 audio\n\nHello there") }
    end

    context 'when status has a poll' do
      let(:preloadable_poll) { Fabricate.build(:poll, options: %w(One Two)) }
      let(:status) { Fabricate.build :status, text: 'Hello there', preloadable_poll: }

      it { is_expected.to eq("Hello there\n\n[ ] One\n[ ] Two") }
    end
  end
end
