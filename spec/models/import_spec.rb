# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:data) }
  end
end
