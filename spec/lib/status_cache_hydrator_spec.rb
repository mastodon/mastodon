# frozen_string_literal: true

require 'rails_helper'

describe StatusCacheHydrator do
  let(:status)  { Fabricate(:status) }
  let(:account) { Fabricate(:account) }

  describe '#hydrate' do
    subject { described_class.new(status).hydrate(account.id) }

    let(:compare_to_hash) { InlineRenderer.render(status, account, :status) }

    context 'when cache is warm' do
      before do
        Rails.cache.write("fan-out/#{status.id}", InlineRenderer.render(status, nil, :status))
      end

      it 'renders the same attributes as a full render' do
        expect(subject).to include(compare_to_hash)
      end
    end

    context 'when cache is cold' do
      before do
        Rails.cache.delete("fan-out/#{status.id}")
      end

      it 'renders the same attributes as a full render' do
        expect(subject).to include(compare_to_hash)
      end
    end

    context 'when account has favourited status' do
      before do
        FavouriteService.new.call(account, status)
      end

      it 'renders the same attributes as a full render' do
        expect(subject).to include(compare_to_hash)
      end
    end

    context 'when account has reblogged status' do
      before do
        ReblogService.new.call(account, status)
      end

      it 'renders the same attributes as a full render' do
        expect(subject).to include(compare_to_hash)
      end
    end
  end
end
