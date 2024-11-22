# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RedownloadMediaWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    it 'returns nil for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be_nil
    end

    it 'returns nil without a remote_url' do
      media_attachment = Fabricate(:media_attachment, remote_url: '')

      result = worker.perform(media_attachment.id)

      expect(result).to be_nil
    end

    context 'with a valid remote url' do
      let(:url) { 'https://example.host/file.txt' }

      before { stub_request(:get, url).to_return(status: 200) }

      it 'processes downloads for valid record' do
        media_attachment = Fabricate(:media_attachment, remote_url: url)

        worker.perform(media_attachment.id)

        expect(a_request(:get, url)).to have_been_made
      end
    end
  end
end
