# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCardTrend do
  include_examples 'RankedTrend'

  describe 'Associations' do
    it { is_expected.to belong_to(:preview_card).required }
  end
end
