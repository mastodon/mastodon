# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Invitations' do
  describe 'Associations' do
    it { is_expected.to belong_to(:invite).optional.counter_cache(:uses) }
    it { is_expected.to have_many(:invites).inverse_of(:user).dependent(false) }
    it { is_expected.to have_one(:invite_request).inverse_of(:user).dependent(:destroy).class_name(UserInviteRequest) }
  end
end
