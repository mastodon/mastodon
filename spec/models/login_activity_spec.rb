# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginActivity do
  include_examples 'BrowserDetection'

  describe 'Associations' do
    it { is_expected.to belong_to(:user).required }
  end

  describe 'Validations' do
    subject { Fabricate.build :login_activity }

    it { is_expected.to define_enum_for(:authentication_method).backed_by_column_of_type(:string) }
  end
end
