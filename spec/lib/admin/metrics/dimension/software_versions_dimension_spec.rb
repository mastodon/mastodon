# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Dimension::SoftwareVersionsDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }
  let(:redis_human_key) { 'Redis' }
  let(:redis_version) { '7.4.5' }
  let(:redis_info) { { 'redis_version' => redis_version } }

  describe '#data' do
    shared_examples 'shared behavior' do
      before do
        allow(subject).to receive(:redis_info).and_return(redis_info) # rubocop:disable RSpec/SubjectStub
      end

      it 'reports on the running software' do
        expect(subject.data.map(&:symbolize_keys))
          .to include(
            include(key: 'mastodon', value: Mastodon::Version.to_s),
            include(key: 'ruby', value: include(RUBY_VERSION)),
            include(key: 'redis', human_key: redis_human_key, value: redis_version)
          )
      end
    end

    context 'when using redis' do
      it_behaves_like 'shared behavior'
    end

    context 'when using valkey' do
      let(:redis_human_key) { 'Valkey' }
      let(:redis_version) { '8.1.3' }
      let(:redis_info) { { 'valkey_version' => redis_version } }

      it_behaves_like 'shared behavior'
    end

    context 'when using dragonfly' do
      let(:redis_human_key) { 'Dragonfly' }
      let(:redis_version) { 'df-v1.32.0' }
      let(:redis_info) { { 'dragonfly_version' => redis_version } }

      it_behaves_like 'shared behavior'
    end
  end
end
