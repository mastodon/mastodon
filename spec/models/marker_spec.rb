# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Marker do
  describe 'Validations' do
    it { is_expected.to validate_inclusion_of(:timeline).in_array(described_class::TIMELINES) }
  end
end
