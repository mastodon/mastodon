# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  describe 'Validations' do
    subject { Fabricate.build :collection }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:description) }

    context 'when collection is remote' do
      subject { Fabricate.build :collection, local: false }

      it { is_expected.to validate_presence_of(:uri) }

      it { is_expected.to validate_presence_of(:remote_items) }
    end
  end
end
