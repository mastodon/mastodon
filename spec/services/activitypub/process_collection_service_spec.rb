require 'rails_helper'

RSpec.describe ActivityPub::ProcessCollectionService do
  subject { described_class.new }

  describe '#call' do
    context 'when actor is the sender'
    context 'when actor differs from sender'
  end
end
