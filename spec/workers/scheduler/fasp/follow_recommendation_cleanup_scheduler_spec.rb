# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scheduler::Fasp::FollowRecommendationCleanupScheduler do
  let(:worker) { described_class.new }

  describe '#perform', feature: :fasp do
    before do
      Fabricate(:fasp_follow_recommendation, created_at: 2.days.ago)
    end

    it 'deletes outdated recommendations' do
      expect { worker.perform }.to change(Fasp::FollowRecommendation, :count).by(-1)
    end
  end
end
