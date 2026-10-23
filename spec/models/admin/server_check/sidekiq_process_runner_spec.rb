# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::SidekiqProcessRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }
  let(:queues) { described_class::SIDEKIQ_QUEUES }
  let(:process_set) { queues.map { |queue| { 'queues' => [queue] } } }

  it_behaves_like 'a check runner available to devops users'

  describe '#run' do
    subject(:result) { runner.run }

    context 'when missing queues is empty' do
      before do
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
      end

      it { is_expected.to be_ok }
    end

    context 'when missing queues is not empty' do
      let(:queues) { %w(default push mailers pull) }

      before do
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(process_set)
      end

      it { is_expected.to be_pending }

      it 'sets the missing queues as extra data' do
        expect(result.data).to include(missing_queues: %w(scheduler ingress fasp))
      end
    end
  end
end
