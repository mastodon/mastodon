# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusesHelper do
  describe 'status_text_summary' do
    context 'with blank text' do
      let(:status) { Status.new(spoiler_text: '') }

      it 'returns immediately with nil' do
        result = helper.status_text_summary(status)
        expect(result).to be_nil
      end
    end

    context 'with present text' do
      let(:status) { Status.new(spoiler_text: 'SPOILERS!!!') }

      it 'returns the content warning' do
        result = helper.status_text_summary(status)
        expect(result).to eq(I18n.t('statuses.content_warning', warning: 'SPOILERS!!!'))
      end
    end
  end

  describe '#media_summary' do
    it 'describes the media on a status' do
      status = Fabricate :status
      Fabricate :media_attachment, status: status, type: :video
      Fabricate :media_attachment, status: status, type: :audio
      Fabricate :media_attachment, status: status, type: :image

      result = helper.media_summary(status)

      expect(result).to eq('Attached: 1 image · 1 video · 1 audio')
    end
  end

  describe 'visibility_icon' do
    context 'with a status that is public' do
      let(:status) { Status.new(visibility: 'public') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('globe')
      end
    end

    context 'with a status that is unlisted' do
      let(:status) { Status.new(visibility: 'unlisted') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock_open')
      end
    end

    context 'with a status that is private' do
      let(:status) { Status.new(visibility: 'private') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('lock')
      end
    end

    context 'with a status that is direct' do
      let(:status) { Status.new(visibility: 'direct') }

      it 'returns the correct fa icon' do
        result = helper.visibility_icon(status)

        expect(result).to match('alternate_email')
      end
    end
  end
end
