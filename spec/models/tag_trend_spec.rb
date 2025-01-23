# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagTrend do
  include_examples 'RankedTrend'

  describe 'Associations' do
    it { is_expected.to belong_to(:tag).required }
  end
end
