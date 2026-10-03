# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelayPreference do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:relay).required }
  end
end
