# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagTrend do
  it_behaves_like 'RankedTrend'

  describe 'Associations' do
    it { is_expected.to belong_to(:tag).required }
  end
end
