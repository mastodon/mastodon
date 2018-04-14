require 'spec_helper_integration'

describe Doorkeeper::DashboardHelper do
  describe '#doorkeeper_errors_for' do
    let(:object) { double errors: { method: messages } }
    let(:messages) { ['first message', 'second message'] }

    context 'when object has errors' do
      it 'returns error messages' do
        messages.each do |message|
          expect(helper.doorkeeper_errors_for(object, :method)).to include(
            message.capitalize
          )
        end
      end
    end

    context 'when object has no errors' do
      it 'returns nil' do
        expect(helper.doorkeeper_errors_for(object, :amonter_method)).to be_nil
      end
    end
  end
end
