# frozen_string_literal: true

require 'rails_helper'

describe MediaComponentHelper do
  before { helper.extend controller_helpers }

  describe 'render_video_component' do
    let(:media) { Fabricate(:media_attachment, type: :video, status: Fabricate(:status)) }
    let(:result) { helper.render_video_component(media.status) }

    it 'renders a react component for the video' do
      expect(parsed_html.div['data-component']).to eq('Video')
    end
  end

  describe 'render_audio_component' do
    let(:media) { Fabricate(:media_attachment, type: :audio, status: Fabricate(:status)) }
    let(:result) { helper.render_audio_component(media.status) }

    it 'renders a react component for the audio' do
      expect(parsed_html.div['data-component']).to eq('Audio')
    end
  end

  describe 'render_media_gallery_component' do
    let(:media) { Fabricate(:media_attachment, type: :audio, status: Fabricate(:status)) }
    let(:result) { helper.render_media_gallery_component(media.status) }

    it 'renders a react component for the media gallery' do
      expect(parsed_html.div['data-component']).to eq('MediaGallery')
    end
  end

  describe 'render_card_component' do
    let(:status) { Fabricate(:status) }
    let(:result) { helper.render_card_component(status) }

    before do
      PreviewCardsStatus.create(status: status, preview_card: Fabricate(:preview_card))
    end

    it 'returns the correct react component markup' do
      expect(parsed_html.div['data-component']).to eq('Card')
    end
  end

  describe 'render_poll_component' do
    let(:status) { Fabricate(:status, poll: Fabricate(:poll)) }
    let(:result) { helper.render_poll_component(status) }

    it 'returns the correct react component markup' do
      expect(parsed_html.div['data-component']).to eq('Poll')
    end
  end

  private

  def parsed_html
    Nokogiri::Slop(result)
  end

  def controller_helpers
    Module.new do
      def current_account = Account.last
    end
  end
end
