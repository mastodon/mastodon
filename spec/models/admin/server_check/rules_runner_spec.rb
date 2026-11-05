# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ServerCheck::RulesRunner do
  subject(:runner) { described_class.new }

  let(:user) { Fabricate(:user) }

  describe '#authorized?' do
    context 'when user can manage rules' do
      before { allow(user).to receive(:can?).with(:manage_rules).and_return(true) }

      it 'returns true' do
        expect(runner.authorized?(user)).to be(true)
      end
    end

    context 'when user cannot manage rules' do
      before { allow(user).to receive(:can?).with(:manage_rules).and_return(false) }

      it 'returns false' do
        expect(runner.authorized?(user)).to be(false)
      end
    end
  end

  describe '#run' do
    subject(:result) { runner.run }

    context 'when there is not any kept rule' do
      it { is_expected.to be_pending }
    end

    context 'when there is a kept rule' do
      before { Fabricate(:rule) }

      it { is_expected.to be_ok }
    end
  end
end
