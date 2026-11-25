# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaPlayerHelper do
  describe '#media_player_card_type' do
    subject { helper.media_player_card_type(status) }

    let(:status) { Status.new }

    before { status.media_attachments.build(type:) }

    context 'with a video attachment' do
      let(:type) { :video }

      it { is_expected.to eq('player') }
    end

    context 'with an image attachment' do
      let(:type) { :image }

      it { is_expected.to eq('summary_large_image') }
    end
  end
end
