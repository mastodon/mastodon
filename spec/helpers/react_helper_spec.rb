# frozen_string_literal: true

require 'rails_helper'

describe ReactHelper do
  describe 'render_video_component' do
    let(:media) { Fabricate(:media_attachment, type: :video, status: Fabricate(:status)) }
    let(:result) { helper.render_video_component(media.status) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
    end

    it 'renders a react component for the video' do
      expect(parsed_html.div['data-component']).to eq('Video')
    end
  end

  describe 'render_audio_component' do
    let(:media) { Fabricate(:media_attachment, type: :audio, status: Fabricate(:status)) }
    let(:result) { helper.render_audio_component(media.status) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
    end

    it 'renders a react component for the audio' do
      expect(parsed_html.div['data-component']).to eq('Audio')
    end
  end

  describe 'render_media_gallery_component' do
    let(:media) { Fabricate(:media_attachment, type: :audio, status: Fabricate(:status)) }
    let(:result) { helper.render_media_gallery_component(media.status) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
    end

    it 'renders a react component for the media gallery' do
      expect(parsed_html.div['data-component']).to eq('MediaGallery')
    end
  end

  describe 'render_card_component' do
    let(:status) { Fabricate(:status, preview_cards: [Fabricate(:preview_card)]) }
    let(:result) { helper.render_card_component(status) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(status.account)
      end
    end

    it 'returns the correct react component markup' do
      expect(parsed_html.div['data-component']).to eq('Card')
    end
  end

  describe 'render_poll_component' do
    let(:status) { Fabricate(:status, poll: Fabricate(:poll)) }
    let(:result) { helper.render_poll_component(status) }

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(status.account)
      end
    end

    it 'returns the correct react component markup' do
      expect(parsed_html.div['data-component']).to eq('Poll')
    end
  end

  describe 'react_component' do
    context 'with no block passed in' do
      let(:result) { helper.react_component('name', { one: :two }) }

      it 'returns a tag with data attributes' do
        expect(parsed_html.div['data-component']).to eq('Name')
        expect(parsed_html.div['data-props']).to eq('{"one":"two"}')
      end
    end

    context 'with a block passed in' do
      let(:result) do
        helper.react_component('name', { one: :two }) do
          helper.content_tag(:nav, 'ok')
        end
      end

      it 'returns a tag with data attributes' do
        expect(parsed_html.div['data-component']).to eq('Name')
        expect(parsed_html.div['data-props']).to eq('{"one":"two"}')
        expect(parsed_html.div.nav.content).to eq('ok')
      end
    end
  end

  describe 'react_admin_component' do
    let(:result) { helper.react_admin_component('name', { one: :two }) }

    it 'returns a tag with data attributes' do
      expect(parsed_html.div['data-admin-component']).to eq('Name')
      expect(parsed_html.div['data-props']).to eq('{"locale":"en","one":"two"}')
    end
  end

  private

  def parsed_html
    Nokogiri::Slop(result)
  end
end
