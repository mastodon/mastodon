# frozen_string_literal: true

require 'rails_helper'

describe ReactHelper do
  describe 'render_video_component' do
    it 'renders a react component for the video' do
      media = Fabricate(:media_attachment, type: :video, status: Fabricate(:status))
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
      result = helper.render_video_component(media.status)
      html = Nokogiri::Slop(result)

      expect(html.div['data-component']).to eq('Video')
    end
  end

  describe 'render_audio_component' do
    it 'renders a react component for the audio' do
      media = Fabricate(:media_attachment, type: :audio, status: Fabricate(:status))
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
      result = helper.render_audio_component(media.status)
      html = Nokogiri::Slop(result)

      expect(html.div['data-component']).to eq('Audio')
    end
  end

  describe 'render_media_gallery_component' do
    it 'renders a react component for the media gallery' do
      media = Fabricate(:media_attachment, type: :audio, status: Fabricate(:status))
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(media.account)
      end
      result = helper.render_media_gallery_component(media.status)
      html = Nokogiri::Slop(result)

      expect(html.div['data-component']).to eq('MediaGallery')
    end
  end

  describe 'render_card_component' do
    it 'returns the correct react component markup' do
      status = Fabricate(:status, preview_cards: [Fabricate(:preview_card)])
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(status.account)
      end
      result = helper.render_card_component(status)
      html = Nokogiri::Slop(result)

      expect(html.div['data-component']).to eq('Card')
    end
  end

  describe 'render_poll_component' do
    it 'returns the correct react component markup' do
      status = Fabricate(:status, poll: Fabricate(:poll))
      without_partial_double_verification do
        allow(helper).to receive(:current_account).and_return(status.account)
      end
      result = helper.render_poll_component(status)
      html = Nokogiri::Slop(result)

      expect(html.div['data-component']).to eq('Poll')
    end
  end

  describe 'react_component' do
    context 'with no block passed in' do
      let(:result) { helper.react_component('name', { one: :two }) }
      let(:html) { Nokogiri::Slop(result) }

      it 'returns a tag with data attributes' do
        expect(html.div['data-component']).to eq('Name')
        expect(html.div['data-props']).to eq('{"one":"two"}')
      end
    end

    context 'with a block passed in' do
      let(:result) do
        helper.react_component('name', { one: :two }) do
          helper.content_tag(:nav, 'ok')
        end
      end
      let(:html) { Nokogiri::Slop(result) }

      it 'returns a tag with data attributes' do
        expect(html.div['data-component']).to eq('Name')
        expect(html.div['data-props']).to eq('{"one":"two"}')
        expect(html.div.nav.content).to eq('ok')
      end
    end
  end

  describe 'react_admin_component' do
    let(:result) { helper.react_admin_component('name', { one: :two }) }
    let(:html) { Nokogiri::Slop(result) }

    it 'returns a tag with data attributes' do
      expect(html.div['data-admin-component']).to eq('Name')
      expect(html.div['data-props']).to eq('{"locale":"en","one":"two"}')
    end
  end
end
