# frozen_string_literal: true

shared_examples 'Settings-extended' do
  describe 'settings' do
    def fabricate
      super.settings
    end

    def create!
      super.settings
    end

    it_behaves_like 'ScopedSettings'
  end
end
