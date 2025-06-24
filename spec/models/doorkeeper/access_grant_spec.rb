# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::AccessGrant do
  describe 'Validations' do
    subject { Fabricate :access_grant }

    it { is_expected.to validate_presence_of(:application_id) }
    it { is_expected.to validate_presence_of(:expires_in) }
    it { is_expected.to validate_presence_of(:redirect_uri) }
    it { is_expected.to validate_presence_of(:token) }
  end
end
