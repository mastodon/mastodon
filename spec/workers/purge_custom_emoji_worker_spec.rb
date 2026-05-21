# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurgeCustomEmojiWorker do
  let(:worker) { described_class.new }

  let(:domain) { 'evil' }

  before do
    Fabricate(:custom_emoji)
    Fabricate(:custom_emoji, domain: 'example.com')
    Fabricate.times(5, :custom_emoji, domain: domain)
  end

  describe '#perform' do
    context 'when domain is nil' do
      it 'does not delete emojis' do
        expect { worker.perform(nil) }
          .to_not(change(CustomEmoji, :count))
      end
    end

    context 'when passing a domain' do
      it 'deletes emojis from this domain only' do
        expect { worker.perform(domain) }
          .to change { CustomEmoji.where(domain: domain).count }.to(0)
          .and not_change { CustomEmoji.local.count }
          .and(not_change { CustomEmoji.where(domain: 'example.com').count })
      end
    end
  end
end
