# frozen_string_literal: true

shared_examples 'a check available to devops users' do
  describe 'skip?' do
    context 'when user can view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(true) }

      it 'returns false' do
        expect(check.skip?).to be false
      end
    end

    context 'when user cannot view devops' do
      before { allow(user).to receive(:can?).with(:view_devops).and_return(false) }

      it 'returns true' do
        expect(check.skip?).to be true
      end
    end
  end
end
