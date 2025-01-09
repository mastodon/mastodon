# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::BaseCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  describe 'skip?' do
    it 'returns false' do
      expect(check.skip?).to be false
    end
  end

  describe 'pass?' do
    it 'raises not implemented error' do
      expect { check.pass? }.to raise_error(NotImplementedError)
    end
  end

  describe 'message' do
    it 'raises not implemented error' do
      expect { check.message }.to raise_error(NotImplementedError)
    end
  end
end
