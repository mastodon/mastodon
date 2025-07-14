# frozen_string_literal: true

RSpec.shared_examples 'Recommendation Maintenance' do
  describe 'Callbacks' do
    describe 'Maintaining the cache' do
      let(:account) { Fabricate :account }
      let(:cache_key) { "follow_recommendations/#{account.id}" }

      before { Rails.cache.write(cache_key, 123) }

      it 'purges the cache value when record saved' do
        expect { Fabricate factory_name, account: account }
          .to(change { Rails.cache.exist?(cache_key) }.from(true).to(false))
      end

      def factory_name
        described_class.name.underscore.to_sym
      end
    end
  end
end
