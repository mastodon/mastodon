# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Invitations' do
  describe 'Associations' do
    it { is_expected.to belong_to(:invite).optional.counter_cache(:uses) }
  end
end
