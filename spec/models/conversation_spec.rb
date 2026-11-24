# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation do
  describe '#local?' do
    subject { Fabricate.build :conversation, uri: }

    context 'when uri is nil' do
      let(:uri) { nil }

      it { is_expected.to be_local }
    end

    context 'when uri is set' do
      let(:uri) { 'abc' }

      it { is_expected.to_not be_local }
    end
  end
end
