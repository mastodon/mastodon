# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck do
  let(:user) { Fabricate(:user) }

  describe 'perform' do
    let(:result) { described_class.perform(user) }

    it 'runs all the checks' do
      expect(result).to be_an(Array)
    end
  end
end
