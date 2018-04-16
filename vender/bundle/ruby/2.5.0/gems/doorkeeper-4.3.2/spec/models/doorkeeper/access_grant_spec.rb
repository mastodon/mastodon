require 'spec_helper_integration'

describe Doorkeeper::AccessGrant do
  subject { FactoryBot.build(:access_grant) }

  it { expect(subject).to be_valid }

  it_behaves_like 'an accessible token'
  it_behaves_like 'a revocable token'
  it_behaves_like 'a unique token' do
    let(:factory_name) { :access_grant }
  end

  describe 'validations' do
    it 'is invalid without resource_owner_id' do
      subject.resource_owner_id = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without application_id' do
      subject.application_id = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without token' do
      subject.save
      subject.token = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without expires_in' do
      subject.expires_in = nil
      expect(subject).not_to be_valid
    end
  end
end
