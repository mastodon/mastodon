# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::Application do
  describe 'Associations' do
    it { is_expected.to have_many(:created_users).class_name('User').inverse_of(:created_by_application).with_foreign_key(:created_by_application_id) }
  end

  describe 'Validations' do
    it { is_expected.to validate_length_of(:name).is_at_most(described_class::APP_NAME_LIMIT) }
    it { is_expected.to validate_length_of(:redirect_uri).is_at_most(described_class::APP_REDIRECT_URI_LIMIT) }
    it { is_expected.to validate_length_of(:website).is_at_most(described_class::APP_WEBSITE_LIMIT) }
  end
end
