# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Favourite::FaspConcern, feature: :fasp do
  describe '#create' do
    it 'queues a job to notify provider' do
      expect { Fabricate(:favourite) }.to enqueue_sidekiq_job(Fasp::AnnounceTrendWorker)
    end
  end
end
