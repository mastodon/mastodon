# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::Extend do
  class User
    include Settings::Extend
  end

  describe '#settings' do
    it 'sets @settings as an instance of Settings::ScopedSettings' do
      user = Fabricate(:user)
      expect(user.settings).to be_kind_of Settings::ScopedSettings
    end
  end
end
