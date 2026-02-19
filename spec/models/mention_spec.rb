# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mention do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:status).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :mention }

    it { is_expected.to validate_uniqueness_of(:account_id).scoped_to(:status_id) }
  end
end
