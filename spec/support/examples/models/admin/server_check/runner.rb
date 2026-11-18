# frozen_string_literal: true

RSpec.shared_examples 'a check runner available to devops users' do
  describe '#authorized?' do
    context 'when user can view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(true) }

      it 'returns true' do
        expect(runner.authorized?(user)).to be(true)
      end
    end

    context 'when user cannot view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(false) }

      it 'returns false' do
        expect(runner.authorized?(user)).to be(false)
      end
    end
  end
end
