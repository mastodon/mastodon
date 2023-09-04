# frozen_string_literal: true

require 'rails_helper'

describe RemoveFeaturedTagWorker do
  let(:worker) { described_class.new }

  describe 'perform' do
    it 'runs without error for missing record' do
      account_id = nil
      featured_tag_id = nil
      expect { worker.perform(account_id, featured_tag_id) }.to_not raise_error
    end
  end
end
