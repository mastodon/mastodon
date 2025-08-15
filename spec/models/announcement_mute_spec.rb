# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementMute do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).inverse_of(:announcement_mutes) }
    it { is_expected.to belong_to(:announcement).inverse_of(:announcement_mutes) }
  end

  describe 'Validations' do
    subject { Fabricate.build :announcement_mute }

    it { is_expected.to validate_uniqueness_of(:account_id).scoped_to(:announcement_id) }
  end
end
