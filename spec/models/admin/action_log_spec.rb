# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLog do
  describe '#action' do
    it 'returns action' do
      action_log = described_class.new(action: 'hoge')
      expect(action_log.action).to be :hoge
    end
  end
end
