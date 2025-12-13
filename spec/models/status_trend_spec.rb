# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusTrend do
  it_behaves_like 'RankedTrend'

  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:status).required }
  end
end
