# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Metrics::Dimension::SpaceUsageDimension do
  subject { described_class.new(start_at, end_at, limit, params) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:limit) { 10 }
  let(:params) { ActionController::Parameters.new }

  let(:redis_human_key) { 'Redis' }
  let(:redis_info) { { 'redis_version' => '7.4.5', 'used_memory' => 1_024 } }

  describe '#data' do
    shared_examples 'shared behavior' do
      before do
        allow(subject).to receive(:redis_info).and_return(redis_info) # rubocop:disable RSpec/SubjectStub
      end

      it 'reports on used storage space' do
        expect(subject.data.map(&:symbolize_keys))
          .to include(
            include(key: 'media', value: /\d/),
            include(key: 'postgresql', value: /\d/),
            include(key: 'redis', human_key: redis_human_key, value: /\d/)
          )
      end
    end

    context 'when using redis' do
      it_behaves_like 'shared behavior'
    end

    context 'when using valkey' do
      let(:redis_human_key) { 'Valkey' }
      let(:redis_info) { { 'valkey_version' => '8.1.3', 'used_memory' => 1_024 } }

      it_behaves_like 'shared behavior'
    end

    context 'when using dragonfly' do
      let(:redis_human_key) { 'Dragonfly' }
      let(:redis_info) { { 'dragonfly_version' => 'df-v1.32.0', 'used_memory' => 1_024 } }

      it_behaves_like 'shared behavior'
    end
  end
end
