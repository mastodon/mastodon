# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Doorkeeper::AccessToken do
  describe 'Validations' do
    subject { Fabricate :access_token }

    it { is_expected.to validate_presence_of(:token) }
  end
end
