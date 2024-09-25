# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemCheck::RulesCheck do
  subject(:check) { described_class.new(user) }

  let(:user) { Fabricate(:user) }

  describe 'skip?' do
    context 'when user can manage rules' do
      before { allow(user).to receive(:can?).with(:manage_rules).and_return(true) }

      it 'returns false' do
        expect(check.skip?).to be false
      end
    end

    context 'when user cannot manage rules' do
      before { allow(user).to receive(:can?).with(:manage_rules).and_return(false) }

      it 'returns true' do
        expect(check.skip?).to be true
      end
    end
  end

  describe 'pass?' do
    context 'when there is not a kept rule' do
      it 'returns false' do
        expect(check.pass?).to be false
      end
    end

    context 'when there is a kept rule' do
      before { Fabricate(:rule) }

      it 'returns true' do
        expect(check.pass?).to be true
      end
    end
  end

  describe 'message' do
    it 'sends class name symbol to message instance' do
      allow(Admin::SystemCheck::Message).to receive(:new).with(:rules_check, nil, '/admin/rules')

      check.message

      expect(Admin::SystemCheck::Message).to have_received(:new).with(:rules_check, nil, '/admin/rules')
    end
  end
end
