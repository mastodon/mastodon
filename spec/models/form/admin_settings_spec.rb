# frozen_string_literal: true

require 'rails_helper'

describe Form::AdminSettings do
  describe 'validations' do
    describe 'site_contact_username' do
      context 'with no accounts' do
        it 'is not valid' do
          setting = described_class.new(site_contact_username: 'Test')
          setting.valid?

          expect(setting).to model_have_error_on_field(:site_contact_username)
        end
      end

      context 'with an account' do
        before { Fabricate(:account, username: 'Glorp') }

        it 'is not valid when account doesnt match' do
          setting = described_class.new(site_contact_username: 'Test')
          setting.valid?

          expect(setting).to model_have_error_on_field(:site_contact_username)
        end

        it 'is valid when account matches' do
          setting = described_class.new(site_contact_username: 'Glorp')
          setting.valid?

          expect(setting).to_not model_have_error_on_field(:site_contact_username)
        end
      end
    end
  end
end
