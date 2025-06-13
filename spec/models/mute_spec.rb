# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mute do
  it_behaves_like 'Expireable'

  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
    it { is_expected.to belong_to(:target_account).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :mute }

    it { is_expected.to validate_uniqueness_of(:account_id).scoped_to(:target_account_id) }
  end
end
