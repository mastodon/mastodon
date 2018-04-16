require "spec_helper"

describe PostPolicy do
  let(:user) { double }
  let(:own_post) { double(user: user) }
  let(:other_post) { double(user: double) }
  subject { described_class }

  permissions :update?, :show? do
    it "is successful when all permissions match" do
      should permit(user, own_post)
    end

    it "fails when any permissions do not match" do
      expect do
        should permit(user, other_post)
      end.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end
  end
end
