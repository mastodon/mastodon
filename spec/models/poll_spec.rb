require 'rails_helper'

RSpec.describe Poll, type: :model do

  describe "validations" do
    context "when valid" do
      let(:subject) { Fabricate.build(:poll) }
      it "is valid with valid attributes" do
        expect(subject).to be_valid
      end
    end

    context "when not valid" do
      let(:subject) { Fabricate.build(:poll, expires_at: nil) }
      it 'is invalid without an expire date' do
        subject.valid?
        expect(subject).to model_have_error_on_field(:expires_at)
      end
    end
  end
end
