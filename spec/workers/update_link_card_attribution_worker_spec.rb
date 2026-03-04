# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateLinkCardAttributionWorker do
  let(:worker) { described_class.new }

  let(:account) { Fabricate(:account, attribution_domains: ['writer.example.com']) }

  describe '#perform' do
    let!(:preview_card) { Fabricate(:preview_card, url: 'https://writer.example.com/article', unverified_author_account: account, author_account: nil) }
    let!(:unattributable_preview_card) { Fabricate(:preview_card, url: 'https://otherwriter.example.com/article', unverified_author_account: account, author_account: nil) }
    let!(:unrelated_preview_card) { Fabricate(:preview_card) }

    it 'reattributes expected preview cards' do
      expect { worker.perform(account.id) }
        .to change { preview_card.reload.author_account }.from(nil).to(account)
        .and not_change { unattributable_preview_card.reload.author_account }
        .and(not_change { unrelated_preview_card.reload.author_account })
    end
  end
end
