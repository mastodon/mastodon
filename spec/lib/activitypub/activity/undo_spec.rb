require 'rails_helper'

RSpec.describe ActivityPub::Activity::Undo do
  let(:sender) { Fabricate(:account) }

  describe '#perform' do
    context 'with Announce' do
      pending
    end

    context 'with Block' do
      pending
    end

    context 'with Follow' do
      pending
    end

    context 'with Like' do
      pending
    end
  end
end
